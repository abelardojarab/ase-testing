#!/bin/sh

MAX=1000

for i in `seq 1 $MAX`
do
    if [ -e $ASE_WORKDIR/.ase_ready.pid ] ; then
	echo "----------------------------"
	echo "        Iteration $i        "
	echo "----------------------------"	
#	gdb -ex run -ex quit --args ./InitRelease
	./InitRelease
	rc=$?
	if [[ $rc != 0 ]]
	then
	    echo "./InitRelease probably crashed ! EXITing"
	    exit
	fi
    else
	echo "Simulator not running !"
	exit
    fi
done
