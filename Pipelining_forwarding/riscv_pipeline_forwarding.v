`include "aluformain.v"
`include "execute_forwarding.v"
`include "instruction_decode.v"
`include "instruction_fetch.v"
`include "mem.v"
`include "write_back.v"
module TopLevel (
    input clk,
    input reset,
    output wire [63:0] final_rd // Monitor final register values (optional)
);

    //-------------------------------------------------------------------------
    //  Wires and Registers
    //-------------------------------------------------------------------------

    // Instruction Fetch Stage
    wire PCSrc;
    wire [63:0] branchAddr;
    wire [63:0] PC;
    wire [31:0] instruction;
    
    // Pipeline Registers (Separate for each stage)
    // IF/ID Stage
    reg [63:0] IF_ID_PC;
    reg [31:0] IF_ID_instruction;

    // ID/EX Stage
    reg ID_EX_RegWrite;
    reg ID_EX_MemtoReg;
    reg ID_EX_Branch;
    reg ID_EX_MemRead;
    reg ID_EX_MemWrite;
    reg ID_EX_ALUSrc;
    reg [1:0] ID_EX_ALUOp;
    reg [63:0] ID_EX_PC;
    reg [63:0] ID_EX_readData1;
    reg [63:0] ID_EX_readData2;
    reg [63:0] ID_EX_imm;
    reg [6:0] ID_EX_funct7;
    reg [2:0] ID_EX_funct3;
    reg [4:0] ID_EX_rd_addr;
    reg [4:0] ID_EX_RegisterRs1;
    reg [4:0] ID_EX_RegisterRs2;

    // EX/MEM Stage
    reg EX_MEM_RegWrite;
    reg EX_MEM_MemtoReg;
    reg EX_MEM_Branch;
    reg EX_MEM_MemRead;
    reg EX_MEM_MemWrite;
    reg [63:0] EX_MEM_PCPlusImmShifted;
    reg EX_MEM_Zero;
    reg [63:0] EX_MEM_ALUResult;
    reg [63:0] EX_MEM_readData2;
    reg [4:0] EX_MEM_rd_addr;

    // MEM/WB Stage
    reg MEM_WB_RegWrite;
    reg MEM_WB_MemtoReg;
    reg [63:0] MEM_WB_mem_readData;
    reg [63:0] MEM_WB_ALUResult;
    reg [4:0] MEM_WB_rd_addr;

    // Instruction Decode Stage
    wire [6:0] opcode;
    wire [4:0] rs1_addr, rs2_addr, rd_addr;
    wire [63:0] imm;
    wire [2:0] funct3;
    wire [6:0] funct7;
    
    // Control Signals
    wire RegWrite, MemtoReg, Branch, MemRead, MemWrite, ALUSrc;
    wire [1:0] ALUOp;

    // Register File Signals
    wire [63:0] readData1, readData2, ALUInput2;
    
    // Execute Stage
    wire [3:0] ALUControl;
    wire [63:0] ALUResult, immShifted, PCPlusImmShifted, ALUInput1;
    wire Zero;

    // Data Memory Signals
    wire [63:0] mem_readData;
    wire branch_taken;
    
    // Write Back Stage
    wire [63:0] write_data;
    
    // Forwarding Unit Signals
    wire [1:0] ForwardA, ForwardB;
    
    //-------------------------------------------------------------------------
    //  Pipeline Register Assignments
    //-------------------------------------------------------------------------

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all pipeline registers
            IF_ID_PC <= 0;
            IF_ID_instruction <= 0;
            ID_EX_RegWrite <= 0;
            ID_EX_MemtoReg <= 0;
            ID_EX_Branch <= 0;
            ID_EX_MemRead <= 0;
            ID_EX_MemWrite <= 0;
            ID_EX_ALUSrc <= 0;
            ID_EX_ALUOp <= 0;
            ID_EX_PC <= 0;
            ID_EX_readData1 <= 0;
            ID_EX_readData2 <= 0;
            ID_EX_imm <= 0;
            ID_EX_funct7 <= 0;
            ID_EX_funct3 <= 0;
            ID_EX_rd_addr <= 0;
            ID_EX_RegisterRs1 <= 0;
            ID_EX_RegisterRs2 <= 0;
            EX_MEM_RegWrite <= 0;
            EX_MEM_MemtoReg <= 0;
            EX_MEM_Branch <= 0;
            EX_MEM_MemRead <= 0;
            EX_MEM_MemWrite <= 0;
            EX_MEM_PCPlusImmShifted <= 0;
            EX_MEM_Zero <= 0;
            EX_MEM_ALUResult <= 0;
            EX_MEM_readData2 <= 0;
            EX_MEM_rd_addr <= 0;
            MEM_WB_RegWrite <= 0;
            MEM_WB_MemtoReg <= 0;
            MEM_WB_mem_readData <= 0;
            MEM_WB_ALUResult <= 0;
            MEM_WB_rd_addr <= 0;
        end else begin
            // IF/ID Stage
            IF_ID_PC <= PC;
            IF_ID_instruction <= instruction;

            // ID/EX Stage
            ID_EX_RegWrite <= RegWrite;
            ID_EX_MemtoReg <= MemtoReg;
            ID_EX_Branch <= Branch;
            ID_EX_MemRead <= MemRead;
            ID_EX_MemWrite <= MemWrite;
            ID_EX_ALUSrc <= ALUSrc;
            ID_EX_ALUOp <= ALUOp;
            ID_EX_PC <= IF_ID_PC;
            ID_EX_readData1 <= readData1;
            ID_EX_readData2 <= readData2;
            ID_EX_imm <= imm;
            ID_EX_funct7 <= funct7;
            ID_EX_funct3 <= funct3;
            ID_EX_rd_addr <= rd_addr;
            ID_EX_RegisterRs1 <= rs1_addr;
            ID_EX_RegisterRs2 <= rs2_addr;

            // EX/MEM Stage
            EX_MEM_RegWrite <= ID_EX_RegWrite;
            EX_MEM_MemtoReg <= ID_EX_MemtoReg;
            EX_MEM_Branch <= ID_EX_Branch;
            EX_MEM_MemRead <= ID_EX_MemRead;
            EX_MEM_MemWrite <= ID_EX_MemWrite;
            EX_MEM_PCPlusImmShifted <= PCPlusImmShifted;
            EX_MEM_Zero <= Zero;
            EX_MEM_ALUResult <= ALUResult;
            EX_MEM_readData2 <= ALUInput2;
            EX_MEM_rd_addr <= ID_EX_rd_addr;

            // MEM/WB Stage
            MEM_WB_RegWrite <= EX_MEM_RegWrite;
            MEM_WB_MemtoReg <= EX_MEM_MemtoReg;
            MEM_WB_mem_readData <= mem_readData;
            MEM_WB_ALUResult <= EX_MEM_ALUResult;
            MEM_WB_rd_addr <= EX_MEM_rd_addr;
        end
    end
    
    //-------------------------------------------------------------------------
    //  Module Instantiations
    //-------------------------------------------------------------------------

    // Instruction Fetch Stage
    InstructionFetch ifetch (
        .clk(clk),
        .reset(reset),
        .BranchTaken(branch_taken),
        .branchAddr(EX_MEM_PCPlusImmShifted),
        .PC(PC),
        .instruction(instruction)
    );
    
    // Instruction Decode Stage
    InstructionDecoder idecode (
        .instruction(IF_ID_instruction), // Use separate instruction register
        .opcode(opcode),
        .rs1(rs1_addr),
        .rs2(rs2_addr),
        .rd(rd_addr),
        .funct3(funct3),
        .funct7(funct7)
    );
    
    // Control Unit
    ControlUnit control (
        .opcode(opcode),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .ALUOp(ALUOp),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite)
    );
    
    // Register File
    RegisterFile regfile (
        .clk(clk),
        .reset(reset),
        .regWrite(MEM_WB_RegWrite),
        .rs1(rs1_addr),
        .rs2(rs2_addr),
        .rd(MEM_WB_rd_addr),
        .writeData(write_data),
        .readData1(readData1),
        .readData2(readData2)
    );
    
    // Immediate Generator
    ImmGen immgen (
        .instruction(IF_ID_instruction),
        .opcode(opcode),
        .imm(imm)
    );
    
    // ALU Control Stage
    ALUControlUnit alucontrolunit (
        .funct3(ID_EX_funct3),
        .funct7(ID_EX_funct7),
        .ALUOp(ID_EX_ALUOp),
        .ALUControl(ALUControl)
    );
    
    // Forwarding Unit
    ForwardingUnit forwardingUnit (
        .ID_EX_RegisterRs1(ID_EX_RegisterRs1),
        .ID_EX_RegisterRs2(ID_EX_RegisterRs2),
        .EX_MEM_RegisterRd(EX_MEM_rd_addr),
        .MEM_WB_RegisterRd(MEM_WB_rd_addr),
        .EX_MEM_RegWrite(EX_MEM_RegWrite),
        .MEM_WB_RegWrite(MEM_WB_RegWrite),
        .ForwardA(ForwardA),
        .ForwardB(ForwardB)
    );
    
    // Execute Stage
    ExecuteStage execute (
        .clk(clk),
        .reset(reset),
        .PC(ID_EX_PC),
        .imm(ID_EX_imm),
        .readData1(ID_EX_readData1),
        .readData2(ID_EX_readData2),
        .ALUOp(ID_EX_ALUOp),
        .ALUSrc(ID_EX_ALUSrc),
        .Branch(ID_EX_Branch),
        .ALUResult(ALUResult),
        .Zero(Zero),
        .ALUInput2(ALUInput2),
        .ALUControl(ALUControl),
        .immShifted(immShifted),
        .PCPlusImmShifted(PCPlusImmShifted),
        // Forwarding Unit Inputs
        .EX_MEM_ALUResult(EX_MEM_ALUResult),
        .MEM_WB_ALUResult(MEM_WB_ALUResult),
        .MEM_WB_mem_readData(MEM_WB_mem_readData),
        .EX_MEM_RegWrite(EX_MEM_RegWrite),
        .MEM_WB_RegWrite(MEM_WB_RegWrite),
        .EX_MEM_rd_addr(EX_MEM_rd_addr),
        .MEM_WB_rd_addr(MEM_WB_rd_addr),
        .ID_EX_RegisterRs1(ID_EX_RegisterRs1),
        .ID_EX_RegisterRs2(ID_EX_RegisterRs2),
        .ForwardA(ForwardA),
        .ForwardB(ForwardB),
        .forwardedData1(ALUInput1)
    );
    
    // Data Memory
    DataMemory datamem (
        .clk(clk),
        .reset(reset),
        .address(EX_MEM_ALUResult),
        .writeData(EX_MEM_readData2),
        .MemWrite(EX_MEM_MemWrite),
        .MemRead(EX_MEM_MemRead),
        .readData(mem_readData),
        .BranchTaken(branch_taken),
        .Branch(EX_MEM_Branch),
        .Zero(EX_MEM_Zero)
    );
    
    // Write Back Stage
    write_back wb(
        .MemtoReg(MEM_WB_MemtoReg),
        .alu_result(MEM_WB_ALUResult),
        .mem_data(MEM_WB_mem_readData),
        .wb_out(write_data)
    );
    
    assign final_rd = write_data; // Output write data

endmodule