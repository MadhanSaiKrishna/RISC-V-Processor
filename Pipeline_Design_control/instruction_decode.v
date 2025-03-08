module HazardDetectionUnit (
    input [4:0] IF_ID_RegisterRs1,  // Rs1 from IF/ID stage
    input [4:0] IF_ID_RegisterRs2,  // Rs2 from IF/ID stage
    input [4:0] ID_EX_RegisterRd,   // Rd from ID/EX stage
    input ID_EX_MemRead,            // MemRead signal from ID/EX stage
    output reg stall                 // Stall signal
);

    always @(*) begin
        // Default to no stall
        stall = 1'b0;

        // Check for load-use hazard
        if (ID_EX_MemRead && ((ID_EX_RegisterRd == IF_ID_RegisterRs1) || (ID_EX_RegisterRd == IF_ID_RegisterRs2))) begin
            stall = 1'b1; // Stall the pipeline
        end
    end

endmodule

module InstructionDecoder (
    input [31:0] instruction,  // 32-bit instruction input
    input stall,               // Stall signal from hazard detection unit
    output wire [6:0] opcode,   // Bits [6:0] - Opcode
    output wire [4:0] rs1,      // Bits [19:15] - Source Register 1
    output wire [4:0] rs2,      // Bits [24:20] - Source Register 2
    output wire [4:0] rd,       // Bits [11:7] - Destination Register
    output wire [2:0] funct3,   // Bits [14:12] - Function code
    output wire [6:0] funct7,   // Bits [31:25] - Function code (R-type)
    output wire [31:0] imm,     // Immediate value (for I, S, B, U, J types)
    output wire Branch,         // Branch signal
    output wire MemRead,        // Memory read enable
    output wire MemtoReg,       // Select memory output to register
    output wire [1:0] ALUOp,    // ALU operation
    output wire MemWrite,       // Memory write enable
    output wire ALUSrc,         // ALU source selection
    output wire RegWrite        // Register write enable
);

    // Internal registers for control signals
    reg Branch_reg, MemRead_reg, MemtoReg_reg;
    reg [1:0] ALUOp_reg;
    reg MemWrite_reg, ALUSrc_reg, RegWrite_reg;

    // Internal register for immediate value
    reg [31:0] imm_reg;

    // Connect internal registers to the output wires
    assign Branch = Branch_reg;
    assign MemRead = MemRead_reg;
    assign MemtoReg = MemtoReg_reg;
    assign ALUOp = ALUOp_reg;
    assign MemWrite = MemWrite_reg;
    assign ALUSrc = ALUSrc_reg;
    assign RegWrite = RegWrite_reg;
    assign imm = imm_reg; // Assign the internal register to the output wire

    // Extract fields from the instruction
    assign opcode = instruction[6:0];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign rd = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];

    // Immediate generation logic
    always @(*) begin
        case (opcode)
            // I-type (ADDI, LW, etc.)
            7'b0010011, 7'b0000011, 7'b1100111:
                imm_reg = {{20{instruction[31]}}, instruction[31:20]}; // Sign-extended 12-bit immediate
            // S-type (SW, SH, SB)
            7'b0100011:
                imm_reg = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}; // Sign-extended
            // B-type (BEQ, BNE, etc.)
            7'b1100011:
                imm_reg = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            // U-type (LUI, AUIPC)
            7'b0110111, 7'b0010111:
                imm_reg = {instruction[31:12], 12'b0}; // 20-bit immediate (shifted left)
            // J-type (JAL)
            7'b1101111:
                imm_reg = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            default:
                imm_reg = 32'b0; // Default to zero
        endcase
    end

    // Control signal generation logic
    always @(*) begin
        // Default control signals (NOP)
        Branch_reg = 0;
        MemRead_reg = 0;
        MemtoReg_reg = 0;
        ALUOp_reg = 2'b00;
        MemWrite_reg = 0;
        ALUSrc_reg = 0;
        RegWrite_reg = 0;

        // If stall is detected, keep control signals as NOP
        if (stall) begin
            Branch_reg = 0;
            MemRead_reg = 0;
            MemtoReg_reg = 0;
            ALUOp_reg = 2'b00;
            MemWrite_reg = 0;
            ALUSrc_reg = 0;
            RegWrite_reg = 0;
        end
        else begin
            // Generate control signals based on opcode
            case (opcode)
                // R-type (ADD, SUB, AND, OR, etc.)
                7'b0110011: begin
                    RegWrite_reg = 1;
                    ALUOp_reg = 2'b10;
                end
                // I-type (ADDI, LW, etc.)
                7'b0010011, 7'b0000011: begin
                    RegWrite_reg = 1;
                    ALUSrc_reg = 1;
                    MemRead_reg = (opcode == 7'b0000011) ? 1 : 0; // LW only
                    MemtoReg_reg = (opcode == 7'b0000011) ? 1 : 0; // LW only
                    ALUOp_reg = 2'b00;
                end
                // S-type (SW, SH, SB)
                7'b0100011: begin
                    MemWrite_reg = 1;
                    ALUSrc_reg = 1;
                    ALUOp_reg = 2'b00;
                end
                // B-type (BEQ, BNE, etc.)
                7'b1100011: begin
                    Branch_reg = 1;
                    ALUOp_reg = 2'b01;
                end
                // J-type (JAL, JALR)
                7'b1101111, 7'b1100111: begin
                    RegWrite_reg = 1;
                    ALUSrc_reg = 1;
                    ALUOp_reg = 2'b00;
                end
                // U-type (LUI, AUIPC)
                7'b0110111, 7'b0010111: begin
                    RegWrite_reg = 1;
                    ALUSrc_reg = 1;
                    ALUOp_reg = 2'b00;
                end
                default: begin
                    // Default: Keep all signals low (NOP)
                end
            endcase
        end
    end

endmodule


module RegisterFile (
    input clk,                    // Clock signal
    input reset,                  // Reset signal
    input regWrite,               // Write enable signal
    input [4:0] rs1,              // Source register 1 address
    input [4:0] rs2,              // Source register 2 address
    input [4:0] rd,               // Destination register address
    input [63:0] writeData,       // Data to write into rd
    output wire [63:0] readData1,  // Data output for rs1
    output wire [63:0] readData2   // Data output for rs2
);

    // 32 registers of 64-bit each (RISC-V uses 32 registers)
    reg [63:0] registers [0:31];
    reg [63:0] readData1_reg, readData2_reg;
    
    assign readData1 = readData1_reg;
    assign readData2 = readData2_reg;

    // Reset all registers (only for simulation/testing)
    integer i;
    always @(posedge reset) begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] <= i; // Reset all registers to 0
            registers[12] <= 64'd25; // Set x12 to 1 (for testing)

    end
    


    // Register Read (Combinational Logic)
    always @(*) begin
        readData1_reg = (rs1 == 5'b0) ? 64'b0 : registers[rs1]; // x0 register is always 0
        readData2_reg = (rs2 == 5'b0) ? 64'b0 : registers[rs2]; // x0 register is always 0
    end

    // Register Write (Synchronous, on clock edge)
    always @(*) begin  /// changed to *
        if (regWrite && rd != 5'b0)  // Prevent writing to x0 (zero register)
            registers[rd] <= writeData;
    end

endmodule

module ImmGen (
    input [31:0] instruction,
    input [6:0] opcode,
    output wire [63:0] imm
);

reg [63:0] imm_reg;
assign imm = imm_reg;

always @(*) begin
    case (opcode)
        // --- I-TYPE (Immediate Operations) ---
        7'b0010011,  // Arithmetic Immediate (ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI)
        7'b0000011,  // Load Instructions (LW, LH, LB, etc.)
        7'b1100111:  // JALR (Jump and Link Register)
            imm_reg = {{52{instruction[31]}}, instruction[31:20]};  // Sign-extended 12-bit immediate to 64-bit

        // --- S-TYPE (Store Operations) ---
        7'b0100011:  // SW, SH, SB
            imm_reg = {{52{instruction[31]}}, instruction[31:25], instruction[11:7]};  // Sign-extended to 64-bit

        // --- B-TYPE (Branch Operations) ---
        7'b1100011:  // BEQ, BNE, BLT, BGE, etc.
            imm_reg = {{51{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};  // Sign-extended to 64-bit

        // --- U-TYPE (Upper Immediate Operations) ---
        7'b0110111,  // LUI (Load Upper Immediate)
        7'b0010111:  // AUIPC (Add Upper Immediate to PC)
            imm_reg = {{32{instruction[31]}}, instruction[31:12], 12'b0};  // 20-bit immediate (shifted left) sign-extended to 64-bit

        // --- J-TYPE (Jump Instructions) ---
        7'b1101111:  // JAL (Jump and Link)
            imm_reg = {{43{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};  // Sign-extended to 64-bit

        default:
            imm_reg = 64'b0;  // Default to zero if opcode is not recognized
    endcase
end

endmodule

module ControlUnit (
    input [6:0] opcode,       // Instruction opcode
    output wire Branch,        // Branch signal
    output wire MemRead,       // Memory read enable
    output wire MemtoReg,      // Select memory output to register
    output wire [1:0] ALUOp,   // ALU operation
    output wire MemWrite,      // Memory write enable
    output wire ALUSrc,        // ALU source selection
    output wire RegWrite       // Register write enable
);

reg Branch_reg, MemRead_reg, MemtoReg_reg;
reg [1:0] ALUOp_reg;
reg MemWrite_reg, ALUSrc_reg, RegWrite_reg;

// Connect internal registers to the output wires
assign Branch = Branch_reg;
assign MemRead = MemRead_reg;
assign MemtoReg = MemtoReg_reg;
assign ALUOp = ALUOp_reg;
assign MemWrite = MemWrite_reg;
assign ALUSrc = ALUSrc_reg;
assign RegWrite = RegWrite_reg;

always @(*) begin
    // Default control signals
    Branch_reg   = 0;
    MemRead_reg  = 0;
    MemtoReg_reg = 0;
    ALUOp_reg    = 2'b00;
    MemWrite_reg = 0;
    ALUSrc_reg   = 0;
    RegWrite_reg = 0;
    
    case (opcode)
        7'b0110011: begin // R-type (ADD, SUB, AND, OR, XOR, etc.)
            RegWrite_reg = 1;
            ALUOp_reg    = 2'b10;
        end
        
        7'b0010011, // I-type (ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI)
        7'b0000011: begin // Load (LW, LH, LB)
            RegWrite_reg = 1;
            ALUSrc_reg   = 1;
            MemRead_reg  = (opcode == 7'b0000011) ? 1 : 0;
            MemtoReg_reg = (opcode == 7'b0000011) ? 1 : 0;
            ALUOp_reg    = 2'b00;
        end
        
        7'b0100011: begin // S-type (Store: SW, SH, SB)
            MemWrite_reg = 1;
            ALUSrc_reg   = 1;
            ALUOp_reg    = 2'b00;
        end
        
        7'b1100011: begin // B-type (Branch: BEQ, BNE, etc.)
            Branch_reg   = 1;
            ALUOp_reg    = 2'b01;
        end
        
        7'b1101111, // J-type (JAL: Jump and Link)
        7'b1100111: begin // JALR (Jump and Link Register)
            RegWrite_reg = 1;
            ALUSrc_reg   = 1;
            ALUOp_reg    = 2'b00;
        end
    
        7'b0110111, // U-type (LUI: Load Upper Immediate)
        7'b0010111: begin // AUIPC (Add Upper Immediate to PC)
            RegWrite_reg = 1;
            ALUSrc_reg   = 1;
            ALUOp_reg    = 2'b00;
        end
        
        default: begin
            // Default: Keep all signals low
        end
    endcase
end

endmodule