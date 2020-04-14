from utils_multiple_choice import RaceProcessor
from utils_multiple_choice import convert_examples_to_features
from transformers import BertTokenizer, BertForMultipleChoice
import torch

proc = RaceProcessor()
samples = proc.get_dev_examples('../../data/RACE/')

label_list = proc.get_labels()
seq_len = 384
pad_on_left = False
pad_token_segment_id = 0

tokenizer = BertTokenizer.from_pretrained('bert-base-uncased')
model = BertForMultipleChoice.from_pretrained('bert-base-uncased')

features = convert_examples_to_features(examples=samples, label_list=label_list, max_length=seq_len, tokenizer=tokenizer, pad_on_left=pad_on_left, pad_token_segment_id=pad_token_segment_id)
top_ten_feat = features[:10]

def select_field(features, field):
    return [[choice[field] for choice in feature.choices_features] for feature in features]

all_input_ids = torch.tensor(select_field(top_ten_feat, "input_ids"), dtype=torch.long)
all_input_mask = torch.tensor(select_field(top_ten_feat, "input_mask"), dtype=torch.long)
all_segment_ids = torch.tensor(select_field(top_ten_feat, "segment_ids"), dtype=torch.long)
all_label_ids = torch.tensor([f.label for f in top_ten_feat], dtype=torch.long)
all_ids = torch.tensor([int(f.example_id) for f in top_ten_feat])

batch = [all_input_ids, all_input_mask, all_segment_ids, all_label_ids, all_ids]

inputs = {
  "input_ids": batch[0],
  "attention_mask": batch[1],
  "token_type_ids": batch[2],
  "labels": batch[3],
}
outputs = model(**inputs)
