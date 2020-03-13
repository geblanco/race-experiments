import sys
import json
import argparse
from evaluation import c_at_1

flags = None
no_answer = -1

def parse_flags():
  parser = argparse.ArgumentParser()
  parser.add_argument('nbest_predictions', help='All predictions from model')

  if len(sys.argv) == 1:
    parser.print_help()
    sys.exit(1)
  return parser.parse_args()

def argmax(values):
  max_val, max_idx = values[0], 0
  for i in range(len(values)):
    if values[i] > max_val:
      max_val = values[i]
      max_idx = i
  return max_idx

def unique(values):
  ret = {}
  for value in values:
    ret[value] = 1
  return list(ret.keys())

class Answer(object):
  def __init__(self, probs, label, pred_label):
    self.probs = probs
    self.label = label
    self.pred_label = pred_label
    self.threshold = 0.0

  def set_threshold(self, threshold):
    self.threshold = threshold

  def get_answer(self):
    ans = -1
    if max(self.probs) > self.threshold:
      ans = argmax(self.probs)
    return ans

  def get_pred_tuple(self):
    return [(self.label, self.get_answer())]

  def get_max_prob(self):
    return max(self.probs)

def sweep(answers, increments):
  scores = []
  for threshold in increments:
    gold_and_labels = []
    for ans in answers:
      ans.set_threshold(threshold)
      gold_and_labels.extend(ans.get_pred_tuple())
    gold, labels = list(zip(*gold_and_labels))
    scores.append(c_at_1(gold, labels, no_answer))
  best_thresh_idx = argmax(scores)
  return best_thresh_idx, scores

def main():
  predictions = json.load(open(flags.nbest_predictions, 'r'))
  prediction_answers = [Answer(p['probs'], p['label'], p['pred_label']) 
                          for p in predictions]
  increments = unique([0] + sorted([p.get_max_prob() for p in prediction_answers]))
  best_thresh_idx, scores = sweep(prediction_answers, increments)
  print('Best score: {}, threshold {}'.format(scores[best_thresh_idx],
    increments[best_thresh_idx]))
  print('Score with no threshold: {}, threshold {}'.format(scores[0],
    increments[0]))

if __name__ == '__main__':
  flags = parse_flags()
  main()
