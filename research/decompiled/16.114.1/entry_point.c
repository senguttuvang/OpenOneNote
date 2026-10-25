/* Ghidra pseudocode; inferred types and names; not Microsoft source. */
/* No whole-program analysis. Sample cannot establish complete behavior. */

void entry(undefined8 param_1,undefined8 param_2)

{
  func_0x00010005ad9c();
  func_0x00010005af28();
  _MBUTimerStart(PTR_PTR_10178e748,"","",0);
                    /* WARNING: Could not recover jumptable at 0x0001010dfebc. Too many branches */
                    /* WARNING: Treating indirect jump as call */
  (*(code *)PTR__NSApplicationMain_10157ade8)(param_1,param_2);
  return;
}


