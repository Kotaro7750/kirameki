import BasicTypes::*;

interface DebugIF(
  input var logic clk,
  input var logic rst
);

  modport ThisStage(
    input clk,
    input rst
  );

endinterface : DebugIF
