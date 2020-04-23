import os
import sys
import json
import random
import argparse
import numpy as np

from baseline_methods import baselines
from utils_multiple_choice import processors

def parse_args():
  parser = argparse.ArgumentParser()
  parser.add_argument('-t', '--task', help='Task to evaluate with the'
      f'baseline (one of: {list(processors.keys())})', required=True)
  parser.add_argument('-b', '--baselines', nargs='*', help='Baselines to apply'
      f'(one of: {list(baselines.keys())})', default=None)
  parser.add_argument('-d', '--dataset', help='Data to apply Baseline',
      required=True)
  parser.add_argument('-o', '--output', help='Output directory to store'
      'predictions', default='./results/')
  if len(sys.argv) == 1:
    parser.print_help()
    sys.exit(0)
  return parser.parse_args()

def set_seed(seed):
  random.seed(seed)

def simple_accuracy(preds, labels):
  return (np.array(preds) == np.array(labels)).mean()

def apply_baseline_to_examples(examples, baseline):
  # examples := [InputExample].
  # contains contexts (duplicated), endings, question, label, example_id
  # len(endings) == len(contexts). Created that way for commodity inside BERT 
  answers = []
  labels = []
  predictions = []
  for example in examples:
    answer = baseline.get_answer(example.contexts[0], example.question, example.endings)
    answer.update(id=str(example.example_id), label=int(example.label))
    answers.append(answer)
    predictions.append(answer['pred_label'])
    labels.append(int(example.label))

  accuracy = simple_accuracy(predictions, labels)
  return accuracy, answers

def main(args):
  processor = processors[args.task]()
  examples = processor.get_test_examples(args.dataset)
  for baseline_name in args.baselines:
    scores, preds = apply_baseline_to_examples(examples, baselines[baseline_name]())
    pred_file = f'{baseline_name}_baseline_is_test_true_eval_nbest_predictions.json'
    print(f'Baseline `{baseline_name}` obtained score: {scores}, saved predictions to {pred_file}')
    with open(os.path.join(args.output, pred_file), 'w') as fstream:
      fstream.write(json.dumps(preds) + '\n')

if __name__ == '__main__':
  args = parse_args()
  if args.baselines is None:
    args.baselines = list(baselines.keys())
  main(args)

