##############################################################
#                                                            #
# Xeon(R) + FPGA AFU Simulation Environment                  #
# File generated by ase/scripts/generate_ase_environment.py  #
#                                                            #
##############################################################

DUT_VLOG_SRC_LIST = $(ASE_SRCDIR)/vlog_files.list 

DUT_INCDIR = $(ASE_VALGIT)/test_afus/ccip_mmio_rdwr_stress/HW+

SIMULATOR ?= VCS

ASE_PLATFORM ?= FPGA_PLATFORM_INTG_XEON

