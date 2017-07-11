#!/bin/bash

# Simulator PID
ase_pid=`cat $ASE_WORKDIR/.ase_ready.pid | grep pid | cut -d "=" -s -f2-`

cd $MYINST_DIR/bin
for i in `seq 0 10000`; do
    echo "---------------------------------"
    echo " Iteration $i                    "
    echo "---------------------------------"
    if ps -p $ase_pid > /dev/null
    then
	# gdb -ex run -ex quit --args ./fpgadiag --target=ase --mode=lpbk1 --begin=1
	./fpgadiag --target=ase --mode=lpbk1 --begin=1
	if [[ $? != 0 ]] ; 
	then
	    "fpgadiag timed out -- FAILURE EXIT !!"
	    exit 1
	fi
    else
	echo "** Simulator not running **"
	exit 1	
    fi
done

