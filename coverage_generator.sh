#!/bin/sh

## Build AALSDK
# $ASEVAL_GIT/aalsdk_build.sh

## Include
# source $ASEVAL_GIT/test_afus/ccip_nlb_all/SW/fpgadiag_include.sh

ASE_COV=$ASE_SRCDIR/coverage/

## Clean up
rm -rf $ASE_COV/*

## Copy over the Makefile
cp $ASEVAL_GIT/Makefile.internal $ASE_SRCDIR/Makefile

#######################################
##                                   ##
##          NLB-fpgadiag test        ##
##                                   ##
#######################################
## Config set up
cp $ASEVAL_GIT/test_afus/ccip_nlb_all/config/SKX1/* $ASE_SRCDIR/
cp $ASEVAL_GIT/synopsys_sim.setup                   $ASE_SRCDIR/
cp $ASEVAL_GIT/sim_tcl/vcs_nodumpwave.tcl           $ASE_SRCDIR/vcs_run.tcl
$ASEVAL_GIT/config_generator.sh single 2343 silent 250.00 32 > $ASE_SRCDIR/ase.cfg

## Build with coverage metrics
cd $ASE_SRCDIR/
make clean
make ASE_COVERAGE=1 ASE_DEBUG=0

## Listing options
# fpgadiag_mode_arr="lpbk1 read write trput"
# fpgadiag_rdvc_arr="auto vl0 vh0 vh1 random"
# fpgadiag_wrvc_arr="auto vl0 vh0 vh1 random"
fpgadiag_mode_arr="lpbk1"
fpgadiag_rdvc_arr="auto"
fpgadiag_wrvc_arr="auto"
fpgadiag_mcl_arr="1 2 4"
fpgadiag_rdtype_arr="rdline-I"
# fpgadiag_wrtype_arr="wrline-I wrline-M wrpush-I"
fpgadiag_wrtype_arr="wrline-M"
cd $MYINST_DIR/bin
for mode_sel in $fpgadiag_mode_arr ; do
    ## Mode global
    if [ $mode_sel == "lpbk1" ] ;
    then
	linux_timeout=600
	fpgadiag_cmd="--mode=$mode_sel"
	# fpgadiag_cnt_arr="64 1024 8192"
	fpgadiag_cnt_arr="1024"
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

			    ## Prepare command
			    cmd="/usr/bin/timeout $linux_timeout ./fpgadiag --target=ase $mode_str --begin=$cnt_set --cache-hint=$rd_set --cache-policy=$wr_set --multi-cl=$mcl_set --read-vc=$rdvc_set --write-vc=$wrvc_set"
			    ## Testname
			    testname="f_${mode_sel}_${cnt_set}_${rd_set}_${wr_set}_${mcl_set}_${rdvc_set}_${wrvc_set}"
			    echo "-----------------------------------------------------------------"
			    echo $testname
			    echo "-----------------------------------------------------------------"
			    ## Start simulator with coverage running
			    cd $ASE_WORKDIR/
			    ./ase_simv -ucli -do $ASE_SRCDIR/vcs_run.tcl +CONFIG=$ASE_SRCDIR/ase.cfg -cm line+cond+fsm+branch+tgl -cm_name $testname &
			    ## Wait until ready
			    $ASEVAL_GIT/wait_till_ase_ready.sh
			    # Run fpgadiag
			    cd $MYINST_DIR/bin/
    			    eval $cmd
			    # $ASEVAL_GIT/kill_running_ase.sh
			    ## Wait until Ready file is gone
			    while [ -f $ASE_WORKDIR/.ase_ready.pid ]
			    do
				sleep 1
			    done
			    sleep 3
    			done
    		    done
    		done
    	    done
    	done
    done
done


#######################################
##                                   ##
##          MMIO Stress Test         ##
##                                   ##
#######################################
cd $ASE_SRCDIR/
$ASEVAL_GIT/create_bbb_afu_files.sh ccip_mmio_rdwr_stress
# make clean
make ASE_COVERAGE=1 ASE_DEBUG=0
cmd="./mmio_stress"
testname="mmio_stress_test"
echo "-----------------------------------------------------------------"
echo $testname
echo "-----------------------------------------------------------------"
cd $ASE_WORKDIR/
./ase_simv -ucli -do $ASE_SRCDIR/vcs_run.tcl +CONFIG=$ASE_SRCDIR/ase.cfg -cm line+cond+fsm+branch+tgl -cm_name $testname &> /dev/null &
## Wait until ready
$ASEVAL_GIT/wait_till_ase_ready.sh
## Run mmio_stress test
cd $ASEVAL_GIT/test_afus/ccip_mmio_rdwr_stress/SW/
eval $cmd
## Wait until Ready file is gone
while [ -f $ASE_WORKDIR/.ase_ready.pid ]
do
    sleep 1
done
sleep 3


#######################################
##                                   ##
##     Coverage report generation    ##
##                                   ##
#######################################
cd $ASE_SRCDIR/coverage/
lcov --base-directory . --directory $ASE_WORKDIR --capture --output-file sim_coverage.info
genhtml sim_coverage.info --output-directory sim_coverage

## Convert cov_db to reports
urg -full64 -dir ase_simv.vdb -show tests -format both
