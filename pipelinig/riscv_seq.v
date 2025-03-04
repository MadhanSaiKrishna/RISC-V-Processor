`include "aluformain.v"
`include "execute.v"
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
    wire [2:0] funct3;
    wire [6:0] funct7;

    // Instruction Decode Stage
    wire [6:0] opcode;
    wire [4:0] rs1_addr;
    wire [4:0] rs2_addr;
    wire [4:0] rd_addr;
    wire [63:0] imm; //  was output of decode, now connects to ImmGen

    // Control Unit Signals
    wire Branch;
    wire MemRead;
    wire MemtoReg;
    wire [1:0] ALUOp;
    wire MemWrite;
    wire ALUSrc;
    wire RegWrite;

    // Register File Signals
    wire [63:0] readData1;
    wire [63:0] ALUInput2;
    wire [63:0] readData2;
    
    // Execute Stage
    wire [63:0] ALUResult;
    wire [63:0] immShifted;
    wire [63:0] PCPlusImmShifted;
    wire Zero;

    // Data Memory Signals
    wire [63:0] mem_readData;
    
    // Writeback stage
    wire [63:0] write_data;
    
    //-------------------------------------------------------------------------
    //  Module Instantiations
    //-------------------------------------------------------------------------

    // Instruction Fetch Stage
    InstructionFetch ifetch (
        .clk(clk),
        .reset(reset),
        .BranchTaken(BranchTaken),
        .branchAddr(PCPlusImmShifted),
        .PC(PC),
        .instruction(instruction)
    );

    // Instruction Decode Stage
    InstructionDecoder idecode (
        .instruction(instruction),
        .opcode(opcode),
        .rs1(rs1_addr),
        .rs2(rs2_addr),
        .funct3(funct3),
        .funct7(funct7),
        .rd(rd_addr)
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
        .regWrite(RegWrite),
        .rs1(rs1_addr),
        .rs2(rs2_addr),
        .rd(rd_addr),
        .writeData(write_data),
        .readData1(readData1),
        .readData2(readData2)
    );

    // Immediate Generator
    ImmGen immgen (
        .instruction(instruction),
        .opcode(opcode),
        .imm(imm)
    );

    //ALU control stage
    ALUControlUnit alucontrolunit (
        .funct3(funct3),
        .funct7(funct7),
        .ALUOp(ALUOp),
        .ALUControl(ALUControl)
    );

    //Internal wire for alucontrol
    wire [3:0] ALUControl;
    
    
    // Execute Stage
    ExecuteStage execute (
        .clk(clk),
        .reset(reset),
        .PC(PC),
        .imm(imm),
        .readData1(readData1),
        .readData2(readData2),
        .ALUOp(ALUOp),
        .ALUSrc(ALUSrc),
        .Branch(Branch),
        .ALUResult(ALUResult),
        .Zero(Zero),
        .ALUInput2(ALUInput2),
        .ALUControl(ALUControl),
        .immShifted(immShifted),
        .PCPlusImmShifted(PCPlusImmShifted),
        .BranchTaken(BranchTaken)
    );

    // Data Memory
    DataMemory datamem (
        .clk(clk),
        .reset(reset),
        .address(ALUResult),
        .writeData(readData2),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .readData(mem_readData)
    );

    // Write Back Stage
    write_back wb(
        .MemtoReg(MemtoReg),
        .alu_result(ALUResult),
        .mem_data(mem_readData),
        .wb_out(write_data)
    );
    
    
    //Assign the branchaddress and PCSrc
    // assign branchAddr = execute.BranchAddr;
    // assign PCSrc = execute.BranchTaken;
    assign final_rd = regfile.registers[31]; //output of reg 31

endmodule

