package DecoderFunc;

import BasicTypes::*;
import OpTypes::*;
import MemoryTypes::*;

function automatic void DecodeI(
  output OpInfo opInfo,
  output BasicData imm,
  input BasicData inst,
  input RegAddr rdAddr,
  input Funct3 funct3,
  input Funct7 funct7
);
  begin
    imm = {{20{inst[31]}},inst[31:20]};

    opInfo.opType = TYPE_I;

    opInfo.aluCtrl.aluOp1Type = OP_TYPE_REG;
    opInfo.aluCtrl.aluOp2Type = OP_TYPE_IMM;

    opInfo.isMulDiv = FALSE;
    opInfo.mulDivCode = MULDIV_MUL;


    unique case (funct3)
      //ADD,SUB
      3'b000: begin
        opInfo.aluCtrl.aluCode = ALU_ADD;
      end
      //SLT
      3'b010: begin
        opInfo.aluCtrl.aluCode = ALU_SLT;
      end
      //SLTU
      3'b011: begin
        opInfo.aluCtrl.aluCode = ALU_SLTU;
      end
      //XOR
      3'b100: begin
        opInfo.aluCtrl.aluCode = ALU_XOR;
      end
      //SLL
      3'b001: begin
        opInfo.aluCtrl.aluCode = ALU_SLL;
      end
      //SRL,SRA
      3'b101: begin
        unique case (funct7)
          7'b0000000: begin
            opInfo.aluCtrl.aluCode = ALU_SRL;
          end
          7'b0100000: begin
            opInfo.aluCtrl.aluCode = ALU_SRA;
          end
          default : begin
            opInfo.aluCtrl.aluCode = ALU_NONE;
          end
        endcase
      end
      //OR
      3'b110: begin
        opInfo.aluCtrl.aluCode = ALU_OR;
      end
      //AND
      3'b111: begin
        opInfo.aluCtrl.aluCode = ALU_AND;
      end
      default : begin
        opInfo.aluCtrl.aluCode = ALU_NONE;
      end
    endcase

    opInfo.brCtrl = BR_NONE;

    opInfo.wEnable = rdAddr == 5'd0 ? FALSE : TRUE;
    opInfo.memAccessWidth = MEM_NONE;
    opInfo.isForwardable = TRUE;
    opInfo.isBranch = FALSE;
    opInfo.isStore = FALSE;
    opInfo.isLoad = FALSE;
    opInfo.isLoadUnsigned = FALSE;
    opInfo.isBubble = FALSE;
  end
endfunction

