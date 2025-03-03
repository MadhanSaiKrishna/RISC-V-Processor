`timescale 1ns / 1ps
`include "mem.v"

module DataMemory_tb;
    // Testbench signals
    reg clk;
    reg reset;
    reg [63:0] address;
    reg [63:0] writeData;
    reg MemWrite;
    reg MemRead;
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

    integer i;

    // Task to print all memory values
    task print_memory;
        begin
            $display("\nCurrent Memory State:");
            for (i = 0; i < 32; i = i + 1) begin
                address = i*8 ;
                MemRead = 1;
                #10;
                $display("Memory[%0d] = %d", i, readData);
            end
            MemRead = 0;
        end
    endtask

    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        address = 0;
        writeData = 0;
        MemWrite = 0;
        MemRead = 0;

        // Apply reset
        #10 reset = 0;
        
        // Print initial memory values
        print_memory();
        
        // Read test
        address = 64'h0;
        MemRead = 1;
        #10;
        $display("\nRead Address: %d, Data: %d", address, readData);
        print_memory();
        MemRead = 0;
        
        address = 64'h8;
        MemRead = 1;
        #10;
        $display("\nRead Address: %d, Data: %d", address, readData);
        print_memory();
        MemRead = 0;
        
        // Write test
        address = 64'h10;
        writeData = 64'hDEADBEEFCAFEBABE;
        MemWrite = 1;
        #10;
        MemWrite = 0;
        $display("\nWritten Data %d at Address: %d", writeData, address);
        print_memory();
        
        // Read back written value
        MemRead = 1;
        #10;
        $display("\nRead Address: %d, Data: %d", address, readData);
        print_memory();
        MemRead = 0;
        
        // Invalid address access
        address = 64'h4; // Misaligned access
        MemRead = 1;
        #10;
        $display("\nRead Invalid Address: %d, Data: %d (should be 0)", address, readData);
        print_memory();
        MemRead = 0;
        
        // Finish simulation
        #20;
        $finish;
    end
endmodule