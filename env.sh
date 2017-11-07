#!/bin/bash

if [[ $1 != "" ]]
then
    BASEDIR=$1
else
    BASEDIR=/home/rrsharma/xeon-fpga-src
fi

export ASEVAL_GIT=$BASEDIR/ase-testing/
export BBB_GIT=$BASEDIR/intel-fpga-bbb-x/
export BDX_GIT=$BASEDIR/bdx_fpga_piu/
export FPGASW_GIT=$BASEDIR/opae-sdk-x/
export FPGAINT_GIT=$BASEDIR/fpga-internal/
export ASE_SRCDIR=$FPGASW_GIT/ase
export ASE_WORKDIR=$FPGASW_GIT/ase/work
export MYINST_DIR=$BASEDIR/myinst
export PLATFORM_DIR=$MYINST_DIR/share/opae/platform

export RELCODE="SKX1"

export PATH=$PATH:$MYINST_DIR/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$MYINST_DIR/lib

echo "Directory settings =>"
echo "FPGASW_GIT      : " $FPGASW_GIT
echo "FPGAINT_GIT     : " $FPGAINT_GIT
echo "ASEVAL_GIT      : " $ASEVAL_GIT
echo "BBB_GIT         : " $BBB_GIT
echo "ASE_SRCDIR      : " $ASE_SRCDIR
echo "ASE_WORKDIR     : " $ASE_WORKDIR
echo "MYINST_DIR      : " $MYINST_DIR
echo "PLATFORM_DIR    : " $PLATFORM_DIR
echo "RELCODE         : " $RELCODE
echo "PATH            : " $PATH
echo "LD_LIBRARY_PATH : " $LD_LIBRARY_PATH
