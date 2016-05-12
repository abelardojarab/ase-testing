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

rm -rf $MYINST_DIR
./prep-build --deep-clean
./prep-build

cd $AALUSER_DIR
rm -rf mybuild
mkdir mybuild
cd mybuild
../configure --prefix=$MYINST_DIR || exit 1
make -j 8 || exit 1
make install || exit 1

cd $AALKERN_DIR
rm -rf mybuild
mkdir mybuild
cd mybuild
../configure --prefix=$MYINST_DIR || exit 1
make -j 8  || exit 1


