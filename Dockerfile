FROM nvcr.io/nvidia/tensorflow:20.03-tf2-py3
MAINTAINER Guillermo Echegoyen <gblanco@lsi.uned.es>

WORKDIR /workspace
COPY install_packages.sh /workspace
COPY requirements.txt  /workspace

RUN cd /workspace && ./install_packages.sh

