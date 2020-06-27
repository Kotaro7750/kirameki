module Core(
  input var logic sysclk,
  input var logic cpu_resetn,
  output var logic uart_tx
);
  FetchStageIF fetchStageIF(sysclk,cpu_resetn);

  DecodeStageIF decodeStageIF(sysclk,cpu_resetn);

  ExecuteStageIF executeStageIF(sysclk,cpu_resetn);

  MemoryAccessStageIF memoryAccessStageIF(sysclk,cpu_resetn);

  WriteBackStageIF writeBackStageIF(sysclk,cpu_resetn);

  RegisterFileIF registerFileIF(sysclk,cpu_resetn);

  ControllerIF controllerIF(sysclk,cpu_resetn);

  BranchPredictorIF branchPredictorIF(sysclk,cpu_resetn);

  BypassNetworkIF bypassNetworkIF(sysclk,cpu_resetn);

  `ifdef DEBUG
  DebugIF debugIF(sysclk,cpu_resetn);

  Debug Debug(
    .port(debugIF),
  `ifndef BRANCH_M
    .executeStage(executeStageIF),
  `endif
    .memoryAccessStage(memoryAccessStageIF),
    .writeBackStage(writeBackStageIF)
  );
  `endif

  //BranchPredictor BranchPredictor(
  TwoLevelGlobal BranchPredictor (
    .port(branchPredictorIF),
  `ifndef BRANCH_M
    .branchConfirmedStage(executeStageIF)
  `else
    .branchConfirmedStage(memoryAccessStageIF)
  `endif
  );

  logic [7:0] uart;
  logic uartWe;

  uart uart0(
      .uart_tx(uart_tx),
      .uart_wr_i(uartWe),
      .uart_dat_i(uart),
      .sys_clk_i(sysclk),
      .sys_rstn_i(cpu_resetn)
  );

`ifndef NOT_USE_BTB
  BTB BTB(
    .clk(sysclk),
    .fetchStage(fetchStageIF),
    .controller(controllerIF),
  `ifndef BRANCH_M
    .execute(executeStageIF)
  `else
    .memoryAccess(memoryAccessStageIF)
  `endif
  );
`endif

  Controller Controller(
    .port(controllerIF),
    .fetch(fetchStageIF),
    .decode(decodeStageIF),
    .execute(executeStageIF),
    .memoryAccess(memoryAccessStageIF),
    .registerFile(registerFileIF)
  );

  RegisterFile RegisterFile(
    .port(registerFileIF)
  );

  FetchStage FetchStage(
    .port(fetchStageIF),
    .controller(controllerIF),
    .branchPredictor(branchPredictorIF)
  );
  
  DecodeStage DecodeStage(
    .port(decodeStageIF),
    .prev(fetchStageIF),
    .registerFile(registerFileIF),
    .controller(controllerIF)
  );

  ExecuteStage ExecuteStage(
    .port(executeStageIF),
    .prev(decodeStageIF),
    .controller(controllerIF)
  );

  MemoryAccessStage MemoryAccessStage(
    .port(memoryAccessStageIF),
    .prev(executeStageIF),
    .controller(controllerIF),
    .uart(uart),
    .uartWe(uartWe)
  );

  WriteBackStage WriteBackStage(
    .port(writeBackStageIF),
    .prev(memoryAccessStageIF),
    .registerFile(registerFileIF)
  );
endmodule
