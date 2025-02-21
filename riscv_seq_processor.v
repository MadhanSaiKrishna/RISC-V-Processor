module riscv_seq_processor (
    input wire clk, reset
);
    // ========== IF Stage Signals ==========
    wire [31:0] pc, instruction;
    
    // ========== ID Stage Signals ==========
    wire [4:0] rs1, rs2, rd;
    wire [31:0] reg_read_data1, reg_read_data2, imm_ext;
    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire branch, mem_read, mem_to_reg, mem_write, alu_src, reg_write;
    wire [1:0] alu_op;

    // ========== EX Stage Signals ==========
    wire [31:0] alu_result, operand2;
    wire [3:0] alu_control;
    wire zero_flag, branch_taken;

    // ========== MEM Stage Signals ==========
    wire [31:0] mem_data;

    // ========== WB Stage Signals ==========
    wire [31:0] write_data;

    // ========== Instruction Fetch (IF) ==========
    instruction_fetch IF_stage (
        .clk(clk),
        .reset(reset),
        .pc_out(pc),
        .instruction(instruction)
    );

    // ========== Instruction Decode (ID) ==========
    instruction_decode ID_stage (
        .instruction(instruction),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .imm_out(imm_ext),
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7)
    );

    register_file RF (
        .clk(clk),
        .we(reg_write),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(write_data),
        .read_data1(reg_read_data1),
        .read_data2(reg_read_data2)
    );

    control_unit CU (
        .opcode(opcode),
        .Branch(branch),
        .MemRead(mem_read),
        .MemtoReg(mem_to_reg),
        .ALUOp(alu_op),
        .MemWrite(mem_write),
        .ALUSrc(alu_src),
        .RegWrite(reg_write)
    );

    imm_gen IMM_GEN (
        .instruction(instruction),
        .imm_out(imm_ext)
    );

    // ========== Execute Stage (EX) ==========
    mux mux_operand2 (
        .sel(alu_src),
        .in0(reg_read_data2),
        .in1(imm_ext),
        .out(operand2)
    );

    alu_control ALU_CTRL (
        .ALUOp(alu_op),
        .funct3(funct3),
        .funct7(funct7),
        .ALU_control(alu_control)
    );

    alu ALU (
        .a(reg_read_data1),
        .b(operand2),
        .alu_control(alu_control),
        .result(alu_result),
        .zero(zero_flag)
    );

    // Branch Decision
    assign branch_taken = branch & zero_flag; // Taken only if branch is enabled and condition is met

    // ========== Memory Access (MEM) ==========
    memory_access MEM_stage (
        .clk(clk),
        .MemRead(mem_read),
        .MemWrite(mem_write),
        .address(alu_result),
        .write_data(reg_read_data2),
        .read_data(mem_data)
    );

    // ========== Write Back (WB) ==========
    write_back WB_stage (
        .MemtoReg(mem_to_reg),
        .alu_result(alu_result),
        .mem_data(mem_data),
        .write_data(write_data)
    );

endmodule
