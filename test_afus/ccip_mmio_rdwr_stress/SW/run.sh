#!/bin/sh

set -e

gcc -g -o mmio_stress mmio_stress.c -I $MYINST_DIR/include  -L $MYINST_DIR/lib -luuid -lopae-c -lpthread -std=c99 

# Wait for readiness
echo "##################################"
echo "#     Waiting for .ase_ready     #"
echo "##################################"
while [ ! -f $ASE_WORKDIR/.ase_ready.pid ]
do
    sleep 1
done

/usr/bin/timeout 1800  LD_PRELOAD=libopae-c-ase.so LD_LIBRARY_PATH=$MYINST_DIR/lib/  ./mmio_stress

errcode=$?
echo "Error code $errcode"
