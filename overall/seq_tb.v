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
        
        // Run simulation for 64 clock cycles but print only from 32 to 64
        repeat (45) begin
            #10;
            instr_count = instr_count + 1;
            
            // Print only from instruction 32 to 64
            if (instr_count >= 30)
             begin
                $display("========================");
                $display("Instruction No: %0d | Time: %0t", instr_count, $time);
                $display("PC: %d | Instruction: %h", uut.PC, uut.instruction);
                
                // Instruction Decode Stage
                $display("--- Decode Stage ---");
                $display("Opcode: %b | rs1: %d | rs2: %d | rd: %d | funct3: %b | funct7: %b | Immediate: %d", 
                    uut.idecode.opcode, uut.idecode.rs1, uut.idecode.rs2, uut.idecode.rd, 
                    uut.idecode.funct3, uut.idecode.funct7, uut.immgen.imm);
                
                // Execute Stage
                $display("--- Execute Stage ---");
                $display("ReadData1: %h | ReadData2: %h | Immediate: %d | ImShifted: %d | PCPlusImShifted : %d | BranchTaken : %h ", uut.execute.readData1, uut.execute.readData2, uut.execute.imm, uut.execute.immShifted, uut.execute.PCPlusImmShifted, uut.execute.BranchTaken);
                $display("ALUOp: %b | ALUSrc: %b | ALUControl: %b", uut.execute.ALUOp, uut.execute.ALUSrc, uut.execute.ALUControl);
                $display("ALU Input 1: %h | ALU Input 2: %h | ALU Result: %h | Zero Flag: %b", 
                         uut.execute.readData1, uut.execute.ALUInput2, uut.execute.ALUResult, uut.execute.Zero);
                $display("Branch Taken: %b | Branch Address: %h", uut.execute.BranchTaken, uut.execute.PCPlusImmShifted);
                
                // Data Memory
                $display("--- Data Memory ---");
                $display("Address: %h | Write Data: %h | Mem Read Data: %h | MemWrite: %b | MemRead: %b", 
                    uut.datamem.address, uut.datamem.writeData, uut.datamem.readData, uut.datamem.MemWrite, uut.datamem.MemRead);
                
                // Write Back Stage
                $display("--- Write Back ---");
                $display("ALU Result: %h | Mem Data: %h | Write Data: %h | MemtoReg: %b ", 
                    uut.wb.alu_result, uut.wb.mem_data, uut.wb.write_data, uut.wb.MemtoReg);
                
                // Control Signals
                $display("--- Control Signals ---");
                $display("RegWrite: %b | ALUSrc: %b | MemtoReg: %b | MemRead: %b | MemWrite: %b | Branch: %b | ALUOp: %b", 
                    uut.control.RegWrite, uut.control.ALUSrc, uut.control.MemtoReg, uut.control.MemRead, uut.control.MemWrite, uut.control.Branch, uut.control.ALUOp);
                
                // Print all 32 registers in the register file
                $display("--- Register File ---");
                for (i = 0; i < 32; i = i + 4) begin
                    $display("x[%0d]: %h  x[%0d]: %h  x[%0d]: %h  x[%0d]: %h", 
                        i, uut.regfile.registers[i], i+1, uut.regfile.registers[i+1], 
                        i+2, uut.regfile.registers[i+2], i+3, uut.regfile.registers[i+3]);
                end
                $display("========================");
            end
        end
        
        // End simulation
        $finish;
    end
endmodule
