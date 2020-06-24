import BasicTypes::*;

module IMem(
  input var logic clk,
  input var logic rst,
  input var logic stall,
  input var PC pc,
  input var PC irregPc,
  output var Instruction instruction
);
  Instruction iMem [0:32767];
  MemAddr addr;

  always_ff@(posedge clk) begin
    if (rst == RESET) begin
      instruction <= {(INST_WIDTH){1'b0}};
    end
    else if (!stall) begin
      instruction <= iMem[addr >> 2];
    end
  end

  always_comb begin
    addr = irregPc != {(ADDR_WIDTH){1'b0}} ? irregPc : pc;
  end

  //initial $readmemh("/home/koutarou/develop/kirameki/benchmarks/Coremark/prog.hex",iMem);
  initial $readmemh("/home/koutarou/develop/kirameki/benchmarks/Coremark_for_Synthesis/prog.hex",iMem);

endmodule
