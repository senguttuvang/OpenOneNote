/* Ghidra pseudocode; inferred types and names; not Microsoft source. */
/* Default Ghidra analysis requested with 600-second per-file limit. Consult analysis log for completion; types remain inferred. */

undefined8 *
FUN_000a713c(undefined8 *param_1,undefined8 param_2,undefined8 param_3,undefined8 param_4,
            undefined8 param_5,undefined8 param_6,undefined8 param_7,undefined8 param_8,
            undefined8 param_9,undefined8 param_10,undefined1 param_11,undefined1 param_12)

{
  long *plVar1;
  long *plVar2;
  long *local_30;
  undefined1 local_21;
  
  local_21 = param_11;
  *(undefined4 *)(param_1 + 1) = 1;
  *param_1 = &PTR_thunk_FUN_000a9434_00c91760;
  param_1[3] = 0;
  param_1[2] = 0;
  param_1[5] = 0;
  param_1[4] = 0;
  param_1[6] = 0;
  FUN_000a7204(&local_30,param_2,param_3,param_4,param_5,param_6,param_7,param_8,param_9,param_10,
               &local_21,&param_12);
  plVar1 = local_30;
  local_30 = (long *)0x0;
  plVar2 = (long *)param_1[6];
  param_1[6] = plVar1;
  if (plVar2 != (long *)0x0) {
    (**(code **)(*plVar2 + 8))();
    plVar1 = local_30;
    if (local_30 != (long *)0x0) {
      local_30 = (long *)0x0;
      (**(code **)(*plVar1 + 8))();
    }
  }
  return param_1;
}


