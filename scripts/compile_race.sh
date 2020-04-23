#!/bin/bash

RACE=${1:-"data/RACE"}
OUTPUT=${2:-$RACE}

if [[ ! -d $OUTPUT ]]; then
  mkdir -p $OUTPUT
fi

for data_set in 'test' 'dev' 'train'; do
  for partition in 'high' 'middle'; do
    compiled_dataset="${OUTPUT}/race_${data_set}_compiled_${partition}.json"
    echo "-> Compiling ${data_set} - ${partition} to $compiled_dataset"
    python scripts/compile_race.py --data ${RACE}/${data_set} --partition ${partition} > $compiled_dataset
  done
done

