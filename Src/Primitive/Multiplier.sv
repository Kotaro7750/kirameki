import BasicTypes::*;
import PipelineTypes::*;
import MulDivTypes::*;

module SignExtender (
    input var BasicData in, 
    input var logic sign,
    output var SignExtendedBasicData out
);
    always_comb begin
        if (sign) begin
            out = {in[31], in};
        end
        else begin
            out = {1'b0, in};
        end
    end    
endmodule

module Multiplier(
  input var logic signOp1,
  input var BasicData op1,
  input var logic signOp2,
  input var BasicData op2,
  output var MulDivResult product
);

  SignExtendedBasicData exOp1;
  SignExtendedBasicData exOp2;

  SignExtender signExtenderOp1 (
    .in(op1),
    .sign(signOp1),
    .out(exOp1)
  );

  SignExtender signExtenderOp2 (
    .in(op2),
    .sign(signOp2),
    .out(exOp2)
  );

  always_comb begin
    (* use_dsp48 = "yes" *)
    product = exOp1 * exOp2;  // synthesis syn_dspstyle = "dsp48"
  end

endmodule
