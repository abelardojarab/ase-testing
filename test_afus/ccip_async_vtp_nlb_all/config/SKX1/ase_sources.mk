####################################################################
#                                                                  #
# Xeon(R) + FPGA AFU Simulation Environment                        #
# File generated by AALSDK/ase/scripts/generate_ase_environment.py #
#                                                                  #
####################################################################

DUT_VLOG_SRC_LIST = $(ASE_SRCDIR)/vlog_files.list 

DUT_INCDIR = $(BBB_GIT)/BBB_cci_mpf/rtl/+$(BBB_GIT)/BBB_cci_mpf/rtl/rtl+$(BBB_GIT)/BBB_cci_mpf/rtl/rtl/cci-mpf-shims+$(BBB_GIT)/BBB_cci_mpf/rtl/rtl/cci-mpf-shims/cci_mpf_shim_vtp+$(BBB_GIT)/BBB_cci_mpf/rtl/rtl/cci-mpf-shims/cci_mpf_shim_edge+$(BBB_GIT)/BBB_cci_mpf/rtl/rtl/cci-mpf-shims/cci_mpf_shim_wro+$(BBB_GIT)/BBB_cci_mpf/rtl/rtl/cci-mpf-shims/cci_mpf_shim_pwrite+$(BBB_GIT)/BBB_cci_mpf/rtl/rtl/cci-if+$(BBB_GIT)/BBB_cci_mpf/rtl/rtl/cci-mpf-if+$(BBB_GIT)/BBB_cci_mpf/rtl/rtl/cci-mpf-prims+$(BBB_GIT)/BBB_cci_mpf/rtl/par+$(BBB_GIT)/BBB_cci_mpf/sample/afu/+$(ASEVAL_GIT)/test_afus/ccip_nlb_all_SKX1/HW/+$(ASEVAL_GIT)/test_afus/ccip_nlb_all_SKX1/HW/include_files+$(ASEVAL_GIT)/test_afus/ccip_nlb_all_SKX1/HW/include_files/common+$(ASEVAL_GIT)/test_afus/ccip_nlb_all_SKX1/HW/QSYS_IPs+$(ASEVAL_GIT)/test_afus/ccip_nlb_all_SKX1/HW/QSYS_IPs/RAM+$(ASEVAL_GIT)/test_afus/ccip_nlb_all_SKX1/HW/QSYS_IPs/RAM/lpbk1_RdRspRAM2PORT+$(ASEVAL_GIT)/test_afus/ccip_nlb_all_SKX1/HW/QSYS_IPs/RAM/lpbk1_RdRspRAM2PORT/synth+$(ASEVAL_GIT)/test_afus/ccip_nlb_all_SKX1/HW/QSYS_IPs/RAM/lpbk1_RdRspRAM2PORT/ram_2port_160+$(ASEVAL_GIT)/test_afus/ccip_nlb_all_SKX1/HW/QSYS_IPs/RAM/lpbk1_RdRspRAM2PORT/ram_2port_160/synth+$(ASEVAL_GIT)/test_afus/ccip_nlb_all_SKX1/HW/QSYS_IPs/RAM/req_C1TxRAM2PORT+$(ASEVAL_GIT)/test_afus/ccip_nlb_all_SKX1/HW/QSYS_IPs/RAM/req_C1TxRAM2PORT/synth+$(ASEVAL_GIT)/test_afus/ccip_nlb_all_SKX1/HW/QSYS_IPs/RAM/req_C1TxRAM2PORT/ram_2port_160+$(ASEVAL_GIT)/test_afus/ccip_nlb_all_SKX1/HW/QSYS_IPs/RAM/req_C1TxRAM2PORT/ram_2port_160/synth+$(BBB_GIT)/BBB_ccip_async/rtl/rtl/+

SIMULATOR ?= VCS

SNPS_VLOGAN_OPT = +define+VENDOR_ALTERA +define+TOOL_QUARTUS +define+NUM_AFUS=1 +define+CCIP_IF_V0_1 +define+MPF_PLATFORM_SKX  +define+CCI_SIMULATION=1

ASE_PLATFORM = FPGA_PLATFORM_INTG_XEON

