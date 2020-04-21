local utils = import 'utils.libsonnet';

local common = {
  task_name: 'race',
  data_dir: 'data/RACE',
  fp16: true,
  fp16_opt_level: 'O2',
  max_seq_length: 384,
  do_train: true,
  do_eval: true,
  warmup_proportion: 0.1,
  num_train_epochs: 3,
  loss_scale: 128,
  per_gpu_train_batch_size: 4,
  per_gpu_eval_batch_size: 32,
  gradient_accumulation_steps: 8,
  model_type: 'bert',
};

local models = {
  bert: {
    output_dir: 'data/bert-base-uncased',
    model_name_or_path: 'bert-base-uncased',
    learning_rate: 5e-5,
  },
  multibert: {
    output_dir: 'data/bert-base-multilingual-cased',
    model_name_or_path: 'bert-base-multilingual-cased',
    learning_rate: 1e-5,
  },
};

local modelsTests = [
  item + '.json'
  for item in std.objectFields(models)
];

local modelName(testName) = utils.trimExt(testName);

local files = {
  [testName]: std.manifestJsonEx(common + models[modelName(testName)], '  ')
  for testName in modelsTests
};

local filelist = {
  'race-finetune.filelist': std.join('\n', modelsTests),
};

// object comprehension can only have one item, either filelist or model test files in the export section....
local allFiles = files + filelist;

{
  [fileName]: |||
    %s
  ||| % allFiles[fileName]
  for fileName in std.objectFields(allFiles)
}
