#!/bin/sh

## Run instructions
## $ ./sw_build_all.sh [lib_only] [cov]

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

arg_list="$*"

lib_only=0
cov=0
gtest=0
slim=0

if [[ $arg_list == *"lib_only"* ]];
then
    lib_only=1
fi

if [[ $arg_list == *"cov"* ]];
then
    cov=1
fi

if [[ $arg_list == *"gtest"* ]];
then
    gtest=1
fi

if [[ $arg_list == *"slim"* ]];
then
    slim=1
fi

echo "lib_only = $lib_only"
echo "cov      = $cov"
echo "slim     = $slim"

cd $BASEDIR
rm -rf $MYINST_DIR

## Build and install fpga-sw
cd $FPGASW_GIT/
rm -rf mybuild
mkdir mybuild
cd mybuild

## **FIXME ** Add Gtest enable
if [ $cov -eq 1 ];
then
    cmake -DCMAKE_INSTALL_PREFIX=$MYINST_DIR -DBUILD_ASE=ON -DBUILD_FPGAFX=ON -DBUILD_TESTS=OFF -DCMAKE_BUILD_TYPE=Coverage ../
elif [ $slim -eq 1 ];
then
    cmake -DCMAKE_INSTALL_PREFIX=$MYINST_DIR -DBUILD_LIBFPGA=OFF -DBUILD_ASE=ON -DBUILD_FPGAFX=ON -DBUILD_TESTS=OFF -DCMAKE_BUILD_TYPE=Coverage ../
#    cmake -DCMAKE_INSTALL_PREFIX=$MYINST_DIR -DBUILD_LIBFPGA=OFF -DBUILD_ASE=ON ../
else
    cmake -DCMAKE_INSTALL_PREFIX=$MYINST_DIR -DBUILD_ASE=ON -DBUILD_TESTS=OFF ../
#    cmake -DCMAKE_INSTALL_PREFIX=$MYINST_DIR -DBUILD_ASE=ON -DBUILD_FPGAFX=ON -DBUILD_TESTS=ON -DGTEST_ROOT=/home/rrsharma/other/googletest-release-1.7.0/ ../
fi
make
make install

## If only library is to be built, return right here
if [ $lib_only -eq 1 ];
then
    echo "BBBs will not be built... returning here !"
    exit 0
fi

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

## Build MUX sample
echo "#################################"
echo "#       CCI-P MUX Sample        #"
echo "#################################"
cd $BBB_GIT/BBB_ccip_mux/sample/sw/
gcc -g -o hello_fpga_mux $BBB_GIT/BBB_ccip_mux/sample/sw/hello_fpga_mux.c $MYINST_DIR/lib/libfpga-ASE.so -I $MYINST_DIR/include -std=c99 -luuid


# MMIO Stress
echo "#################################"
echo "#       CCI-P MMIO Sample       #"
echo "#################################"
cd $ASEVAL_GIT/test_afus/ccip_mmio_rdwr_stress/SW/
gcc -g -o mmio_stress mmio_stress.c $MYINST_DIR/lib/libfpga-ASE.so -I $MYINST_DIR/include -luuid -std=c99
