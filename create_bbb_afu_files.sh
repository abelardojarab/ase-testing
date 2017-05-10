#!/bin/sh

afu=$1

if [ $afu == "ccip_umsg_trigger" ];
then
    afu="ccip_nlb_mode0"
fi

## BBB VLOG and DIR
mpf_v_list=$BBB_GIT/BBB_cci_mpf/hw/sim/cci_mpf_sim_addenda.txt
async_v_list=$BBB_GIT/BBB_ccip_async/hw/sim/ccip_async_sim_addenda.txt
mux_v_list=$BBB_GIT/BBB_ccip_mux/hw/sim/mux_simfiles.list
iom_v_list=$BBB_GIT/BBB_iom/hw/rtl/iom_sim_filelist.txt
iombuf_samp_v_list=$BBB_GIT/BBB_iom/sample/hw/sample_acce_buffer_intf_filelist.txt
iomfifo_samp_v_list=$BBB_GIT/BBB_iom/sample/hw/sample_acce_fifo_intf_filelist.txt

mpf_rtldir=$(dirname $mpf_v_list)"/"
async_rtldir=$(dirname $async_v_list)"/"
mux_rtldir=$(dirname $mux_v_list)"/"
iom_rtldir=$BBB_GIT/BBB_iom/

## Base directory
mpf_basedir=$BBB_GIT/BBB_cci_mpf/
async_basedir=$BBB_GIT/BBB_ccip_async/
nlb_basedir=$ASEVAL_GIT/test_afus/ccip_nlb_all_${RELCODE}/HW/
mmio_basedir=$ASEVAL_GIT/test_afus/ccip_mmio_rdwr_stress/HW/
testrandom_basedir="$BBB_GIT/BBB_cci_mpf/test/test-mpf/base/ $BBB_GIT/BBB_cci_mpf/test/test-mpf/test_random/"
mux_basedir="${mux_rtldir} $BBB_GIT/BBB_ccip_mux/sample/hw/"
iom_sampledir="${iom_rtldir}/sample/hw/ ${iom_rtldir}/sample/hw/iom_stream/"

## AFU paths
ccip_async_nlb100_all="$BBB_GIT/BBB_ccip_async/samples/async_nlb100.sv"
ccip_async_nlb300_all="$BBB_GIT/BBB_ccip_async/samples/async_nlb300.sv"
ccip_mpf_nlb_all="$BBB_GIT/BBB_cci_mpf/sample/afu/ccip_mpf_nlb.sv"
ccip_async_mpf_nlb_all="$BBB_GIT/BBB_cci_mpf/sample/afu/ccip_slow_mpf_nlb.sv"
ccip_mpf_test_random="$BBB_GIT/BBB_cci_mpf/test/test-mpf/base/hw/rtl/cci_test_afu.sv\n$BBB_GIT/BBB_cci_mpf/test/test-mpf/base/hw/rtl/cci_test_csrs.sv\n$BBB_GIT/BBB_cci_mpf/test/test-mpf/test_random/hw/rtl/test_random.sv"
ccip_async_mux_muxsample=`find $BBB_GIT/BBB_ccip_mux/sample/hw/ -name \*.sv -or -name \*.v`

## Directory listing
dir_list=""

async_found=0
mpf_found=0
nlb_found=0
mmio_stress=0
test_random=0
mux_found=0
iom_found=0
iomfifo_found=0
iombuf_found=0

## Generate Temp file sets
awk -v basedir=${async_rtldir} '/^[^#]/ {print basedir $0}' $async_v_list > $ASEVAL_GIT/async_vlog_files.list
awk -v basedir=${mpf_rtldir}   '/^[^#]/ {print basedir $0}' $mpf_v_list | grep -v "+" |grep -v ccip_if_pkg > $ASEVAL_GIT/mpf_vlog_files.list
awk -v basedir=${mux_rtldir}   '/^[^#]/ {print basedir $0}' $mux_v_list | grep -v "+" |grep -v ccip_if_pkg > $ASEVAL_GIT/mux_vlog_files.list
awk -v basedir=${iom_rtldir}   '/^[^#]/ {print basedir $0}' $iom_v_list | grep -v "+" |grep -v ccip_if_pkg > $ASEVAL_GIT/iom_vlog_files.list
awk -v basedir=${iom_rtldir}   '/^[^#]/ {print basedir $0}' $iombuf_samp_v_list | grep -v "+" | grep -v " " |grep -v ccip_if_pkg > $ASEVAL_GIT/iombuf_samp_vlog_files.list
awk -v basedir=${iom_rtldir}   '/^[^#]/ {print basedir $0}' $iomfifo_samp_v_list | grep -v "+" | grep -v " "  |grep -v ccip_if_pkg > $ASEVAL_GIT/iomfifo_samp_vlog_files.list

## Generate DIR list
if echo $afu | grep -q "async"
then
    dir_list=$dir_list" "$async_basedir
    async_found=1
    echo "Async found"
fi

if echo $afu | grep -q "mpf"
then
    echo "MPF found"
    mpf_found=1
    dir_list=$dir_list" "$mpf_basedir
fi

if echo $afu | grep -q "mux"
then
    echo "MUX found"
    mux_found=1
    dir_list=$dir_list" "$mux_basedir
fi

if echo $afu | grep -Eq 'nlb'
then
    echo "NLB found"
    nlb_found=1
    dir_list=$dir_list" "$nlb_basedir
