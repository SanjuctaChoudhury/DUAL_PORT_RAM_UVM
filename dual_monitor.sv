class dual_monitor extends uvm_monitor;
  
  `uvm_component_utils(dual_monitor)

  virtual dual_if vif;
  uvm_analysis_port#(dual_transaction) monitor_port; 

  function new(string name, uvm_component parent);
    super.new(name, parent);
    monitor_port = new("monitor_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual dual_if)::get(this, "", "vif", vif))
      `uvm_fatal("MONITOR", "No virtual interface specified!");
  endfunction

  virtual task run_phase(uvm_phase phase);
    dual_transaction req_write, req_read;

    forever begin
      @(posedge vif.clk);
    
      if (vif.rst) begin
        `uvm_info("MONITOR", "Reset Detected. Flushing Monitor...", UVM_MEDIUM)
        continue;
      end

     
      if (vif.wr_en && vif.rd_en) begin
       
        req_write = dual_transaction::type_id::create("req_write");
        req_write.wr_addr = vif.wr_addr;
        req_write.data_in = vif.data_in;
        req_write.wr_en   = 1;
        req_write.rd_en   = 0; 
        `uvm_info("MONITOR", $sformatf("Captured Write Transaction: %s", req_write.convert2str()), UVM_LOW)
        monitor_port.write(req_write);

        req_read = dual_transaction::type_id::create("req_read");
        req_read.rd_addr  = vif.rd_addr;
        req_read.data_out = vif.data_out;
        req_read.rd_en    = 1;
        req_read.wr_en    = 0; 
        `uvm_info("MONITOR", $sformatf("Captured Read Transaction: %s", req_read.convert2str()), UVM_LOW)
        monitor_port.write(req_read);
      end
    
      else if (vif.wr_en) begin
        req_write = dual_transaction::type_id::create("req_write");
        req_write.wr_addr = vif.wr_addr;
        req_write.data_in = vif.data_in;
        req_write.wr_en   = 1;
        req_write.rd_en   = 0;
        `uvm_info("MONITOR", $sformatf("Captured Write Transaction: %s", req_write.convert2str()), UVM_LOW)
        monitor_port.write(req_write);
      end
     
      else if (vif.rd_en) begin
        req_read = dual_transaction::type_id::create("req_read");
        req_read.rd_addr  = vif.rd_addr;
        req_read.data_out = vif.data_out;
        req_read.rd_en    = 1;
        req_read.wr_en    = 0;
        `uvm_info("MONITOR", $sformatf("Captured Read Transaction: %s", req_read.convert2str()), UVM_LOW)
        monitor_port.write(req_read);
      end
    end
  endtask

endclass
