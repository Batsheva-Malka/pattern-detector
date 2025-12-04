// Pattern Detector Agent
// Encapsulates driver, sequencer, and two monitor instances (input and output)

class pattern_detector_agent extends uvm_agent;
    
    `uvm_component_utils(pattern_detector_agent)
    
    pattern_detector_driver    driver;
    pattern_detector_sequencer sequencer;
    pattern_detector_monitor   monitor_in;   // Configured as INPUT monitor
    pattern_detector_monitor   monitor_out;  // Configured as OUTPUT monitor
    
    uvm_analysis_port #(pattern_detector_seq_item) item_collected_port_in;
    uvm_analysis_port #(pattern_detector_seq_item) item_collected_port_out;
    
    // Constructor
    function new(string name = "pattern_detector_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Create both monitor instances
        monitor_in  = pattern_detector_monitor::type_id::create("monitor_in", this);
        monitor_out = pattern_detector_monitor::type_id::create("monitor_out", this);
        
        // Configure monitor types
        uvm_config_db#(string)::set(this, "monitor_in", "monitor_type", "INPUT");
        uvm_config_db#(string)::set(this, "monitor_out", "monitor_type", "OUTPUT");
        
        // Create driver and sequencer only in active mode
        if (get_is_active() == UVM_ACTIVE) begin
            driver    = pattern_detector_driver::type_id::create("driver", this);
            sequencer = pattern_detector_sequencer::type_id::create("sequencer", this);
        end
    endfunction
    
    // Connect phase
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Connect driver to sequencer in active mode
        if (get_is_active() == UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end
        
        // Export both monitors' analysis ports
        item_collected_port_in  = monitor_in.item_collected_port;
        item_collected_port_out = monitor_out.item_collected_port;
    endfunction
    
endclass
