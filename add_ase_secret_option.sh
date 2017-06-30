#!/bin/sh

## Run instructions
## ./add_ase_secret_option.sh [cov] [prof]

CURRDIR=${PWD}

COV_DIR=${ASE_SRCDIR}/coverage/

COV_TYPES="line+cond+branch+fsm+tgl"

VALGRIND_OPT="--tool=memcheck -v --log-file=valgrind.log --error-limit=no  --track-fds=yes --trace-children=yes  --leak-check=full --track-origins=yes  --show-reachable=yes  --show-leak-kinds=definite,possible --undef-value-errors=yes"

set -ve

if [ -z "$FPGASW_GIT" ]; then
    echo "env(FPGASW_GIT) has not been set !"
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

arg_list="$*"

cov=0
prof=0

if [[ $arg_list == *"cov"* ]];
then
    cov=1
fi

if [[ $arg_list == *"prof"* ]];
then
    prof=1
fi

echo "Profile option  = $prof"
echo "Coverage option = $cov"

## Open ASE workdir
cd $ASE_SRCDIR
if [ -e $ASE_SRCDIR/ase_sources.mk ];
then
    ## Profile options
    if [ $prof -eq 1 ];
    then
	echo "Adding Profiler options"
	echo "## Adding Profiler options" >> $ASE_SRCDIR/ase_sources.mk
	echo "SNPS_VLOGAN_OPT+= +define+ASE_PROFILE=1" >> $ASE_SRCDIR/ase_sources.mk
	echo "SNPS_VCS_OPT+= +vcs+loopreport +vcs+loopdetect -simprofile" >> $ASE_SRCDIR/ase_sources.mk
	echo "SNPS_SIM_OPT+= -simprofile time" >> $ASE_SRCDIR/ase_sources.mk
	## Add Valgrind options in Makefile	
 	echo "VALGRIND_OPT = ${VALGRIND_OPT}" >> $ASE_SRCDIR/ase_sources.mk
	echo -e "\n" >> $ASE_SRCDIR/Makefile
	cat $ASEVAL_GIT/snippets/valgrind_run.make >> $ASE_SRCDIR/Makefile
    fi
    ## Coverage options
    if [ $cov -eq 1 ];
    then
	echo "Add Coverage options"
	echo "## Add Coverage options" >> $ASE_SRCDIR/ase_sources.mk
	echo "COV_DIR = ${COV_DIR}" >> $ASE_SRCDIR/ase_sources.mk
	echo "CC_OPT+= -fprofile-arcs -ftest-coverage" >> $ASE_SRCDIR/ase_sources.mk
	echo "ASE_LD_SWITCHES+= -lgcov" >> $ASE_SRCDIR/ase_sources.mk
	echo "SNPS_VCS_OPT+= -cm_dir ${COV_DIR}/ase_simv -cm_name ase_cov -cm ${COV_TYPES} -cm_tgl mda -cm_hier ${ASEVAL_GIT}/ase_coverage.cfg" >> $ASE_SRCDIR/ase_sources.mk
	echo "SNPS_SIM_OPT+= -cm ${COV_TYPES}" >> $ASE_SRCDIR/ase_sources.mk
    fi
else
    echo "ase_sources.mk doesnt exist in $ASE_SRCDIR"
    echo "Script will exit now "
    exit 1
fi

# Go back to calling directory
cd $CURRDIR
