#!/bin/sh

BASEDIR=$(pwd)
AALDIR="$BASEDIR"/aalsdk/
AALUSER="$AALDIR"/aaluser/
AALKERNEL="$AALDIR"/aalkernel/
INSTALL_DIR=$BASEDIR/myinst/
ASE_DEBUG=$ASE_DEBUG
ASE_DIR=$AALUSER/ase/
TESTS_BASE=$BASEDIR/tests/
ASE_WORKDIR=$AALUSER/ase/work/
PEEKPOKE_APPS=$BASEDIR/apps/

echo "################################################"
echo "#                                              #"
echo "#               Setup variables                #"
echo "#                                              #"
echo "################################################"
echo "VCS Version     : " $VCS_HOME
echo "Quartus Version : " $QUARTUS_HOME
echo "ASE_DEBUG       : " $ASE_DEBUG

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
echo "#           Building Peek-Poke apps            #"
echo "#                                              #"
echo "################################################"
cd $PEEKPOKE_APPS
./build.sh $ASE_DIR
cd $BASEDIR

echo "################################################"
echo "#                                              #"
echo "#                Building ASE                  #"
echo "#                                              #"
echo "################################################"
cd $ASE_DIR
./scripts/env_check.sh
./scripts/generate_ase_environment.py $TESTS_BASE/nlb_allmodes/HW/
make ASE_DEBUG=$ASE_DEBUG
cp $BASEDIR/fpga-regress.py $INSTALL_DIR/bin/
cp $BASEDIR/testlib.py $INSTALL_DIR/bin/


echo "################################################"
echo "#                                              #"
echo "#                Starting ASE                  #"
echo "#                                              #"
echo "################################################"
xterm -e make sim &
echo "Waiting for simulator to be ready ."
while [ ! -f "$ASE_WORKDIR/.ase_ready.pid" ]
do
    echo "."
    sleep 1
done
SIM_PID=$(cat "$ASE_WORKDIR/.ase_ready.pid")
echo "Simulator is ready with PID $SIM_PID"


echo "################################################"
echo "#                                              #"
echo "#                Starting APP                  #"
echo "#                                              #"
echo "################################################"
echo "Testing peek-poke application"
cd $PEEKPOKE_APPS
export ASE_WORKDIR="$ASE_WORKDIR"
xterm -e ./stress.sh 200 
sleep 3
cd $BASEDIR


echo "################################################"
echo "#                                              #"
echo "#           Killing ASE Simulator              #"
echo "#                                              #"
echo "################################################"
echo "Killing process $SIM_PID"
if ps -p $SIM_PID > /dev/null
then
    echo "Process running..."
    kill $SIM_PID
fi

