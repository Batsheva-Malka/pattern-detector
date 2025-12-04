// Pattern Detector Coverage Collector
// Implements all coverage items from VPlan

class pattern_detector_coverage extends uvm_subscriber #(pattern_detector_seq_item);
    
    `uvm_component_utils(pattern_detector_coverage)
    
    pattern_detector_seq_item item;
    
    // Coverage group implementing all VPlan coverage items
    covergroup cg_pattern_detector;
        
        // Mode coverage
        cp_mode: coverpoint item.mode_select {
            bins full_mode = {0};
            bins mask_mode = {1};
        }
        
        // Pattern match result
        cp_match_result: coverpoint item.pattern_match {
            bins match    = {1};
            bins no_match = {0};
        }
        
        // Mode × Match cross coverage
        cx_mode_match: cross cp_mode, cp_match_result;
        
        // Mask patterns (for mask-based mode)
        cp_mask_patterns: coverpoint item.pattern_mask iff (item.mode_select == 1) {
            bins all_zeros = {32'h00000000};
            bins all_ones  = {32'hFFFFFFFF};
            bins single_bit[] = {32'h00000001, 32'h00000002, 32'h00000004, 32'h00000008,
                                  32'h00000010, 32'h00000020, 32'h00000040, 32'h00000080};
            bins continuous_low  = {32'h0000FFFF};
            bins continuous_high = {32'hFFFF0000};
            bins sparse = {32'hAA55AA55, 32'h55AA55AA, 32'hF0F0F0F0, 32'h0F0F0F0F};
            bins others = default;
        }
        
        // Pattern types based on data streams
        cp_pattern_types_a: coverpoint item.data_stream_a[31:0] {
            bins all_zeros = {32'h00000000};
            bins all_ones  = {32'hFFFFFFFF};
            bins alternating1 = {32'hAAAAAAAA};
            bins alternating2 = {32'h55555555};
            bins others = default;
        }
        
        cp_pattern_types_b: coverpoint item.data_stream_b[31:0] {
            bins all_zeros = {32'h00000000};
            bins all_ones  = {32'hFFFFFFFF};
            bins alternating1 = {32'hAAAAAAAA};
            bins alternating2 = {32'h55555555};
            bins others = default;
        }
        
        // Equality of lower 32 bits (detecting potential matches)
        cp_stream_equality: coverpoint (item.data_stream_a[31:0] == item.data_stream_b[31:0]) {
            bins equal     = {1};
            bins different = {0};
        }
        
        // Boundary windows - checking if patterns appear at edges
        cp_boundary_a_low: coverpoint item.data_stream_a[31:0] {
            bins boundary = {[32'h00000000:32'hFFFFFFFF]};
        }
        
        cp_boundary_a_high: coverpoint item.data_stream_a[63:32] {
            bins boundary = {[32'h00000000:32'hFFFFFFFF]};
        }
        
        cp_boundary_b_low: coverpoint item.data_stream_b[31:0] {
            bins boundary = {[32'h00000000:32'hFFFFFFFF]};
        }
        
        cp_boundary_b_high: coverpoint item.data_stream_b[63:32] {
            bins boundary = {[32'h00000000:32'hFFFFFFFF]};
        }
        
        // Mode transitions (detected across consecutive samples)
        // Note: This requires maintaining previous mode state
        
    endgroup
    
    // Additional variables for tracking transitions
    bit prev_mode_valid = 0;
    bit prev_mode;
    
    // Constructor
    function new(string name = "pattern_detector_coverage", uvm_component parent = null);
        super.new(name, parent);
        cg_pattern_detector = new();
    endfunction
    
    // Write method - called when monitor broadcasts transaction
    virtual function void write(pattern_detector_seq_item t);
        item = t;
        cg_pattern_detector.sample();
        
        // Track mode transitions
        if (prev_mode_valid && (prev_mode != item.mode_select)) begin
            `uvm_info(get_type_name(), $sformatf("Mode transition detected: %0d -> %0d", prev_mode, item.mode_select), UVM_MEDIUM)
        end
        prev_mode = item.mode_select;
        prev_mode_valid = 1;
    endfunction
    
    // Report phase - display coverage statistics
    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info(get_type_name(), $sformatf("\n\n========== COVERAGE REPORT =========="), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Overall Coverage: %.2f%%", cg_pattern_detector.get_coverage()), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("=====================================\n"), UVM_LOW)
    endfunction
    
endclass
