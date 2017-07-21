#!/bin/bash

set -e

LD_LIBRARY_PATH=$MYINST_DIR/lib/

cd $FPGASW_GIT/mybuild/bin/

./gtase

errcode=$?
echo "Error code $errcode"
exit $errcode

