import BasicTypes::*;
import MemoryTypes::*;

module MemoryCtrl(
  input var logic flush,
  input var logic isStore,
  input var MemAddr addr,
  input var MemAccessWidth memAccessWidth,
  input var BasicData wData,
  output var MemAddr line,
  output var [1:0]offset,
  output var BasicData shiftedWData,
  output var [3:0] wEnable,
  output var [7:0] uart,
  output var logic uartWe
);

  assign line = addr >> 2;
  assign offset = addr - ((addr >> 2)<<2);

  assign shiftedWData = shiftedWDataGen(isStore,memAccessWidth,shiftedWDataB,shiftedWDataH,shiftedWDataW,shiftedWDataNone);
  assign wEnable = wEnableGen(flush,isStore,memAccessWidth,offset);

  BasicData shiftedWDataB;
  BasicData shiftedWDataH;
  BasicData shiftedWDataW;
  BasicData shiftedWDataNone;

  assign shiftedWDataB = (wData & 8'hff) << (offset*8);
  assign shiftedWDataH = (wData & 16'hffff) << (offset*8);
  assign shiftedWDataW = wData;
  assign shiftedWDataNone = 32'd0;

  assign uart = shiftedWDataB & 8'hff;
  assign uartWe = ((addr == UART_ADDR) && (isStore == TRUE)) ? 1'b1 : 1'b0;

  function automatic [31:0] shiftedWDataGen;
    input bit isStore;
    input [1:0] memAccessWidth;
    input [31:0] shiftedWDataB;
    input [31:0] shiftedWDataH;
    input [31:0] shiftedWDataW;
    input [31:0] shiftedWDataNone;

    begin
      if(isStore) begin
        case (memAccessWidth)
          MEM_BYTE: begin
            shiftedWDataGen = shiftedWDataB;
          end
          MEM_HALF: begin
            shiftedWDataGen = shiftedWDataH;
          end
          MEM_WORD: begin
            shiftedWDataGen = shiftedWDataW;
          end
          default: begin
            shiftedWDataGen = shiftedWDataNone;
          end
        endcase
      end
      else begin
        shiftedWDataGen = shiftedWDataNone;
      end
    end
  endfunction

  
  function automatic [3:0] wEnableGen;
    input bit flush;
    input bit isStore;
    input [1:0] memAccessWidth;
    input [1:0] offset;
    begin
      if(isStore && !flush) begin
        case (memAccessWidth)
          MEM_BYTE: begin
            wEnableGen = 4'b0001 << offset;
          end
          MEM_HALF: begin
            wEnableGen = 4'b0011 << offset;
          end
          MEM_WORD: begin
            wEnableGen = 4'b1111;
          end
          default: begin
            wEnableGen = 4'b0000;
          end
        endcase
      end
      else begin
        wEnableGen = 4'b0000;
      end
    end
  endfunction
endmodule
