#!/bin/bash

set -e

if [[ $FPGASW_GIT == "" ]];
then
    echo "Looks like FPGASW_GIT has not been set, see <OPAE>/ase-testing/env.sh to set the right variables"
fi

git clone git@github.intel.com:OPAE/opae-sdk-x.git
git clone git@github.intel.com:OPAE/ase-testing.git
git clone git@github.intel.com:OPAE/intel-fpga-bbb-x.git

