`include "../SynthesisMacros.svh"
import BasicTypes::*;
import FetchUnitTypes::*;

module BranchPredictGen(
  input var PC npc,
  input var logic isBranch,
  input var logic [3:0]globalBranchHistory,
  input var logic isBranchTakenPredicted,
  input var logic btbHit,
  input var PC btbPredictedPc,
  output var BranchPredict branchPredict
);
  always_comb begin
    branchPredict.globalBranchHistory = globalBranchHistory;

    if (isBranch) begin
      if (isBranchTakenPredicted) begin
      `ifndef NOT_USE_BTB
        if (btbHit) begin
          branchPredict.isNextPcPredicted = TRUE;
          branchPredict.predictedNextPC = btbPredictedPc;
          branchPredict.isBranchTakenPredicted = isBranchTakenPredicted;
        end
        else begin
          branchPredict.isNextPcPredicted = FALSE;
          branchPredict.predictedNextPC = {(ADDR_WIDTH){1'b0}};
          branchPredict.isBranchTakenPredicted = TRUE;
        end
      `else
        branchPredict.isNextPcPredicted = FALSE;
        branchPredict.predictedNextPC = {(ADDR_WIDTH){1'b0}};
        branchPredict.isBranchTakenPredicted = TRUE;
      `endif
      end
      else begin
        branchPredict.isNextPcPredicted = TRUE;
        branchPredict.predictedNextPC = npc;
        branchPredict.isBranchTakenPredicted = FALSE;
      end
    end
    else begin
      branchPredict.isNextPcPredicted = FALSE;
      branchPredict.predictedNextPC = {(ADDR_WIDTH){1'b0}};
      branchPredict.isBranchTakenPredicted = FALSE;
    end
  end
endmodule
