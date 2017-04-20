#!/bin/sh
cd $1
mkdir myinst
cd $FPGASW_GIT/ase/api
rm -rf mybuild
mkdir mybuild
cd mybuild
cmake -DCMAKE_INSTALL_PREFIX=$MYINST_DIR -DBUILD_ASE=ON ../../.. 
make
make install

## Copy include directory to $MYINST_DIR
cp -r $FPGASW_GIT/common/include/ $MYINST_DIR/include/


cd $BBB_GIT/BBB_cci_mpf/sw/
rm -rf mybuild
mkdir mybuild
cd mybuild
cmake -DCMAKE_INSTALL_PREFIX=$MYINST_DIR/ -DCMAKE_C_FLAGS=-isystem\ $MYINST_DIR/include ../
make
make install

## Build MPF samples
export LD_LIBRARY_PATH=$MYINST_DIR/lib/
cd $BBB_GIT/BBB_cci_mpf/test/test-mpf/test_random/sw/
make clean
rm -rf test_random_ase
make test_random_ase prefix=$MYINST_DIR/
make all prefix=$MYINST_DIR/
