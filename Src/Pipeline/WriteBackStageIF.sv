interface WriteBackStageIF(
  input var logic clk,
  input var logic rst
);

  modport ThisStage(
    input clk,
    input rst
  );

endinterface : WriteBackStageIF
