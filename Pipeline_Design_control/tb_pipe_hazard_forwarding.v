`timescale 1ns / 1ps

`include "pipeline_forwarding_hazard.v"

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
    
    // Testbench variables
    integer i; // Loop variable
    integer cycle_count = 1; // Clock cycle counter
    
    // Testbench logic
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

        // Display the first instruction and PC value
        $display("\n=================================================");
        $display("  Initial State (Before Simulation Starts)");
        $display("=================================================");
        $display("PC: %h  |  Instruction: %h", uut.PC, uut.instruction);
        $display("=================================================\n");
        
        // Main simulation loop
        for (cycle_count = 1; cycle_count <= 20; cycle_count = cycle_count + 1) begin
            #10; // Wait for one clock cycle
            
            // Display pipeline state for each cycle
            $display("\n=================================================");
            $display("  Clock Cycle: %0d  |  Time: %0t ns", cycle_count, $time);
            $display("=================================================");
            
            // Fetch Stage
            $display("\n--- Fetch Stage ---");
            $display("PC: %h  |  Instruction: %h | BranchTaken: %h | Stall: %h", 
                uut.PC, uut.instruction, uut.branch_taken, uut.stall);
            
            // Decode Stage
            $display("\n--- Decode Stage ---");
            $display("Opcode: %b  |  rs1: %d  |  rs2: %d  |  rd: %d", 
                uut.opcode, uut.rs1_addr, uut.rs2_addr, uut.rd_addr);
            $display("funct3: %b  |  funct7: %b  |  Immediate: %h", 
                uut.funct3, uut.funct7, uut.imm);
            
            // Control Signals in Decode Stage
            $display("\n--- Control Signals (Decode Stage) ---");
            $display("Branch: %b  |  MemRead: %b  |  MemtoReg: %b", 
                uut.Branch, uut.MemRead, uut.MemtoReg);
            $display("ALUOp: %b  |  MemWrite: %b  |  ALUSrc: %b  |  RegWrite: %b", 
                uut.ALUOp, uut.MemWrite, uut.ALUSrc, uut.RegWrite);
            
            // Execute Stage
            $display("\n--- Execute Stage ---");
            $display("ReadData1: %h  |  ReadData2: %h", 
                uut.ID_EX_readData1, uut.ID_EX_readData2);
            $display("ALUResult: %h  |  Zero: %b | PC: %h | ImmShifted: %d | PCPlusImmShifted: %h | ALUInput1: %h | ALUInput2: %h", 
                uut.ALUResult, uut.Zero, uut.ID_EX_PC, uut.immShifted, uut.PCPlusImmShifted, uut.execute.forwardedData1, uut.execute.forwardedData2);
            
            // Control Signals in Execute Stage
            $display("\n--- Control Signals (Execute Stage) ---");
            $display("RegWrite: %b  |  MemtoReg: %b  |  Branch: %b", 
                uut.ID_EX_RegWrite, uut.ID_EX_MemtoReg, uut.ID_EX_Branch);
            $display("MemRead: %b  |  MemWrite: %b  |  ALUSrc: %b  |  ALUOp: %b", 
                uut.ID_EX_MemRead, uut.ID_EX_MemWrite, uut.ID_EX_ALUSrc, uut.ID_EX_ALUOp);
            
            // Forwarding Unit Outputs
            $display("\n--- Forwarding Unit ---");
            $display("ForwardA: %b  |  ForwardB: %b", uut.ForwardA, uut.ForwardB);
            $display("EX_MEM_ALUResult: %h  |  MEM_WB_ALUResult: %h", 
                uut.EX_MEM_ALUResult, uut.MEM_WB_ALUResult);
            $display("EX_MEM_rd_addr: %d  |  MEM_WB_rd_addr: %d", 
                uut.EX_MEM_rd_addr, uut.MEM_WB_rd_addr);
            $display("ID_EX_RegisterRs1: %d  |  ID_EX_RegisterRs2: %d", 
                uut.ID_EX_RegisterRs1, uut.ID_EX_RegisterRs2);
            
            // Forwarded Data and MUX Inputs
            $display("\n--- Forwarded Data and MUX Inputs ---");
            $display("forwardedData1: %h  |  forwardedData2: %h", 
                uut.ALUInput1, uut.ALUInput2);
            $display("MUX Inputs (ALUInput2):");
            $display("  readData2: %h  |  EX_MEM_ALUResult: %h  |  MEM_WB_ALUResult: %h", 
                uut.ID_EX_readData2, uut.EX_MEM_ALUResult, uut.MEM_WB_ALUResult);
            $display("MUX Inputs (ALU Input 1):");
            $display("  readData1: %h  |  EX_MEM_ALUResult: %h  |  MEM_WB_ALUResult: %h", 
                uut.ID_EX_readData1, uut.EX_MEM_ALUResult, uut.MEM_WB_ALUResult);
            
            // Memory Stage
            $display("\n--- Memory Stage ---");
            $display("ALUResult: %h  |  MemRead: %b  |  MemWrite: %b | WriteData: %h", 
                uut.EX_MEM_ALUResult, uut.EX_MEM_MemRead, uut.EX_MEM_MemWrite, uut.EX_MEM_readData2);
            $display("MemReadData: %h", uut.mem_readData);
            
            // Control Signals in Memory Stage
            $display("\n--- Control Signals (Memory Stage) ---");
            $display("RegWrite: %b  |  MemtoReg: %b  |  Branch: %b", 
                uut.EX_MEM_RegWrite, uut.EX_MEM_MemtoReg, uut.EX_MEM_Branch);
            $display("MemRead: %b  |  MemWrite: %b", 
                uut.EX_MEM_MemRead, uut.EX_MEM_MemWrite);
            
            // Write Back Stage
            $display("\n--- Write Back Stage ---");
            $display("WriteData: %h", uut.write_data);
            
            // Control Signals in Write Back Stage
            $display("\n--- Control Signals (Write Back Stage) ---");
            $display("RegWrite: %b  |  MemtoReg: %b", 
                uut.MEM_WB_RegWrite, uut.MEM_WB_MemtoReg);
            
            // Pipeline Registers
            $display("\n--- Pipeline Registers ---");
            $display("IF/ID: PC=%h  |  Instruction=%h", 
                uut.IF_ID_PC, uut.IF_ID_instruction);
            $display("ID/EX: RegWrite=%b  |  MemtoReg=%b  |  ALUOp=%b  |  ALUSrc=%b", 
                uut.ID_EX_RegWrite, uut.ID_EX_MemtoReg, uut.ID_EX_ALUOp, uut.ID_EX_ALUSrc);
            $display("EX/MEM: ALUResult=%h  |  Zero=%b  |  MemWrite=%b", 
                uut.EX_MEM_ALUResult, uut.EX_MEM_Zero, uut.EX_MEM_MemWrite);
            $display("MEM/WB: RegWrite=%b  |  MemtoReg=%b  |  WriteData=%h", 
                uut.MEM_WB_RegWrite, uut.MEM_WB_MemtoReg, uut.write_data);
            
            // Register File Dump
            $display("\n--- Register File ---");
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
        end
        
        $finish;
    end
endmodule