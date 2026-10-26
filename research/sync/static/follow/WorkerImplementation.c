/* Ghidra pseudocode; inferred types and names; not Microsoft source. */
/* Default Ghidra analysis requested with 600-second per-file limit. Consult analysis log for completion; types remain inferred. */

void FUN_0009dae8(undefined8 *param_1)

{
  long lVar1;
  undefined8 uVar2;
  
  lVar1 = Mso::Memory::AllocateEx(0x128,0);
  if (lVar1 == 0) {
                    /* WARNING: Subroutine does not return */
    FUN_009a4680();
  }
  uVar2 = FUN_0009e850();
  *param_1 = uVar2;
  return;
}


