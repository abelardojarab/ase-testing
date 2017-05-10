#!/bin/sh

set -e

LD_LIBRARY_PATH=$MYINST_DIR/lib/

gcc -g -o hello_fpga_ase $FPGASW_GIT/libfpga/samples/hello_fpga.c $MYINST_DIR/lib/libfpga-ASE.so -I $MYINST_DIR/include/ -std=c99 -luuid

# Wait for readiness
echo "##################################"
echo "#     Waiting for .ase_ready     #"
echo "##################################"
while [ ! -f $ASE_WORKDIR/.ase_ready.pid ]
do
    sleep 1
done

/usr/bin/timeout 1800 ./hello_fpga_ase 
errcode=$?
echo "Error code $errcode"

