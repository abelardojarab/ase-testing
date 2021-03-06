####################################################################
#                                                                  #
# Xeon(R) + FPGA AFU Simulation Environment                        #
# File generated by AALSDK/ase/scripts/generate_ase_environment.py #
#                                                                  #
####################################################################

DUT_VLOG_SRC_LIST = $(ASE_SRCDIR)/vlog_files.list 

DUT_INCDIR = $(ASEVAL_GIT)/test_afus/ccip_nlb_all_SKX1/+$(ASEVAL_GIT)/test_afus/ccip_nlb_all_SKX1/HW+$(ASEVAL_GIT)/test_afus/ccip_nlb_all_SKX1/HW/include_files+$(ASEVAL_GIT)/test_afus/ccip_nlb_all_SKX1/HW/include_files/common+$(ASEVAL_GIT)/test_afus/ccip_nlb_all_SKX1/HW/QSYS_IPs+$(ASEVAL_GIT)/test_afus/ccip_nlb_all_SKX1/HW/QSYS_IPs/RAM+$(ASEVAL_GIT)/test_afus/ccip_nlb_all_SKX1/HW/QSYS_IPs/RAM/lpbk1_RdRspRAM2PORT+$(ASEVAL_GIT)/test_afus/ccip_nlb_all_SKX1/HW/QSYS_IPs/RAM/lpbk1_RdRspRAM2PORT/synth+$(ASEVAL_GIT)/test_afus/ccip_nlb_all_SKX1/HW/QSYS_IPs/RAM/lpbk1_RdRspRAM2PORT/ram_2port_160+$(ASEVAL_GIT)/test_afus/ccip_nlb_all_SKX1/HW/QSYS_IPs/RAM/lpbk1_RdRspRAM2PORT/ram_2port_160/synth+$(ASEVAL_GIT)/test_afus/ccip_nlb_all_SKX1/HW/QSYS_IPs/RAM/req_C1TxRAM2PORT+$(ASEVAL_GIT)/test_afus/ccip_nlb_all_SKX1/HW/QSYS_IPs/RAM/req_C1TxRAM2PORT/synth+$(ASEVAL_GIT)/test_afus/ccip_nlb_all_SKX1/HW/QSYS_IPs/RAM/req_C1TxRAM2PORT/ram_2port_160+$(ASEVAL_GIT)/test_afus/ccip_nlb_all_SKX1/HW/QSYS_IPs/RAM/req_C1TxRAM2PORT/ram_2port_160/synth+

ASE_TOP = ase_top

SIMULATOR ?= VCS
