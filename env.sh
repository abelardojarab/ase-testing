#!/bin/sh

if [[ $1 != "" ]]
then
    BASEDIR=$1
else
    BASEDIR=/home/rrsharma/xeon-fpga-src
fi

export ASEVAL_GIT=$BASEDIR/ase_regression/
export BBB_GIT=$BASEDIR/BuildingBlocks/
export BDX_GIT=$BASEDIR/bdx_fpga_piu/
export FPGASW_GIT=$BASEDIR/fpga-sw/
export FPGAINT_GIT=$BASEDIR/cpt_sys_sw-fpga-internal/
export ASE_SRCDIR=$FPGASW_GIT/ase
export ASE_WORKDIR=$FPGASW_GIT/ase/work
export MYINST_DIR=$BASEDIR/myinst

export RELCODE="SKX1"

echo "Directory settings =>"
echo "FPGASW_GIT  : " $FPGASW_GIT
echo "FPGAINT_GIT : " $FPGAINT_GIT
echo "ASEVAL_GIT  : " $ASEVAL_GIT
echo "BBB_GIT     : " $BBB_GIT
echo "ASE_SRCDIR  : " $ASE_SRCDIR
echo "ASE_WORKDIR : " $ASE_WORKDIR
echo "MYINST_DIR  : " $MYINST_DIR
echo "RELCODE     : " $RELCODE
