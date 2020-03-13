"""
implement:
   accuracy
   c@1: https://www.researchgate.net/publication/220873174_A_Simple_Measure_to_Assess_Non-response
"""
import json

def accuracy(gold, answers):
  correct = 0
  for gold_ans, ans in zip(gold, answers):
    if gold_ans == ans:
      correct += 1
  return correct / len(gold)

def c_at_1(gold, answers, no_answer):
  correct = 0
  unanswered = 0
  total = len(gold)
  for gold_ans, ans in zip(gold, answers):
    if gold_ans == ans:
      correct += 1
    elif ans == no_answer:
      unanswered += 1
  return (1 / total) * (correct + (correct / total) * unanswered)

