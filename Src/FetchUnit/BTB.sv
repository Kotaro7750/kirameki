`include "../SynthesisMacros.svh"
import BasicTypes::*;
import PipelineTypes::*;
import FetchUnitTypes::*;

module BTB(
  input var logic clk,
  FetchStageIF.BTB fetchStage,
  ControllerIF.BTB controller,
  `ifndef BRANCH_M
  ExecuteStageIF.BTB execute
  `else
  MemoryAccessStageIF.BTB memoryAccess
  `endif
);
  
  PC pc;
  PC requestedPc;
  PC requestedPcFF;
  logic isBranch;
  logic isBranchTaken;
  PC irregPc;

  logic wEnable;
  BTBEntry wBtbEntry;
  BTBIndex wBtbIndex;
  BTBEntry rBtbEntry;
  BTBIndex rBtbIndex;

  always_ff@(posedge clk) begin
    //requestedPcFF <= requestedPc;
    requestedPcFF <= irregPc != {(ADDR_WIDTH){1'b0}} ? irregPc : fetchStage.pc;
  end

  always_comb begin
  `ifndef BRANCH_M
    pc = execute.pc;
    isBranch = execute.isBranch;
    isBranchTaken = execute.isBranchTaken;
    //irregPc = execute.irregPc;
  `else
    pc = memoryAccess.pc;
    isBranch = memoryAccess.isBranch;
    isBranchTaken = memoryAccess.isBranchTaken;
    //irregPc = memoryAccess.irregPc;
  `endif
    irregPc = controller.irregPc;
  end

  generate
    BlockDualPortRAM #(
      .ENTRY_NUM(BTB_ENTRY_NUM),
      .ENTRY_BIT_SIZE($bits(BTBEntry))
    )
    btbArray(
      .clk(clk),
      .wEnable(wEnable),
      .wAddr(wBtbIndex),
      .wData(wBtbEntry),
      .rAddr(rBtbIndex),
      .rData(rBtbEntry)
    );
  endgenerate

  always_comb begin
    requestedPc = irregPc != {(ADDR_WIDTH){1'b0}} ? irregPc : fetchStage.pc;

    if (isBranch && isBranchTaken) begin
      wEnable = TRUE;
    end
    else begin
      wEnable = FALSE;
    end

    if (rBtbEntry.tag == ToBTB_Tag(requestedPcFF)) begin
      fetchStage.btbHit = TRUE;
      fetchStage.btbPredictedPc = ToRawAddrFromBTB_PC(rBtbEntry.content,requestedPcFF);
    end
    else begin
      fetchStage.btbHit = FALSE;
    end

    rBtbIndex = ToBTB_Index(requestedPc);

    wBtbIndex = ToBTB_Index(pc);
    wBtbEntry.tag = ToBTB_Tag(pc);
    wBtbEntry.content = ToBTB_Content(irregPc);
  end
endmodule
