`include "../SynthesisMacros.svh"
import BasicTypes::*;
import PipelineTypes::*;

module TwoLevelGlobal(
  BranchPredictorIF.BranchPredictor port,
  FetchStageIF.BranchPredictor fetchStage,
`ifndef BRANCH_M
  ExecuteStageIF.BranchPredictor branchConfirmedStage
`else
  MemoryAccessStageIF.BranchPredictor branchConfirmedStage
`endif
);
  
  PHTIndex phtIndex;
  GlobalBranchHistory globalBranchHistory;
  logic [1:0] SaturationCounters[0:PHT_ENTRY_NUM - 1];

  always_ff@(posedge port.clk) begin
    if (port.rst == RESET) begin
      globalBranchHistory <= {(GLOBAL_BRANCH_HISTORY_LENGTH){1'b0}};
      for (int i = 0; i < PHT_ENTRY_NUM; i++) begin
        SaturationCounters[i] <= 2'b10;
      end
    end
    else begin
      if (branchConfirmedStage.isBranch) begin
        globalBranchHistory[0] <= branchConfirmedStage.isBranchTaken ? TRUE : FALSE;
        for (int i = 1; i < GLOBAL_BRANCH_HISTORY_LENGTH; i++) begin
          globalBranchHistory[i] <= globalBranchHistory[i-1];
        end
      end

      if (branchConfirmedStage.isBranch) begin
        if(branchConfirmedStage.isBranchTaken) begin
          //if (SaturationCounters[branchConfirmedStage.branchPredict.globalBranchHistory] == 2'b11) begin //TODO ここらへん strongly takenとかに変えたいし，それぞれのindexに変えたい
          if (SaturationCounters[branchConfirmedStage.branchPredict.phtIndex] == 2'b11) begin //TODO ここらへん strongly takenとかに変えたいし，それぞれのindexに変えたい
            //SaturationCounters[branchConfirmedStage.branchPredict.globalBranchHistory] <= 2'b11;
            SaturationCounters[branchConfirmedStage.branchPredict.phtIndex] <= 2'b11;
          end
          else begin
            //SaturationCounters[branchConfirmedStage.branchPredict.globalBranchHistory] <= SaturationCounters[branchConfirmedStage.branchPredict.globalBranchHistory] + 1;
            SaturationCounters[branchConfirmedStage.branchPredict.phtIndex] <= SaturationCounters[branchConfirmedStage.branchPredict.phtIndex] + 1;
          end
        end
        else begin
          //if (SaturationCounters[branchConfirmedStage.branchPredict.globalBranchHistory] == 2'b00) begin 
          if (SaturationCounters[branchConfirmedStage.branchPredict.phtIndex] == 2'b00) begin 
            //SaturationCounters[branchConfirmedStage.branchPredict.globalBranchHistory] <= 2'b00;
            SaturationCounters[branchConfirmedStage.branchPredict.phtIndex] <= 2'b00;
          end
          else begin
            //SaturationCounters[branchConfirmedStage.branchPredict.globalBranchHistory] <= SaturationCounters[branchConfirmedStage.branchPredict.globalBranchHistory] - 1;
            SaturationCounters[branchConfirmedStage.branchPredict.phtIndex] <= SaturationCounters[branchConfirmedStage.branchPredict.phtIndex] - 1;
          end
        end
      end
    end
  end

  always_comb begin
    //port.globalBranchHistory = globalBranchHistory;
    phtIndex = ToPHT_Index(fetchStage.pc,globalBranchHistory);
    port.phtIndex = phtIndex;

    //if (SaturationCounters[globalBranchHistory][1] == TRUE) begin //そのうちPCも使う
    if (SaturationCounters[phtIndex][1] == TRUE) begin //そのうちPCも使う
      port.isBranchTakenPredicted = TRUE;
    end
    else begin
      port.isBranchTakenPredicted = FALSE;
    end
  end
endmodule
