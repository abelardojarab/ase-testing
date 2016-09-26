#!/bin/sh

# export PATH=/home/rrsharma/kw10/bin:$PATH
export PATH=/home/rrsharma/kw10/bin:${PATH}
export KW_BUILD=$AALUSER_DIR/kw_build/

source /opt/vcs.sh

source /opt/quartus_16.sh

TEST_OPTION=$1


if [[ $TEST_OPTION == "aal" ]]
then
    ############################################################################
    # delete and rebuild KWbuild
    rm -rf $KW_BUILD
    mkdir -p $KW_BUILD
    ## configure
    cd $KW_BUILD
    ../configure
    ## Klocwork
    kwcheck create --url https://klocwork-jf3.devtools.intel.com:8085/AALUSER
    kwshell --verbose make -j 8
    kwcheck run
    kwcheck list -F detailed --local --system --severity 1 > $ASEVAL_GIT/kw_run.1.log
    kwcheck list -F detailed --local --system --severity 2 > $ASEVAL_GIT/kw_run.2.log
    ############################################################################
elif [[ $TEST_OPTION == "ase" ]]
then
    ############################################################################
    cd $ASE_SRCDIR
    kwcheck create --url https://klocwork-jf3.devtools.intel.com:8085/AALUSER
    kwshell --verbose make
    kwcheck run
    kwcheck list -F detailed --local --system --severity 1 > $ASEVAL_GIT/kw_ase.1.log
    kwcheck list -F detailed --local --system --severity 2 > $ASEVAL_GIT/kw_ase.2.log
    ############################################################################
else
    echo "Set an option -- 'aal' or 'ase'"
fi

