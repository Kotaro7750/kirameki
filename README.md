# 煌 RISC-V32IM準拠パイプラインプロセッサ

## 特徴
* RISC-V32IM(システム命令を除く)準拠
* systemverilogの機能を用いた保守性の高いコード
* FPGA上での実行を念頭に置いた設計

## ベンチマーク
FPGAボード DIGILENT社製NEXYS VIDEOでの100MHz動作時

Coremark
```
2K performance run parameters for coremark.
CoreMark Size    : 666
Total ticks      : 1310801051
Total time (secs): 13
Iterations/Sec   : 230
Iterations       : 3000
Compiler version : GCC9.2.0
Compiler flags   : 
Memory location  : STACK
seedcrc          : 0xe9f5
[0]crclist       : 0xe714
[0]crcmatrix     : 0x1fd7
[0]crcstate      : 0x8e3a
[0]crcfinal      : 0xcc42
Correct operation validated. See readme.txt for run and reporting rules.
```
