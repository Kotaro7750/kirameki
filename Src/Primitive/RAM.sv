// 1 read/1 write block RAM
module BlockDualPortRAM #(
  parameter ENTRY_NUM = 1024,
  parameter ENTRY_BIT_SIZE = 32
)(
  input var logic clk,
  input var logic wEnable,
  input var [$clog2(ENTRY_NUM)-1:0] wAddr,
  input var [ENTRY_BIT_SIZE-1:0] wData,
  input var [$clog2(ENTRY_NUM)-1:0] rAddr,
  output var [ENTRY_BIT_SIZE-1:0] rData
);

  logic [ENTRY_BIT_SIZE-1:0] Array[ENTRY_NUM];

  always_ff@(posedge clk) begin
    if (wEnable) begin
      Array[wAddr] <= wData;
    end
    rData <= Array[rAddr];
  end

endmodule
