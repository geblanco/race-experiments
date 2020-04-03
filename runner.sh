#!/bin/bash

result_files=(
  "is_test_false_eval_results.txt"
  "is_test_false_eval_nbest_predictions.json"
  "is_test_true_eval_results.txt"
  "is_test_true_eval_nbest_predictions.json"
)

save_experiment_data() {
  local model_dir=$1; shift
  local results_dir=$1; shift
  local exp_name=$1; shift
  for file in ${result_files[@]}; do
    if [[ -f $model_dir/$file ]]; then
      echo "Saving $model_dir/$file $results_dir/${exp_name}_${file}"
      mv $model_dir/$file $results_dir/${exp_name}_${file}
    fi
  done
}

run_experiment() {
  local file=$1; shift
  args="./transformers/examples/run_multiple_choice.py "
  # Run this if just want to dump your args to a config file (use with from config import *)
  #   args="./scripts/dump_args.py "
  for line in $(sed -n 's/^export \(.*\)=\([^ ]*\)/\1=\2/p' $file | tr -d \'\"); do 
    # <key>=<value>
    key=${line%=*}
    value=${line#*=}
    # lowercase
    args+="--${key,,} "
    if [[ ! "${value,,}" == "true" ]]; then
      args+="$value "
    fi
  done

  if [[ -z ${DOCKERIZE} ]]; then
    inside_docker=""
  else
    inside_docker="nvidia-docker run ${docker_args[@]}"
  fi
  ${inside_docker} python3 ${args[@]}
}

results_dir='./results'
[[ ! -d $results_dir ]] && mkdir $results_dir

docker_img="race-experiments"
docker_args="--shm-size=1g --ulimit memlock=-1 --ulimit stack=67108864 -v `pwd`:/workspace $docker_img"

echo "###### Starting experiments $(date)"
total_start_time=$(date -u +%s)

experiments=($@)
for exp in ${experiments[@]}; do
  model_dir=$(sed -n 's/export OUTPUT_DIR=\(.*\)/\1/p' experiments/$exp);
  exp_name=${exp%.*}
  echo "*********** $exp *************";
  run_experiment experiments/$exp
  save_experiment_data $model_dir $results_dir $exp_name
  echo "********************************";
done

total_end_time=$(date -u +%s)
total_elapsed=$(python3 -c "print('{:.2f}'.format(($total_end_time - $total_start_time)/60.0 ))")
echo "###### End of experiments $(date) ($total_elapsed) minutes"

