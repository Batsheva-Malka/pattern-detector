// Pattern Detector Block
// Monitors two 64-bit data streams and detects matching 32-bit patterns
// Operates at 160 MHz with two modes: Full Adjustment and Mask-Based

module pattern_detector (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [63:0] data_stream_a,
    input  logic [63:0] data_stream_b,
    input  logic        mode_select,      // 0 = Full Adjustment, 1 = Mask-Based
    input  logic [31:0] pattern_mask,
    output logic        pattern_match
);

    logic match_found;
    
    always_comb begin
        match_found = 1'b0;
        
        // Check all possible 32-bit windows in both streams
        // 33 positions in each 64-bit stream (0 to 32)
        for (int i = 0; i <= 32; i++) begin
            for (int j = 0; j <= 32; j++) begin
                logic [31:0] window_a, window_b;
                logic window_match;
                
                // Extract 32-bit windows
                window_a = data_stream_a[i +: 32];
                window_b = data_stream_b[j +: 32];
                
                // Compare based on mode
                if (mode_select == 1'b0) begin
                    // Full Adjustment Mode: compare all bits
                    window_match = (window_a == window_b);
                end else begin
                    // Mask-Based Mode: compare only masked bits
                    window_match = ((window_a & pattern_mask) == (window_b & pattern_mask));
                end
                
                if (window_match) begin
                    match_found = 1'b1;
                end
            end
        end
    end
    
    // Register the output
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pattern_match <= 1'b0;
        end else begin
            pattern_match <= match_found;
        end
    end

endmodule
