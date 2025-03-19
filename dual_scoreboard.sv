

class dual_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(dual_scoreboard)

  virtual dual_if vif;
  dual_transaction pkt_qu[$];
  bit [7:0] sc_mem [256]; 
  int total_transactions = 0;
 
  uvm_analysis_imp#(dual_transaction, dual_scoreboard) analysis_export;

  function new (string name, uvm_component parent);
    super.new(name, parent);
    analysis_export = new("analysis_export", this);  
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

  
    foreach(sc_mem[i]) 
      sc_mem[i] = 8'h0;
  endfunction: build_phase

  
  virtual function void write(dual_transaction pkt);
    pkt_qu.push_back(pkt);
    total_transactions++;
  endfunction : write

 
  virtual task run_phase(uvm_phase phase);
    dual_transaction dual_pkt;

    forever begin
      wait(pkt_qu.size() > 0);
      dual_pkt = pkt_qu.pop_front();

      if (dual_pkt.wr_en && dual_pkt.rd_en) begin
        
        if ($isunknown(dual_pkt.data_out)) begin
          `uvm_error(get_type_name(), 
            $sformatf("SIMUL READ Error: Addr=%0h Received X/Z Data=%0h", 
            dual_pkt.rd_addr, dual_pkt.data_out))
        end
        else if (sc_mem[dual_pkt.rd_addr] == dual_pkt.data_out) begin
          `uvm_info(get_type_name(), 
            $sformatf("SIMUL READ MATCH: Addr=%0h Expected=%0h Actual=%0h", 
            dual_pkt.rd_addr, sc_mem[dual_pkt.rd_addr], dual_pkt.data_out), UVM_LOW)
        end
        else begin
          `uvm_error(get_type_name(), 
            $sformatf("SIMUL READ MISMATCH: Addr=%0h Expected=%0h Actual=%0h", 
            dual_pkt.rd_addr, sc_mem[dual_pkt.rd_addr], dual_pkt.data_out))
        end

       
        sc_mem[dual_pkt.wr_addr] = dual_pkt.data_in;
        `uvm_info(get_type_name(), 
          $sformatf("SIMUL WRITE: Addr=%0h Data=%0h", 
          dual_pkt.wr_addr, dual_pkt.data_in), UVM_LOW)
      end 
      else if (dual_pkt.wr_en) begin
        sc_mem[dual_pkt.wr_addr] = dual_pkt.data_in;
        `uvm_info(get_type_name(), 
          $sformatf("\nWRITE: Addr=%0h Data=%0h", 
          dual_pkt.wr_addr, dual_pkt.data_in), UVM_LOW)
      end
      else if (dual_pkt.rd_en) begin
      
        if ($isunknown(dual_pkt.data_out)) begin
          `uvm_error(get_type_name(), 
            $sformatf("READ Error: Addr=%0h Received X/Z Data=%0h", 
            dual_pkt.rd_addr, dual_pkt.data_out))
        end
        else if (sc_mem[dual_pkt.rd_addr] == dual_pkt.data_out) begin
          `uvm_info(get_type_name(), 
            $sformatf("READ MATCH: Addr=%0h Expected=%0h Actual=%0h", 
            dual_pkt.rd_addr, sc_mem[dual_pkt.rd_addr], dual_pkt.data_out), UVM_LOW)
        end
        else begin
          `uvm_error(get_type_name(), 
            $sformatf("READ MISMATCH: Addr=%0h Expected=%0h Actual=%0h", 
            dual_pkt.rd_addr, sc_mem[dual_pkt.rd_addr], dual_pkt.data_out))
        end
      end

     
      if (pkt_qu.size() == 0 && total_transactions > 0) begin
        `uvm_info(get_type_name(), "ALL TRANSACTIONS PROCESSED. STOPPING SIMULATION.", UVM_MEDIUM)
      end
    end
  endtask : run_phase

endclass : dual_scoreboard

