class dual_transaction extends uvm_sequence_item;
  rand bit [7:0]  rd_addr, wr_addr;
  rand bit [7:0]  data_in;
  bit [7:0] data_out;  
  rand bit wr_en, rd_en;
  rand bit rst;

  `uvm_object_utils_begin(dual_transaction) 
    `uvm_field_int (rd_addr, UVM_DEFAULT)
    `uvm_field_int (wr_addr, UVM_DEFAULT)
    `uvm_field_int (data_in, UVM_DEFAULT)
    `uvm_field_int (data_out, UVM_DEFAULT)
    `uvm_field_int (wr_en, UVM_DEFAULT)
    `uvm_field_int (rd_en, UVM_DEFAULT)
    `uvm_field_int (rst, UVM_DEFAULT)
  `uvm_object_utils_end

 
  virtual function string convert2str();
    return $sformatf("rd_addr=0x%0h wr_addr=0x%0h data_in=0x%0h data_out=0x%0h wr_en=%0b rd_en=%0b rst=%0b", 
                      rd_addr, wr_addr, data_in, data_out, wr_en, rd_en, rst);
  endfunction

  
  function new(string name = "dual_transaction");
    super.new(name);
  endfunction


  constraint reset_behavior {
    if (rst == 1) {
      wr_en == 0;
      rd_en == 0;
      data_in == 0;
      rd_addr == 0;
      wr_addr == 0;
    }
  }


endclass
