#!/bin/sh

BASEDIR=$(pwd)
AALDIR="$BASEDIR"/aalsdk/
AALUSER="$AALDIR"/aaluser/
AALKERNEL="$AALDIR"/aalkernel/
INSTALL_DIR=$BASEDIR/myinst/
ASE_DEBUG=$ASE_DEBUG
ASE_DIR=$AALUSER/ase/
TESTS_BASE=$BASEDIR/tests/

echo "################################################"
echo "#                                              #"
echo "#               Setup variables                #"
echo "#                                              #"
echo "################################################"
echo "VCS Version : " $VCS_HOME
echo "ASE_DEBUG   : " $ASE_DEBUG

# Set submodule directory to my branch
echo "################################################"
echo "#                                              #"
echo "#           AALSDK Anonymous pull              #"
echo "#                                              #"
echo "################################################"
rm -rf aalsdk
git clone git://aalrepo.jf.intel.com/aalsdk aalsdk
cd aalsdk
git checkout ase_ccip
cd ..

echo "################################################"
echo "#                                              #"
echo "#              Building AALSDK                 #"
echo "#                                              #"
echo "################################################"
cd $AALDIR
./prep-build
cd $AALUSER
mkdir mybuild
cd mybuild
../configure --prefix=$INSTALL_DIR
make -j 8
make install

cd $AALKERNEL
mkdir mybuild
cd mybuild 
../configure --prefix=$INSTALL_DIR
make -j 8
make install

cd $BASEDIR

echo "################################################"
echo "#                                              #"
echo "#                Building ASE                  #"
echo "#                                              #"
echo "################################################"
cd $ASE_DIR
./scripts/generate_ase_envrionment.py $TESTS_BASE/nlb_mode0/HW/
make ASE_DEBUG=$ASE_DEBUG

