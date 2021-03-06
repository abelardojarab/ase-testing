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

## Coverage directory name, create if not available
ASE_COV=$ASE_SRCDIR/coverage/
mkdir -p $ASE_COV

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
$ASEVAL_GIT/add_ase_secret_option.sh cov
make ASE_COVERAGE=1 ASE_DEBUG=0

## Run simulation
cd $ASE_WORKDIR/
./ase_simv -ucli -do $ASE_SRCDIR/vcs_run.tcl +CONFIG=$ASE_SRCDIR/ase.cfg -cm line+cond+fsm+branch+tgl -cm_name $$TESTNAME &> /dev/null &

## Wait until ready
$ASEVAL_GIT/wait_till_ase_ready.sh

## Run test
echo "ChangeDir: $ASEVAL_GIT/test_afus/$TESTNAME/SW/"
cd $ASEVAL_GIT/test_afus/$TESTNAME/SW/
./run.sh

## Kill application
$ASEVAL_GIT/kill_running_ase.sh
sleep 2

#######################################
##                                   ##
##     Coverage report generation    ##
##                                   ##
#######################################
if [[ $arg_list == *"cov"* ]];
then
cd $ASE_COV
lcov --capture \
     --test-name $TESTNAME \
     --base-directory $PWD \
     --directory $FPGASW_GIT/build/ase/api/CMakeFiles/opae-c-ase.dir/__/sw/ \
     --directory $FPGASW_GIT/build/ase/api/CMakeFiles/opae-c-ase.dir/src/ \
     --directory $ASE_WORKDIR/ \
     --output-file $TESTNAME.info

## Generate HTML
genhtml $TESTNAME.info --output-directory html_$TESTNAME

## Convert cov_db to reports
urg -full64 -dir ase_simv.vdb -show tests -format both
fi
