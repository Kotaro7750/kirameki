`include "../SynthesisMacros.svh"
import PipelineTypes::*;

interface WriteBackStageIF(
  input var logic clk,
  input var logic rst
);

  WriteBackStagePipeReg pipeReg;

  modport ThisStage(
    output pipeReg,
    input clk,
    input rst
  );

`ifdef DEBUG
  modport Debug(
    input pipeReg
  );
`endif

endinterface : WriteBackStageIF
