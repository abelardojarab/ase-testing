#!/bin/sh

set -e

LD_LIBRARY_PATH=$MYINST_DIR/lib/

gcc -g -o hello_mem_afu hello_mem_afu.c -L $MYINST_DIR/lib/ -I $MYINST_DIR/include -DUSE_ASE=1 -lopae-c -luuid -lpthread

# Wait for readiness
echo "##################################"
echo "#     Waiting for .ase_ready     #"
echo "##################################"
while [ ! -f $ASE_WORKDIR/.ase_ready.pid ]
do
    sleep 1
done

LD_PRELOAD="$MYINST_DIR/lib/libopae-c-ase.so" ./hello_mem_afu 2 1
errcode=$?
echo "Error code $errcode"
exit $?
