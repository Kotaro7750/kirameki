`include "../SynthesisMacros.svh"
import PipelineTypes::*;
import FetchUnitTypes::*;

interface FetchStageIF(
  input var logic clk,
  input var logic rst
);

  logic isBranch;
  logic btbHit;
  logic stall;
  PC pc;
  PC npc;
  PC btbPredictedPc;
  BranchPredict branchPredict;
  DecodeStagePipeReg nextStage;

  modport ThisStage(
    input clk,
    input rst,
    input btbHit,
    input btbPredictedPc,
    output pc,
    output npc,
    output stall,
    output isBranch,
    output branchPredict,
    output nextStage
  );

  modport NextStage(
    input nextStage
  );

  modport Controller(
    input isBranch,
    input branchPredict
  );

  modport BranchPredictor(
    input pc
  );

`ifndef NOT_USE_BTB
  modport BTB(
    input npc,
    input stall,
    output btbHit,
    output btbPredictedPc
  );
`endif

endinterface : FetchStageIF
