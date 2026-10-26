/* Ghidra pseudocode; inferred types and names; not Microsoft source. */
/* Default Ghidra analysis requested with 600-second per-file limit. Consult analysis log for completion; types remain inferred. */

void FUN_0009da6c(undefined8 *param_1)

{
  undefined8 *puVar1;
  
  puVar1 = (undefined8 *)Mso::Memory::AllocateEx(0x10,0);
  if (puVar1 == (undefined8 *)0x0) {
                    /* WARNING: Subroutine does not return */
    FUN_009a4680();
  }
  *(undefined4 *)(puVar1 + 1) = 1;
  *puVar1 = &PTR_FUN_00c91960;
  *param_1 = puVar1;
  return;
}


