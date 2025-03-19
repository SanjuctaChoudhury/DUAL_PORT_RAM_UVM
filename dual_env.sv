class dual_env extends uvm_env;
  `uvm_component_utils(dual_env)

  virtual dual_if vif; 
  dual_agent agent;
  dual_scoreboard scb;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    agent = dual_agent::type_id::create("agent", this);
    scb = dual_scoreboard::type_id::create("scb", this);

    
    if (!uvm_config_db#(virtual dual_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NO_VIF", "Virtual interface not set in dual_env")
    end

    uvm_config_db#(virtual dual_if)::set(this, "agent", "vif", vif);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

   
    agent.mon.monitor_port.connect(scb.analysis_export);
  endfunction
endclass : dual_env
