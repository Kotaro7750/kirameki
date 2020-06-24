package BasicTypes;
  localparam TRUE = 1'b1;
  localparam FALSE = 1'b0;

  localparam RESET = 1'b0;

  //Instruction
  localparam INST_WIDTH = 32;
  typedef logic [INST_WIDTH - 1:0] Instruction;

  //Addr
  localparam ADDR_WIDTH = 32;
  typedef logic [ADDR_WIDTH - 1:0] PC;
  typedef logic [ADDR_WIDTH - 1:0] MemAddr;

  //Register
  localparam REG_NUMBER = 32;
  localparam REG_ADDR_WIDTH = $clog2(REG_NUMBER);
  localparam ZERO_REG = 5'b0;
  typedef logic [REG_ADDR_WIDTH - 1:0] RegAddr;

  //Data
  localparam DATA_WIDTH = 32;
  typedef logic [DATA_WIDTH - 1:0] BasicData;

  typedef enum logic [3:0] {
    ALU_ADD,
    ALU_SUB,
    ALU_SLT,
    ALU_SLTU,
    ALU_XOR,
    ALU_OR,
    ALU_AND,
    ALU_SLL,
    ALU_SRL,
    ALU_SRA,
    ALU_JUMP,
    ALU_NONE
  } ALUCode;

  typedef enum logic [1:0] {
    OP_TYPE_NONE = 2'd0,
    OP_TYPE_REG  = 2'd1,
    OP_TYPE_IMM  = 2'd2,
    OP_TYPE_PC   = 2'd3
  } ALUOpType;

  typedef enum logic [2:0] {
    MULDIV_MUL,
    MULDIV_MULH,
    MULDIV_MULHSU,
    MULDIV_MULHU,
    MULDIV_DIV,
    MULDIV_DIVU,
    MULDIV_REM,
    MULDIV_REMU
  } MulDivCode;
  
  typedef struct packed {
    ALUCode aluCode;
    ALUOpType aluOp1Type;
    ALUOpType aluOp2Type;
  } ALUCtrl;

  typedef struct packed {
    logic wEnable;
    RegAddr rdAddr;
    logic isForwardable;
    BasicData wData;
  } RDCtrl ;

  typedef enum logic [1:0]{
    BYPASS_NONE = 2'd0,
    BYPASS_EXEC = 2'd1,
    BYPASS_MEM = 2'd2
  } BypassCtrl;

endpackage
