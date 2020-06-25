import PipelineTypes::*;
import FetchUnitTypes::*;

interface ExecuteStageIF(
  input var logic clk,
  input var logic rst
);
  
  PC irregPc;
  RDCtrl rdCtrl;
  BasicData bypassedRs1;
  BasicData bypassedRs2;
  logic isMulDivUnitBusy;
  logic isBranch;
  logic isBranchTaken;
  PC pc;
  BranchPredict branchPredict;
  MemoryAccessStagePipeReg nextStage;

  always_comb begin
    rdCtrl = nextStage.rdCtrl;
  end

  modport ThisStage(
    input clk,
    input rst,
    input bypassedRs1,
    input bypassedRs2,
    output pc,
    output irregPc,
    output isMulDivUnitBusy,
    output isBranch,
    output isBranchTaken,
    output branchPredict,
    output nextStage
  );

  modport NextStage(
    input nextStage
  );

  modport FetchStage(
    input irregPc
  );

  modport Controller(
    input rdCtrl,
    input isMulDivUnitBusy,
    input irregPc,
    input isBranchTaken,
    input branchPredict,
    output bypassedRs1,
    output bypassedRs2
  );

  modport BranchPredictor(
    input isBranch,
    input isBranchTaken
  );

  modport BTB(
    input pc,
    input isBranch,
    input isBranchTaken,
    input irregPc
  );

endinterface : ExecuteStageIF
