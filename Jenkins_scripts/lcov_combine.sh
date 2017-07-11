#!/bin/bash
lcov -a /home/lab/workspace/jenkins/workspace/ASE_Coverage/TEST_AFU_DIR/ccip_nlb_all_SKX1/label/ASE/$AALSDK_GIT/ase/api/mybuild/*.info -a /home/lab/workspace/jenkins/workspace/ASE_Coverage/TEST_AFU_DIR/ccip_mmio_rdwr_stress/label/ASE/$AALSDK_GIT/ase/api/mybuild/*.info -o total.info  # combine them into total.info
genhtml total.info --output-directory total_info
