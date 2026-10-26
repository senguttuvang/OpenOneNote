/* Ghidra pseudocode; inferred types and names; not Microsoft source. */
/* Default Ghidra analysis requested with 600-second per-file limit. Consult analysis log for completion; types remain inferred. */

void FUN_00108e14(long param_1,undefined8 param_2,long *param_3,undefined8 param_4,
                 undefined8 param_5)

{
  long *plVar1;
  undefined8 uVar2;
  undefined8 uVar3;
  undefined8 *puVar4;
  int local_98 [2];
  long local_90;
  long *local_88;
  long *local_80;
  long *local_78;
  undefined4 local_6c;
  long *local_68;
  long *local_60;
  long *local_58;
  
  local_58 = (long *)0xba22c2;
  FUN_000bfb18(0x1f646303,0x9d4,0x32,2,&local_58);
  FUN_00109120(&local_58,param_2);
  if (local_58 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
    FUN_009a4668();
  }
  puVar4 = (undefined8 *)(**(code **)(local_58[2] + 0x58))();
  if (local_58 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
    FUN_009a4668();
  }
  uVar2 = *puVar4;
  uVar3 = puVar4[1];
  local_6c = 0x1f851097;
  (**(code **)(local_58[2] + 0x20))(&local_68,local_58 + 2,&local_6c);
  FUN_00109ec8(&local_78,param_1,param_3,param_5);
  FUN_0010a074(&local_60,&local_68,param_1 + 0xb0,&local_78);
  plVar1 = local_60;
  if (local_60 != (long *)0x0) {
    local_60 = (long *)0x0;
    (**(code **)(*plVar1 + 0x10))();
  }
  plVar1 = local_78;
  if (local_78 != (long *)0x0) {
    local_78 = (long *)0x0;
    (**(code **)(*plVar1 + 0x10))();
  }
  plVar1 = local_68;
  if (local_68 != (long *)0x0) {
    local_68 = (long *)0x0;
    (**(code **)(*plVar1 + 0x10))();
  }
  (**(code **)(*param_3 + 0x40))(&local_68,param_3);
  FUN_0010a1d4(&local_78,param_1,uVar2,uVar3);
  FUN_0010a260(&local_80,&local_68,param_1 + 0xb0,&local_78);
  plVar1 = local_80;
  if (local_80 != (long *)0x0) {
    local_80 = (long *)0x0;
    (**(code **)(*plVar1 + 0x10))();
  }
  plVar1 = local_78;
  if (local_78 != (long *)0x0) {
    local_78 = (long *)0x0;
    (**(code **)(*plVar1 + 0x10))();
  }
  plVar1 = local_68;
  if (local_68 != (long *)0x0) {
    local_68 = (long *)0x0;
    (**(code **)(*plVar1 + 0x10))();
  }
  (**(code **)(*param_3 + 0x48))(&local_68,param_3);
  FUN_0010a394(&local_78,param_1,uVar2,uVar3);
  FUN_0010a420(&local_88,&local_68,param_1 + 0xb0,&local_78);
  plVar1 = local_88;
  if (local_88 != (long *)0x0) {
    local_88 = (long *)0x0;
    (**(code **)(*plVar1 + 0x10))();
  }
  plVar1 = local_78;
  if (local_78 != (long *)0x0) {
    local_78 = (long *)0x0;
    (**(code **)(*plVar1 + 0x10))();
  }
  plVar1 = local_68;
  if (local_68 != (long *)0x0) {
    local_68 = (long *)0x0;
    (**(code **)(*plVar1 + 0x10))();
  }
  FUN_0010a530(&local_68,&local_58,&DAT_00a7edf8);
  FUN_0010a7c8(param_1 + 0x120,local_58);
  if (*(long *)(param_1 + 0xa8) == 0) {
                    /* WARNING: Subroutine does not return */
    FUN_009a5668();
  }
  local_78 = (long *)CONCAT44(local_78._4_4_,0x1f851096);
  plVar1 = (long *)0x0;
  if (local_58 != (long *)0x0) {
    plVar1 = local_58 + 2;
  }
  FUN_0010a908(local_98,*(long *)(param_1 + 0xa8),&local_78,plVar1,param_4);
  if ((local_98[0] == 1) && (local_90 != 0)) {
    local_90 = 0;
    Mso::ErrorCodeState::Release();
  }
  plVar1 = local_68;
  if (local_68 != (long *)0x0) {
    local_68 = (long *)0x0;
    (**(code **)(*plVar1 + 0x10))();
  }
  plVar1 = local_58;
  if (local_58 != (long *)0x0) {
    local_58 = (long *)0x0;
    (**(code **)(*plVar1 + 0x10))();
  }
  return;
}


