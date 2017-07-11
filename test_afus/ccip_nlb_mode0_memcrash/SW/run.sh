#!/bin/bash

set -e

LD_LIBRARY_PATH=$MYINST_DIR/lib/

gcc -g -o hello_fpga_memcrash hello_fpga_memcrash.c $MYINST_DIR/lib/libopae-c-ase.so -I $MYINST_DIR/include/ -std=c99 -luuid -lpthread

# Wait for readiness
echo "##################################"
echo "#     Waiting for .ase_ready     #"
echo "##################################"
while [ ! -f $ASE_WORKDIR/.ase_ready.pid ]
do
    sleep 1
done

./hello_fpga_memcrash

if [ -e $ASE_WORKDIR/ase_memory_error.log ];
then
    echo "Error file found"
    errcode=0
else
    echo "Error file not found -- marking failure"
    errcode=1
fi
exit $errcode
