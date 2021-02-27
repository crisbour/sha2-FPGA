DEV_DIR = ./

clean:
	@find . -type f -name 'results.xml' -delete
	@find . -type f -name '*.vcd' -delete
	@find . -type d -name 'sim_build' -exec rm -rf {} +
	@find . -type d -name '__pycache__' -exec rm -rf {} +
all:
	make -C $(DEV_DIR)/padder/test/
	make -C $(DEV_DIR)/wt_unit/test/
	make -C $(DEV_DIR)/hcu/test/Choose/
	make -C $(DEV_DIR)/hcu/test/Majority/
	make -C $(DEV_DIR)/hcu/test/Sigma/
	make -C $(DEV_DIR)/hcu/test/hash_update/
	make -C $(DEV_DIR)/hcu/test/
	make -C $(DEV_DIR)/digest/test/
	make -C $(DEV_DIR)/hash_engine/test/