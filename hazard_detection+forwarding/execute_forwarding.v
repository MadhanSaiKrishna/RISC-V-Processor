module ForwardingUnit (
    input [4:0] ID_EX_RegisterRs1,
    input [4:0] ID_EX_RegisterRs2,
    input [4:0] EX_MEM_RegisterRd,
    input [4:0] MEM_WB_RegisterRd,
    input EX_MEM_RegWrite,
    input MEM_WB_RegWrite,
    input MEM_WB_memRead,
    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB
);
    always @(*) begin
        ForwardA = 2'b00;
        ForwardB = 2'b00;

        if (EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0)) begin
            if (EX_MEM_RegisterRd == ID_EX_RegisterRs1)
                ForwardA = 2'b10;
            if (EX_MEM_RegisterRd == ID_EX_RegisterRs2)
                ForwardB = 2'b10;
        end

        if (MEM_WB_RegWrite && (MEM_WB_RegisterRd != 0)) begin
            if ((MEM_WB_RegisterRd == ID_EX_RegisterRs1) && !(EX_MEM_RegWrite && (EX_MEM_RegisterRd == ID_EX_RegisterRs1)))
                ForwardA = 2'b01;
            
            if ((MEM_WB_RegisterRd == ID_EX_RegisterRs2) && !(EX_MEM_RegWrite && (EX_MEM_RegisterRd == ID_EX_RegisterRs2)))
                ForwardB = 2'b01;
        end

        if (MEM_WB_memRead && (MEM_WB_RegisterRd != 0)) begin
            if (MEM_WB_RegisterRd == ID_EX_RegisterRs1)
                ForwardA = 2'b11;
            if (MEM_WB_RegisterRd == ID_EX_RegisterRs2)
                ForwardB = 2'b11;
        end
    end
endmodule

module ExecuteStage (
    input clk,
    input reset,
    input [63:0] PC,
    input [63:0] imm,
    input [63:0] readData1,
    input [63:0] readData2,
    input [2:0] funct3,
    input [6:0] funct7,
    input [1:0] ALUOp,
    input ALUSrc,
    input Branch,
    output wire [63:0] ALUResult,
    output wire Zero,
    input [3:0] ALUControl,
    output wire [63:0] immShifted,
    output wire [63:0] PCPlusImmShifted,

    input [63:0] EX_MEM_ALUResult,
    input [63:0] MEM_WB_ALUResult,
    input [63:0] MEM_WB_mem_readData,
    input EX_MEM_RegWrite,
    input MEM_WB_RegWrite,
    input MEM_WB_memRead,
    input [4:0] EX_MEM_rd_addr,
    input [4:0] MEM_WB_rd_addr,
    input [4:0] ID_EX_RegisterRs1,
    input [4:0] ID_EX_RegisterRs2,
    input [1:0] ForwardA,
    input [1:0] ForwardB,
    output [63:0] forwardedData1,
    output [63:0] forwardedData2
);
    assign forwardedData1 = 
        (ForwardA == 2'b10) ? EX_MEM_ALUResult :  
        (ForwardA == 2'b01) ? MEM_WB_ALUResult :  
        (ForwardA == 2'b11) ? MEM_WB_mem_readData : 
        readData1;

    assign forwardedData2 = 
        (ForwardB == 2'b10) ? EX_MEM_ALUResult :  
        (ForwardB == 2'b01) ? MEM_WB_ALUResult :  
        (ForwardB == 2'b11) ? MEM_WB_mem_readData : 
        readData2;

    wire [63:0] ALUInput2;
    assign ALUInput2 = ALUSrc ? imm : forwardedData2;

    alu2 mainALU (
        .rs1(forwardedData1),
        .rs2(ALUInput2),
        .ALUControl(ALUControl),
        .rd(ALUResult)
    );

    alu2 shiftALU (
        .rs1(imm),
        .rs2(64'd1),
        .ALUControl(4'b0100),
        .rd(immShifted)
    );

    alu2 addALU (
        .rs1(PC),
        .rs2(immShifted),
        .ALUControl(4'b0010),
        .rd(PCPlusImmShifted)
    );

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