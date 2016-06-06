#!/bin/sh

SCRUB_LOG=questa-scrub.txt

export MGLS_LICENSE_FILE="1717@mentor04p.elic.intel.com"

export LM_LICENSE_FILE="1717@mentor04p.elic.intel.com":$LM_LICENSE_FILE

export LM_PROJECT="ATP-PLAT-DEV"

export TOOL_VERSION="
/p/eda/acd/mentor/questasim/6.6a/bin \
/nfs/site/eda/tools/mentor/questasim/10.0c/linux_2.6.16_x86-64/bin/ \
/nfs/site/eda/tools/mentor/questasim/10.1a/common/bin \
/nfs/site/eda/tools/mentor/questasim/10.1b/common/bin \
/nfs/site/eda/tools/mentor/questasim/10.1c/common/bin \
/nfs/site/eda/tools/mentor/questasim/10.2b/linux_2.6.16_x86-64/bin \
/nfs/site/eda/tools/mentor/questasim/10.2c/common/bin \
/nfs/site/eda/tools/mentor/questasim/10.2e/linux_3.0.51_x86-64/bin \
/nfs/site/eda/tools/mentor/questasim/10.3c/common/bin \
/nfs/site/eda/tools/mentor/questasim/6.2f/common/bin \
/nfs/site/eda/tools/mentor/questasim/6.3c/common/bin \
/nfs/site/eda/tools/mentor/questasim/6.3f/common/bin \
/nfs/site/eda/tools/mentor/questasim/6.3g/common/bin \
/nfs/site/eda/tools/mentor/questasim/6.3h/common/bin \
/nfs/site/eda/tools/mentor/questasim/6.3i/common/bin \
/nfs/site/eda/tools/mentor/questasim/6.4/common/bin \
/nfs/site/eda/tools/mentor/questasim/6.5b/common/bin \
/nfs/site/eda/tools/mentor/questasim/6.6b/linux_2.6.5_x86-64/questasim/bin \
/nfs/site/eda/tools/mentor/questasim/6.6f/common/bin \
/nfs/site/eda/tools/mentor/modelsim/6.0b/common/modeltech/bin/ \
/nfs/site/eda/tools/mentor/modelsim/6.0c/common/modeltech/bin/ \
/nfs/site/eda/tools/mentor/modelsim/6.0d/common/bin \
/nfs/site/eda/tools/mentor/modelsim/6.1a/common/modeltech/bin/ \
/nfs/site/eda/tools/mentor/modelsim/6.1b/common/modeltech/bin \
/nfs/site/eda/tools/mentor/modelsim/6.1d/common/bin \
/nfs/site/eda/tools/mentor/modelsim/6.1e/common/bin \
/nfs/site/eda/tools/mentor/modelsim/6.1f/common/bin \
/nfs/site/eda/tools/mentor/modelsim/6.1g/common/bin \
/nfs/site/eda/tools/mentor/modelsim/6.2/common/bin \
/nfs/site/eda/tools/mentor/modelsim/6.2b/common/bin \
/nfs/site/eda/tools/mentor/modelsim/6.2c/common/bin \
/nfs/site/eda/tools/mentor/modelsim/6.2d/common/bin \
/nfs/site/eda/tools/mentor/modelsim/6.2e/common/bin \
/nfs/site/eda/tools/mentor/modelsim/6.2g/common/bin \
/nfs/site/eda/tools/mentor/modelsim/6.2i/common/bin \
/nfs/site/eda/tools/mentor/modelsim/6.3/common/bin \
/nfs/site/eda/tools/mentor/modelsim/6.3a/common/bin \
/nfs/site/eda/tools/mentor/modelsim/6.3e/common/bin \
/nfs/site/eda/tools/mentor/modelsim/6.3g/common/bin \
/nfs/site/eda/tools/mentor/modelsim/6.3i/common/bin \
/nfs/site/eda/tools/mentor/modelsim/6.4a/common/bin \
/nfs/site/eda/tools/mentor/modelsim/6.6b1/common/bin \
/nfs/site/eda/tools/mentor/modelsim/6.6c/common/bin \
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
    cd $ASE_SRCDIR
    make clean
    make
    echo -e -n "$MTI_HOME" >> $ASEVAL_GIT/$SCRUB_LOG
    if [ -f $ASE_SRCDIR/work/work/dpiheader.h ]; then
    	echo -e -n "\t[BUILD PASS]" >> $ASEVAL_GIT/$SCRUB_LOG
	echo "Running tests"
	xterm -iconic -e "cd $ASE_SRCDIR ; make sim " &
#	xterm -e "cd $ASE_SRCDIR ; make sim " &
	while [ ! -f $ASE_WORKDIR/.ase_ready.pid ]
	do
	    sleep 1
	done
	cd $ASEVAL_GIT/apps/
	./nlb_scrub.sh 
	if [ $? -eq 0 ]; then
    	    echo -e -n "\t[RUN PASS]" >> $ASEVAL_GIT/$SCRUB_LOG	    
	    $ASEVAL_GIT/kill_running_ase.sh
	else
	    echo -e -n "\t[** RUN FAIL **]" >> $ASEVAL_GIT/$SCRUB_LOG
	    $ASEVAL_GIT/kill_running_ase.sh
	fi
	sleep 1
    else
    	echo -n -e "\t[** BUILD FAIL **]" >> $ASEVAL_GIT/$SCRUB_LOG
    fi
    echo -e "" >> $ASEVAL_GIT/$SCRUB_LOG 
done

