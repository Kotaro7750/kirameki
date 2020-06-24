import BasicTypes::*;

interface DecodeStageIF(
  input var logic clk,
  input var logic rst
);

  logic stall;
  ALUOpType aluOp1Type;
  ALUOpType aluOp2Type;
  logic isStore;
  ExecuteStagePipeReg nextStage;

  modport ThisStage(
    input clk,
    input rst,
    output stall,
    output aluOp1Type,
    output aluOp2Type,
    output isStore,
    output nextStage
  );

  modport NextStage(
    input stall,
    input nextStage
  );

  modport Controller(
    input aluOp1Type,
    input aluOp2Type,
    input isStore
  );

endinterface : DecodeStageIF
