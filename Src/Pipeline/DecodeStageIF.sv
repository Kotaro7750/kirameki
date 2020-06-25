import BasicTypes::*;

interface DecodeStageIF(
  input var logic clk,
  input var logic rst
);

  ALUOpType aluOp1Type;
  ALUOpType aluOp2Type;
  logic isStore;
  ExecuteStagePipeReg nextStage;

  modport ThisStage(
    input clk,
    input rst,
    output aluOp1Type,
    output aluOp2Type,
    output isStore,
    output nextStage
  );

  modport NextStage(
    input nextStage
  );

  modport Controller(
    input aluOp1Type,
    input aluOp2Type,
    input isStore
  );

endinterface : DecodeStageIF
