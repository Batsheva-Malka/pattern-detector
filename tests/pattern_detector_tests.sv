// Pattern Detector Base Test
// Base class for all tests

class pattern_detector_base_test extends uvm_test;
    
    `uvm_component_utils(pattern_detector_base_test)
    
    pattern_detector_env env;
    
    // Constructor
    function new(string name = "pattern_detector_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = pattern_detector_env::type_id::create("env", this);
    endfunction
    
    // End of elaboration phase
    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction
    
    // Start of simulation phase
    virtual function void start_of_simulation_phase(uvm_phase phase);
        super.start_of_simulation_phase(phase);
        `uvm_info(get_type_name(), "Starting test...", UVM_LOW)
    endfunction
    
    // Run phase - apply reset
    virtual task run_phase(uvm_phase phase);
        virtual pattern_detector_if vif;
        
        phase.raise_objection(this);
        
        // Get virtual interface
        if (!uvm_config_db#(virtual pattern_detector_if)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(), "Virtual interface not found")
        
        // Apply reset
        vif.rst_n = 1'b0;
        repeat(5) @(posedge vif.clk);
        vif.rst_n = 1'b1;
        `uvm_info(get_type_name(), "Reset completed", UVM_LOW)
        
        phase.drop_objection(this);
    endtask
    
endclass

// --- Directed Tests (1.1 - 2.2) ---

class basic_match_test extends pattern_detector_base_test;
    `uvm_component_utils(basic_match_test)
    function new(string name = "basic_match_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    virtual task run_phase(uvm_phase phase);
        basic_match_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        seq = basic_match_seq::type_id::create("seq");
        seq.start(env.agent.sequencer);
        #100ns;
        phase.drop_objection(this);
    endtask
endclass

class no_match_test extends pattern_detector_base_test;
    `uvm_component_utils(no_match_test)
    function new(string name = "no_match_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    virtual task run_phase(uvm_phase phase);
        no_match_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        seq = no_match_seq::type_id::create("seq");
        seq.start(env.agent.sequencer);
        #100ns;
        phase.drop_objection(this);
    endtask
endclass

class first_window_match_test extends pattern_detector_base_test;
    `uvm_component_utils(first_window_match_test)
    function new(string name = "first_window_match_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    virtual task run_phase(uvm_phase phase);
        first_window_match_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        seq = first_window_match_seq::type_id::create("seq");
        seq.start(env.agent.sequencer);
        #100ns;
        phase.drop_objection(this);
    endtask
endclass

class last_window_match_test extends pattern_detector_base_test;
    `uvm_component_utils(last_window_match_test)
    function new(string name = "last_window_match_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    virtual task run_phase(uvm_phase phase);
        last_window_match_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        seq = last_window_match_seq::type_id::create("seq");
        seq.start(env.agent.sequencer);
        #100ns;
        phase.drop_objection(this);
    endtask
endclass

class multiple_matches_test extends pattern_detector_base_test;
    `uvm_component_utils(multiple_matches_test)
    function new(string name = "multiple_matches_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    virtual task run_phase(uvm_phase phase);
        multiple_matches_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        seq = multiple_matches_seq::type_id::create("seq");
        seq.start(env.agent.sequencer);
        #100ns;
        phase.drop_objection(this);
    endtask
endclass

class full_mask_test extends pattern_detector_base_test;
    `uvm_component_utils(full_mask_test)
    function new(string name = "full_mask_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    virtual task run_phase(uvm_phase phase);
        full_mask_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        seq = full_mask_seq::type_id::create("seq");
        seq.start(env.agent.sequencer);
        #100ns;
        phase.drop_objection(this);
    endtask
endclass

class zero_mask_test extends pattern_detector_base_test;
    `uvm_component_utils(zero_mask_test)
    function new(string name = "zero_mask_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    virtual task run_phase(uvm_phase phase);
        zero_mask_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        seq = zero_mask_seq::type_id::create("seq");
        seq.start(env.agent.sequencer);
        #100ns;
        phase.drop_objection(this);
    endtask
endclass

// --- Special Tests (Reset, Random, Coverage) ---

class reset_test extends pattern_detector_base_test;
    `uvm_component_utils(reset_test)
    function new(string name = "reset_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    virtual task run_phase(uvm_phase phase);
        reset_test_seq seq;
        virtual pattern_detector_if vif;
        super.run_phase(phase);
        phase.raise_objection(this);
        if (!uvm_config_db#(virtual pattern_detector_if)::get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(), "Virtual interface not found")
        seq = reset_test_seq::type_id::create("seq");
        seq.start(env.agent.sequencer);
        #50ns;
        vif.rst_n = 1'b0;
        `uvm_info(get_type_name(), "Applying reset during operation", UVM_LOW)
        repeat(5) @(posedge vif.clk);
        if (vif.pattern_match !== 1'b0)
            `uvm_error(get_type_name(), "pattern_match not cleared on reset!")
        else
            `uvm_info(get_type_name(), "Reset successfully cleared pattern_match", UVM_LOW)
        vif.rst_n = 1'b1;
        #100ns;
        phase.drop_objection(this);
    endtask
endclass

class random_test extends pattern_detector_base_test;
    `uvm_component_utils(random_test)
    function new(string name = "random_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    virtual task run_phase(uvm_phase phase);
        random_seq seq;
        super.run_phase(phase);
        phase.raise_objection(this);
        seq = random_seq::type_id::create("seq");
        seq.start(env.agent.sequencer);
        #500ns;
        phase.drop_objection(this);
    endtask
endclass

// --- Master Suite ---

class all_tests_suite extends pattern_detector_base_test;
    
    `uvm_component_utils(all_tests_suite)
    
    function new(string name = "all_tests_suite", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        basic_match_seq          seq1;
        no_match_seq             seq2;
        first_window_match_seq   seq3;
        last_window_match_seq    seq4;
        multiple_matches_seq     seq5;
        full_mask_seq            seq6;
        zero_mask_seq            seq7;
        reset_test_seq           seq8;
        random_seq               seq9;
      	varied_mask_seq seq_masks;
      	reset_match_seq          seq_reset_match;

        
        super.run_phase(phase);
        
        phase.raise_objection(this);
        
        `uvm_info(get_type_name(), "\n========== Running Suite ==========", UVM_LOW)
        
        seq1 = basic_match_seq::type_id::create("seq1");
        seq1.start(env.agent.sequencer);
        #50ns;
        
        seq2 = no_match_seq::type_id::create("seq2");
        seq2.start(env.agent.sequencer);
        #50ns;
        
        seq3 = first_window_match_seq::type_id::create("seq3");
        seq3.start(env.agent.sequencer);
        #50ns;
        
        seq4 = last_window_match_seq::type_id::create("seq4");
        seq4.start(env.agent.sequencer);
        #50ns;
        
        seq5 = multiple_matches_seq::type_id::create("seq5");
        seq5.start(env.agent.sequencer);
        #50ns;
        
        seq6 = full_mask_seq::type_id::create("seq6");
        seq6.start(env.agent.sequencer);
        #50ns;
        
        seq7 = zero_mask_seq::type_id::create("seq7");
        seq7.start(env.agent.sequencer);
        #50ns;
        
        seq8 = reset_test_seq::type_id::create("seq8");
        seq8.start(env.agent.sequencer);
        #50ns;
        
        seq9 = random_seq::type_id::create("seq9");
        seq9.start(env.agent.sequencer);
        #50ns;
      
      	seq_masks = varied_mask_seq::type_id::create("seq_masks");
		seq_masks.start(env.agent.sequencer);
        #50ns;
      
        seq_reset_match = reset_match_seq::type_id::create("seq_reset_match");
        seq_reset_match.start(env.agent.sequencer);
        #100ns;
  
        
        `uvm_info(get_type_name(), "\n========== ALL TESTS COMPLETED ==========", UVM_LOW)
        
        phase.drop_objection(this);
    endtask
    
endclass