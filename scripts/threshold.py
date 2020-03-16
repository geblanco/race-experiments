import sys
import json
import argparse
from evaluation import c_at_1_by_test
from utils import argmax, unique, parse_predictions_file

flags = None
no_answer = -1

def parse_flags():
  parser = argparse.ArgumentParser()
  parser.add_argument('nbest_predictions', nargs='*',
      help='All predictions from model. Can be multiple files')

  if len(sys.argv) == 1:
    parser.print_help()
    sys.exit(1)
  return parser.parse_args()

def sweep(answers, increments):
  scores = []
  for threshold in increments:
    gold_and_labels = []
    for ans in answers:
      ans.set_threshold(threshold)
      gold_and_labels.extend(ans.get_pred_tuple())
    gold, labels = list(zip(*gold_and_labels))
    scores.append(c_at_1_by_test(gold, labels, no_answer))
  best_thresh_idx = argmax(scores)
  return best_thresh_idx, scores

def apply_threshold(answers, threshold):
  for ans in answers:
    ans.set_threshold(threshold)

def main():
  prediction_answers = []
  for predictions_file in flags.nbest_predictions:
    prediction_answers.extend(parse_predictions_file(predictions_file))
  increments = unique([0] + sorted([p.get_max_prob() for p in prediction_answers]))
  best_thresh_idx, scores = sweep(prediction_answers, increments)
  print('Best score: {}, threshold {}'.format(scores[best_thresh_idx],
    increments[best_thresh_idx]))
  print('Score with no threshold: {}, threshold {}'.format(scores[0],
    increments[0]))

if __name__ == '__main__':
  flags = parse_flags()
  main()
