#!/bin/sh

test_select=$1

if [[ $test_select == "" ]]
then
    test_select="all"
fi

source $ASEVAL_GIT/test_afus/ccip_nlb_all/SW/fpgadiag_include.sh

LOGNAME="$PWD/results_fpgadiag_3.log"

# Delete log if exists
rm -rf $LOGNAME

# Wait for simulator ready
# $ASEVAL_GIT/wait_till_ase_ready.sh

# Simulator PID
ase_pid=`cat $ASE_WORKDIR/.ase_ready.pid | grep pid | cut -d "=" -s -f2-`

# Return code
retcode=0

## Listing options
fpgadiag_mode="trput read write"

## Run options
cd $MYINST_DIR/bin
for nlb_mode in $fpgadiag_mode ; do
    ## ----------------------------------------------- ##
    mode_str="--mode=trput --timeout-sec=3 --cont"
    timeout_val=10
    fpgadiag_cnt_arr="1024 4096 32768 64000"
    ## ----------------------------------------------- ##
    for rdvc_set in $fpgadiag_rdvc_arr ; do
	for wrvc_set in $fpgadiag_wrvc_arr ; do
	    for mcl_set in $fpgadiag_mcl_arr ; do
		for cnt_set in $fpgadiag_cnt_arr ; do
		    for rd_set in $fpgadiag_rdtype_arr ; do
			for wr_set in $fpgadiag_wrtype_arr ; do
			    # if ps -p $ase_pid > /dev/null
			    # then
				## Test select
				if [[ $test_select == "random" ]]
				then
				    random_out=`shuf -i 1-25 -n 1`
				elif [[ $test_select == "all" ]]
				then
				    random_out=1
				fi
				## WrFence setting
				wrfvc_set=$wrvc_set
				if [[ $wrfvc_set == "random" ]]
				then
				    wrfvc_set="auto"
				fi
				## Run test
				if [[ $random_out == 1 ]]
				then
				    ## Run test
				    stride=`shuf -i 1-25 -n 1`
				    cmd="/usr/bin/timeout $timeout_val ./fpgadiag --target=ase $mode_str --begin=$cnt_set --cache-hint=$rd_set --cache-policy=$wr_set --multi-cl=$mcl_set --read-vc=$rdvc_set --write-vc=$wrvc_set --strided-access=$stride --wrfence-vc=$wrfvc_set"
				    echo $cmd
				    # eval $cmd | tee output.log
				    # errcode=$?
				    # simtime=`grep -i nsec output.log`
				    # if [[ $errcode != 0 ]] 
				    # then
				    # 	echo -e " [** FAIL **]  $simtime  $cmd " >> $LOGNAME
				    # 	exit 1
				    # 	retcode=1
				    # else
				    # 	echo -e " [PASS]        $simtime  $cmd " >> $LOGNAME
				    # fi
				fi				
			    # else
			    # 	echo "** Simulator not running **"
			    # 	exit 1
			    # fi
			done
		    done
		done
	    done
	done
    done
done

## Return status
# if [ $retcode == "0" ]
# then
#     echo "fpgadiag_scrub completed -- SUCCESS"
# else
#     echo "fpgadiag_scrub completed -- FAILED"
#     exit 1
# fi
