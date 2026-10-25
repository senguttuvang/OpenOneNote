/* Ghidra pseudocode; inferred types and names; not Microsoft source. */
/* No whole-program analysis. Sample cannot establish complete behavior. */

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

void ONPageView_method_10027424c(undefined8 param_1,undefined8 param_2,long param_3)

{
  undefined8 *puVar1;
  ulong uVar2;
  
  puVar1 = (undefined8 *)(param_3 + _DAT_101781900);
  uVar2 = _NSEqualPoints(param_1,param_2,*puVar1,puVar1[1]);
  if ((uVar2 & 1) == 0) {
    *puVar1 = param_1;
    puVar1[1] = param_2;
                    /* WARNING: Could not recover jumptable at 0x00010110aed0. Too many branches */
                    /* WARNING: Treating indirect jump as call */
    (*(code *)PTR__objc_msgSend_10157bb70)(param_3,PTR_s_updateAffineTransform_10177c330);
    return;
  }
  return;
}


