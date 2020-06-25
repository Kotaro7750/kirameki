import BasicTypes::*;
import FetchUnitTypes::*;

module BranchPredictGen(
  input var logic isBranch,
  input var logic isBranchTakenPredicted,
  input var logic btbHit,
  input var PC btbPredictedPc,
  output var BranchPredict branchPredict
);
  always_comb begin
    if (isBranch) begin
      if (isBranchTakenPredicted) begin
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
      end
      else begin
        branchPredict.isNextPcPredicted = TRUE;
        branchPredict.predictedNextPC = {(ADDR_WIDTH){1'b0}}; //後でirregPcと比較するので0の方が都合がいい
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
