#!/bin/bash

scriptdir=$(dirname -- "$(realpath -- "$0")")
rootdir=$(dirname $scriptdir)
cd $rootdir

baselines=("random_baseline" "longest_baseline")
models=("bert" "multibert")
splits=("middle" "high")

eval_script="./evaluation/evaluation.py"
join_script="./evaluation/join_data.py"
json2table="../../dataset-utils/json2table"

dataset_dir="../../../datasets/RACE/test/"
preds_suffix="is_test_true_eval_nbest_predictions.json"
scores_suffix="is_test_true_eval_scores.json"
table_suffix="is_test_true_eval_table.txt"
results_dir="./results"

declare -A thresholds

echo "Calculating thresholds..."
for model in ${models[@]}; do
  echo -n " ...${model}"
  if [[ $# -gt 0 ]]; then
    threshold=$1; shift
  else
    threshold=$(python evaluation/threshold.py --script ${results_dir}/${model}_is_test_false_eval_nbest_predictions.json)
  fi
  echo " ${threshold}"
  thresholds[${model}]=$threshold
done

echo "Generating join predictions..."
join(){
  local prefix=${1:-""}; shift
  local suffix=${1:-""}; shift
  local args="--join "
  echo "  ${prefix}"
  for split in ${splits[@]}; do
    dataset="${prefix}-${split}${suffix}"
    args+="$dataset "
    echo "    ${split^}"
  done
  python $join_script ${args[@]} -o ${prefix}-all${suffix}
}

evaluate() {
  local split=$1; shift
  local model=$1; shift
  local threshold="${thresholds[$model]}"
  local dataset="${dataset_dir}/race_test_compiled_${split}.json"
  local predictions="${results_dir}/${model}-${split}_${preds_suffix}"
  local results="${results_dir}/${model}-${split}_${scores_suffix}"
  local table="${results_dir}/${model}-${split}_${table_suffix}"
  python $eval_script --global_only --passed_tests --accuracy $dataset $predictions -t $threshold > $results
  $json2table $results -t | tee $table  | awk '{print "   " $0}' | head -n -1 | tail -n 2
}

models=(${models[@]} ${baselines[@]})
for base in ${baselines[@]}; do
  thresholds[$base]=0
done

for model in ${models[@]}; do
  join "${results_dir}/${model}" "_${preds_suffix}"
done
echo ""
splits+=("all")

for split in ${splits[@]}; do
  echo "${split^}"
  for model in ${models[@]}; do
    echo " ${model}"
    evaluate $split $model
    echo ""
  done
done

cd - >/dev/null

