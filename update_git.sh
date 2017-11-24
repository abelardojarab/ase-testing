#!/bin/bash

GIT_DIR_LIST="$HOME/xeon-fpga-src/opae-sdk/ $HOME/xeon-fpga-src/opae-sdk-x/ $ASEVAL_GIT $HOME/xeon-fpga-src/intel-fpga-bbb/ $HOME/xeon-fpga-src/intel-fpga-bbb-x $FPGAINT_GIT $FPGADOC_GIT"

for dir in $GIT_DIR_LIST
do
    cd $dir
    pwd
    git fetch
done
