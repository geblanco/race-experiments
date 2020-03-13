"""
Extract a predictions file (id: result) from a nbest, just like squad
"""

import json
import argparse
import sys
from collections import defaultdict

flags = None

def parse_flags():
  parser = argparse.ArgumentParser()
  parser.add_argument('nbest_predictions', help='All model predictions')
  parser.add_argument('--output', '-o', 
      help='Output for the predictions, default is stdout')

  if len(sys.argv) == 1:
    parser.print_help()
    sys.exit(1)
  return parser.parse_args()

def main():
  nbest = json.load(open(flags.nbest_file, 'r'))
  ids_ans = defaultdict(list)
  for best in nbest:
    ids_ans[best['id']].append(best['pred_label'])
  result = json.dumps(obj=ids_ans) + '\n'
  if flags.output is None:
    print(result)
  else:
    with open(flags.output, 'w') as f:
      f.write(result)


if __name__ == '__main__':
  flags = parse_flags()
  main()
