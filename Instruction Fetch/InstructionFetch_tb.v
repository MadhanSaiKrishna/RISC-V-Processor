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

    // Test sequence (Fetch All Instructions)
    initial begin
        $dumpfile("test.vcd"); // Waveform file
        $dumpvars(0, tb_InstructionFetch);

        // Initialize signals
        clk = 0;
        reset = 1;
        PCSrc = 0;

        #40; // Hold reset long enough to ensure PC starts from 0

        // Check if PC is reset to 0
        if (PC !== 64'd0) begin
            $display("Error: PC did not reset to 0");
            $finish;
        end

        reset = 0; // Release reset

        // Initial fetch printout (before first clock edge)
        $display("Time: %0t ns | Clock: %b | PC[6:2]: %b | Instruction: %h", 
                 $time, clk, PC[6:2], instruction);

        // Fetch and print ALL instructions (32 total)
        repeat (31) begin
            #10;
            $display("Time: %0t ns | Clock: %b | PC[6:2]: %b | Instruction: %h", 
                     $time, clk, PC[6:2], instruction);
        end

        $finish;
    end

endmodule
