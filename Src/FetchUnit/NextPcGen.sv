`include "../SynthesisMacros.svh"
import BasicTypes::*;
import FetchUnitTypes::*;

module NextPcGen(
  input var PC pc,
  input var PC irregPc,
  input var logic isBranch,
  input var logic isBranchTakenPredicted,
  input var logic stall,
  input var logic flush,
  input var logic btbHit,
  input var PC btbPredictedPc,
  output var PC npc
);
  always_comb begin
    if (stall) begin
      npc = pc;
    end
  `ifdef BRANCH_M //M確定のときは予測変更はミスとする．
    else if (irregPc != {(ADDR_WIDTH){1'b0}}) begin
  `else
    else if (irregPc != {(ADDR_WIDTH){1'b0}} && (flush || (pc != irregPc && !flush))) begin //たまたまpc==irregPcとなるとその命令が二回繰り返されてしまう
  `endif
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
