`include "uvm_macros.svh"
import uvm_pkg::*;


`include "dual_interface.sv"
`include "dual_transaction.sv"
`include "dual_sequencer.sv"
`include "dual_sequence.sv"
`include "dual_driver.sv"
`include "dual_monitor.sv"
`include "dual_agent.sv"
`include "dual_scoreboard.sv"
`include "dual_env.sv"
`include "dual_test.sv"

module top_tb;
  
  bit clk;
  bit rst;

  always #5 clk = ~clk;

  
  dual_if vif(clk);


  dual_ram_async dut (
    .wr_en(vif.wr_en),
    .rd_en(vif.rd_en),
    .rst(vif.rst),
    .rd_addr(vif.rd_addr),
    .wr_addr(vif.wr_addr),
    .data_in(vif.data_in),
    .data_out(vif.data_out)
  );

 
  initial begin
    clk = 0;
    rst = 1; 
    vif.rst = rst;

   
    uvm_config_db#(virtual dual_if)::set(null, "uvm_test_top", "vif", vif);
    
    run_test("dual_test");
  end

  initial begin
    #10; 
    $display("RESET ASSERTED AT TIME %0t", $time);

    #100; 
    rst = 0; 
    vif.rst = rst;
    $display("RESET DEASSERTED AT TIME %0t", $time);
  end
  initial begin
    #10000;
    $display("SIMULATION TIMEOUT. FORCE FINISH.");
    $finish;
  end

 
  initial begin
    uvm_top.set_report_verbosity_level_hier(UVM_HIGH);
  end

endmodule 
