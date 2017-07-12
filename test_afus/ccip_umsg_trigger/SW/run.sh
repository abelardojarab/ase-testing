#!/bin/bash

set -e
CURRDIR=$PWD

LD_LIBRARY_PATH=$MYINST_DIR/lib/

# Wait for readiness
echo "##################################"
echo "#     Waiting for .ase_ready     #"
echo "##################################"
while [ ! -f $ASE_WORKDIR/.ase_ready.pid ]
do
    sleep 1
done

cd $ASEVAL_GIT/apps/
./build_all.sh
./umsg_test.out
errcode=$?
echo "Error code $errcode"

# cd $CURRDIR
# gcc -g -o umsg_trigger_test umsg_trigger_test.c $MYINST_DIR/lib/libopae-c-ase.so -I $MYINST_DIR/include -std=c99 -luuid -lpthread
# ./umsg_trigger_test
# errcode=$?
# echo "Error code $errcode"

## Kill the Simualtor
$ASEVAL_GIT/kill_running_ase.sh

