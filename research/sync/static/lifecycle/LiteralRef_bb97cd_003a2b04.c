/* Ghidra pseudocode; inferred types and names; not Microsoft source. */
/* Default Ghidra analysis requested with 600-second per-file limit. Consult analysis log for completion; types remain inferred. */

/* WARNING: Removing unreachable block (ram,0x003a32dc) */
/* WARNING: Removing unreachable block (ram,0x003a32f0) */

void FUN_003a2b04(uint *param_1,undefined8 param_2,undefined8 param_3,uint param_4,
                 undefined8 *param_5,undefined8 *param_6,uint param_7,undefined1 param_8,
                 ulong param_9)

{
  uint uVar1;
  uint uVar2;
  undefined8 *****pppppuVar3;
  uint uVar4;
  uint uVar5;
  undefined **ppuVar6;
  long *plVar7;
  undefined1 uVar8;
  undefined1 uVar9;
  undefined1 uVar10;
  undefined1 uVar11;
  ushort uVar12;
  uint uVar13;
  undefined8 uVar14;
  ulong uVar15;
  wchar16 *pwVar16;
  code *pcVar17;
  int iVar18;
  short sVar19;
  undefined8 uVar20;
  undefined **local_458;
  char *pcStack_450;
  uint *local_448;
  undefined2 local_440;
  undefined **local_438;
  char *pcStack_430;
  undefined8 local_428;
  undefined2 local_420;
  void *local_418;
  undefined8 local_410;
  long lStack_408;
  undefined **local_400;
  char *pcStack_3f8;
  undefined8 local_3f0;
  undefined2 local_3e8;
  void *local_3e0;
  undefined8 local_3d8;
  long lStack_3d0;
  undefined **local_3c8;
  char *pcStack_3c0;
  undefined8 local_3b8;
  undefined2 local_3b0;
  void *local_3a8;
  undefined8 local_3a0;
  long lStack_398;
  undefined **local_390;
  char *pcStack_388;
  undefined8 local_380;
  undefined2 local_378;
  void *local_370;
  undefined8 local_368;
  long lStack_360;
  undefined **local_358;
  char *pcStack_350;
  undefined8 local_348;
  undefined2 local_340;
  void *local_338;
  undefined8 local_330;
  long lStack_328;
  undefined **local_320;
  char *pcStack_318;
  uint local_310;
  undefined2 local_30c;
  void *local_308;
  undefined8 local_300;
  long lStack_2f8;
  undefined **local_2f0;
  char *local_2e8;
  undefined1 local_2e0;
  undefined2 local_2de;
  void *local_2d8;
  undefined8 local_2d0;
  long local_2c8;
  undefined **local_2c0;
  char *local_2b8;
  undefined1 local_2b0;
  undefined2 local_2ae;
  void *local_2a8;
  undefined8 local_2a0;
  long local_298;
  undefined **local_290;
  char *local_288;
  undefined1 local_280;
  undefined2 local_27e;
  void *local_278;
  undefined8 local_270;
  long local_268;
  void *local_260;
  undefined8 uStack_258;
  long local_250;
  undefined **local_248;
  char *local_240;
  void *local_238;
  undefined8 uStack_230;
  long local_228;
  undefined2 local_220;
  void *local_218;
  undefined8 local_210;
  long local_208;
  undefined8 *****local_200 [2];
  char local_1e9;
  void *local_1e8;
  undefined8 uStack_1e0;
  long local_1d8;
  undefined **local_1d0;
  char *local_1c8;
  void *local_1c0;
  undefined8 uStack_1b8;
  long local_1b0;
  undefined2 local_1a8;
  void *local_1a0;
  undefined8 local_198;
  long local_190;
  undefined8 *****local_188 [2];
  char local_171;
  void *local_170;
  undefined8 uStack_168;
  long local_160;
  undefined **local_158;
  char *local_150;
  void *local_148;
  undefined8 uStack_140;
  long local_138;
  undefined2 local_130;
  void *local_128;
  undefined8 local_120;
  long local_118;
  char *local_110;
  uint local_104;
  long *local_100;
  uint local_f4;
  undefined **local_f0;
  char *pcStack_e8;
  undefined8 local_e0;
  undefined8 uStack_d8;
  undefined2 local_d0;
  undefined8 local_c8;
  undefined8 local_c0;
  undefined8 uStack_b8;
  undefined **local_b0;
  char *pcStack_a8;
  undefined8 local_a0;
  undefined8 uStack_98;
  undefined2 local_90;
  undefined8 local_88;
  undefined8 local_80;
  undefined8 uStack_78;
  long local_70;
  
  local_70 = *(long *)PTR____stack_chk_guard_00c8a488;
  local_f4 = param_4;
  uVar14 = FUN_000b5934();
  FUN_003a34c0(&local_100,param_2);
  if (local_100 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
    FUN_009a4668();
  }
  (**(code **)(*local_100 + 0x28))(local_100,param_3,uVar14);
  if (DAT_00d9aae0 < '\0') {
    uVar13 = Mso::AB::Optimized::FeatureGate::Evaluate();
  }
  else {
    uVar13 = (uint)(DAT_00d9aae0 != '\0');
  }
  uVar5 = param_7 | uVar13;
  iVar18 = (int)param_3;
  if (iVar18 == 2) {
    uVar5 = 1;
  }
  local_104 = local_f4;
  uVar4 = param_7;
  if (iVar18 == 2) {
    uVar4 = 1;
  }
  if ((uVar4 == 1) && ((int)uVar14 != 0)) {
    uVar1 = 0x25;
    if (iVar18 != 2) {
      uVar1 = local_f4;
    }
    uVar2 = 0x24;
    if (iVar18 != 0x14) {
      uVar2 = uVar1;
    }
    uVar1 = 0x23;
    if (iVar18 != 4) {
      uVar1 = uVar2;
    }
    uVar2 = 0x21;
    if (iVar18 != 1) {
      uVar2 = uVar1;
    }
    local_f4 = FUN_006b58a8(0x1e29d194,param_2,local_f4,uVar2);
  }
  if (uVar5 == 0) {
    *(undefined8 *)((long)param_1 + 0x1e) = 0;
    param_1[2] = 0;
    param_1[3] = 0;
    param_1[0] = 0;
    param_1[1] = 0;
    param_1[6] = 0;
    param_1[7] = 0;
    param_1[4] = 0;
    param_1[5] = 0;
    param_1[10] = 0;
    param_1[0xb] = 0;
    param_1[0xc] = 0;
    param_1[0xd] = 0;
    param_1[0xe] = 4;
    *(undefined1 *)(param_1 + 0x1c) = 0;
    param_1[0x12] = 0;
    param_1[0x13] = 0;
    param_1[0x10] = 0;
    param_1[0x11] = 0;
    param_1[0x16] = 0;
    param_1[0x17] = 0;
    param_1[0x14] = 0;
    param_1[0x15] = 0;
    *(undefined8 *)((long)param_1 + 0x61) = 0;
    *(undefined8 *)((long)param_1 + 0x59) = 0;
    FUN_00001eb8(param_1 + 0x1e,"");
    FUN_00001eb8(param_1 + 0x24,"");
    FUN_00001eb8(param_1 + 0x2a,"");
    FUN_00001eb8(param_1 + 0x30,"");
    FUN_00001eb8(param_1 + 0x36,"");
    param_1[0x42] = 0;
    *(undefined2 *)(param_1 + 0x43) = 0;
    param_1[0x3c] = 0;
    param_1[0x3d] = 0;
    param_1[0x3e] = 0;
    param_1[0x3f] = 0;
    *(undefined8 *)((long)param_1 + 0xfe) = 0;
  }
  else {
    uVar8 = FUN_000b5934(param_2,1);
    uVar9 = FUN_000b5934(param_2,4);
    uVar10 = FUN_000b5934(param_2,0x14);
    uVar11 = FUN_000b5934(param_2,2);
    uVar12 = 0;
    if (iVar18 == 4) {
      sVar19 = 0;
      if ((local_f4 & 0xfffffffe) == 0xc) {
        uVar12 = FUN_003f0e8c(0x1e244495,param_2);
        sVar19 = 1;
      }
    }
    else {
      sVar19 = 0;
    }
    *param_1 = local_f4;
    *(char *)(param_1 + 1) = (char)uVar14;
    *(undefined1 *)((long)param_1 + 5) = param_8;
    uVar20 = *param_5;
    *(undefined8 *)((long)param_1 + 0xe) = param_5[1];
    *(undefined8 *)((long)param_1 + 6) = uVar20;
    uVar20 = *param_6;
    *(undefined8 *)((long)param_1 + 0x1e) = param_6[1];
    *(undefined8 *)((long)param_1 + 0x16) = uVar20;
    *(ulong *)(param_1 + 10) = param_9 / 10000;
    uVar15 = FUN_000e3584(0x1e35b34f,param_2);
    *(ulong *)(param_1 + 0xc) = uVar15 / 10000;
    param_1[0xe] = 4;
    *(undefined1 *)(param_1 + 0x1c) = 0;
    param_1[0x12] = 0;
    param_1[0x13] = 0;
    param_1[0x10] = 0;
    param_1[0x11] = 0;
    param_1[0x16] = 0;
    param_1[0x17] = 0;
    param_1[0x14] = 0;
    param_1[0x15] = 0;
    *(undefined8 *)((long)param_1 + 0x61) = 0;
    *(undefined8 *)((long)param_1 + 0x59) = 0;
    FUN_00001eb8(param_1 + 0x1e,"");
    FUN_00001eb8(param_1 + 0x24,"");
    FUN_00001eb8(param_1 + 0x2a,"");
    FUN_00001eb8(param_1 + 0x30,"");
    FUN_00001eb8(param_1 + 0x36,"");
    param_1[0x3c] = 0;
    param_1[0x3d] = 0;
    param_1[0x3e] = 0;
    param_1[0x3f] = 0;
    *(undefined1 *)(param_1 + 0x40) = uVar8;
    *(undefined1 *)((long)param_1 + 0x101) = uVar9;
    *(undefined1 *)((long)param_1 + 0x102) = uVar10;
    *(undefined1 *)((long)param_1 + 0x103) = uVar11;
    uVar8 = FUN_000b5884(param_2,1);
    *(undefined1 *)(param_1 + 0x41) = uVar8;
    uVar8 = FUN_003f0a04(param_2);
    *(undefined1 *)((long)param_1 + 0x105) = uVar8;
    param_1[0x42] = local_104;
    *(ushort *)(param_1 + 0x43) = uVar12 | sVar19 << 8;
    FUN_003a3c58(param_2,param_1);
    local_158 = (undefined **)Mso::Memory::AllocateEx(0x18,0);
    if (local_158 == (undefined **)0x0) {
                    /* WARNING: Subroutine does not return */
      FUN_009a4758();
    }
    *(undefined4 *)(local_158 + 1) = 1;
    *local_158 = (undefined *)&PTR_FUN_00cee270;
    local_158[2] = (undefined *)param_1;
    FUN_000b5eb0(0x1e31a04c,param_2,param_3,&local_158);
    ppuVar6 = local_158;
    if (local_158 != (undefined **)0x0) {
      local_158 = (undefined **)0x0;
      (**(code **)(*ppuVar6 + 0x10))();
    }
    local_110 = "HostNotifications::OnRequestCompletion";
    thunk_FUN_00059ce4(local_188,&local_f4);
    pppppuVar3 = local_188[0];
    if (-1 < local_171) {
      pppppuVar3 = local_188;
    }
    FUN_000019ec(&local_170,pppppuVar3);
    local_158 = &PTR_DAT_00c8e7d8;
    local_150 = "FileScenario";
    uStack_140 = uStack_168;
    local_148 = local_170;
    local_138 = local_160;
    uStack_168 = 0;
    local_170 = (void *)0x0;
    local_160 = 0;
    local_130 = 4;
    local_118 = 0;
    local_128 = (void *)0x0;
    local_120 = 0;
    thunk_FUN_00059ce4(local_200,&local_104);
    pppppuVar3 = local_200[0];
    if (-1 < local_1e9) {
      pppppuVar3 = local_200;
    }
    FUN_000019ec(&local_1e8,pppppuVar3);
    local_1d0 = &PTR_DAT_00c8e7d8;
    local_1c8 = "OriginalFileScenario";
    uStack_1b8 = uStack_1e0;
    local_1c0 = local_1e8;
    local_1b0 = local_1d8;
    uStack_1e0 = 0;
    local_1e8 = (void *)0x0;
    local_1d8 = 0;
    local_1a8 = 4;
    local_190 = 0;
    local_1a0 = (void *)0x0;
    local_198 = 0;
    if (iVar18 + 4U < 0x1c) {
      pwVar16 = (wchar16 *)(&PTR_u_UpdateNotificationType_Persiste_00cee4e0)[iVar18 + 4U];
    }
    else {
      pwVar16 = L"UnknownUpdateNotificationType";
    }
    FUN_000019ec(&local_260,pwVar16);
    local_248 = &PTR_DAT_00c8e7d8;
    local_240 = "Notification";
    local_448 = param_1 + 0x1a;
    uStack_230 = uStack_258;
    local_238 = local_260;
    local_228 = local_250;
    uStack_258 = 0;
    local_260 = (void *)0x0;
    local_250 = 0;
    local_220 = 4;
    local_208 = 0;
    local_218 = (void *)0x0;
    local_210 = 0;
    local_290 = &PTR_DAT_00c8b158;
    local_288 = "Subscribed";
    local_27e = 4;
    local_268 = 0;
    local_278 = (void *)0x0;
    local_270 = 0;
    local_2c0 = &PTR_DAT_00c8b158;
    local_2b8 = "IsRepeatable";
    local_2ae = 4;
    local_298 = 0;
    local_2a8 = (void *)0x0;
    local_2a0 = 0;
    local_2f0 = &PTR_DAT_00c8b158;
    local_2e8 = "DetectedUpdates";
    local_2e0 = (undefined1)param_7;
    local_2de = 0x100;
    local_2c8 = 0;
    local_2d8 = (void *)0x0;
    local_2d0 = 0;
    local_b0 = &PTR_DAT_0004ef90_4_00c8df00;
    pcStack_a8 = "SyncRequestId";
    uStack_98 = param_5[1];
    local_a0 = *param_5;
    local_90 = 0x100;
    local_80 = 0;
    uStack_78 = 0;
    local_88 = 0;
    local_f0 = &PTR_DAT_0004ef90_4_00c8df00;
    pcStack_e8 = "ServerCorrelationId";
    uStack_d8 = param_6[1];
    local_e0 = *param_6;
    local_d0 = 0x100;
    local_c0 = 0;
    uStack_b8 = 0;
    local_c8 = 0;
    local_310 = param_1[0xe];
    local_320 = &PTR_DAT_00c8b1a8;
    pcStack_318 = "RtcConnectionState";
    local_30c = 4;
    local_300 = 0;
    lStack_2f8 = 0;
    local_308 = (void *)0x0;
    local_358 = &PTR_DAT_00c8b108;
    pcStack_350 = "TimeSinceRtcReconnectingStart";
    local_348 = *(undefined8 *)(param_1 + 0x10);
    local_380 = *(undefined8 *)(param_1 + 0x12);
    local_340 = 4;
    local_330 = 0;
    lStack_328 = 0;
    local_338 = (void *)0x0;
    local_390 = &PTR_DAT_00c8b108;
    pcStack_388 = "TimeSinceRtcConnectingStart";
    local_378 = 4;
    local_368 = 0;
    lStack_360 = 0;
    local_370 = (void *)0x0;
    local_3c8 = &PTR_DAT_00c8b108;
    pcStack_3c0 = "TimeSinceRtcTokenRefreshStart";
    local_3b8 = *(undefined8 *)(param_1 + 0x14);
    local_3b0 = 4;
    local_3a0 = 0;
    lStack_398 = 0;
    local_3a8 = (void *)0x0;
    local_400 = &PTR_DAT_00c8b108;
    pcStack_3f8 = "TimeSincePowerRestore";
    local_3f0 = *(undefined8 *)(param_1 + 0x3c);
    local_428 = *(undefined8 *)(param_1 + 0x3e);
    local_3e8 = 4;
    local_3d8 = 0;
    lStack_3d0 = 0;
    local_3e0 = (void *)0x0;
    local_438 = &PTR_DAT_00c8b108;
    pcStack_430 = "TimeSinceSubscriptionStarted";
    local_420 = 4;
    local_410 = 0;
    lStack_408 = 0;
    local_418 = (void *)0x0;
    local_458 = &PTR_FUN_00c9d048;
    pcStack_450 = "EstimatedLastResumeTime";
    local_440 = 4;
    local_2b0 = param_8;
    local_280 = (char)uVar14;
    FUN_003a46cc(0x1e31d049,0x657,0x32,2,&local_110,&local_158,&local_1d0,&local_248,&local_290,
                 &local_2c0,&local_2f0,&local_b0,&local_f0,&local_320,&local_358,&local_390,
                 &local_3c8,&local_400,&local_438,&local_458,param_2);
    local_438 = &PTR_DAT_00c8b108;
    if (lStack_408 < 0) {
      operator_delete(local_418);
    }
    local_400 = &PTR_DAT_00c8b108;
    if (lStack_3d0 < 0) {
      operator_delete(local_3e0);
    }
    local_3c8 = &PTR_DAT_00c8b108;
    if (lStack_398 < 0) {
      operator_delete(local_3a8);
    }
    local_390 = &PTR_DAT_00c8b108;
    if (lStack_360 < 0) {
      operator_delete(local_370);
    }
    local_358 = &PTR_DAT_00c8b108;
    if (lStack_328 < 0) {
      operator_delete(local_338);
    }
    local_320 = &PTR_DAT_00c8b1a8;
    if (lStack_2f8 < 0) {
      operator_delete(local_308);
    }
    local_f0 = &PTR_DAT_0004ef90_4_00c8df00;
    local_b0 = &PTR_DAT_0004ef90_4_00c8df00;
    local_2f0 = &PTR_DAT_00c8b158;
    if (local_2c8 < 0) {
      operator_delete(local_2d8);
    }
    local_2c0 = &PTR_DAT_00c8b158;
    if (local_298 < 0) {
      operator_delete(local_2a8);
    }
    local_290 = &PTR_DAT_00c8b158;
    if (local_268 < 0) {
      operator_delete(local_278);
    }
    local_248 = &PTR_DAT_00c8e7d8;
    if (local_208 < 0) {
      operator_delete(local_218);
    }
    if (local_228 < 0) {
      operator_delete(local_238);
    }
    if (local_250 < 0) {
      operator_delete(local_260);
    }
    local_1d0 = &PTR_DAT_00c8e7d8;
    if (local_190 < 0) {
      operator_delete(local_1a0);
    }
    if (local_1b0 < 0) {
      operator_delete(local_1c0);
    }
    if (local_1d8 < 0) {
      operator_delete(local_1e8);
    }
    if (local_1e9 < '\0') {
      operator_delete(local_200[0]);
    }
    local_158 = &PTR_DAT_00c8e7d8;
    if (local_118 < 0) {
      operator_delete(local_128);
    }
    if (local_138 < 0) {
      operator_delete(local_148);
    }
    if (local_160 < 0) {
      operator_delete(local_170);
    }
    if (local_171 < '\0') {
      operator_delete(local_188[0]);
    }
    if (uVar4 == 0) {
      if (uVar13 == 0) goto LAB_003a3444;
      if (local_100 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
        FUN_009a4668();
      }
      pcVar17 = *(code **)(*local_100 + 0x20);
    }
    else {
      if (local_100 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
        FUN_009a4668();
      }
      pcVar17 = *(code **)(*local_100 + 0x18);
    }
    (*pcVar17)(local_100,param_3,param_1);
  }
LAB_003a3444:
  plVar7 = local_100;
  if (local_100 != (long *)0x0) {
    local_100 = (long *)0x0;
    (**(code **)(*plVar7 + 0x10))();
  }
  if (*(long *)PTR____stack_chk_guard_00c8a488 != local_70) {
                    /* WARNING: Subroutine does not return */
    ___stack_chk_fail();
  }
  return;
}


