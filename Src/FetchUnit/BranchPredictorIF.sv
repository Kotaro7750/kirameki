import BasicTypes::*;
import PipelineTypes::*;
import FetchUnitTypes::*;

interface BranchPredictorIF(
  input var logic clk,
  input var logic rst
);

  logic isBranchTakenPredicted;
  //GlobalBranchHistory globalBranchHistory;
  PHTIndex phtIndex;
  
  modport BranchPredictor(
    input clk,
    input rst,
    //output globalBranchHistory,
    output phtIndex,
    output isBranchTakenPredicted
  );

  modport FetchStage(
    //input globalBranchHistory,
    input phtIndex,
    input isBranchTakenPredicted
  );

endinterface : BranchPredictorIF

