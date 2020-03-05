local utils = import 'utils.libsonnet';

local common = {
  "task_name": "race",
  "data_dir": "data/RACE",
  "fp16": true,
  "fp16_opt_level": '"O2"',
  "max_seq_length": 384,
  "overwrite_cache": true,
  "do_test": true,
};

# when not training, model_name_or_path must match the model in output_dir
local bertCommon = {
  "model_type": "bert",
  "output_dir": "data/bert-base-uncased",
  "model_name_or_path": self.output_dir,
};

local multiBertCommon = {
  "model_type": "bert",
  "output_dir": "data/bert-base-multilingual-cased",
  "model_name_or_path": self.output_dir,
};


local variables = {
  globalCommon: utils.fieldsToBash(common),
  bertCommon: utils.fieldsToBash(bertCommon),
  multiBertCommon: utils.fieldsToBash(multiBertCommon),
};

{
  'bert-high.sh': |||
    #!/bin/bash
    %(common)s
    %(vars)s
    export DATA_ID="test/high"
  ||| % { common: variables.globalCommon, vars: variables.bertCommon },
  'bert-middle.sh': |||
    #!/bin/bash
    %(common)s
    %(vars)s
    export DATA_ID="test/middle"
  ||| % { common: variables.globalCommon, vars: variables.bertCommon },
  'multi-bert-high.sh': |||
    #!/bin/bash
    %(common)s
    %(vars)s
    export DATA_ID="test/high"
  ||| % { common: variables.globalCommon, vars: variables.multiBertCommon },
  'multi-bert-middle.sh': |||
    #!/bin/bash
    %(common)s
    %(vars)s
    export DATA_ID="test/middle"
  ||| % { common: variables.globalCommon, vars: variables.multiBertCommon },
}
