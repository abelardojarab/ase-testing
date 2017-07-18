#!/bin/bash
set -e

##Install GOOGLE TESTS
# cd $ASEVAL_GIT/test_afus/gtest/SW
# git pull
# tar -xzvf googletest-release-1.8.0.tar.gz
# cd googletest-release-1.8.0
# mkdir build
# cd build
# cmake ../ -DCMAKE_INSTALL_PREFIX=$ASEVAL_GIT/myinst
# make
# make install

## Build GTESTS for ASE.
cd $FPGASW_GIT
git checkout feature/GTEST-NOMERGE_ASE
#git merge develop
cd $FPGASW_GIT/ase/api
rm -rf mybuild
mkdir mybuild
cd mybuild
cmake ../../.. -DBUILD_ASE=ON -DBUILD_TESTS=ON -DGTEST_ROOT=/home/rrsharma/googletest/myinst/
make

# Wait for readiness
# echo "##################################"
# echo "#     Waiting for .ase_ready     #"
# echo "##################################"
# while [ ! -f $ASE_WORKDIR/.ase_ready.pid ]
# do
# sleep 1
# done

./bin/gtase

