// Pattern Detector Testbench Top Module
// Pattern Detector Testbench Top Module
// Instantiates DUT, interface, generates clock, and runs UVM test

module tb_top;
    
    import uvm_pkg::*;
    import pattern_detector_pkg::*;
    `include "uvm_macros.svh"
    // Clock generation
    logic clk;
    initial begin
        clk = 0;
        forever #3.125ns clk = ~clk; // 160 MHz (6.25ns period)
    end
    
    // Interface instantiation
    pattern_detector_if vif(clk);
    
    // DUT instantiation
    pattern_detector dut (
        .clk(vif.clk),
        .rst_n(vif.rst_n),
        .data_stream_a(vif.data_stream_a),
        .data_stream_b(vif.data_stream_b),
        .mode_select(vif.mode_select),
        .pattern_mask(vif.pattern_mask),
        .pattern_match(vif.pattern_match)
    );
    
    // Initial block for UVM
    initial begin
        // Set virtual interface in config DB
        uvm_config_db#(virtual pattern_detector_if)::set(null, "*", "vif", vif);
        
        // Enable waveform dumping
        $dumpfile("pattern_detector.vcd");
        $dumpvars(0, tb_top);
        
        // Run the test
        run_test();
    end
    
    // Timeout watchdog (optional)
    initial begin
        #1ms;
        `uvm_fatal("TIMEOUT", "Test timed out after 1ms")
    end
    
endmodule
