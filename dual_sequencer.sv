
class dual_sequencer extends uvm_sequencer#(dual_transaction);

  `uvm_component_utils(dual_sequencer)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

endclass
