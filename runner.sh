#!/bin/bash

if [[ "$#" -lt 1 ]]; then
  echo "Usage runner.sh <experiment file>"
  exit 0
fi

file=$1

echo "###### Starting experiments $(date)"
total_start_time=$(date -u +%s)

args="./transformers/examples/run_multiple_choice.py "
for line in $(sed -n 's/^export \(.*\)=\([^ ]*\)/\1=\2/p' $file); do 
  # <key>=<value>
  key=${line%=*}
  value=${line#*=}
  # lowercase
  args+="--${key,,} "
  if [[ ! "${value,,}" == "true" ]]; then
    args+="$value "
  fi
done

echo "python3 ${args[@]}"

total_end_time=$(date -u +%s)
total_elapsed=$(python3 -c "print('{:.2f}'.format(($total_end_time - $total_start_time)/60.0 ))")
echo "###### End of experiments $(date) ($total_elapsed) minutes"

