#!/bin/bash

set -v
set -e

arg_list="$*"
## Sanity check input
if [ "$1" = "" ];
then
    echo "Test input name is required!"
    return 1
else
    echo "TESTNAME = $1"
    TESTNAME=$1
fi

## Copy over the Makefile
cd $ASE_SRCDIR/

## Config set up
$ASEVAL_GIT/create_bbb_afu_files.sh $TESTNAME
if [ $TESTNAME == "ccip_nlb_mode0" ];
then
    $ASEVAL_GIT/config_generator.sh single 1234 noisy 300.0 32 > $ASE_SRCDIR/ase.cfg
elif [ $TESTNAME == "ccip_umsg_trigger" ];
then
    $ASEVAL_GIT/config_generator.sh multi 1234 silent 300.0 32 > $ASE_SRCDIR/ase.cfg
elif [ $TESTNAME == "gtest" ];
then
    $ASEVAL_GIT/config_generator.sh multi 0 silent 270.0 32 > $ASE_SRCDIR/ase.cfg
elif [ $TESTNAME == "ccip_app_idiotproof" ];
then
    $ASEVAL_GIT/config_generator.sh multi 0 silent 145.0 16 > $ASE_SRCDIR/ase.cfg
fi

## Build with coverage metrics
cd $ASE_SRCDIR/
make SIMULATOR=QUESTA ASE_DEBUG=0

## Run simulation
cd $ASE_WORKDIR/
vsim -c -l run.log -dpioutoftheblue 1 -novopt -sv_lib ase_libs -do "$ASE_SRCDIR/vsim_run.tcl" "+CONFIG=$ASE_SRCDIR/ase.cfg" ase_top &> /dev/null &

## Wait until ready
$ASEVAL_GIT/wait_till_ase_ready.sh

## Run test
echo "ChangeDir: $ASEVAL_GIT/test_afus/$TESTNAME/SW/"
cd $ASEVAL_GIT/test_afus/$TESTNAME/SW/
./run.sh

## Kill application
$ASEVAL_GIT/kill_running_ase.sh
sleep 2

