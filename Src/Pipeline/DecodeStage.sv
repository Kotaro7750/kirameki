import BasicTypes::*;
import PipelineTypes::*;

module DecodeStage(
  DecodeStageIF.ThisStage port,
  FetchStageIF.NextStage prev,
  RegisterFileIF.DecodeStage registerFile,
  ControllerIF.DecodeStage controller
);

  logic stall;
  logic flush;
  always_comb begin
    stall = controller.decodeStage.stall;
    flush = controller.decodeStage.flush;
  end

  Decoder Decoder(
    .instruction(pipeReg.instruction),
    .rs1Addr(rs1Addr),
    .rs2Addr(rs2Addr),
    .rdAddr(rdAddr),
    .imm(imm),
    .opInfo(opInfo)
  );

  RegAddr rs1Addr;
  RegAddr rs2Addr;
  RegAddr rdAddr;
  BasicData imm;
  OpInfo opInfo;
  DecodeStagePipeReg pipeReg;
  ExecuteStagePipeReg nextStage;

  always_ff@(posedge port.clk) begin
    if (port.rst == RESET || flush || (controller.fetchStageVirtual.stall && !stall)) begin
    //if (port.rst == RESET || flush || (prev.stall && !stall)) begin
    //if (port.rst == RESET || flush || prev.stall) begin
      pipeReg <= {($bits(DecodeStagePipeReg)){1'b0}};
    end
    else if (stall) begin
      pipeReg <= pipeReg;
    end
    else begin
      pipeReg <= prev.nextStage;
    end
  end

  always_comb begin
    registerFile.rs1Addr = rs1Addr;
    registerFile.rs2Addr = rs2Addr;
    
    nextStage.pc = pipeReg.pc;
    nextStage.rdAddr = rdAddr;
    nextStage.imm = imm;
    nextStage.opInfo = opInfo;
    nextStage.branchPredict = pipeReg.branchPredict;

    port.stall = stall;
    port.aluOp1Type = opInfo.aluCtrl.aluOp1Type;
    port.aluOp2Type = opInfo.aluCtrl.aluOp2Type;
    port.isStore = opInfo.isStore;
    port.nextStage = nextStage;
  end
endmodule
