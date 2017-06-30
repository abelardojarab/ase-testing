valgrind_run:
	cd $(ASE_WORKDIR); valgrind $(VALGRIND_OPT) ./ase_simv $(SNPS_SIM_OPT) +CONFIG=$(ASE_CONFIG) +SCRIPT=$(ASE_SCRIPT); cd -
