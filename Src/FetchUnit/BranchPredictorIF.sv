import BasicTypes::*;
import PipelineTypes::*;

interface BranchPredictorIF(
  input var logic clk,
  input var logic rst
);

  logic isBranchTakenPredicted;
  logic [3:0]globalBranchHistory;
  
  modport BranchPredictor(
    input clk,
    input rst,
    output globalBranchHistory,
    output isBranchTakenPredicted
  );

  modport FetchStage(
    input globalBranchHistory,
    input isBranchTakenPredicted
  );

endinterface : BranchPredictorIF

