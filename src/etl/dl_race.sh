#!/bin/bash

cd data
wget -q --show-progress -O race.tar.gz http://www.cs.cmu.edu/~glai1/data/race/RACE.tar.gz
echo "Uncompressing race..."
tar xfz race.tar.gz
rm race.tar.gz
cd -
