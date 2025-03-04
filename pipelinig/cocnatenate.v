module ConcatenateExample (
    input wire [31:0] reg1, // 32-bit register 1
    input wire [31:0] reg2, // 32-bit register 2
    output wire [63:0] concatenated // 64-bit concatenated output
);

    // Concatenate reg1 and reg2
    assign concatenated = {reg1, reg2};

endmodule
module ConcatenateExample_tb;

    // Testbench signals
    reg [31:0] reg1;
    reg [31:0] reg2;
    wire [63:0] concatenated;

    // Instantiate the ConcatenateExample module
    ConcatenateExample uut (
        .reg1(reg1),
        .reg2(reg2),
        .concatenated(concatenated)
    );

    initial begin
        // Initialize inputs
        reg1 = 32'h12345678;
        reg2 = 32'h9ABCDEF0;

        // Wait for a short time and display the result
        #10;
        $display("reg1 = %h, reg2 = %h, concatenated = %h", reg1, reg2, concatenated);

        // Change inputs
        reg1 = 32'hFFFFFFFF;
        reg2 = 32'h00000000;

        // Wait for a short time and display the result
        #10;
        $display("reg1 = %h, reg2 = %h, concatenated = %h", reg1, reg2, concatenated);

        // Finish simulation
        #10;
        $finish;
    end

endmodule