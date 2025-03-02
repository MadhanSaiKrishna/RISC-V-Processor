module DataMemory (
    input clk,
    input reset, // Reset signal
    input [63:0] address,
    input [63:0] writeData,
    input MemWrite,
    input MemRead, // MemRead is now an input
    output reg [63:0] readData
);

    // Memory array: 1024 locations (8KB)
    reg [63:0] memory [0:1023];

    // Valid address range: 0 to 1023 * 8 = 8184 (0x1FF8)
    wire valid_address = (address < 64'h2000); // Ensure address is within bounds

    // Initialize memory on reset
    integer i;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 1024; i = i + 1) begin
                memory[i] <= 64'b0; // Initialize memory to all zeros
            end
        end else if (MemWrite && valid_address) begin
            memory[address[12:3]] <= writeData; // Write data to memory
        end
    end

    // Synchronous read operation
    always @(posedge clk) begin
        if (MemRead && valid_address) begin
            readData <= memory[address[12:3]]; // Read data from memory
        end else begin
            readData <= 64'b0; // Force output to zero for invalid access or no read operation
        end
    end

endmodule

