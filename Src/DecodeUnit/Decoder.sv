import BasicTypes::*;
import PipelineTypes::*;
import OpTypes::*;
import MemoryTypes::*;
import DecoderFunc::*;

module Decoder(
  input var Instruction instruction,
  output var RegAddr rs1Addr,
  output var RegAddr rs2Addr,
  output var RegAddr rdAddr,
  output var BasicData imm,
  output var OpInfo opInfo
);

  //OpCode opCode;
  logic [6:0] opCode;
  Funct3 funct3;
  Funct7 funct7;

  assign opCode = instruction[6:0];
  assign funct3 = instruction[14:12];
  assign funct7 = instruction[31:25];

  //これ以降はreg用
  always_comb begin
    unique case (opCode)
      //ADDi ~ SRAi
      RISCV_OP_IMM: begin
        rs1Addr = instruction[19:15];
        rs2Addr = 0;
        rdAddr = instruction[11:7];

        DecodeI(opInfo,imm,instruction,rdAddr,funct3,funct7);
      end

      //ADD ~ AND
      RISCV_OP: begin
        rs1Addr = instruction[19:15];
        rs2Addr = instruction[24:20];
        rdAddr = instruction[11:7];

        DecodeR(opInfo,imm,rdAddr,funct3,funct7);
      end

    //LUi
    RISCV_LUI,RISCV_AUIPC: begin
        rs1Addr = 0;
        rs2Addr = 0;
        rdAddr = instruction[11:7];

        DecodeU(opInfo,imm,instruction,rdAddr,opCode);
    end

    //JAL
    RISCV_JAL: begin
        rs1Addr = 0;
        rs2Addr = 0;
        rdAddr = instruction[11:7];

        DecodeJ(opInfo,imm,instruction,rdAddr);
    end

    //JALR
    RISCV_JALR: begin
        rs1Addr = instruction[19:15];
        rs2Addr = 0;
        rdAddr = instruction[11:7];

        DecodeJALR(opInfo,imm,instruction,rdAddr);
    end

    //Beq ~ Bgeu
    RISCV_BR:begin
        rs1Addr = instruction[19:15];
        rs2Addr = instruction[24:20];
        rdAddr = ZERO_REG;

        DecodeB(opInfo,imm,instruction,funct3);
    end

    //Sb ~ Sw
    RISCV_ST: begin
        rs1Addr = instruction[19:15];
        rs2Addr = instruction[24:20];
        rdAddr = ZERO_REG;

        DecodeST(opInfo,imm,instruction,funct3);
    end

    //Lb ~ Lhu
    RISCV_LD: begin
        rs1Addr = instruction[19:15];
        rs2Addr = 0;
        rdAddr = instruction[11:7];

        DecodeLD(opInfo,imm,instruction,rdAddr,funct3);
    end

    default: begin
      rs1Addr = ZERO_REG;
      rs2Addr = ZERO_REG;
      rdAddr = ZERO_REG;
      imm = 32'd0;
      opInfo = {($bits(OpInfo)){1'b0}};
    end
    endcase
  end
endmodule
