#!/bin/bash

set -e

LD_LIBRARY_PATH=${MYINST_DIR}/lib/

#####################################################################
## Start hello_fpga, kill immediately, check if send_simkill works ##
#####################################################################
echo "Starting App and killing within 2 seconds"
cd $FPGASW_GIT/build/bin/
LD_PRELOAD=libopae-c-ase.so ./hello_fpga &

sleep 2
kill `head $ASE_WORKDIR/.app_lock.pid`

## Wait and see if app closed gracefully
while [ -f $ASE_WORKDIR/.app_lock.pid ]
do
    echo "App is still running"
    sleep 1    
done
echo "Test 1 complete"

sleep 2

#####################################################################
##            Try run two applications at one time                 ##
#####################################################################
echo "Running Two Apps at one time"
cd $FPGASW_GIT/build/bin/
echo "Starting App 1"
LD_PRELOAD=libopae-c-ase.so ./hello_fpga | tee good_run.log & 
good_pid=$!
sleep 1
echo "Starting App 2"
LD_PRELOAD=libopae-c-ase.so ./hello_fpga | tee bad_run.log

if grep -Fxq "ASE was found to be running with another application" bad_run.log
then
    echo "Bad application failed to launch -- SUCCESS !"    
else
    echo "Test 2 failed !"    
fi

#wait

sleep 2

#####################################################################
##                  Try with no simulator running                  ##
#####################################################################
echo "Running App without a simulator"
sim_pid=`cat $ASE_WORKDIR/.ase_ready.pid | grep pid | cut -d "=" -s -f2-`
kill $sim_pid
echo "  Simulator killed"
sleep 2
LD_PRELOAD=libopae-c-ase.so ./hello_fpga | tee no_sim.log
if grep -Fxq "Simualtor is not running yet" no_sim.log
then
    echo "Simulator finder (false case) worked correctly -- SUCCESS !"
else
    echo "Test 3 Failed !"
fi

echo "Test Complete"

#####################################################################
##                  App Lock resilience test                       ##
#####################################################################
# TBD
