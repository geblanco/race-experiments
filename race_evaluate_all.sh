#!/bin/bash

models=("bert" "multibert")
splits=("middle" "high")

eval_script="./scripts/ee_evaluation.py"
join_script="./scripts/utils_ee.py"
json2table="../../dataset-utils/json2table"

dataset_dir="../../../datasets/RACE/test/"
preds_suffix="is_test_true_eval_nbest_predictions.json"
scores_suffix="is_test_true_eval_scores.json"
table_suffix="is_test_true_eval_table.txt"

declare -A thresholds

echo "Calculating thresholds..."
for model in ${models[@]}; do
  echo -n " ...${model}"
  if [[ $# -gt 0 ]]; then
    threshold=$1; shift
  else
    threshold=$(python scripts/threshold.py --script results/${model}_is_test_false_eval_nbest_predictions.json)
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
  local predictions="results/${model}-${split}_${preds_suffix}"
  local results="results/${model}-${split}_${scores_suffix}"
  local table="results/${model}-${split}_${table_suffix}"
  python $eval_script --global_only --passed_tests --accuracy $dataset $predictions -t $threshold > $results
  $json2table $results -t | tee $table  | awk '{print "   " $0}' | head -n -1 | tail -n 2
}

join "results/bert" "_${preds_suffix}"
join "results/multibert" "_${preds_suffix}"
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