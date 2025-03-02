`include "InstructionFetch.v"

module tb_InstructionFetch;

    // Testbench signals
    reg clk, reset, PCSrc;
    reg [63:0] branchAddr;
    wire [63:0] PC;
    wire [31:0] instruction;

    // Instantiate the DUT (Device Under Test)
    InstructionFetch uut (
        .clk(clk),
        .reset(reset),
        .PCSrc(PCSrc),
        .branchAddr(branchAddr),
        .PC(PC),
        .instruction(instruction)
    );

    // Clock Generation (10ns period -> 100MHz clock)
    always #5 clk = ~clk;

    // Test sequence (Branching Conditions)
    initial begin
        $dumpfile("test.vcd"); // Waveform file
        $dumpvars(0, tb_InstructionFetch);

        // Initialize signals
        clk = 0;
        reset = 1;
        PCSrc = 0;
        branchAddr = 64'b0;

        #40; // Hold reset long enough to ensure PC starts from 0

        // Check if PC is reset to 0
        if (PC !== 64'd0) begin
            $display("Error: PC did not reset to 0");
            $finish;
        end

        reset = 0; // Release reset
        $display("Time: %0t ns | Clock: %b | PC[6:2]: %b | Instruction: %h", 
                 $time, clk, PC[6:2], instruction);

        // Execute a few instructions
        repeat (10) begin
            #10;
            $display("Time: %0t ns | Clock: %b | PC[6:2]: %b | Instruction: %h", 
                     $time, clk, PC[6:2], instruction);
        end

        // Perform a branch
        PCSrc = 1;
        branchAddr = 64'b0000000000000000000000000000000000000000000000000000000000010000
        ; // Branching to instruction at address 16
        #10; // Wait for one cycle to apply branch

        $display(" BRANCH TAKEN  5th instruction", 
                 );
        $display("Time: %0t ns | Clock: %b | PC[6:2]: %b | Instruction: %h", 
                     $time, clk, PC[6:2], instruction);
        PCSrc = 0; // Return to normal execution

        // Continue execution from the branch address
        repeat (5) begin
            #10;
            $display("Time: %0t ns | Clock: %b | PC[6:2]: %b | Instruction: %h", 
                     $time, clk, PC[6:2], instruction);
        end

        $finish;
    end

endmodule
