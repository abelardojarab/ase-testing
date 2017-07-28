#!/bin/bash

set -e

LD_LIBRARY_PATH=${MYINST_DIR}/lib/

#####################################################################
## Start hello_fpga, kill immediately, check if send_simkill works ##
#####################################################################
cd $FPGASW_GIT/mybuild/bin/
LD_PRELOAD=libopae-c-ase.so ./hello_fpga &

sleep 2
kill `head $ASE_WORKDIR/.app_lock.pid`

## Wait and see if app closed gracefully
while [ -f $ASE_WORKDIR/.app_lock.pid ]
do
    echo "App is still running"
    sleep 1    
done
    
#####################################################################
##            Try run two applications at one time                 ##
#####################################################################
cd $FPGASW_GIT/mybuild/bin/
nohup LD_PRELOAD=libopae-c-ase.so ./hello_fpga & 
good_pid=$!
sleep 1
LD_PRELOAD=libopae-c-ase.so ./hello_fpga &> bad_run.log

if grep -Fxq "ASE was found to be running with another application" bad_run.log
then
    echo "Bad application failed to launch -- SUCCESS !"    
else
    echo "Test failed !"    
fi

wait

echo "Test Complete"

