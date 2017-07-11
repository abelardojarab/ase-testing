#!/bin/bash

set -v
set -e

if [ -z "$AALSDK_GIT" ]; then
    echo "env(AALSDK_GIT) has not been set !"
    exit 1
fi

if [ -z "$BBB_GIT" ]; then
    echo "env(BBB_GIT) has not been set !"
    exit 1
fi

if [ -z "$ASEVAL_GIT" ]; then
    echo "env(ASEVAL_GIT) has not been set !"
    exit 1
fi

PERF_REPORT=$ASEVAL_GIT/ase_performance.rpt
RELCODE=BDX2

rm -rf $PERF_REPORT
touch $PERF_REPORT

#############################################
#               Start regression            #
#############################################
CURRDIR=$PWD

ASE_SRCDIR=$AALUSER_DIR/ase/
ASE_WORKDIR=$ASE_SRCDIR/work/

AFU_CONFIG=$ASEVAL_GIT/test_afus/ccip_nlb_all/config/

## Recompile AALSDK specifics
ASE_DEBUG="0 1"

## Runtime setting
VCS_RUN_TCL=" $ASEVAL_GIT/sim_tcl/vcs_nodumpwave.tcl $ASEVAL_GIT/sim_tcl/vcs_dumpwave.tcl"

## Config setting
ASE_CFG_FILE="$ASEVAL_GIT/ase_configs/ase_sw_simkill_cl_view_0.cfg $ASEVAL_GIT/ase_configs/ase_sw_simkill_cl_view_1.cfg"

## Test configs
numcl_array="64000"
vc_array="0 1 2 3"
mcl_array="0 1 3"

## Build NLB test
cd $ASEVAL_GIT/apps/
./build_all.sh $ASE_SRCDIR/
cd $CURRDIR

## Copy AFU configuration
cp $ASEVAL_GIT/test_afus/ccip_nlb_all/$RELCODE/* $ASE_SRCDIR/

## --------------------------------------------- ##
for asedbg in $ASE_DEBUG
do
    ## --------------------------------------------- ##
    cd $ASE_SRCDIR/
    cp $AFU_CONFIG/* .
    make ASE_DEBUG=$asedbg
    cd $CURRDIR
    ## --------------------------------------------- ##
    for simtcl in $VCS_RUN_TCL
    do
	if grep dump $simtcl > /dev/null
	then
	    wavedump=1
	else
	    wavedump=0
	fi
	## --------------------------------------------- ##
	for cfg in $ASE_CFG_FILE
	do
	    ## --------------------------------------------- ##
	    enable_cl_view=`grep ENABLE_CL_VIEW $cfg`
	    ## --------------------------------------------- ##
	    for numcl_set in $numcl_array ; do
		for vc_set in $vc_array ; do
		    for mcl_set in $mcl_array ; do
			cp $cfg $ASE_SRCDIR/ase.cfg
			xterm -e "cd $ASE_WORKDIR/ ; make sim " &
			while [ ! -f $ASE_WORKDIR/.ase_ready.pid ]
			do
			    sleep 1
			done
			cd $ASEVAL_GIT/apps/
			ASE_WORKDIR=$ASE_WORKDIR ./nlb_test.out $numcl_set $vc_set $mcl_set > output.log
			simtime=`grep -i nsec output.log`
			echo -e "ASE_DEBUG=$asedbg \tWAVEDUMP=$wavedump \t$enable_cl_view \t./nlb_test $numcl_set $vc_set $mcl_set \t $simtime" >> $PERF_REPORT
			sleep 1
			$ASEVAL_GIT/kill_running_ase.sh
		    done
		done
	    done
	done
    done
done
