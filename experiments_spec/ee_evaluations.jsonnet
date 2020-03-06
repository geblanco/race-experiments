local utils = import 'utils.libsonnet';

local common = {
  "task_name": "ee",
  "data_dir": "data/EntranceExams",
  "fp16": true,
  "fp16_opt_level": '"O2"',
  "max_seq_length": 384,
  "overwrite_cache": true,
  "do_test": true,
  "per_gpu_eval_batch_size": 32,
  "model_type": "bert",
};

# when not training, model_name_or_path must match the model in output_dir
local models = {
  "bert": {
    "output_dir": "data/bert-base-uncased",
    "model_name_or_path": self.output_dir,
  },
  "multibert": {
    "output_dir": "data/bert-base-multilingual-cased",
    "model_name_or_path": self.output_dir,
  },
};

local eeCommons = {
  languages: ['spanish', 'english'],
  years: [2013, 2014, 2015],
  mapLanguage(language): [std.format('%s-%s.sh', [language, year]) for year in self.years],
  mapModel(model): [std.format('%s-%s', [model, test]) for test in self.tests],
  tests: std.flattenArrays([self.mapLanguage(language) for language in self.languages]),
  modelsTests: std.flattenArrays([self.mapModel(model) for model in std.objectFields(models)]),
};

# from bert-english-2013.sh to rc-test-english-2013.json
local composeDataId(testName, modelName) = {
  "DATA_ID": std.strReplace(std.strReplace(testName, modelName, 'rc-test'), '.sh', '.json')
};

{
  [testName]: |||
    #!/bin/bash
    %(common)s
    %(model)s
    %(dataId)s
  ||| % {
    common: utils.fieldsToBash(common),
    model: utils.fieldsToBash(models[std.split(testName, '-')[0]]),
    dataId: utils.fieldsToBash(composeDataId(testName, std.split(testName, '-')[0])),
  } for testName in eeCommons.modelsTests
}
