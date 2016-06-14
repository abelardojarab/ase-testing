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

cd $BASEDIR
rm -rf $MYINST_DIR

cd $AALSDK_GIT
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

cd $AALSAMP_DIR/Hello_ALI_NLB/SW/
sed -i 's/#define  HWAFU/\/\/#define  HWAFU/g' HelloALINLB.cpp
sed -i 's/\/\/#define  ASEAFU/#define  ASEAFU/g' HelloALINLB.cpp
make prefix=$MYINST_DIR || exit 1

