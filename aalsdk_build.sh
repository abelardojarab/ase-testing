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

cd $AALUSER_DIR
mkdir mybuild
cd mybuild
../configure --prefix=$MYINST_DIR
make -j 8
make install

cd $AALKERN_DIR
mkdir mybuild
cd mybuild
../configure --prefix=$MYINST_DIR
make -j 8 


