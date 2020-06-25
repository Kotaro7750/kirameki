import BasicTypes::*;
import PipelineTypes::*;

module ExecuteStage(
  ExecuteStageIF.ThisStage port,
  DecodeStageIF.NextStage prev,
  ControllerIF.ExecuteStage controller
);
  
  logic stall;
  logic flush;
  always_comb begin
    stall = controller.executeStage.stall;
    flush = controller.executeStage.flush;
  end

  OperandSwitcher OperandSwitcher(
    .pc(pipeReg.pc),
    .rs1(bypassedRs1),
    .rs2(bypassedRs2),
    .imm(pipeReg.imm),
    .aluCtrl(pipeReg.opInfo.aluCtrl),
    .opType(pipeReg.opInfo.opType),
    .aluOp1(aluOp1),
    .aluOp2(aluOp2),
    .irregPcOp1(irregPcOp1),
    .irregPcOp2(irregPcOp2)
  );

  IntALU IntALU(
    .alucode(pipeReg.opInfo.aluCtrl.aluCode),
    .op1(aluOp1),
    .op2(aluOp2),
    .aluResult(aluResult)
  );

  BranchResolver BranchResolver(
    .pc(pipeReg.pc),
    .isBranch(pipeReg.opInfo.isBranch),
    .brCtrl(pipeReg.opInfo.brCtrl),
    .imm(pipeReg.imm),
    .rs1Data(aluOp1),
    .rs2Data(aluOp2),
    .irregPcOp1(irregPcOp1),
    .irregPcOp2(irregPcOp2),
    .irregPc(irregPc),
    .isBranchTaken(isBranchTaken)
  );

  MultiStageMulDiv MultiStageMulDiv(
    .clk(port.clk),
    .rst(port.rst),
  `ifdef BRANCH_M
    .clear(controller.mulDivClear),
  `endif
    .isMulDiv(prev.nextStage.opInfo.isMulDiv),
    .mulDivCode(prev.nextStage.opInfo.mulDivCode),
    .op1(aluOp1),
    .op2(aluOp2),
    .isMulDivUnitBusy(port.isMulDivUnitBusy),
    .result(mulDivResult)
  );

  BasicData aluOp1;
  BasicData aluOp2;
  BasicData irregPcOp1;
  BasicData irregPcOp2;
  BasicData aluResult;
  BasicData mulDivResult;
  BasicData bypassedRs1;
  BasicData bypassedRs2;
  PC irregPc;
  logic isBranchTaken;

  ExecuteStagePipeReg pipeReg;
  MemoryAccessStagePipeReg nextStage;

  always_ff@(posedge port.clk) begin
    if (port.rst == RESET) begin
      pipeReg <= {($bits(ExecuteStagePipeReg)){1'b0}};
    end
    else if (stall) begin
      pipeReg <= pipeReg;
    end
    else begin
      pipeReg <= prev.nextStage;
    end

    bypassedRs1 <= controller.bypassedRs1;
    bypassedRs2 <= controller.bypassedRs2;
  end

  always_comb begin
    nextStage.pc = pipeReg.pc;
    nextStage.memCtrl.addr = aluResult;
    nextStage.memCtrl.memAccessWidth = pipeReg.opInfo.memAccessWidth;
    nextStage.memCtrl.wData = bypassedRs2;
    nextStage.memCtrl.isStore = pipeReg.opInfo.isStore;
    nextStage.memCtrl.isLoad = pipeReg.opInfo.isLoad;
    nextStage.memCtrl.isLoadUnsigned = pipeReg.opInfo.isLoadUnsigned;
    nextStage.rdCtrl.wEnable = pipeReg.opInfo.wEnable;
    nextStage.rdCtrl.rdAddr = pipeReg.rdAddr;
    nextStage.rdCtrl.isForwardable = pipeReg.opInfo.isForwardable;
    nextStage.rdCtrl.wData = pipeReg.opInfo.isMulDiv ? mulDivResult : aluResult;
  `ifdef BRANCH_M
    nextStage.isBranch = pipeReg.opInfo.isBranch;
    nextStage.isBranchTaken = isBranchTaken;
    nextStage.branchPredict = pipeReg.branchPredict;
    nextStage.irregPc = irregPc;
  `endif

    port.pc = pipeReg.pc;
    port.irregPc = irregPc;
    port.isBranch = pipeReg.opInfo.isBranch;
    port.isBranchTaken = isBranchTaken;
    port.branchPredict = pipeReg.branchPredict;

    port.nextStage = flush ? {($bits(MemoryAccessStagePipeReg)){1'b0}} : nextStage;
  end
endmodule
