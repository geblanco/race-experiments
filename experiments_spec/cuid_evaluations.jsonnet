local utils = import 'utils.libsonnet';

local common = {
  task_name: 'ee',
  data_dir: 'data/CUID',
  fp16: true,
  fp16_opt_level: '"O2"',
  max_seq_length: 384,
  overwrite_cache: true,
  do_test: true,
  per_gpu_eval_batch_size: 32,
  model_type: 'bert',
};

// when not training, model_name_or_path must match the model in output_dir in order
// to load from checkpoint, otherwise will download the model from the internet
local models = {
  bert: {
    output_dir: 'data/bert-base-uncased',
    model_name_or_path: self.output_dir,
  },
  multibert: {
    output_dir: 'data/bert-base-multilingual-cased',
    model_name_or_path: self.output_dir,
  },
};

local testsData = {
  splits: ['A', 'B', 'C'],
  parts: [1, 2],
  exceptions: ['C-2'],
  modelNames: std.objectFields(models),
  datasetPrefix: 'CUID',
};

local modelsTests = [
  item + '.sh'
  for item in
    utils.generateCombinations(
      testsData.modelNames,
      testsData.splits,
      testsData.parts,
      testsData.exceptions,
      '%s-%s'
    )
];

// from bert-english-2013.sh to race-test-english-2013.json
local composeDataId(testName, modelName) = {
  DATA_ID:
    testsData.datasetPrefix +
    std.lstripChars(utils.trimExt(testName), modelName)
    + '.json',
};

local modelName(testName) = utils.getStringSegment(testName, '-', 0);

local files = {
  [testName]: |||
    #!/bin/bash
    %(common)s
    %(model)s
    %(dataId)s
  ||| % {
    common: utils.fieldsToBash(common),
    model: utils.fieldsToBash(models[modelName(testName)]),
    dataId: utils.fieldsToBash(composeDataId(testName, modelName(testName))),
  }
  for testName in modelsTests
};

local filelist = {
  'cuid-eval.filelist': std.join('\n', modelsTests),
};

// object comprehension can only have one item, either filelist or model test files in the export section....
local allFiles = files + filelist;

{
  [fileName]: |||
    %s
  ||| % allFiles[fileName]
  for fileName in std.objectFields(allFiles)
}
