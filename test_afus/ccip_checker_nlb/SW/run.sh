#!/bin/bash

set -e

CHECKER_DIR=$PWD
LD_LIBRARY_PATH=$MYINST_DIR/lib/
echo $CHECKER_DIR
cd $CHECKER_DIR/../config/SKX1/svunit
ls $CHECKER_DIR/../config/SKX1/svunit
source ./Setup.csh
# Wait for readiness
echo "##################################"
echo "#     Waiting for .ase_ready     #"
echo "##################################"
while [ ! -f $ASE_WORKDIR/.ase_ready.pid ]
do
    sleep 1
done
echo $LD_LIBRARY_PATH
echo $PATH
echo $SVUNIT_INSTALL
cd $CHECKER_DIR/../config/SKX1/svunit/bin
make sim




