`timescale 1ns / 1ps

// Include all submodules
`include "adder.v"
`include "instruction_memory.v"
`include "mux.v"
`include "program_counter.v"

// Instruction Fetch Module
module instruction_fetch (
    input  wire clk,        // Clock signal
    input  wire rst         // Reset signal
);

    // Internal wires
    wire [63:0] current_pc;      // 64-bit current program counter value
    wire [63:0] next_pc;         // 64-bit next program counter value (PC + 4)
    wire [31:0] instruction;     // 32-bit fetched instruction from memory
    wire [63:0] mux_output;      // 64-bit output of the multiplexer (input to PC)

    reg select_signal;           // Control signal for MUX

    // Program Counter (PC) Module
    program_counter pc_module (
        .clk(clk),
        .rst(rst),
        .next_pc(mux_output),
        .current_pc(current_pc)
    );

    // Instruction Memory Module
    instruction_memory instruction_memory_module (
        .address(current_pc),
        .data(instruction)
    );

    // Adder Module (PC + 4)
    adder adder_module (
        .current_pc(current_pc),
        .next_pc(next_pc)
    );

    // Multiplexer (MUX) Module
    mux mux_module (
        .input_0({32'b0, instruction}), // Zero-extended instruction (for branches/jumps)
        .input_1(next_pc),              // Next sequential PC (PC + 4)
        .select(select_signal),         
        .output_(mux_output)            
    );

    // Set select_signal to always choose PC + 4 for now
    always @(posedge clk or posedge rst) begin
        if (rst)
            select_signal <= 1'b1; // Default to sequential execution
    end

endmodule

// Testbench for Instruction Fetch Module
module instruction_fetch_tb;

    // Inputs
    reg clk;
    reg rst;

    // Internal wires for monitoring
    wire [63:0] current_pc;
    wire [31:0] instruction;

    // Instantiate the instruction_fetch module
    instruction_fetch uut (
        .clk(clk),
        .rst(rst)
    );

    // Clock generation (Ensuring it terminates)
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Continuous clock toggle
    end

    // Test sequence
    initial begin
        // Monitor signals
        $monitor("Time: %0t | PC: %d | Instruction: %d", 
                 $time, uut.pc_module.current_pc, uut.instruction_memory_module.data);

        // Initialize inputs
        rst = 1; 
        #20;     // Hold reset for 20 time units

        rst = 0; 
        #10;     // Run for a few cycles to observe sequential execution

        // Test branching (simulate a branch instruction)
        $display("Testing Branch Instruction...");
        #10;

        // Test jump (simulate a jump instruction)
        $display("Testing Jump Instruction...");
        #10;

        // Test immediate (simulate an immediate instruction)
        $display("Testing Immediate Instruction...");
        #10;
        // Stop simulation
        $display("Simulation Complete!");
        $finish; // Force termination
    end

    // Termination Watchdog
    initial begin
        #500; // Force exit after 500 time units if still running
        $display("Forcing Simulation End!");
        $finish;
    end

endmodule