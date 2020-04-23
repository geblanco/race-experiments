import numpy as np

from abc import ABC, abstractmethod

class Baseline(ABC):
  @abstractmethod
  def get_answer(self, context, question, options):
    raise NotImplementedError('You must implement `get_answer` method.')

  def create_answer_dict(self, pred_label, total): 
    probs = [0] * pred_label + [1] + [0] * (total-pred_label) 
    answer = dict(pred_label=int(pred_label), probs=probs) 
    return answer 

class RandomBaseline(Baseline):
  def get_answer(self, context, question, options):
    total = len(options)
    # exclusive range
    pred_label = np.random.randint(0, total +1)
    return self.create_answer_dict(pred_label, total)

class LongestBaseline(Baseline):
  def get_answer(self, context, question, options):
    total = len(options)
    lengths = [len(opt) for opt in options]
    pred_label = np.argmax(lengths)
    return self.create_answer_dict(pred_label, total)

baselines = {
  'random': RandomBaseline,
  'longest': LongestBaseline
}