#!/bin/sh

if [[ $1 != "" ]]
then
    BASEDIR=$1
else
    BASEDIR=/home/rrsharma/xeon-fpga-src
fi

# export AALSDK_GIT=$BASEDIR/aalsdk/
export ASEVAL_GIT=$BASEDIR/ase_regression/
export BBB_GIT=$BASEDIR/BuildingBlocks/
export BDX_GIT=$BASEDIR/bdx_fpga_piu/
export FPGASW_GIT=$BASEDIR/fpga-sw/

# export AALUSER_DIR=$AALSDK_GIT/aaluser
export ASE_SRCDIR=$FPGASW_GIT/ase
export ASE_WORKDIR=$FPGASW_GIT/ase/work
# export AALKERN_DIR=$AALSDK_GIT/aalkernel
# export MYINST_DIR=$BASEDIR/myinst
# export AALSAMP_DIR=$AALSDK_GIT/aalsamples

export RELCODE="SKX1"

echo "Directory settings =>"
echo "FPGASW_GIT  : " $FPGASW_GIT
# echo "AALSDK_GIT  : " $AALSDK_GIT
echo "ASEVAL_GIT  : " $ASEVAL_GIT
echo "BBB_GIT     : " $BBB_GIT
# echo "AALUSER_DIR : " $AALUSER_DIR
echo "ASE_SRCDIR  : " $ASE_SRCDIR
echo "ASE_WORKDIR : " $ASE_WORKDIR
# echo "AALKERN_DIR : " $AALKERN_DIR
echo "MYINST_DIR  : " $MYINST_DIR
# echo "AALSAMP_DIR : " $AALSAMP_DIR
echo "RELCODE     : " $RELCODE

