// Pattern Detector Sequences
// Implements sequences for all test cases from VPlan

// Base sequence
class pattern_detector_base_seq extends uvm_sequence #(pattern_detector_seq_item);
    
    `uvm_object_utils(pattern_detector_base_seq)
    
    function new(string name = "pattern_detector_base_seq");
        super.new(name);
    endfunction
    
    // Reset task
    virtual task pre_body();
        if (starting_phase != null)
            starting_phase.raise_objection(this);
    endtask
    
    virtual task post_body();
        if (starting_phase != null)
            starting_phase.drop_objection(this);
    endtask
    
endclass

// Test 1.1: PD_Full_BasicMatch_test - One identical 32-bit window
class basic_match_seq extends pattern_detector_base_seq;
    
    `uvm_object_utils(basic_match_seq)
    
    function new(string name = "basic_match_seq");
        super.new(name);
    endfunction
    
    virtual task body();
        pattern_detector_seq_item item;
        bit [31:0] common_pattern;
        
        repeat(10) begin
            item = pattern_detector_seq_item::type_id::create("item");
            
            // Generate common pattern
            common_pattern = $urandom();
            
            // Place pattern in random positions in both streams
            start_item(item);
            assert(item.randomize() with {
                mode_select == 0; // Full adjustment mode
                data_stream_a[31:0] == common_pattern;
                data_stream_b[31:0] == common_pattern;
            });
            finish_item(item);
        end
    endtask
    
endclass

// Test 1.2: PD_Full_NoMatch_test - No identical window exists
class no_match_seq extends pattern_detector_base_seq;
    
    `uvm_object_utils(no_match_seq)
    
    function new(string name = "no_match_seq");
        super.new(name);
    endfunction
    
    virtual task body();
        pattern_detector_seq_item item;
        
        repeat(10) begin
            item = pattern_detector_seq_item::type_id::create("item");
            
            start_item(item);
            assert(item.randomize() with {
                mode_select == 0;
                // Ensure streams are completely different
                data_stream_a[31:0] != data_stream_b[63:32];
                data_stream_a[63:32] != data_stream_b[31:0];
                data_stream_a != data_stream_b;
            });
            finish_item(item);
        end
    endtask
    
endclass

// Test 1.3: PD_Full_FirstWindowMatch_test - Match in first window (bits 0-31)
class first_window_match_seq extends pattern_detector_base_seq;
    
    `uvm_object_utils(first_window_match_seq)
    
    function new(string name = "first_window_match_seq");
        super.new(name);
    endfunction
    
    virtual task body();
        pattern_detector_seq_item item;
        bit [31:0] common_pattern;
        
        repeat(10) begin
            item = pattern_detector_seq_item::type_id::create("item");
            common_pattern = $urandom();
            
            start_item(item);
            assert(item.randomize() with {
                mode_select == 0;
                data_stream_a[31:0] == common_pattern;
                data_stream_b[31:0] == common_pattern;
            });
            finish_item(item);
        end
    endtask
    
endclass

// Test 1.4: PD_Full_LastWindowMatch_test - Match in last window (bits 32-63)
class last_window_match_seq extends pattern_detector_base_seq;
    
    `uvm_object_utils(last_window_match_seq)
    
    function new(string name = "last_window_match_seq");
        super.new(name);
    endfunction
    
    virtual task body();
        pattern_detector_seq_item item;
        bit [31:0] common_pattern;
        
        repeat(10) begin
            item = pattern_detector_seq_item::type_id::create("item");
            common_pattern = $urandom();
            
            start_item(item);
            assert(item.randomize() with {
                mode_select == 0;
                data_stream_a[63:32] == common_pattern;
                data_stream_b[63:32] == common_pattern;
            });
            finish_item(item);
        end
    endtask
    
endclass

// Test 1.5: PD_Full_MultipleMatches_test - Multiple matching windows
class multiple_matches_seq extends pattern_detector_base_seq;
    
    `uvm_object_utils(multiple_matches_seq)
    
    function new(string name = "multiple_matches_seq");
        super.new(name);
    endfunction
    
    virtual task body();
        pattern_detector_seq_item item;
        
        repeat(10) begin
            item = pattern_detector_seq_item::type_id::create("item");
            
            start_item(item);
            assert(item.randomize() with {
                mode_select == 0;
                // Make both streams identical - guarantees multiple matches
                data_stream_a == data_stream_b;
            });
            finish_item(item);
        end
    endtask
    
endclass

// Test 2.1: PD_Mask_FullMask_test - mask = all 1's (same as Full Mode)
class full_mask_seq extends pattern_detector_base_seq;
    
    `uvm_object_utils(full_mask_seq)
    
    function new(string name = "full_mask_seq");
        super.new(name);
    endfunction
    
    virtual task body();
        pattern_detector_seq_item item;
        bit [31:0] common_pattern;
        
        repeat(10) begin
            item = pattern_detector_seq_item::type_id::create("item");
            common_pattern = $urandom();
            
            start_item(item);
            assert(item.randomize() with {
                mode_select == 1; // Mask mode
                pattern_mask == 32'hFFFFFFFF;
                data_stream_a[31:0] == common_pattern;
                data_stream_b[31:0] == common_pattern;
            });
            finish_item(item);
        end
    endtask
    
endclass

// Test 2.2: PD_Mask_ZeroMask_test - No bits are compared (mask = 0)
class zero_mask_seq extends pattern_detector_base_seq;
    
    `uvm_object_utils(zero_mask_seq)
    
    function new(string name = "zero_mask_seq");
        super.new(name);
    endfunction
    
    virtual task body();
        pattern_detector_seq_item item;
        
        repeat(10) begin
            item = pattern_detector_seq_item::type_id::create("item");
            
            start_item(item);
            assert(item.randomize() with {
                mode_select == 1;
                pattern_mask == 32'h00000000;
            });
            finish_item(item);
        end
    endtask
    
endclass

// Test 0.1: PD_ResetFunctionality_test - Reset behavior
class reset_test_seq extends pattern_detector_base_seq;
    
    `uvm_object_utils(reset_test_seq)
    
    function new(string name = "reset_test_seq");
        super.new(name);
    endfunction
    
    virtual task body();
        pattern_detector_seq_item item;
        
        // Send some transactions, then reset will be handled by test
        repeat(5) begin
            item = pattern_detector_seq_item::type_id::create("item");
            start_item(item);
            assert(item.randomize());
            finish_item(item);
        end
    endtask
    
endclass

// Random test sequence
class random_seq extends pattern_detector_base_seq;
    
    `uvm_object_utils(random_seq)
    
    function new(string name = "random_seq");
        super.new(name);
    endfunction
    
    virtual task body();
        pattern_detector_seq_item item;
        
        repeat(100) begin
            item = pattern_detector_seq_item::type_id::create("item");
            start_item(item);
            assert(item.randomize());
            finish_item(item);
        end
    endtask
    
endclass
