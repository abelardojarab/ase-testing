#!/bin/bash

## Build SW libraries with coverage
$ASEVAL_GIT/sw_build_all.sh cov gtest lib_only parallel

## Clean up coverage directory
/bin/rm -rf $ASE_SRCDIR/coverage/
mkdir -p  $ASE_SRCDIR/coverage/

## Run coverage tests
# $ASEVAL_GIT/svunit_tests.sh ccip_checker_nlb
$ASEVAL_GIT/coverage_generator.sh gtest
$ASEVAL_GIT/coverage_generator.sh ccip_nlb_mode0
# $ASEVAL_GIT/coverage_generator.sh ccip_mmio_rdwr_stress
# $ASEVAL_GIT/coverage_generator.sh ccip_umsg_trigger

## Generate combined report
cd $ASE_SRCDIR/coverage/
lcov -a ccip_nlb_mode0.info \
     -a gtest.info \
     -o raw.info

#    -a ccip_umsg_trigger.info \
#    -a ccip_mmio_rdwr_stress.info \

lcov --remove raw.info 'common.c' 'safe_string/*' 'manage.c' 'reconf.c' 'umsg.c' 'error_report.c' 'event.c' --config-file $ASEVAL_GIT/lcovrc.cfg -o combined.info

genhtml combined.info -o html
