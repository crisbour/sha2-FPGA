DEV_DIR = ./sha2-dev

sync:
	rsync `find sha2-dev | egrep 'hdl/.*(\.v|\.sv)' | egrep -v '_tb\.'` nf_sha2/hdl
	@echo 'All Verilog/SystemVerilog scripts that are not testbenches copied'
