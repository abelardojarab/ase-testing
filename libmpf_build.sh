#!/bin/sh

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

cd $BBB_GIT/cci_mpf/SW/
make clean
make prefix=$MYINST_DIR

cd $BBB_GIT/cci_mpf/Hello_ALI_VTP_NLB/SW/
make clean
make prefix=$MYINST_DIR
