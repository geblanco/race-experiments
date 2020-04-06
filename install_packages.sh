#!/bin/bash

inside_docker=${1:-1}

sudo_cmd="sudo"
if [[ "$inside_docker" -eq 1 ]]; then
  sudo_cmd=""
fi
# download transformers repo
# cloned in setup to always have it in host workspace
# git clone https://github.com/m0n0l0c0/transformers
cd transformers
${sudo_cmd} pip3 install .
cd -

# install apex manually (py3 error...)
git clone https://www.github.com/nvidia/apex
cd apex
${sudo_cmd} pip3 install -v --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" ./
cd -
rm -rf apex
${sudo_cmd} pip3 install -r requirements.txt
