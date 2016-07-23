#!/bin/sh

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

## Ensure Hello_ALI_NLB works in the release
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

#######################################################################
## For BDX2 release
if [ $RELCODE == "BDX2" ]
then
    # echo "#############################################"
    # echo "#           Testing with NLB Scrub          #"
    # echo "#############################################"
    # $ASEVAL_GIT/apps/
    # ./build_all.sh
    # ./nlb_scrub.sh full
    echo "######################################################"
    echo "#        Testing fpgadiag on $RELCODE with lpbk1"
    echo "######################################################"
    ## Listing options
    fpgadiag_vc_arr="--va --vl0 --vh0 --vh1"
    fpgadiag_mcl_arr="1 2 4"
    fpgadiag_cnt_arr="64 1024 8192"
    fpgadiag_rdtype_arr="--rds --rdi"
    fpgadiag_wrtype_arr="--wt --wb"
    ## Run options
    cd $MYINST_DIR/bin
    for vc_set in $fpgadiag_vc_arr ; do
    	for mcl_set in $fpgadiag_mcl_arr ; do
    	    for cnt_set in $fpgadiag_cnt_arr ; do
    		for rd_set in $fpgadiag_rdtype_arr ; do
    		    for wr_set in $fpgadiag_wrtype_arr ; do
    			date
    			if ps -p $ase_pid > /dev/null
    			then
    			    timeout 600 ./fpgadiag --target=ase --mode=lpbk1 --begin=$cnt_set $rd_set $wr_set --mcl=$mcl_set $vc_set
			    errcode=$?
    			    if [[ $errcode != 0 ]] 
    			    then
				echo "fpgadiag timed out -- FAILURE EXIT, Error code $errcode !!"
				echo "Last command:  ./fpgadiag --target=ase --mode=lpbk1 --begin=$cnt_set $rd_set $wr_set --mcl=$mcl_set $vc_set"
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

    echo "#######################################################"
    echo "#        Testing fpgadiag on $RELCODE with trput"
    echo "#######################################################"
    ## Listing options
    fpgadiag_vc_arr="--va --vl0 --vh0 --vh1"
    fpgadiag_mcl_arr="1 2 4"
    fpgadiag_cnt_arr="64 1024 8192"
    fpgadiag_rdtype_arr="--rds --rdi"
    fpgadiag_wrtype_arr="--wt --wb"
    ## Run options
    cd $MYINST_DIR/bin
    for vc_set in $fpgadiag_vc_arr ; do
    	for mcl_set in $fpgadiag_mcl_arr ; do
    	    for cnt_set in $fpgadiag_cnt_arr ; do
    		for rd_set in $fpgadiag_rdtype_arr ; do
    		    for wr_set in $fpgadiag_wrtype_arr ; do
    			date
    			if ps -p $ase_pid > /dev/null
    			then
    			    timeout 600 ./fpgadiag --target=ase --mode=trput --begin=$cnt_set $rd_set $wr_set --mcl=$mcl_set $vc_set --timeout-sec=20 --cont
			    errcode=$?
    			    if [[ $errcode != 0 ]] 
    			    then
				echo "fpgadiag timed out -- FAILURE EXIT, Error code $errcode !!"
				echo "Last command:  ./fpgadiag --target=ase --mode=trput --begin=$cnt_set $rd_set $wr_set --mcl=$mcl_set $vc_set --timeout-sec=20 --cont"
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

fi

#######################################################################
## For SKX1 release
if [ $RELCODE == "SKX1" ]
then
    echo "#######################################"
    echo "#        Testing fpgadiag lpbk1       #"
    echo "#######################################"
    ## Listing options
    fpgadiag_rdvc_arr="--rva --rvl0 --rvh0 --rvh1"
    fpgadiag_wrvc_arr="--wva --wvl0 --wvh0 --wvh1"
    fpgadiag_mcl_arr="1 2 4"
    fpgadiag_cnt_arr="64 1024 8192"
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
    				timeout 600 ./fpgadiag --target=ase --mode=lpbk1 --begin=$cnt_set $rd_set $wr_set --mcl=$mcl_set $rdvc_set $wrvc_set
    				errcode=$?
    				if [[ $errcode != 0 ]] ; 
    				then
    				    echo "fpgadiag timed out -- FAILURE EXIT, Error code $errcode !!"
    				    echo "Last command: ./fpgadiag --target=ase --mode=lpbk1 --begin=$cnt_set $rd_set $wr_set --mcl=$mcl_set $vc_set"
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

    echo "#######################################"
    echo "#        Testing fpgadiag trput       #"
    echo "#######################################"
    ## Listing options
    fpgadiag_rdvc_arr="--rva --rvl0 --rvh0 --rvh1"
    fpgadiag_wrvc_arr="--wva --wvl0 --wvh0 --wvh1"
    fpgadiag_mcl_arr="1 2 4"
    fpgadiag_cnt_arr="4096"
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
				timeout 600 ./fpgadiag --target=ase --mode=trput --begin=$cnt_set $rd_set $wr_set --mcl=$mcl_set $rdvc_set $wrvc_set --timeout-sec=20 --cont
				errcode=$?
				if [[ $errcode != 0 ]] ; 
				then
				    echo "fpgadiag timed out -- FAILURE EXIT, Error code $errcode !!"
				    echo "Last command: ./fpgadiag --target=ase --mode=trput --begin=$cnt_set $rd_set $wr_set --mcl=$mcl_set $rdvc_set $wrvc_set --timeout-sec=20 --cont"
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

