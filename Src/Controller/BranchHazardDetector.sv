`include "../SynthesisMacros.svh"
import BasicTypes::*;
import FetchUnitTypes::*;

module BranchHazardDetector(
  input var logic isBranch,
  input var BranchPredict branchPredict,
  input var PC irregPc,
  output var logic isBranchHazard
);

  always_comb begin
    if (isBranch == TRUE && irregPc == {(ADDR_WIDTH){1'b0}}) begin
    `ifndef NOT_USE_BTB
      if (branchPredict.isNextPcPredicted == TRUE) begin
        isBranchHazard = FALSE;
      end
      else begin
        isBranchHazard = TRUE;
      end
    `else
      if (branchPredict.isBranchTakenPredicted) begin
        isBranchHazard = TRUE;
      end
      else begin
        isBranchHazard = FALSE;
      end
    `endif
    end
    else begin
      isBranchHazard = FALSE;
    end
  end
endmodule
