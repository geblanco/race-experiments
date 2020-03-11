import argparse

flags = None
sizes = {
  'eval': [1436, 3451],
  'test': [1436, 3498]
}

def parse_args():
  parser = argparse.ArgumentParser()
  parser.add_argument('--eval', '-e', action='store_true', help='Whether to'
    'calculate based on test set size (default) or eval set')
  parser.add_argument('scores', nargs='+', type=float)
  return parser.parse_args()

def calculate_score(scores, dataset_sizes):
  total = sum(dataset_sizes)
  mid_score = scores[0] * (dataset_sizes[0] / total)
  high_score = scores[1] * (dataset_sizes[1] / total)
  return mid_score + high_score

def main():
  if len(flags.scores) % 2 != 0:
    raise ValueError('You must provide scores by pairs (mid, high).')
  dataset_sizes = sizes['eval' if flags.eval else 'test']
  for i in range(0, len(flags.scores), 2):
    print(calculate_score(flags.scores[:i+2], dataset_sizes))

if __name__ == '__main__':
  flags = parse_args()
  main()
