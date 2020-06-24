import BasicTypes::*;
import PipelineTypes::*;
import FetchUnitTypes::*;

interface MemoryAccessStageIF(
  input var logic clk,
  input var logic rst
);

`ifdef BRANCH_M
  PC pc;
  PC irregPc;
  logic isBranch;
  logic isBranchTaken;
  BranchPredict branchPredict;
`endif
  RDCtrl rdCtrl;
  WriteBackStagePipeReg nextStage;

  always_comb begin
    rdCtrl = nextStage.rdCtrl;
  end

  modport ThisStage(
    input clk,
    input rst,
  `ifdef BRANCH_M
    output pc,
    output irregPc,
    output isBranch,
    output isBranchTaken,
    output branchPredict,
  `endif
    output nextStage
  );

  modport NextStage(
    input nextStage
  );

  modport Controller(
  `ifdef BRANCH_M
    input irregPc,
    input isBranchTaken,
    input branchPredict,
  `endif
    input rdCtrl
  );

`ifdef BRANCH_M
  modport FetchStage(
    input irregPc
  );

  modport BTB(
    input pc,
    input isBranch,
    input isBranchTaken,
    input irregPc
  );
`endif

endinterface : MemoryAccessStageIF
