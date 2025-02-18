`timescale 1ns / 1ps

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
        $monitor("Time: %0t | PC: %h | Instruction: %h", 
                 $time, uut.pc_module.current_pc, uut.instruction_memory_module.data);

        // Initialize inputs
        rst = 1; 
        #20;     // Hold reset for 20 time units

        rst = 0; 
        #100;    // Run simulation for a while

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



// Adder Module
module adder (
    input  wire [63:0] current_pc, 
    output wire [63:0] next_pc     
);
    assign next_pc = current_pc + 64'd4; // Increment PC by 4
endmodule

// Instruction Memory Module
module instruction_memory (
    input  wire [63:0] address, 
    output wire [31:0] data     
);

    reg [31:0] instruction_memory [0:255];

    // Initialize memory with hardcoded instructions
    initial begin
        instruction_memory[0] = 32'h3c011001; 
        instruction_memory[1] = 32'h34280000; 
        instruction_memory[2] = 32'h3c011001; 
        instruction_memory[3] = 32'h342d0030; 
        instruction_memory[4] = 32'h8dad0000; 
        instruction_memory[5] = 32'h240a0001; 
        instruction_memory[6] = 32'h46241000; 
        instruction_memory[7] = 32'had0a0000; 
        instruction_memory[8] = 32'had0a0004; 
        instruction_memory[9] = 32'h21a9fffe; 

        for (integer i = 10; i < 256; i = i + 1) begin
            instruction_memory[i] = 32'h00000013; // NOP
        end
    end

    // Use word-aligned access
    assign data = instruction_memory[address[7:2]]; 

endmodule

// Multiplexer Module
module mux (
    input  wire [63:0] input_0, 
    input  wire [63:0] input_1, 
    input  wire select,         
    output wire [63:0] output_  
);
    assign output_ = select ? input_1 : input_0; 
endmodule

// Program Counter Module
module program_counter (
    input  wire clk,           
    input  wire rst,           
    input  wire [63:0] next_pc, 
    output reg  [63:0] current_pc 
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            current_pc <= 64'b0; 
        else
            current_pc <= next_pc; 
    end
endmodule
