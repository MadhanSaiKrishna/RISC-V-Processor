`include "instruction_fetch.v"

`timescale 1ns / 1ps

module InstructionFetch_tb;

    // Inputs
    reg clk;
    reg reset;
    reg BranchTaken;
    reg [63:0] branchAddr;

    // Outputs
    wire [63:0] PC;
    wire [31:0] instruction;

    // Instantiate the InstructionFetch module
    InstructionFetch uut (
        .clk(clk),
        .reset(reset),
        .BranchTaken(BranchTaken),
        .branchAddr(branchAddr),
        .PC(PC),
        .instruction(instruction)
    );

    // Clock generation
    always #5 clk = ~clk; // 10ns clock period

    // Testbench logic
    initial begin
        // Initialize inputs
        clk = 0;
        reset = 0;
        BranchTaken = 0;
        branchAddr = 0;

        // Apply reset
        reset = 1;
        #10; // Hold reset for 10ns
        reset = 0;
        #10; // Wait for a clock cycle

        // Test Case 1: Normal PC update (no branch)
        $display("\nTest Case 1: Normal PC update (no branch)");
        $display("Time\tPC\t\tInstruction");
        $display("----------------------------------");
        #10; // Wait for PC to update
        $display("%0t\t%h\t%h", $time, PC, instruction);
        #10;
        $display("%0t\t%h\t%h", $time, PC, instruction);
        #10;
        $display("%0t\t%h\t%h", $time, PC, instruction);

        // Test Case 2: Branch to a higher address
        $display("\nTest Case 2: Branch to a higher address");
        BranchTaken = 1;
        branchAddr = 64'h0000000000000020; // Branch to address 0x20
        #10;
        $display("%0t\t%h\t%h", $time, PC, instruction);
        BranchTaken = 0; // Disable branch after one cycle
        #10;
        $display("%0t\t%h\t%h", $time, PC, instruction);
        #10;
        $display("%0t\t%h\t%h", $time, PC, instruction);

        // Test Case 3: Branch to a lower address
        $display("\nTest Case 3: Branch to a lower address");
        BranchTaken = 1;
        branchAddr = 64'h0000000000000008; // Branch to address 0x08
        #10;
        $display("%0t\t%h\t%h", $time, PC, instruction);
        BranchTaken = 0; // Disable branch after one cycle
        #10;
        $display("%0t\t%h\t%h", $time, PC, instruction);
        #10;
        $display("%0t\t%h\t%h", $time, PC, instruction);

        // Test Case 4: Branch to the same address (no change)
        $display("\nTest Case 4: Branch to the same address (no change)");
        BranchTaken = 1;
        branchAddr = PC; // Branch to the current PC (no change)
        #10;
        $display("%0t\t%h\t%h", $time, PC, instruction);
        BranchTaken = 0; // Disable branch after one cycle
        #10;
        $display("%0t\t%h\t%h", $time, PC, instruction);
        #10;
        $display("%0t\t%h\t%h", $time, PC, instruction);

        // Test Case 5: Branch to the last address in memory
        $display("\nTest Case 5: Branch to the last address in memory");
        BranchTaken = 1;
        branchAddr = 64'h0000000000000060; // Branch to address 0x60 (last address)
        #10;
        $display("%0t\t%h\t%h", $time, PC, instruction);
        BranchTaken = 0; // Disable branch after one cycle
        #10;
        $display("%0t\t%h\t%h", $time, PC, instruction);
        #10;
        $display("%0t\t%h\t%h", $time, PC, instruction);

        // Test Case 6: Reset and verify PC is set to 0
        $display("\nTest Case 6: Reset and verify PC is set to 0");
        reset = 1;
        #10;
        reset = 0;
        $display("%0t\t%h\t%h", $time, PC, instruction);

        // End simulation
        $display("\nSimulation completed.");
        $finish;
    end

endmodule