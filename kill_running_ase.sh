#!/bin/bash

echo "ASE_WORKDIR =" $ASE_WORKDIR

# Check if ready file exists
echo "Looking for ASE lock file in ASE_WORKDIR=" $ASE_WORKDIR
if [ -e $ASE_WORKDIR/.ase_ready.pid ]
then
    pid=`cat $ASE_WORKDIR/.ase_ready.pid | grep pid | cut -d "=" -s -f2-`
    while [ -f $ASE_WORKDIR/.ase_ready.pid ]
    do
	echo "Killing Simulator PID " $pid
	kill $pid
	sleep 1
    done
else
    echo "Simulator has probably already been killed"
fi

# Disk cleanup
# if [ $USER == "lab" ] ; then
#     echo "####################################################"
#     echo "# Proceeding with cleaning up simulation for space #"
#     echo "####################################################"
#     rm -rf $ASE_WORKDIR
# else
#     echo "Looks like a manual run, will NOT clean up simulation workspace"
# fi
