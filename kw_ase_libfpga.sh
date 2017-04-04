#!/bin/sh

set -e

BASEDIR=$PWD

### Build libfpga
cd $BASEDIR/ase/api/
rm -rf mybuild
mkdir mybuild
cd mybuild
cmake ../
make

### Build ASE portion
export VCS_HOME=/home/rpdevbox/tools/vcs/

cd $BASEDIR/ase/
./scripts/generate_ase_environment.py ../samples/

make sw_build
