`timescale 1ns / 1ps

module write_back (
    input wire MemtoReg,         // Selects data source for write-back
    input wire [63:0] alu_result,   // Result from ALU
    input wire [63:0] mem_data,     // Data from memory
    output wire [63:0] wb_out // Register Input Write data
);

    // MUX to select between ALU result and memory data
    assign wb_out = MemtoReg ? mem_data : alu_result;

endmodule