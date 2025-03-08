module InstructionFetch(
    input clk,                // Clock signal
    input reset,              // Reset signal
    input BranchTaken,        // Control signal: 1 for branch, 0 for sequential execution
    input [63:0] branchAddr, // 64-bit Branch target address
    input stall,              // Stall signal from hazard detection unit
    output reg [63:0] PC,     // Current 64-bit Program Counter
    output reg [31:0] instruction // 32-bit instruction fetched
);

    // Instruction Memory: 32 x 32-bit words
    reg [31:0] instruction_memory [0:15];

    // Initialize memory (for simulation/testing)
    initial begin
        $readmemh("instructions_test_1.hex", instruction_memory); // Load from file
    end

    // ALU wires
    wire signed [63:0] alu_result;
    wire add_cout;

    // Instantiate ALU for adding 4 to PC
    alu2 adder (
        .rs1(PC),
        .rs2(64'd4),
        .ALUControl(4'b0010), // ADD operation
        .rd(alu_result)
    );

    // PC Register Update
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            PC <= 64'b0; // Reset PC to 0
    end
       
        else if (BranchTaken) begin
                PC <= branchAddr;
             // Branch address
    end
     else if (!stall) begin
                PC <= alu_result; // PC + 4
        end
    end

    // Read instruction from memory (word-aligned access)
    always @(*) begin
        instruction = instruction_memory[PC[6:2]]; // Addressed by word index
    end

endmodule

// module InstructionFetch(
//     input clk,                // Clock signal
//     input reset,              // Reset signal
//     input BranchTaken,        // Control signal: 1 for branch, 0 for sequential execution
//     input [63:0] branchAddr, // 64-bit Branch target address
//     input stall,              // Stall signal from hazard detection unit
//     output reg [63:0] PC,     // Current 64-bit Program Counter
//     output reg [31:0] instruction // 32-bit instruction fetched
// );

//     // Instruction Memory: 32 x 32-bit words
//     reg [31:0] instruction_memory [0:15];

//     // Initialize memory (for simulation/testing)
//     initial begin
//         $readmemh("instructions_test_1.hex", instruction_memory); // Load from file
//     end

//     // ALU wires
//     wire signed [63:0] alu_result;
//     wire add_cout;

//     // Instantiate ALU for adding 4 to PC
//     alu2 adder (
//         .rs1(PC),
//         .rs2(64'd4),
//         .ALUControl(4'b0010), // ADD operation
//         .rd(alu_result)
//     );

//     // PC Register Update
//     always @(posedge clk or posedge reset) begin
//         if (reset)
//             PC <= 64'b0; // Reset PC to 0
//         else if (!stall) begin
//             if (BranchTaken)
//                 PC <= branchAddr; // Branch address
//             else
//                 PC <= alu_result; // PC + 4
//         end
//     end

//     // Read instruction from memory (word-aligned access)
//     always @(*) begin
//         instruction = instruction_memory[PC[6:2]]; // Addressed by word index
//     end

// endmodule