import BasicTypes::*;
import PipelineTypes::*;

module MulDivUnit(
  input var clk,
  input var MulDivCode mulDivCode,
  input var BasicData op1,
  input var BasicData op2,
  output var BasicData result
);

  Multiplier Multiplier(
    .signOp1(signOp1),
    .op1(op1),
    .signOp2(signOp2),
    .op2(op2),
    .product(product)
  );

  Divider Divider(
    .op1(op1Input),
    .op2(op2Input),
    .quotient(quotient),
    .remainder(remainder)
  );


  logic signOp1;
  logic signOp2;
  BasicData op1Input;
  BasicData op2Input;

  logic [63:0] product;
  BasicData quotient;
  BasicData remainder;

  always_comb begin
    unique case (mulDivCode)
      MULDIV_MUL: begin
        signOp1 = TRUE;
        signOp2 = TRUE;
        result = product[31:0];
      end
      MULDIV_MULH: begin
        signOp1 = TRUE;
        signOp2 = TRUE;
        result = product[63:32];
      end
      MULDIV_MULHSU: begin
        //言語仕様上、オペランドの片方が符号なしだと結果も符号なしになってしまうので無理やり符号付きにする
        signOp1 = TRUE;
        signOp2 = FALSE;
        result = product[63:32];
      end
      MULDIV_MULHU: begin
        signOp1 = FALSE;
        signOp2 = FALSE;
        result = product[63:32];
      end
      MULDIV_DIV: begin
        if (op2 == 32'd0) begin
          result = 32'hffffffff;
        end
        else if (op1 == 32'h80000000 && op2 == 32'hffffffff) begin
          result = 32'h80000000;
        end
        else begin
          op1Input = $signed(op1);
          op2Input = $signed(op2);
          result = quotient;
        end
      end
      MULDIV_DIVU: begin
        if (op2 == 32'd0) begin
          result = 32'hffffffff;
        end
        else begin
          op1Input = op1;
          op2Input = op2;
          result = quotient;
        end
      end
      MULDIV_REM: begin
        if (op2 == 32'd0) begin
          result = op1;
        end
        else if (op1 == 32'h80000000 && op2 == 32'hffffffff) begin
          result = 32'd0;
        end
        else begin
          op1Input = $signed(op1);
          op2Input = $signed(op2);
          result = remainder;
        end
      end
      MULDIV_REMU: begin
        if (op2 == 32'd0) begin
          result = op1;
        end
        else begin
          op1Input = op1;
          op2Input = op2;
          result = remainder;
        end
      end
      default : begin
        result = 32'd0;
      end
    endcase
  end
endmodule
