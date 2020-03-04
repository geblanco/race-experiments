# process Entrance Exams dataset to RACE-like format
# sample:
""" {
    "test-set": {
        "topic": {
            "t_id": "0",
            "t_name": "Entrance Exam",
            "reading-test": [
                {
                    "r_id": "13",
                    "doc": {
                        "d_id": "1",
                        "$t": "<Document.>"
                    },
                    "question": [
                        {
                            "q_id": "1",
                            "q_str": "Question",
                            "answer": [
                                {
                                    "a_id": "1",
                                    "$t": "<ans 1>"
                                },
                                {
                                    "a_id": "2",
                                    "correct": "Yes",
                                    "$t": "<ans 2>"
                                },
                                {
                                    "a_id": "3",
                                    "$t": "<ans 3>"
                                },
                                {
                                    "a_id": "4",
                                    "$t": "<ans 4>"
                                }
                            ]
                        },
                        {...}
"""
# ->
"""
{
    "version": 1.0,
    "language": "spanish",
    "data": [{
        "answers": ["B", ...],
        "options": [
          ["<ans 1>", "<ans 2>", "<ans 3>", "<ans 4>"],
          ...
        ],
        "questions": [
          ["q1", ...]
        ],
        "article": "<Document>",
        "id": ""
    }]
}
"""

import json
import argparse

flags = None

def parse_args():
  parser = argparse.ArgumentParser()
  parser.add_argument('-i', '--input', type=str, required=True,
    help="Dataset to process")
  return parser.parse_args()

answer_indices_to_letters = ['A', 'B', 'C', 'D']

class Example(object):
  def __init__(self, id, ee_example):
    self.id = id
    self.article = ee_example['doc']['$t']

    self.questions = self._process_questions(ee_example['question'])
    self.answers = self._process_answers(ee_example['question'])
    self.options = self._process_options(ee_example['question'])

  def _process_questions(self, questions):
    return [q['q_str'] for q in questions]

  def _process_answers(self, questions):
    # get the index of the answer with correct=True
    answers = []
    for question in questions:
      for index, answer in enumerate(question['answer']):
        if answer.get('correct', False):
          answers.append(answer_indices_to_letters[index])
    return answers

  def _process_options(self, questions):
    options = []
    for question in questions:
      options.append([q['$t'] for q in question['answer']])
    return options

  def to_json(self):
    return self.__dict__

def main():
  data = json.load(open(flags.input))
  data = data['test-set']['topic']['reading-test']
  examples = [Example(datapoint['r_id'], datapoint).to_json()
                for datapoint in data]
  dataset = dict(version=1.0, data=examples)
  print(json.dumps(obj=dataset, ensure_ascii=False))

if __name__ == '__main__':
  flags = parse_args()
  main()
