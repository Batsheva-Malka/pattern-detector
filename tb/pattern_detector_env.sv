// Pattern Detector Environment
// Top-level verification environment containing agent, scoreboard, and coverage

class pattern_detector_env extends uvm_env;
    
    `uvm_component_utils(pattern_detector_env)
    
    pattern_detector_agent      agent;
    pattern_detector_scoreboard scoreboard;
    pattern_detector_coverage   coverage;
    
    // Constructor
    function new(string name = "pattern_detector_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        agent      = pattern_detector_agent::type_id::create("agent", this);
        scoreboard = pattern_detector_scoreboard::type_id::create("scoreboard", this);
        coverage   = pattern_detector_coverage::type_id::create("coverage", this);
    endfunction
    
    // Connect phase
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);        // Connect input monitor to scoreboard
        agent.item_collected_port_in.connect(scoreboard.item_collected_export_in);
        
        // Connect output monitor to scoreboard
        agent.item_collected_port_out.connect(scoreboard.item_collected_export_out);
        
        // Connect output monitor to coverage collector
        agent.item_collected_port_out.connect(coverage.analysis_export);
    endfunction
    
endclass
