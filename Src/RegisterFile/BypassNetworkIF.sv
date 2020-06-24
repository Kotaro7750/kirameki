import BasicTypes::*;
import PipelineTypes::*;

interface BypassNetworkIF(
  input var logic clk,
  input var logic rst
);

  modport ExecuteStage(
  );

endinterface : BypassNetworkIF

