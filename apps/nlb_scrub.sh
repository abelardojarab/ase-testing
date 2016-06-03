#!/bin/sh

rm scrub.*.log

if [[ $1 == "full" ]];
then
    vc_arr="0 1 2 3"
    mcl_arr="0 1 3"
    cl_arr="16 64 256 1024 4096 32768"
else
    vc_arr="0 1 2"
    mcl_arr="0 3"
    cl_arr="16 4096"
fi

echo "NLB Scrub test will run" $NUM_TESTS "tests"
for vc in $vc_arr; do
    for mcl in $mcl_arr; do
	for cl in $cl_arr; do
	    timeout 500 ./nlb_test.out $cl $vc $cl > scrub_test_"$cl"_"$vc"_"$mcl".log
	    echo "./nlb_test $cl $vc $mcl "
	    if [ $? != 0 ];
	    then
	    	echo " ERROR "
		exit -1
	    fi	    
	done
    done
done

