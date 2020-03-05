#!/bin/bash

output_folder='../experiments'
[[ ! -d $output_folder ]] && mkdir $output_folder

files=$(find . -iname '*.jsonnet' -type f)

for file in ${files[@]}; do
  echo "-> $file"
  jsonnet -m $output_folder -y -S $file
done
