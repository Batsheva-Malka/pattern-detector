
// `timescale 1ns/1ps

module pattern_detector (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [63:0] data_stream_a,
    input  logic [63:0] data_stream_b,
    input  logic        mode_select,      // 0 = full, 1 = mask
    input  logic [31:0] pattern_mask,
    output logic        pattern_match
);

    logic match_found;

    // Sliding windows (no dynamic slicing!)
    logic [31:0] win_a;
    logic [31:0] win_b;

    logic compare_ok;

    always_comb begin
        match_found = 1'b0;

        for (int i = 0; i < 33; i++) begin
            // SHIFT instead of slice
            win_a = (data_stream_a >> i) & 32'hFFFF_FFFF;

            for (int j = 0; j < 33; j++) begin
                win_b = (data_stream_b >> j) & 32'hFFFF_FFFF;

                if (mode_select == 1'b0)
                    compare_ok = (win_a == win_b);
                else
                    compare_ok = ((win_a & pattern_mask) == (win_b & pattern_mask));

                if (compare_ok)
                    match_found = 1'b1;
            end
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            pattern_match <= 1'b0;
        else
            pattern_match <= match_found;
    end

endmodule