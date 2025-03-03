`include "execute.v"

`timescale 1ns/1ps

module ExecuteStage_tb();
    // Inputs
    reg clk;
    reg reset;
    reg [63:0] PC;
    reg [63:0] imm;
    reg [63:0] readData1;
    reg [63:0] readData2;
    reg [2:0] funct3;
    reg [6:0] funct7;
    reg [1:0] ALUOp;
    reg ALUSrc;
    reg Branch;
    reg [3:0] ALUControl;

    // Outputs
    wire [63:0] ALUResult;
    wire Zero;
    wire [63:0] ALUInput2;
    wire [63:0] immShifted;
    wire [63:0] PCPlusImmShifted;
    wire BranchTaken;

    // Instantiate the Unit Under Test (UUT)
    ExecuteStage uut (
        .clk(clk),
        .reset(reset),
        .PC(PC),
        .imm(imm),
        .readData1(readData1),
        .readData2(readData2),
        .funct3(funct3),
        .funct7(funct7),
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

    // Helper task to display test case results
    task display_test_case;
        input [127:0] test_case_name;
        begin
            $display("\n=== %s ===", test_case_name);
            $display("Inputs:");
            $display("  PC = 0x%h, imm = 0x%h", PC, imm);
            $display("  readData1 = 0x%h, readData2 = 0x%h", readData1, readData2);
            $display("  ALUOp = %b, ALUSrc = %b, Branch = %b", ALUOp, ALUSrc, Branch);
            $display("  funct3 = %b, funct7 = %b, ALUControl = %b", funct3, funct7, ALUControl);
            $display("Outputs:");
            $display("  ALUInput2 = 0x%h", ALUInput2);
            $display("  ALUResult = 0x%h", ALUResult);
            $display("  Zero = %b", Zero);
            $display("  immShifted = 0x%h", immShifted);
            $display("  PCPlusImmShifted = 0x%h", PCPlusImmShifted);
            $display("  BranchTaken = %b", BranchTaken);
        end
    endtask
  
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test stimulus
    initial begin
        // Initialize Inputs
        reset = 1;
        PC = 64'h0000000000001000;
        imm = 64'h0000000000000000;
        readData1 = 64'h0000000000000000;
        readData2 = 64'h0000000000000000;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        ALUOp = 2'b00;
        ALUSrc = 0;
        Branch = 0;
        ALUControl = 4'b0000;
        
        // Wait for global reset
        #10;
        reset = 0;
        
        // Test Case 1: R-type ADD instruction (add rd, rs1, rs2)
        #10;
        PC = 64'h0000000000001000;
        imm = 64'h0000000000000010;
        readData1 = 64'h0000000000000015; // 21 in decimal
        readData2 = 64'h000000000000000A; // 10 in decimal
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        ALUOp = 2'b10;
        ALUSrc = 0; // Use readData2
        Branch = 0;
        ALUControl = 4'b0010; // ADD operation
        #10;
        display_test_case("R-type ADD Instruction");
        
        // Test Case 2: R-type SUB instruction (sub rd, rs1, rs2)
        #10;
        PC = 64'h0000000000001004;
        imm = 64'h0000000000000000;
        readData1 = 64'h0000000000000064; // 100 in decimal
        readData2 = 64'h000000000000001E; // 30 in decimal
        funct3 = 3'b000;
        funct7 = 7'b0100000;
        ALUOp = 2'b10;
        ALUSrc = 0; // Use readData2
        Branch = 0;
        ALUControl = 4'b0110; // SUBTRACT operation
        #10;
        display_test_case("R-type SUB Instruction");
        
        // Test Case 3: R-type OR instruction (or rd, rs1, rs2)
        #10;
        PC = 64'h0000000000001008;
        imm = 64'h0000000000000000;
        readData1 = 64'h00000000000000F0; // 240 in decimal
        readData2 = 64'h000000000000000F; // 15 in decimal
        funct3 = 3'b110;
        funct7 = 7'b0000000;
        ALUOp = 2'b10;
        ALUSrc = 0; // Use readData2
        Branch = 0;
        ALUControl = 4'b0001; // OR operation
        #10;
        display_test_case("R-type OR Instruction");
        
        // Test Case 4: Load instruction (ld rd, offset(rs1))
        #10;
        PC = 64'h000000000000100C;
        imm = 64'h0000000000000008; // Offset: 8 bytes
        readData1 = 64'h0000000000001000; // Base address
        readData2 = 64'h0000000000000000; // Not used for ld
        funct3 = 3'b011; // LD instruction
        funct7 = 7'b0000000;
        ALUOp = 2'b00; // Load/Store ALUOp
        ALUSrc = 1; // Use immediate
        Branch = 0;
        ALUControl = 4'b0010; // ADD operation
        #10;
        display_test_case("Load (LD) Instruction");
        
        // Test Case 5: Store instruction (sd rs2, offset(rs1))
        #10;
        PC = 64'h0000000000001010;
        imm = 64'h0000000000000010; // Offset: 16 bytes
        readData1 = 64'h0000000000002000; // Base address
        readData2 = 64'h00000000DEADBEEF; // Data to store
        funct3 = 3'b011; // SD instruction
        funct7 = 7'b0000000;
        ALUOp = 2'b00; // Load/Store ALUOp
        ALUSrc = 1; // Use immediate
        Branch = 0;
        ALUControl = 4'b0010; // ADD operation
        #10;
        display_test_case("Store (SD) Instruction");
        
        // Test Case 6: Branch instruction (beq rs1, rs2, offset) - Branch taken
        #10;
        PC = 64'h0000000000001014;
        imm = 64'h0000000000000050; // Offset: 80 in decimal
        readData1 = 64'h0000000000000064; // Both equal
        readData2 = 64'h0000000000000064;
        funct3 = 3'b000; // BEQ instruction
        funct7 = 7'b0000000;
        ALUOp = 2'b01; // Branch ALUOp
        ALUSrc = 0; // Use readData2
        Branch = 1; // Branch instruction
        ALUControl = 4'b0110; // SUBTRACT operation
        #10;
        display_test_case("Branch (BEQ) Instruction - Branch Taken");
        
        // Test Case 7: Branch instruction (beq rs1, rs2, offset) - Branch not taken
        #10;
        PC = 64'h0000000000001018;
        imm = 64'h0000000000000050; // Offset: 80 in decimal
        readData1 = 64'h0000000000000064; // Not equal
        readData2 = 64'h0000000000000065;
        funct3 = 3'b000; // BEQ instruction
        funct7 = 7'b0000000;
        ALUOp = 2'b01; // Branch ALUOp
        ALUSrc = 0; // Use readData2
        Branch = 1; // Branch instruction
        ALUControl = 4'b0110; // SUBTRACT operation
        #10;
        display_test_case("Branch (BEQ) Instruction - Branch Not Taken");
        
        // Finish simulation
        #10 $finish;
    end
endmodule