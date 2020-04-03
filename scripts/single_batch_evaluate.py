import argparse
import glob
import logging
import os
import random
import math
import json

import numpy as np
import torch
from torch.utils.data import DataLoader, RandomSampler, SequentialSampler, TensorDataset
from torch.utils.data.distributed import DistributedSampler
from tqdm import tqdm, trange

from transformers import (
    WEIGHTS_NAME,
    AdamW,
    BertConfig,
    BertForMultipleChoice,
    BertTokenizer,
    RobertaConfig,
    RobertaForMultipleChoice,
    RobertaTokenizer,
    XLNetConfig,
    XLNetForMultipleChoice,
    XLNetTokenizer,
    AlbertConfig,
    AlbertTokenizer,
    AlbertForMultipleChoice,
    get_linear_schedule_with_warmup,
)
from utils_multiple_choice import convert_examples_to_features, processors

# Force no unnecessary allocation
import tensorflow as tf
gpus = tf.config.experimental.list_physical_devices('GPU')
for gpu in gpus:
    tf.config.experimental.set_memory_growth(gpu, True)

MODEL_CLASSES = {
    "bert": (BertConfig, BertForMultipleChoice, BertTokenizer),
    "xlnet": (XLNetConfig, XLNetForMultipleChoice, XLNetTokenizer),
    "roberta": (RobertaConfig, RobertaForMultipleChoice, RobertaTokenizer),
    "albert": (AlbertConfig, AlbertForMultipleChoice, AlbertTokenizer),
}

def parse_args():
    parser = argparse.ArgumentParser()

    # Required parameters
    parser.add_argument(
        "--data_dir",
        default=None,
        type=str,
        required=True,
        help="The input data dir. Should contain the .tsv files (or other data files) for the task.",
    )
    parser.add_argument(
        "--data_id",
        default='',
        type=str,
        required=False,
        help="Data id to load (e.g.: 2014-spanish for Entrance Exams,"
        "dev/high for RACE).\nIt is concatenated to data_dir during execution.",
    )
    parser.add_argument(
        "--model_type",
        default=None,
        type=str,
        required=True,
        help="Model type selected in the list: " + ", ".join(MODEL_CLASSES.keys()),
    )
    parser.add_argument(
        "--model_name_or_path",
        default=None,
        type=str,
        required=True,
        help="Path to pre-trained model or shortcut name selected in the list: ",
    )
    parser.add_argument(
        "--task_name",
        default=None,
        type=str,
        required=True,
        help="The name of the task to train selected in the list: " + ", ".join(processors.keys()),
    )
    parser.add_argument(
        "--output_dir",
        default=None,
        type=str,
        required=True,
        help="The output directory where the model predictions and checkpoints will be written.",
    )

    # Other parameters
    parser.add_argument(
        "--config_name", default="", type=str, help="Pretrained config name or path if not the same as model_name"
    )
    parser.add_argument(
        "--tokenizer_name",
        default="",
        type=str,
        help="Pretrained tokenizer name or path if not the same as model_name",
    )
    parser.add_argument(
        "--cache_dir",
        default="",
        type=str,
        help="Where do you want to store the pre-trained models downloaded from s3",
    )
    parser.add_argument(
        "--max_seq_length",
        default=128,
        type=int,
        help="The maximum total input sequence length after tokenization. Sequences longer "
        "than this will be truncated, sequences shorter will be padded.",
    )
    parser.add_argument("--do_train", action="store_true", help="Whether to run training.")
    parser.add_argument("--do_eval", action="store_true", help="Whether to run eval on the dev set.")
    parser.add_argument("--do_test", action="store_true", help="Whether to run test on the test set")
    parser.add_argument(
        "--evaluate_during_training", action="store_true", help="Run evaluation during training at each logging step."
    )
    parser.add_argument(
        "--do_lower_case", action="store_true", help="Set this flag if you are using an uncased model."
    )

    parser.add_argument("--per_gpu_train_batch_size", default=8, type=int, help="Batch size per GPU/CPU for training.")
    parser.add_argument(
        "--per_gpu_eval_batch_size", default=8, type=int, help="Batch size per GPU/CPU for evaluation."
    )
    parser.add_argument(
        "--gradient_accumulation_steps",
        type=int,
        default=1,
        help="Number of updates steps to accumulate before performing a backward/update pass.",
    )
    parser.add_argument("--learning_rate", default=5e-5, type=float, help="The initial learning rate for Adam.")
    parser.add_argument("--weight_decay", default=0.0, type=float, help="Weight deay if we apply some.")
    parser.add_argument("--adam_epsilon", default=1e-8, type=float, help="Epsilon for Adam optimizer.")
    parser.add_argument("--max_grad_norm", default=1.0, type=float, help="Max gradient norm.")
    parser.add_argument(
        "--num_train_epochs", default=3.0, type=float, help="Total number of training epochs to perform."
    )
    parser.add_argument(
        "--max_steps",
        default=-1,
        type=int,
        help="If > 0: set total number of training steps to perform. Override num_train_epochs.",
    )
    parser.add_argument("--warmup_steps", default=0, type=int, help="Linear warmup over warmup_steps.")
    parser.add_argument("--warmup_proportion",
        default=0,
        type=float,
        help="Proportion of steps to apply warmup (exclusive with warmup_steps."
            "E.g., 0.1 = 10%% of training.")

    parser.add_argument("--logging_steps", type=int, default=500, help="Log every X updates steps.")
    parser.add_argument("--save_steps", type=int, default=500, help="Save checkpoint every X updates steps.")
    parser.add_argument(
        "--eval_all_checkpoints",
        action="store_true",
        help="Evaluate all checkpoints starting with the same prefix as model_name ending and ending with step number",
    )
    parser.add_argument("--no_cuda", action="store_true", help="Avoid using CUDA when available")
    parser.add_argument(
        "--overwrite_output_dir", action="store_true", help="Overwrite the content of the output directory"
    )
    parser.add_argument(
        "--overwrite_cache", action="store_true", help="Overwrite the cached training and evaluation sets"
    )
    parser.add_argument("--seed", type=int, default=42, help="random seed for initialization")

    parser.add_argument(
        "--fp16",
        action="store_true",
        help="Whether to use 16-bit (mixed) precision (through NVIDIA apex) instead of 32-bit",
    )
    parser.add_argument(
        "--fp16_opt_level",
        type=str,
        default="O1",
        help="For fp16: Apex AMP optimization level selected in ['O0', 'O1', 'O2', and 'O3']."
        "See details at https://nvidia.github.io/apex/amp.html",
    )
    parser.add_argument(
      "--loss_scale",
      type=float,
      default=0,
      help="Loss scaling to improve fp16 numeric stability. Only used when fp16 set to True.\n"
      "0 (default value): dynamic loss scaling.\n"
      "Positive power of 2: static loss scaling value.\n"
    )
    parser.add_argument("--local_rank", type=int, default=-1, help="For distributed training: local_rank")
    parser.add_argument("--server_ip", type=str, default="", help="For distant debugging.")
    parser.add_argument("--server_port", type=str, default="", help="For distant debugging.")
    return parser.parse_args()

