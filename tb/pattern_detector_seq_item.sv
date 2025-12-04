// Pattern Detector Sequence Item
// Transaction object for stimulus generation

class pattern_detector_seq_item extends uvm_sequence_item;
    
    // Randomized inputs
    rand bit [63:0] data_stream_a;
    rand bit [63:0] data_stream_b;
    rand bit        mode_select;      // 0 = Full Adjustment, 1 = Mask-Based
    rand bit [31:0] pattern_mask;
    
    // Output (captured by monitor)
    bit             pattern_match;
    
    // UVM automation macros
    `uvm_object_utils_begin(pattern_detector_seq_item)
        `uvm_field_int(data_stream_a, UVM_ALL_ON)
        `uvm_field_int(data_stream_b, UVM_ALL_ON)
        `uvm_field_int(mode_select,   UVM_ALL_ON)
        `uvm_field_int(pattern_mask,  UVM_ALL_ON)
        `uvm_field_int(pattern_match, UVM_ALL_ON)
    `uvm_object_utils_end
    
    // Constructor
    function new(string name = "pattern_detector_seq_item");
        super.new(name);
    endfunction
    
    // Constraints for different test scenarios
    
    // Default: reasonable distribution
    constraint c_default {
        soft mode_select dist {0 := 50, 1 := 50};
    }
    
    // Mask constraints for mask-based mode
    constraint c_mask_valid {
        mode_select == 1 -> pattern_mask != 0; // Avoid all-zero mask in mask mode
    }
    
endclass
