`include "aluformain.v" // for individual 


module ExecuteStage (
    input clk,                // Clock signal
    input reset,              // Reset signal
    input [63:0] PC,          // Current Program Counter
    input [63:0] imm,         // Immediate value
    input [63:0] readData1,   // Data from source register 1
    input [63:0] readData2,   // Data from source register 2
    input [2:0] funct3,        //will be used in alucontrol unit
    input [6:0] funct7,         //will be used in alucontrol unit
    input [1:0] ALUOp,        // ALU operation control signal
    input ALUSrc,             // ALU source selection
    input Branch,             // Branch control signal
    output wire [63:0] ALUResult, // Result from ALU
    output wire Zero,      // Zero flag from ALU
    output wire [63:0] ALUInput2, // Added output for testbench monitoring
    input [3:0] ALUControl,   // ALU control signal
    output wire [63:0] immShifted,
    output wire [63:0] PCPlusImmShifted,
    output wire BranchTaken
);

    // wire BranchTaken;
    wire [63:0] PCPlus4;

    // MUX for ALU input 2 selection
    assign ALUInput2 = ALUSrc ? imm : readData2;

    // // ALU control unit
    // ALUControlUnit aluControlUnit (
    //     .funct3(funct3),
    //     .funct7(funct7),
    //     .ALUOp(ALUOp),
    //     .ALUControl(ALUControl)
    // );

    // Main ALU
    alu2 mainALU (
        .rs1(readData1),
        .rs2(ALUInput2),
        .ALUControl(ALUControl),
        .rd(ALUResult)
    );

    // ALU for shifting immediate value
    alu2 shiftALU (
        .rs1(imm),
        .rs2(64'd1), // Shift left by 1
        .ALUControl(4'b0100), // SLL operation
        .rd(immShifted)
    );

    alu2 addALU (
        .rs1(PC),
        .rs2(immShifted),
        .ALUControl(4'b0010), // ADD operation
        .rd(PCPlusImmShifted)
    );

    // Branch address output
    // assign BranchAddr = PCPlusImmShifted;

    // Zero flag
    assign Zero = (ALUResult == 64'b0);

    // AND gate for branch decision
    assign BranchTaken = Branch & Zero;

endmodule

module ALUControlUnit (
    input [2:0] funct3,
    input [6:0] funct7,
    input [1:0] ALUOp,
    output reg [3:0] ALUControl
);

    always @(*) begin
        case (ALUOp)
            2'b00: ALUControl = 4'b0010; // Load/store -> ADD
            2'b01: ALUControl = 4'b0110; // Branch -> SUBTRACT
            2'b10: begin
                case ({funct7, funct3})
                    10'b0000000_000: ALUControl = 4'b0010; // ADD
                    10'b0100000_000: ALUControl = 4'b0110; // SUBTRACT
                    10'b0000000_111: ALUControl = 4'b0000; // AND
                    10'b0000000_110: ALUControl = 4'b0001; // OR
                    10'b0000000_100: ALUControl = 4'b0011; // XOR
                    10'b0000000_001: ALUControl = 4'b0100; // SLL
                    10'b0000000_101: ALUControl = 4'b0101; // SRL
                    10'b0100000_101: ALUControl = 4'b0111; // SRA
                    default: ALUControl = 4'b00; //Default to AND
                endcase
            end
            default: ALUControl = 4'b0000; // Default to AND
        endcase
    end

endmodule