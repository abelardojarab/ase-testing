#!/bin/bash
set -e
cd $FPGASW_GIT
git checkout feature/ase_gtest-NOMERGE
cd $FPGASW_GIT/ase/api
mkdir mybuild
cd mybuild
cmake ../../.. -DBUILD_ASE=ON -DBUILD_TESTS=ON
make

./bin/gtase

