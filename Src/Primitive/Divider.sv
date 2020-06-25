import BasicTypes::*;
import PipelineTypes::*;

module Divider(
  input var BasicData op1,
  input var BasicData op2,
  output var BasicData quotient,
  output var BasicData remainder
);

  assign quotient = op1 / op2;
  assign remainder = op1 % op2;

endmodule
