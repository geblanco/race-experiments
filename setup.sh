#!/bin/bash

# dockerize by default
dockerize=${1:-1}

if ! hash git unzip wget 2>/dev/null; then
  echo '"git", "unzip" and "wget" are necessary, install them first'
  exit 1
fi

# download some repos we want locally, installed in docker
git clone https://github.com/m0n0l0c0/transformers
git clone https://github.com/artetxem/vecmap
if [[ "$dockerize" -eq 0 ]]; then
  ./install_packages.sh $dockerize
else
  docker build -t race-experiments .
fi

mkdir -p data
wget -q -O data/race.tar.gz http://www.cs.cmu.edu/~glai1/data/race/RACE.tar.gz
cd data/
echo "Uncompressing race..."
tar xfz race.tar.gz
rm race.tar.gz
cd -

