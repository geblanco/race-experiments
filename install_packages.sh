#!/bin/bash

inside_docker=${1:-1}

sudo_cmd="sudo"
if [[ "$inside_docker" -eq 1 ]]; then
  sudo_cmd=""
fi

${sudo_cmd} pip3 install -U pip
${sudo_cmd} pip3 install -r requirements.txt
# install apex manually (py3 error...)
git clone https://www.github.com/nvidia/apex
cd apex
${sudo_cmd} pip3 install -v --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" ./
cd -
rm -rf apex

${sudo_cmd} pip3 install git+git://github.com/huggingface/transformers@b1ff0b2ae7d368b7db3a8a8472a29cc195d278d8

