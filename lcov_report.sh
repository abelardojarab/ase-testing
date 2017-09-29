#!/bin/bash

set -e

## Build SW libraries with coverage
$ASEVAL_GIT/sw_build_all.sh cov parallel

## Clean up coverage directory
/bin/rm -rf $ASE_SRCDIR/coverage/
mkdir -p  $ASE_SRCDIR/coverage/

## Run coverage tests
# $ASEVAL_GIT/svunit_tests.sh ccip_checker_nlb
$ASEVAL_GIT/coverage_generator.sh ccip_nlb_mode0
$ASEVAL_GIT/coverage_generator.sh ccip_mmio_rdwr_stress
# $ASEVAL_GIT/coverage_generator.sh ccip_umsg_trigger
# $ASEVAL_GIT/coverage_generator.sh gtest
$ASEVAL_GIT/coverage_generator.sh ccip_nlb_mode0_memcrash
# $ASEVAL_GIT/coverage_generator.sh ccip_app_idiotproof

## Generate combined report
cd $ASE_SRCDIR/coverage/
lcov -a ccip_nlb_mode0.info \
     -a ccip_mmio_rdwr_stress.info \
     -a ccip_nlb_mode0_memcrash.info \
     -o raw.info


lcov --remove raw.info 'common.c' '*safe_string*' 'reconf.c' 'umsg.c' -o combined.info

genhtml combined.info -o html/


#     -a ccip_umsg_trigger.info \
#     -a gtest.info \
#     -a ccip_app_idiotproof.info \
# genhtml combined.info
