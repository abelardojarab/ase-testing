#!/bin/bash

# Wait for readiness
echo "##################################"
echo "#     Waiting for .ase_ready     #"
echo "##################################"
while [ ! -f $ASE_WORKDIR/.ase_ready.pid ]
do
    sleep 1
done

# Simulator PID
ase_pid=`cat $ASE_WORKDIR/.ase_ready.pid | grep pid | cut -d "=" -s -f2-`

## Copy BDX/SKX version
cp $ASEVAL_GIT/test_afus/ccip_vtp_nlb_all/SW/HelloALIVTPNLB.cpp.$RELCODE $BBB_GIT/BBB_cci_mpf/sample/Hello_ALI_VTP_NLB/SW/HelloALIVTPNLB.cpp

echo "######################################"
echo "#     Compiling Hello_ALI_VTP_NLB    #"
echo "######################################"
cd $BBB_GIT/BBB_cci_mpf/sample/Hello_ALI_VTP_NLB/SW/
make clean
make prefix=$MYINST_DIR CFLAGS="-I $BBB_GIT/BBB_cci_mpf/sw/include/"

echo "######################################"
echo "#     Testing Hello_ALI_VTP_NLB      #"
echo "######################################"
cd $BBB_GIT/BBB_cci_mpf/sample/Hello_ALI_VTP_NLB/SW/
timeout 3600 ./helloALIVTPnlb
if [[ $? != 0 ]]; 
then
    "helloALIVTPnlb timed out -- FAILURE EXIT !!"
    exit 1
fi



#######################################################################
## For SKX1 release
# if [ $RELCODE == "SKX1" ]
# then
#     echo "##########################################################"
#     echo "#    Testing SKX1 NLB+MPF with fpgadiag in lpbk1 mode    #"
#     echo "##########################################################"
#     ## Listing options
#     fpgadiag_rdvc_arr="--rva --rvl0 --rvh0 --rvh1"
#     fpgadiag_wrvc_arr="--wva --wvl0 --wvh0 --wvh1"
#     fpgadiag_mcl_arr="1 2 4"
#     fpgadiag_cnt_arr="64 1024 8192"
#     fpgadiag_rdtype_arr="--rds --rdi"
#     fpgadiag_wrtype_arr="--wt --wb"
#     ## Run options
#     cd $MYINST_DIR/bin
#     for rdvc_set in $fpgadiag_rdvc_arr ; do
# 	for wrvc_set in $fpgadiag_wrvc_arr ; do
# 	    for mcl_set in $fpgadiag_mcl_arr ; do
# 		for cnt_set in $fpgadiag_cnt_arr ; do
# 		    for rd_set in $fpgadiag_rdtype_arr ; do
# 			for wr_set in $fpgadiag_wrtype_arr ; do
# 			    date
# 			    if ps -p $ase_pid > /dev/null
# 			    then
# 				echo "./fpgadiag --target=ase --mode=lpbk1 --begin=$cnt_set $rd_set $wr_set --mcl=$mcl_set $rdvc_set $wrvc_set"
# 				timeout 1800 ./fpgadiag --target=ase --mode=lpbk1 --begin=$cnt_set $rd_set $wr_set --mcl=$mcl_set $rdvc_set $wrvc_set
# 				if [[ $? != 0 ]] ; 
# 				then
# 				    "fpgadiag timed out -- FAILURE EXIT !!"
# 				    exit 1
# 				fi
# 			    else
# 				echo "** Simulator not running **"
# 				exit 1
# 			    fi
# 			done
# 		    done
# 		done
# 	    done
# 	done
#     done
# fi
