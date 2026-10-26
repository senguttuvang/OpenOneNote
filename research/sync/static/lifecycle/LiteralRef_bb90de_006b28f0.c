/* Ghidra pseudocode; inferred types and names; not Microsoft source. */
/* Default Ghidra analysis requested with 600-second per-file limit. Consult analysis log for completion; types remain inferred. */

void FUN_006b28f0(long param_1,undefined8 param_2)

{
  undefined **ppuVar1;
  int iVar2;
  ulong uVar3;
  ulong uVar4;
  undefined8 uVar5;
  undefined8 uVar6;
  undefined **local_68;
  char *pcStack_60;
  undefined4 local_58;
  undefined2 local_54;
  void *local_50;
  undefined8 local_48;
  long lStack_40;
  char *local_38;
  
  uVar3 = FUN_006b2010(0x1f714281,param_1 + 0xc,param_2);
  uVar4 = FUN_003f61ac();
  if ((uVar3 & 0xffffffff) < uVar4) {
    uVar4 = FUN_003f617c();
    if (uVar4 == (uVar3 & 0xffffffff)) {
      local_38 = "HostNotifications: Entering grace period";
      local_58 = (undefined4)param_2;
      local_54 = 4;
      local_48 = 0;
      lStack_40 = 0;
      local_50 = (void *)0x0;
      local_68 = &PTR_DAT_00ced9d0;
      pcStack_60 = "UpdateNotificationType";
      FUN_00032670(0x1e8a3692,0x657,0x32,2,&local_38,&local_68,param_1 + 0xc);
      local_68 = &PTR_DAT_00c8b1a8;
      if (lStack_40 < 0) {
        operator_delete(local_50);
      }
      local_68 = (undefined **)CONCAT44(local_68._4_4_,0x1f714263);
      FUN_003f0284(&local_68,param_1 + 0xc);
    }
  }
  else {
    FUN_00029adc(&local_68,param_1 + 0xc);
    if (local_68 == (undefined **)0x0) {
      uVar6 = 0x1f01708e;
      uVar5 = 4;
    }
    else {
      iVar2 = (**(code **)(*local_68 + 0x10))();
      if (iVar2 == 1) {
        uVar5 = 3;
        uVar6 = 0x1f01708c;
      }
      else {
        uVar6 = 0x1f01708d;
        uVar5 = 5;
      }
    }
    FUN_00142e50(param_1 + 0xc,param_2,uVar5,uVar6);
    ppuVar1 = local_68;
    if (local_68 != (undefined **)0x0) {
      local_68 = (undefined **)0x0;
      (**(code **)(*ppuVar1 + 8))();
    }
  }
  return;
}


