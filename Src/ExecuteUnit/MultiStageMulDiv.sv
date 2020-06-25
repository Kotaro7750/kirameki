`include "../SynthesisMacros.svh"
import BasicTypes::*;

module MultiStageMulDiv(
  input var clk,
  input var rst,
`ifdef BRANCH_M
  input var clear,
`endif
  input var isMulDiv,
  input var MulDivCode mulDivCode,
  input var BasicData op1,
  input var BasicData op2,
  output var logic isMulDivUnitBusy,
  output var BasicData result
);

  BasicData mulDivResult;
  logic [3:0] state;
  MulDivCode mulDivCodeReg;
  BasicData op1Reg;
  BasicData op2Reg;

  MulDivUnit MulDivUnit(
    .clk(clk),
    .mulDivCode(mulDivCodeReg),
    .op1(op1Reg),
    .op2(op2Reg),
    .result(mulDivResult)
  );

  always_ff@(posedge clk) begin
  `ifndef BRANCH_M
    if (rst == RESET || (!isMulDiv && state == 4'd0)) begin
  `else
    if (rst == RESET || (!isMulDiv && state == 4'd0) || clear) begin
  `endif
      isMulDivUnitBusy <= FALSE;
      state <= 4'd0;
    end
    else if (isMulDiv && state == 4'd0) begin
      isMulDivUnitBusy <= TRUE;
      state <= 4'd1;
      mulDivCodeReg <= mulDivCode;
    end
    else if (state == 4'd1) begin
      isMulDivUnitBusy <= TRUE;
      state <= state + 1;
      op1Reg <= op1;
      op2Reg <= op2;
    end
    else if (state == 4'd8) begin
      state <= 4'd0;
      isMulDivUnitBusy <= FALSE;
      result <= mulDivResult;
    end
    else begin
      isMulDivUnitBusy <= TRUE;
      state <= state + 1;
    end
  end
endmodule
