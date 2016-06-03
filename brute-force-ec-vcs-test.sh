#!/bin/sh

## NOTES:
# Do not list any older than 2011
# Do not list any with "Beta" in the name
# Do not list all the "-x" version, just list the largest one

source ~/bashrc_aliases/quartus_15_pro.csh

# export CURRDIR=$PWD

# export ASE_SRCDIR=$PWD/../aalsdk/aaluser/ase/

export SNPSLMD_LICENSE_FILE="26586@plxs0402.pdx.intel.com:26586@plxs0405.pdx.intel.com:26586@plxs0406.pdx.intel.com:26586@plxs0408.pdx.intel.com:26586@plxs0414.pdx.intel.com:26586@plxs0415.pdx.intel.com:26586@plxs0416.pdx.intel.com:26586@plxs0418.pdx.intel.com"

export TOOL_VERSION="
/p/eda/acd/synopsys/vcs/E-2011.03-SP1-7 \
/p/eda/acd/synopsys/vcs/F-2011.12-SP1 \
/p/eda/acd/synopsys/vcs/F-2011.12-SP1-8 \
/p/eda/acd/synopsys/vcs/G-2012.09 \
/p/eda/acd/synopsys/vcs/H-2013.06-SP1-2 \
/p/eda/acd/synopsys/vcs/I-2014.03 \
/nfs/site/eda/tools/synopsys/vcs/E-2011.03-SP1-16 \
/nfs/site/eda/tools/synopsys/vcs/F-2011.12-SP1-11 \
/nfs/site/eda/tools/synopsys/vcs/G-2012.09 \
/nfs/site/eda/tools/synopsys/vcs/H-2013.06-4 \
/nfs/site/eda/tools/synopsys/vcs/H-2013.06-SP1-6 \
/nfs/site/eda/tools/synopsys/vcs/H-2013.06-SP1 \
/nfs/site/eda/tools/synopsys/vcs/I-2014.03 \
/p/eda/acd/synopsys/vcsmx/F-2011.12-SP1-11 \
/p/eda/acd/synopsys/vcsmx/H-2013.06 \
/p/eda/acd/synopsys/vcsmx/H-2013.06-3 \
/p/eda/acd/synopsys/vcsmx/H-2013.06-SP1 \
/p/eda/acd/synopsys/vcsmx/H-2013.06-SP1-11 \
/p/eda/acd/synopsys/vcsmx/I-2014.03 \
/p/eda/acd/synopsys/vcsmx/I-2014.03-1 \
/nfs/site/eda/tools/synopsys/vcsmx/E-2011.03-3 \
/nfs/site/eda/tools/synopsys/vcsmx/E-2011.03-SP1-11 \
/nfs/site/eda/tools/synopsys/vcsmx/E-2011.03 \
/nfs/site/eda/tools/synopsys/vcsmx/F-2011.12-4 \
/nfs/site/eda/tools/synopsys/vcsmx/F-2011.12-SP1-28 \
/nfs/site/eda/tools/synopsys/vcsmx/F-2011.12 \
/nfs/site/eda/tools/synopsys/vcsmx/G-2012.09-3 \
/nfs/site/eda/tools/synopsys/vcsmx/G-2012.09-SP1-7 \
/nfs/site/eda/tools/synopsys/vcsmx/G-2012.09-SP1 \
/nfs/site/eda/tools/synopsys/vcsmx/G-2012.09 \
/nfs/site/eda/tools/synopsys/vcsmx/H-2013.06-4 \
/nfs/site/eda/tools/synopsys/vcsmx/H-2013.06-SP1-15 \
/nfs/site/eda/tools/synopsys/vcsmx/H-2013.06 \
/nfs/site/eda/tools/synopsys/vcsmx/I-2014.03 \
/nfs/site/eda/tools/synopsys/vcsmx/J-2014.09-SP3-3 \
/nfs/site/eda/tools/synopsys/vcsmx/J-2014.12-1 \
/nfs/site/eda/tools/synopsys/vcsmx/J-2014.12-SP3 \
/nfs/site/eda/tools/synopsys/vcsmx/J-2014.12 \
/nfs/site/eda/tools/synopsys/vcsmx/K-2015.09-SP1 \
/nfs/site/eda/tools/synopsys/vcsmx/K-2015.09 \
/nfs/site/eda/tools/synopsys/vcsmx/L-2016.06-Beta \
"

cd $ASE_SRCDIR
rm -rf $ASEVAL_GIT/vcs-scrub.txt

echo "Building Quick-scrub tests"
cd $ASEVAL_GIT/apps/
./build_all.sh

for i in $TOOL_VERSION; do
    logname=`basename $i`
    export VCS_HOME=$i
    export PATH=$VCS_HOME/bin/:${PATH}    
    echo "--------------------------------------------------------------------------"
    echo "  Currently testing VCS version: $i $logname  " 
    echo "--------------------------------------------------------------------------"
    cd $ASE_SRCDIR
    make clean
    make > log.txt
    if [ $? -eq 0 ]; then
    	echo -e "$VCS_HOME" "\t\t[BUILD PASS]" >> $ASEVAL_GIT/vcs-scrub.txt
	echo "Running tests"
	xterm -iconic -e "cd $ASE_SRCDIR ; make sim " &
	while [ ! -f $ASE_WORKDIR/.ase_ready.pid ]
	do
	    sleep 1
	done
	cd $ASEVAL_GIT/apps/
	./nlb_scrub.sh 
	if [ $? -eq 0 ]; then
    	    echo -e "$VCS_HOME" "\t\t[RUN PASS]" >> $ASEVAL_GIT/vcs-scrub.txt	    
	else
	    echo -e "$VCS_HOME" "\t\t[** RUN FAIL **]" >> $ASEVAL_GIT/vcs-scrub.txt
	fi
	$ASEVAL_GIT/kill_running_ase.sh
	sleep 1
    else
    	echo -e "$VCS_HOME" "\t\t[** BUILD FAIL **]" >> $ASEVAL_GIT/vcs-scrub.txt
	mv log.txt $logname-build-FAIL.txt
    fi
done