def compute_softmax(scores):

  if not scores:
    return []

  max_score = None
  for score in scores:
    if max_score is None or score > max_score:
      max_score = score

  exp_scores = []
  total_sum = 0.0
  for score in scores:
    x = math.exp(score - max_score)
    exp_scores.append(x)
    total_sum += x

  probs = []
  for score in exp_scores:
    probs.append(score / total_sum)
  return probs

def simple_accuracy(preds, labels):
    return (preds == labels).mean()

def select_field(features, field):
    return [[choice[field] for choice in feature.choices_features] for feature in features]

def load_and_cache_examples(args, task, tokenizer, evaluate=False, test=False):
    processor = processors[task]()
    # Load data features from cache or dataset file
    if evaluate:
        cached_mode = "dev"
    elif test:
        cached_mode = "test"
    else:
        cached_mode = "train"
    assert not (evaluate and test)
    label_list = processor.get_labels()
    full_data_dir = os.path.join(args.data_dir, args.data_id)
    if evaluate:
        examples = processor.get_dev_examples(full_data_dir)
    elif test:
        examples = processor.get_test_examples(full_data_dir)
    else:
        examples = processor.get_train_examples(full_data_dir)
    features = convert_examples_to_features(
        examples,
        label_list,
        args.max_seq_length,
        tokenizer,
        pad_on_left=False,  # pad on the left for xlnet
        pad_token_segment_id=0,
    )

    # Convert to Tensors and build dataset
    all_input_ids = torch.tensor(select_field(features, "input_ids"), dtype=torch.long)
    all_input_mask = torch.tensor(select_field(features, "input_mask"), dtype=torch.long)
    all_segment_ids = torch.tensor(select_field(features, "segment_ids"), dtype=torch.long)
    all_label_ids = torch.tensor([f.label for f in features], dtype=torch.long)
    all_ids = torch.tensor([int(f.example_id) for f in features])

    dataset = TensorDataset(all_input_ids, all_input_mask, all_segment_ids, all_label_ids, all_ids)
    return dataset

