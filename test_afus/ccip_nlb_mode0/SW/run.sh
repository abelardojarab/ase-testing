#!/bin/bash

set -e

LD_LIBRARY_PATH=$MYINST_DIR/lib/

gcc -g -o hello_fpga $FPGASW_GIT/samples/hello_fpga.c -L$MYINST_DIR/lib/ -I $MYINST_DIR/include/ -std=c99 -luuid -lopae-c -lpthread

# Wait for readiness
echo "##################################"
echo "#     Waiting for .ase_ready     #"
echo "##################################"
while [ ! -f $ASE_WORKDIR/.ase_ready.pid ]
do
    sleep 1
done

LD_PRELOAD=libopae-c-ase.so ./hello_fpga
errcode=$?
echo "Error code $errcode"
exit $errcode
