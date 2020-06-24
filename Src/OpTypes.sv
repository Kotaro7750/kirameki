package OpTypes;
  import BasicTypes::*;
  import MemoryTypes::*;

  typedef enum logic [2:0] {
    TYPE_R = 3'd0,
    TYPE_I = 3'd1,
    TYPE_S = 3'd2,
    TYPE_U = 3'd3,
    TYPE_J = 3'd4,
    TYPE_JALR = 3'd5,
    TYPE_B = 3'd6,
    TYPE_NONE = 3'd7
  } OpType;

  typedef enum logic [6:0] {
    RISCV_OP = 7'b0110011,
    RISCV_OP_IMM = 7'b0010011,
    RISCV_LUI = 7'b0110111,
    RISCV_AUIPC = 7'b0010111,
    RISCV_JAL = 7'b1101111,
    RISCV_JALR = 7'b1100111,
    RISCV_BR = 7'b1100011,
    RISCV_ST = 7'b0100011,
    RISCV_LD = 7'b0000011
  } OpCode;

  typedef enum logic [2:0] {
    BR_NONE = 3'd0,
    BR_EQ,
    BR_NE,
    BR_LT,
    BR_GE,
    BR_LTU,
    BR_GEU,
    BR_JUMP
  } BranchResolverCtrl;

  typedef logic [2:0] Funct3;
  typedef logic [6:0] Funct7;

  typedef struct packed {
    OpType opType;
    ALUCtrl aluCtrl;
    MulDivCode mulDivCode;
    BranchResolverCtrl brCtrl;
    logic wEnable;
    logic isForwardable;
    MemAccessWidth memAccessWidth;
    logic isMulDiv;
    logic isBranch;
    logic isStore;
    logic isLoad;
    logic isLoadUnsigned;
    logic isBubble;
  } OpInfo ;
endpackage
