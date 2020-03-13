"""
implement:
   accuracy
   c@1: https://www.researchgate.net/publication/220873174_A_Simple_Measure_to_Assess_Non-response
"""

import argparse
import json
import sys
from evaluation import c_at_1

flags = None

def parse_flags():
  parser = argparse.ArgumentParser()
  parser.add_argument('data', help='Dataset to evaluate against')
  parser.add_argument('predictions', help='Predictions from model to evaluate')
  parser.add_argument('--output', '-o', 
      help='Output for the predictions, default is stdout')

  if len(sys.argv) == 1:
    parser.print_help()
    sys.exit(1)
  return parser.parse_args()

def flatten(lists):
  return [item for _list in lists for item in _list]

def label_to_id(label):
  return ord(label.upper()) - ord('A')

def gather_answers(dataset):
  id_ans = {}
  for test in dataset:
    id_ans[test['id']] = [label_to_id(ans) for ans in test['answers']]
  return id_ans

def evaluate(gold, flat_gold, predictions, flat_preds):
  no_answer = -1
  passed_tests = 0
  total_tests = len(gold.keys())
  eval_results = {}
  eval_results['c@1'] = c_at_1(flat_gold, flat_preds, no_answer)
  for test_key in gold.keys():
    key = 'test_%s_c@1' % test_key
    eval_results[key] = c_at_1(gold[test_key], predictions[test_key], no_answer)
    if eval_results[key] >= 0.5:
      passed_tests += 1
  eval_results['passed_tests'] = passed_tests
  eval_results['total_tests'] = total_tests
  return eval_results

def main():
  dataset = json.load(open(flags.data))['data']
  gold= gather_answers(dataset)
  flat_gold = flatten(gold.values())
  predictions = json.load(open(flags.predictions))
  flat_preds = flatten(predictions.values())
  eval_results = evaluate(gold, flat_gold, predictions, flat_preds)
  results = json.dumps(eval_results) + '\n'
  if flags.output is None:
    print(results)
  else:
    with open(flags.output, 'w') as f:
      f.write(results)

if __name__ == '__main__':
  flags = parse_flags()
  main()
