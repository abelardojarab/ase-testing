#!/bin/sh

fpgadiag_vc_arr="--va --vl0 --vh0 --vh1"
fpgadiag_mcl_arr="1 2 4"
fpgadiag_cnt_arr="64 1024 8192"
fpgadiag_rdtype_arr="--rds --rdi"
fpgadiag_wrtype_arr="--wt --wb"

# echo "##################################"
# echo "# Testing Peek-poke stress tests #"
# echo "##################################"
# cd $ASEVAL_GIT/apps/
# ./stress.sh 25 short
# ./stress.sh 10 long

echo "##################################"
echo "#     Testing Hello_ALI_NLB      #"
echo "##################################"
cd $AALSAMP_DIR/Hello_ALI_NLB/SW/
timeout 10 ./helloALInlb
if [[ $? != 0 ]]; 
then
    "helloALInlb timed out -- FAILURE EXIT !!"
    exit 1
fi

echo "##################################"
echo "#        Testing fpgadiag        #"
echo "##################################"
cd $MYINST_DIR/bin
for vc_set in $fpgadiag_vc_arr ; do
    for mcl_set in $fpgadiag_mcl_arr ; do
	for cnt_set in $fpgadiag_cnt_arr ; do
	    for rd_set in $fpgadiag_rdtype_arr ; do
		for wr_set in $fpgadiag_wrtype_arr ; do
		    date
		    echo "./fpgadiag --target=ase --mode=lpbk1 --begin=$cnt_set $rd_set $wr_set --mcl=$mcl_set $vc_set"
		    timeout 1800 ./fpgadiag --target=ase --mode=lpbk1 --begin=$cnt_set $rd_set $wr_set --mcl=$mcl_set $vc_set
		    if [[ $? != 0 ]] ; 
		    then
			"fpgadiag timed out -- FAILURE EXIT !!"
			exit 1
		    fi
		    sleep 1
		done
	    done
	done
    done
done

