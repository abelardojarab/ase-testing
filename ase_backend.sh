#!/bin/bash

set -e

gtest = 0
cd $BASEDIR
rm -rf $MYINST_DIR

## Build and install fpga-sw
cd $FPGASW_GIT/

rm -rf mybuild
mkdir mybuild
cd mybuild

cmake_cmd="cmake ../ -DCMAKE_INSTALL_PREFIX=$MYINST_DIR -DBUILD_ASE=ON"

## Gtest support
if [ $gtest -eq 1 ];
then
    cmake_cmd="$cmake_cmd"
fi

## CMake command
eval $cmake_cmd
make -j 8
make install