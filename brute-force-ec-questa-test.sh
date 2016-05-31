#!/bin/sh

SCRUB_LOG=questa-scrub.txt

export MGLS_LICENSE_FILE="1717@mentor04p.elic.intel.com"


export TOOL_VERSION="
/p/eda/acd/mentor/questasim/10.1a \
/p/eda/acd/mentor/questasim/10.1b \
/p/eda/acd/mentor/questasim/10.1c \
/p/eda/acd/mentor/questasim/10.2c \
/p/eda/acd/mentor/questasim/10.3c \
/p/eda/acd/mentor/questasim/6.6a \
"

cd $ASE_SRCDIR
rm -rf $ASEVAL_GIT/$SCRUB_LOG

echo "Building Quick-scrub tests"
cd $ASEVAL_GIT/apps/
./build_all.sh

for i in $TOOL_VERSION; do
    logname=vsim-`basename $i`
    export MTI_HOME=$i
    export PATH=$MTI_HOME/bin/:${PATH}
    echo "--------------------------------------------------------------------------"
    echo "  Currently testing VCS version: $i $logname  "
    echo "--------------------------------------------------------------------------"
    cd $ASE_SRCDIR
    make clean
    make
    if [ $? -eq 0 ]; then
    	echo -e "$MTI_HOME" "\t\t" "[BUILD PASS]" >> $ASEVAL_GIT/$SCRUB_LOG
	xterm -iconic -e "cd $ASE_SRCDIR ; make sim " &
	while [ ! -f $ASE_WORKDIR/.ase_ready.pid ]
	do
	    sleep 1
	done
	cd $ASEVAL_GIT/apps/
	./nlb_scrub.sh
	if [ $? -eq 0 ]; then
    	    echo -e "$MTI_HOME" "\t\t" "[RUN PASS]" >> $ASEVAL_GIT/$SCRUB_LOG
	else
	    echo -e "$MTI_HOME" "\t\t" "[RUN FAIL]" >> $ASEVAL_GIT/$SCRUB_LOG
	fi
	$ASEVAL_GIT/kill_running_ase.sh
	sleep 1
    else
    	echo -e "$MTI_HOME" "\t\t" "[BUILD FAIL]" >> $ASEVAL_GIT/$SCRUB_LOG
	make clean
	make | tee $logname-build-FAIL.txt
    fi
done
