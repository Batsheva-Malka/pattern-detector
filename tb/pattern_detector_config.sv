// Pattern Detector Configuration Object
// Stores testbench configuration parameters

class pattern_detector_config extends uvm_object;
    
    `uvm_object_utils(pattern_detector_config)
    
    // Virtual interface handle
    virtual pattern_detector_if vif;
    
    // Configuration parameters
    uvm_active_passive_enum is_active = UVM_ACTIVE;
    
    // Constructor
    function new(string name = "pattern_detector_config");
        super.new(name);
    endfunction
    
endclass
