#############################################################################
#                                                                           #
# Xeon(R) + FPGA AFU Simulation Environment 5.0.3                           #
# This file was generated by AALSDK/ase/scripts/generate_ase_environment.py #
#                                                                           #
#############################################################################

DUT_VLOG_SRC_LIST = vlog_files.list 

DUT_INCDIR = $(ASEVAL_GIT)/test_afus/ccip_vtp_nlb_all/HW/+$(ASEVAL_GIT)/test_afus/ccip_vtp_nlb_all/HW/include_files+$(ASEVAL_GIT)/test_afus/ccip_vtp_nlb_all/HW/include_files/common+$(ASEVAL_GIT)/test_afus/ccip_vtp_nlb_all/HW/QSYS_IPs+$(ASEVAL_GIT)/test_afus/ccip_vtp_nlb_all/HW/QSYS_IPs/RAM+$(ASEVAL_GIT)/test_afus/ccip_vtp_nlb_all/HW/QSYS_IPs/RAM/lpbk1_RdRspRAM2PORT+$(ASEVAL_GIT)/test_afus/ccip_vtp_nlb_all/HW/QSYS_IPs/RAM/lpbk1_RdRspRAM2PORT/ram_2port_151+$(ASEVAL_GIT)/test_afus/ccip_vtp_nlb_all/HW/QSYS_IPs/RAM/lpbk1_RdRspRAM2PORT/ram_2port_151/synth+$(ASEVAL_GIT)/test_afus/ccip_vtp_nlb_all/HW/QSYS_IPs/RAM/lpbk1_RdRspRAM2PORT/synth+$(ASEVAL_GIT)/test_afus/ccip_vtp_nlb_all/HW/QSYS_IPs/RAM/req_C1TxRAM2PORT+$(ASEVAL_GIT)/test_afus/ccip_vtp_nlb_all/HW/QSYS_IPs/RAM/req_C1TxRAM2PORT/ram_2port_151+$(ASEVAL_GIT)/test_afus/ccip_vtp_nlb_all/HW/QSYS_IPs/RAM/req_C1TxRAM2PORT/ram_2port_151/synth+$(ASEVAL_GIT)/test_afus/ccip_vtp_nlb_all/HW/QSYS_IPs/RAM/req_C1TxRAM2PORT/synth+$(BBB_GIT)/cci_mpf/HW/+$(BBB_GIT)/cci_mpf/HW/cci-mpf-shims+$(BBB_GIT)/cci_mpf/HW/cci-mpf-shims/cci_mpf_shim_vtp+$(BBB_GIT)/cci_mpf/HW/cci-mpf-shims/cci_mpf_shim_edge+$(BBB_GIT)/cci_mpf/HW/cci-if+$(BBB_GIT)/cci_mpf/HW/cci-mpf-if+$(BBB_GIT)/cci_mpf/HW/par+$(BBB_GIT)/cci_mpf/HW/cci-mpf-prims+$(BBB_GIT)/cci_mpf/test_afus/+

ASEHW_FILE_LIST = \
	$(ASE_SRCDIR)/hw/ccip_if_pkg.sv \
	$(ASE_SRCDIR)/hw/ase_pkg.sv \
	$(ASE_SRCDIR)/hw/outoforder_wrf_channel.sv \
	$(ASE_SRCDIR)/hw/latency_pipe.sv \
	$(ASE_SRCDIR)/hw/ccip_emulator.sv \
	$(ASE_SRCDIR)/hw/ase_svfifo.sv \
	$(ASE_SRCDIR)/hw/ccip_logger.sv \
	$(ASE_SRCDIR)/hw/ccip_sniffer.sv \
	$(ASE_SRCDIR)/hw/ase_top.sv \


ASE_INCDIR = $(ASE_SRCDIR)/hw/+

ASESW_FILE_LIST = \
	$(ASE_SRCDIR)/sw/ase_ops.c \
	$(ASE_SRCDIR)/sw/ipc_mgmt_ops.c \
	$(ASE_SRCDIR)/sw/mem_model.c \
	$(ASE_SRCDIR)/sw/protocol_backend.c \
	$(ASE_SRCDIR)/sw/tstamp_ops.c \
	$(ASE_SRCDIR)/sw/mqueue_ops.c \
	$(ASE_SRCDIR)/sw/error_report.c \
	$(ASE_SRCDIR)/sw/linked_list_ops.c \
	$(ASE_SRCDIR)/sw/randomness_control.c \


ASE_TOP = ase_top

SIMULATOR ?= VCS

