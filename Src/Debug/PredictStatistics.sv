import BasicTypes::*;
import FetchUnitTypes::*;

module PredictStatistics(
  input var logic clk,
  input var logic rst,
  input var PC irregPc,
  input var logic isBranch,
  input var logic isBranchTaken,
  input var BranchPredict branchPredict
);

  BasicData Branch;
  BasicData PredictedTaken;
  BasicData PredictedNotTaken;
  BasicData CorrectBranchPredict;
  BasicData NextPcNotPredicted;
  BasicData Miss;
  BasicData MissOfTaken;
  BasicData MissOfNotTaken;
  
  always_ff@(posedge clk) begin
    if (rst == RESET) begin
      Branch <= {(DATA_WIDTH){1'b0}};
      PredictedTaken <= {(DATA_WIDTH){1'b0}};
      PredictedNotTaken <= {(DATA_WIDTH){1'b0}};
      CorrectBranchPredict <= {(DATA_WIDTH){1'b0}};
      NextPcNotPredicted <= {(DATA_WIDTH){1'b0}};
      Miss <= {(DATA_WIDTH){1'b0}};
      MissOfTaken <= {(DATA_WIDTH){1'b0}};
      MissOfNotTaken <= {(DATA_WIDTH){1'b0}};
    end
    else if (isBranch) begin
      Branch <= Branch + 1;
      if (branchPredict.isBranchTakenPredicted) begin
        PredictedTaken <= PredictedTaken + 1;
      end
      else begin
        PredictedNotTaken <= PredictedNotTaken + 1;
      end

      if (isBranchTaken == branchPredict.isBranchTakenPredicted) begin
        CorrectBranchPredict <= CorrectBranchPredict + 1;
      end

      if (!branchPredict.isNextPcPredicted) begin
        NextPcNotPredicted <= NextPcNotPredicted + 1;
      end

      if (branchPredict.isBranchTakenPredicted) begin
        if (branchPredict.isNextPcPredicted) begin
          if (branchPredict.predictedNextPC != irregPc) begin
            MissOfTaken <= MissOfTaken + 1;
            Miss <= Miss + 1;
          end
        end
      end
      else begin
        if (branchPredict.predictedNextPC != irregPc) begin
          MissOfNotTaken <= MissOfNotTaken + 1;
          Miss <= Miss + 1;
        end
      end
    end
  end
endmodule
