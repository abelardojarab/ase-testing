#!/bin/sh
cd $ASE_SRCDIR/api/mybuild
lcov --zerocounters --directory .
lcov --capture --initial --directory . --output-file coverage_new
cd $BBB_GIT/BBB_cci_mpf/test/test-mpf/test_random/sw/
./$1 --target=ase --tc=100

cd $ASE_SRCDIR/api/mybuild
lcov -capture --directory ./ase/api/CMakeFiles/fpga-ASE.dir/ -o coverage.info
genhtml coverage.info --output-directory coverage_out
