SIMULATOR           = vcs
OUT_DIR             = ccip_sniffer_output
COMMON_COMPILE_ARGS = -timescale=1ns/1ps -lca -cm cond+branch+fsm+tgl -full64
#ASE_DIR		    = ${PWD}
ASE_PLATFORM?=FPGA_PLATFORM_INTG_XEON
# To run all the TEST_CASES, leave the TEST_CASES variable blank (as shown below).
TEST_CASES	   =
# To run a subset of the test cases, specify them in the TEST_CASES variable using
# the -t option (as shown below).
#TEST_CASES          = -t dot2_alm_w16_l1_d1_unit_test.sv dot2_alm_w8_l0_d0_unit_test.sv

sim:
	runSVUnit -s $(SIMULATOR) -f rtl.f -d FPGA_PLATFORM_INTG_XEON -o $(OUT_DIR) $(TEST_CASES) -c_arg "$(COMMON_COMPILE_ARGS)"
sim_coverage:
	runSVUnit -s $(SIMULATOR) -f rtl.f -o $(OUT_DIR) $(TEST_CASES) -c_arg "$(COMMON_COMPILE_ARGS) -debug_all" -r_arg "-vpd inter.vpd -full64 &"

sim_debug:
	runSVUnit -s $(SIMULATOR) -f rtl.f -o $(OUT_DIR) $(TEST_CASES) -c_arg "$(COMMON_COMPILE_ARGS) -debug_all" -r_arg "-gui -do ../vcs_debug.tcl"

clean:
	rm -rf $(OUT_DIR)

wave:
	dve -dir $(OUT_DIR)/simv.vdb/ -full64