def evaluate(args, model, tokenizer, prefix="", test=False, train=True):
    results = {}
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    eval_dataset = load_and_cache_examples(args, args.task_name, tokenizer, evaluate=not test, test=test)

    # Note that DistributedSampler samples randomly
    eval_sampler = SequentialSampler(eval_dataset)
    eval_dataloader = DataLoader(eval_dataset, sampler=eval_sampler,
        batch_size=args.batch_size)

    eval_loss = 0.0
    nb_eval_steps = 0
    preds = None
    out_label_ids = None
    raw_results = []
    for batch in eval_dataloader:
        model.eval()
        batch = tuple(t.to(device) for t in batch)

        with torch.no_grad():
            inputs = {
                "input_ids": batch[0],
                "attention_mask": batch[1],
                "token_type_ids": batch[2],
                "labels": batch[3],
            }
            outputs = model(**inputs)
            tmp_eval_loss, logits = outputs[:2]

            eval_loss += tmp_eval_loss.mean().item()
        nb_eval_steps += 1
        np_logits = logits.detach().cpu().numpy()
        np_label = inputs["labels"].detach().cpu().numpy()

        if preds is None:
            preds = np_logits
            out_label_ids = np_label
        else:
            preds = np.append(preds, np_logits, axis=0)
            out_label_ids = np.append(out_label_ids, np_label, axis=0)

        # up to batch size or remaining examples
        for batch_index in range(len(batch[0])):
            # convert everything to python types to ensure json serializability
            id = int(batch[4][batch_index].detach().cpu().numpy())
            label = int(np_label[batch_index])
            pred_label = int(np.argmax(np_logits[batch_index], axis=0))
            logs = list([d.item() for d in np_logits[batch_index]])
            probs = compute_softmax(list(logs))
            raw_result = dict(id=id, label=label, pred_label=pred_label, logits=logs, probs=probs)
            raw_results.append(raw_result)

    eval_loss = eval_loss / nb_eval_steps
    preds = np.argmax(preds, axis=1)
    acc = simple_accuracy(preds, out_label_ids)
    result = {"eval_acc": acc, "eval_loss": eval_loss}
    results.update(result)

    return results

# args = dict(
#     data_dir=data_dir,
#     data_id=data_id,
#     max_seq_length=max_seq_length,
#     task_name=task_name
# )

class dotdict(dict): 
    """
      dot.notation access to dictionary attributes, useful to load a json
      as object, i.e.: args = dotdict(json.load(open('./args.json', 'r')))
    """ 
    __getattr__ = dict.get 
    __setattr__ = dict.__setitem__ 
    __delattr__ = dict.__delitem__ 

def main():
    args = parse_args()
    
    # dataset processor
    processor = processors[args.task_name]()
    label_list = processor.get_labels()
    num_labels = len(label_list)

    args.model_type = args.model_type.lower()

    if args.model_type in ['xlnet']:
        raise ValueError('Model not supported: %s' % args.model_type)

    args.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

    # model, tokenizer and config
    config_class, model_class, tokenizer_class = MODEL_CLASSES[args.model_type]
    config = config_class.from_pretrained(
        args.config_name if args.config_name else args.model_name_or_path,
        num_labels=num_labels,
        finetuning_task=args.task_name,
        cache_dir=args.cache_dir if args.cache_dir else None,
    )
    tokenizer = tokenizer_class.from_pretrained(
        args.tokenizer_name if args.tokenizer_name else args.model_name_or_path,
        do_lower_case=args.do_lower_case,
        cache_dir=args.cache_dir if args.cache_dir else None,
    )
    model = model_class.from_pretrained(
        args.model_name_or_path,
        from_tf=bool(".ckpt" in args.model_name_or_path),
        config=config,
        cache_dir=args.cache_dir if args.cache_dir else None,
    )
    
    # model = model_class.from_pretrained(checkpoint)

    model.to(args.device)

    args.output_dir = args.model_name_or_path
    global_step = args.output_dir.split("-")[-1] if len(args.output_dir) > 1 else ""
    prefix = args.output_dir.split("/")[-1] if args.output_dir.find("checkpoint") != -1 else ""

    result = evaluate(args, model, tokenizer, prefix=prefix, test=True, train=False)
    result = dict((k + "_{}".format(global_step), v) for k, v in result.items())

