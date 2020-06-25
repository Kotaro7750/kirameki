import BasicTypes::*;
import PipelineTypes::*;
import ControllerTypes::*;
import FetchUnitTypes::*;

interface ControllerIF(
  input var logic clk,
  input var logic rst
);

  PC irregPc;
  StageCtrl fetchStage;
  StageCtrl fetchStageVirtual;
  StageCtrl decodeStage;
  StageCtrl executeStage;
  StageCtrl memoryAccessStage;
  logic mulDivClear;
  BasicData bypassedRs1;
  BasicData bypassedRs2;

  modport Controller(
    input clk,
    input rst,
    output irregPc,
    output bypassedRs1,
    output bypassedRs2,
    output fetchStage,
    output fetchStageVirtual,
    output decodeStage,
    output executeStage,
    output mulDivClear,
    output memoryAccessStage
  );

  modport FetchStage(
    input irregPc,
    input fetchStage
  );

  modport DecodeStage(
    input fetchStageVirtual,
    input decodeStage
  );

  modport ExecuteStage(
    input mulDivClear,
    input executeStage,
    input bypassedRs1,
    input bypassedRs2
  );

  modport MemoryAccessStage(
    input memoryAccessStage
  );

  modport BTB(
    input irregPc
  );

endinterface : ControllerIF
