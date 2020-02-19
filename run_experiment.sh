export RACE_DIR=data/RACE
python ./transformers/examples/run_multiple_choice.py \
  --model_type albert \
  --task_name race \
  --model_name_or_path albert-large-v2 \
  --data_dir $RACE_DIR \
  --output_dir data/albert-large-v2 \
  --config_name config/albert_large_config.json \
  --overwrite_output \
  --do_train \
  --do_eval \
  --do_lower_case \
  --fp16 \
  --learning_rate 1e-5 \
  --num_train_epochs 3 \
  --max_seq_length 512 \
  --per_gpu_train_batch_size=32 \
  --per_gpu_eval_batch_size=8 \
  --gradient_accumulation_steps 2 \
  --warmup_steps 1000

