/* Ghidra pseudocode; inferred types and names; not Microsoft source. */
/* Default Ghidra analysis requested with 600-second per-file limit. Consult analysis log for completion; types remain inferred. */

void FUN_006b4e58(undefined8 *param_1,undefined8 param_2)

{
  undefined8 ****ppppuVar1;
  undefined8 ****ppppuVar2;
  byte bVar3;
  long *plVar4;
  ulong uVar5;
  long lVar6;
  char *pcVar7;
  undefined **ppuVar8;
  undefined8 *****pppppuVar9;
  undefined8 *****pppppuVar10;
  int iVar11;
  undefined1 auStack_4b8 [8];
  long *local_4b0;
  undefined1 auStack_4a0 [8];
  undefined8 local_498;
  char *pcStack_490;
  long *local_488;
  undefined8 *local_480;
  undefined1 *puStack_478;
  undefined2 local_470;
  undefined1 local_46e;
  undefined8 local_469;
  undefined1 uStack_461;
  undefined7 uStack_460;
  undefined1 uStack_459;
  undefined7 uStack_458;
  undefined1 uStack_451;
  undefined7 uStack_450;
  undefined1 local_449;
  undefined **local_448;
  char local_440 [8];
  undefined7 uStack_438;
  char cStack_431;
  undefined3 uStack_430;
  undefined1 local_42d;
  undefined1 local_3ff;
  undefined2 local_3fe;
  undefined **local_3f8;
  char local_3f0 [8];
  char acStack_3e8 [8];
  undefined2 local_3e0;
  undefined1 local_3af;
  undefined2 local_3ae;
  undefined1 auStack_3a8 [88];
  undefined **local_350;
  char local_348 [8];
  char acStack_340 [8];
  char local_338 [8];
  char acStack_330 [5];
  char acStack_32b [3];
  char acStack_328 [5];
  undefined1 local_323;
  long local_300;
  undefined2 local_2f8;
  undefined **local_2f0;
  char local_2e8 [8];
  char acStack_2e0 [6];
  char acStack_2da [2];
  char acStack_2d8 [6];
  undefined1 local_2d2;
  long local_2a0;
  undefined2 local_298;
  undefined **local_290;
  char local_288 [8];
  undefined2 local_280;
  undefined1 local_27e;
  byte local_247;
  undefined2 local_246;
  undefined **local_240;
  char local_238 [8];
  char acStack_230 [8];
  undefined2 local_228;
  undefined1 local_1f7;
  undefined2 local_1f6;
  undefined **local_1f0;
  char local_1e8 [8];
  undefined4 local_1e0;
  undefined1 local_1dc;
  int local_1a4;
  undefined2 local_1a0;
  undefined **local_198;
  undefined7 local_190;
  char cStack_189;
  undefined3 uStack_188;
  undefined1 local_185;
  undefined8 local_14f;
  undefined8 uStack_147;
  undefined2 local_13e;
  undefined **local_138;
  char *local_130;
  int local_128;
  undefined2 local_124;
  undefined8 *****local_120;
  undefined8 local_118;
  long local_110;
  void *local_b0;
  char local_99;
  char local_98;
  long local_70;
  
  local_70 = *(long *)PTR____stack_chk_guard_00c8a488;
  uVar5 = FUN_000cc04c();
  iVar11 = (int)param_2;
  if ((uVar5 & 1) == 0) {
    local_198 = (undefined **)0xbb95f6;
    local_124 = 4;
    local_110 = 0;
    local_120 = (undefined8 *****)0x0;
    local_118 = 0;
    local_130 = "UpdateNotificationType";
    local_138 = &PTR_DAT_00ced9d0;
    local_128 = iVar11;
    FUN_00032670(0x2020f4df,0x657,0xf,2,&local_198,&local_138,param_1);
    local_138 = &PTR_DAT_00c8b1a8;
    if (local_110 < 0) {
      operator_delete(local_120);
    }
  }
  else {
    FUN_003a34c0(&local_488,param_1);
    if (local_488 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
      FUN_009a4668();
    }
    (**(code **)(*local_488 + 0x30))(local_488,param_2);
    FUN_000b5a9c(&local_138,0x2020f4de,param_1);
    if (local_120 != (undefined8 *****)0x0) {
      pppppuVar9 = &local_120;
      pppppuVar10 = local_120;
      do {
        lVar6 = 8;
        if (iVar11 <= *(int *)(pppppuVar10 + 4)) {
          lVar6 = 0;
          pppppuVar9 = pppppuVar10;
        }
        pppppuVar10 = *(undefined8 ******)((long)pppppuVar10 + lVar6);
      } while (pppppuVar10 != (undefined8 *****)0x0);
      if (((undefined8 ******)pppppuVar9 != &local_120) && (*(int *)(pppppuVar9 + 4) <= iVar11)) {
        bVar3 = *(byte *)(pppppuVar9 + 5);
        if (iVar11 != 0x13) {
          ppppuVar1 = pppppuVar9[7];
          ppppuVar2 = pppppuVar9[8];
          local_498 = Office::FileIO::CSI::GetNamespace();
          pcStack_490 = "HostNotificationsSubscriptionEvent";
          FUN_00083a14(auStack_4a0,2,0x6e);
          uStack_147 = param_1[1];
          local_14f = *param_1;
          local_13e = 0x100;
          local_198 = &PTR_FUN_00c8f030;
          local_190 = s_CacheFileId_00b7e348._0_7_;
          _cStack_189 = CONCAT31(0x644965,s_CacheFileId_00b7e348[7]);
          local_185 = 0;
          local_1a0 = 4;
          local_1e0 = 0x6e6f6974;
          local_1f0 = &PTR_FUN_00c8f078;
          local_1e8[0] = s_Notification_00bb914f[0];
          local_1e8[1] = s_Notification_00bb914f[1];
          local_1e8[2] = s_Notification_00bb914f[2];
          local_1e8[3] = s_Notification_00bb914f[3];
          local_1e8[4] = s_Notification_00bb914f[4];
          local_1e8[5] = s_Notification_00bb914f[5];
          local_1e8[6] = s_Notification_00bb914f[6];
          local_1e8[7] = s_Notification_00bb914f[7];
          local_1dc = 0;
          local_240 = &PTR_FUN_00ca6e50;
          local_1f7 = 0xe;
          local_1f6 = 4;
          local_228 = 0x74;
          acStack_230[0] = s_SubscriptionEvent_00bb8de7[8];
          acStack_230[1] = s_SubscriptionEvent_00bb8de7[9];
          acStack_230[2] = s_SubscriptionEvent_00bb8de7[10];
          acStack_230[3] = s_SubscriptionEvent_00bb8de7[0xb];
          acStack_230[4] = s_SubscriptionEvent_00bb8de7[0xc];
          acStack_230[5] = s_SubscriptionEvent_00bb8de7[0xd];
          acStack_230[6] = s_SubscriptionEvent_00bb8de7[0xe];
          acStack_230[7] = s_SubscriptionEvent_00bb8de7[0xf];
          local_238[0] = s_SubscriptionEvent_00bb8de7[0];
          local_238[1] = s_SubscriptionEvent_00bb8de7[1];
          local_238[2] = s_SubscriptionEvent_00bb8de7[2];
          local_238[3] = s_SubscriptionEvent_00bb8de7[3];
          local_238[4] = s_SubscriptionEvent_00bb8de7[4];
          local_238[5] = s_SubscriptionEvent_00bb8de7[5];
          local_238[6] = s_SubscriptionEvent_00bb8de7[6];
          local_238[7] = s_SubscriptionEvent_00bb8de7[7];
          local_246 = 4;
          local_280 = 0x6465;
          local_290 = &PTR_FUN_00c8f3c8;
          local_288[0] = s_Subscribed_00bb962d[0];
          local_288[1] = s_Subscribed_00bb962d[1];
          local_288[2] = s_Subscribed_00bb962d[2];
          local_288[3] = s_Subscribed_00bb962d[3];
          local_288[4] = s_Subscribed_00bb962d[4];
          local_288[5] = s_Subscribed_00bb962d[5];
          local_288[6] = s_Subscribed_00bb962d[6];
          local_288[7] = s_Subscribed_00bb962d[7];
          local_27e = 0;
          local_247 = bVar3;
          local_1a4 = iVar11;
          lVar6 = std::chrono::system_clock::now();
          lVar6 = lVar6 - (long)ppppuVar1;
          local_2a0 = lVar6 / 1000000;
          if ((ulong)(lVar6 / 1000) < 1000 && 999 < lVar6) {
            local_2a0 = 1;
          }
          local_2f0 = &PTR_FUN_00c8f290;
          local_298 = 4;
          acStack_2e0[0] = s_SecondsSinceLastUpdate_00bb9173[8];
          acStack_2e0[1] = s_SecondsSinceLastUpdate_00bb9173[9];
          acStack_2e0[2] = s_SecondsSinceLastUpdate_00bb9173[10];
          acStack_2e0[3] = s_SecondsSinceLastUpdate_00bb9173[0xb];
          acStack_2e0[4] = s_SecondsSinceLastUpdate_00bb9173[0xc];
          acStack_2e0[5] = s_SecondsSinceLastUpdate_00bb9173[0xd];
          local_2e8[0] = s_SecondsSinceLastUpdate_00bb9173[0];
          local_2e8[1] = s_SecondsSinceLastUpdate_00bb9173[1];
          local_2e8[2] = s_SecondsSinceLastUpdate_00bb9173[2];
          local_2e8[3] = s_SecondsSinceLastUpdate_00bb9173[3];
          local_2e8[4] = s_SecondsSinceLastUpdate_00bb9173[4];
          local_2e8[5] = s_SecondsSinceLastUpdate_00bb9173[5];
          local_2e8[6] = s_SecondsSinceLastUpdate_00bb9173[6];
          local_2e8[7] = s_SecondsSinceLastUpdate_00bb9173[7];
          acStack_2da[0] = s_SecondsSinceLastUpdate_00bb9173[0xe];
          acStack_2da[1] = s_SecondsSinceLastUpdate_00bb9173[0xf];
          acStack_2d8[0] = s_SecondsSinceLastUpdate_00bb9173[0x10];
          acStack_2d8[1] = s_SecondsSinceLastUpdate_00bb9173[0x11];
          acStack_2d8[2] = s_SecondsSinceLastUpdate_00bb9173[0x12];
          acStack_2d8[3] = s_SecondsSinceLastUpdate_00bb9173[0x13];
          acStack_2d8[4] = s_SecondsSinceLastUpdate_00bb9173[0x14];
          acStack_2d8[5] = s_SecondsSinceLastUpdate_00bb9173[0x15];
          local_2d2 = 0;
          lVar6 = std::chrono::system_clock::now();
          acStack_340[0] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[8];
          acStack_340[1] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[9];
          acStack_340[2] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[10];
          acStack_340[3] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[0xb];
          acStack_340[4] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[0xc];
          acStack_340[5] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[0xd];
          acStack_340[6] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[0xe];
          acStack_340[7] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[0xf];
          local_348[0] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[0];
          local_348[1] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[1];
          local_348[2] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[2];
          local_348[3] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[3];
          local_348[4] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[4];
          local_348[5] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[5];
          local_348[6] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[6];
          local_348[7] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[7];
          lVar6 = lVar6 - (long)ppppuVar2;
          local_300 = lVar6 / 1000000;
          if ((ulong)(lVar6 / 1000) < 1000 && 999 < lVar6) {
            local_300 = 1;
          }
          local_350 = &PTR_FUN_00c8f290;
          local_2f8 = 4;
          acStack_330[0] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[0x18];
          acStack_330[1] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[0x19];
          acStack_330[2] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[0x1a];
          acStack_330[3] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[0x1b];
          acStack_330[4] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[0x1c];
          local_338[0] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[0x10];
          local_338[1] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[0x11];
          local_338[2] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[0x12];
          local_338[3] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[0x13];
          local_338[4] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[0x14];
          local_338[5] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[0x15];
          local_338[6] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[0x16];
          local_338[7] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[0x17];
          acStack_32b[0] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[0x1d];
          acStack_32b[1] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[0x1e];
          acStack_32b[2] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[0x1f];
          acStack_328[0] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[0x20];
          acStack_328[1] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[0x21];
          acStack_328[2] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[0x22];
          acStack_328[3] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[0x23];
          acStack_328[4] = s_SecondsSinceLastLastHeartbeatCyc_00bb9638[0x24];
          local_323 = 0;
          FUN_003986a0(auStack_4b8,param_1);
          FUN_003986f0(auStack_3a8,"Doc",auStack_4b8);
          pcVar7 = (char *)FUN_0019c620();
          if (*pcVar7 < '\0') {
            local_3af = Mso::AB::Optimized::FeatureGate::Evaluate();
          }
          else {
            local_3af = *pcVar7 != '\0';
          }
          local_3f8 = &PTR_FUN_00c8f3c8;
          local_3ae = 4;
          local_3e0 = 0x65;
          acStack_3e8[0] = s_EnableSignalRCore_00b98bf3[8];
          acStack_3e8[1] = s_EnableSignalRCore_00b98bf3[9];
          acStack_3e8[2] = s_EnableSignalRCore_00b98bf3[10];
          acStack_3e8[3] = s_EnableSignalRCore_00b98bf3[0xb];
          acStack_3e8[4] = s_EnableSignalRCore_00b98bf3[0xc];
          acStack_3e8[5] = s_EnableSignalRCore_00b98bf3[0xd];
          acStack_3e8[6] = s_EnableSignalRCore_00b98bf3[0xe];
          acStack_3e8[7] = s_EnableSignalRCore_00b98bf3[0xf];
          local_3f0[0] = s_EnableSignalRCore_00b98bf3[0];
          local_3f0[1] = s_EnableSignalRCore_00b98bf3[1];
          local_3f0[2] = s_EnableSignalRCore_00b98bf3[2];
          local_3f0[3] = s_EnableSignalRCore_00b98bf3[3];
          local_3f0[4] = s_EnableSignalRCore_00b98bf3[4];
          local_3f0[5] = s_EnableSignalRCore_00b98bf3[5];
          local_3f0[6] = s_EnableSignalRCore_00b98bf3[6];
          local_3f0[7] = s_EnableSignalRCore_00b98bf3[7];
          pcVar7 = (char *)FUN_0019c62c();
          if (*pcVar7 < '\0') {
            local_3ff = Mso::AB::Optimized::FeatureGate::Evaluate();
          }
          else {
            local_3ff = *pcVar7 != '\0';
          }
          local_448 = &PTR_FUN_00c8f3c8;
          local_3fe = 4;
          uStack_438 = s_DeprecateCppRestSdk_00b98c05._8_7_;
          _cStack_431 = CONCAT31(0x6b6453,s_DeprecateCppRestSdk_00b98c05[0xf]);
          local_440[0] = s_DeprecateCppRestSdk_00b98c05[0];
          local_440[1] = s_DeprecateCppRestSdk_00b98c05[1];
          local_440[2] = s_DeprecateCppRestSdk_00b98c05[2];
          local_440[3] = s_DeprecateCppRestSdk_00b98c05[3];
          local_440[4] = s_DeprecateCppRestSdk_00b98c05[4];
          local_440[5] = s_DeprecateCppRestSdk_00b98c05[5];
          local_440[6] = s_DeprecateCppRestSdk_00b98c05[6];
          local_440[7] = s_DeprecateCppRestSdk_00b98c05[7];
          local_42d = 0;
          local_480 = &local_498;
          puStack_478 = auStack_4a0;
          local_470 = 0;
          local_46e = 0;
          uStack_461 = 0;
          uStack_460 = 0;
          local_469 = 0;
          uStack_451 = 0;
          uStack_450 = 0;
          uStack_459 = 0;
          uStack_458 = 0;
          local_449 = 0;
          FUN_0039873c(&local_480,&local_198,&local_1f0,&local_240,&local_290,&local_2f0,&local_350,
                       auStack_3a8,&local_3f8,&local_448);
          plVar4 = (long *)CONCAT17(local_449,uStack_450);
          if (plVar4 != (long *)0x0) {
            LOAcquire();
            lVar6 = plVar4[1];
            plVar4[1] = lVar6 + -1;
            LORelease();
            if (lVar6 == 0) {
              (**(code **)(*plVar4 + 0x10))(plVar4);
              std::__shared_weak_count::__release_weak();
            }
          }
          plVar4 = (long *)CONCAT17(uStack_459,uStack_460);
          if (plVar4 != (long *)0x0) {
            LOAcquire();
            lVar6 = plVar4[1];
            plVar4[1] = lVar6 + -1;
            LORelease();
            if (lVar6 == 0) {
              (**(code **)(*plVar4 + 0x10))(plVar4);
              std::__shared_weak_count::__release_weak();
            }
          }
          plVar4 = local_4b0;
          if (local_4b0 != (long *)0x0) {
            local_4b0 = (long *)0x0;
            (**(code **)(*plVar4 + 0x10))();
          }
        }
        if ((bVar3 & 1) != 0) {
          FUN_00143c5c(0x1f714259,param_1,param_2,0xe);
          FUN_006b20b0(0x1f714258,param_1,param_2);
          ppuVar8 = (undefined **)Mso::Memory::AllocateEx(0x10,0);
          if (ppuVar8 == (undefined **)0x0) {
                    /* WARNING: Subroutine does not return */
            FUN_009a4758();
          }
          *(undefined4 *)(ppuVar8 + 1) = 1;
          *ppuVar8 = (undefined *)&PTR_FUN_00cedfb0;
          local_198 = ppuVar8;
          FUN_0014477c(0x1f39138f,param_1,param_2,&local_198);
          ppuVar8 = local_198;
          if (local_198 != (undefined **)0x0) {
            local_198 = (undefined **)0x0;
            (**(code **)(*ppuVar8 + 0x10))();
          }
        }
      }
    }
    if ((local_98 == '\x01') && (local_99 < '\0')) {
      operator_delete(local_b0);
    }
    FUN_0001be9c(&local_128,local_120);
    plVar4 = local_488;
    if (local_488 != (long *)0x0) {
      local_488 = (long *)0x0;
      (**(code **)(*plVar4 + 0x10))();
    }
  }
  if (*(long *)PTR____stack_chk_guard_00c8a488 != local_70) {
                    /* WARNING: Subroutine does not return */
    ___stack_chk_fail();
  }
  return;
}


