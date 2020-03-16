"""
implement:
   accuracy
   c@1: https://www.researchgate.net/publication/220873174_A_Simple_Measure_to_Assess_Non-response
"""
import json
from utils import flatten

def accuracy(gold, answers):
  correct = 0
  for gold_ans, ans in zip(gold, answers):
    if gold_ans == ans:
      correct += 1
  return correct / len(gold)

def c_at_1(gold, answers, no_answer):
  passed_tests = 0
  total_tests = len(gold.keys())
  flat_gold = flatten(gold.values())
  flat_ans = flatten(answers.values())
  eval_results = {}
  eval_results['c@1'] = c_at_1_by_test(flat_gold, flat_ans, no_answer)
  for test_key in gold.keys():
    key = 'test_%s_c@1' % test_key
    eval_results[key] = c_at_1_by_test(gold[test_key], answers[test_key], no_answer)
    if eval_results[key] >= 0.5:
      passed_tests += 1
  eval_results['passed_tests'] = passed_tests
  eval_results['total_tests'] = total_tests
  return eval_results

def c_at_1_by_test(gold, answers, no_answer):
  correct = 0
  unanswered = 0
  total = len(gold)
  for gold_ans, ans in zip(gold, answers):
    if gold_ans == ans:
      correct += 1
    elif ans == no_answer:
      unanswered += 1
  return (1 / total) * (correct + (correct / total) * unanswered)

