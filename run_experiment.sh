export RACE_DIR=data/RACE
export BERT_MODEL=multi_cased_L-12_H-768_A-12
export BERT_MULTI_DIR=models/$BERT_MODEL

python3 ./transformers/examples/run_multiple_choice.py \
  --model_type albert \
  --task_name race \
  --model_name_or_path $BERT_MULTI_DIR/bert_model.ckpt \
  --config_name $BERT_MULTI_DIR/bert_config.json \
  --tokenizer_name $BERT_MULTI_DIR/vocab.txt \
  --data_dir $RACE_DIR \
  --output_dir data/$BERT_MODEL \
  --overwrite_output \
  --do_train \
  --do_eval \
  --fp16 \
  --fp16_opt_level "O2" \
  --learning_rate 1e-5 \
  --num_train_epochs 3 \
  --max_seq_length 256 \
  --per_gpu_train_batch_size=2 \
  --per_gpu_eval_batch_size=8 \
  --gradient_accumulation_steps 64 \
  --warmup_steps 1000

