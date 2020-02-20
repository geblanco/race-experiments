#!/bin/bash

dockerize=${1:-0}

if ! hash git unzip wget 2>/dev/null; then
  echo '"git", "unzip" and "wget" are necessary, install them first'
  exit 1
fi

# upgrade pip
sudo pip install --upgrade pip

# download transformers repo
git clone https://github.com/m0n0l0c0/transformers
cd transformers
sudo pip install .
cd -

# install apex manually (py3 error...)
git clone https://www.github.com/nvidia/apex
cd apex
sudo pip install -v --no-cache-dir --global-option="--cpp_ext" --global-option="--cuda_ext" ./
cd -


mkdir -p data
wget -q -O data/race.tar.gz http://www.cs.cmu.edu/~glai1/data/race/RACE.tar.gz
cd data/
echo "Uncompressing race..."
tar xfz race.tar.gz
cd -

# pre-installed tensorflow-gpu and cuda
if [[ $dockerize -eq 0 ]]; then
  sudo pip install -r requirements.txt
else
  echo "Asked for docker install, no packages to install"
fi
