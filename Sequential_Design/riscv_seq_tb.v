`timescale 1ns / 1ps
`include "riscv_seq.v"

module TopLevel_tb;
    // Clock and reset
    reg clk;
    reg reset;
    
    // Output monitoring
    wire [63:0] final_rd;
    
    // Instantiate the TopLevel module
    TopLevel uut (
        .clk(clk),
        .reset(reset),
        .final_rd(final_rd)
    );
    
    // Clock generation
    always #5 clk = ~clk; // 10 ns clock period (100 MHz)
    
    integer i; // Declare loop variable
    integer instr_count = 0; // Instruction serial number
    
    initial begin
        // Open file for output logging
        $dumpfile("TopLevel_tb.vcd");
        $dumpvars(0, TopLevel_tb);
        
        // Initialize inputs
        clk = 0;
        reset = 1;
        
        // Apply reset
        #10;
        reset = 0;
        $display("\n=================================================");
                $display("  Instruction No: %0d  |  Time: %0t ns", instr_count, $time);
                $display("=================================================");

                // Program Counter & Instruction
                $display("\n--- Fetch Stage ---");
                $display("PC: %d  |  Instruction: %h", uut.PC, uut.instruction);
                
                // Instruction Decode Stage
                $display("\n--- Decode Stage ---");
                $display("Opcode: %b  |  rs1: %d  |  rs2: %d  |  rd: %d", 
                    uut.idecode.opcode, uut.idecode.rs1, uut.idecode.rs2, uut.idecode.rd);
                $display("funct3: %b  |  funct7: %b  |  Immediate: %d", 
                    uut.idecode.funct3, uut.idecode.funct7, uut.immgen.imm);
                
                // Execute Stage
                $display("\n--- Execute Stage ---");
                $display("ReadData1: %h  |  ReadData2: %h", uut.execute.readData1, uut.execute.readData2);
                $display("Immediate: %d  |  Shifted Immediate: %d", uut.execute.imm, uut.execute.immShifted);
                $display("ALUOp: %b  |  ALUSrc: %b  |  ALUControl: %b", uut.execute.ALUOp, uut.execute.ALUSrc, uut.execute.ALUControl);
                $display("ALU Input 1: %h  |  ALU Input 2: %h  |  ALU Result: %h", 
                    uut.execute.readData1, uut.execute.ALUInput2, uut.execute.ALUResult);
                $display("Zero Flag: %b  |  Branch Taken: %b  |  Branch Address: %h", 
                    uut.execute.Zero, uut.execute.BranchTaken, uut.execute.PCPlusImmShifted);
                
                // Data Memory Stage
                $display("\n--- Data Memory ---");
                $display("Address: %h  |  Write Data: %h  |  Read Data: %h", 
                    uut.datamem.address, uut.datamem.writeData, uut.datamem.readData);
                $display("MemWrite: %b  |  MemRead: %b", uut.datamem.MemWrite, uut.datamem.MemRead);
                
                // Write Back Stage
                $display("\n--- Write Back ---");
                $display("ALU Result: %h  |  Mem Data: %h  |  Write Data: %h", 
                    uut.wb.alu_result, uut.wb.mem_data, uut.wb.wb_out);
                $display("MemtoReg: %b", uut.wb.MemtoReg);
                
                // Control Signals
                $display("\n--- Control Signals ---");
                $display("RegWrite: %b  |  ALUSrc: %b  |  MemtoReg: %b", 
                    uut.control.RegWrite, uut.control.ALUSrc, uut.control.MemtoReg);
                $display("MemRead: %b  |  MemWrite: %b  |  Branch: %b  |  ALUOp: %b", 
                    uut.control.MemRead, uut.control.MemWrite, uut.control.Branch, uut.control.ALUOp);
                
                // Register File Dump
                $display("\n--- Register File (x0 - x31) ---");
                for (i = 0; i < 32; i = i + 4) begin
                    $display("x[%0d]: %h  |  x[%0d]: %h  |  x[%0d]: %h  |  x[%0d]: %h", 
                        i, uut.regfile.registers[i], i+1, uut.regfile.registers[i+1], 
                        i+2, uut.regfile.registers[i+2], i+3, uut.regfile.registers[i+3]);
                end

                // Data Memory Dump
                $display("\n--- Data Memory (Memory[0] - Memory[31]) ---");
                for (i = 0; i < 32; i = i + 4) begin
                    $display("Mem[%0d]: %h  |  Mem[%0d]: %h  |  Mem[%0d]: %h  |  Mem[%0d]: %h", 
                        i, uut.datamem.memory[i], i+1, uut.datamem.memory[i+1], 
                        i+2, uut.datamem.memory[i+2], i+3, uut.datamem.memory[i+3]);
                end

                $display("=================================================\n");

        repeat (16) begin
            #10;
            instr_count = instr_count + 1;
             begin
                $display("\n=================================================");
                $display("  Instruction No: %0d  |  Time: %0t ns", instr_count, $time);
                $display("=================================================");

                // Program Counter & Instruction
                $display("\n--- Fetch Stage ---");
                $display("PC: %d  |  Instruction: %h", uut.PC, uut.instruction);
                
                // Instruction Decode Stage
                $display("\n--- Decode Stage ---");
                $display("Opcode: %b  |  rs1: %d  |  rs2: %d  |  rd: %d", 
                    uut.idecode.opcode, uut.idecode.rs1, uut.idecode.rs2, uut.idecode.rd);
                $display("funct3: %b  |  funct7: %b  |  Immediate: %d", 
                    uut.idecode.funct3, uut.idecode.funct7, uut.immgen.imm);
                
                // Execute Stage
                $display("\n--- Execute Stage ---");
                $display("ReadData1: %h  |  ReadData2: %h", uut.execute.readData1, uut.execute.readData2);
                $display("Immediate: %d  |  Shifted Immediate: %d", uut.execute.imm, uut.execute.immShifted);
                $display("ALUOp: %b  |  ALUSrc: %b  |  ALUControl: %b", uut.execute.ALUOp, uut.execute.ALUSrc, uut.execute.ALUControl);
                $display("ALU Input 1: %h  |  ALU Input 2: %h  |  ALU Result: %h", 
                    uut.execute.readData1, uut.execute.ALUInput2, uut.execute.ALUResult);
                $display("Zero Flag: %b  |  Branch Taken: %b  |  Branch Address: %h", 
                    uut.execute.Zero, uut.execute.BranchTaken, uut.execute.PCPlusImmShifted);
                
                // Data Memory Stage
                $display("\n--- Data Memory ---");
                $display("Address: %h  |  Write Data: %h  |  Read Data: %h", 
                    uut.datamem.address, uut.datamem.writeData, uut.datamem.readData);
                $display("MemWrite: %b  |  MemRead: %b", uut.datamem.MemWrite, uut.datamem.MemRead);
                
                // Write Back Stage
                $display("\n--- Write Back ---");
                $display("ALU Result: %h  |  Mem Data: %h  |  Write Data: %h", 
                    uut.wb.alu_result, uut.wb.mem_data, uut.wb.wb_out);
                $display("MemtoReg: %b", uut.wb.MemtoReg);
                
                // Control Signals
                $display("\n--- Control Signals ---");
                $display("RegWrite: %b  |  ALUSrc: %b  |  MemtoReg: %b", 
                    uut.control.RegWrite, uut.control.ALUSrc, uut.control.MemtoReg);
                $display("MemRead: %b  |  MemWrite: %b  |  Branch: %b  |  ALUOp: %b", 
                    uut.control.MemRead, uut.control.MemWrite, uut.control.Branch, uut.control.ALUOp);
                
                // Register File Dump
                $display("\n--- Register File (x0 - x31) ---");
                for (i = 0; i < 32; i = i + 4) begin
                    $display("x[%0d]: %h  |  x[%0d]: %h  |  x[%0d]: %h  |  x[%0d]: %h", 
                        i, uut.regfile.registers[i], i+1, uut.regfile.registers[i+1], 
                        i+2, uut.regfile.registers[i+2], i+3, uut.regfile.registers[i+3]);
                end

                // Data Memory Dump
                $display("\n--- Data Memory (Memory[0] - Memory[31]) ---");
                for (i = 0; i < 32; i = i + 4) begin
                    $display("Mem[%0d]: %h  |  Mem[%0d]: %h  |  Mem[%0d]: %h  |  Mem[%0d]: %h", 
                        i, uut.datamem.memory[i], i+1, uut.datamem.memory[i+1], 
                        i+2, uut.datamem.memory[i+2], i+3, uut.datamem.memory[i+3]);
                end

                $display("=================================================\n");
            end
        end
        
        // End simulation
        $finish;
    end
endmodule
