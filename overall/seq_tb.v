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
        
        // Run simulation for 64 clock cycles
        repeat (64) begin
            #10;
            instr_count = instr_count + 1;
            
            // Print general execution details
            $display("Instruction No: %0d | Time: %0t | PC: %h | Instruction: %h", instr_count, $time, uut.PC, uut.instruction);
            
            // Execute stage outputs
            $display("ALU Result: %h | Zero Flag: %b", uut.ALUResult, uut.Zero);
            
            // Data Memory stage signals
            $display("Data Memory -> Address: %h | Write Data: %h | Mem Read Data: %h | MemWrite: %b | MemRead: %b", 
                uut.datamem.address, uut.datamem.writeData, uut.datamem.readData, uut.datamem.MemWrite, uut.datamem.MemRead);
            
            // Write Back stage signals
            $display("Write Back -> ALU Result: %h | Mem Data: %h | Write Data: %h | MemtoReg: %b | RD: %d | Id_RD: %d", 
                uut.wb.alu_result, uut.wb.mem_data, uut.wb.write_data, uut.wb.MemtoReg, uut.wb.rd, uut.idecode.rd);
            
            // Control Signals
            $display("Control Signals -> RegWrite: %b | ALUSrc: %b | MemtoReg: %b | MemRead: %b | MemWrite: %b | Branch: %b | ALUOp: %b", 
                uut.control.RegWrite, uut.control.ALUSrc, uut.control.MemtoReg, uut.control.MemRead, uut.control.MemWrite, uut.control.Branch, uut.control.ALUOp);
            
            // Print all 32 registers in the register file
            $display("=============================================");
            for (i = 0; i < 32; i = i + 4) begin
                
                $display("x[%0d]: %h  x[%0d]: %h  x[%0d]: %h  x[%0d]: %h", 
                    i, uut.regfile.registers[i], i+1, uut.regfile.registers[i+1], 
                    i+2, uut.regfile.registers[i+2], i+3, uut.regfile.registers[i+3]);
            end
            $display("=============================================");
        end
        
        // End simulation
        $finish;
    end
endmodule
