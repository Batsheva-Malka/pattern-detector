# Pattern Detector UVM Testbench Makefile
# Supports QuestaSim/ModelSim

# Simulator settings
SIM = vsim
VLOG = vlog
VOPT = vopt

# Directories
RTL_DIR = ../rtl
TB_DIR = ../tb
TEST_DIR = ../tests
SIM_DIR = .

# UVM settings
UVM_HOME = $(QUESTASIM_HOME)/../verilog_src/uvm-1.2
UVM_FLAGS = +incdir+$(UVM_HOME)/src $(UVM_HOME)/src/uvm_pkg.sv

# Compilation flags
VLOG_FLAGS = -sv +acc -timescale=1ns/1ps
VLOG_FLAGS += +incdir+$(TB_DIR) +incdir+$(TEST_DIR)
VLOG_FLAGS += -suppress 2286,7061

# Simulation flags
VSIM_FLAGS = -voptargs=+acc -sv_seed=random
VSIM_FLAGS += +UVM_TESTNAME=$TEST
VSIM_FLAGS += +UVM_VERBOSITY=UVM_MEDIUM
VSIM_FLAGS += -do "run -all; quit -f"

# Coverage flags
COV_FLAGS = +cover=bcesf

# Default test
TEST ?= basic_match_test

# Source files
RTL_FILES = $(RTL_DIR)/pattern_detector.sv
TB_FILES = $(TB_DIR)/pattern_detector_if.sv \
           $(TB_DIR)/pattern_detector_pkg.sv \
           $(TB_DIR)/tb_top.sv

# Targets
.PHONY: all clean compile simulate run_all_tests help

all: compile

# Compile all files
compile:
	@echo "Compiling RTL and Testbench..."
	$(VLOG) $(VLOG_FLAGS) $(UVM_FLAGS) $(RTL_FILES)
	$(VLOG) $(VLOG_FLAGS) $(UVM_FLAGS) $(TB_FILES)
	@echo "Compilation complete!"

# Run simulation with specified test
simulate: compile
	@echo "Running test: $(TEST)"
	$(SIM) $(VSIM_FLAGS) tb_top

# Run all tests from VPlan
run_all_tests: compile
	@echo "Running all tests from VPlan..."
	$(SIM) $(VSIM_FLAGS) -c tb_top +UVM_TESTNAME=basic_match_test
	$(SIM) $(VSIM_FLAGS) -c tb_top +UVM_TESTNAME=no_match_test
	$(SIM) $(VSIM_FLAGS) -c tb_top +UVM_TESTNAME=first_window_match_test
	$(SIM) $(VSIM_FLAGS) -c tb_top +UVM_TESTNAME=last_window_match_test
	$(SIM) $(VSIM_FLAGS) -c tb_top +UVM_TESTNAME=multiple_matches_test
	$(SIM) $(VSIM_FLAGS) -c tb_top +UVM_TESTNAME=full_mask_test
	$(SIM) $(VSIM_FLAGS) -c tb_top +UVM_TESTNAME=zero_mask_test
	$(SIM) $(VSIM_FLAGS) -c tb_top +UVM_TESTNAME=reset_test
	$(SIM) $(VSIM_FLAGS) -c tb_top +UVM_TESTNAME=random_test
	@echo "All tests complete!"

# Run with coverage
coverage: compile
	@echo "Running with coverage..."
	$(SIM) $(VSIM_FLAGS) $(COV_FLAGS) tb_top

# Clean simulation files
clean:
	@echo "Cleaning simulation files..."
	rm -rf work transcript vsim.wlf *.vcd *.log
	rm -rf covhtmlreport/ coverage.ucdb
	@echo "Clean complete!"

# Help
help:
	@echo "Pattern Detector UVM Testbench Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  make compile          - Compile RTL and testbench"
	@echo "  make simulate TEST=<test_name> - Run specific test"
	@echo "  make run_all_tests    - Run all tests from VPlan"
	@echo "  make coverage         - Run with coverage collection"
	@echo "  make clean            - Remove simulation files"
	@echo ""
	@echo "Available tests:"
	@echo "  basic_match_test"
	@echo "  no_match_test"
	@echo "  first_window_match_test"
	@echo "  last_window_match_test"
	@echo "  multiple_matches_test"
	@echo "  full_mask_test"
	@echo "  zero_mask_test"
	@echo "  reset_test"
	@echo "  random_test"
	@echo ""
	@echo "Example: make simulate TEST=basic_match_test"
