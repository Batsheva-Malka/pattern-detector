// Pattern Detector Interface
// UVM interface with clocking blocks and modports

interface pattern_detector_if (input logic clk);
    
    logic        rst_n;
    logic [63:0] data_stream_a;
    logic [63:0] data_stream_b;
    logic        mode_select;
    logic [31:0] pattern_mask;
    logic        pattern_match;
    
    // Clocking block for driver
    clocking driver_cb @(posedge clk);
        default input #1step output #1ns;
        output rst_n;
        output data_stream_a;
        output data_stream_b;
        output mode_select;
        output pattern_mask;
        input  pattern_match;
    endclocking
    
    // Clocking block for monitor
    clocking monitor_cb @(posedge clk);
        default input #1step;
        input rst_n;
        input data_stream_a;
        input data_stream_b;
        input mode_select;
        input pattern_mask;
        input pattern_match;
    endclocking
    
    // Modports
    modport DRV (clocking driver_cb, input clk, output rst_n);
    modport MON (clocking monitor_cb, input clk);
    
endinterface
