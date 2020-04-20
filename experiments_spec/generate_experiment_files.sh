#!/bin/bash

scriptdir=$(dirname -- "$(realpath -- "$0")")
rootdir=$(dirname $scriptdir)

output_folder="${rootdir}/experiments"
[[ ! -d $output_folder ]] && mkdir $output_folder

files=$(find $scriptdir -iname '*.jsonnet' -type f)

for file in ${files[@]}; do
  echo "jsonnet -m $output_folder -y -S $file"
  jsonnet -m $output_folder -y -S $file
done
