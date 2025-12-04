# Pattern Detector Block Verification Plan

**Date**: December 4, 2025

**Verification Team**: שולמית קרליבך, מלכה רכניצר ורחלי אוסטרוב

---

## Content

1. [Glossary and References](#glossary-and-references)
2. [RTL Block Description](#rtl-block-description)
3. [RTL Block Diagram](#rtl-block-diagram)
4. [DUT Interface](#dut-interface)
5. [Verification Block Diagram](#verification-block-diagram)
6. [Verification Checkers and Assertions](#verification-checkers-and-assertions)
7. [Waves](#waves)
8. [Test List](#test-list)
9. [Coverage Plan](#coverage-plan)
10. [Coverage Result](#coverage-result)
11. [Disclaimers](#disclaimers)
12. [Open Issues / TODO List](#open-issues--todo-list)

---

## Glossary and References

### Glossary

- **Pattern Match**: A process in which the block checks whether there is a 32-bit pattern that appears in both 64-bit data streams. The match can occur anywhere in the stream, and in both operation modes (Full Adjustment Mode and Mask-Based Mode).

- **Full Adjustment Mode**: In this mode (mode_select = 0), the block searches for a match of the entire 32-bit pattern between the two data streams, regardless of the pattern's location within the stream. All 32 bits must be identical.

- **Mask-Based Mode**: In this mode (mode_select = 1), the block uses a 32-bit mask to determine which bits of the pattern should be compared. Only the bits where the mask contains a "1" will be checked.

- **Window**: A 32-bit segment extracted from the 64-bit data stream. There are 33 possible window positions in each 64-bit stream (positions 0-32).

- **Window Alignment**: The specific combination of window positions from stream A and stream B being compared. Total of 33×33 = 1089 possible alignments.

- **DUT (Device Under Test)**: The device being tested—in this case, the Pattern Detector Block where all functions and requirements are verified.

- **Reference Model**: A software implementation of the expected DUT behavior used in the scoreboard for comparing actual DUT outputs.

- **Scoreboard**: UVM component that compares DUT outputs with reference model predictions to verify correctness.

- **Coverage**: Metric measuring how thoroughly the verification environment has exercised the DUT's functionality.

### References

| Document | Version | Description |
|----------|---------|-------------|
| Pattern Detector Specification | 1.0 | RTL block functional specification |
| ChipVerify UVM Tutorial | Latest | UVM methodology reference |
| SystemVerilog LRM | IEEE 1800-2017 | Language reference |

---

## RTL Block Description

The Pattern Detector block is designed to monitor two 64-bit data streams (`data_stream_a` and `data_stream_b`) and detect when they contain the same 32-bit pattern. The block operates in two distinct modes: full adjustment mode and mask-based mode. When a pattern match is detected according to the active mode's criteria, the block asserts an output signal (`pattern_match`).

**Key Features:**
- Dual 64-bit input data streams
- Configurable operation modes via `mode_select` signal
- Flexible mask-based comparison using 32-bit `pattern_mask`
- Single-bit output indicating pattern match detection
- Operates at 160 MHz clock frequency
- Pattern detection latency: 1-3 clock cycles
- Active-low asynchronous reset

**Operation Modes:**

1. **Full Adjustment Mode (mode_select = 0)**:
   - Searches for any identical 32-bit pattern within both 64-bit streams
   - Performs sliding window comparison across all possible 32-bit alignments
   - Asserts pattern_match when any 32-bit sequence appears in both streams

2. **Mask-Based Mode (mode_select = 1)**:
   - Uses provided 32-bit pattern_mask to determine comparison bits
   - Only bits where pattern_mask[i] = 1 are compared
   - Comparison performed on all possible 32-bit alignments
   - Enables partial pattern matching based on mask configuration

---

## RTL Block Diagram

```
                    ┌─────────────────────────────────────┐
                    │                                     │
    clk ───────────>│                                     │
    rst_n ─────────>│                                     │
                    │      Pattern Detector Block         │
data_stream_a[63:0]─>│                                     │
data_stream_b[63:0]─>│     - Window Extraction (33x33)    │──> pattern_match
mode_select ───────>│     - Pattern Comparison Logic      │
pattern_mask[31:0]─>│     - Mode Selection                │
                    │     - Output Register               │
                    │                                     │
                    └─────────────────────────────────────┘
```

**Internal Blocks:**
1. Window Extraction Logic - Extracts all 33 possible 32-bit windows from each stream
2. Comparison Matrix - Performs 1089 comparisons (33×33 combinations)
3. Mode Selection Logic - Applies full or masked comparison based on mode_select
4. Match Detection - Detects if any comparison results in a match
5. Output Register - Registers the match result synchronously

---

## DUT Interface

| Signal Name    | Direction | Width | Type  | Description |
|----------------|-----------|-------|-------|-------------|
| clk            | Input     | 1     | logic | System clock – 160 MHz. Rising edge active. All synchronous operations occur on positive edge. |
| rst_n          | Input     | 1     | logic | Active low asynchronous reset. When asserted (0), clears all internal state and outputs. |
| data_stream_a  | Input     | 64    | logic | First data stream to be monitored. Can change every clock cycle. |
| data_stream_b  | Input     | 64    | logic | Second data stream to be monitored. Can change every clock cycle. |
| mode_select    | Input     | 1     | logic | Mode selection control:<br>0 = Full adjustment mode<br>1 = Mask-based mode |
| pattern_mask   | Input     | 32    | logic | Bit mask for mask-based mode comparison. Each bit enables/disables comparison of corresponding pattern bit. Only used when mode_select = 1. |
| pattern_match  | Output    | 1     | logic | Pattern match indicator. Asserted (1) when a pattern match is detected according to active mode. Registered output (1-3 cycle latency). |

**Timing Specifications:**
- Setup time: 1ns before rising edge of clk
- Hold time: 1ns after rising edge of clk  
- Clock-to-output delay: Maximum 3.125ns (@ 160 MHz)
- Reset assertion time: Minimum 2 clock cycles recommended
- Pattern detection latency: 1-3 clock cycles after input change

---

## Verification Block Diagram

```
┌───────────────────────────────────────────────────────────────────────────┐
│                              tb_top (Module)                               │
│                                                                            │
│  ┌──────────────────┐                    ┌─────────────────────────┐    │
│  │  Clock Generator │                    │   pattern_detector      │    │
│  │   (160 MHz)      │───> clk           │        (DUT)            │    │
│  └──────────────────┘                    │                         │    │
│                                          │   RTL Implementation    │    │
│  ┌──────────────────────────────────────┐│                         │    │
│  │   pattern_detector_if (Interface)    ││  - Window Extraction    │    │
│  │                                       ││  - Comparison Logic     │    │
│  │  • Clocking blocks (driver_cb,       ││  - Mode Selection       │    │
│  │    monitor_cb)                        ││  - Output Register      │    │
│  │  • Modports (DRV, MON)               ││                         │    │
│  │  • Signal declarations                │└─────────────────────────┘    │
│  │                                       │            ▲                   │
│  └───────────────┬───────────────────────┘            │                   │
│                  │                                    │                   │
│         ┌────────┴─────────┐                         │                   │
│         │                  │                         │                   │
│         ▼                  ▼                         │                   │
│  ┌─────────────┐    ┌─────────────┐                │                   │
│  │   Driver    │    │   Monitor   │                │                   │
│  │             │    │             │────────────────┘                   │
│  └─────────────┘    └─────────────┘                                    │
│                                                                          │
└───────────────────────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────────────────────┐
│                    UVM Test Environment Hierarchy                         │
│                                                                            │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │                    pattern_detector_test                          │   │
│  │                                                                    │   │
│  │  • Configures environment                                         │   │
│  │  • Starts sequences                                               │   │
│  │  • Controls test flow                                             │   │
│  └────────────────────────────┬───────────────────────────────────────┘   │
│                               │                                           │
│                               ▼                                           │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │                    pattern_detector_env                           │   │
│  │                                                                    │   │
│  │  ┌───────────────────────────────────────────────────────────┐  │   │
│  │  │           pattern_detector_agent                          │  │   │
│  │  │                                                            │  │   │
│  │  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │  │   │
│  │  │  │   Driver     │  │  Sequencer   │  │   Monitor    │   │  │   │
│  │  │  │              │  │              │  │              │   │  │   │
│  │  │  │ • Gets items │  │ • Controls   │  │ • Observes   │   │  │   │
│  │  │  │   from       │◄─┤   sequence   │  │   DUT signals│   │  │   │
│  │  │  │   sequencer  │  │   execution  │  │ • Broadcasts │   │  │   │
│  │  │  │ • Drives to  │  │ • Manages    │  │   via AP     │   │  │   │
│  │  │  │   DUT via IF │  │   seq_items  │  │              │   │  │   │
│  │  │  └──────────────┘  └──────────────┘  └──────┬───────┘   │  │   │
│  │  │                                              │            │  │   │
│  │  └──────────────────────────────────────────────┼───────────┘  │   │
│  │                                                  │               │   │
│  │                                                  │               │   │
│  │  ┌───────────────────────────────────────────────┼──────────┐  │   │
│  │  │         pattern_detector_scoreboard           ▼          │  │   │
│  │  │                                                           │  │   │
│  │  │  • Receives transactions from monitor                    │  │   │
│  │  │  • Runs reference model                                  │  │   │
│  │  │  • Compares DUT output with expected result              │  │   │
│  │  │  • Reports pass/fail status                              │  │   │
│  │  │  • Tracks match/mismatch count                           │  │   │
│  │  └───────────────────────────────────────────────────────────┘  │   │
│  │                                                  │               │   │
│  │  ┌───────────────────────────────────────────────┼──────────┐  │   │
│  │  │         pattern_detector_coverage             ▼          │  │   │
│  │  │                                                           │  │   │
│  │  │  • Subscribes to monitor transactions                    │  │   │
│  │  │  • Collects functional coverage                          │  │   │
│  │  │  • Samples covergroups                                   │  │   │
│  │  │  • Reports coverage statistics                           │  │   │
│  │  └───────────────────────────────────────────────────────────┘  │   │
│  │                                                                  │   │
│  └──────────────────────────────────────────────────────────────────┘   │
│                                                                          │
└───────────────────────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────────────────────┐
│                         Sequence Layer                                     │
│                                                                            │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │             pattern_detector_base_seq (Base Class)               │   │
│  │                                                                   │   │
│  │  • Defines common sequence infrastructure                        │   │
│  │  • Manages objections (pre_body/post_body)                       │   │
│  │  • Base class for all test sequences                             │   │
│  └────────┬─────────────────────────────────────────────────────────┘   │
│           │                                                               │
│           ├─> basic_match_seq                                            │
│           ├─> no_match_seq                                               │
│           ├─> first_window_match_seq                                     │
│           ├─> last_window_match_seq                                      │
│           ├─> multiple_matches_seq                                       │
│           ├─> full_mask_seq                                              │
│           ├─> zero_mask_seq                                              │
│           ├─> reset_test_seq                                             │
│           └─> random_seq                                                 │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────┘
```

**Component Descriptions:**

1. **tb_top**: Top-level module instantiating DUT, interface, and UVM environment
2. **pattern_detector_if**: SystemVerilog interface with clocking blocks for synchronization
3. **pattern_detector_agent**: Encapsulates driver, sequencer, and monitor
4. **pattern_detector_driver**: Drives stimulus from sequences to DUT
5. **pattern_detector_monitor**: Observes DUT signals and broadcasts transactions
6. **pattern_detector_sequencer**: Coordinates sequence execution
7. **pattern_detector_scoreboard**: Implements reference model and checking
8. **pattern_detector_coverage**: Collects functional coverage metrics
9. **pattern_detector_sequences**: Library of test sequences for different scenarios

---

## Verification Checkers and Assertions

### Scoreboard Checks

The scoreboard implements a reference model that performs the following checks for each transaction:

#### 1. Pattern Match Algorithm Check
```
For i = 0 to 32 (windows in stream A):
  For j = 0 to 32 (windows in stream B):
    window_a = data_stream_a[i +: 32]
    window_b = data_stream_b[j +: 32]
    
    If mode_select == 0:  // Full Adjustment Mode
      If window_a == window_b:
        expected_match = 1
        
    Else:  // Mask-Based Mode
      If (window_a & pattern_mask) == (window_b & pattern_mask):
        expected_match = 1

Compare expected_match with DUT pattern_match output
Report mismatch if different
```

#### 2. Mode Selection Check
- Verify behavior changes correctly when mode_select toggles
- Ensure full comparison in mode 0
- Ensure masked comparison in mode 1

#### 3. Mask Application Check (Mask Mode)
- Verify only masked bits affect comparison
- Test with various mask patterns (all 0s, all 1s, sparse, continuous)
- Confirm mask has no effect in Full Adjustment Mode

#### 4. Reset Behavior Check
- Verify pattern_match clears to 0 during reset
- Verify proper operation after reset de-assertion
- Check no false positives immediately after reset

### SystemVerilog Assertions (SVA)

The following assertions should be added to the interface or testbench:

#### 1. Reset Assertions
```systemverilog
// pattern_match must be 0 when reset is asserted
property p_reset_clears_output;
  @(posedge clk) !rst_n |-> !pattern_match;
endproperty
assert property (p_reset_clears_output) 
  else $error("pattern_match not cleared during reset");
```

#### 2. Stability Assertions
```systemverilog
// Output should be stable when inputs are stable
property p_stable_inputs_stable_output;
  @(posedge clk) disable iff (!rst_n)
  $stable(data_stream_a) && $stable(data_stream_b) && 
  $stable(mode_select) && $stable(pattern_mask)
  |=> $stable(pattern_match);
endproperty
assert property (p_stable_inputs_stable_output)
  else $warning("Output changed despite stable inputs");
```

#### 3. Latency Assertions
```systemverilog
// Pattern detection should complete within 3 cycles
property p_detection_latency;
  @(posedge clk) disable iff (!rst_n)
  $changed(data_stream_a) || $changed(data_stream_b)
  |-> ##[1:3] $stable(pattern_match);
endproperty
assert property (p_detection_latency)
  else $error("Pattern detection latency exceeded 3 cycles");
```

### Scoreboard Statistics Tracking

The scoreboard maintains the following counters:
- **total_transactions**: Total number of transactions checked
- **match_count**: Number of transactions where DUT matched expected
- **mismatch_count**: Number of mismatches (errors)
- **pass_rate**: Calculated as (match_count / total_transactions) × 100%

### Error Reporting

Mismatches are reported with full transaction details:
```
ERROR: Expected=1, Got=0
  mode=0, stream_a=0x123456789ABCDEF0, 
  stream_b=0x123456789ABCDEF0, mask=0xFFFFFFFF
```

---

## Waves

### Waveform Configuration

Waveforms are automatically generated during simulation and saved to:
- **VCD Format**: `pattern_detector.vcd` (for GTKWave, etc.)
- **WLF Format**: `vsim.wlf` (for QuestaSim)

### Key Signals to Monitor

#### Top-Level Signals
| Signal | Description | Watch For |
|--------|-------------|-----------|
| clk | System clock (160 MHz) | Regular toggling |
| rst_n | Active-low reset | Assertion/de-assertion |
| data_stream_a[63:0] | First data stream | Pattern changes |
| data_stream_b[63:0] | Second data stream | Pattern changes |
| mode_select | Mode control | Mode transitions |
| pattern_mask[31:0] | Comparison mask | Mask patterns |
| pattern_match | Match output | Assert/de-assert timing |

#### Internal Signals (for debugging)
| Signal | Description | Purpose |
|--------|-------------|---------|
| window_a[31:0] | Extracted window from stream A | Verify extraction |
| window_b[31:0] | Extracted window from stream B | Verify extraction |
| window_match | Intermediate match signal | Debug comparison |
| match_found | Internal match detection | Verify logic |

### Recommended Waveform Views

#### View 1: Full Transaction
- All input signals
- Output signal
- Clock and reset
- 10-20 clock cycle window

#### View 2: Pattern Match Detection
- data_stream_a and data_stream_b (in hex)
- pattern_match
- Internal match signals
- Zoom to match transition

#### View 3: Mode Comparison
- mode_select
- pattern_mask
- pattern_match
- Split view showing both modes

#### View 4: Reset Behavior
- rst_n
- All outputs
- Internal state signals
- Focus on reset assertion/de-assertion

### Waveform Analysis Checklist

✅ Verify pattern_match timing (1-3 cycle latency)  
✅ Check reset clears all outputs  
✅ Confirm mode_select affects behavior  
✅ Validate mask application in mask mode  
✅ Look for glitches or metastability  
✅ Verify no false positives  
✅ Check boundary conditions (first/last windows)  

---

## Test List

| Test ID | Test Name | Mode | Description / Steps | Expected Result | Priority | Status |
|---------|-----------|------|---------------------|-----------------|----------|--------|
| **1.1** | **PD_Full_BasicMatch_test** | Full | Generate two streams with one identical 32-bit window at random positions. Run 10 iterations with different random patterns. | pattern_match = 1 for all iterations | High | ✅ Implemented |
| **1.2** | **PD_Full_NoMatch_test** | Full | Generate two completely different streams where no 32-bit windows match. Ensure streams are constrained to be different. Run 10 iterations. | pattern_match = 0 for all iterations | High | ✅ Implemented |
| **1.3** | **PD_Full_FirstWindowMatch_test** | Full | Place identical pattern in bits [31:0] of both streams. Upper bits randomized. Run 10 iterations. | pattern_match = 1 (first window match detected) | Medium | ✅ Implemented |
| **1.4** | **PD_Full_LastWindowMatch_test** | Full | Place identical pattern in bits [63:32] of both streams. Lower bits randomized. Run 10 iterations. | pattern_match = 1 (last window match detected) | Medium | ✅ Implemented |
| **1.5** | **PD_Full_MultipleMatches_test** | Full | Set data_stream_a == data_stream_b (identical streams). This creates multiple matching windows. Run 10 iterations. | pattern_match = 1 (multiple matches detected) | High | ✅ Implemented |
| **2.1** | **PD_Mask_FullMask_test** | Mask | Set pattern_mask = 32'hFFFFFFFF (all bits enabled). Place matching pattern in both streams. Should behave identically to Full Mode. Run 10 iterations. | pattern_match = 1 (same as Full Mode) | High | ✅ Implemented |
| **2.2** | **PD_Mask_ZeroMask_test** | Mask | Set pattern_mask = 32'h00000000 (no bits compared). Streams can be random. With zero mask, all patterns match. Run 10 iterations. | pattern_match = 1 (all match with zero mask) | High | ✅ Implemented |
| **2.3** | **PD_Mask_PartialMask_test** | Mask | Test various partial masks: single-bit (0x00000001), continuous (0x0000FFFF, 0xFFFF0000), sparse (0xAA55AA55). Verify only masked bits affect comparison. | pattern_match varies based on masked bits | Medium | 📝 To Add |
| **0.1** | **PD_ResetFunctionality_test** | N/A | Assert reset (rst_n = 0) during operation. Verify pattern_match clears to 0. De-assert reset. Send transactions. Verify proper operation resumes. | pattern_match = 0 during reset, proper operation after | High | ✅ Implemented |
| **3.1** | **PD_ModeTransition_test** | Both | Toggle mode_select during operation. Verify behavior changes appropriately. Test transitions: 0→1 and 1→0. | Correct behavior in each mode | Medium | 📝 To Add |
| **3.2** | **PD_Random_test** | Both | Generate 100 random transactions with random modes, masks, and streams. Verify all results via scoreboard. Maximum coverage collection. | All transactions pass scoreboard check | High | ✅ Implemented |
| **4.1** | **PD_BoundaryPattern_test** | Full | Test patterns at stream boundaries: all zeros (0x0000000000000000), all ones (0xFFFFFFFFFFFFFFFF), alternating (0xAAAAAAAAAAAAAAAA, 0x5555555555555555). | Correct detection of boundary patterns | Low | 📝 To Add |
| **4.2** | **PD_OverlappingWindows_test** | Full | Create streams where patterns overlap across window boundaries. Example: pattern spans bits [20:51]. | Correct detection of overlapping patterns | Medium | 📝 To Add |
| **5.1** | **PD_StressTest** | Both | Rapid input changes every cycle for 1000 cycles. Mix of modes. Verify no missed detections or false positives. | All detections correct, no errors | Medium | 📝 To Add |

### Test Execution Order

**Phase 1 - Sanity Tests** (Run First):
1. PD_ResetFunctionality_test (0.1)
2. PD_Full_BasicMatch_test (1.1)
3. PD_Full_NoMatch_test (1.2)

**Phase 2 - Directed Tests** (Core Functionality):
4. PD_Full_FirstWindowMatch_test (1.3)
5. PD_Full_LastWindowMatch_test (1.4)
6. PD_Full_MultipleMatches_test (1.5)
7. PD_Mask_FullMask_test (2.1)
8. PD_Mask_ZeroMask_test (2.2)

**Phase 3 - Random & Corner Cases**:
9. PD_Random_test (3.2)
10. PD_Mask_PartialMask_test (2.3) [To Add]
11. PD_ModeTransition_test (3.1) [To Add]

**Phase 4 - Advanced Tests** (Optional):
12. PD_BoundaryPattern_test (4.1) [To Add]
13. PD_OverlappingWindows_test (4.2) [To Add]
14. PD_StressTest (5.1) [To Add]

### Test Success Criteria

Each test passes if:
✅ Scoreboard reports 0 mismatches  
✅ All transactions checked by reference model  
✅ No UVM errors or fatal messages  
✅ Expected coverage bins hit (per test)  
✅ Simulation completes without timeout  

---

## Coverage Plan

### Functional Coverage Goals

**Overall Target**: 95% functional coverage minimum

### Coverage Items

| Coverage Item | Bins | Sample Time | Description / Comment | Priority |
|---------------|------|-------------|----------------------|----------|
| **cp_mode** | {0, 1} | Every clock cycle | Coverage of both operation modes: Full (0) / Mask (1) | **High** |
| **cp_match_result** | {match=1, no_match=0} | Every clock cycle | Distribution of pattern_match output values | **High** |
| **cx_mode_match** | All combinations (mode × match) | On result update | Cross coverage ensuring no holes:<br>• Full + Match<br>• Full + No Match<br>• Mask + Match<br>• Mask + No Match | **High** |
| **cp_pattern_types_a** | {all_zeros, all_ones, alternating1=0xAAAAAAAA, alternating2=0x55555555, others} | On receiving data_stream_a | Coverage of pattern types in stream A lower 32 bits | **Medium** |
| **cp_pattern_types_b** | {all_zeros, all_ones, alternating1=0xAAAAAAAA, alternating2=0x55555555, others} | On receiving data_stream_b | Coverage of pattern types in stream B lower 32 bits | **Medium** |
| **cp_stream_equality** | {equal=1, different=0} | Every clock cycle | Tracks if lower 32 bits of streams are equal (potential match) | **Medium** |
| **cp_mask_patterns** | {all_zeros=0x00000000, all_ones=0xFFFFFFFF, single_bit[], continuous_low=0x0000FFFF, continuous_high=0xFFFF0000, sparse[], others} | During mode=1 | Ensures all mask types are covered during mask-based mode:<br>• All zeros<br>• All ones<br>• Single bits (8 bins)<br>• Continuous patterns<br>• Sparse patterns<br>• Random others | **High** |
| **cp_boundary_a_low** | Full range [0:0xFFFFFFFF] | Every clock cycle | Coverage of lower 32 bits of stream A (boundary window) | **Low** |
| **cp_boundary_a_high** | Full range [0:0xFFFFFFFF] | Every clock cycle | Coverage of upper 32 bits of stream A (boundary window) | **Low** |
| **cp_boundary_b_low** | Full range [0:0xFFFFFFFF] | Every clock cycle | Coverage of lower 32 bits of stream B (boundary window) | **Low** |
| **cp_boundary_b_high** | Full range [0:0xFFFFFFFF] | Every clock cycle | Coverage of upper 32 bits of stream B (boundary window) | **Low** |

### Additional Coverage Items (To Be Implemented)

| Coverage Item | Bins | Description | Priority |
|---------------|------|-------------|----------|
| **cp_window_index_a** | {0..32} (33 bins) | Tracks which window positions in stream A contain matches | **High** |
| **cp_window_index_b** | {0..32} (33 bins) | Tracks which window positions in stream B contain matches | **High** |
| **cx_window_alignment** | 33×33 = 1089 combinations | Cross coverage of all possible window alignment pairs. This is the most comprehensive metric from spec. | **Critical** |
| **cp_mode_transitions** | {0→1, 1→0, stable_0, stable_1} | Tracks mode_select transitions and stability | **Medium** |
| **cx_transition_match** | mode_transitions × match_result | Cross coverage of mode transitions with match results | **Medium** |
| **cp_reset_behavior** | {assert, deassert} | Tracks reset signal changes | **High** |
| **cx_reset_match** | {match_after_reset, no_match_after_reset} | Pattern match behavior immediately after reset | **High** |
| **cp_mask_bit_count** | {0_bits, 1-8_bits, 9-16_bits, 17-24_bits, 25-31_bits, 32_bits} | Number of enabled bits in pattern_mask | **Low** |
| **cp_consecutive_matches** | {single, multiple} | Whether multiple transactions in a row show pattern_match=1 | **Low** |

### Coverage Collection Strategy

#### Automatic Coverage
- Covergroups sampled automatically by monitor on every transaction
- Mode and match result tracked continuously
- Pattern types sampled on input changes

#### Manual Coverage Points
- Window alignment tracking requires additional logic to identify specific matching windows
- Reset behavior tracked via dedicated sequences
- Mode transition coverage requires state tracking

#### Coverage Reporting
- Coverage reported at end of each test
- Overall coverage reported in final test summary
- Detailed coverage reports generated using simulator tools (QuestaSim coverage report)

### Coverage Analysis

#### Per-Test Expected Coverage

| Test Name | Expected Coverage Contribution |
|-----------|-------------------------------|
| basic_match_test | Mode=0, Match=1, various patterns |
| no_match_test | Mode=0, Match=0 |
| first_window_match_test | Mode=0, Match=1, boundary coverage |
| last_window_match_test | Mode=0, Match=1, boundary coverage |
| multiple_matches_test | Mode=0, Match=1, multiple windows |
| full_mask_test | Mode=1, Mask=all_ones, Match=1 |
| zero_mask_test | Mode=1, Mask=all_zeros, Match=1 |
| reset_test | Reset behavior, both modes |
| random_test | Maximum coverage across all categories |

#### Coverage Closure Plan

To achieve 95% coverage:
1. Run all directed tests (Phase 1-2)
2. Run random test with sufficient iterations (minimum 100 transactions)
3. Analyze coverage holes using coverage report
4. Add directed tests for uncovered bins
5. Increase random test iterations if needed
6. Target specific window alignments if cx_window_alignment not covered

---

## Coverage Result

### Current Status

**Status**: 🟡 In Progress

**Tests Completed**: 9 / 14 tests implemented

**Coverage Achieved**: *To be measured after simulation runs*

### Coverage Goals vs Actual

| Coverage Category | Goal | Actual | Status |
|------------------|------|--------|--------|
| Mode Coverage | 100% | TBD | 🔄 Pending |
| Match Result Coverage | 100% | TBD | 🔄 Pending |
| Mode × Match Cross | 100% | TBD | 🔄 Pending |
| Pattern Types | 90% | TBD | 🔄 Pending |
| Mask Patterns | 90% | TBD | 🔄 Pending |
| Boundary Coverage | 50% | TBD | 🔄 Pending |
| Window Alignment | 70% | TBD | 🔄 Pending |
| **Overall Functional** | **95%** | **TBD** | 🔄 **Pending** |

### Code Coverage (To Be Measured)

| Metric | Goal | Actual | Status |
|--------|------|--------|--------|
| Line Coverage | 100% | TBD | 🔄 Pending |
| Branch Coverage | 95% | TBD | 🔄 Pending |
| Toggle Coverage | 90% | TBD | 🔄 Pending |
| FSM Coverage | 100% | TBD | 🔄 Pending |

### Coverage Improvement Actions

**Identified Gaps** (to be filled after first run):
- [ ] Add partial mask test (Test 2.3)
- [ ] Add mode transition test (Test 3.1)
- [ ] Add boundary pattern test (Test 4.1)
- [ ] Add overlapping windows test (Test 4.2)
- [ ] Add stress test (Test 5.1)
- [ ] Increase random test iterations if needed
- [ ] Add window alignment tracking logic

**Next Steps**:
1. Run regression with all implemented tests
2. Generate coverage reports
3. Identify uncovered bins and corners
4. Implement additional tests as needed
5. Re-run and measure coverage improvement
6. Iterate until 95% goal achieved

---

## Disclaimers

### Verification Scope

**In Scope**:
✅ Functional verification of pattern detection algorithm  
✅ Both operation modes (Full Adjustment and Mask-Based)  
✅ All window alignment combinations (33×33)  
✅ Reset behavior and basic timing  
✅ Mode selection and mask application  
✅ Pattern match output correctness  

**Out of Scope**:
❌ Timing analysis and setup/hold violations (Static Timing Analysis required)  
❌ Power analysis and consumption  
❌ Gate-level simulation and synthesis verification  
❌ Physical design verification (DRC, LVS)  
❌ Performance optimization beyond specification  
❌ Clock domain crossing (single clock domain assumed)  
❌ DFT (Design for Test) features  

### Assumptions

1. **Clock**: 160 MHz clock is clean and stable (no jitter modeling)
2. **Reset**: Reset assertion time sufficient (minimum 2 cycles assumed)
3. **Inputs**: All inputs assumed synchronous to clock (no metastability)
4. **Timing**: Setup/hold times met by external logic
5. **Pattern Latency**: 1-3 cycle latency acceptable per specification
6. **Single Clock Domain**: No CDC (Clock Domain Crossing) verification needed

### Known Limitations

1. **Window Alignment Coverage**: Full 33×33 = 1089 alignment coverage requires significant simulation time. May be sampled rather than exhaustive.

2. **Reference Model Performance**: Reference model runs same algorithm as DUT, so algorithmic bugs may not be caught. Validated against specification examples.

3. **Corner Cases**: Some rare corner cases may require additional directed tests beyond current test plan.

4. **Waveform Storage**: Full waveform dumps for long simulations may require significant disk space.

### Dependencies

**External Dependencies**:
- QuestaSim/ModelSim with UVM 1.2 library
- SystemVerilog compiler supporting IEEE 1800-2017
- Sufficient simulation license seats
- Disk space for waveforms and coverage databases

**Internal Dependencies**:
- Final RTL specification (version 1.0)
- Synthesis constraints for timing verification (if applicable)
- Integration test plan (for system-level testing)

---

## Open Issues / TODO List

### High Priority

- [ ] **Issue #1**: Implement window alignment cross coverage (33×33 bins)
  - **Status**: Not started
  - **Owner**: Verification team
  - **ETA**: Week 2

- [ ] **Issue #2**: Add partial mask test (Test 2.3)
  - **Status**: Not started
  - **Owner**: שולמית קרליבך
  - **ETA**: Week 1

- [ ] **Issue #3**: Add mode transition test (Test 3.1)
  - **Status**: Not started
  - **Owner**: מלכה רכניצר
  - **ETA**: Week 1

- [ ] **Issue #4**: Implement SVA assertions in interface
  - **Status**: Not started
  - **Owner**: רחלי אוסטרוב
  - **ETA**: Week 2

### Medium Priority

- [ ] **Issue #5**: Add boundary pattern test (Test 4.1)
  - **Status**: Not started
  - **Owner**: שולמית קרליבך
  - **ETA**: Week 3

- [ ] **Issue #6**: Add overlapping windows test (Test 4.2)
  - **Status**: Not started
  - **Owner**: מלכה רכניצר
  - **ETA**: Week 3

- [ ] **Issue #7**: Implement stress test (Test 5.1)
  - **Status**: Not started
  - **Owner**: רחלי אוסטרוב
  - **ETA**: Week 3

- [ ] **Issue #8**: Add window position tracking in coverage
  - **Status**: Not started
  - **Owner**: Verification team
  - **ETA**: Week 2

### Low Priority

- [ ] **Issue #9**: Optimize random test for faster coverage closure
  - **Status**: Not started
  - **Owner**: Verification team
  - **ETA**: Week 4

- [ ] **Issue #10**: Create regression script for nightly runs
  - **Status**: Not started
  - **Owner**: Verification team
  - **ETA**: Week 4

- [ ] **Issue #11**: Add performance profiling for simulation time
  - **Status**: Not started
  - **Owner**: Verification team
  - **ETA**: Week 4

### Completed Items

- [x] **Task #1**: Create UVM testbench infrastructure
  - **Completed**: Dec 4, 2025
  - **Owner**: GitHub Copilot

- [x] **Task #2**: Implement RTL DUT
  - **Completed**: Dec 4, 2025
  - **Owner**: GitHub Copilot

- [x] **Task #3**: Create interface with clocking blocks
  - **Completed**: Dec 4, 2025
  - **Owner**: GitHub Copilot

- [x] **Task #4**: Implement sequence item and sequencer
  - **Completed**: Dec 4, 2025
  - **Owner**: GitHub Copilot

- [x] **Task #5**: Implement driver and monitor
  - **Completed**: Dec 4, 2025
  - **Owner**: GitHub Copilot

- [x] **Task #6**: Implement agent and environment
  - **Completed**: Dec 4, 2025
  - **Owner**: GitHub Copilot

- [x] **Task #7**: Implement scoreboard with reference model
  - **Completed**: Dec 4, 2025
  - **Owner**: GitHub Copilot

- [x] **Task #8**: Implement coverage collector
  - **Completed**: Dec 4, 2025
  - **Owner**: GitHub Copilot

- [x] **Task #9**: Create all basic test sequences
  - **Completed**: Dec 4, 2025
  - **Owner**: GitHub Copilot

- [x] **Task #10**: Create test classes for all 9 base tests
  - **Completed**: Dec 4, 2025
  - **Owner**: GitHub Copilot

- [x] **Task #11**: Create simulation scripts (Makefile and batch)
  - **Completed**: Dec 4, 2025
  - **Owner**: GitHub Copilot

- [x] **Task #12**: Create comprehensive documentation
  - **Completed**: Dec 4, 2025
  - **Owner**: GitHub Copilot

### Questions / Clarifications Needed

1. **Q1**: Should we verify timing paths for critical frequency targets?
   - **Status**: Open
   - **Impact**: May require additional timing verification

2. **Q2**: Is there a specific coverage database format required for integration?
   - **Status**: Open
   - **Impact**: May need to adjust coverage collection methodology

3. **Q3**: Should we add constrained random coverage for all 1089 window alignments?
   - **Status**: Open
   - **Impact**: Significant simulation time increase

### Future Enhancements

- [ ] Add UVM RAL (Register Abstraction Layer) if block becomes part of larger system
- [ ] Create constrained random coverage optimizer
- [ ] Add performance benchmarking framework
- [ ] Create automated regression dashboard
- [ ] Add power-aware verification (UPF)
- [ ] Create formal verification properties

---

## Appendix A: File Structure

```
copilot-practicum/
├── rtl/
│   └── pattern_detector.sv              # DUT implementation
├── tb/
│   ├── pattern_detector_if.sv           # Interface
│   ├── pattern_detector_seq_item.sv     # Transaction
│   ├── pattern_detector_sequencer.sv    # Sequencer
│   ├── pattern_detector_driver.sv       # Driver
│   ├── pattern_detector_monitor.sv      # Monitor
│   ├── pattern_detector_agent.sv        # Agent
│   ├── pattern_detector_scoreboard.sv   # Scoreboard
│   ├── pattern_detector_coverage.sv     # Coverage
│   ├── pattern_detector_env.sv          # Environment
│   ├── pattern_detector_config.sv       # Config
│   ├── pattern_detector_sequences.sv    # Sequences
│   ├── pattern_detector_pkg.sv          # Package
│   └── tb_top.sv                        # Top module
├── tests/
│   └── pattern_detector_tests.sv        # Test classes
├── sim/
│   ├── Makefile                         # Compilation script
│   └── run_sim.bat                      # Windows script
├── docs/
│   ├── README.md                        # Main documentation
│   ├── QUICKSTART.md                    # Quick start guide
│   ├── PROJECT_STRUCTURE.md             # Structure details
│   ├── SUMMARY.md                       # Project summary
│   └── VPLAN_COMPLETE.md                # This document
└── spec/
    ├── PATTERN DETECTOR SPEC.docx       # RTL specification
    └── VPLAN (1).docx                   # Original VPlan
```

---

## Appendix B: Running Tests

### Quick Commands

```bash
# Run single test
make simulate TEST=basic_match_test

# Run all tests
make run_all_tests

# Run with coverage
make coverage

# Clean
make clean
```

### Test Names Reference

- `basic_match_test`
- `no_match_test`
- `first_window_match_test`
- `last_window_match_test`
- `multiple_matches_test`
- `full_mask_test`
- `zero_mask_test`
- `reset_test`
- `random_test`

---

## Revision History

| Version | Date | Author | Description |
|---------|------|--------|-------------|
| 1.0 | Dec 4, 2025 | Verification Team | Initial VPlan - Complete UVM environment implementation |
| 0.1 | Dec 1, 2025 | שולמית, מלכה, רחלי | Original VPlan draft |

---

**End of Verification Plan**
