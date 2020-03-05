local utils = import 'utils.libsonnet';

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

local variables = {
  globalCommon: utils.fieldsToBash(common),
  betCommon: utils.fieldsToBash(bertCommon),
  multiBertCommon: utils.fieldsToBash(multiBertCommon),
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
