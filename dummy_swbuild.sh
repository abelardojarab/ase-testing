#!/bin/sh

CURRDIR=$PWD

cd $ASE_SRCDIR

if [ -e $ASE_SRCDIR/ase_sources.mk ];
then
    echo "SW config exists .. continue with same"
else
    echo "SW config doesn't exist .. create one"
    cp $ASE_SRCDIR/sample_config/mcp_nlb0/config/* $ASE_SRCDIR
fi

make sw_build

cd $CURRDIR
