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

cd $BBB_GIT/BBB_cci_mpf/sw/
make clean
make prefix=$MYINST_DIR

cd $BBB_GIT/BBB_cci_mpf/sample/Hello_ALI_VTP_NLB/SW/
make clean
make prefix=$MYINST_DIR CFLAGS="-I $BBB_GIT/BBB_cci_mpf/sw/include/"
