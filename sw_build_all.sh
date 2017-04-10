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
cd $FPGASW_GIT/
rm -rf mybuild
mkdir mybuild
cd mybuild
cmake -DCMAKE_INSTALL_PREFIX=$MYINST_DIR -DBUILD_ASE=YES ../
make
make install

## Copy include directory to $MYINST_DIR
# cp -r $FPGASW_GIT/common/include/ $MYINST_DIR/include/

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

## Build NLB hello_fpga
# mkdir -p $MYINST_DIR/bin/
# cd  $MYINST_DIR/bin/
# gcc -g -o hello_fpga $FPGASW_GIT/fpga-api/samples/hello_fpga.c $MYINST_DIR/lib/libfpga-ASE.so -I $MYINST_DIR/include -std=c99 -luuid

## Build MMIO stress test
# cd $MYINST_DIR/bin/
# gcc -g -o $ASEVAL_GIT/test_afus/

## Build MUX sample
cd $BBB_GIT/BBB_ccip_mux/sample/sw/
gcc -g -o hello_fpga_mux $BBB_GIT/BBB_ccip_mux/sample/sw/hello_fpga_mux.c $MYINST_DIR/lib/libfpga-ASE.so -I $MYINST_DIR/include -std=c99 -luuid
