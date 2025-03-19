class dual_driver extends uvm_driver #(dual_transaction);
  
  virtual dual_if vif;
  `uvm_component_utils(dual_driver)
 
  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual dual_if)::get(this, "", "vif", vif))
       `uvm_fatal("NO_VIF", {"Virtual interface must be set for: ", get_full_name(), ".vif"});
  endfunction: build_phase

  virtual task run_phase(uvm_phase phase);
    forever begin
      seq_item_port.get_next_item(req);

   
      if (vif.rst) begin
        `uvm_info(get_type_name(), "Reset asserted. Flushing transaction...", UVM_LOW)
        flush_transaction();
        seq_item_port.item_done();
        @(negedge vif.rst); 
        `uvm_info(get_type_name(), "Reset de-asserted. Resuming transaction...", UVM_LOW)
      end

     
      drive(req);
      seq_item_port.item_done();
    end
  endtask : run_phase

  virtual task drive(dual_transaction req);
  
    vif.wr_en   <= 0;
    vif.rd_en   <= 0;
    vif.rd_addr <= 0;
    vif.wr_addr <= 0;
    vif.data_in <= 0;

   
    if (req.wr_en && req.rd_en && !vif.rst) begin
      `uvm_info(get_type_name(), $sformatf("Driving Simultaneous Read & Write: rd_addr=0x%0h, wr_addr=0x%0h, data_in=0x%0h", req.rd_addr, req.wr_addr, req.data_in), UVM_LOW)
      
     
      vif.rd_en   <= 1;
      vif.rd_addr <= req.rd_addr;
      @(posedge vif.clk);  
      req.data_out = vif.data_out;
      vif.rd_en   <= 0;

      vif.wr_en   <= 1;
      vif.wr_addr <= req.wr_addr;
      vif.data_in <= req.data_in;
      @(posedge vif.clk);
      vif.wr_en   <= 0;
    end 
   
    else if (req.wr_en && !vif.rst) begin
      `uvm_info(get_type_name(), $sformatf("Driving Write: wr_addr=0x%0h, data_in=0x%0h", req.wr_addr, req.data_in), UVM_LOW)
      vif.wr_en   <= 1;
      vif.wr_addr <= req.wr_addr;
      vif.data_in <= req.data_in;
      @(posedge vif.clk);   
      vif.wr_en   <= 0;
    end 
   
    else if (req.rd_en && !vif.rst) begin
      `uvm_info(get_type_name(), $sformatf("Driving Read: rd_addr=0x%0h", req.rd_addr), UVM_LOW)
      vif.rd_en   <= 1;
      vif.rd_addr <= req.rd_addr;
      
    
      @(posedge vif.clk);  
      req.data_out = vif.data_out;

      vif.rd_en   <= 0;
    end
  endtask : drive

  virtual task flush_transaction();
   
    vif.wr_en   <= 0;
    vif.rd_en   <= 0;
    vif.rd_addr <= 0;
    vif.wr_addr <= 0;
    vif.data_in <= 0;
    
   
    while (vif.rst) begin
      @(posedge vif.clk);
    end
  endtask : flush_transaction

endclass : dual_driver
