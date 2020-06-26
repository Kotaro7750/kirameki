module Controller(
  ControllerIF.Controller port,
  FetchStageIF.Controller fetch,
  DecodeStageIF.Controller decode,
  ExecuteStageIF.Controller execute,
  MemoryAccessStageIF.Controller memoryAccess,
  RegisterFileIF.Controller registerFile
);

  logic isDataHazard;
  logic isStructureHazard;
  logic isBranchHazard;
  logic isBranchHazardDelayed;
  logic isMiss;
  PC irregPc;
  BasicData bypassedRs1;
  BasicData bypassedRs2;

  BypassController BypassController(
    .rs1Addr(registerFile.rs1Addr),
    .rs2Addr(registerFile.rs2Addr),
    .aluOp1Type(decode.aluOp1Type),
    .aluOp2Type(decode.aluOp2Type),
    .isStore(decode.isStore),
    .rs1Data(registerFile.rs1Data),
    .rs2Data(registerFile.rs2Data),
    .ExRdCtrl(execute.rdCtrl),
    .MemRdCtrl(memoryAccess.rdCtrl),
    .isDataHazard(isDataHazard),
    .bypassedRs1(bypassedRs1),
    .bypassedRs2(bypassedRs2)
  );

  MissDetector MissDetector(
  `ifndef BRANCH_M
    .isBranchTaken(execute.isBranchTaken),
    .branchPredict(execute.branchPredict),
    .irregPcFromConfirmedStage(execute.irregPc),
  `else
    .isBranchTaken(memoryAccess.isBranchTaken),
    .branchPredict(memoryAccess.branchPredict),
    .irregPcFromConfirmedStage(memoryAccess.irregPc),
  `endif
    .irregPc(irregPc),
    .isMiss(isMiss)
  );

  BranchHazardDetector BranchHazardDetector(
    .isBranch(fetch.isBranch),
    .branchPredict(fetch.branchPredict),
    .irregPc(irregPc),
    .isBranchHazard(isBranchHazard)
  );

  StageController StageController(
    .isBranchHazard(isBranchHazard),
    .isBranchHazardDelayed(isBranchHazardDelayed),
    .isDataHazard(isDataHazard),
    .isStructureHazard(isStructureHazard),
    .isMiss(isMiss),
    .fetchStage(port.fetchStage),
    .decodeStage(port.decodeStage),
    .executeStage(port.executeStage),
    .mulDivClear(port.mulDivClear)
  );

  always_ff@(posedge port.clk) begin
    if (isMiss) begin
      isBranchHazardDelayed <= FALSE;
    end
    else if (!isDataHazard && !isStructureHazard) begin
      isBranchHazardDelayed <= isBranchHazard;
    end
  end

  always_comb begin
    isStructureHazard = execute.isMulDivUnitBusy;
    port.irregPc = irregPc;
    port.bypassedRs1 = bypassedRs1;
    port.bypassedRs2 = bypassedRs2;
  end

endmodule
