local common = {
  "task_name": "race",
  "data_dir": "data/RACE",
  "fp16": true,
  "fp16_opt_level": '"O2"',
  "max_seq_length": 384,
  "per_gpu_eval_batch_size": 4,
  "overwrite_cache": true,
};

local bertCommon = {
  "model_type": "bert",
  "model_name_or_path": "bert-base-uncased",
  "output_dir": "data/bert-base-uncased"
};

local multiBertCommon = {
  "model_type": "bert",
  "model_name_or_path": "bert-base-multilingual-cased",
  "output_dir": "data/bert-base-multilingual-cased"
};

local bashExport(var, val) = {
  ret: 'export ' + std.asciiUpper(var) + '=' + val
};


{
  'bert-high.sh': |||
    #!/bin/bash
    %(common)s
    %(vars)s
    export DATA_ID="test/high"
  ||| % {
    common: std.join('\n', [bashExport(var, common[var]).ret for var in std.objectFields(common)]),
    vars: std.join('\n', [bashExport(var, bertCommon[var]).ret for var in std.objectFields(bertCommon)])
  },
  'bert-middle.sh': |||
    #!/bin/bash
    %(common)s
    %(vars)s
    export DATA_ID="test/middle"
  ||| % {
    common: std.join('\n', [bashExport(var, common[var]).ret for var in std.objectFields(common)]),
    vars: std.join('\n', [bashExport(var, bertCommon[var]).ret for var in std.objectFields(bertCommon)])
  },
  'multi-bert-high.sh': |||
    #!/bin/bash
    %(common)s
    %(vars)s
    export DATA_ID="test/high"
  ||| % {
    common: std.join('\n', [bashExport(var, common[var]).ret for var in std.objectFields(common)]),
    vars: std.join('\n', [bashExport(var, multiBertCommon[var]).ret for var in std.objectFields(multiBertCommon)]),
  },
  'multi-bert-middle.sh': |||
    #!/bin/bash
    %(common)s
    %(vars)s
    export DATA_ID="test/middle"
  ||| % {
    common: std.join('\n', [bashExport(var, common[var]).ret for var in std.objectFields(common)]),
    vars: std.join('\n', [bashExport(var, multiBertCommon[var]).ret for var in std.objectFields(multiBertCommon)]),
  },
}
