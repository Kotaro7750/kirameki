`include "../SynthesisMacros.svh"
package PipelineTypes;

import BasicTypes::*;
import FetchUnitTypes::*;
import MemoryTypes::*;
import OpTypes::*;

typedef struct packed {
  PC pc;
  Instruction instruction;
  BranchPredict branchPredict;
} DecodeStagePipeReg ;

typedef struct packed {
  PC pc;
  RegAddr rdAddr;
  BasicData imm;
  OpInfo opInfo;
  BranchPredict branchPredict;
} ExecuteStagePipeReg ;

typedef struct packed {
  PC pc;
  MemCtrl memCtrl;
  RDCtrl rdCtrl;
`ifdef BRANCH_M
  logic isBranch;
  logic isBranchTaken;
  BranchPredict branchPredict;
  PC irregPc;
`endif
} MemoryAccessStagePipeReg ;

typedef struct packed {
  PC pc;
  MemCtrl memCtrl;
  RDCtrl rdCtrl;
} WriteBackStagePipeReg ;

endpackage
