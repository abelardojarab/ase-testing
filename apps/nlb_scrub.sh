#!/bin/sh

rm scrub.*.log
#./build_all.sh

vc_arr="0 1 2 3"

mcl_arr="0 1 3"

cl_arr="16 64 256 1024 4096"

echo "NLB Scrub test will run" $NUM_TESTS "tests"
for vc in $vc_arr; do
    for mcl in $mcl_arr; do
	for cl in $cl_arr; do
	    timeout 300 ./nlb_test.out $cl $vc $cl > scrub_test_"$cl"_"$vc"_"$mcl".log
	    echo "./nlb_test $cl $vc $mcl "
	    if [ $? != 0 ];
	    then
	    	echo " ERROR "
		exit 1
	    fi	    
	done
    done
done

