# Quick Start Guide - Pattern Detector UVM Testbench

## 🚀 Quick Start

### Step 1: Navigate to simulation directory
```bash
cd sim
```

### Step 2: Run a test (Windows)
```cmd
run_sim.bat basic_match_test
```

### Step 2: Run a test (Linux with Make)
```bash
make simulate TEST=basic_match_test
```

## 📋 Available Tests

| Test Name                  | What it tests                           |
|---------------------------|-----------------------------------------|
| `basic_match_test`        | Basic pattern matching                  |
| `no_match_test`           | No patterns match                       |
| `first_window_match_test` | Pattern in first 32 bits                |
| `last_window_match_test`  | Pattern in last 32 bits                 |
| `multiple_matches_test`   | Multiple matching patterns              |
| `full_mask_test`          | Mask mode with all bits enabled         |
| `zero_mask_test`          | Mask mode with no bits compared         |
| `reset_test`              | Reset functionality                     |
| `random_test`             | Random stimulus (100 transactions)      |

## 🔧 Common Commands

```bash
# Run all tests
make run_all_tests

# Clean simulation files
make clean

# View help
make help
```

## 📊 Checking Results

After simulation completes:

1. **Check Pass/Fail**: Look for "TEST PASSED" or "TEST FAILED" in transcript
2. **Scoreboard Summary**: Shows number of matches/mismatches
3. **Coverage Report**: Shows functional coverage percentage
4. **Waveforms**: Open `pattern_detector.vcd` in GTKWave or ModelSim

## 🐛 Troubleshooting

**Problem**: Compilation errors  
**Solution**: Ensure you're in the `sim/` directory and paths are correct

**Problem**: UVM not found  
**Solution**: Check QuestaSim installation has UVM 1.2 library

**Problem**: Test timeout  
**Solution**: Increase timeout in `tb_top.sv` (default 1ms)

## 📁 File Organization

```
Key files you'll modify:
- tests/pattern_detector_tests.sv    ← Add new tests here
- tb/pattern_detector_sequences.sv   ← Add new sequences here
- tb/pattern_detector_coverage.sv    ← Add coverage points here
```

## ✅ What's Implemented

✓ Complete UVM environment (ChipVerify style)  
✓ All 9 tests from VPlan  
✓ Reference model in scoreboard  
✓ Functional coverage collection  
✓ Clocking blocks for timing control  
✓ Automated checking  
✓ Comprehensive reporting  

## 📖 Learning Resources

- ChipVerify UVM: https://www.chipverify.com/uvm
- UVM Cookbook: https://verificationacademy.com/cookbook
- Your VPlan document for test specifications
