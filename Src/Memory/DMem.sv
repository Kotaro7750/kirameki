import BasicTypes::*;

module DMem(
  input var PC pc,
  input var logic clk,
  input var [3:0] wEnable, //TODO これどうにかしたい
  input var MemAddr rAddr,
  input var MemAddr wAddr,
  input var BasicData wData,
  input var MemAddr rowAddr, //TODO ラインとアドレスの区別もしたい
  output var BasicData rData
);
  //TODO もっと大きく
  BasicData mem [0:32767]; //定数化

  always_ff @(posedge clk) begin
      if (wEnable) $display("0x%4h: ", pc,"mem[0x%08h]",rowAddr," <- ","0x%h",wData); //TODO これどうにかしたい
      if(wEnable[0]) mem[wAddr][ 7: 0] <= wData[ 7: 0]; //TODO ここらへんの定数化
      if(wEnable[1]) mem[wAddr][15: 8] <= wData[15: 8];
      if(wEnable[2]) mem[wAddr][23:16] <= wData[23:16];
      if(wEnable[3]) mem[wAddr][31:24] <= wData[31:24];
      rData <= mem[rAddr];
  end

  //initial $readmemh("/home/koutarou/develop/kirameki/benchmarks/uart/data.hex",mem);
  initial $readmemh("/home/koutarou/develop/kirameki/benchmarks/Coremark_for_Synthesis/data.hex",mem);
endmodule
