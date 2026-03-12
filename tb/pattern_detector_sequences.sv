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


class basic_match_seq extends pattern_detector_base_seq;
    `uvm_object_utils(basic_match_seq)
    function new(string name = ""); super.new(name); endfunction

  virtual task body();
    pattern_detector_seq_item item;
    bit [31:0] special_data[] = '{32'hAAAAAAAA, 32'h55555555, 32'hFFFFFFFF, 32'h00000000};
    
    foreach (special_data[i]) begin
      //send 3 times to ensure stability in the monitor.
        repeat(3) begin
            item = pattern_detector_seq_item::type_id::create("item");
            start_item(item);
            assert(item.randomize() with {
                mode_select == 0;
                data_stream_a[31:0] == special_data[i];
                data_stream_b[31:0] == special_data[i];
            });
            finish_item(item);
        end
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


class full_mask_seq extends pattern_detector_base_seq;
    `uvm_object_utils(full_mask_seq)
    function new(string name = ""); super.new(name); endfunction
  virtual task body();
    pattern_detector_seq_item item;
    // closed list that targets all the bins
    bit [31:0] all_masks[] = '{
        32'h00000001, 32'h00000002, 32'h00000004, 32'h00000008, 
        32'h00000010, 32'h00000020, 32'h00000040, 32'h00000080, // Single bits 0-7
        32'h0000FFFF, 32'hFFFF0000,                             // Continuous low/high
        32'hAA55AA55, 32'h00000000, 32'hFFFFFFFF              // Sparse, Zeros, Ones
    };
    
    foreach (all_masks[i]) begin
       repeat(2) begin // multiple runs for stability
            item = pattern_detector_seq_item::type_id::create("item");
            start_item(item);
         item.allow_zero_mask = (all_masks[i] == 0); // working with zero constraint
            assert(item.randomize() with {
                mode_select == 1;
                pattern_mask == all_masks[i];
            });
            finish_item(item);
        end
    end
endtask
endclass


class zero_mask_seq extends pattern_detector_base_seq;
    `uvm_object_utils(zero_mask_seq)
    function new(string name = "zero_mask_seq"); super.new(name); endfunction

    virtual task body();
        pattern_detector_seq_item item;
        repeat(10) begin
            item = pattern_detector_seq_item::type_id::create("item");
            start_item(item);
            // using the flag to deal with the constraint
            assert(item.randomize() with {
                mode_select == 1;
                allow_zero_mask == 1; 
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

class varied_mask_seq extends pattern_detector_base_seq;
    `uvm_object_utils(varied_mask_seq)
    function new(string name = "varied_mask_seq"); super.new(name); endfunction

    virtual task body();
        pattern_detector_seq_item item;
        //values to target the bins in-cp_mask_patterns
        bit [31:0] target_masks[] = '{32'h00000001, 32'h00000002, 32'h00000004, 32'h00000008, 
                                      32'h0000FFFF, 32'hFFFF0000, 32'hAA55AA55};
        
        foreach (target_masks[i]) begin
            item = pattern_detector_seq_item::type_id::create("item");
            start_item(item);
//             assert(item.randomize() with {
//                 mode_select == 1; 
//                 pattern_mask == target_masks[i];
//             });
          assert(item.randomize() with {
    mode_select == 1;
    pattern_mask == target_masks[i];
    // This forces the masked bits to be identical!
    (data_stream_a & pattern_mask) == (data_stream_b & pattern_mask);
});
            finish_item(item);
        end
    endtask
endclass

class reset_match_seq extends pattern_detector_base_seq;
    `uvm_object_utils(reset_match_seq)
    function new(string name = ""); super.new(name); endfunction

    virtual task body();
        pattern_detector_seq_item item;
        item = pattern_detector_seq_item::type_id::create("item");

        // שלב א: שליחת דאטה עם התאמה כדי "ללכלך" את הרגיסטרים
        start_item(item);
        item.randomize() with { 
            mode_select == 0; 
            data_stream_a == data_stream_b; // Force Match
        };
        finish_item(item);

        // שלב ב: כאן הטסט (3.2) מצפה שנראה שאין False Match אחרי שהריסט משתחרר.
        // אנחנו נשלח טרנזקציה של No Match מיד אחרי הריסט (שיבוצע ב-Test)
        start_item(item);
        item.randomize() with { 
            data_stream_a != data_stream_b; // Force No Match
        };
        finish_item(item);
    endtask
endclass