#!/bin/sh

# set -e
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

cd $CURRDIR
gcc -g -o umsg_trigger_test umsg_trigger_test.c /home/rrsharma/xeon-fpga-src/myinst/lib/libfpga-ASE.so -I /home/rrsharma/xeon-fpga-src/myinst/include -std=c99 -luuid -lpthread
./umsg_trigger_test | echo "This should have failed"
errcode=$?
echo "Error code $errcode"

## Kill the Simualtor
$ASEVAL_GIT/kill_running_ase.sh
