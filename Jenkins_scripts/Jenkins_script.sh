#!/bin/sh

cd $ASE_SRCDIR
make clean

rm -rf $ASE_API_DIR/mybuild

echo '************************************'
echo $ASEVAL_GIT
echo '************************************'
echo $1

echo '********************************************************************************'
echo '******************** Setting up the ASE Environment ****************************'
echo '********************************************************************************'

cd $ASE_SRCDIR
python scripts/generate_ase_environment.py $1

make -j8
make sim &

###############################################################################
##################            APPLICATION  SIDE            ####################
###############################################################################

echo "############################### #################################################"
echo "######################   	 Build libfpga-ASE library    #########################"
echo "#################################################################################"
rm -rf $ASE_API_DIR/mybuild
cd $ASE_API_DIR
mkdir  mybuild
cd mybuild

cmake ../ -DCMAKE_BUILD_TYPE=Coverage 

make VERBOSE=1

export LD_LIBRARY_PATH=$PWD

echo "############################### #################################################"
echo "#############################   	 Building samples   # #########################"
echo "#################################################################################"
LIBNAME=libfpga-ASE.so

gcc -g -o $TEST_AFU_DIR $1/SW/*.c $LIBNAME -I$AALSDK_GIT/common/include/ -std=c99 -luuid -lgcov
export ASE_WORKDIR=$ASE_WORKDIR
if [ -z "$ASE_WORKDIR" ]
then
echo '??????????????????????????????? ASE_WORKDIR is not set ??????????????????????????'
else
echo "#############################   ASE_WORKDIR is set   ############################"
lcov --zerocounters --directory .
lcov --capture --initial --directory . --output-file coverage_new

./$TEST_AFU_DIR

lcov --no-checksum --directory .  --capture --output-file coverage_new.info
genhtml coverage_new.info --output-directory coverage_out

fi
