#!/bin/bash

set -v
set -e

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
if [ $TESTNAME == "ccip_checker_nlb" ];
then
## Run test
echo "ChangeDir: $ASEVAL_GIT/test_afus/$TESTNAME/SW/"
cd $ASEVAL_GIT/test_afus/$TESTNAME/SW/
./run.sh

fi
