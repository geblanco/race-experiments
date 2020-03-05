#!/bin/bash

if [[ "$#" -lt 1 ]]; then
  echo "Usage runner.sh <experiment file>"
  exit 0
fi

source $1

export RACE_DIR=data/RACE
export BERT_MODEL=multi_cased_L-12_H-768_A-12
export BERT_MULTI_DIR=models/$BERT_MODEL

echo "###### Starting experiments $(date)"
total_start_time=$(date -u +%s)

args="./transformers/examples/run_multiple_choice.py "
args+="--model_type $MODEL_TYPE "
args+="--task_name $TASK_NAME "
args+="--model_name_or_path $MODEL_NAME_OR_PATH "
args+="--data_dir $DATA_DIR "
args+="--data_id $DATA_ID "
args+="--output_dir $OUTPUT_DIR "
args+="--overwrite_output "
args+="--do_eval "
args+="--learning_rate 1e-5 "
args+="--num_train_epochs 3 "
args+="--max_seq_length 256 "
args+="--per_gpu_train_batch_size=2 "
args+="--per_gpu_eval_batch_size=8 "
args+="--gradient_accumulation_steps 64 "

if [[ ! -z "$DO_TRAIN" ]]; then
  args+="--do_train "
fi

if [[ ! -z "$FP16" ]]; then
  args+="--fp16 "
  args+="--fp16_opt_level $FP16_OPT_LEVEL "
fi

if [[ ! -z "$WARMUP_STEPS" ]]; then
  args+="--warmup_steps $WARMUP_STEPS "
fi

if [[ ! -z "$WARMUP_PROPORTION" ]]; then
  args+="--warmup_proportion $WARMUP_PROPORTION "
fi

if [[ ! -z "$OVERWRITE_CACHE" ]]; then
  args+="--overwrite_cache "
fi

python3 ${args[@]}

total_end_time=$(date -u +%s)
total_elapsed=$(python3 -c "print('{:.2f}'.format(($total_end_time - $total_start_time)/60.0 ))")
echo "###### End of experiments $(date) ($total_elapsed) minutes"

