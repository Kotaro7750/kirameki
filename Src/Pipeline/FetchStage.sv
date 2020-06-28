`include "../SynthesisMacros.svh"
import BasicTypes::*;

module FetchStage(
  FetchStageIF.ThisStage port,
  ControllerIF.FetchStage controller,
  BranchPredictorIF.FetchStage branchPredictor
);

  logic stall;
  logic flush;
  always_comb begin
    stall = controller.fetchStage.stall;
    flush = controller.fetchStage.flush;
  end

  PC pc;
  PC npc;
  PC irregPc;
  Instruction instruction;
  logic isBranch;
  logic hit;  //BTBにヒットしたかどうか
  PC btbPc; //BTBの結果
  DecodeStagePipeReg nextStage;

  IMem IMem(
    .clk(port.clk),
    .rst(port.rst),
    .stall(stall),
    .pc(npc), //IMemの読みはクロック同期なので、内容的にはpcだが、記述としてはnpc。BTBも同様。
    //.irregPc(irregPc),
    .instruction(instruction)
  );

  NextPcGen NextPcGen(
    .pc(pc),
    .irregPc(irregPc),
    .isBranch(isBranch),
    .isBranchTakenPredicted(branchPredictor.isBranchTakenPredicted),
    .stall(stall),
    .flush(flush),
    .btbHit(port.btbHit),
    .btbPredictedPc(port.btbPredictedPc),
    .npc(npc)
  );

  BranchPredictGen BranchPredictGen(
    .npc(npc),
    .isBranch(isBranch),
    .globalBranchHistory(branchPredictor.globalBranchHistory),
    .isBranchTakenPredicted(branchPredictor.isBranchTakenPredicted),
    .btbHit(port.btbHit),
    .btbPredictedPc(port.btbPredictedPc),
    .branchPredict(nextStage.branchPredict)
  );


  always_ff@(posedge port.clk) begin
    if (port.rst == RESET) begin
      pc <= {(ADDR_WIDTH){1'b0}};
    end
    else begin
      pc <= npc;
    end
  end

  always_comb begin
    irregPc = controller.irregPc;
    isBranch = checkIfBranch(instruction);


    nextStage.pc = pc;
    nextStage.instruction = instruction;

    port.pc = npc;
    port.stall = stall;
    port.isBranch = isBranch; //TODO とりあえずcontrollerに入れておけば次のサイクルでstallとかしてくれるようにする。
    port.branchPredict = nextStage.branchPredict;

  `ifdef BRANCH_M
    port.nextStage = flush ? {($bits(DecodeStagePipeReg)){1'b0}} : nextStage;
  `else
    port.nextStage = (flush || (irregPc != {(ADDR_WIDTH){1'b0}} && irregPc != pc)) ? {($bits(DecodeStagePipeReg)){1'b0}} : nextStage;
  `endif
  end
  
  //ここで分岐命令かチェックする。
  //分岐命令はJAL,JALR,Beq,Bne,Blt,Bge,Bltu,Bgeuで、これらはすべて7bit目が1
  function automatic [0:0] checkIfBranch(input Instruction instruction);
    begin
      if (instruction[6] == 1'b0) begin
        checkIfBranch = FALSE;
      end
      else begin
        checkIfBranch = TRUE;
      end
    end
  endfunction
endmodule