fi

if echo $afu | grep -q "iom"
then
    echo "IOM found"
    iom_found=1
    dir_list=$dir_list" "$iom_rtldir" "$iom_sampledir
fi

if echo $afu | grep -q "_iom"
then
    echo "IOM found"
    iom_found=1
    dir_list=$dir_list" "$iom_rtldir
fi


if echo $afu | grep -q "ccip_mmio_rdwr_stress"
then
    echo "MMIO stress AFU found"
    mmio_stress=1
    dir_list=$dir_list" "$mmio_basedir
fi

if echo $afu | grep -q "ccip_mpf_test_random"
then
    echo "MPF Test Random AFU found"
    test_random=1
    dir_list=$dir_list" "$testrandom_basedir
fi


#########################################################
echo $dir_list

cd $ASE_SRCDIR
./scripts/generate_ase_environment.py $dir_list
cp vlog_files.list vlog_files.list.BAK

## Redo vlog_files.list
echo "" > $ASE_SRCDIR/vlog_files.list

if [[ $async_found -eq 1 ]]
then
    cat $ASEVAL_GIT/async_vlog_files.list >> $ASE_SRCDIR/vlog_files.list
fi

if [[ $mpf_found -eq 1 ]]
then
    cat $ASEVAL_GIT/mpf_vlog_files.list >> $ASE_SRCDIR/vlog_files.list
    cp $ASEVAL_GIT/test_afus/ccip_mpf_nlb_all/config/${RELCODE}/nlb_csr.sv $ASEVAL_GIT/test_afus/ccip_nlb_all_${RELCODE}/HW/nlb_csr.sv
fi

if [[ $mux_found -eq 1 ]]
then
    cat $ASEVAL_GIT/mux_vlog_files.list >> $ASE_SRCDIR/vlog_files.list
    cp  $BBB_GIT/BBB_ccip_mux/sample/hw/nlb_csr.sv $ASEVAL_GIT/test_afus/ccip_nlb_all_${RELCODE}/HW/nlb_csr.sv
    sed -i '$ a '$BBB_GIT'/BBB_ccip_mux/sample/hw/ccip_std_afu.sv' $ASE_SRCDIR/vlog_files.list
fi

if [[ $nlb_found -eq 1 ]]
then
    cat $ASEVAL_GIT/test_afus/ccip_nlb_all/config/${RELCODE}/vlog_files.list | grep -v "ccip_std_afu\.sv" >> $ASE_SRCDIR/vlog_files.list
    sed -i 's/BDX2/SKX1/g' $ASE_SRCDIR/vlog_files.list
fi

if [[ $iom_found -eq 1 ]]
then
    cat $ASEVAL_GIT/iom_vlog_files.list >>  $ASE_SRCDIR/vlog_files.list
fi

## Wrapper AFU
if [[ $afu == "ccip_async_nlb100_all" ]]
then
    echo -e "\n$ccip_async_nlb100_all\n" >> $ASE_SRCDIR/vlog_files.list
elif [[ $afu == "ccip_async_nlb300_all" ]]
then
    echo -e "\n$ccip_async_nlb300_all\n" >> $ASE_SRCDIR/vlog_files.list
elif [[ $afu == "ccip_mpf_nlb_all" ]]
then
    echo -e "\n$ccip_mpf_nlb_all\n" >> $ASE_SRCDIR/vlog_files.list
elif [[ $afu == "ccip_async_mpf_nlb_all" ]]
then
    echo -e "\n$ccip_async_mpf_nlb_all\n" >> $ASE_SRCDIR/vlog_files.list
elif [[ $afu == "ccip_mpf_test_random" ]]
then
    echo "Creating MPF test_random AFU"
    echo -e "\n$ccip_mpf_test_random\n" >> $ASE_SRCDIR/vlog_files.list
elif [[ $afu == "ccip_async_mux_4nlb" ]]
then
    echo "Create MUX test configuration"
    echo -e "\n$ccip_async_mux_4nlb\n" >> $ASE_SRCDIR/vlog_files.list
elif [[ $afu == "ccip_mmio_rdwr_stress" ]]
then
    echo "MMIO Stress AFU should be available"
    mv $ASE_SRCDIR/vlog_files.list.BAK $ASE_SRCDIR/vlog_files.list
elif [[ $afu == "ccip_async_mpf_iom_iombuf_samp" ]]
then
    echo "IOM buffer example"
    cat  $ASEVAL_GIT/iombuf_samp_vlog_files.list >>  $ASE_SRCDIR/vlog_files.list
elif [[ $afu == "ccip_async_mpf_iom_iomfifo_samp" ]]
then
    echo "IOM FIFO example"
    cat  $ASEVAL_GIT/iomfifo_samp_vlog_files.list >>  $ASE_SRCDIR/vlog_files.list
elif [[ $afu == "ccip_nlb_mode0" ]]
then
    echo "NLB Mode0 AFU"
    cp $ASEVAL_GIT/test_afus/ccip_nlb_mode0/config/$RELCODE/* $ASE_SRCDIR/
else
    echo "Requested AFU was not found, this may not work !"
    exit 1
fi

## Print out ase_sources.mk & vlog_files.list
echo "-------------------------------------------------"
cat $ASE_SRCDIR/vlog_files.list
echo "-------------------------------------------------"
cat $ASE_SRCDIR/ase_sources.mk
echo "-------------------------------------------------"
