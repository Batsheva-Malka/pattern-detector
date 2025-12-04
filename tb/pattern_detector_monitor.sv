// Pattern Detector Monitor
// Configurable monitor that can sample either inputs or outputs
// Use monitor_type to configure: "INPUT" samples inputs, "OUTPUT" samples outputs

class pattern_detector_monitor extends uvm_monitor;
    
    `uvm_component_utils(pattern_detector_monitor)
    
    virtual pattern_detector_if vif;
    uvm_analysis_port #(pattern_detector_seq_item) item_collected_port;
    
    pattern_detector_seq_item trans_collected;
    
    // Configuration: "INPUT" or "OUTPUT"
    string monitor_type = "INPUT";
    
    // Constructor
    function new(string name = "pattern_detector_monitor", uvm_component parent = null);
        super.new(name, parent);
        item_collected_port = new("item_collected_port", this);
    endfunction
    
    // Build phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual pattern_detector_if)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(), "Virtual interface not found in config DB")
        
        // Get monitor type from config DB (optional, defaults to INPUT)
        void'(uvm_config_db#(string)::get(this, "", "monitor_type", monitor_type));
        
        `uvm_info(get_type_name(), $sformatf("Monitor created with type: %s", monitor_type), UVM_MEDIUM)
    endfunction
    
    // Run phase - collect transactions based on monitor type
    virtual task run_phase(uvm_phase phase);
        forever begin
            @(vif.monitor_cb);
            
            // Create new transaction
            trans_collected = pattern_detector_seq_item::type_id::create("trans_collected");
            
            if (monitor_type == "INPUT") begin
                // Sample INPUT signals only
                trans_collected.data_stream_a = vif.monitor_cb.data_stream_a;
                trans_collected.data_stream_b = vif.monitor_cb.data_stream_b;
                trans_collected.mode_select   = vif.monitor_cb.mode_select;
                trans_collected.pattern_mask  = vif.monitor_cb.pattern_mask;
                
                `uvm_info(get_type_name(), $sformatf("MonitorIn: mode=%0d, stream_a=0x%0h, stream_b=0x%0h, mask=0x%0h",
                          trans_collected.mode_select, trans_collected.data_stream_a, 
                          trans_collected.data_stream_b, trans_collected.pattern_mask), UVM_HIGH)
            end
            else if (monitor_type == "OUTPUT") begin
                // Sample OUTPUT signal
                trans_collected.pattern_match = vif.monitor_cb.pattern_match;
                
                `uvm_info(get_type_name(), $sformatf("MonitorOut: pattern_match=%0b", 
                          trans_collected.pattern_match), UVM_HIGH)
            end
            else begin
                `uvm_fatal(get_type_name(), $sformatf("Invalid monitor_type: %s. Must be INPUT or OUTPUT", monitor_type))
            end
            
            // Broadcast transaction
            item_collected_port.write(trans_collected);
        end
    endtask
    
endclass
