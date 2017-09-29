#!/bin/bash

## Run instructions
## $ ./sw_build_all.sh [lib_only] [cov]

set -e

if [ -z "$FPGASW_GIT" ]; then
    echo "env(FPGASW_GIT) has not been set !"
    exit 1
fi

if [ -z "$ASEVAL_GIT" ]; then
    echo "env(ASEVAL_GIT) has not been set !"
    exit 1
fi

arg_list="$*"

lib_only=0
cov=0
debug=0
gtest=0
parallel=0

if [[ $arg_list == *"lib_only"* ]];
then
    lib_only=1
fi

if [[ $arg_list == *"cov"* ]];
then
    cov=1
fi

if [[ $arg_list == *"debug"* ]];
then
    debug=1
fi

if [[ $arg_list == *"gtest"* ]];
then
    gtest=1
fi

if [[ $arg_list == *"parallel"* ]];
then
    parallel=1
fi

echo "Build OPAE stack with ASE = $lib_only"
echo "Build OPAE with coverage  = $cov"
echo "Build OPAE with debug     = $debug"
echo "Build OPAE with GTest     = $gtest"
echo "Enable Parallel option    = $parallel"

cd $BASEDIR
rm -rf $MYINST_DIR

## Build and install fpga-sw
cd $FPGASW_GIT/
rm -rf mybuild
mkdir mybuild
cd mybuild

## CMake command
cmake_cmd="cmake ../ -DCMAKE_INSTALL_PREFIX=$MYINST_DIR -DBUILD_ASE=ON"

## {lcov, debug, slim build options"
if [ $cov -eq 1 ];
then
    cmake_cmd="$cmake_cmd -DCMAKE_BUILD_TYPE=Coverage"
elif [ $debug -eq 1 ];
then
    cmake_cmd="$cmake_cmd -DCMAKE_BUILD_TYPE=Debug"
elif [ $lib_only -eq 1 ];
then
    cmake_cmd="$cmake_cmd "
fi

## Gtest support
if [ $gtest -eq 1 ];
then
    cmake_cmd="$cmake_cmd -DBUILD_TESTS=ON -DGTEST_ROOT=/home/rrsharma/googletest/myinst/"
fi

## CMake command
eval $cmake_cmd

## Build and install
if [ $parallel -eq 1 ];
then
    make -j 8
else
    make
fi
make install

## If only library is to be built, return right here
if [ $lib_only -eq 1 ];
then
    echo "BBBs will not be built... returning here !"
    exit 0
fi

## BBB_GIT check
if [ -z "$BBB_GIT" ]; then
    echo "env(BBB_GIT) has not been set !"
    exit 1
fi

## Build and install MPF
cd $BBB_GIT/BBB_cci_mpf/sw/
rm -rf mybuild
mkdir mybuild
cd mybuild
cmake -DCMAKE_INSTALL_PREFIX=$MYINST_DIR/ -DCMAKE_C_FLAGS=-isystem\ $MYINST_DIR/include ../
if [ $parallel -eq 1 ];
then
    make -j 8
else
    make
fi
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
cd $BBB_GIT/BBB_ccip_mux/samples/sw/
gcc -g -o hello_fpga_mux hello_fpga_mux.c $MYINST_DIR/lib/libopae-c-ase.so -I $MYINST_DIR/include -std=c99 -luuid


# MMIO Stress
echo "#################################"
echo "#       CCI-P MMIO Sample       #"
echo "#################################"
cd $ASEVAL_GIT/test_afus/ccip_mmio_rdwr_stress/SW/
gcc -g -o mmio_stress mmio_stress.c -I $MYINST_DIR/include  -L $MYINST_DIR/lib -luuid -lopae-c -lpthread -std=c99 
