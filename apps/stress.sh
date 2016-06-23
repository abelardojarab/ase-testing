#!/bin/sh

rm output.*.log

./build_all.sh

vc_arr[0]="0"
vc_arr[1]="1"
vc_arr[2]="2"
vc_arr[3]="3"


mcl_arr[0]="0"
mcl_arr[1]="1"
mcl_arr[2]="3"


if [ -z "$1" ]
then
    NUM_TESTS=10
else
    NUM_TESTS=$1
fi

## Check if inputs OK
if [ -z "$1" ]
then
    echo "Usage: ./stress.sh <num_tests> <short|long>"
    exit
else
    TEST_TYPE=$2
    if [ "$2" != "short" ]; then
	if [ "$2" != "long" ]; then
	    echo "TEST_TYPE must be short OR long"
	    exit
	fi
    fi	
fi

# Wait for Simulator to be running/ready
echo "Waiting for simulator to be ready ... "
for sleep in `seq 0 180`;
do
    if [ ! -f $ASE_WORKDIR/.ase_ready.pid ] 
    then
	sleep 1
    fi
done
if [ ! -f $ASE_WORKDIR/.ase_ready.pid ] 
then
    echo "Simulator might probably not come up at all -- ending regression here !"
    exit 1   
fi
echo "DONE"

# Simulator PID
ase_pid=`cat $ASE_WORKDIR/.ase_ready.pid | grep pid | cut -d "=" -s -f2-`

# 
echo "Stress test will run $NUM_TESTS tests"
for i in `seq 1 $NUM_TESTS`;
do
    if ps -p $ase_pid > /dev/null
    then
	echo "------------------------------------------------"
	echo "Running test" $i

	index=$[ $RANDOM % 4 ]
	vc_set=${vc_arr[$index]}

	index=$[ $RANDOM % 3 ]
	mcl_set=${mcl_arr[$index]}
	mcl_cnt=$(($mcl_set + 1))

	if [ $TEST_TYPE == "long" ] ; then
	    num_cl=`shuf -i 12000-16000 -n 1`	    
	fi
	if [ $TEST_TYPE == "short" ] ; then
	    num_cl=`shuf -i 256-1024 -n 1`
	fi

	num_cl=$(($num_cl * $mcl_cnt))
	
	echo ./nlb_test.out $num_cl $vc_set $mcl_set
	./nlb_test.out $num_cl $vc_set $mcl_set > output.$i.log
	if [ "$?" != 0 ] ; 
	then
	    echo "***** Test error *****"
	    $ASEVAL_GIT/kill_running_ase.sh
	    exit
	else
	    echo "Test PASS"
	fi
	sleep 1
    else
	echo "Simulator not running... EXIT";
	$ASEVAL_GIT/kill_running_ase.sh
	exit
    fi
done
echo "------------------------------------------------"

