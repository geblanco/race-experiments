#!/bin/bash

languages=("english" "spanish")
years=(2013 2014 2015)
models=("bert" "multibert")

eval_script="./scripts/ee_evaluation.py"
join_script="./scripts/utils_ee.py"
json2table="../../dataset-utils/json2table"

ee_dataset_dir="../../../datasets/EntranceExams"
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

echo "Generating join by year datasets and predictions..."
join(){
  local prefix=${1:-""}; shift
  local suffix=${1:-""}; shift
  echo "$(basename $prefix)"
  for lang in ${languages[@]}; do
    local args="--join "
    local prefixes="--prefix "
    for year in ${years[@]}; do
      dataset="${prefix}-${lang}-${year}${suffix}"
      args+="$dataset "
      prefixes+="${lang}-${year} "
    done
    echo "  ${lang^}"
    python $join_script ${args[@]} ${prefixes[@]} -o ${prefix}-${lang}-all${suffix}
  done
}

evaluate() {
  local lang=$1; shift
  local model=$1; shift
  local year=$1; shift
  local threshold="${thresholds[$model]}"
  local dataset="${ee_dataset_dir}/rc-test-${lang}-${year}.json"
  local predictions="results/${model}-${lang}-${year}_${preds_suffix}"
  local results="results/${model}-${lang}-${year}_${scores_suffix}"
  local table="results/bert-spanish-${year}_${table_suffix}"
  python $eval_script --global_only --passed_tests --accuracy $dataset $predictions -t $threshold > $results
  $json2table $results -t | tee $table  | awk '{print "     " $0}' | head -n -1
}

join "${ee_dataset_dir}/rc-test" ".json"
join "results/bert" "_${preds_suffix}"
join "results/multibert" "_${preds_suffix}"
years+=("all")
echo ""

for lang in ${languages[@]}; do
  echo "${lang^}"
  for model in ${models[@]}; do
    echo " ${model}"
    for year in ${years[@]}; do
      echo "   ${year}"
      evaluate $lang $model $year
    done
    echo ""
  done
done
