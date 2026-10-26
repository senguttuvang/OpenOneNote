/* Ghidra pseudocode; inferred types and names; not Microsoft source. */
/* Default Ghidra analysis requested with 600-second per-file limit. Consult analysis log for completion; types remain inferred. */

void FUN_0079dc78(undefined8 param_1,undefined8 param_2,undefined8 param_3,undefined8 param_4,
                 undefined8 param_5,undefined8 param_6,undefined8 param_7,undefined8 param_8,
                 undefined8 param_9,undefined8 param_10,undefined4 param_11,undefined8 param_12,
                 undefined8 param_13)

{
  undefined8 local_88;
  undefined8 local_80;
  undefined8 uStack_78;
  undefined8 local_70;
  undefined8 uStack_68;
  undefined8 local_60;
  undefined8 uStack_58;
  undefined8 *local_50;
  undefined8 *puStack_48;
  undefined8 *local_40;
  undefined8 *puStack_38;
  undefined8 *local_30;
  undefined8 *puStack_28;
  undefined8 *local_20;
  long local_18;
  
  local_18 = *(long *)PTR____stack_chk_guard_00c8a488;
  local_50 = &uStack_58;
  puStack_48 = &local_60;
  local_40 = &uStack_68;
  puStack_38 = &local_70;
  local_30 = &uStack_78;
  puStack_28 = &local_80;
  local_20 = &local_88;
  local_88 = param_8;
  local_80 = param_7;
  uStack_78 = param_6;
  local_70 = param_5;
  uStack_68 = param_4;
  local_60 = param_3;
  uStack_58 = param_2;
  _WsCall(param_1,&DAT_00d4c358,&local_50,param_9,param_10,param_11,param_12,param_13);
  if (*(long *)PTR____stack_chk_guard_00c8a488 != local_18) {
                    /* WARNING: Subroutine does not return */
    ___stack_chk_fail();
  }
  return;
}


