package FetchUnitTypes;

import BasicTypes::*;
  //Branch Prediction
  typedef struct packed {
    logic isBranchTakenPredicted;
    logic isNextPcPredicted;
    PC predictedNextPC;
  } BranchPredict;

  //BTB
  localparam INST_BYTE_WIDTH = INST_WIDTH / 8;
  localparam INST_ALLIGN = $clog2(INST_BYTE_WIDTH);
  
  localparam BTB_ENTRY_NUM = 1024;
  localparam BTB_ENTRY_NUM_BIT_WIDTH = $clog2(BTB_ENTRY_NUM);
  typedef logic [BTB_ENTRY_NUM_BIT_WIDTH - 1:0] BTBIndex;
  
  localparam BTB_TAG_WIDTH = 4;
  typedef logic [BTB_TAG_WIDTH - 1:0] BTBTag;
  
  localparam BTB_CONTENTS_WIDTH = 13;
  typedef logic [BTB_CONTENTS_WIDTH - 1:0] BTBContent;
  
  typedef struct packed {
    BTBTag tag;
    BTBContent content;
  } BTBEntry ;
  
  function automatic BTBIndex ToBTB_Index(PC pc);
      return pc[
          BTB_ENTRY_NUM_BIT_WIDTH + INST_ALLIGN - 1: 
          INST_ALLIGN
      ];
  endfunction
  
  function automatic BTBTag ToBTB_Tag(PC pc);
      return pc[
          BTB_ENTRY_NUM_BIT_WIDTH + INST_ALLIGN + BTB_TAG_WIDTH - 1:
          BTB_ENTRY_NUM_BIT_WIDTH + INST_ALLIGN
      ];
  endfunction
  
  function automatic BTBContent ToBTB_Content(PC pc);
      return pc[
          INST_ALLIGN + BTB_CONTENTS_WIDTH - 1:
          INST_ALLIGN
      ];
  endfunction
  
  function automatic PC ToRawAddrFromBTB_PC(BTBContent btbContent, PC pc);
      return 
      {
          pc[31 : BTB_CONTENTS_WIDTH + 2],
          btbContent[BTB_CONTENTS_WIDTH - 1 : 0],
          2'b0
      };
  endfunction
endpackage
