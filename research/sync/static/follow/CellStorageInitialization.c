/* Ghidra pseudocode; inferred types and names; not Microsoft source. */
/* Default Ghidra analysis requested with 600-second per-file limit. Consult analysis log for completion; types remain inferred. */

void FUN_0023d464(long param_1,wchar_t *param_2,wchar_t *param_3,undefined8 *param_4)

{
  undefined8 uVar1;
  
  MsoCF::Strings::CopyWzToWz(param_2,(CWzInBuffer_T *)(param_1 + 0x20),(int *)0x0);
  if ((param_3 != (wchar_t *)0x0) && ((short)*param_3 != 0)) {
    param_2 = param_3;
  }
  MsoCF::Strings::CopyWzToWz(param_2,(CWzInBuffer_T *)(param_1 + 0x38),(int *)0x0);
  uVar1 = *param_4;
  *(undefined8 *)(param_1 + 0x58) = param_4[1];
  *(undefined8 *)(param_1 + 0x50) = uVar1;
  return;
}


