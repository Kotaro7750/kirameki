package MemoryTypes;
  import BasicTypes::*;

  localparam UART_ADDR = 32'hf6fff070;
  localparam HARDWARE_COUNTER_ADDR = 32'hffffff00;

  typedef enum logic [1:0]{
    MEM_NONE,
    MEM_BYTE,
    MEM_HALF,
    MEM_WORD
  } MemAccessWidth;

  typedef struct packed {
    MemAddr addr;
    MemAccessWidth memAccessWidth;
    BasicData wData;
    logic isStore;
    logic isLoad;
    logic isLoadUnsigned;
  } MemCtrl ;
endpackage
