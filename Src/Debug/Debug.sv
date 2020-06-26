`include "../SynthesisMacros.svh"
import BasicTypes::*;
import MemoryTypes::*;

module Debug(
  DebugIF.ThisStage port,
  MemoryAccessStageIF.Debug memoryAccessStage,
  WriteBackStageIF.Debug writeBackStage
);

  PC wbPc;
  MemCtrl wbMemCtrl;
  RDCtrl wbRdCtrl;
  BasicData hcOut;

  always_ff@(posedge port.clk) begin
    if (wbRdCtrl.wEnable && port.rst != RESET) begin
      if (wbMemCtrl.isLoad) begin
      `ifdef WITH_HC
        $display("0x%4h ", wbPc,"%d: ", hcOut, "x%02d",wbRdCtrl.rdAddr," = ","0x%08h",wbRdCtrl.wData," 0x%08h",wbRdCtrl.wData," <- ","mem[0x%08h]",wbMemCtrl.addr);
      `else
        $display("0x%4h: ", wbPc, "x%02d",wbRdCtrl.rdAddr," = ","0x%08h",wbRdCtrl.wData," 0x%08h",wbRdCtrl.wData," <- ","mem[0x%08h]",wbMemCtrl.addr);
      `endif
      end
      else begin
      `ifdef WITH_HC
        $display("0x%4h ", wbPc,"%d: ", hcOut, "x%02d",wbRdCtrl.rdAddr," = ","0x%08h",wbRdCtrl.wData);
      `else
        $display("0x%4h: ", wbPc, "x%02d",wbRdCtrl.rdAddr," = ","0x%08h",wbRdCtrl.wData);
      `endif
      end
    end

    if (memoryAccessStage.debugWEnable) begin
      `ifdef WITH_HC
        $display("0x%4h ", memoryAccessStage.debugPc,"%d: ", hcOut, "mem[0x%08h]",memoryAccessStage.debugAddr," <- ","0x%h",memoryAccessStage.debugWData);
      `else
        $display("0x%4h: ", memoryAccessStage.debugPc,"mem[0x%08h]",memoryAccessStage.debugAddr," <- ","0x%h",memoryAccessStage.debugWData);
      `endif
    end
  end

  always_comb begin
    hcOut = memoryAccessStage.hcOut;

    wbPc = writeBackStage.pipeReg.pc;
    wbMemCtrl = writeBackStage.pipeReg.memCtrl;
    wbRdCtrl = writeBackStage.pipeReg.rdCtrl;
  end
endmodule
