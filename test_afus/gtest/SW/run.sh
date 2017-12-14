#!/bin/bash

set -e

CURR_DIR=$PWD

LD_LIBRARY_PATH=$MYINST_DIR/lib/

cd $FPGAINT_GIT/tests

# Wait for readiness
echo "##################################"
echo "#     Waiting for .ase_ready     #"
echo "##################################"
while [ ! -f $ASE_WORKDIR/.ase_ready.pid ]
do
    sleep 1
done

ASE_LOG=0 LD_PRELOAD=libopae-c-ase.so LD_LIBRARY_PATH=$MYINST_DIR/lib/  ./build/gtase --gtest_filter="*CommonALL*"

errcode=$?
echo "Error code $errcode"
exit $errcode

cd $CURR_DIR
