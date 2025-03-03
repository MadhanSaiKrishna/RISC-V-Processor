`include "instruction_decode.v"

`timescale 1ns / 1ps

module ID_tb();
    // Test inputs
    reg [31:0] instruction;
    reg clk;
    reg reset;
    reg regWrite;
    
    // Instruction Decoder outputs
    wire [6:0] opcode;
    wire [4:0] rs1, rs2, rd;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [31:0] id_imm;
    
    // ImmGen outputs
    wire [63:0] imm;
    
    // Register File outputs
    wire [63:0] readData1, readData2;
    reg [63:0] writeData;
    
    // Control Unit outputs
    wire Branch, MemRead, MemtoReg;
    wire [1:0] ALUOp;
    wire MemWrite, ALUSrc, RegWrite_cu;
    
    // Instantiate modules
    InstructionDecoder id (
        .instruction(instruction),
        .opcode(opcode),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .funct3(funct3),
        .funct7(funct7),
        .imm(id_imm)
    );
    
    RegisterFile rf (
        .clk(clk),
        .reset(reset),
        .regWrite(regWrite),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .writeData(writeData),
        .readData1(readData1),
        .readData2(readData2)
    );
    
    ImmGen ig (
        .instruction(instruction),
        .opcode(opcode),
        .imm(imm)
    );
    
    ControlUnit cu (
        .opcode(opcode),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .ALUOp(ALUOp),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite_cu)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Display function for readability
    task display_instruction_info;
        input [31:0] instr;
        input [7:0] instruction_type;
        begin
            $display("----------------------------------------");
            $display("Instruction Type: %s (0x%h)", instruction_type, instr);
            $display("----------------------------------------");
            $display("Instruction Decoder Outputs:");
            $display("  Opcode  = 0b%b (0x%h)", opcode, opcode);
            $display("  rs1     = %d (x%0d)", rs1, rs1);
            $display("  rs2     = %d (x%0d)", rs2, rs2);
            $display("  rd      = %d (x%0d)", rd, rd);
            $display("  funct3  = 0b%b", funct3);
            $display("  funct7  = 0b%b", funct7);
            $display("  ID Imm  = 0x%h", id_imm);
            
            $display("\nImmGen Output:");
            $display("  64-bit Imm = 0x%h", imm);
            
            $display("\nRegister File Outputs:");
            $display("  readData1 = 0x%h", readData1);
            $display("  readData2 = 0x%h", readData2);
            
            $display("\nControl Unit Outputs:");
            $display("  Branch   = %b", Branch);
            $display("  MemRead  = %b", MemRead);
            $display("  MemtoReg = %b", MemtoReg);
            $display("  ALUOp    = %b", ALUOp);
            $display("  MemWrite = %b", MemWrite);
            $display("  ALUSrc   = %b", ALUSrc);
            $display("  RegWrite = %b", RegWrite_cu);
            $display("\n");
        end
    endtask
    
    // Test stimulus
    initial begin
        // Initialize
        reset = 1;
        regWrite = 0;
        writeData = 64'h0;
        instruction = 32'h0;
        
        // Reset the register file
        #10 reset = 0;
        
        // Test R-type instruction: ADD x3, x1, x2 (add contents of registers x1 and x2, store in x3)
        // 0000000 00010 00001 000 00011 0110011
        #10 instruction = 32'h002081B3;  // add x3, x1, x2
        #10 display_instruction_info("R-TYPE", instruction);
        
        // Test R-type instruction: SUB x4, x1, x2 (subtract contents of registers x1 and x2, store in x4)
        // 0100000 00010 00001 000 00100 0110011
        #10 instruction = 32'h40208233;  // sub x4, x1, x2
        #10 display_instruction_info("R-TYPE", instruction);
        
        // Test R-type instruction: OR x5, x1, x2 (bitwise OR of registers x1 and x2, store in x5)
        // 0000000 00010 00001 110 00101 0110011
        #10 instruction = 32'h0020E2B3;  // or x5, x1, x2
        #10 display_instruction_info("R-TYPE", instruction);
        
        // Test B-type instruction: BEQ x1, x2, 12 (Branch if x1 equals x2, to PC+12)
        // 0000000 00010 00001 000 00110 1100011
        #10 instruction = 32'h00208663;  // beq x1, x2, 12
        #10 display_instruction_info("B-TYPE", instruction);
        
        // End simulation
        $finish;
    end
    
endmodule