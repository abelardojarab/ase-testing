#!/bin/sh

if [ -z "$AALSDK_GIT" ]; then
    echo "env(AALSDK_GIT) has not been set !"
    exit 1
fi

if [ -z "$BBB_GIT" ]; then
    echo "env(BBB_GIT) has not been set !"
    exit 1
fi

if [ -z "$ASEVAL_GIT" ]; then
    echo "env(ASEVAL_GIT) has not been set !"
    exit 1
fi

echo "ASE_WORKDIR =" $ASE_WORKDIR

# Check if ready file exists
if [ -e $ASE_WORKDIR/.ase_ready.pid ] ; then
    pid=`cat $ASE_WORKDIR/.ase_ready.pid | grep pid | cut -d "=" -s -f2-`
    echo "Killing Simulator PID " $pid
    kill $pid
else
    echo "** ERROR => Simulator process not found ! **"
fi


