#!/bin/sh

LOGNAME="$PWD/test_status.log"

# Delete log if exists
rm -rf $LOGNAME

# Wait for simulator ready
$ASEVAL_GIT/wait_till_ase_ready.sh

# Simulator PID
ase_pid=`cat $ASE_WORKDIR/.ase_ready.pid | grep pid | cut -d "=" -s -f2-`

# Return code
retcode=0

# Change Directory to Hello_ALI_NLB
cd $AALSAMP_DIR/Hello_ALI_NLB/SW/

# Run 
./helloALInlb

# Record Retcode
retcode=$?

## Return status
if [ $retcode == "0" ]
then
    echo "Hello_ALI_NLB completed -- SUCCESS"
else
    echo "Hello_ALI_NLB completed -- FAILED"
    exit 1
fi
