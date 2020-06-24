`timescale 1ns / 1ps

module CoreTB;
  logic sysclk;
  logic cpu_resetn;

  Core Core(sysclk,cpu_resetn);

  initial begin
    cpu_resetn <= 1;
    sysclk <= 0;
    #50;
    cpu_resetn <= 0;
    #20;
    cpu_resetn <= 1;

    #1000000000 $finish;
    
  end

  always #5 sysclk = ~sysclk;

endmodule
