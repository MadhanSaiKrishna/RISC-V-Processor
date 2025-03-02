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


module DataMemory_tb;

    reg clk;
    reg reset; // Reset signal
    reg [63:0] address;
    reg [63:0] writeData;
    reg MemWrite;
    reg MemRead; // MemRead is now a reg
    wire [63:0] readData;

    // Instantiate DataMemory module
    DataMemory uut (
        .clk(clk),
        .reset(reset),
        .address(address),
        .writeData(writeData),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .readData(readData)
    );

    // Clock generation
    always #5 clk = ~clk; // 10ns clock period

    initial begin
        // Initialize signals
        clk = 0;
        reset = 1; // Assert reset to initialize memory
        address = 0;
        writeData = 0;
        MemWrite = 0;
        MemRead = 0;

        // Release reset after initialization
        #10;
        reset = 0;

        // ----------------------------------------------
        // Test Case 1: Write to Address 0x20
        // ----------------------------------------------
        #10;
        address = 64'h20; 
        writeData = 64'h123456789ABCDEF0;
        MemWrite = 1;  
        #10; MemWrite = 0;  // Disable write

        // Verify write operation by reading back the data
        #10;
        MemRead = 1;
        #10;
        if (readData === 64'h123456789ABCDEF0)
            $display("[PASS] Write to Address 0x20: Data = %h", readData);
        else
            $display("[FAIL] Write to Address 0x20: Data = %h (Expected: 123456789ABCDEF0)", readData);
        MemRead = 0;

        // ----------------------------------------------
        // Test Case 2: Write to Address 0x40
        // ----------------------------------------------
        #10;
        address = 64'h40; 
        writeData = 64'hFEDCBA9876543210;
        MemWrite = 1;  
        #10; MemWrite = 0;  

        // Verify write operation by reading back the data
        #10;
        MemRead = 1;
        #10;
        if (readData === 64'hFEDCBA9876543210)
            $display("[PASS] Write to Address 0x40: Data = %h", readData);
        else
            $display("[FAIL] Write to Address 0x40: Data = %h (Expected: FEDCBA9876543210)", readData);
        MemRead = 0;

        // ----------------------------------------------
        // Test Case 3: Write to First Memory Location (0x0)
        // ----------------------------------------------
        #10;
        address = 64'h0;
        writeData = 64'hDEADBEEFCAFEBABE;
        MemWrite = 1;  
        #10; MemWrite = 0;

        // Verify write operation by reading back the data
        #10;
        MemRead = 1;
        #10;
        if (readData === 64'hDEADBEEFCAFEBABE)
            $display("[PASS] Write to First Memory Location: Data = %h", readData);
        else
            $display("[FAIL] Write to First Memory Location: Data = %h (Expected: DEADBEEFCAFEBABE)", readData);
        MemRead = 0;

        // ----------------------------------------------
        // Test Case 4: Write to Last Memory Location (0x7F8)
        // ----------------------------------------------
        #10;
        address = 64'h7F8;
        writeData = 64'hAABBCCDDEEFF0011;
        MemWrite = 1;  
        #10; MemWrite = 0;

        // Verify write operation by reading back the data
        #10;
        MemRead = 1;
        #10;
        if (readData === 64'hAABBCCDDEEFF0011)
            $display("[PASS] Write to Last Memory Location: Data = %h", readData);
        else
            $display("[FAIL] Write to Last Memory Location: Data = %h (Expected: AABBCCDDEEFF0011)", readData);
        MemRead = 0;

        // ----------------------------------------------
        // Test Case 5: Attempt to Write Out-of-Bounds (Should be Ignored)
        // ----------------------------------------------
        #10;
        address = 64'h2000; // Invalid address (8192 in decimal, which is out-of-bounds)
        writeData = 64'hBADBADBADBADBADB;
        MemWrite = 1;
        #10; MemWrite = 0;

        // Verify that MemWrite is ignored for out-of-bounds address
        #10;
        MemRead = 1;
        #10;
        if (readData === 64'b0)
            $display("[PASS] Out-of-bounds write correctly ignored.");
        else begin
            $display(readData);
            $display(uut.valid_address);
            $display("[FAIL] Out-of-bounds write incorrectly enabled.");
        end
        MemRead = 0;

        // ----------------------------------------------
        // Test Case 6: Ensure Valid Memory Not Corrupted
        // ----------------------------------------------
        #10;
        address = 64'h20;
        MemRead = 1;
        #10;
        if (readData === 64'h123456789ABCDEF0)
            $display("[PASS] Address 0x20 still holds correct value: %h", readData);
        else
            $display("[FAIL] Address 0x20 corrupted: %h (Expected: 123456789ABCDEF0)", readData);
        MemRead = 0;

        // End simulation
        #20;
        $finish;
    end
endmodule