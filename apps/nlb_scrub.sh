#!/bin/sh

rm output.*.log
./build_all.sh

vc_arr="0 1 2 3"

mcl_arr="0 1 3"

cl_arr="16 256 1024"

echo "NLB Scrub test will run" $NUM_TESTS "tests"
for vc in $vc_arr; do
    for mcl in $mcl_arr; do
	for cl in $cl_arr; do
	    timeout 20 ./nlb_test.out $cl $vc $cl > nlb-out.log
	    echo "./nlb_test $cl $vc $mcl "
	    if [ $? == 124 ];
	    then
	    	echo "Timeout occured "
	    else
	    	if grep -q "ERROR" nlb-out.log
	    	then
	    	    echo " FAIL "
	    	else
	    	    echo " OK   "
	    	fi
	    fi
	done
    done
done

