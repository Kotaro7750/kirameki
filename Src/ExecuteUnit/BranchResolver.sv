import BasicTypes::*;
import PipelineTypes::*;
import OpTypes::*;

module BranchResolver(
  input var PC pc,
  input var logic isBranch,
  input var BranchResolverCtrl brCtrl,
  input var BasicData imm,
  input var BasicData rs1Data,
  input var BasicData rs2Data,
  input var BasicData irregPcOp1,
  input var BasicData irregPcOp2,
  output var PC irregPc,
  output var logic isBranchTaken
);

  always_comb begin
    unique case (brCtrl)
      BR_EQ: begin
        isBranchTaken = rs1Data == rs2Data ? TRUE : FALSE;
      end
      BR_NE: begin
        isBranchTaken = rs1Data != rs2Data ? TRUE : FALSE;
      end
      BR_LT: begin
        isBranchTaken = ((rs1Data - rs2Data) & (32'b1 << 31)) ? TRUE : FALSE;
      end
      BR_GE: begin
        isBranchTaken = (((rs2Data - rs1Data) & (32'b1 << 31)) || (rs1Data == rs2Data)) ? TRUE : FALSE;
      end
      BR_LTU: begin
        isBranchTaken = rs1Data < rs2Data ? TRUE : FALSE;
      end
      BR_GEU: begin
        isBranchTaken = rs1Data >= rs2Data ? TRUE : FALSE;
      end
      BR_JUMP: begin
        isBranchTaken = TRUE;
      end

      BR_NONE: begin
        isBranchTaken = FALSE;
      end
      default : begin
        isBranchTaken = FALSE;
      end
    endcase

    irregPc = (isBranch == TRUE) ? ((isBranchTaken == TRUE) ? irregPcOp1 + irregPcOp2 : irregPcOp1 + 4) : 31'd0;
  end
endmodule
