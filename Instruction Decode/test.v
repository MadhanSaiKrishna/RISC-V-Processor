
`include "instruction_decode.v"

module testbench_risc_v;
    // Test signals
    reg [31:0] instruction;
    wire [6:0] opcode;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire [31:0] imm;
    
    // Control signals for verification
    wire Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite;
    wire [1:0] ALUOp;
    
    // Module instantiations
    InstructionDecoder id (
        .instruction(instruction),
        .opcode(opcode),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .funct3(funct3),
        .funct7(funct7),
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
        .RegWrite(RegWrite)
    );
    
    // Task to display instruction details
    task display_instruction;
        input [31:0] inst;
        input [255:0] inst_name;
        begin
            $display("==================================================================");
            $display("Testing instruction: %s (0x%h)", inst_name, inst);
            $display("------------------------------------------------------------------");
            $display("Decoded fields:");
            $display("  opcode = 0b%b (0x%h)", opcode, opcode);
            $display("  rd     = %d (x%d)", rd, rd);
            $display("  rs1    = %d (x%d)", rs1, rs1);
            $display("  rs2    = %d (x%d)", rs2, rs2);
            $display("  funct3 = 0b%b", funct3);
            $display("  funct7 = 0b%b", funct7);
            $display("  imm    = 0x%h", imm);
            $display("Control signals:");
            $display("  RegWrite = %b", RegWrite);
            $display("  ALUSrc   = %b", ALUSrc);
            $display("  MemWrite = %b", MemWrite);
            $display("  MemRead  = %b", MemRead);
            $display("  Branch   = %b", Branch);
            $display("  MemtoReg = %b", MemtoReg);
            $display("  ALUOp    = %b", ALUOp);
            $display("==================================================================\n");
        end
    endtask
    
    initial begin
        // Wait to stabilize signals
        #5;
        
        // 1. ADD instruction: add x5, x6, x7
        // Format: funct7[31:25] rs2[24:20] rs1[19:15] funct3[14:12] rd[11:7] opcode[6:0]
        // Encoding: 0000000 00111 00110 000 00101 0110011
        instruction = 32'h00730233;  // add x4, x6, x7
        #10;
        display_instruction(instruction, "ADD x4, x6, x7");
        
        // 2. SUB instruction: sub x9, x10, x11
        // SUB uses funct7=0100000 to differentiate from ADD
        // Encoding: 0100000 01011 01010 000 01001 0110011
        instruction = 32'h40b504b3;  // sub x9, x10, x11
        #10;
        display_instruction(instruction, "SUB x9, x10, x11");
        
        // 3. AND instruction: and x12, x13, x14
        // AND uses funct3=111
        // Encoding: 0000000 01110 01101 111 01100 0110011
        instruction = 32'h00e6f633;  // and x12, x13, x14
        #10;
        display_instruction(instruction, "AND x12, x13, x14");
        
        // 4. OR instruction: or x15, x16, x17
        // OR uses funct3=110
        // Encoding: 0000000 10001 10000 110 01111 0110011
        instruction = 32'h011807b3;  // or x15, x16, x17
        #10;
        display_instruction(instruction, "OR x15, x16, x17");
        
        // 5. LD instruction: ld x8, 16(x20)
        // Format: imm[11:0] rs1[19:15] funct3[14:12] rd[11:7] opcode[6:0]
        // Encoding: 000000010000 10100 011 01000 0000011
        instruction = 32'h010a3403;  // ld x8, 16(x20)
        #10;
        display_instruction(instruction, "LD x8, 16(x20)");
        
        // 6. SD instruction: sd x22, -24(x23)
        // Format: imm[11:5] rs2[24:20] rs1[19:15] funct3[14:12] imm[4:0] opcode[6:0]
        // Encoding: 1111111 10110 10111 011 11000 0100011
        instruction = 32'hfe6b8c23;  // sd x22, -24(x23)
        #10;
        display_instruction(instruction, "SD x22, -24(x23)");
        
        // 7. BEQ instruction: beq x24, x25, offset(16)
        // Format: imm[12|10:5] rs2[24:20] rs1[19:15] funct3[14:12] imm[4:1|11] opcode[6:0]
        // Encoding: 0000000 11001 11000 000 10000 1100011
        instruction = 32'h019c0863;  // beq x24, x25, 16
        #10;
        display_instruction(instruction, "BEQ x24, x25, 16");
        
        $finish;
    end
    
    // Additional logging for waveform analysis
    initial begin
        $dumpfile("risc_v_testbench.vcd");
        $dumpvars(0, testbench_risc_v);
    end
endmodule