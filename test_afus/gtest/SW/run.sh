#!/bin/bash

set -e

CURR_DIR=$PWD

LD_LIBRARY_PATH=$MYINST_DIR/lib/

cd $FPGASW_GIT/mybuild/bin/

# Wait for readiness
echo "##################################"
echo "#     Waiting for .ase_ready     #"
echo "##################################"
while [ ! -f $ASE_WORKDIR/.ase_ready.pid ]
do
    sleep 1
done

./gtase

errcode=$?
echo "Error code $errcode"
exit $errcode

cd $CURR_DIR
