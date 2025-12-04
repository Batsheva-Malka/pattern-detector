// Pattern Detector UVM Package
// Includes all verification components

package pattern_detector_pkg;
    
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    // Include all verification components in order
    `include "pattern_detector_seq_item.sv"
    `include "pattern_detector_sequencer.sv"
    `include "pattern_detector_driver.sv"
    `include "pattern_detector_monitor.sv"
    `include "pattern_detector_scoreboard.sv"
    `include "pattern_detector_coverage.sv"
    `include "pattern_detector_agent.sv"
    `include "pattern_detector_config.sv"
    `include "pattern_detector_env.sv"
    `include "pattern_detector_sequences.sv"
    `include "../tests/pattern_detector_tests.sv"
    
endpackage
