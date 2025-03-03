module alu2 (
    input signed [63:0] rs1,
    input signed [63:0] rs2,
    input [3:0] ALUControl, // ALU control signal
    output reg signed [63:0] rd
);

    wire signed [63:0] add_result;
    wire signed [63:0] sub_result;
    wire signed [63:0] xor_result;
    wire signed [63:0] or_result;
    wire signed [63:0] and_result;
    wire signed [63:0] sll_result;
    wire signed [63:0] srl_result;
    wire signed [63:0] sra_result;
    wire slt_result;
    wire sltu_result;
    wire add_cout, sub_cout;

    cla adder (
        .A(rs1),
        .B(rs2),
        .Cin(1'b0),
        .Sum(add_result),
        .Cout(add_cout)
    );

    cla_subtractor subtractor (
        .A(rs1),
        .B(rs2),
        .Sub(sub_result),
        .Cout(sub_cout)
    );

    XOR xor_op (
        .A(rs1),
        .B(rs2),
        .XOR(xor_result)
    );

    OR or_op (
        .A(rs1),
        .B(rs2),
        .OR(or_result)
    );

    AND and_op (
        .A(rs1),
        .B(rs2),
        .AND(and_result)
    );

    sll shift_left (
        .a(rs1),
        .b(rs2),
        .y(sll_result)
    );

    srl shift_right_logical (
        .a(rs1),
        .b(rs2),
        .y(srl_result)
    );

    sra shift_right_arithmetic (
        .a(rs1),
        .b(rs2),
        .y(sra_result)
    );

    SLT set_less_than (
        .A(rs1),
        .B(rs2),
        .result(slt_result)
    );

    SLTU set_less_than_unsigned (
        .A(rs1),
        .B(rs2),
        .result(sltu_result)
    );

    always @(*) begin
        case (ALUControl)
            4'b0010: rd = add_result;  // ADD
            4'b0110: rd = sub_result;  // SUB
            4'b0100: rd = sll_result;  // SLL
            4'b1000: rd = {63'b0, slt_result};  // SLT
            4'b1001: rd = {63'b0, sltu_result}; // SLTU
            4'b0011: rd = xor_result;  // XOR
            4'b0101: rd = srl_result;  // SRL
            4'b0111: rd = sra_result;  // SRA
            4'b0001: rd = or_result;   // OR
            4'b0000: rd = and_result;  // AND
            default: rd = 64'b0;
        endcase
    end
endmodule

module cla (
    input  signed [63:0] A, B,
    input                Cin,
    output signed [63:0] Sum,
    output               Cout
);

    wire [63:0] P, G;   
    wire [64:0] C;      

    assign C[0] = Cin;

    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin : GP_GEN
            xor (P[i], A[i], B[i]); 
            and (G[i], A[i], B[i]);
        end
    endgenerate

    generate
        for (i = 0; i < 64; i = i + 1) begin : CARRY_GEN
            wire temp;
            and (temp, P[i], C[i]);
            or  (C[i+1], G[i], temp);
        end
    endgenerate

    generate
        for (i = 0; i < 64; i = i + 1) begin : SUM_GEN
            xor (Sum[i], P[i], C[i]);
        end
    endgenerate

    assign Cout = C[64]; 

endmodule

module AND (
    input signed [63:0] A,
    input signed [63:0] B,
    output signed [63:0] AND
);

genvar i;
generate
    for (i = 0; i < 64; i = i + 1) begin
        and gate(AND[i], A[i], B[i]);
    end
endgenerate

endmodule

module OR (
    input signed [63:0] A,
    input signed [63:0] B,
    output signed [63:0] OR
);

genvar i;
generate
    for (i = 0; i < 64; i = i + 1) begin
        or gate(OR[i], A[i], B[i]);
    end
endgenerate

endmodule

module XOR (
    input signed [63:0] A,
    input signed [63:0] B,
    output signed [63:0] XOR
);

genvar i;
generate
    for (i = 0; i < 64; i = i + 1) begin
        xor gate(XOR[i], A[i], B[i]);
    end
endgenerate

endmodule

