#!/bin/sh

## Listing options
fpgadiag_rdvc_arr="--rva --rvl0 --rvh0 --rvh1"
fpgadiag_wrvc_arr="--wva --wvl0 --wvh0 --wvh1"
fpgadiag_mcl_arr="1 2 4"
fpgadiag_cnt_arr="256"
fpgadiag_rdtype_arr="--rds --rdi"
fpgadiag_wrtype_arr="--wt --wb"
## Run options
cd $MYINST_DIR/bin
for rdvc_set in $fpgadiag_rdvc_arr ; do
    for wrvc_set in $fpgadiag_wrvc_arr ; do
	for mcl_set in $fpgadiag_mcl_arr ; do
	    for cnt_set in $fpgadiag_cnt_arr ; do
		for rd_set in $fpgadiag_rdtype_arr ; do
		    for wr_set in $fpgadiag_wrtype_arr ; do
			date
			if ps -p $ase_pid > /dev/null
			then
			    echo "./fpgadiag --target=ase --mode=lpbk1 --begin=$cnt_set $rd_set $wr_set --mcl=$mcl_set $rdvc_set $wrvc_set"
			    timeout 1800 ./fpgadiag --target=ase --mode=lpbk1 --begin=$cnt_set $rd_set $wr_set --mcl=$mcl_set $rdvc_set $wrvc_set
			    if [[ $? != 0 ]] ; 
			    then
				"fpgadiag timed out -- FAILURE EXIT !!"
				exit 1
			    fi
			else
			    echo "** Simulator not running **"
			    exit 1
			fi
		    done
		done
	    done
	done
    done
done
