/* Ghidra pseudocode; inferred types and names; not Microsoft source. */
/* Default Ghidra analysis requested with 600-second per-file limit. Consult analysis log for completion; types remain inferred. */

void FUN_000a708c(undefined8 *param_1,undefined8 param_2,undefined8 param_3,undefined8 param_4,
                 undefined8 param_5,undefined8 param_6,undefined8 param_7,undefined8 param_8,
                 undefined8 param_9,undefined8 param_10,undefined1 *param_11)

{
  long lVar1;
  undefined8 uVar2;
  
  lVar1 = Mso::Memory::AllocateEx(0x38,0);
  if (lVar1 == 0) {
                    /* WARNING: Subroutine does not return */
    FUN_009a4680();
  }
  uVar2 = FUN_000a713c(lVar1,param_2,param_3,param_4,param_5,param_6,param_7,param_8,param_9,
                       param_10,*param_11,0);
  *param_1 = uVar2;
  return;
}


