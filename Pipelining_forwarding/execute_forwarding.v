module ForwardingUnit (
    input [4:0] ID_EX_RegisterRs1,  // Rs1 from ID/EX stage
    input [4:0] ID_EX_RegisterRs2,  // Rs2 from ID/EX stage
    input [4:0] EX_MEM_RegisterRd,  // Rd from EX/MEM stage
    input [4:0] MEM_WB_RegisterRd,  // Rd from MEM/WB stage
    input EX_MEM_RegWrite,          // RegWrite signal from EX/MEM stage
    input MEM_WB_RegWrite,          // RegWrite signal from MEM/WB stage
    output reg [1:0] ForwardA,      // Forwarding control for ALU input 1
    output reg [1:0] ForwardB       // Forwarding control for ALU input 2
);

    always @(*) begin
        // Default to no forwarding
        ForwardA = 2'b00;
        ForwardB = 2'b00;

        // EX hazard (EX/MEM forwarding)
        if (EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0) && (EX_MEM_RegisterRd == ID_EX_RegisterRs1)) begin
            ForwardA = 2'b10; // Forward EX/MEM_ALUResult to ALU input 1
        end
        if (EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0) && (EX_MEM_RegisterRd == ID_EX_RegisterRs2)) begin
            ForwardB = 2'b10; // Forward EX/MEM_ALUResult to ALU input 2
        end

        // MEM hazard (MEM/WB forwarding)
        if (MEM_WB_RegWrite && (MEM_WB_RegisterRd != 0) && 
            !(EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0) && (EX_MEM_RegisterRd == ID_EX_RegisterRs1)) &&
            (MEM_WB_RegisterRd == ID_EX_RegisterRs1)) begin
            ForwardA = 2'b01; // Forward MEM/WB_ALUResult to ALU input 1
        end
        if (MEM_WB_RegWrite && (MEM_WB_RegisterRd != 0) && 
            !(EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0) && (EX_MEM_RegisterRd == ID_EX_RegisterRs2)) &&
            (MEM_WB_RegisterRd == ID_EX_RegisterRs2)) begin
            ForwardB = 2'b01; // Forward MEM/WB_ALUResult to ALU input 2
        end
    end

endmodule


module ExecuteStage (
    input clk,                // Clock signal
    input reset,              // Reset signal
    input [63:0] PC,          // Current Program Counter
    input [63:0] imm,         // Immediate value
    input [63:0] readData1,   // Data from source register 1
    input [63:0] readData2,   // Data from source register 2
    input [2:0] funct3,       // Function field 3 (for ALU control)
    input [6:0] funct7,       // Function field 7 (for ALU control)
    input [1:0] ALUOp,        // ALU operation control signal
    input ALUSrc,             // ALU source selection
    input Branch,             // Branch control signal
    output wire [63:0] ALUResult, // Result from ALU
    output wire Zero,         // Zero flag from ALU
    output wire [63:0] ALUInput2, // Output for testbench monitoring
    // output wire [63:0] ALUInput1
    input [3:0] ALUControl,   // ALU control signal
    output wire [63:0] immShifted,
    output wire [63:0] PCPlusImmShifted,

    // Forwarding Unit Inputs
    input [63:0] EX_MEM_ALUResult, // ALU result from EX/MEM stage
    input [63:0] MEM_WB_ALUResult, // ALU result from MEM/WB stage
    input [63:0] MEM_WB_mem_readData, // Memory read data from MEM/WB stage
    input EX_MEM_RegWrite,    // RegWrite signal from EX/MEM stage
    input MEM_WB_RegWrite,    // RegWrite signal from MEM/WB stage
    input [4:0] EX_MEM_rd_addr, // Destination register from EX/MEM stage
    input [4:0] MEM_WB_rd_addr, // Destination register from MEM/WB stage
    input [4:0] ID_EX_RegisterRs1, // Rs1 from ID/EX stage
    input [4:0] ID_EX_RegisterRs2,  // Rs2 from ID/EX stage
    input [1:0] ForwardA,     // Forwarding control for ALU input 1
    input [1:0] ForwardB,      // Forwarding control for ALU input 2
    output [63:0] forwardedData1 // Forwarded data for ALU input 1 (to display in the top level module)
);

    // Internal signals for forwarded values
    wire [63:0] forwardedData1;
    wire [63:0] forwardedData2;

    // Forwarding logic for ALU input 1
    assign forwardedData1 = 
        (ForwardA == 2'b10) ? EX_MEM_ALUResult :
        (ForwardA == 2'b01) ? MEM_WB_ALUResult :
        readData1;
                    
    // Forwarding logic for ALU input 2
    assign forwardedData2 = 
        (ForwardB == 2'b10) ? EX_MEM_ALUResult :
        (ForwardB == 2'b01) ? MEM_WB_ALUResult :
        readData2;

    // MUX for ALU input 2 selection
    assign ALUInput2 = ALUSrc ? imm : forwardedData2;

    // Main ALU
    alu2 mainALU (
        .rs1(forwardedData1),
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

    // ALU for adding PC and shifted immediate value
    alu2 addALU (
        .rs1(PC),
        .rs2(immShifted),
        .ALUControl(4'b0010), // ADD operation
        .rd(PCPlusImmShifted)
    );

    // Zero flag
    assign Zero = (ALUResult == 64'b0);

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