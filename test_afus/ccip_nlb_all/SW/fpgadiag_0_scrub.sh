#!/bin/sh

source $ASEVAL_GIT/test_afus/ccip_nlb_all/SW/fpgadiag_include.sh

LOGNAME="$PWD/test_status.log"

# Delete log if exists
rm -rf $LOGNAME

# Wait for simulator ready
$ASEVAL_GIT/wait_till_ase_ready.sh

# Simulator PID
ase_pid=`cat $ASE_WORKDIR/.ase_ready.pid | grep pid | cut -d "=" -s -f2-`

# Return code
retcode=0

## Listing options
fpgadiag_mode="lpbk1"
# fpgadiag_rdvc_arr="--rva --rvl0 --rvh0 --rvh1 --rvr"
# fpgadiag_wrvc_arr="--wva --wvl0 --wvh0 --wvh1 --wvr"
# fpgadiag_mcl_arr="1 2 4"
# fpgadiag_rdtype_arr="--rds --rdi"
# fpgadiag_wrtype_arr="--wt --wb"
## Run options
cd $MYINST_DIR/bin
for nlb_mode in $fpgadiag_mode ; do
    ## ----------------------------------------------- ##
    mode_str="--mode=lpbk1"
    timeout_val=600
    fpgadiag_cnt_arr="32768"
    ## ----------------------------------------------- ##
    for rdvc_set in $fpgadiag_rdvc_arr ; do
	for wrvc_set in $fpgadiag_wrvc_arr ; do
	    for mcl_set in $fpgadiag_mcl_arr ; do
		for cnt_set in $fpgadiag_cnt_arr ; do
		    for rd_set in $fpgadiag_rdtype_arr ; do
			for wr_set in $fpgadiag_wrtype_arr ; do
			    date
			    if ps -p $ase_pid > /dev/null
			    then
				random_out=`shuf -i 1-20 -n 1`
				if [[ $random_out == 1 ]]
				then
				    cmd="/usr/bin/timeout $timeout_val ./fpgadiag --target=ase $mode_str --begin=$cnt_set $rd_set $wr_set --mcl=$mcl_set $rdvc_set $wrvc_set"
				    echo $cmd
				    eval $cmd | tee output.log
				    errcode=$?
				    simtime=`grep -i nsec output.log`
				    if [[ $errcode != 0 ]]
				    then
					echo -e " [** FAIL **]  $simtime  $cmd \n" >> $LOGNAME
					retcode=1
				    else
					echo -e " [PASS]        $simtime  $cmd \n" >> $LOGNAME
				    fi
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
done

## Return status
if [ $retcode == "0" ]
then
    echo "fpgadiag_scrub completed -- SUCCESS"
else
    echo "fpgadiag_scrub completed -- FAILED"
    exit 1
fi
