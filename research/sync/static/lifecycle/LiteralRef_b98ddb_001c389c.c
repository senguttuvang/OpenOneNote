/* Ghidra pseudocode; inferred types and names; not Microsoft source. */
/* Default Ghidra analysis requested with 600-second per-file limit. Consult analysis log for completion; types remain inferred. */

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

void FUN_001c389c(long param_1,ulong param_2,undefined8 param_3,long *param_4,undefined8 param_5,
                 undefined8 param_6,undefined8 *param_7,undefined8 param_8,long *param_9,
                 undefined8 param_10,undefined8 param_11)

{
  long *plVar1;
  int iVar2;
  uint uVar3;
  uint uVar4;
  uint uVar5;
  undefined8 uVar6;
  undefined8 uVar7;
  long lVar8;
  undefined **ppuVar9;
  long *plVar10;
  undefined2 *puVar11;
  ulong uVar12;
  ulong uVar13;
  undefined **local_220;
  undefined *puStack_218;
  undefined1 uStack_209;
  uint local_208;
  undefined1 local_201;
  long *local_200;
  Activity aAStack_1f8 [16];
  long *local_1e8;
  undefined1 auStack_1e0 [120];
  void *local_168;
  char local_151;
  void *local_150;
  char local_139;
  void *local_138;
  char local_121;
  void *local_120;
  char local_109;
  void *local_108;
  char local_f1;
  long *local_d0;
  char *pcStack_c8;
  undefined1 local_88;
  undefined8 local_78;
  undefined8 uStack_70;
  long local_68;
  
  local_68 = *(long *)PTR____stack_chk_guard_00c8a488;
  local_78 = param_5;
  uStack_70 = param_6;
  if (DAT_00d9b7b0 < '\0') {
    iVar2 = Mso::AB::Optimized::ChangeGate::Evaluate();
    if (iVar2 != 0) goto LAB_001c38f8;
LAB_001c3934:
    uVar13 = 0x300;
    uVar12 = 2;
  }
  else {
    if (DAT_00d9b7b0 == '\0') goto LAB_001c3934;
LAB_001c38f8:
    uVar12 = 0;
    if ((ulong)(param_7[0xc] - param_7[0xd]) < 1200000000) {
      uVar12 = 2;
    }
    uVar13 = 0x100;
    if ((ulong)(param_7[0xc] - param_7[0xd]) < 1200000000) {
      uVar13 = 0x300;
    }
  }
  local_d0 = (long *)Office::FileIO::CSI::GetNamespace();
  pcStack_c8 = "OnIsOnlyClientRequestComplete";
  FUN_00083a14(&local_220,2,0x6e);
  uVar6 = FUN_00061c00();
  Mso::Telemetry::Activity::Activity(aAStack_1f8,&local_d0,uVar6,uVar13 | uVar12,&local_220);
  uVar6 = Mso::Telemetry::Activity::DataFields();
  uVar7 = FUN_0003427c();
  FUN_0006a384(uVar6,"CanHostNotificationsFeatureRunForLicense",uVar7,4);
  uVar6 = Mso::Telemetry::Activity::DataFields();
  uVar7 = Storage::Configuration::GetBoolean(0xfcd);
  FUN_0006a384(uVar6,"ListenToHostNotifications",uVar7,4);
  uVar6 = Mso::Telemetry::Activity::DataFields();
  uVar7 = Storage::Configuration::GetUnsignedInteger32(0xfce);
  FUN_000833ec(uVar6,"HostNotificationsHeartbeatIntervalInSeconds",uVar7,4);
  uVar6 = Mso::Telemetry::Activity::DataFields();
  uVar7 = Storage::Configuration::GetUnsignedInteger32(0xfcf);
  FUN_000833ec(uVar6,"HostNotificationsVerifyPingIntervalPct",uVar7,4);
  uVar6 = Mso::Telemetry::Activity::DataFields();
  uVar7 = Storage::Configuration::GetBoolean(0xfd2);
  FUN_0006a384(uVar6,"SubscribeToEditorsTableNotification",uVar7,4);
  uVar6 = Mso::Telemetry::Activity::DataFields();
  uVar7 = Storage::Configuration::GetUnsignedInteger32(0xfd5);
  FUN_000833ec(uVar6,"PollingIntervalWhileSubscribedInSec",uVar7,4);
  local_200 = (long *)0x0;
  if (param_4 != (long *)0x0) {
    (**(code **)(*param_4 + 8))(param_4);
  }
  local_200 = param_4;
  FUN_001757c8(param_1 + 0xc,param_3,&local_200);
  uVar6 = Mso::Telemetry::Activity::DataFields();
  FUN_000686ac(uVar6,"CorrelationId",local_78,uStack_70,0x100);
  uVar6 = Mso::Telemetry::Activity::DataFields();
  FUN_000686ac(uVar6,"ServerCorrelationId",*param_7,param_7[1],0x100);
  uVar6 = Mso::Telemetry::Activity::DataFields();
  uVar7 = FUN_001c4414();
  FUN_000833ec(uVar6,"PingIntervalFastInSec",uVar7,4);
  uVar6 = Mso::Telemetry::Activity::DataFields();
  uVar7 = FUN_001c441c();
  FUN_000833ec(uVar6,"PingIntervalMediumInSec",uVar7,4);
  local_201 = 0;
  iVar2 = Storage::Configuration::GetBoolean(0x419);
  if (iVar2 == 0) {
    FUN_0029dc34(&local_220,1,0,0x204145e2);
    lVar8 = FUN_000c5f58();
    FUN_0029de84(&local_1e8,*(undefined8 *)(lVar8 + 0x10),param_1 + 0xc,0x204145e2);
    FUN_00733f98(&local_d0,local_1e8,0x205a2155,0);
    plVar1 = local_d0;
    local_201 = FUN_00431884(local_1e8);
    plVar10 = local_1e8;
    local_1e8 = (long *)0x0;
    if (plVar10 != (long *)0x0) {
      (**(code **)(*plVar10 + 0x10))();
    }
    FUN_0029e094(&local_220);
    uVar3 = (**(code **)(*plVar1 + 0x70))(plVar1);
    (**(code **)(*plVar1 + 8))(plVar1);
  }
  else {
    FUN_0029dc34(&local_d0,1,0,0x1e14c496);
    lVar8 = FUN_000c5f58();
    FUN_0029de84(&local_220,*(undefined8 *)(lVar8 + 0x10),param_1 + 0xc,0x1e14c496);
    local_201 = FUN_00431884(local_220);
    uVar3 = FUN_0039ec50(local_220);
    uVar4 = FUN_00433948(local_220);
    if (local_220 == (undefined **)0x0) {
                    /* WARNING: Subroutine does not return */
      FUN_009a49bc();
    }
    uVar5 = (**(code **)(*local_220 + 0x2e8))();
    ppuVar9 = local_220;
    local_220 = (undefined **)0x0;
    if (ppuVar9 != (undefined **)0x0) {
      (**(code **)(*ppuVar9 + 0x10))();
    }
    FUN_0029e094(&local_d0);
    uVar3 = (uint)((uVar5 & 0xff) != 0) & uVar5 >> 8 & (uVar3 ^ 1 | uVar4);
  }
  FUN_004319ec(0x205a2156,param_1 + 0xc,&local_208,0,local_201,0);
  if ((((local_208 == 1) && ((param_2 & 1) == 0)) && (local_200 == (long *)0x0)) &&
     (local_208 = 2, uVar3 == 0)) {
    local_208 = 3;
  }
  uVar6 = Mso::Telemetry::Activity::DataFields();
  FUN_000686ac(uVar6,"CacheFileId",*(undefined8 *)(param_1 + 0xc),*(undefined8 *)(param_1 + 0x14),
               0x100);
  pcStack_c8 = *(char **)(param_1 + 0x14);
  local_d0 = *(long **)(param_1 + 0xc);
  local_1e8 = (long *)((ulong)local_1e8 & 0xffffffffffff0000);
  ppuVar9 = (undefined **)Mso::Memory::AllocateEx(0x20,0);
  if (ppuVar9 == (undefined **)0x0) {
                    /* WARNING: Subroutine does not return */
    FUN_009a8568();
  }
  *(undefined4 *)(ppuVar9 + 1) = 1;
  *ppuVar9 = (undefined *)&PTR_FUN_00d06c98;
  ppuVar9[2] = (undefined *)&local_1e8;
  ppuVar9[3] = &uStack_209;
  local_220 = ppuVar9;
  FUN_0019db30(&local_d0,0x1e2888a2,&DAT_00aca200,0,&local_220);
  ppuVar9 = local_220;
  if (local_220 != (undefined **)0x0) {
    local_220 = (undefined **)0x0;
    (**(code **)(*ppuVar9 + 0x10))();
  }
  uVar12 = (ulong)local_1e8 & 0xff;
  uVar6 = Mso::Telemetry::Activity::DataFields();
  FUN_0006a384(uVar6,"Authenticated",uVar12,4);
  FUN_0016a6ec(aAStack_1f8,param_1 + 0xc,0xffffffffffffffff,0);
  FUN_001c4480(&local_78,aAStack_1f8);
  param_9 = (long *)*param_9;
  if (param_9 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
    FUN_009a4668();
  }
  (**(code **)(*param_9 + 0x18))(param_9,&local_200);
  if (local_200 == (long *)0x0) goto LAB_001c3ebc;
  local_d0 = (long *)0x0;
  FUN_003927ac(&local_d0);
  if (local_d0 == (long *)0x0) {
LAB_001c3e18:
    local_d0 = (long *)0x0;
    FUN_003927ac(&local_d0,local_200);
    if (local_d0 == (long *)0x0) goto LAB_001c3ebc;
    iVar2 = (**(code **)(*local_d0 + 0x48))();
    plVar10 = local_d0;
    local_d0 = (long *)0x0;
    if (plVar10 != (long *)0x0) {
      (**(code **)(*plVar10 + 0x10))();
    }
    if (iVar2 != 0x7e2) goto LAB_001c3ebc;
  }
  else {
    iVar2 = (**(code **)(*local_d0 + 0x48))();
    plVar10 = local_d0;
    local_d0 = (long *)0x0;
    if (plVar10 != (long *)0x0) {
      (**(code **)(*plVar10 + 0x10))();
    }
    if (iVar2 != 0x643) goto LAB_001c3e18;
  }
  pcStack_c8 = *(char **)(param_1 + 0x14);
  local_d0 = *(long **)(param_1 + 0xc);
  local_220 = &PTR_PTR_00d06ce0;
  FUN_006aa5cc(&local_d0,0x1e59d7d8,&local_220);
  ppuVar9 = local_220;
  if (local_220 != (undefined **)0x0) {
    local_220 = (undefined **)0x0;
    (**(code **)(*ppuVar9 + 0x10))();
  }
  uVar6 = Mso::Telemetry::Activity::DataFields();
  FUN_0006a384(uVar6,"AuthenticatedFlagSet",1,4);
LAB_001c3ebc:
  puStack_218 = PTR_s_SkipUnecessaryAmIAloneTransactio_00d06b70;
  local_220 = _DAT_00d06b68;
  iVar2 = Mso::AB::Optimized::ChangeGate::Evaluate();
  if (iVar2 == 0) {
    plVar10 = (long *)Mso::Memory::AllocateEx(0x28,0);
    if (plVar10 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
      FUN_009a738c();
    }
    *(undefined4 *)(plVar10 + 1) = 1;
    *plVar10 = (long)&PTR_FUN_00d06da0;
    plVar10[2] = (long)&local_208;
    plVar10[3] = (long)&local_200;
    plVar10[4] = (long)&local_201;
    local_d0 = (long *)((ulong)local_d0 & 0xffffffffffffff00);
    local_88 = 0;
    local_1e8 = plVar10;
    FUN_00059838(0x1f3d0605,param_1 + 0xc,&local_1e8,&local_d0,&DAT_00b7c5a8);
    FUN_0005c6fc(&local_d0);
    plVar10 = local_1e8;
    if (local_1e8 != (long *)0x0) {
      local_1e8 = (long *)0x0;
      (**(code **)(*plVar10 + 0x10))();
    }
  }
  else if ((local_208 & 0xfffffffe) == 2) {
    plVar10 = (long *)Mso::Memory::AllocateEx(0x28,0);
    if (plVar10 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
      FUN_009a738c();
    }
    *(undefined4 *)(plVar10 + 1) = 1;
    *plVar10 = (long)&PTR_FUN_00d06d48;
    plVar10[2] = (long)&local_208;
    plVar10[3] = (long)&local_200;
    plVar10[4] = (long)&local_201;
    local_d0 = (long *)((ulong)local_d0 & 0xffffffffffffff00);
    local_88 = 0;
    local_1e8 = plVar10;
    FUN_00059838(0x1e2420a0,param_1 + 0xc,&local_1e8,&local_d0,&DAT_00b7c5a8);
    FUN_0005c6fc(&local_d0);
    plVar10 = local_1e8;
    if (local_1e8 != (long *)0x0) {
      local_1e8 = (long *)0x0;
      (**(code **)(*plVar10 + 0x10))();
    }
  }
  uVar6 = Mso::Telemetry::Activity::DataFields();
  FUN_0028f2fc(uVar6,"CoauthStatus",local_208,4);
  uVar6 = Mso::Telemetry::Activity::DataFields();
  uVar7 = FUN_000b5934(param_1 + 0xc,1);
  FUN_0006a384(uVar6,"IsCurrentlySubscribedToETHostNotifications",uVar7,4);
  uVar6 = Mso::Telemetry::Activity::DataFields();
  uVar7 = FUN_000b5934(param_1 + 0xc,4);
  FUN_0006a384(uVar6,"IsCurrentlySubscribedToQCHostNotifications",uVar7,4);
  uVar6 = Mso::Telemetry::Activity::DataFields();
  uVar7 = FUN_001c477c(param_1 + 0xc,1);
  FUN_0006a384(uVar6,"IsCurrentlyInGracePeriod",uVar7,4);
  iVar2 = thunk_FUN_003e5868();
  if (iVar2 != 0) {
    plVar10 = (long *)FUN_00032f48();
    (**(code **)(*plVar10 + 0x40))();
    plVar10 = (long *)FUN_00032f48();
    iVar2 = (**(code **)(*plVar10 + 0x68))();
    if (iVar2 != 0) {
      local_d0 = (long *)0xbce129;
      FUN_000bfb18(0x205a2152,0x199,100,2,&local_d0);
      local_d0 = (long *)CONCAT44(local_d0._4_4_,0x205a2150);
      FUN_003e59e0(&local_d0,param_1 + 0xc,2,1);
    }
  }
  FUN_00176550(aAStack_1f8,param_1 + 0xc,param_3,8,1,&local_200,param_7,param_10,param_11);
  if (local_200 == (long *)0x0) {
    if ((param_2 & 1) == 0) {
      FUN_003a2b04(auStack_1e0,param_1 + 0xc,1,2,param_3,param_7,1,1,0);
      if (local_f1 < '\0') {
        operator_delete(local_108);
      }
      if (local_109 < '\0') {
        operator_delete(local_120);
      }
      if (local_121 < '\0') {
        operator_delete(local_138);
      }
      if (local_139 < '\0') {
        operator_delete(local_150);
      }
      if (local_151 < '\0') {
        operator_delete(local_168);
      }
    }
    puVar11 = (undefined2 *)Mso::Telemetry::Activity::Success();
    *puVar11 = 0x101;
  }
  else {
    FUN_001ce014(&local_200,param_8);
    FUN_000e01d8(aAStack_1f8,local_200,0);
    FUN_000e0e84(&local_d0,param_1 + 0xc,local_200);
    FUN_000e0e94();
  }
  local_d0 = (long *)0xbce17c;
  FUN_001c4d60(0x205a214d,0x199,0x32,2,&local_d0,param_1 + 0xc,&local_200,&local_208);
  plVar10 = local_200;
  local_200 = (long *)0x0;
  if (plVar10 != (long *)0x0) {
    (**(code **)(*plVar10 + 0x10))();
  }
  Mso::Telemetry::Activity::~Activity(aAStack_1f8);
  if (*(long *)PTR____stack_chk_guard_00c8a488 != local_68) {
                    /* WARNING: Subroutine does not return */
    ___stack_chk_fail();
  }
  return;
}


