#!/bin/bash

echo "ASE_WORKDIR =" $ASE_WORKDIR

max_timeout=100
let kill_timer=0

# Check if ready file exists
echo "Looking for ASE lock file in ASE_WORKDIR=" $ASE_WORKDIR
if [ -e $ASE_WORKDIR/.ase_ready.pid ]
then
    pid=`cat $ASE_WORKDIR/.ase_ready.pid | grep pid | cut -d "=" -s -f2-`
    while [ -f $ASE_WORKDIR/.ase_ready.pid ] && [ $kill_timer -lt $max_timeout ]
    do
	echo "Killing Simulator PID " $pid
 	kill $pid
	sleep 1
	let "kill_timer++"
    done
    echo "Killing wrapper make script"
    kill $(ps -p `fuser $ASE_SRCDIR` | grep make | cut -f 1 -d " ")    
else
    echo "Simulator has probably already been killed"
fi
