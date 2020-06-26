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
`ifdef DEBUG
  PC debugPc;
  MemAddr debugAddr;
  BasicData debugWData;
  logic [3:0] debugWEnable;
  BasicData hcOut;
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
  `ifdef DEBUG
    output debugPc,
    output debugAddr,
    output debugWData,
    output debugWEnable,
    output hcOut,
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
`endif

`ifdef DEBUG
  modport Debug(
  `ifdef BRANCH_M
    input irregPc,
    input isBranch,
    input isBranchTaken,
    input branchPredict,
  `endif
    input hcOut,
    input debugPc,
    input debugWEnable,
    input debugAddr,
    input debugWData
  );
`endif

endinterface : MemoryAccessStageIF
