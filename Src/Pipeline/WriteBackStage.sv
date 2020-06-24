module WriteBackStage(
  WriteBackStageIF.ThisStage port,
  MemoryAccessStageIF.NextStage prev,
  RegisterFileIF.WriteBackStage registerFile
);
  
  WriteBackStagePipeReg pipeReg;

  always_ff@(posedge port.clk) begin
    if (port.rst == RESET) begin
      pipeReg <= {($bits(WriteBackStagePipeReg)){1'b0}};
    end
    else begin
      pipeReg <= prev.nextStage;
    end

    if (prev.nextStage.rdCtrl.wEnable) begin
     if (prev.nextStage.memCtrl.isLoad) $display("0x%4h: ", prev.nextStage.pc,"x%02d",prev.nextStage.rdCtrl.rdAddr," = ","0x%08h",prev.nextStage.rdCtrl.wData," 0x%08h",prev.nextStage.rdCtrl.wData," <- ","mem[0x%08h]",prev.nextStage.memCtrl.addr);
     else $display("0x%4h: ", prev.nextStage.pc,"x%02d",prev.nextStage.rdCtrl.rdAddr," = ","0x%08h",prev.nextStage.rdCtrl.wData);
    end
  end

  always_comb begin
    registerFile.pc = pipeReg.pc;
    registerFile.rdCtrl = prev.nextStage.rdCtrl;
  end
endmodule
