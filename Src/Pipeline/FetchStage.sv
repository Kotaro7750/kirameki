import BasicTypes::*;

module FetchStage(
  FetchStageIF.ThisStage port,
  ControllerIF.FetchStage controller,
//`ifndef BRANCH_M
//  ExecuteStageIF.FetchStage branchConfirmedStage,
//`else
//  MemoryAccessStageIF.FetchStage branchConfirmedStage,
//`endif
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
    .irregPc(irregPc),
    .instruction(instruction)
  );

  always_ff@(posedge port.clk) begin
    if (port.rst == RESET || flush) begin
      pc <= {(ADDR_WIDTH){1'b0}};
    end
    else if (stall) begin
      pc <= pc;
    end
    else if (irregPc != {(ADDR_WIDTH){1'b0}}) begin
      pc <= irregPc;
    end
    else begin
      pc <= npc;
    end
  end

  always_comb begin
    irregPc = controller.irregPc;
    isBranch = checkIfBranch(instruction);

    if (isBranch) begin
      if (branchPredictor.isBranchTakenPredicted) begin
        if (port.btbHit) begin
          npc = port.btbPredictedPc;
          nextStage.branchPredict.isNextPcPredicted = TRUE;
          nextStage.branchPredict.predictedNextPC = port.btbPredictedPc;
          nextStage.branchPredict.isBranchTakenPredicted = branchPredictor.isBranchTakenPredicted;
        end
        else begin
          npc = pc + 4;
          nextStage.branchPredict.isNextPcPredicted = FALSE;
          nextStage.branchPredict.predictedNextPC = {(ADDR_WIDTH){1'b0}};
          nextStage.branchPredict.isBranchTakenPredicted = TRUE;
        end
      end
      else begin
        npc = pc + 4;
        nextStage.branchPredict.isNextPcPredicted = TRUE;
        nextStage.branchPredict.predictedNextPC = {(ADDR_WIDTH){1'b0}}; //後でirregPcと比較するので0の方が都合がいい
        nextStage.branchPredict.isBranchTakenPredicted = FALSE;
      end
    end
    else begin
      npc = pc + 4;
      nextStage.branchPredict.isNextPcPredicted = FALSE;
      nextStage.branchPredict.predictedNextPC = {(ADDR_WIDTH){1'b0}};
      nextStage.branchPredict.isBranchTakenPredicted = FALSE;
    end
    //if (branchPredictor.isBranchTakenPredicted && isBranch) begin
    //  if (port.btbHit) begin
    //    npc = port.btbPredictedPc;
    //    nextStage.branchPredict.isNextPcPredicted = TRUE;
    //    nextStage.branchPredict.predictedNextPC = port.btbPredictedPc;
    //    nextStage.branchPredict.isBranchTakenPredicted = branchPredictor.isBranchTakenPredicted;
    //  end
    //  else begin
    //    npc = pc + 4;
    //    nextStage.branchPredict.isNextPcPredicted = FALSE;
    //    nextStage.branchPredict.predictedNextPC = {(ADDR_WIDTH){1'b0}};
    //    nextStage.branchPredict.isBranchTakenPredicted = FALSE;
    //  end
    //end
    //else begin
    //  npc = pc + 4;
    //  nextStage.branchPredict.isNextPcPredicted = FALSE;
    //  nextStage.branchPredict.predictedNextPC = {(ADDR_WIDTH){1'b0}};
    //  nextStage.branchPredict.isBranchTakenPredicted = FALSE;
    //end

    nextStage.pc = pc;
    nextStage.instruction = instruction;

    //port.pc = npc;
    port.pc = stall ? pc : npc;
    port.stall = stall;
    port.isBranch = isBranch; //TODO とりあえずcontrollerに入れておけば次のサイクルでstallとかしてくれるようにする。
    port.branchPredict = nextStage.branchPredict;

    port.nextStage = nextStage;
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
