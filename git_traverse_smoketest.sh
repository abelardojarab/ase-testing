#!/bin/sh

# Go to ASE_SRCDIR directory
cd $ASE_SRCDIR

revlist=`git rev-list $1`
revlist=`echo $revlist | awk '{ for (i=NF; i>1; i--) printf("%s ",$i); print $1; }'`
echo $revlist

logname=$ASEVAL_GIT/git_traverse_status.txt

# Copy ccip_nlb_mode0 config
cp $ASEVAL_GIT/test_afus/ccip_nlb_mode0/config/SKX1/* $ASE_SRCDIR/
cp $ASEVAL_GIT/sim_tcl/vcs_nodumpwave.tcl             $ASE_SRCDIR/vcs_run.tcl
cp $ASEVAL_GIT/synopsys_sim.setup                     $ASE_SRCDIR/

# Config generator
$ASEVAL_GIT/config_generator.sh single 1234 silent 300.0 32 > $ASE_SRCDIR/ase.cfg

# Empty out log
echo "" > $logname

for gitrev in $revlist
do
    cd $ASE_SRCDIR/
    ## Write log
    echo $gitrev >> $logname
    echo "-------------------------------------------------------"
    echo "Commit: $gitrev  "
    echo "-------------------------------------------------------"
    git checkout $gitrev
    $ASEVAL_GIT/sw_build_all.sh lib_only
    echo "Running Simulator..."
    make all sim ASE_PLATFORM=ASE_PLATFORM_MCP_SKYLAKE &
    $ASEVAL_GIT/wait_till_ase_ready.sh
    echo "Running application..."
    cd $FPGASW_GIT/mybuild/bin/
    /usr/bin/timeout 600 ./hello_fpga-ASE
    if [ $? -eq 0 ]; then
	echo -e "\t [PASS]" >> $logname
    else
	echo -e "\t [** FAIL **]" >> $logname
    fi
done

