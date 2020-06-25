`include "../SynthesisMacros.svh"
import BasicTypes::*;
import ControllerTypes::*;

module StageController(
  input var logic isBranchHazard,
  input var logic isBranchHazardDelayed,
  input var logic isDataHazard,
  input var logic isStructureHazard,
  input var logic isMiss,
  output var StageCtrl fetchStage,
  output var StageCtrl decodeStage,
  output var StageCtrl executeStage,
  output var logic mulDivClear
);
  always_comb begin
    if (isMiss) begin
      fetchStage.stall = FALSE;
      fetchStage.flush = TRUE;

      decodeStage.stall = FALSE;
      decodeStage.flush = TRUE;

  `ifndef BRANCH_M
      executeStage.flush = FALSE;
  `else
      executeStage.flush = TRUE;
  `endif
      executeStage.stall = FALSE;
      mulDivClear = TRUE;

    end
    else if (isStructureHazard) begin
      fetchStage.stall = TRUE;
      fetchStage.flush = FALSE;

      decodeStage.stall = TRUE;
      decodeStage.flush = FALSE;

      executeStage.stall = TRUE;
      executeStage.flush = TRUE;
      mulDivClear = FALSE;
    end
    else if (isDataHazard) begin
      fetchStage.stall = TRUE;
      fetchStage.flush = FALSE;

      decodeStage.stall = TRUE;
      decodeStage.flush = TRUE;

      executeStage.stall = FALSE;
      executeStage.flush = FALSE;
      mulDivClear = FALSE;
    end
    else if (isBranchHazard || isBranchHazardDelayed) begin
      if (isBranchHazard && !isBranchHazardDelayed) begin
        fetchStage.stall = TRUE;
        fetchStage.flush = FALSE;
      end
      else if (isBranchHazard && isBranchHazardDelayed ) begin
        fetchStage.stall = TRUE;
        fetchStage.flush = TRUE;
      end
      else begin
        fetchStage.stall = FALSE;
        fetchStage.flush = TRUE;
      end

      decodeStage.stall = FALSE;
      decodeStage.flush = FALSE;

      executeStage.stall = FALSE;
      executeStage.flush = FALSE;
      mulDivClear = FALSE;
    end
    else begin
      fetchStage.stall = FALSE;
      fetchStage.flush = FALSE;

      decodeStage.stall = FALSE;
      decodeStage.flush = FALSE;

      executeStage.stall = FALSE;
      executeStage.flush = FALSE;
      mulDivClear = FALSE;
    end
  end
endmodule
