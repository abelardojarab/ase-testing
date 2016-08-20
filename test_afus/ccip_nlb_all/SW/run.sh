#!/bin/sh

# Wait for readiness
# echo "##################################"
# echo "#     Waiting for .ase_ready     #"
# echo "##################################"
# while [ ! -f $ASE_WORKDIR/.ase_ready.pid ]
# do
#     sleep 1
# done

# Wait for simulator ready
$ASEVAL_GIT/wait_till_ase_ready.sh

# Simulator PID
ase_pid=`cat $ASE_WORKDIR/.ase_ready.pid | grep pid | cut -d "=" -s -f2-`

## Ensure Hello_ALI_NLB works in the release
echo "##################################"
echo "#     Testing Hello_ALI_NLB      #"
echo "##################################"
cd $AALSAMP_DIR/Hello_ALI_NLB/SW/
/usr/bin/timeout 10 ./helloALInlb
if [[ $? != 0 ]]; 
then
    "helloALInlb timed out -- FAILURE EXIT !!"
    exit 1
fi

#######################################################################
## For BDX2 release
if [ $RELCODE == "BDX2" ]
then
    echo "######################################################"
    echo "#        Testing fpgadiag on $RELCODE                 "
    echo "######################################################"
    ## Listing options
    fpgadiag_mode_arr="lpbk1 read write trput"
    fpgadiag_vc_arr="--va --vl0 --vh0 --vh1"
    fpgadiag_mcl_arr="1 2 4"
    fpgadiag_rdtype_arr="--rds --rdi"
    fpgadiag_wrtype_arr="--wt --wb"
    ## Run tests
    cd $MYINST_DIR/bin
    for mode_sel in $fpgadiag_mode_arr ; do
	## Mode global
	if [ $mode_sel == "lpbk1" ] ; 
	then
	    linux_timeout=600
	    fpgadiag_cmd="--mode=$mode_sel"
	    fpgadiag_cnt_arr="64 1024 8192"
	else
	    linux_timeout=10
	    fpgadiag_cmd="--mode=$mode_sel --timeout-sec=5 --cont"
	    fpgadiag_cnt_arr="1024"
	fi
	## Iterate options	    
	for vc_set in $fpgadiag_vc_arr ; do
    	    for mcl_set in $fpgadiag_mcl_arr ; do
    		for cnt_set in $fpgadiag_cnt_arr ; do
    		    for rd_set in $fpgadiag_rdtype_arr ; do
    			for wr_set in $fpgadiag_wrtype_arr ; do
    			    date
    			    if ps -p $ase_pid > /dev/null
    			    then
    				cmd="/usr/bin/timeout $linux_timeout ./fpgadiag --target=ase $fpgadiag_cmd --begin=$cnt_set $rd_set $wr_set --mcl=$mcl_set $vc_set"
    				echo "Run: " $cmd
    				eval $cmd
    				errcode=$?
    				if [[ $errcode != 0 ]] 
    				then
    				    echo "fpgadiag timed out -- FAILURE EXIT, Error code $errcode !!"
    				    echo "Last command: " $cmd
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
fi


#######################################################################
## For SKX1 release
if [ $RELCODE == "SKX1" ]
then
    echo "#######################################"
    echo "#        Testing fpgadiag lpbk1       #"
    echo "#######################################"
    ## Listing options
    fpgadiag_mode_arr="lpbk1 read write trput"
    fpgadiag_rdvc_arr="--rva --rvl0 --rvh0 --rvh1 --rvr"
    fpgadiag_wrvc_arr="--wva --wvl0 --wvh0 --wvh1 --wvr"
    fpgadiag_mcl_arr="1 2 4"
    fpgadiag_rdtype_arr="--rds --rdi"
    fpgadiag_wrtype_arr="--wlm --wli --wpi"
    cd $MYINST_DIR/bin
    for mode_sel in $fpgadiag_mode_arr ; do
	## Mode global
	if [ $mode_sel == "lpbk1" ] ; 
	then
	    linux_timeout=600
	    fpgadiag_cmd="--mode=$mode_sel"
	    fpgadiag_cnt_arr="64 1024 8192"
	else
	    linux_timeout=10
	    fpgadiag_cmd="--mode=$mode_sel --timeout-sec=5 --cont"
	    fpgadiag_cnt_arr="1024"
	fi
	## Iterate options	    
	for rdvc_set in $fpgadiag_rdvc_arr ; do
    	    for wrvc_set in $fpgadiag_wrvc_arr ; do
    		for mcl_set in $fpgadiag_mcl_arr ; do
    		    for cnt_set in $fpgadiag_cnt_arr ; do
    			for rd_set in $fpgadiag_rdtype_arr ; do
    			    for wr_set in $fpgadiag_wrtype_arr ; do
    				date
    				if ps -p $ase_pid > /dev/null
    				then
    				    cmd="/usr/bin/timeout 600 ./fpgadiag --target=ase $fpgadiag_cmd --begin=$cnt_set $rd_set $wr_set --mcl=$mcl_set $rdvc_set $wrvc_set"
    				    echo "Run: " $cmd
    				    eval $cmd
    				    errcode=$?
    				    if [[ $errcode != 0 ]]
    				    then
    					echo "fpgadiag timed out -- FAILURE EXIT, Error code $errcode !!"
    					echo "Last command: " $cmd
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
    done

fi

