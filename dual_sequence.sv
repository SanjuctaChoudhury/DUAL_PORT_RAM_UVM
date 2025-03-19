

class dual_sequence extends uvm_sequence#(dual_transaction);
  
  `uvm_object_utils(dual_sequence)

  function new(string name = "dual_sequence");
      super.new(name);
  endfunction

  virtual task body();
      dual_transaction tr;
      int i;

     
      tr = dual_transaction::type_id::create("tr_write");
      start_item(tr);
      tr.wr_en  = 1;
      tr.rd_en  = 0;
      tr.wr_addr = 8'h10;
      tr.data_in = 8'hAA;
      finish_item(tr);
      #10;

    
      tr = dual_transaction::type_id::create("tr_read");
      start_item(tr);
      tr.wr_en  = 0;
      tr.rd_en  = 1;
      tr.rd_addr = 8'h10;
      finish_item(tr);
      #10;

      tr =dual_transaction::type_id::create("tr_write_read");
      start_item(tr);
      tr.wr_en  = 1;
      tr.rd_en  = 1;
      tr.wr_addr = 8'h20;
      tr.rd_addr = 8'h10;
      tr.data_in = 8'h55;
      finish_item(tr);
      #10;

     

     
 

  endtask
endclass


