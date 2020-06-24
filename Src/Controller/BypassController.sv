import BasicTypes::*;

module BypassController(
  input var RegAddr rs1Addr,
  input var RegAddr rs2Addr,
  input var ALUOpType aluOp1Type,
  input var ALUOpType aluOp2Type,
  input var logic isStore,
  input var BasicData rs1Data,
  input var BasicData rs2Data,
  input var RDCtrl ExRdCtrl,
  input var RDCtrl MemRdCtrl,
  output var logic isDataHazard,
  output var BasicData bypassedRs1,
  output var BasicData bypassedRs2
);

  logic isRs1DataHazard;
  logic isRs2DataHazard;
  assign isDataHazard = (isRs1DataHazard == TRUE || isRs2DataHazard == TRUE) ? TRUE : FALSE;

  always_comb begin
    //rs1
    if (aluOp1Type != OP_TYPE_REG) begin
      isRs1DataHazard = FALSE;
      bypassedRs1 = rs1Data;
    end

    else if (rs1Addr == ZERO_REG) begin
      isRs1DataHazard = FALSE;
      bypassedRs1 = rs1Data;
    end

    else if (rs1Addr == ExRdCtrl.rdAddr && ExRdCtrl.wEnable == TRUE) begin
      if (ExRdCtrl.isForwardable == TRUE) begin
        isRs1DataHazard = FALSE;
        bypassedRs1 = ExRdCtrl.wData;
      end
      else begin
        isRs1DataHazard = TRUE;
        bypassedRs1 = rs1Data;
      end
    end

    else if (rs1Addr == MemRdCtrl.rdAddr && MemRdCtrl.wEnable == TRUE) begin
      if (MemRdCtrl.isForwardable == TRUE) begin
        isRs1DataHazard = FALSE;
        bypassedRs1 = MemRdCtrl.wData;
      end
      else begin
        isRs1DataHazard = TRUE;
        bypassedRs1 = rs1Data;
      end
    end

    else begin
      isRs1DataHazard = FALSE;
      bypassedRs1 = rs1Data;
    end

    //rs2
    if (aluOp2Type != OP_TYPE_REG && isStore != TRUE) begin
      isRs2DataHazard = FALSE;
      bypassedRs2 = rs2Data;
    end

    else if (rs2Addr == ZERO_REG) begin
      isRs2DataHazard = FALSE;
      bypassedRs2 = rs2Data;
    end

    else if (rs2Addr == ExRdCtrl.rdAddr && ExRdCtrl.wEnable == TRUE) begin
      if (ExRdCtrl.isForwardable == TRUE) begin
        isRs2DataHazard = FALSE;
        bypassedRs2 = ExRdCtrl.wData;
      end
      else begin
        isRs2DataHazard = TRUE;
        bypassedRs2 = rs2Data;
      end
    end

    else if (rs2Addr == MemRdCtrl.rdAddr && MemRdCtrl.wEnable == TRUE) begin
      if (MemRdCtrl.isForwardable == TRUE) begin
        isRs2DataHazard = FALSE;
        bypassedRs2 = MemRdCtrl.wData;
      end
      else begin
        isRs2DataHazard = TRUE;
        bypassedRs2 = rs2Data;
      end
    end

    else begin
      isRs2DataHazard = FALSE;
      bypassedRs2 = rs2Data;
    end
  end
endmodule
