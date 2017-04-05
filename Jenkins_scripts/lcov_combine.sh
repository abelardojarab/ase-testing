#!/bin/sh
lcov -a SCRIPT/cpt_sys_sw-fpga-sw/ase/api/mybuild/app_mmio.info -a SCRIPT_NLB3/cpt_sys_sw-fpga-sw/ase/api/mybuild/app.info -o total.info  # combine them into total.info
genhtml total.info --output-directory total_info
