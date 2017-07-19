#!/bin/bash

max_timeout=600

# Wait for Simulator to be running/ready (check for 10 mins = 600 sec)
echo "Waiting for simulator to be ready ... "

## Initialize timer
let timer=0

## Wait process
while [ ! -f $ASE_WORKDIR/.ase_ready.pid ] && [ $timer -lt $max_timeout ]
do
    let "timer++"
    echo "Waited $timer second(s)"
    sleep 1
done

## Check if it actually ran
if [ -f $ASE_WORKDIR/.ase_ready.pid ];
then
    echo "Simulator is running"
    exit 0
else
    echo "Simulator is not running (failed after $max_timeout seconds"
    exit -1
fi
