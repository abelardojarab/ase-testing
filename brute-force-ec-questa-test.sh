#!/bin/sh

set -e

SCRUB_LOG=questa-scrub.txt

export MGLS_LICENSE_FILE="1717@mentor04p.elic.intel.com"

export LM_LICENSE_FILE="1717@mentor04p.elic.intel.com":$LM_LICENSE_FILE

export LM_PROJECT="ATP-PLAT-DEV"

# /nfs/site/eda/tools/mentor/modelsim/6.1a/common/modeltech/linux_x86_64/ \



export TOOL_VERSION="
/p/eda/acd/mentor/questasim/6.6a/linux_x86_64 \
/nfs/site/eda/tools/mentor/questasim/10.0c/linux_2.6.16_x86-64/linux_x86_64/ \
/nfs/site/eda/tools/mentor/questasim/10.1a/common/linux_x86_64 \
/nfs/site/eda/tools/mentor/questasim/10.1b/common/linux_x86_64 \
/nfs/site/eda/tools/mentor/questasim/10.1c/common/linux_x86_64 \
/nfs/site/eda/tools/mentor/questasim/10.2b/linux_2.6.16_x86-64/linux_x86_64 \
/nfs/site/eda/tools/mentor/questasim/10.2c/common/linux_x86_64 \
/nfs/site/eda/tools/mentor/questasim/10.2e/linux_3.0.51_x86-64/linux_x86_64 \
/nfs/site/eda/tools/mentor/questasim/10.3c/common/linux_x86_64 \
/nfs/site/eda/tools/mentor/questasim/6.2f/common/linux_x86_64 \
/nfs/site/eda/tools/mentor/questasim/6.3c/common/linux_x86_64 \
/nfs/site/eda/tools/mentor/questasim/6.3f/common/linux_x86_64 \
/nfs/site/eda/tools/mentor/questasim/6.3g/common/linux_x86_64 \
/nfs/site/eda/tools/mentor/questasim/6.3h/common/linux_x86_64 \
/nfs/site/eda/tools/mentor/questasim/6.3i/common/linux_x86_64 \
/nfs/site/eda/tools/mentor/questasim/6.4/common/linux_x86_64 \
/nfs/site/eda/tools/mentor/questasim/6.5b/common/linux_x86_64 \
/nfs/site/eda/tools/mentor/questasim/6.6b/linux_2.6.5_x86-64/questasim/linux_x86_64 \
/nfs/site/eda/tools/mentor/questasim/6.6f/common/bin \
/nfs/site/eda/tools/mentor/modelsim/6.0b/common/modeltech/linux_x86_64/ \
/nfs/site/eda/tools/mentor/modelsim/6.0c/common/modeltech/linux_ia64/ \
/nfs/site/eda/tools/mentor/modelsim/6.0d/common/linux_x86_64 \
/nfs/site/eda/tools/mentor/modelsim/6.1b/common/modeltech/linux_x86_64 \
/nfs/site/eda/tools/mentor/modelsim/6.1d/common/linux_x86_64 \
/nfs/site/eda/tools/mentor/modelsim/6.1e/common/linux_x86_64 \
/nfs/site/eda/tools/mentor/modelsim/6.1f/common/linux_x86_64 \
/nfs/site/eda/tools/mentor/modelsim/6.1g/common/linux_x86_64 \
/nfs/site/eda/tools/mentor/modelsim/6.2/common/linux_x86_64 \
/nfs/site/eda/tools/mentor/modelsim/6.2b/common/linux_x86_64 \
/nfs/site/eda/tools/mentor/modelsim/6.2c/common/linux_x86_64 \
/nfs/site/eda/tools/mentor/modelsim/6.2d/common/linux_x86_64 \
/nfs/site/eda/tools/mentor/modelsim/6.2e/common/linux_x86_64 \
/nfs/site/eda/tools/mentor/modelsim/6.2g/common/linux_x86_64 \
/nfs/site/eda/tools/mentor/modelsim/6.2i/common/linux_x86_64 \
/nfs/site/eda/tools/mentor/modelsim/6.3/common/linux_x86_64 \
/nfs/site/eda/tools/mentor/modelsim/6.3a/common/linux_x86_64 \
/nfs/site/eda/tools/mentor/modelsim/6.3e/common/linux_x86_64 \
/nfs/site/eda/tools/mentor/modelsim/6.3g/common/linux_x86_64 \
/nfs/site/eda/tools/mentor/modelsim/6.3i/common/linux_x86_64 \
/nfs/site/eda/tools/mentor/modelsim/6.4a/common/linux_x86_64 \
/nfs/site/eda/tools/mentor/modelsim/6.6b1/common/linux_x86_64 \
/nfs/site/eda/tools/mentor/modelsim/6.6c/common/linux_x86_64 \
"

cd $ASE_SRCDIR
rm -rf $ASEVAL_GIT/$SCRUB_LOG

echo "Building Quick-scrub tests"
cd $ASEVAL_GIT/apps/
./build_all.sh

for i in $TOOL_VERSION; do
    export MTI_HOME=$i/../
    export PATH=$i:$PATH
    echo "------------------------------------------------------------------"
    echo "Now running : $MTI_HOME "
    echo "------------------------------------------------------------------"
    find $MTI_HOME -name svdpi.h
    echo -e -n "$MTI_HOME" >> $ASEVAL_GIT/$SCRUB_LOG
    cd $ASE_SRCDIR
    rm -rf compile.log
    make clean 
    make SIMULATOR=QUESTA | tee compile.log
    if [ -d $ASE_SRCDIR/work/work/ase_top/ ]; then
    	echo -e -n "\t[BUILD PASS]" >> $ASEVAL_GIT/$SCRUB_LOG
    	echo "Running tests"
#    	xterm -iconic -e "cd $ASE_SRCDIR ; make sim SIMULATOR=QUESTA " &
    	xterm -e "cd $ASE_SRCDIR ; make sim SIMULATOR=QUESTA " &
    	while [ ! -f $ASE_WORKDIR/.ase_ready.pid ]
    	do
    	    sleep 1
    	done
    	cd $ASEVAL_GIT/apps/
    	./nlb_scrub.sh
    	if [ $? -eq 0 ]; then
    	    echo -e -n "\t[RUN PASS]" >> $ASEVAL_GIT/$SCRUB_LOG
    	else
    	    echo -e -n "\t[** RUN FAIL **]" >> $ASEVAL_GIT/$SCRUB_LOG
    	fi
    	$ASEVAL_GIT/kill_running_ase.sh
	pkill xterm
    	sleep 1
    else
    	echo -n -e "\t[** BUILD FAIL **]" >> $ASEVAL_GIT/$SCRUB_LOG
	# IFS='/' read -r -a $path_str <<< "$i"
	# mv compile.log $ASE_SRCDIR/vsim-$path_str[6]-FAIL.txt
    fi
    echo -e "" >> $ASEVAL_GIT/$SCRUB_LOG
done
