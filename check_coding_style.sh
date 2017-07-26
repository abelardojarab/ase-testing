#!/bin/sh

set -e

LOGNAME=$ASEVAL_GIT/style_issues.log
CHECK_SCRIPT=/home/eluebber/work/intel-fpga/scripts/checkpatch.pl

if [[ $ASE_SRCDIR == "" ]];
then
    echo "env(ASE_SRCDIR) has not been set up -- exiting here"
    exit -1
else
    cd $ASE_SRCDIR
    make clean
    find . -name \*.c -exec $CHECK_SCRIPT --no-tree --no-signoff --file {} \; &> $LOGNAME
fi

