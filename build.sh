#!/bin/sh

BASEDIR=$(pwd)
AALDIR="$BASEDIR"/aalsdk/
AALUSER="$AALDIR"/aaluser/
AALKERNEL="$AALDIR"/aalkernel/
INSTALL_DIR=$BASEDIR/myinst/

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


