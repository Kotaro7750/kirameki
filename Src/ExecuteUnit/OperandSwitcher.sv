import BasicTypes::*;
import PipelineTypes::*;

module OperandSwitcher(
  input var PC pc,
  input var BasicData rs1,
  input var BasicData rs2,
  input var BasicData imm,
  input var ALUCtrl aluCtrl,
  input var OpType opType,
  output var BasicData aluOp1,
  output var BasicData aluOp2,
  output var BasicData irregPcOp1,
  output var BasicData irregPcOp2
);

  assign aluOp1 = (aluCtrl.aluOp1Type == OP_TYPE_REG) ? rs1 : (aluCtrl.aluOp1Type == OP_TYPE_IMM) ? imm : (aluCtrl.aluOp1Type == OP_TYPE_PC) ? pc :  {(DATA_WIDTH){1'b0}};
  assign aluOp2 = (aluCtrl.aluOp2Type == OP_TYPE_REG) ? rs2 : (aluCtrl.aluOp2Type == OP_TYPE_IMM) ? imm : (aluCtrl.aluOp2Type == OP_TYPE_PC) ? pc :  {(DATA_WIDTH){1'b0}};

  always_comb begin
    unique case (opType)
      TYPE_B,TYPE_J: begin
        irregPcOp1 = pc;
        irregPcOp2 = imm;
      end
      TYPE_JALR: begin
        irregPcOp1 = rs1;
        irregPcOp2 = imm;
      end
      default : begin
        irregPcOp1 = pc;
        irregPcOp2 = 32'd4;
      end
    endcase
  end
endmodule
