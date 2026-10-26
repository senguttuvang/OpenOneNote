/* Ghidra pseudocode; inferred types and names; not Microsoft source. */
/* Default Ghidra analysis requested with 600-second per-file limit. Consult analysis log for completion; types remain inferred. */

undefined8 FUN_0009e850(undefined8 param_1)

{
  long *plVar1;
  long *local_30;
  long *local_28;
  
  thunk_FUN_0009e9a4(&local_28);
  FUN_0009e9e8(&local_30);
  FUN_0009e9f8(param_1,&local_28,&local_30);
  plVar1 = local_30;
  if (local_30 != (long *)0x0) {
    local_30 = (long *)0x0;
    (**(code **)(*plVar1 + 0x10))();
  }
  plVar1 = local_28;
  if (local_28 != (long *)0x0) {
    local_28 = (long *)0x0;
    (**(code **)(*plVar1 + 8))();
  }
  return param_1;
}


