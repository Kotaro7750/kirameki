import BasicTypes::*;
import PipelineTypes::*;

module BranchPredictor(
  BranchPredictorIF.BranchPredictor port,
  ExecuteStageIF.BranchPredictor execute
);

  logic [1:0] State;

  always_ff@(posedge port.clk) begin
    if (port.rst == RESET) begin
      State <= 2'b01;
    end
    else if (execute.isBranch == TRUE) begin
      case (State)
        2'b00: begin
          if (execute.isBranchTaken == TRUE) begin
            State <= 2'b01;
          end
          else begin
            State <= 2'b00;
          end
        end
        2'b01: begin
          if (execute.isBranchTaken == TRUE) begin
            State <= 2'b11;
          end
          else begin
            State <= 2'b00;
          end
          
        end
        2'b10: begin
          if (execute.isBranchTaken == TRUE) begin
            State <= 2'b11;
          end
          else begin
            State <= 2'b01;
          end
          
        end
        2'b11: begin
          if (execute.isBranchTaken == TRUE) begin
            State <= 2'b11;
          end
          else begin
            State <= 2'b10;
          end
        end
      endcase
    end
  end

  always_comb begin
  `ifdef BPRED_STATIC
    port.isBranchTakenPredicted = FALSE;
  `else
    case (State)
      2'b00: begin
        port.isBranchTakenPredicted = FALSE;
      end
      2'b01: begin
        port.isBranchTakenPredicted = FALSE;
      end
      2'b10: begin
        port.isBranchTakenPredicted = TRUE;
      end
      2'b11: begin
        port.isBranchTakenPredicted = TRUE;
      end
    endcase
  `endif
  end
endmodule
