#!/bin/sh

set -e

if [ -z "$FPGASW_GIT" ]; then
    echo "env(FPGASW_GIT) has not been set !"
    exit 1
fi

if [ -z "$BBB_GIT" ]; then
    echo "env(BBB_GIT) has not been set !"
    exit 1
fi

if [ -z "$ASEVAL_GIT" ]; then
    echo "env(ASEVAL_GIT) has not been set !"
    exit 1
fi

cd $BASEDIR
rm -rf $MYINST_DIR

## Build and install fpga-sw
cd $FPGASW_GIT/ase/api/
rm -rf mybuild
mkdir mybuild
cd mybuild
cmake -DCMAKE_INSTALL_PREFIX=$MYINST_DIR ../
make
make install

## Copy include directory to $MYINST_DIR
cp -r $FPGASW_GIT/fpga-api/include/ $MYINST_DIR/include/

## Build and install MPF
cd $BBB_GIT/BBB_cci_mpf/sw/
rm -rf mybuild
mkdir mybuild
cd mybuild
cmake -DCMAKE_INSTALL_PREFIX=$MYINST_DIR/ -DCMAKE_C_FLAGS=-isystem\ $MYINST_DIR/include ../
make 
make install

## Build MPF samples
cd $BBB_GIT/BBB_cci_mpf/test/test-mpf/test_random/sw/
make clean
rm -rf test_random_ase
export LD_LIBRARY_PATH=$MYINST_DIR/lib/
make test_random_ase prefix=$MYINST_DIR/ 
