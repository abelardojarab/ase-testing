#!/bin/sh

gcc -g -o mmio_stress mmio_stress.c $MYINST_DIR/lib/libfpga-ASE.so -I $MYINST_DIR/include -luuid -std=c99

# Wait for readiness
echo "##################################"
echo "#     Waiting for .ase_ready     #"
echo "##################################"
while [ ! -f $ASE_WORKDIR/.ase_ready.pid ]
do
    sleep 1
done

LD_LIBRARY_PATH=$MYINST_DIR/lib/

/usr/bin/timeout 1800 ./mmio_stress
errcode=$?
echo "Error code $errcode"
