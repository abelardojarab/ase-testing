#!/bin/sh

afu=$1

## BBB VLOG and DIR
mpf_v_list=$BBB_GIT/BBB_cci_mpf/hw/par/sim_file_list.txt
async_v_list=$BBB_GIT/BBB_ccip_async/hw/sim/ccip_async_sim_addenda.txt
nlb_v_list=$ASEVAL_GIT/nlb_vlog_files.list

mpf_basedir=$BBB_GIT/BBB_cci_mpf/
async_basedir=$BBB_GIT/BBB_ccip_async/
nlb_basedir=$ASEVAL_GIT/test_afus/ccip_nlb_all_SKX1/HW/

## AFU paths
ccip_async_nlb100_all="$BBB_GIT/BBB_ccip_async/samples/async_nlb100.sv"
ccip_async_nlb300_all="$BBB_GIT/BBB_ccip_async/samples/async_nlb300.sv"
ccip_mpf_nlb_all="$BBB_GIT/BBB_cci_mpf/sample/afu/ccip_mpf_nlb.sv"
ccip_async_mpf_nlb_all="$BBB_GIT/BBB_cci_mpf/sample/afu/ccip_slow_mpf_nlb.sv"

dir_list=""
async_found=0
mpf_found=0
nlb_found=0

## Generate Temp file sets
awk '{print "$BBB_GIT/BBB_ccip_async/" $0}' $async_v_list > $ASEVAL_GIT/async_vlog_files.list
awk '{print "$BBB_GIT/BBB_cci_mpf/" $0}' $mpf_v_list | grep -v ccip_if_pkg > $ASEVAL_GIT/mpf_vlog_files.list

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

if echo $afu | grep -q "nlb"
then
    echo "NLB found"
    nlb_found=1
    dir_list=$dir_list" "$nlb_basedir
fi

echo $dir_list

cd $ASE_SRCDIR
./scripts/generate_ase_environment.py $dir_list

## Redo vlog_files.list
echo "" > $ASE_SRCDIR/vlog_files.list

if [[ $async_found -eq 1 ]] 
then
    cat $ASEVAL_GIT/async_vlog_files.list >> $ASE_SRCDIR/vlog_files.list
fi

if [[ $mpf_found -eq 1 ]] 
then
    cat $ASEVAL_GIT/mpf_vlog_files.list >> $ASE_SRCDIR/vlog_files.list
fi

if [[ $nlb_found -eq 1 ]] 
then
    cat $ASEVAL_GIT/nlb_vlog_files.list >> $ASE_SRCDIR/vlog_files.list
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
else
    echo "Requested AFU was not found, this may not work !"
    exit 1
fi
