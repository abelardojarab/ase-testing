#!/bin/bash

GIT_DIR_LIST="$FPGASW_GIT $ASEVAL_GIT $BBB_GIT $FPGAINT_GIT $FPGADOC_GIT"

for dir in $GIT_DIR_LIST
do
    cd $dir
    pwd
    git fetch
done
