#!/bin/sh

echo "ASE_WORKDIR =" $ASE_WORKDIR

# Check if ready file exists
if [ -e $ASE_WORKDIR/.ase_ready.pid ] ; then
    pid=`cat $ASE_WORKDIR/.ase_ready.pid | grep pid | cut -d "=" -s -f2-`
    echo "Killing Simulator PID " $pid
    kill $pid
else
    echo "** ERROR => Simulator process not found ! **"
    exit 1
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
