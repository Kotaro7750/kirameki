import BasicTypes::*;
import PipelineTypes::*;

interface BranchPredictorIF(
  input var logic clk,
  input var logic rst
);

  logic isBranchTakenPredicted;
  
  modport BranchPredictor(
    input clk,
    input rst,
    output isBranchTakenPredicted
  );

  modport FetchStage(
    input isBranchTakenPredicted
  );

endinterface : BranchPredictorIF

