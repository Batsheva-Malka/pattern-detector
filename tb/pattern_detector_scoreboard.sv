// Pattern Detector Scoreboard
// Receives transactions from both input and output monitors
// Compares DUT output with reference model prediction

// Declare unique analysis implementations for input/output streams
`uvm_analysis_imp_decl(_in)
`uvm_analysis_imp_decl(_out)

class pattern_detector_scoreboard extends uvm_scoreboard;
    
    `uvm_component_utils(pattern_detector_scoreboard)
    
    // Two analysis imports - one for inputs, one for outputs
    uvm_analysis_imp_in  #(pattern_detector_seq_item, pattern_detector_scoreboard) item_collected_export_in;
    uvm_analysis_imp_out #(pattern_detector_seq_item, pattern_detector_scoreboard) item_collected_export_out;
    
    // Queue to store input transactions for comparison
    pattern_detector_seq_item input_queue[$];
    
    int match_count;
    int mismatch_count;
    int total_transactions;
    
    // Constructor
    function new(string name = "pattern_detector_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        item_collected_export_in  = new("item_collected_export_in", this);
        item_collected_export_out = new("item_collected_export_out", this);
    endfunction
    
    // Build phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        match_count = 0;
        mismatch_count = 0;
        total_transactions = 0;
    endfunction
    
    // Write method for input monitor
    virtual function void write_in(pattern_detector_seq_item item);
        pattern_detector_seq_item item_clone;
        
        // Clone and store input transaction
        $cast(item_clone, item.clone());
        input_queue.push_back(item_clone);
        
        `uvm_info(get_type_name(), $sformatf("Received INPUT: mode=%0d, stream_a=0x%0h, stream_b=0x%0h, mask=0x%0h",
                  item.mode_select, item.data_stream_a, item.data_stream_b, item.pattern_mask), UVM_HIGH)
    endfunction
    
    // Write method for output monitor
    virtual function void write_out(pattern_detector_seq_item item);
        pattern_detector_seq_item input_item;
        bit expected_match;
        
        // Get corresponding input transaction
        if (input_queue.size() == 0) begin
            `uvm_error(get_type_name(), "Received output but no input in queue!")
            return;
        end
        
        input_item = input_queue.pop_front();
        total_transactions++;
        
        // Run reference model on input to get expected output
        expected_match = reference_model(input_item);
        
        // Compare with actual DUT output
        if (expected_match == item.pattern_match) begin
            match_count++;
            `uvm_info(get_type_name(), $sformatf("PASS: Expected=%0b, Got=%0b", expected_match, item.pattern_match), UVM_HIGH)
        end else begin
            mismatch_count++;
            `uvm_error(get_type_name(), $sformatf("FAIL: Expected=%0b, Got=%0b, mode=%0d, stream_a=0x%0h, stream_b=0x%0h, mask=0x%0h",
                       expected_match, item.pattern_match, input_item.mode_select,
                       input_item.data_stream_a, input_item.data_stream_b, input_item.pattern_mask))
        end
    endfunction
    
    // Write method - kept for backward compatibility but not used
    virtual function void write(pattern_detector_seq_item item);
        bit expected_match;
        
        total_transactions++;
        
        // Reference model: check if any 32-bit pattern matches
        expected_match = reference_model(item);
        
        // Compare with DUT output
        if (expected_match == item.pattern_match) begin
            match_count++;
            `uvm_info(get_type_name(), $sformatf("PASS: Expected=%0b, Got=%0b", expected_match, item.pattern_match), UVM_HIGH)
        end else begin
            mismatch_count++;
            `uvm_error(get_type_name(), $sformatf("FAIL: Expected=%0b, Got=%0b, mode=%0d, stream_a=0x%0h, stream_b=0x%0h, mask=0x%0h",
                       expected_match, item.pattern_match, item.mode_select,
                       item.data_stream_a, item.data_stream_b, item.pattern_mask))
        end
    endfunction
    
    // Reference model - implements pattern detection algorithm
    function bit reference_model(pattern_detector_seq_item item);
        bit found_match = 0;
        
        // Check all possible 32-bit windows (33 positions in each 64-bit stream)
        for (int i = 0; i <= 32; i++) begin
            for (int j = 0; j <= 32; j++) begin
                bit [31:0] window_a, window_b;
                bit window_match;
                
                // Extract 32-bit windows
                window_a = item.data_stream_a[i +: 32];
                window_b = item.data_stream_b[j +: 32];
                
                // Compare based on mode
                if (item.mode_select == 1'b0) begin
                    // Full Adjustment Mode: compare all bits
                    window_match = (window_a == window_b);
                end else begin
                    // Mask-Based Mode: compare only masked bits
                    window_match = ((window_a & item.pattern_mask) == (window_b & item.pattern_mask));
                end
                
                if (window_match) begin
                    found_match = 1;
                    break;
                end
            end
            if (found_match) break;
        end
        
        return found_match;
    endfunction
    
    // Report phase
    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info(get_type_name(), $sformatf("\n\n========== SCOREBOARD SUMMARY =========="), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Total Transactions: %0d", total_transactions), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Matches:            %0d", match_count), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("Mismatches:         %0d", mismatch_count), UVM_LOW)
        `uvm_info(get_type_name(), $sformatf("========================================\n"), UVM_LOW)
        
        if (mismatch_count == 0 && total_transactions > 0)
            `uvm_info(get_type_name(), "** TEST PASSED **", UVM_LOW)
        else
            `uvm_error(get_type_name(), "** TEST FAILED **")
    endfunction
    
endclass
