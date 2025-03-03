`include "mem.v"

`timescale 1ns / 1ps

module DataMemory_tb;

    // Inputs
    reg clk;
    reg reset;
    reg [63:0] address;
    reg [63:0] writeData;
    reg MemWrite;
    reg MemRead;

    // Outputs
    wire [63:0] readData;

    // Instantiate the DataMemory module
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

    // Testbench logic
    initial begin
        // Initialize inputs
        clk = 0;
        reset = 0;
        address = 0;
        writeData = 0;
        MemWrite = 0;
        MemRead = 0;

        // Apply reset
        reset = 1;
        #10; // Hold reset for 10ns
        reset = 0;
        #10; // Wait for a clock cycle

        // Test Case 1: Read from memory after reset
        $display("Test Case 1: Read from memory after reset");
        MemRead = 1;
        address = 0; // Read from address 0
        #10;
        $display("Address: %h, Read Data: %h", address, readData);
        MemRead = 0;

        // Test Case 2: Write to memory
        $display("\nTest Case 2: Write to memory");
        MemWrite = 1;
        address = 8; // Write to address 8
        writeData = 64'hDEADBEEFDEADBEEF;
        #10;
        $display("Address: %h, Write Data: %h", address, writeData);
        MemWrite = 0;

        // Test Case 3: Read back the written data
        $display("\nTest Case 3: Read back the written data");
        MemRead = 1;
        address = 8; // Read from address 8
        #10;
        $display("Address: %h, Read Data: %h", address, readData);
        MemRead = 0;

        // Test Case 4: Write to another memory location
        $display("\nTest Case 4: Write to another memory location");
        MemWrite = 1;
        address = 16; // Write to address 16
        writeData = 64'hCAFEBABECAFEBABE;
        #10;
        $display("Address: %h, Write Data: %h", address, writeData);
        MemWrite = 0;

        // Test Case 5: Read back the second written data
        $display("\nTest Case 5: Read back the second written data");
        MemRead = 1;
        address = 16; // Read from address 16
        #10;
        $display("Address: %h, Read Data: %h", address, readData);
        MemRead = 0;

        // Test Case 6: Attempt to read without MemRead enabled
        $display("\nTest Case 6: Attempt to read without MemRead enabled");
        address = 8; // Address with valid data
        #10;
        $display("Address: %h, Read Data: %h (MemRead = 0)", address, readData);

        // Test Case 7: Attempt to write without MemWrite enabled
        $display("\nTest Case 7: Attempt to write without MemWrite enabled");
        address = 24; // New address
        writeData = 64'h1234567812345678;
        #10;
        $display("Address: %h, Write Data: %h (MemWrite = 0)", address, writeData);
        MemRead = 1;
        #10;
        $display("Address: %h, Read Data: %h (Verify no write occurred)", address, readData);
        MemRead = 0;

        // Test Case 8: Reset memory and verify initialization
        $display("\nTest Case 8: Reset memory and verify initialization");
        reset = 1;
        #10;
        reset = 0;
        MemRead = 1;
        address = 0; // Read from address 0
        #10;
        $display("Address: %h, Read Data: %h (After reset)", address, readData);
        MemRead = 0;

        // End simulation
        $display("\nSimulation completed.");
        $finish;
    end

endmodule