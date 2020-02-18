#!/bin/bash

dockerize=${1:-0}

if ! hash git unzip wget 2>/dev/null; then
  echo '"git", "unzip" and "wget" are necessary, install them first'
  exit 1
fi

# download transformers repo
git clone https://github.com/m0n0l0c0/transformers
cd transformers
pip install .
cd -

mkdir -p data/race
wget -q -O data/race/race.tar.gz http://www.cs.cmu.edu/~glai1/data/race/RACE.tar.gz
cd data/race
tar xvfz race.tar.gz
cd -

# pre-installed tensorflow-gpu and cuda
if [[ $dockerize -eq 0 ]]; then
  pip install requirements.txt
else
  echo "Asked for docker install, no packages to install"
fi
