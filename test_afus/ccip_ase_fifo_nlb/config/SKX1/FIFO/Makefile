channel:
	vcs -j 4 -full64 -nc -l comp.log \
	-sverilog -override_timescale=10ps/10ps \
	+incdir+$(ASE_SRCDIR)/hw/ -debug_all -race \
	+define+ASE_DEBUG \
	$(ASE_SRCDIR)/hw/ase_pkg.sv \
	$(ASE_SRCDIR)/hw/outoforder_wrf_channel.sv \
	tb_channel.sv \

#	+vcs+loopreport +vcs+loopdetect \
# -cm line+cond+fsm+tgl+branch+assert \
# -cm_tgl mda -cm_cond basic+allops -cm_dir coverage \


latency_pipe:
	vcs -lca -full64 -nc ../../hw/latency_pipe.sv tb_latency_pipe.sv -sverilog +v2k -override_timescale=10ps/10ps -l comp.log


fifo:
	vcs -j 4 -full64 -nc  -sverilog -override_timescale=10ps/10ps +define+ASE_DEBUG \
	+incdir+../../hw/ -debug_all \
	../../aalsdk/aaluser/ase/hw/ase_svfifo.sv \
	tb_ase_fifo.sv

ase_svfifo:
	vcs -j 4 -full64 -nc  -sverilog -override_timescale=10ps/10ps \
	+incdir+$(ASE_SRCDIR)/rtl/ -debug_all \
        $(ASE_SRCDIR)/rtl/ase_svfifo.sv \
        $(PWD)/tb_ase_fifo.sv \
		-cm line+fsm+cond+tgl+branch \

prng:
	vcs -j 4 -full64 -nc \
	 -Mupdate -sverilog -override_timescale=10ps/10ps +incdir+../../hw/ -debug_all +lint=all \
	prng.sv \
	../../hw/latency_scoreboard.sv \
	../../hw/ase_fifo.sv \
	../../hw/sdp_ram.sv

string:
	vcs -full64 -nc -sverilog ../../hw/ase_pkg.sv ../../hw/ccip_logger.sv string_test.sv -debug_all +incdir+../../hw/

random_test:
	vcs -full64 -nc -sverilog random_test.sv  -debug_all 


################################################
all: random_test

sim:
	./simv -l run.log -ucli -do run.tcl
	# ./simv -l run.log -ucli -do run.tcl -cm line+fsm+cond+tgl+branch
	 urg -dir work/coverage.vdb -format both
	# dve -vpd inter.vpd -session session.tcl

wave: 
	dve -vpd inter.vpd -full64 &

################################################
clean:
	rm -rf *.vpd ucli.key DVEFiles/ DVEfiles/ *.log
	rm -rf simv* csrc/ coverage.vdb/
