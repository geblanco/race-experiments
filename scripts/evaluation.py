"""
implement:
   accuracy
   c@1: https://www.researchgate.net/publication/220873174_A_Simple_Measure_to_Assess_Non-response
"""
import json
from utils import flatten_dict

# when all questions are answered, this matches with accuracy
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

def c_at_1(gold, answers, no_answer, global_only=False, passed_tests=False):
  passed_tests = 0
  total_tests = len(gold.keys())
  flat_gold = flatten_dict(gold)
  flat_ans = flatten_dict(answers, keys=gold.keys())
  eval_results = {}
  c_at_1_obj = {
    'value': c_at_1_by_test(flat_gold, flat_ans, no_answer)
  }
  for test_key in gold.keys():
    key = 'test_%s_c@1' % test_key
    test_result = c_at_1_by_test(gold[test_key], answers[test_key], no_answer)
    if test_result >= 0.5:
      passed_tests += 1
    if not global_only:
      c_at_1_obj[key] = test_result
  if not global_only or passed_tests:
    c_at_1_obj['passed_tests'] = passed_tests
    c_at_1_obj['total_tests'] = total_tests
  eval_results['c@1'] = c_at_1_obj
  return eval_results

