#!/bin/sh

# Tool setting
if [ "$1" == "VCS" ] ; then 
    echo "Running VCS mode"
elif [ "$1" == "QUESTA" ] ; then
    echo "Running QUESTA mode"
else
    echo "** ERROR: Tool unidentified **"
    echo "** You must specify tool when running **"
    echo "** ./build.sh <VCS|QUESTA> [AALCLONE_DISABLE] **"
    exit
fi

# AAL Clone disable
if [ "$2" == "AALCLONE_DISABLE" ] ; then
    echo "AALSDK will not be cloned"
    aalclone_disable=1
else
    echo "AAL will be cloned"
    aalclone_disable=0
fi

BASEDIR=$(pwd)
AALDIR="$BASEDIR"/aalsdk/
AALUSER="$AALDIR"/aaluser/
AALKERNEL="$AALDIR"/aalkernel/
INSTALL_DIR=$BASEDIR/myinst/
ASE_DEBUG=$ASE_DEBUG
ASE_DIR=$AALUSER/ase/
TESTS_BASE=$BASEDIR/tests/
PEEKPOKE_APPS=$BASEDIR/apps/

echo "################################################"
echo "#                                              #"
echo "#               Setup variables                #"
echo "#                                              #"
echo "################################################"
echo "VCS Version       : " $VCS_HOME
echo "Quartus Version   : " $QUARTUS_HOME
echo "Questasim Version : " $MTI_HOME
echo "ASE_DEBUG         : " $ASE_DEBUG

if [ -z "$VCS_HOME" ]; then
    echo "VCS_HOME must be set"
    exit 1
fi

if [ -z "$MTI_HOME" ]; then
    echo "MTI_HOME must be set"
    exit 1
fi

if [ -z "$QUARTUS_HOME" ]; then
    echo "QUARTUS_HOME must be set"
    exit
fi

if [ -z "$ASE_DEBUG" ]; then
    echo "ASE_DEBUG must be set"
    exit
fi

# Set submodule directory to my branch
if [ $aalclone_disable == "0" ] ; then
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
fi

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
if [ "$1" == "VCS" ]
then 
    ./scripts/generate_ase_environment.py -t VCS $TESTS_BASE/nlb_allmodes/HW/
    ASE_WORKDIR=$AALUSER/ase/work/
elif [ "$1" == "QUESTA" ]
then
    ./scripts/generate_ase_environment.py -t QUESTA $TESTS_BASE/nlb_allmodes/HW/
    ASE_WORKDIR=$AALUSER/ase/
fi

make ASE_DEBUG=$ASE_DEBUG
cp $BASEDIR/fpga-regress.py $INSTALL_DIR/bin/
cp $BASEDIR/testlib.py $INSTALL_DIR/bin/


echo "################################################"
echo "#                                              #"
echo "#                Starting ASE                  #"
echo "#                                              #"
echo "################################################"
make sim | tee $BASEDIR/sim.log & 
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
./stress.sh 200 | tee $BASEDIR/stress.log
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

