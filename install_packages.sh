#!/bin/bash

inside_docker=${1:-1}

sudo_cmd="sudo"
if [[ "$inside_docker" -eq 1 ]]; then
  sudo_cmd=""
fi
# install apex manually (py3 error...)
git clone https://www.github.com/nvidia/apex
cd apex
${sudo_cmd} pip3 install -v --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" ./
cd -
rm -rf apex
${sudo_cmd} pip3 install -r requirements.txt
