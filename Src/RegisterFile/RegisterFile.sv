import BasicTypes::*;

module RegisterFile(
  RegisterFileIF.RegisterFile port
);

  BasicData registerFile[0:REG_NUMBER - 1];

  assign port.rs1Data = registerFile[port.rs1Addr];
  assign port.rs2Data = registerFile[port.rs2Addr];

  always_ff @(posedge port.clk) begin
    if (port.rst == RESET) begin
      for (integer i = 0; i < REG_NUMBER; i = i+1) begin
        registerFile[i] <= {(DATA_WIDTH){1'b0}};
      end
    end
    else if (port.rdCtrl.wEnable == TRUE && port.rdCtrl.rdAddr != ZERO_REG) begin
      registerFile[port.rdCtrl.rdAddr] <= port.rdCtrl.wData;
    end
  end
endmodule
