local utils = import 'utils.libsonnet';

local common = {
  task_name: 'race',
  data_dir: 'data/RACE',
  fp16: true,
  fp16_opt_level: 'O2',
  max_seq_length: 384,
  overwrite_cache: true,
  per_gpu_eval_batch_size: 32,
  do_test: true,
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
  modelNames: std.objectFields(models),
  tests: ['high', 'middle'],
  datasetPrefix: 'test',
};

local modelsTests = [
  item + '.json'
  for item in utils.generateCombinationsTwoSets(testsData.modelNames, testsData.tests, '%s-%s')
];

local modelName(testName) = utils.getStringSegment(testName, '-', 0);
local testOnlyName(testName) = utils.getStringSegment(utils.trimExt(testName), '-', 1);
// from bert-high.sh to test/high
local composeDataId(testName) = {
  DATA_ID: testsData.datasetPrefix + '/' + testOnlyName(testName),
};

local files = {
  [testName]: std.manifestJsonEx(
    common + models[modelName(testName)] + composeDataId(testName),
    ' '
  )
  for testName in modelsTests
};

local filelist = {
  'race-eval.filelist': std.join('\n', modelsTests),
};

// object comprehension can only have one item, either filelist or model test files in the export section....
local allFiles = files + filelist;

{
  [fileName]: |||
    %s
  ||| % allFiles[fileName]
  for fileName in std.objectFields(allFiles)
}
