#!/bin/bash

set -v

if [ -z "$AALSDK_GIT" ]; then
    echo "env(AALSDK_GIT) has not been set !"
    exit 1
fi

if [ -z "$BBB_GIT" ]; then
    echo "env(BBB_GIT) has not been set !"
    exit 1
fi

if [ -z "$ASEVAL_GIT" ]; then
    echo "env(ASEVAL_GIT) has not been set !"
    exit 1
fi


cd $AALUSER_DIR/mybuild
make -j 8 || exit 1
make install || exit 1

cd $MYINST_DIR/lib/
objdump -S libASE.so > libASE.obj

