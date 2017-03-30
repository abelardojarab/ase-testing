#!/bin/sh

GIT_DIR_LIST="$FPGASW_GIT $ASEVAL_GIT $BBB_GIT $BDX_GIT"

for dir in $GIT_DIR_LIST
do
    cd $dir
    pwd
    git pull
done
