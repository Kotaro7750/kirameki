`include "../SynthesisMacros.svh"
import BasicTypes::*;
import PipelineTypes::*;

module TwoLevelGlobal(
  BranchPredictorIF.BranchPredictor port,
`ifndef BRANCH_M
  ExecuteStageIF.BranchPredictor branchConfirmedStage
`else
  MemoryAccessStageIF.BranchPredictor branchConfirmedStage
`endif
);
  
  logic [3:0] GlobalBranchHistory;
  logic [1:0] SaturationCounters[0:15];

  always_ff@(posedge port.clk) begin
    if (port.rst == RESET) begin
      GlobalBranchHistory <= 4'b0000;
      for (int i = 0; i < 16; i++) begin
        SaturationCounters[i] <= 2'b10;
      end
    end
    else begin
      if (branchConfirmedStage.isBranch) begin
        GlobalBranchHistory[0] <= branchConfirmedStage.isBranchTaken ? TRUE : FALSE;
        for (int i = 1; i < 3; i++) begin
          GlobalBranchHistory[i] <= GlobalBranchHistory[i-1];
        end
      end

      if (branchConfirmedStage.isBranch) begin
        if(branchConfirmedStage.isBranchTaken) begin
          if (SaturationCounters[branchConfirmedStage.branchPredict.globalBranchHistory] == 2'b11) begin //TODO ここらへん strongly takenとかに変えたいし，それぞれのindexに変えたい
            SaturationCounters[branchConfirmedStage.branchPredict.globalBranchHistory] <= 2'b11;
          end
          else begin
            SaturationCounters[branchConfirmedStage.branchPredict.globalBranchHistory] <= SaturationCounters[branchConfirmedStage.branchPredict.globalBranchHistory] + 1;
          end
        end
        else begin
          if (SaturationCounters[branchConfirmedStage.branchPredict.globalBranchHistory] == 2'b00) begin 
            SaturationCounters[branchConfirmedStage.branchPredict.globalBranchHistory] <= 2'b00;
          end
          else begin
            SaturationCounters[branchConfirmedStage.branchPredict.globalBranchHistory] <= SaturationCounters[branchConfirmedStage.branchPredict.globalBranchHistory] - 1;
          end
        end
      end
    end
  end

  always_comb begin
    port.globalBranchHistory = GlobalBranchHistory;
    if (SaturationCounters[GlobalBranchHistory][1] == TRUE) begin //そのうちPCも使う
      port.isBranchTakenPredicted = TRUE;
    end
    else begin
      port.isBranchTakenPredicted = FALSE;
    end
  end
endmodule
