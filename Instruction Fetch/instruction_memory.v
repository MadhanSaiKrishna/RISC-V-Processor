//this kinda code can be used in the final stages of the project to automate the testing of our processor

`timescale 1ns / 1ps

module instruction_memory (
    input  wire [63:0] address, // 64-bit address input
    output wire [31:0] data     // 32-bit instruction output
);

    // Memory array: 256 x 32-bit instructions
    reg [31:0] instruction_memory [0:255];

    // Initialize memory from a file
    initial begin
        $readmemh("program.hex", instruction_memory, 0, 255); // Load all 256 instructions
    end

    // Fetch instruction from memory
    assign data = instruction_memory[address[7:0]]; // Use lower 8 bits of address for 256-entry memory

    // Debugging: Display address and data
    always @(address) begin
        $display("Instruction Memory");
        $display("Address: %h", address[63:0]); // Display full 64-bit address
        $display("Data: %h", data[31:0]);      // Display 32-bit instruction
    end

endmodule