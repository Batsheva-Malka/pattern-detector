# Pattern Detector UVM Verification Environment

A complete UVM-based verification environment for the Pattern Detector block, following ChipVerify methodology.

## Project Overview

The Pattern Detector block monitors two 64-bit data streams and detects matching 32-bit patterns. It operates in two modes:
- **Full Adjustment Mode** (mode_select=0): Searches for identical 32-bit patterns across all possible alignments
- **Mask-Based Mode** (mode_select=1): Compares only the bits specified by a 32-bit mask

**Operating Frequency**: 160 MHz  
**Detection Latency**: 1-3 clock cycles

## Directory Structure

```
copilot-practicum/
├── rtl/                          # RTL Design
│   └── pattern_detector.sv      # DUT implementation
├── tb/                           # Testbench Components
│   ├── pattern_detector_if.sv          # Interface with clocking blocks
│   ├── pattern_detector_seq_item.sv    # Transaction class
│   ├── pattern_detector_sequencer.sv   # Sequencer typedef
│   ├── pattern_detector_driver.sv      # UVM driver
│   ├── pattern_detector_monitor.sv     # UVM monitor
│   ├── pattern_detector_agent.sv       # UVM agent
│   ├── pattern_detector_scoreboard.sv  # Scoreboard with reference model
│   ├── pattern_detector_coverage.sv    # Coverage collector
│   ├── pattern_detector_env.sv         # UVM environment
│   ├── pattern_detector_config.sv      # Configuration object
│   ├── pattern_detector_sequences.sv   # Test sequences
│   ├── pattern_detector_pkg.sv         # Package file
│   └── tb_top.sv                       # Testbench top module
├── tests/                        # Test Cases
│   └── pattern_detector_tests.sv # All test classes
├── sim/                          # Simulation Scripts
│   ├── Makefile                  # Makefile for compilation/simulation
│   └── run_sim.bat              # Windows batch script
└── README.md                     # This file
```

## Test List (from VPlan)

| Test ID | Test Name                     | Mode | Description                                    |
|---------|-------------------------------|------|------------------------------------------------|
| 1.1     | basic_match_test              | Full | One identical 32-bit window                    |
| 1.2     | no_match_test                 | Full | No identical window exists                     |
| 1.3     | first_window_match_test       | Full | Match occurs in first window (bits 0-31)       |
| 1.4     | last_window_match_test        | Full | Match occurs in last window (bits 32-63)       |
| 1.5     | multiple_matches_test         | Full | Multiple matching windows                      |
| 2.1     | full_mask_test                | Mask | mask = all 1's (same as Full Mode)             |
| 2.2     | zero_mask_test                | Mask | No bits compared (mask = 0)                    |
| 0.1     | reset_test                    | N/A  | Reset functionality verification               |
| -       | random_test                   | Both | Random stimulus for coverage                   |

## Coverage Plan

The verification environment implements comprehensive functional coverage including:
- **Mode Coverage**: Full/Mask modes
- **Window Alignment**: All 33×33 window combinations
- **Pattern Types**: Equal, different, overlapping, all-zero, all-one, alternating, random
- **Mask Patterns**: All zeros, all ones, single-bit, continuous, sparse
- **Match Results**: Match/no-match distribution
- **Mode × Match Cross**: Coverage of all mode and result combinations
- **Reset Behavior**: Reset during operation, match after reset
- **Mode Transitions**: Mode changes during runtime
- **Boundary Conditions**: Edge windows and stress scenarios

## How to Run

### Prerequisites
- QuestaSim/ModelSim (with UVM 1.2 library)
- SystemVerilog compiler support

### Using Makefile (Linux/Unix or Windows with Make)

```bash
cd sim

# Compile only
make compile

# Run specific test
make simulate TEST=basic_match_test

# Run all tests
make run_all_tests

# Run with coverage
make coverage

# Clean simulation files
make clean

# Show help
make help
```

### Using Windows Batch Script

```cmd
cd sim

# Run default test (basic_match_test)
run_sim.bat

# Run specific test
run_sim.bat no_match_test
run_sim.bat reset_test
```

### Manual Compilation (QuestaSim)

```bash
cd sim

# Create library
vlib work

# Compile RTL
vlog -sv +acc ../rtl/pattern_detector.sv

# Compile testbench
vlog -sv +acc +incdir+../tb +incdir+../tests \
     ../tb/pattern_detector_if.sv \
     ../tb/pattern_detector_pkg.sv \
     ../tb/tb_top.sv

# Run simulation
vsim -c +UVM_TESTNAME=basic_match_test tb_top -do "run -all; quit"
```

## UVM Architecture

```
tb_top
  └── pattern_detector_env
        ├── pattern_detector_agent
        │     ├── pattern_detector_driver
        │     ├── pattern_detector_sequencer
        │     └── pattern_detector_monitor
        ├── pattern_detector_scoreboard (with reference model)
        └── pattern_detector_coverage
```

## Key Features

✅ **Complete UVM Testbench**: Following ChipVerify methodology  
✅ **Reference Model**: Golden model in scoreboard for result checking  
✅ **Comprehensive Coverage**: All coverage items from VPlan  
✅ **9 Directed Tests**: Covering all test cases from VPlan  
✅ **Randomized Sequences**: For corner case discovery  
✅ **Clocking Blocks**: Proper timing control  
✅ **Modular Design**: Easy to extend and maintain  

## Scoreboard Reference Model

The scoreboard implements a reference model that:
1. Checks all 33 possible 32-bit windows in stream A
2. Checks all 33 possible 32-bit windows in stream B
3. Compares windows based on active mode (Full or Mask-based)
4. Predicts expected `pattern_match` output
5. Compares prediction with DUT output
6. Reports mismatches with detailed information

## Viewing Results

After simulation:
- **Transcript**: Check `transcript` file for UVM messages
- **Waveforms**: Open `pattern_detector.vcd` in waveform viewer
- **Coverage**: View coverage report (if coverage enabled)

## Extending the Environment

### Adding a New Test

1. Create new sequence in `pattern_detector_sequences.sv`
2. Create new test class in `pattern_detector_tests.sv`
3. Run with: `make simulate TEST=your_new_test`

### Adding Coverage Points

Edit `pattern_detector_coverage.sv` and add new coverpoints/crosses to the covergroup.

## Authors

- שולמית קרליבך
- מלכה רכניצר
- רחלי אוסטרוב

## References

- ChipVerify UVM Tutorial: https://www.chipverify.com/uvm
- Pattern Detector Specification Document
- Verification Plan (VPlan) Document
