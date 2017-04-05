#!/bin/sh
SRCDIR=$PWD

ASE_SRCDIR=$SRCDIR/cpt_sys_sw-fpga-sw/ase
cd cpt_sys_sw-fpga-sw/ase
make clean
##`rm -rf ase_regression-validation
##rm -rf cpt_sys_sw-fpga-sw
##rm -rf mybuild

##cd $SRCDIR
## ASE_Regression
##git clone ssh://diptishe@git-amr-3.devtools.intel.com:29418/ase_regression-validation `

cd $SRCDIR/ase_regression-validation
./env.sh $SRCDIR
echo '************************************'
echo $ASEVAL_GIT
echo '************************************'
#AFU=$SRCDIR/ase_regression-validation/test_afus/ccip_nlb_all_SKX1/HW
AFU=$SRCDIR/ase_regression-validation/test_afus/ccip_mmio_rdwr_stress/HW
echo $AFU
##`git clone ssh://diptishe@git-amr-1.devtools.intel.com:29418/cpt_sys_sw-fpga-sw `
##cd $FPGASW_GIT
##git checkout develop


## BBB
##cd $SRCDIR
##git clone ssh://diptishe@git-amr-1.devtools.intel.com:29418/atd_fpga_app-qa_bblocks 

cd $ASE_SRCDIR
python scripts/generate_ase_environment.py $AFU
##python scripts/generate_ase_environment.py $AFU

make -j8
make sim &

###############################################################################
##################            APPLICATION  SIDE            ####################
###############################################################################

echo " #################################################"
echo " #   	 Build libfpga-ASE library             #"
echo " #################################################"
rm -rf $ASE_SRCDIR/api/mybuild
cd $ASE_SRCDIR/api
mkdir  mybuild
cd mybuild

cmake ../ -DCMAKE_BUILD_TYPE=Coverage 

make VERBOSE=1

export LD_LIBRARY_PATH=$PWD

echo "########################################"
echo "#            Building samples          #"
echo "########################################"

LIBNAME=libfpga-ASE.so
#cd $SRCDIR
## Build sample
#cd $SRCDIR
#gcc -g -o hello_fpga $SRCDIR/cpt_sys_sw-fpga-sw/fpga-api/samples/hello_fpga.c $LIBNAME -I$SRCDIR/cpt_sys_sw-fpga-sw/common/include/ -std=c99 -luuid -lgcov
gcc -g -o mmio_stress $SRCDIR/ase_regression-validation/test_afus/ccip_mmio_rdwr_stress/SW/mmio_stress.c $LIBNAME -I$SRCDIR/cpt_sys_sw-fpga-sw/common/include/ -std=c99 -luuid -lgcov
export ASE_WORKDIR=$ASE_SRCDIR/work
#cd $SRCDIR
lcov --zerocounters --directory .
lcov --capture --initial --directory . --output-file app_mmio

./mmio_stress

#if[$? -eq 0];  then

lcov --no-checksum --directory .  --capture --output-file app_mmio.info
genhtml app_mmio.info --output-directory out_mmio
#else
#	echo "FAILED EXECUTION"
#fi
