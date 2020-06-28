`include "../SynthesisMacros.svh"
import BasicTypes::*;
import FetchUnitTypes::*;

module MissDetector(
  input var logic isBranchHazardDelayed,
  input var logic isBranchTaken,
  input var BranchPredict branchPredict,
  input var PC irregPcFromConfirmedStage,
  output var PC irregPc,
  output var logic isMiss
);
  
  always_comb begin
    if (branchPredict.isBranchTakenPredicted) begin
      if (branchPredict.isNextPcPredicted) begin
        if (branchPredict.predictedNextPC != irregPcFromConfirmedStage) begin
          isMiss = TRUE;
          irregPc = irregPcFromConfirmedStage;
        end
        else begin
          isMiss = FALSE;
          irregPc = {(ADDR_WIDTH){1'b0}};
        end
      end
      else begin
      `ifdef BRANCH_M //M確定のときはBハザード中の予測変更をミスとして扱う．
        isMiss = isBranchHazardDelayed ? FALSE : TRUE;
      `else
        isMiss = FALSE;
      `endif
        irregPc = irregPcFromConfirmedStage;
      end
    end
    else begin
      if (branchPredict.predictedNextPC != irregPcFromConfirmedStage) begin
        irregPc = irregPcFromConfirmedStage;
        isMiss = TRUE;
      end
      else begin
        irregPc = {(ADDR_WIDTH){1'b0}};
        isMiss = FALSE;
      end
    end
  end
endmodule
