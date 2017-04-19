#!/bin/sh
cd $MY_INSTDIR
lcov --zerocounters --directory .
lcov --capture --initial --directory . --output-file coverage_new
cd $BBB_GIT/BBB_cci_mpf/test/test-mpf/test_random/sw/
./$1 --target=ase --tc=100

lcov -capture --directory $MY_INSTDIR ./ase/api/CMakeFiles/fpga-ASE.dir/src/ -o coverage.info
genhtml coverage.info --output-directory coverage_out
