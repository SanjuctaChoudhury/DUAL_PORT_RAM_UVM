interface dual_if(input logic clk);
  
  logic wr_en, rd_en, rst;
  logic [7:0] rd_addr, wr_addr; 
  logic [7:0] data_in, data_out; 


 
  clocking driver_cb @(posedge clk);
    output wr_en, rd_en;
    output wr_addr, data_in;
    input  data_out;
  endclocking
  

  
  clocking monitor_cb @(posedge clk);
    input wr_en, rd_en, rst;
    input wr_addr, rd_addr;
    input data_in, data_out;
  endclocking
  
  


  modport DRIVER  (clocking driver_cb, input rst, input clk);
  modport MONITOR (clocking monitor_cb, input rst, input clk);
  
endinterface
