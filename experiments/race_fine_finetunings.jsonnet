local common = {
  "task_name": "race",
  "data_dir": "data/RACE",
  "fp16": true,
  "fp16_opt_level": '"O2"',
  "max_seq_length": 384,
  "do_train": true,
  "warmup_proportion": 0.1,
  "num_train_epochs": 3,
  "per_gpu_train_batch_size": 4,
  "per_gpu_eval_batch_size": 16,
  "gradient_accumulation_steps": 8,
};

local bertCommon = {
  "model_type": "bert",
  "model_name_or_path": "bert-base-uncased",
  "output_dir": "data/bert-base-uncased"
  "learning_rate": 5e-5,
};

local multiBertCommon = {
  "model_type": "bert",
  "model_name_or_path": "bert-base-multilingual-cased",
  "output_dir": "data/bert-base-multilingual-cased",
  "learning_rate": 1e-5,
};

local bashExport(var, val) = {
  ret: 'export ' + std.asciiUpper(var) + '=' + val
};

local variables = {
  globalCommon: std.join('\n', [bashExport(var, common[var]).ret for var in std.objectFields(common)]),
  betCommon: std.join('\n', [bashExport(var, bertCommon[var]).ret for var in std.objectFields(bertCommon)]),
  multiBertCommon: std.join('\n', [bashExport(var, multiBertCommon[var]).ret for var in std.objectFields(multiBertCommon)]),
};


{
  'bert.sh': |||
    #!/bin/bash
    %(common)s
    %(vars)s
  ||| % { common: variables.globalCommon, vars: variables.bertCommon },
  'multi-bert.sh': |||
    #!/bin/bash
    %(common)s
    %(vars)s
  ||| % { common: variables.globalCommon, vars: variables.multiBertCommon },
}