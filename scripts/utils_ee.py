import os
import sys
import json
import argparse

flags = None

def parse_flags():
  parser = argparse.ArgumentParser()
  parser.add_argument('--join', '-j', help='Datasets or predictions to join', nargs='*')
  parser.add_argument('--prefix', '-p', help='Prefixes for each file', nargs='*')
  parser.add_argument('--output', '-o', 
      help='Output for compiled dataset, default is stdout')

  if len(sys.argv) == 1:
    parser.print_help()
    sys.exit(1)
  return parser.parse_args()

def fix_ids(dataset, prefix):
  for example in dataset:
    example['id'] = '%s-%s' % (prefix, example['id'])
  return dataset

def preprocess_dataset(dataset):
  # if it's a dataset, it contains a data field with the relevant data,
  # if it's a probs file, it contains just the array with probs
  is_dataset = type(dataset) == dict
  if is_dataset:
    data = dataset.get('data', None)
  else:
    data = dataset
  return data, is_dataset

def join(paths, prefixes):
  data = []
  is_dataset = True
  for path, prefix in zip(paths, prefixes):
    dataset = json.load(open(path, 'r'))
    dataset, is_dataset = preprocess_dataset(dataset)
    if prefix is not None:
      dataset = fix_ids(dataset, prefix)
    data.extend(dataset)
  if is_dataset:
    full_dataset = dict(version='1.0', data=data)
  else:
    full_dataset = data
  str_dataset = json.dumps(obj=full_dataset, ensure_ascii=False) + '\n'
  if flags.output is None:
    print(str_dataset)
  else:
    with open(flags.output, 'w') as f:
      f.write(str_dataset)

if __name__ == '__main__':
  flags = parse_flags()
  prefixes = flags.prefix
  if prefixes is None:
    prefixes = [None] * len(flags.join)
  elif len(prefixes) < len(flags.join):
    prefixes = [prefixes[0]] * len(flags.join)
  join(flags.join, prefixes)

