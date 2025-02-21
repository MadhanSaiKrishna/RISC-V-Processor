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