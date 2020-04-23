import os
import re
import sys
import json
import glob
import argparse

flags = None
partitions = ['high', 'middle', 'all']

"""
  train/dev/test := 01, 02, 03
  high/middle    := 04, 02
  <int>.txt      := int
  /              := 00
"""
reg = re.compile('^.*/RACE/(.*)\.txt$')
replacements = [
  ('train', '01'), ('dev', '02'), ('test', '03'),
  ('high', '04'), ('middle', '05'),
  ('/', '00')
]

def get_paths_from_data_dir(data_dir, partition):
  paths = []
  parts = [partition]
  if partition == 'all':
    parts = partitions[:2]
  for part in parts:
    paths.append(os.path.join(data_dir, part))
  return paths

def encode_race_id(race_id):
  race_id = reg.findall(race_id)[0]
  for repl in replacements:
    race_id = race_id.replace(repl[0], repl[1])
  return int(race_id)

def decode_race_id(race_id):
  race_id = '0' + str(race_id)
  id = race_id[8:] + '.txt'
  race_id = race_id[:8]
  for repl in replacements:
    race_id = race_id.replace(repl[1], repl[0])
  return race_id + id

def read_txt(input_dir):
  lines = []
  files = glob.glob(input_dir + "/*txt")
  for file in files:
    with open(file, "r", encoding="utf-8") as fin:
      data_raw = json.load(fin)
      data_raw['original_id'] = data_raw['id']
      data_raw["id"] = encode_race_id(file)
      lines.append(data_raw)
  return lines

def parse_flags():
  parser = argparse.ArgumentParser()
  parser.add_argument('--encode_id', '-e', help='File name to encode')
  parser.add_argument('--decode_id', '-d', help='Id to decode')
  parser.add_argument('--data', help='Race folder to process (RACE/{train/dev/test}).')
  parser.add_argument('--partition', '-p', help='All/high/middle')
  parser.add_argument('--output', '-o', 
      help='Output for compiled dataset, default is stdout')

  if len(sys.argv) == 1:
    parser.print_help()
    sys.exit(1)
  return parser.parse_args()

def main():
  data = []
  paths = get_paths_from_data_dir(flags.data, flags.partition)
  for path in paths:
    data.extend(read_txt(path))
  dataset = dict(version='1.0', data=data)
  str_dataset = json.dumps(obj=dataset, ensure_ascii=False) + '\n'
  if flags.output is None:
    print(str_dataset)
  else:
    with open(flags.output, 'w') as f:
      f.write(str_dataset)
  
if __name__ == '__main__':
  flags = parse_flags()
  if flags.encode_id is not None:
    print(encode_race_id(flags.encode_id))
  elif flags.decode_id is not None:
    print(decode_race_id(flags.decode_id))
  else:
    if flags.partition not in partitions or flags.data is None:
      raise ValueError
    main()

