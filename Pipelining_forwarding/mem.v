module DataMemory (
    input clk,
    input reset, // Reset signal
    input [63:0] address,
    input [63:0] writeData,
    input MemWrite,
    input MemRead, // MemRead is now an input
    input Zero,
    output reg [63:0] readData,
    output BranchTaken,
    input Branch
);

    // Memory array: 32 locations (256 bytes)
    reg [63:0] memory [0:31];

    // Initialize memory on reset
    integer i;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1) begin
                memory[i] <= i; // Initialize memory with index values
            end
        end else if (MemWrite) begin
            memory[address[8:3]] <= writeData; // Write data to memory
        end
    end

    // Asynchronous read operation
    always @(*) begin
        if (MemRead) begin
            readData = memory[address[8:3]]; // Read data from memory
        end else begin
            readData = 64'b0; // Force output to zero for invalid access or no read operation
        end
    end
    assign BranchTaken = Branch & Zero;
endmodule