module cla_subtractor (
    input  signed [63:0] A, B,
    output signed [63:0] Sub,
    output               Cout
);

    wire signed [63:0] B_complement;
    wire signed [63:0] TwoComp_B;
    wire signed [63:0] Sum;
    wire               CarryOut;

    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin : NOT_GEN
            not (B_complement[i], B[i]);
        end
    endgenerate

    cla adder_1 (
        .A(B_complement),
        .B(64'b0), 
        .Cin(1'b1), 
        .Sum(TwoComp_B),
        .Cout() // We ignore carry-out in two’s complement calculation
    );

    cla adder_2 (
        .A(A),
        .B(TwoComp_B),
        .Cin(1'b0), 
        .Sum(Sum),
        .Cout(CarryOut)
    );

    assign Sub = Sum;
    assign Cout = CarryOut;

endmodule

module sll (
    input  wire [63:0] a,      // 64-bit input data
    input  wire [63:0] b,      // 64-bit register providing the shift amount (only last 6 bits used)
    output wire [63:0] y       // 64-bit output of the shift
);

    // Declare intermediate shift results for each stage
    wire [63:0] s0, s1, s2, s3, s4, s5;

    // Use only the last 6 bits of b for the shift amount
    wire [5:0] shift_amount = b[5:0];

    // Stage 0: Shift by 1 bit (if shift_amount[0] == 1)
    assign s0 = shift_amount[0] ? {a[62:0], 1'b0} : a;

    // Stage 1: Shift by 2 bits (if shift_amount[1] == 1)
    assign s1 = shift_amount[1] ? {s0[61:0], 2'b00} : s0;

    // Stage 2: Shift by 4 bits (if shift_amount[2] == 1)
    assign s2 = shift_amount[2] ? {s1[59:0], 4'b0000} : s1;

    // Stage 3: Shift by 8 bits (if shift_amount[3] == 1)
    assign s3 = shift_amount[3] ? {s2[55:0], 8'b00000000} : s2;

    // Stage 4: Shift by 16 bits (if shift_amount[4] == 1)
    assign s4 = shift_amount[4] ? {s3[47:0], 16'b0000000000000000} : s3;

    // Stage 5: Shift by 32 bits (if shift_amount[5] == 1)
    assign s5 = shift_amount[5] ? {s4[31:0], 32'b00000000000000000000000000000000} : s4;

    // Final shifted result
    assign y = s5;

endmodule

module SLT (
    input signed [63:0] A,
    input signed [63:0] B,
    output wire result
);

    wire signed [63:0] diff;
    wire Cout;

    // Subtractor: A - B
    cla_subtractor sub(
        .A(A),
        .B(B),
        .Sub(diff),
        .Cout()  
    );

    // Intermediate signals for conditional logic
    wire sign_diff, both_pos, both_neg;
    wire result_case1, result_case2, result_case3;

    // If the sign bits differ (A[63] != B[63])
    xor g1(sign_diff, A[63], B[63]);

    // Both A and B are positive
    and g2(both_pos, ~A[63], ~B[63]);

    // Both A and B are negative
    and g3(both_neg, A[63], B[63]);

    // Case 1: A and B have different signs, and A is negative
    and g4(result_case1, sign_diff, A[63]);

    // Case 2: A and B have the same sign, and diff is negative
    and g5(result_case2, ~sign_diff, diff[63]);

    // Case 3: Both A and B are negative, and diff is positive
    and g6(result_case3, both_neg, ~diff[63]);

    // Result is true if any of the cases are true
    or g7(result, result_case1, result_case2, result_case3);

endmodule

module magnitude_comparator_gates (
  input A,
  input B,
  output C, // A < B
  output D, // A = B
  output E  // A > B
);

  wire A_not;
  wire B_not;
  wire A_and_B_not;
  wire A_not_and_B;

  not g1 (A_not, A);      
  not g2 (B_not, B);      

  and g3 (A_and_B_not, A, B_not); // A AND (NOT B)  (A > B)
  and g4 (A_not_and_B, A_not, B); // (NOT A) AND B  (A < B)
  
  xor g5 (D, A, B); // A XOR B will be 1 if A and B are different and 0 if they are equal
  not g6 (D_not, D); // NOT (A XOR B) which is equivalent to A=B

  assign C = A_not_and_B; // A < B
  assign E = A_and_B_not; // A > B
  assign D = D_not;      // A = B

endmodule

module SLTU (
    input signed [63:0] A,
    input signed [63:0] B,
    output wire result
);

    integer i;
    reg found;
    reg result_reg;
    
    // Internal signals for comparison of A and B bits
    wire [63:0] C, D, E; // C = A < B, D = A = B, E = A > B
    
    // Declare unsigned versions of A and B
    wire [63:0] A_unsigned = $unsigned(A);
    wire [63:0] B_unsigned = $unsigned(B);
    
    // Instantiate the magnitude comparator for each bit
    genvar j;
    generate
        for (j = 0; j < 64; j = j + 1) begin : comp_gen
            magnitude_comparator_gates comp (
                .A(A_unsigned[j]),
                .B(B_unsigned[j]),
                .C(C[j]),
                .D(D[j]),
                .E(E[j])
            );
        end
    endgenerate
    
    always @(*) begin
        found = 0;
        result_reg = 0;
        
        for (i = 63; i >= 0; i = i - 1) begin
            if (!found) begin
                if (C[i]) begin  // If A[i] < B[i]
                    result_reg = 1; // Set result to 1
                    found = 1; // Set found flag to stop further checking
                end else if (E[i]) begin  // If A[i] > B[i]
                    result_reg = 0; // Set result to 0
                    found = 1; // Set found flag to stop further checking
                end
            end
        end
    end

    assign result = result_reg;

endmodule

module sra (
    input  signed [63:0] a,      // 64-bit signed input data
    input  wire [63:0] b,        // 64-bit register providing the shift amount (only last 6 bits used)
    output signed [63:0] y       // 64-bit signed output of the shift
);

    // Declare intermediate shift results for each stage
    wire signed [63:0] s0, s1, s2, s3, s4, s5;

    // Use only the last 6 bits of b for the shift amount
    wire [5:0] shift_amount = b[5:0];

    // Compute sign extension mask
    wire signed [63:0] sign_ext = {64{a[63]}};

    // Stage 0: Shift by 1 bit (if shift_amount[0] == 1)
    assign s0 = shift_amount[0] ? {sign_ext[63], a[63:1]} : a;

    // Stage 1: Shift by 2 bits (if shift_amount[1] == 1)
    assign s1 = shift_amount[1] ? {sign_ext[63:62], s0[63:2]} : s0;

    // Stage 2: Shift by 4 bits (if shift_amount[2] == 1)
    assign s2 = shift_amount[2] ? {sign_ext[63:60], s1[63:4]} : s1;

    // Stage 3: Shift by 8 bits (if shift_amount[3] == 1)
    assign s3 = shift_amount[3] ? {sign_ext[63:56], s2[63:8]} : s2;

    // Stage 4: Shift by 16 bits (if shift_amount[4] == 1)
    assign s4 = shift_amount[4] ? {sign_ext[63:48], s3[63:16]} : s3;

    // Stage 5: Shift by 32 bits (if shift_amount[5] == 1)
    assign s5 = shift_amount[5] ? {sign_ext[63:32], s4[63:32]} : s4;

    // Final shifted result
    assign y = s5;

endmodule

module srl (
    input  signed [63:0] a,      // 64-bit signed input data
    input  wire [63:0] b,        // 64-bit register providing the shift amount (only last 6 bits used)
    output signed [63:0] y       // 64-bit signed output of the shift
);

    // Declare intermediate shift results for each stage
    wire signed [63:0] s0, s1, s2, s3, s4, s5;

    // Use only the last 6 bits of b for the shift amount
    wire [5:0] shift_amount = b[5:0];

    // Stage 0: Shift by 1 bit (if shift_amount[0] == 1)
    assign s0 = shift_amount[0] ? {1'b0, a[63:1]} : a;

    // Stage 1: Shift by 2 bits (if shift_amount[1] == 1)
    assign s1 = shift_amount[1] ? {2'b00, s0[63:2]} : s0;

    // Stage 2: Shift by 4 bits (if shift_amount[2] == 1)
    assign s2 = shift_amount[2] ? {4'b0000, s1[63:4]} : s1;

    // Stage 3: Shift by 8 bits (if shift_amount[3] == 1)
    assign s3 = shift_amount[3] ? {8'b00000000, s2[63:8]} : s2;

    // Stage 4: Shift by 16 bits (if shift_amount[4] == 1)
    assign s4 = shift_amount[4] ? {16'b0000000000000000, s3[63:16]} : s3;

    // Stage 5: Shift by 32 bits (if shift_amount[5] == 1)
    assign s5 = shift_amount[5] ? {32'b00000000000000000000000000000000, s4[63:32]} : s4;

    // Final shifted result
    assign y = s5;

endmodule