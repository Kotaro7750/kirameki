import BasicTypes::*;

module MemoryAccessStage(
  MemoryAccessStageIF.ThisStage port,
  ExecuteStageIF.NextStage prev,
  ControllerIF.MemoryAccessStage controller,
  output var logic [7:0] uart,
  output var logic uartWe
);

  logic stall;
  logic flush;
  always_comb begin
    stall = controller.memoryAccessStage.stall;
    flush = controller.memoryAccessStage.flush;
  end
  
  MemAddr line;
  logic [1:0] offset;
  logic [1:0] offsetFF;
  BasicData shiftedWData;
  logic [3:0] wEnable;
  BasicData rData;
  logic hcAccess;
  BasicData hcOut;
  MemoryAccessStagePipeReg pipeReg;
  WriteBackStagePipeReg nextStage;

  always_ff@(posedge port.clk) begin
    if (port.rst == RESET || flush) begin
      pipeReg <= {($bits(MemoryAccessStagePipeReg)){1'b0}};
      offsetFF <= 2'b0;
    end
    else if (stall) begin
      pipeReg <= pipeReg;
      offsetFF <= offsetFF;
    end
    else begin
      pipeReg <= prev.nextStage;
      offsetFF <= offset;
    end
  end

  MemoryCtrl MemoryCtrl(
    .flush(flush),
    .isStore(prev.nextStage.memCtrl.isStore),
    .addr(prev.nextStage.memCtrl.addr),
    .memAccessWidth(prev.nextStage.memCtrl.memAccessWidth),
    .wData(prev.nextStage.memCtrl.wData),
    .line(line),
    .offset(offset),
    .shiftedWData(shiftedWData),
    .wEnable(wEnable),
    .uart(uart),
    .uartWe(uartWe)
  );


  HardwareCounter HardwareCounter(
      .CLK_IP(port.clk),
      .RSTN_IP(port.rst),
      .COUNTER_OP(hcOut)
  );

  DMem DMem(
    .pc(prev.nextStage.pc),
    .clk(port.clk),
    .wEnable(wEnable),
    .rAddr(line),
    .wAddr(line),
    .wData(shiftedWData),
    .rowAddr(prev.nextStage.memCtrl.addr),
    .rData(rData)
  );

  always_comb begin
    hcAccess = (pipeReg.rdCtrl.wData == HARDWARE_COUNTER_ADDR) && pipeReg.memCtrl.isLoad ? TRUE : FALSE;

    nextStage.pc = pipeReg.pc;
    if (pipeReg.memCtrl.isLoad) begin
      nextStage.rdCtrl.wEnable = pipeReg.rdCtrl.wEnable;
      nextStage.rdCtrl.rdAddr = pipeReg.rdCtrl.rdAddr;
      nextStage.rdCtrl.isForwardable = TRUE;
      nextStage.rdCtrl.wData = rDataGen(rData,pipeReg.memCtrl.memAccessWidth,pipeReg.memCtrl.isLoad,pipeReg.memCtrl.isLoadUnsigned,offsetFF,hcAccess,hcOut);
    end
    else begin
      nextStage.rdCtrl = pipeReg.rdCtrl;
    end

    nextStage.memCtrl = pipeReg.memCtrl;

  `ifdef BRANCH_M
    port.pc = pipeReg.pc;
    port.isBranch = pipeReg.isBranch;
    port.isBranchTaken = pipeReg.isBranchTaken;
    port.irregPc = pipeReg.irregPc;
    port.branchPredict = pipeReg.branchPredict;
  `endif
    port.nextStage = nextStage;
  end
  
  function automatic [31:0] rDataGen;
    input [31:0] rowRData;
    input [1:0] memAccessWidth;
    input isLoad;
    input isLoadUnsigned;
    input [1:0] offset;
    input bit hcAccess;
    input [31:0] hcOut;

    begin
      if (hcAccess == TRUE && isLoad) begin
        rDataGen = hcOut;
      end
      else begin
        case (memAccessWidth)
          MEM_BYTE: begin
            rDataGen = isLoadUnsigned 
              ? ({32{1'b0}}) | ((rowRData >> (offset * 8)) & 8'hff)
              : ({32{rowRData[(offset+1) * 8 - 1]}} << 8) | ((rowRData >> (offset * 8)) & 8'hff)
              ;
          end
          MEM_HALF: begin
            rDataGen = isLoadUnsigned 
              ? ({32{1'b0}}) | ((rowRData >> (offset * 8)) & 16'hffff)
              : ({32{rowRData[(offset + 2) * 8  -1]}} << 16) | ((rowRData >> (offset * 8)) & 16'hffff)
              ;
          end
          MEM_WORD: begin
            rDataGen = rowRData;
          end
          default: begin
            rDataGen = rowRData;
          end
        endcase
      end
    end
  endfunction
endmodule
