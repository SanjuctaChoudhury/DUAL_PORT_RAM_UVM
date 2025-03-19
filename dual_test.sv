class dual_test extends uvm_test;
  `uvm_component_utils(dual_test)
  virtual dual_if vif; 
  dual_env env;
  dual_sequence seq;
  
  function new(string name = "dual_test", uvm_component parent);
    super.new(name, parent);
  endfunction : new
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = dual_env::type_id::create("env", this);

    
    if (!uvm_config_db#(virtual dual_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NO_VIF", "Virtual interface not set in dual_test")
    end

   
    uvm_config_db#(virtual dual_if)::set(this, "env", "vif", vif);
  endfunction : build_phase
  
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

   
    `uvm_info(get_type_name(), "Waiting for Reset to Deassert...", UVM_LOW);
    wait (vif.rst == 0);
    `uvm_info(get_type_name(), "Reset Deasserted. Waiting for Stable Signals...", UVM_MEDIUM);

   
    @(posedge vif.clk);

   
    seq = dual_sequence::type_id::create("seq");
    if (!seq.randomize())
      `uvm_fatal("SEQ", "Failed to randomize sequence");

   
    fork
      seq.start(env.agent.seqr);
    join
    
    phase.drop_objection(this);
  endtask : run_phase
endclass : dual_test
