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
  end

  always_comb begin
    registerFile.pc = pipeReg.pc;
    registerFile.rdCtrl = prev.nextStage.rdCtrl;
  `ifdef DEBUG
    port.pipeReg = prev.nextStage;
  `endif
  end
endmodule
