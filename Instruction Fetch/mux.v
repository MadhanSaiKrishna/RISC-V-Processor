// Multiplexer Module
module mux (
    input  wire [63:0] input_0, 
    input  wire [63:0] input_1, 
    input  wire select,         
    output wire [63:0] output_  
);
    assign output_ = select ? input_1 : input_0; 
endmodule