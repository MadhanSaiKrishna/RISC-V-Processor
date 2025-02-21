// Adder Module
module adder (
    input  wire [63:0] current_pc, 
    output wire [63:0] next_pc     
);
    assign next_pc = current_pc + 64'd4; // Increment PC by 4
endmodule