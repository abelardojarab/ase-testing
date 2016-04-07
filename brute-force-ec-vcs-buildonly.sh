#!/bin/sh

source ~/bashrc_aliases/quartus_15_pro.csh

export CURRDIR=$PWD

export ASE_SRCDIR=$PWD/../aalsdk/aaluser/ase/

export SNPSLMD_LICENSE_FILE="26586@plxs0402.pdx.intel.com:26586@plxs0405.pdx.intel.com:26586@plxs0406.pdx.intel.com:26586@plxs0408.pdx.intel.com:26586@plxs0414.pdx.intel.com:26586@plxs0415.pdx.intel.com:26586@plxs0416.pdx.intel.com:26586@plxs0418.pdx.intel.com"

export VCS_PATH=/p/eda/acd/synopsys/vcsmx/

export TOOL_VERSION="
/p/eda/acd/synopsys/vcsmx/F-2011.12-SP1-11 \
/p/eda/acd/synopsys/vcsmx/F-2011.12-SP1-5 \
/p/eda/acd/synopsys/vcsmx/F-2011.12-SP1-8 \
/p/eda/acd/synopsys/vcsmx/H-2013.06 \
/p/eda/acd/synopsys/vcsmx/H-2013.06-3 \
/p/eda/acd/synopsys/vcsmx/H-2013.06-SP1 \
/p/eda/acd/synopsys/vcsmx/H-2013.06-SP1-11 \
/p/eda/acd/synopsys/vcsmx/H-2013.06-SP1-15-B-12 \
/p/eda/acd/synopsys/vcsmx/H-2013.06-SP1-2 \
/p/eda/acd/synopsys/vcsmx/H-2013.06-SP1-6_Full64 \
/p/eda/acd/synopsys/vcsmx/H-2013.06-SP1-9 \
/p/eda/acd/synopsys/vcsmx/H-2013.06.SP1-9 \
/p/eda/acd/synopsys/vcsmx/I-2014.03 \
/p/eda/acd/synopsys/vcsmx/I-2014.03-1 \
/p/eda/acd/synopsys/vcs/D-2010.06-SP1-3-B-2 \
/p/eda/acd/synopsys/vcs/E-2011.03-SP1-4 \
/p/eda/acd/synopsys/vcs/E-2011.03-SP1-7 \
/p/eda/acd/synopsys/vcs/F-2011.12-SP1 \
/p/eda/acd/synopsys/vcs/F-2011.12-SP1-3 \
/p/eda/acd/synopsys/vcs/F-2011.12-SP1-5 \
/p/eda/acd/synopsys/vcs/F-2011.12-SP1-8 \
/p/eda/acd/synopsys/vcs/G-2012.09 \
/p/eda/acd/synopsys/vcs/H-2013.06-Beta1 \
/p/eda/acd/synopsys/vcs/H-2013.06-SP1-1 \
/p/eda/acd/synopsys/vcs/H-2013.06-SP1-2 \
/p/eda/acd/synopsys/vcs/I-2014.03 \
"

cd $ASE_SRCDIR
rm -rf $CURRDIR/vcs-scrub.txt

for i in $TOOL_VERSION; do
    logname=`basename $i`
    export VCS_HOME=$i
    export PATH=$VCS_HOME/bin/:${PATH}    
    echo "Currently testing VCS-MX version: "
    echo "------------------------------------------------------"
    which vcs 
    echo "------------------------------------------------------"
    make clean
    make | tee $CURRDIR/$logname.log
    if [ $? -eq 0 ]; then
    	echo -e "$VCS_HOME" "\t\t" "[PASS]" >> $CURRDIR/vcs-scrub.txt
    else
    	echo -e "$VCS_HOME" "\t\t" "[FAIL]" >> $CURRDIR/vcs-scrub.txt
    fi
    # echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
done


