"""
implement:
   accuracy
   c@1: https://www.researchgate.net/publication/220873174_A_Simple_Measure_to_Assess_Non-response
"""

import argparse
import json
import sys
from evaluation import c_at_1
from threshold import apply_threshold
from utils import parse_predictions_file, gather_labels, sort_dict

flags = None
no_answer = -1

def parse_flags():
  parser = argparse.ArgumentParser()
  parser.add_argument('data', help='Dataset to evaluate against')
  parser.add_argument('predictions', help='Predictions from model to evaluate')
  parser.add_argument('--threshold', '-t', default=0.0, type=float,
    help='Threshold above which to give an empty answer')
  parser.add_argument('--output', '-o', 
      help='Output for the predictions, default is stdout')
  parser.add_argument('--global_only', action='store_true', help='Whether to print'
      ' all metrics (default) or just global c@1')
  parser.add_argument('--passed_tests', action='store_true', help='Whether to print'
      'passed tests or not, only affects when global_only=True.')
  parser.add_argument('--accuracy', action='store_true', help='Whether to'
      ' calculate accuracy too (default false).')

  if len(sys.argv) == 1:
    parser.print_help()
    sys.exit(1)
  return parser.parse_args()

def main():
  dataset = json.load(open(flags.data))['data']
  gold = gather_labels(dataset)
  answers = parse_predictions_file(flags.predictions)
  apply_threshold(answers , flags.threshold)
  answer_labels = gather_labels(answers)
  eval_results = c_at_1(gold, answer_labels, no_answer,
      global_only=flags.global_only, include_tests=flags.passed_tests)
  if flags.accuracy:
    apply_threshold(answers, 0.0)
    answer_labels = gather_labels(answers)
    accuracy_results = c_at_1(gold, answer_labels, no_answer,
        global_only=flags.global_only, include_tests=flags.passed_tests)
    eval_results['accuracy'] = accuracy_results['c@1']
  results = json.dumps(sort_dict(eval_results)) + '\n'
  if flags.output is None:
    print(results)
  else:
    with open(flags.output, 'w') as f:
      f.write(results)

if __name__ == '__main__':
  flags = parse_flags()
  main()
