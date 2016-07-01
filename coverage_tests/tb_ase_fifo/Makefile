all:
	vcs -j 4 -full64 -nc  -sverilog -override_timescale=10ps/10ps \
	+incdir+../../hw/ -debug_all \
	../../../aalsdk/aaluser/ase/hw/ase_svfifo.sv \
        tb_alt_fifo.sv \
	-cm line+fsm+cond+tgl+branch \

sim:
	./simv -l run.log -ucli -do run.tcl -cm line+fsm+cond+tgl+branch
	urg -dir simv.vdb -format both
	dve -vpd inter.vpd 


wave: 
	dve -vpd inter.vpd -full64 &


coverage:
	dve -dir simv.vdb/ -full64
	urg -full64 -dir simv.vdb


clean:
	rm -rf *.vpd ucli.key DVEFiles/ DVEfiles/ *.log
	rm -rf simv* csrc/ coverage.vdb/
