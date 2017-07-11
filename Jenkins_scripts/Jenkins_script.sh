#!/bin/bash
set -e

#echo '********************************************************************************'
#echo '******************** Setting up the ASE Environment ****************************'
#echo '********************************************************************************'

cd $ASE_SRCDIR
if [ "$TEST_AFU_DIR" = 'ccip_async_mux_4nlb' ]; then
#cp $ASEVAL_GIT/test_afus/$TEST_AFU_DIR/config/SKX1/* ./ 
cp $BBB_GIT/BBB_ccip_mux/sample/sw/*.c $1/SW
sed -i 's/define+NLB400_MODE_0/define+NLB400_MODE_0 +define+NUM_AFUS_4/g' Makefile
elif [ "$TEST_AFU_DIR" = 'ccip_mmio_rdwr_stress' ]; then
#cp $ASEVAL_GIT/test_afus/$TEST_AFU_DIR/config/SKX1/* ./ 
echo " DO NOTHING"
else
cp $FPGASW_GIT/libfpga/samples/hello_fpga.c $1/SW
echo "COPy Successful"
fi

###############################################################################
##################            APPLICATION  SIDE            ####################
###############################################################################

echo "############################### #################################################"
echo "######################   	 Build libfpga-ASE library    #########################"
echo "#################################################################################"
if [ "$TEST_AFU_DIR" = 'test_random_ase' ]; then
cd $SCRIPTS
./test_mpf.sh $BBB_GIT/..
else
rm -rf $ASE_API_DIR/mybuild
cd $ASE_API_DIR
mkdir  mybuild
cd mybuild

cmake ../../.. -DBUILD_ASE=ON -DCMAKE_BUILD_TYPE=Coverage

make VERBOSE=1

export LD_LIBRARY_PATH=$ASE_API_DIR/mybuild/lib

echo "############################### #################################################"
echo "#############################   	 Building samples   # #########################"
echo "#################################################################################"

gcc -g -o test_bb $1/SW/*.c $ASE_API_DIR/mybuild/lib/libfpga-ASE.so -I$FPGASW_GIT/common/include/ -std=c99 -luuid -lgcov
fi

export ASE_WORKDIR=$ASE_WORKDIR
if [ -z "$ASE_WORKDIR" ]
then
echo '??????????????????????????????? ASE_WORKDIR is not set ??????????????????????????'
else
echo "#############################   ASE_WORKDIR is set   ############################"
if [ "$TEST_AFU_DIR" = 'test_random_ase' ];then
cd $SCRIPTS
./test_mpf_cov.sh $TEST_AFU_DIR
else
lcov --zerocounters --directory .
lcov --capture --initial --directory . --output-file coverage_new

./test_bb
rm -rf coverage_new.info
lcov -capture --directory ./ase/api/CMakeFiles/fpga-ASE.dir/ -o coverage_new.info
#genhtml ${TEST_AFU_DIR}.info --output-directory coverage 
fi
fi
