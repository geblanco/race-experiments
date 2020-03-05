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

# this options should be automagic (maybe do it by jsonnet)
 
if [[ ! -z "$MODEL_TYPE" ]];then
  args+="--model_type $MODEL_TYPE "
fi

if [[ ! -z "$TASK_NAME" ]];then
  args+="--task_name $TASK_NAME "
fi

if [[ ! -z "$MODEL_NAME_OR_PATH" ]];then
  args+="--model_name_or_path $MODEL_NAME_OR_PATH "
fi

if [[ ! -z "$DATA_DIR" ]];then
  args+="--data_dir $DATA_DIR "
fi

if [[ ! -z "$DATA_ID" ]];then
  args+="--data_id $DATA_ID "
fi

if [[ ! -z "$OUTPUT_DIR" ]];then
  args+="--output_dir $OUTPUT_DIR "
fi

if [[ ! -z "$LEARNING_RATE" ]];then
  args+="--learning_rate $LEARNING_RATE "
fi

if [[ ! -z "$NUM_TRAIN_EPOCHS" ]];then
  args+="--num_train_epochs $NUM_TRAIN_EPOCHS "
fi

if [[ ! -z "$MAX_SEQ_LENGTH" ]];then
  args+="--max_seq_length $MAX_SEQ_LENGTH "
fi

if [[ ! -z "$PER_GPU_TRAIN_BATCH_SIZE" ]];then
  args+="--per_gpu_train_batch_size $PER_GPU_TRAIN_BATCH_SIZE "
fi

if [[ ! -z "$PER_GPU_EVAL_BATCH_SIZE" ]];then
  args+="--per_gpu_eval_batch_size $PER_GPU_EVAL_BATCH_SIZE "
fi

if [[ ! -z "$GRADIENT_ACCUMULATION_STEPS" ]];then
  args+="--gradient_accumulation_steps $GRADIENT_ACCUMULATION_STEPS "
fi

if [[ ! -z "$OVERWRITE_OUTPUT" ]]; then
  args+="--overwrite_output "
fi

if [[ ! -z "$DO_TRAIN" ]]; then
  args+="--do_train "
fi

if [[ ! -z "$DO_EVAL" ]]; then
  args+="--do_eval "
fi

if [[ ! -z "$DO_TEST" ]]; then
  args+="--do_test "
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

