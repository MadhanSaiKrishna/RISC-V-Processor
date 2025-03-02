`timescale 1ns / 1ps

module write_back (
    input wire clk,
    input wire MemtoReg,         // Selects data source for write-back
    input wire [63:0] alu_result,   // Result from ALU
    input wire [63:0] mem_data,     // Data from memory
    output reg [63:0] write_data, //Register Input Write data, It needs to stay constant for register file to do its job
    input wire [4:0] rd          // Destination register address
);

 always @ (posedge clk) begin
     if(MemtoReg) // if MemtoReg is 1
         write_data <= mem_data;
     else
         write_data <= alu_result;
     end
endmodule   