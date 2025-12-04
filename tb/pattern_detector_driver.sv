// Pattern Detector Driver
// Drives transactions from sequencer to DUT via interface

class pattern_detector_driver extends uvm_driver #(pattern_detector_seq_item);
    
    `uvm_component_utils(pattern_detector_driver)
    
    virtual pattern_detector_if vif;
    
    // Constructor
    function new(string name = "pattern_detector_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase - get virtual interface from config DB
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual pattern_detector_if)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(), "Virtual interface not found in config DB")
    endfunction
    
    // Run phase - drive transactions
    virtual task run_phase(uvm_phase phase);
        forever begin
            // Get next item from sequencer
            seq_item_port.get_next_item(req);
            
            // Drive the transaction
            drive_item(req);
            
            // Signal item done
            seq_item_port.item_done();
        end
    endtask
    
    // Drive transaction to DUT
    virtual task drive_item(pattern_detector_seq_item item);
        @(vif.driver_cb);
        vif.driver_cb.data_stream_a <= item.data_stream_a;
        vif.driver_cb.data_stream_b <= item.data_stream_b;
        vif.driver_cb.mode_select   <= item.mode_select;
        vif.driver_cb.pattern_mask  <= item.pattern_mask;
        
        `uvm_info(get_type_name(), $sformatf("Driving: mode=%0d, stream_a=0x%0h, stream_b=0x%0h, mask=0x%0h",
                  item.mode_select, item.data_stream_a, item.data_stream_b, item.pattern_mask), UVM_HIGH)
    endtask
    
endclass
