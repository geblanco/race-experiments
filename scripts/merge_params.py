import json
import yaml
import sys

def is_json(file):
  return file.endswith('.json')

def is_yaml(file):
  return file.endswith('.yaml')

def get_data_from_file(file):
  data = None
  if is_yaml(file):
    module = yaml
  else:
    module = json
  try:
    data = module.load(open(file, 'r'))
  except Exception as e:
    print('Unable to parse %s: %r' % (file, e))
  return data

def merge_params(param_files):
  params = dict()
  for arg in param_files:
    new_params = get_data_from_file(arg)
    if new_params is not None:
      params.update(**new_params)
  return params

__all__ = [merge_params]

if __name__ == '__main__':
  params = merge_params(sys.argv[1:])
  print(json.dumps(params) + '\n')

