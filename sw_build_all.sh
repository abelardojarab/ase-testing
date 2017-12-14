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
internal=0

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

if [[ $internal == *"internal"* ]];
then
    internal=1
fi

if [[ $internal -eq 1 ]];
then
    echo "######################################"
    echo "# Building internal GIT              #"
    echo "######################################"
    FPGASW_GIT=$FPGASW_GIT/../opae-sdk-x
    BBB_GIT=$BBB_GIT/../intel-fpga-bbb-x
else
    echo "######################################"
    echo "# Building external GIT              #"
    echo "######################################"
    FPGASW_GIT=$FPGASW_GIT/../opae-sdk
    BBB_GIT=$BBB_GIT/../intel-fpga-bbb
fi

echo "Build OPAE stack with ASE = $lib_only"
echo "Build OPAE with coverage  = $cov"
echo "Build OPAE with debug     = $debug"
echo "Build OPAE with GTest     = $gtest"
echo "Enable Parallel option    = $parallel"
echo "FPGASW_GIT                = $FPGASW_GIT"
echo "BBB_GIT                   = $BBB_GIT"

cd $BASEDIR
rm -rf $MYINST_DIR

## Build and install fpga-sw
cd $FPGASW_GIT/

# Temporary hack to keep RTL simulator scripts that expect to find
# ccip_if_pkg.sv in ASE.  Once all users have platform_db on their
# branches, change all references in hand-written simulator configurations
# from $ASE_SRCDIR/rtl/ccip_if_pkg.sv to
# $PLATFORM_DIR/platform_if/rtl/device_if/ccip_if_pkg.sv
pushd ase/rtl
if [ ! -e ccip_if_pkg.sv ]; then
    ln -s ../../platforms/platform_if/rtl/device_if/ccip_if_pkg.sv
fi
popd

rm -rf build
mkdir build
cd build

## CMake command
cmake_cmd="cmake ../ -DCMAKE_INSTALL_PREFIX=$MYINST_DIR -DBUILD_ASE=ON"
cmake_cmd_gtest="cmake ../ -DBUILD_ASE=ON"

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

cd $FPGASW_GIT/build
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

## Gtest support
if [ $gtest -eq 1 ];
then 
    cd $FPGAINT_GIT/tests
    rm -rf build
    mkdir build
    cd build
    cmake_cmd_gtest="$cmake_cmd_gtest -DOPAE_SDK_SOURCE=$FPGASW_GIT "
    eval $cmake_cmd_gtest
    make -j8
fi

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
