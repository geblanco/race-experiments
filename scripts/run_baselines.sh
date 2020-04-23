#!/bin/bash

scriptdir=$(dirname -- "$(realpath -- "$0")")
rootdir=$(dirname $scriptdir)
cd $rootdir

race_dataset_dir="../../../datasets/RACE/"
ee_dataset_dir="../../../datasets/EntranceExams/"
results_dir="./results"

baseline_script="./evaluation/baseline.py"

preds_suffix="is_test_true_eval_nbest_predictions.json"
scores_suffix="is_test_true_eval_scores.json"
table_suffix="is_test_true_eval_table.txt"

splits=("middle" "high")
languages=("english" "spanish" "italian" "french" "russian" "german")
# languages=("english" "spanish")
years=(2013 2014 2015)
# no data for these years
exceptions=("german-2013" "german-2014")

# ToDo := grep baseline output files
run_baselines() {
  local task=$1; shift
  local dataset=$1; shift
  local output=$1; shift
  python $baseline_script \
    -t $task \
    -d $dataset \
    -o $output >/dev/null
}

for split in ${splits[@]}; do
  echo "${split^}"
  race_dataset="${race_dataset_dir}/test/${split}" 
  output="${results_dir}/${split}_${preds_suffix}"
  run_baselines "race" $race_dataset $output
done

for lang in ${languages[@]}; do
  echo "${lang^}"
  for year in ${years[@]}; do
    if [[ " ${exceptions[@]} " =~ " ${lang}-${year} " ]]; then
      continue
    fi
    echo "  ${year}"
    ee_dataset="${ee_dataset_dir}/rc-test-${lang}-${year}.json"
    output="${results_dir}/${lang}-${year}_${preds_suffix}"
    run_baselines "ee" $ee_dataset $output
  done
  echo ""
done


cd - >/dev/null
