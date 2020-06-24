import BasicTypes::*;
import PipelineTypes::*;

module IntALU(
  input var [3:0]alucode, //演算種別
  input var BasicData op1,
  input var BasicData op2,
  output var BasicData aluResult
);

  always_comb begin
    case (alucode)
      ALU_JUMP: begin
        aluResult = op2 + 4;
      end

      ALU_ADD: begin
        aluResult = (op1 + op2) & 32'hffffffff;
      end

      ALU_SUB: begin
        aluResult = op1 - op2;
      end

      ALU_SLT: begin
        if ((op1 - op2) & (32'b1 << 31)) begin
          aluResult = 1;
        end
        else begin
          aluResult = 0;
        end
      end

      ALU_SLTU: begin
        aluResult = op1 < op2 ? 1 : 0;;
      end

      ALU_XOR: begin
        aluResult = op1 ^ op2;
      end

      ALU_OR: begin
        aluResult = op1 | op2;
      end

      ALU_AND: begin
        aluResult = op1 & op2;
      end

      ALU_SLL: begin
        aluResult = op1 << (op2 & 5'b11111);
      end

      ALU_SRL: begin
        aluResult = op1 >> (op2 & 5'b11111);
      end

      ALU_SRA: begin
        aluResult = $signed(op1) >>> ($signed(op2) & 5'b11111);
      end

      ALU_NONE: begin
        aluResult = 32'd0;
      end

      default: begin
        aluResult = 32'd0;
      end
    endcase
    
  end
endmodule
