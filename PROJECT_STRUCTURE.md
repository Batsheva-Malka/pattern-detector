# Pattern Detector UVM Project Structure

## Complete File Tree

```
copilot-practicum/
│
├── 📁 rtl/                                    # RTL Design Files
│   └── pattern_detector.sv                   # DUT: Pattern detection logic
│
├── 📁 tb/                                     # Testbench Components
│   ├── pattern_detector_if.sv                # Interface with clocking blocks
│   ├── pattern_detector_seq_item.sv          # Transaction object
│   ├── pattern_detector_sequencer.sv         # Sequencer typedef
│   ├── pattern_detector_driver.sv            # UVM Driver (drives stimulus)
│   ├── pattern_detector_monitor.sv           # UVM Monitor (observes signals)
│   ├── pattern_detector_agent.sv             # UVM Agent (contains driver/monitor)
│   ├── pattern_detector_scoreboard.sv        # Scoreboard with reference model
│   ├── pattern_detector_coverage.sv          # Functional coverage collector
│   ├── pattern_detector_env.sv               # Top-level environment
│   ├── pattern_detector_config.sv            # Configuration object
│   ├── pattern_detector_sequences.sv         # All test sequences
│   ├── pattern_detector_pkg.sv               # Package file (includes all)
│   └── tb_top.sv                             # Testbench top module
│
├── 📁 tests/                                  # Test Cases
│   └── pattern_detector_tests.sv             # All 9 test classes
│
├── 📁 sim/                                    # Simulation Scripts
│   ├── Makefile                              # Unix/Linux compilation script
│   └── run_sim.bat                           # Windows batch script
│
├── 📄 README.md                               # Comprehensive documentation
├── 📄 QUICKSTART.md                           # Quick start guide
└── 📄 PROJECT_STRUCTURE.md                    # This file
```

## UVM Component Hierarchy

```
tb_top (module)
  │
  ├── pattern_detector_if (interface)
  │     └── Connected to DUT signals
  │
  ├── pattern_detector DUT (design under test)
  │
  └── UVM Test (selected via +UVM_TESTNAME)
        │
        └── pattern_detector_env
              │
              ├── pattern_detector_agent
              │     │
              │     ├── pattern_detector_driver
              │     │     └── Drives transactions to DUT
              │     │
              │     ├── pattern_detector_sequencer
              │     │     └── Controls sequence execution
              │     │
              │     └── pattern_detector_monitor
              │           └── Observes DUT outputs
              │
              ├── pattern_detector_scoreboard
              │     └── Checks DUT vs reference model
              │
              └── pattern_detector_coverage
                    └── Collects functional coverage
```

## Data Flow

```
1. STIMULUS GENERATION:
   Sequence → Sequencer → Driver → Interface → DUT

2. MONITORING:
   DUT → Interface → Monitor → Analysis Port

3. CHECKING:
   Monitor → Scoreboard (compares with reference model)

4. COVERAGE:
   Monitor → Coverage Collector
```

## Component Communication

```
┌─────────────────────────────────────────────────────────────┐
│                    pattern_detector_env                      │
│                                                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │           pattern_detector_agent                     │   │
│  │                                                       │   │
│  │  ┌──────────┐  ┌────────────┐  ┌─────────────┐     │   │
│  │  │ Driver   │←─│ Sequencer  │  │  Monitor    │     │   │
│  │  └────┬─────┘  └────────────┘  └──────┬──────┘     │   │
│  │       │                                 │            │   │
│  └───────┼─────────────────────────────────┼────────────┘   │
│          │                                 │                 │
│          │     ┌──────────────┐           │                 │
│          ├────→│ Interface    │←──────────┤                 │
│          │     └──────┬───────┘           │                 │
│          │            │                   │                 │
│          │     ┌──────▼───────┐           │                 │
│          │     │     DUT      │           │                 │
│          │     └──────────────┘           │                 │
│          │                                 │                 │
│          │                    ┌────────────▼────────────┐   │
│          │                    │   Scoreboard            │   │
│          │                    │   (Reference Model)     │   │
│          │                    └─────────────────────────┘   │
│          │                                 │                 │
│          │                    ┌────────────▼────────────┐   │
│          │                    │   Coverage Collector    │   │
│          │                    └─────────────────────────┘   │
│          │                                                   │
└──────────┼───────────────────────────────────────────────────┘
```

## Compilation Order

When compiling, files must be compiled in this order:

1. **RTL Files**
   - `pattern_detector.sv`

2. **Interface**
   - `pattern_detector_if.sv`

3. **Package** (includes all classes in correct order)
   - `pattern_detector_pkg.sv`
     - seq_item
     - sequencer
     - driver
     - monitor
     - scoreboard
     - coverage
     - agent
     - config
     - env
     - sequences
     - tests

4. **Top Module**
   - `tb_top.sv`

## Key Files to Understand

### For Beginners:
1. `pattern_detector.sv` - The design being verified
2. `pattern_detector_seq_item.sv` - Transaction format
3. `pattern_detector_sequences.sv` - Test scenarios
4. `pattern_detector_tests.sv` - Test execution

### For Advanced Users:
5. `pattern_detector_scoreboard.sv` - Reference model algorithm
6. `pattern_detector_coverage.sv` - Coverage methodology
7. `pattern_detector_pkg.sv` - Overall structure

## Makefile Targets

| Command                 | What it does                          |
|------------------------|---------------------------------------|
| `make compile`         | Compiles all RTL and TB files        |
| `make simulate`        | Runs one test                         |
| `make run_all_tests`   | Runs all 9 tests sequentially         |
| `make coverage`        | Runs with coverage collection         |
| `make clean`           | Removes simulation artifacts          |
| `make help`            | Shows available commands              |

## Generated Files (after simulation)

- `work/` - Compiled library directory
- `transcript` - Simulation log with all messages
- `pattern_detector.vcd` - Waveform dump file
- `vsim.wlf` - QuestaSim waveform file
- `coverage.ucdb` - Coverage database (if enabled)

## Next Steps

1. **Understand the basics**: Read README.md and QUICKSTART.md
2. **Run a simple test**: Try `basic_match_test`
3. **View waveforms**: Open the .vcd file
4. **Add coverage**: Check what's covered, what's not
5. **Enhance tests**: Add corner cases as needed
