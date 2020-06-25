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
    else if (isBranch && btbHit) begin
      npc = btbPredictedPc;
    end
    else begin
      npc = pc + 4;
    end
  end
endmodule
