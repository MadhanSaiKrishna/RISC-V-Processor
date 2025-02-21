// Instruction Memory Module
// Instruction Memory Module
module instruction_memory (
    input  wire [63:0] address, 
    output wire [31:0] data     
);

    reg [31:0] instruction_memory [0:255];

    // Initialize memory with hardcoded instructions
    initial begin
        // Sequential instructions
        instruction_memory[0] = 32'h3c011001; // LUI R1, 0x1001
        instruction_memory[1] = 32'h34280000; // ORI R8, R1, 0x0000
        instruction_memory[2] = 32'h3c011001; // LUI R1, 0x1001
        instruction_memory[3] = 32'h342d0030; // ORI R13, R1, 0x0030

        // Branch instruction (BEQ)
        instruction_memory[4] = 32'h110d0002; // BEQ R8, R13, +2 (branch if R8 == R13)

        // Jump instruction (J)
        instruction_memory[5] = 32'h08000008; // J 0x0008 (jump to address 0x20)

        // Immediate instruction (ADDI)
        instruction_memory[6] = 32'h200a0001; // ADDI R10, R0, 1 (R10 = R0 + 1)

        // Fill the rest with NOPs
        for (integer i = 7; i < 256; i = i + 1) begin
            instruction_memory[i] = 32'h00000013; // NOP
        end
    end

    // Use word-aligned access
    assign data = instruction_memory[address[7:2]]; 

endmodule










//Code for future use (automated testing of the processor via file reading)
// module instruction_memory (
//     input  wire [63:0] address, // 64-bit address input
//     output wire [31:0] data     // 32-bit instruction output
// );

//     // Memory array: 256 x 32-bit instructions
//     reg [31:0] instruction_memory [0:255];

//     // Initialize memory from a file
//     initial begin
//         $readmemh("program.hex", instruction_memory, 0, 255); // Load all 256 instructions
//     end

//     // Fetch instruction from memory
//     assign data = instruction_memory[address[7:0]]; // Use lower 8 bits of address for 256-entry memory

//     // Debugging: Display address and data
//     always @(address) begin
//         $display("Instruction Memory");
//         $display("Address: %h", address[63:0]); // Display full 64-bit address
//         $display("Data: %h", data[31:0]);      // Display 32-bit instruction
//     end

// endmodule