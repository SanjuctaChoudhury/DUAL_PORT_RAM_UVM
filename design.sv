

module dual_ram_async # (
    parameter RAM_WIDTH = 8,
    parameter RAM_DEPTH = 256,
    parameter ADDR_SIZE = 8
)(
    input wr_en, rd_en, rst,
    input [ADDR_SIZE-1:0] rd_addr, wr_addr,
    input [RAM_WIDTH-1:0] data_in,
    output reg [RAM_WIDTH-1:0] data_out
);

    reg [RAM_WIDTH-1:0] mem [RAM_DEPTH-1:0];
    integer i;

    
    always @(*) begin
        if (rst) begin
            for (i = 0; i < RAM_DEPTH; i = i + 1)
                mem[i] = 0; 
        end
    end

  always @(*) begin  //two parallel blocks to ensure simultaneous access
        if (wr_en)
            mem[wr_addr] = data_in;
    end

   
    always @(*) begin
        if (rd_en) begin
          if (wr_en && (wr_addr == rd_addr))  //if address same update read with latest memory location
                data_out = data_in;  
            else
                data_out = mem[rd_addr];
        end else begin
            data_out = 8'bz;
        end
    end

endmodule
