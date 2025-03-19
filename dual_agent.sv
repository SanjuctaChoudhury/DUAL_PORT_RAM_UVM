class dual_agent extends uvm_agent;

  `uvm_component_utils(dual_agent)

  virtual dual_if vif;
  dual_driver    drv;
  dual_monitor   mon;
  dual_sequencer seqr;

  uvm_active_passive_enum is_active = UVM_ACTIVE;

  
  uvm_analysis_port#(dual_transaction) analysis_export;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    analysis_export = new("analysis_export", this);  
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    mon = dual_monitor::type_id::create("mon", this);

    if (is_active == UVM_ACTIVE) begin
      if (!uvm_config_db#(virtual dual_if)::get(this, "", "vif", vif)) begin
        `uvm_fatal("NO_VIF", "Virtual interface not set in dual_agent")
      end
      
      uvm_config_db#(virtual dual_if)::set(this, "drv", "vif", vif);
      uvm_config_db#(virtual dual_if)::set(this, "mon", "vif", vif);

      drv  = dual_driver::type_id::create("drv", this);
      seqr = dual_sequencer::type_id::create("seqr", this);
    end
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    if (is_active == UVM_ACTIVE) begin
      drv.seq_item_port.connect(seqr.seq_item_export);
    end

   
    mon.monitor_port.connect(analysis_export);  //monitor->agent->driver&sequencer
  endfunction
endclass
