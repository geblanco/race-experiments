#!/bin/bash

base_dir=${1:-`pwd`}
docker_img="race-experiments"
nvidia-docker run \
  --shm-size=1g --ulimit memlock=-1 --ulimit stack=67108864 \
  -v `pwd`:/workspace \
  --rm -it \
  $docker_img \
  ipython
