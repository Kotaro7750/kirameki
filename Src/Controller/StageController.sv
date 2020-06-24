`include "../SynthesisMacros.svh"
import BasicTypes::*;
import ControllerTypes::*;

module StageController(
  input var logic isBranchHazard,
  input var logic isBranchHazardDelayed,
  input var logic isDataHazard,
  input var logic isMiss,
  output var StageCtrl fetchStage,
  output var StageCtrl fetchStageVirtual,
  output var StageCtrl decodeStage,
  output var StageCtrl executeStage,
  output var StageCtrl memoryAccessStage
);
  always_comb begin
    if (isMiss) begin
      fetchStage.stall = FALSE;
      fetchStage.flush = FALSE;
      fetchStageVirtual.stall = FALSE;
      fetchStageVirtual.flush = FALSE;

      decodeStage.stall = FALSE;
      decodeStage.flush = TRUE;

      executeStage.stall = FALSE;
      executeStage.flush = TRUE;

  `ifndef BRANCH_M
    memoryAccessStage.stall = FALSE;
    memoryAccessStage.flush = FALSE;
  `else
    memoryAccessStage.stall = FALSE;
    memoryAccessStage.flush = TRUE;
  `endif
    end
    else if (isDataHazard) begin
      fetchStage.stall = TRUE;
      fetchStage.flush = FALSE;
      fetchStageVirtual.stall = TRUE;
      fetchStageVirtual.flush = FALSE;

      decodeStage.stall = TRUE;
      decodeStage.flush = FALSE;

      executeStage.stall = FALSE;
      executeStage.flush = TRUE;

    memoryAccessStage.stall = FALSE;
    memoryAccessStage.flush = FALSE;
    end
    else if (isBranchHazard || isBranchHazardDelayed) begin
      if (isBranchHazard) begin
        fetchStage.stall = TRUE;
        fetchStage.flush = FALSE;
      end
      else begin
        fetchStage.stall = FALSE;
        fetchStage.flush = FALSE;
      end

      if (isBranchHazardDelayed) begin
        fetchStageVirtual.stall = TRUE;
        fetchStageVirtual.flush = FALSE;
      end
      else begin
        fetchStageVirtual.stall = FALSE;
        fetchStageVirtual.flush = FALSE;
      end

      decodeStage.stall = FALSE;
      decodeStage.flush = FALSE;

      executeStage.stall = FALSE;
      executeStage.flush = FALSE;

      memoryAccessStage.stall = FALSE;
      memoryAccessStage.flush = FALSE;
    end
    else begin
      fetchStage.stall = FALSE;
      fetchStage.flush = FALSE;
      fetchStageVirtual.stall = FALSE;
      fetchStageVirtual.flush = FALSE;

      decodeStage.stall = FALSE;
      decodeStage.flush = FALSE;

      executeStage.stall = FALSE;
      executeStage.flush = FALSE;

      memoryAccessStage.stall = FALSE;
      memoryAccessStage.flush = FALSE;
    end
  end
endmodule
