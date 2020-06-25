`include "../SynthesisMacros.svh"
import BasicTypes::*;
import FetchUnitTypes::*;

module NextPcGen(
  input var PC pc,
  input var PC irregPc,
  input var logic isBranch,
  input var logic isBranchTakenPredicted,
  input var logic stall,
  input var logic btbHit,
  input var PC btbPredictedPc,
  output var PC npc
);
  always_comb begin
    if (stall) begin
      npc = pc;
    end
    else if (irregPc != {(ADDR_WIDTH){1'b0}}) begin
      npc = irregPc;
    end
  `ifndef NOT_USE_BTB
    else if (isBranch && btbHit && isBranchTakenPredicted) begin
      npc = btbPredictedPc;
    end
  `endif
    else begin
      npc = pc + 4;
    end
  end
endmodule