function automatic void DecodeR(
  output OpInfo opInfo,
  output BasicData imm,
  input RegAddr rdAddr,
  input Funct3 funct3,
  input Funct7 funct7
);
  begin
    imm = 32'd0;

    opInfo.opType = TYPE_R;

    opInfo.aluCtrl.aluOp1Type = OP_TYPE_REG;
    opInfo.aluCtrl.aluOp2Type = OP_TYPE_REG;

    opInfo.isMulDiv = FALSE;
    opInfo.mulDivCode = MULDIV_MUL;

    unique case (funct3)
      //ADD,SUB,MUL
      3'b000: begin
        unique case (funct7)
          7'b0000000: begin
            opInfo.aluCtrl.aluCode = ALU_ADD;
          end
          7'b0100000: begin
            opInfo.aluCtrl.aluCode = ALU_SUB;
          end
          7'b0000001: begin
            opInfo.aluCtrl.aluCode = ALU_NONE;
            opInfo.isMulDiv = TRUE;
            opInfo.mulDivCode = MULDIV_MUL;
          end
          default : begin
            opInfo.aluCtrl.aluCode = ALU_NONE;
          end
        endcase
      end
      //SLL,MULH
      3'b001: begin
        if (funct7 == 7'b0000001) begin
          opInfo.aluCtrl.aluCode = ALU_NONE;
          opInfo.isMulDiv = TRUE;
          opInfo.mulDivCode = MULDIV_MULH;
        end
        else begin
          opInfo.aluCtrl.aluCode = ALU_SLL;
        end
      end
      //SLT,MULHsu
      3'b010: begin
        if (funct7 == 7'b0000001) begin
          opInfo.aluCtrl.aluCode = ALU_NONE;
          opInfo.isMulDiv = TRUE;
          opInfo.mulDivCode = MULDIV_MULHSU;
        end
        else begin
          opInfo.aluCtrl.aluCode = ALU_SLT;
        end
      end
      //SLTU,MULHu
      3'b011: begin
        if (funct7 == 7'b0000001) begin
          opInfo.aluCtrl.aluCode = ALU_NONE;
          opInfo.isMulDiv = TRUE;
          opInfo.mulDivCode = MULDIV_MULHU;
        end
        else begin
          opInfo.aluCtrl.aluCode = ALU_SLTU;
        end
      end
      //XOR,DIV
      3'b100: begin
        if (funct7 == 7'b0000001) begin
          opInfo.aluCtrl.aluCode = ALU_NONE;
          opInfo.isMulDiv = TRUE;
          opInfo.mulDivCode = MULDIV_DIV;
        end
        else begin
          opInfo.aluCtrl.aluCode = ALU_XOR;
        end
      end
      //SRL,SRA,DIVu
      3'b101: begin
        unique case (funct7)
          7'b0000000: begin
            opInfo.aluCtrl.aluCode = ALU_SRL;
          end
          7'b0100000: begin
            opInfo.aluCtrl.aluCode = ALU_SRA;
          end
          7'b0000001: begin
            opInfo.aluCtrl.aluCode = ALU_NONE;
            opInfo.isMulDiv = TRUE;
            opInfo.mulDivCode = MULDIV_DIVU;
          end
          default : begin
            opInfo.aluCtrl.aluCode = ALU_NONE;
          end
        endcase
      end
      //OR,REM
      3'b110: begin
        if (funct7 == 7'b0000001) begin
          opInfo.aluCtrl.aluCode = ALU_NONE;
          opInfo.isMulDiv = TRUE;
          opInfo.mulDivCode = MULDIV_REM;
        end
        else begin
          opInfo.aluCtrl.aluCode = ALU_OR;
        end
      end
      //AND
      3'b111: begin
        if (funct7 == 7'b0000001) begin
          opInfo.aluCtrl.aluCode = ALU_NONE;
          opInfo.isMulDiv = TRUE;
          opInfo.mulDivCode = MULDIV_REMU;
        end
        else begin
          opInfo.aluCtrl.aluCode = ALU_AND;
        end
      end
      default : begin
        opInfo.aluCtrl.aluCode = ALU_NONE;
      end
    endcase

    opInfo.brCtrl = BR_NONE;

    opInfo.wEnable = rdAddr == 5'd0 ? FALSE : TRUE;
    opInfo.memAccessWidth = MEM_NONE;
    opInfo.isForwardable = TRUE;
    opInfo.isBranch = FALSE;
    opInfo.isStore = FALSE;
    opInfo.isLoad = FALSE;
    opInfo.isLoadUnsigned = FALSE;
    opInfo.isBubble = FALSE;
  end
endfunction

function automatic void DecodeU(
  output OpInfo opInfo,
  output BasicData imm,
  input BasicData inst,
  input RegAddr rdAddr,
  input logic [6:0] opCode
);
  begin
    imm = {inst[31:12],{12{1'b0}}};

    opInfo.opType = TYPE_U;

    opInfo.aluCtrl.aluCode = ALU_ADD;

    opInfo.isMulDiv = FALSE;
    opInfo.mulDivCode = MULDIV_MUL;


    case (opCode)
      RISCV_LUI: begin
        opInfo.aluCtrl.aluOp1Type = OP_TYPE_NONE;
        opInfo.aluCtrl.aluOp2Type = OP_TYPE_IMM;
      end
      RISCV_AUIPC: begin
        opInfo.aluCtrl.aluOp1Type = OP_TYPE_IMM;
        opInfo.aluCtrl.aluOp2Type = OP_TYPE_PC;
      end
      default : begin
        opInfo.aluCtrl.aluOp1Type = OP_TYPE_NONE;
        opInfo.aluCtrl.aluOp2Type = OP_TYPE_NONE;
      end
    endcase

    opInfo.brCtrl = BR_NONE;

    opInfo.wEnable = rdAddr == 5'd0 ? FALSE : TRUE;
    opInfo.memAccessWidth = MEM_NONE;
    opInfo.isForwardable = TRUE;
    opInfo.isBranch = FALSE;
    opInfo.isStore = FALSE;
    opInfo.isLoad = FALSE;
    opInfo.isLoadUnsigned = FALSE;
    opInfo.isBubble = FALSE;
  end
endfunction

function automatic void DecodeJ(
  output OpInfo opInfo,
  output BasicData imm,
  input BasicData inst,
  input RegAddr rdAddr
);
  begin
    imm = {{11{inst[31]}},inst[31],inst[19:12],inst[20],inst[30:21],{1'b0}};

    opInfo.opType = TYPE_J;

    opInfo.aluCtrl.aluCode = ALU_JUMP;
    opInfo.aluCtrl.aluOp1Type = OP_TYPE_NONE;
    opInfo.aluCtrl.aluOp2Type = OP_TYPE_PC;

    opInfo.brCtrl = BR_JUMP;

    opInfo.isMulDiv = FALSE;
    opInfo.mulDivCode = MULDIV_MUL;


    opInfo.wEnable = rdAddr == 5'd0 ? FALSE : TRUE;
    opInfo.memAccessWidth = MEM_NONE;
    opInfo.isForwardable = FALSE;
    opInfo.isBranch = TRUE;
    opInfo.isStore = FALSE;
    opInfo.isLoad = FALSE;
    opInfo.isLoadUnsigned = FALSE;
    opInfo.isBubble = FALSE;
  end
endfunction

function automatic void DecodeJALR(
  output OpInfo opInfo,
  output BasicData imm,
  input BasicData inst,
  input RegAddr rdAddr
);
  begin
    imm = {{20{inst[31]}},inst[31:20]};

    opInfo.opType = TYPE_JALR;

    opInfo.aluCtrl.aluCode = ALU_JUMP;
    //opInfo.aluCtrl.aluOp1Type = OP_TYPE_NONE;
    opInfo.aluCtrl.aluOp1Type = OP_TYPE_REG;
    opInfo.aluCtrl.aluOp2Type = OP_TYPE_PC;

    opInfo.brCtrl = BR_JUMP;

    opInfo.isMulDiv = FALSE;
    opInfo.mulDivCode = MULDIV_MUL;


    opInfo.wEnable = rdAddr == 5'd0 ? FALSE : TRUE;
    opInfo.memAccessWidth = MEM_NONE;
    opInfo.isForwardable = FALSE;
    opInfo.isBranch = TRUE;
    opInfo.isStore = FALSE;
    opInfo.isLoad = FALSE;
    opInfo.isLoadUnsigned = FALSE;
    opInfo.isBubble = FALSE;
  end
endfunction

function automatic void DecodeB(
  output OpInfo opInfo,
  output BasicData imm,
  input BasicData inst,
  input Funct3 funct3
);
  begin
    imm = {{19{inst[31]}},inst[31],inst[7],inst[30:25],inst[11:8],{1'b0}};

    opInfo.opType = TYPE_B;

    opInfo.aluCtrl.aluCode = ALU_NONE;
    //TODO alu的にはnoneだが、ハザード検知に使う
    //opInfo.aluCtrl.aluOp1Type = OP_TYPE_NONE;
    //opInfo.aluCtrl.aluOp2Type = OP_TYPE_NONE;
    opInfo.aluCtrl.aluOp1Type = OP_TYPE_REG;
    opInfo.aluCtrl.aluOp2Type = OP_TYPE_REG;

    opInfo.isMulDiv = FALSE;
    opInfo.mulDivCode = MULDIV_MUL;


    opInfo.wEnable = FALSE;
    opInfo.memAccessWidth = MEM_NONE;
    opInfo.isForwardable = FALSE;
    opInfo.isBranch = TRUE;
    opInfo.isStore = FALSE;
    opInfo.isLoad = FALSE;
    opInfo.isLoadUnsigned = FALSE;
    opInfo.isBubble = FALSE;

    unique case (funct3)
      3'b000: begin
        opInfo.brCtrl = BR_EQ;
      end
      3'b001: begin
        opInfo.brCtrl = BR_NE;
      end
      3'b100: begin
        opInfo.brCtrl = BR_LT;
      end
      3'b101: begin
        opInfo.brCtrl = BR_GE;
      end
      3'b110: begin
        opInfo.brCtrl = BR_LTU;
      end
      3'b111: begin
        opInfo.brCtrl = BR_GEU;
      end
      default : begin
        opInfo.brCtrl = BR_NONE;
      end
    endcase
  end
endfunction

function automatic void DecodeST(
  output OpInfo opInfo,
  output BasicData imm,
  input BasicData inst,
  input Funct3 funct3
);
  begin
    imm = {{20{inst[31]}},inst[31:25],inst[11:7]};

    opInfo.opType = TYPE_S;

    opInfo.aluCtrl.aluCode = ALU_ADD;
    opInfo.aluCtrl.aluOp1Type = OP_TYPE_REG;
    opInfo.aluCtrl.aluOp2Type = OP_TYPE_IMM;

    opInfo.brCtrl = BR_NONE;

    opInfo.isMulDiv = FALSE;
    opInfo.mulDivCode = MULDIV_MUL;


    opInfo.wEnable = FALSE;
    opInfo.isForwardable = FALSE;
    opInfo.isStore = TRUE;
    opInfo.isBranch = FALSE;
    opInfo.isLoad = FALSE;
    opInfo.isLoadUnsigned = FALSE;
    opInfo.isBubble = FALSE;

    case (funct3)
      3'b000: begin
        opInfo.memAccessWidth = MEM_BYTE;
      end
      3'b001: begin
        opInfo.memAccessWidth = MEM_HALF;
      end
      3'b010: begin
        opInfo.memAccessWidth = MEM_WORD;
      end
      default : begin
        opInfo.memAccessWidth = MEM_NONE;
      end
    endcase
  end
endfunction

function automatic void DecodeLD(
  output OpInfo opInfo,
  output BasicData imm,
  input BasicData inst,
  input RegAddr rdAddr,
  input Funct3 funct3
);
  begin
    imm = {{20{inst[31]}},inst[31:20]};

    //形としてはI
    opInfo.opType = TYPE_I;

    opInfo.aluCtrl.aluCode = ALU_ADD;
    opInfo.aluCtrl.aluOp1Type = OP_TYPE_REG;
    opInfo.aluCtrl.aluOp2Type = OP_TYPE_IMM;

    opInfo.brCtrl = BR_NONE;

    opInfo.isMulDiv = FALSE;
    opInfo.mulDivCode = MULDIV_MUL;


    opInfo.wEnable = rdAddr == 5'd0 ? FALSE : TRUE;
    opInfo.isForwardable = FALSE;
    opInfo.isBranch = FALSE;
    opInfo.isStore = FALSE;
    opInfo.isLoad = TRUE;
    opInfo.isBubble = FALSE;

    case (funct3)
      3'b000: begin
        opInfo.memAccessWidth = MEM_BYTE;
        opInfo.isLoadUnsigned = FALSE;
      end
      3'b001: begin
        opInfo.memAccessWidth = MEM_HALF;
        opInfo.isLoadUnsigned = FALSE;
      end
      3'b010: begin
        opInfo.memAccessWidth = MEM_WORD;
        opInfo.isLoadUnsigned = FALSE;
      end
      3'b100: begin
        opInfo.memAccessWidth = MEM_BYTE;
        opInfo.isLoadUnsigned = TRUE;
      end
      3'b101: begin
        opInfo.memAccessWidth = MEM_HALF;
        opInfo.isLoadUnsigned = TRUE;
      end
      default : begin
        opInfo.memAccessWidth = MEM_NONE;
        opInfo.isLoadUnsigned = FALSE;
      end
    endcase
  end
endfunction

endpackage
