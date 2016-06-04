#!/bin/sh

rm -rf scrub.*.log

if [[ $1 == "full" ]];
then
    vc_arr="0 1 2 3"
    mcl_arr="0 1 3"
    cl_arr="16 64 256 1024 4096 32768"
    timeout=500
else
    vc_arr="0 1 2"
    mcl_arr="0 3"
    cl_arr="16 4096"
    timeout=300
fi

ase_pid=`cat $ASE_WORKDIR/.ase_ready.pid | grep pid | cut -d "=" -s -f2-`

for vc in $vc_arr; do
    for mcl in $mcl_arr; do
	for cl in $cl_arr; do
	    echo "./nlb_test.out $cl $vc $mcl"
	    timeout $timeout ./nlb_test.out $cl $vc $mcl
	    if [ $? != 0 ];
	    then
	    	echo " ERROR running nlb_scrub -- EXIT"
		exit -1
	    fi	    	    
	    if ps -p $ase_pid > /dev/null
	    then
		echo "Simulator is running"
	    else
		echo "ASE PID seems to have crashed -- EXIT"
		exit -1
	    fi
	done
    done
done


