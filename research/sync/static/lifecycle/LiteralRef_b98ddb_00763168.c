/* Ghidra pseudocode; inferred types and names; not Microsoft source. */
/* Default Ghidra analysis requested with 600-second per-file limit. Consult analysis log for completion; types remain inferred. */

void FUN_00763168(long param_1,long *param_2)

{
  undefined1 auVar1 [16];
  undefined1 auVar2 [16];
  bool bVar3;
  bool bVar4;
  byte bVar5;
  undefined2 uVar6;
  int iVar7;
  int iVar8;
  uint uVar9;
  uint uVar10;
  uint uVar11;
  undefined8 uVar12;
  undefined8 uVar13;
  ulong uVar14;
  undefined8 uVar15;
  undefined8 uVar16;
  undefined8 uVar17;
  long *plVar18;
  undefined8 *puVar19;
  long lVar20;
  undefined2 *puVar21;
  undefined4 uVar22;
  int iVar23;
  char *pcVar24;
  undefined8 *puVar25;
  long *plVar26;
  long *local_528;
  void *local_520;
  undefined8 uStack_518;
  undefined8 local_510;
  char cStack_509;
  void *local_500;
  undefined8 uStack_4f8;
  undefined8 local_4f0;
  char cStack_4e9;
  void *local_4e0;
  undefined8 uStack_4d8;
  undefined8 local_4d0;
  char cStack_4c9;
  void *local_4c0;
  undefined8 uStack_4b8;
  undefined8 local_4b0;
  char cStack_4a9;
  void *local_4a0;
  undefined8 uStack_498;
  undefined8 local_490;
  char cStack_489;
  void *local_488;
  undefined8 uStack_480;
  char cStack_471;
  void *local_470;
  undefined8 uStack_468;
  char cStack_459;
  void *local_458;
  undefined8 uStack_450;
  char cStack_441;
  long *local_440;
  void *pvStack_438;
  undefined8 local_430;
  char cStack_429;
  void *local_420;
  undefined8 uStack_418;
  undefined8 local_410;
  char cStack_409;
  uint local_400 [2];
  undefined8 local_3f8;
  undefined4 local_3f0;
  byte local_3e8;
  undefined1 local_3e0;
  undefined7 uStack_3df;
  byte local_3d8;
  void *local_3d0;
  undefined8 uStack_3c8;
  long local_3c0;
  Activity aAStack_3b8 [16];
  undefined1 auStack_3a8 [8];
  undefined8 *local_3a0;
  long *local_398;
  long *local_390;
  uchar *local_388;
  uchar *local_380;
  long *local_370;
  int local_364;
  long *local_360;
  long *local_358;
  undefined1 auStack_350 [8];
  long *local_348;
  void *pvStack_340;
  char cStack_331;
  byte local_330;
  char local_329;
  char local_27f;
  undefined1 local_1e8 [16];
  undefined1 local_1d8 [16];
  undefined8 uStack_1c8;
  char *local_1c0;
  long *local_130;
  void *local_128;
  undefined8 uStack_120;
  char cStack_111;
  byte local_110;
  byte local_10f;
  undefined1 auStack_e0 [40];
  void *local_b8;
  undefined8 uStack_b0;
  char cStack_a1;
  char local_a0;
  void *local_98;
  undefined8 uStack_90;
  char cStack_81;
  byte local_80;
  long local_78;
  
  local_78 = *(long *)PTR____stack_chk_guard_00c8a488;
  param_2 = (long *)*param_2;
  if (param_2 == (long *)0x0) {
    local_348 = (long *)0xbd13df;
    local_1d8._0_8_ = &PTR_FUN_00c936b0;
    uStack_1c8 = *(undefined8 *)(**(long **)(param_1 + 0x18) + 0x18);
    local_1d8._8_8_ = *(undefined8 *)(**(long **)(param_1 + 0x18) + 0x10);
    local_1c0 = "SyncRequestID";
    FUN_0003df1c(0x1d7ce210,0x199,0xf,2,&local_348,local_1d8);
    goto LAB_007643f8;
  }
  (**(code **)(*param_2 + 0x60))(&local_528,param_2,*(undefined8 *)(param_1 + 0x10));
  plVar26 = *(long **)(param_1 + 0x18);
  local_360 = local_528;
  if (local_528 == (long *)0x0) {
    local_348 = (long *)0xbd13df;
    local_1d8._0_8_ = &PTR_FUN_00c936b0;
    uStack_1c8 = *(undefined8 *)(*plVar26 + 0x18);
    local_1d8._8_8_ = *(undefined8 *)(*plVar26 + 0x10);
    local_1c0 = "SyncRequestID";
    FUN_0003df1c(0x1d7ce210,0x199,0xf,2,&local_348,local_1d8);
  }
  else {
    puVar25 = (undefined8 *)plVar26[1];
    local_370 = (long *)0x0;
    (**(code **)(*local_528 + 0x78))(local_528,&local_364,&local_370);
    uVar12 = (**(code **)(*local_360 + 0x28))();
    uVar13 = (**(code **)(*local_360 + 0x48))();
    iVar8 = local_364;
    bVar4 = (int)uVar12 == 1;
    iVar7 = (int)uVar13;
    bVar3 = bVar4 && iVar7 == 2;
    uVar14 = FUN_0017688c(uVar12,uVar13);
    if (((uVar14 & 1) != 0) || (bVar3)) {
      (**(code **)(*local_360 + 0x90))(&local_388);
      if (local_388 == local_380) {
        Mso::Telemetry::Activity::ThreadCurrent();
        FUN_004262f4(&local_390);
      }
      else {
        Mso::Telemetry::IActivityParenter::Deserialize(local_388,(long)local_380 - (long)local_388);
      }
      uVar15 = (**(code **)(*local_360 + 0x30))();
      uVar16 = (**(code **)(*local_360 + 0x40))();
      (**(code **)(*local_360 + 0x18))(&local_3a0);
      if (local_3a0 == (undefined8 *)0x0) {
        uVar17 = 0;
      }
      else {
        uVar17 = (**(code **)*local_3a0)();
      }
      iVar23 = (int)uVar17;
      if (bVar4 && iVar7 == 2) {
        FUN_003d905c(auStack_3a8,2,2);
        pcVar24 = "FileRequestFinishedEditorsTablePartition";
      }
      else {
        FUN_00061b8c(auStack_3a8,0xbf,2,0x6e);
        pcVar24 = "FileRequestFinished";
      }
      local_1d8._0_8_ = Office::FileIO::CSI::GetNamespace();
      plVar18 = local_390;
      local_1d8._8_8_ = pcVar24;
      uVar6 = FUN_000eb83c(0,*puVar25,(iVar23 == 1 || iVar23 == 0xe) || bVar3);
      Mso::Telemetry::Activity::Activity(aAStack_3b8,local_1d8,plVar18,uVar6,auStack_3a8);
      FUN_001765e0(aAStack_3b8,*puVar25,1);
      local_1d8 = (**(code **)(*local_360 + 0x20))();
      FUN_002116b4(aAStack_3b8,local_1d8,uVar12,uVar15,uVar16,uVar17,uVar13,
                   *(undefined1 *)(*plVar26 + 0x78));
      uVar12 = Mso::Telemetry::Activity::DataFields();
      uVar13 = Storage::Configuration::GetBoolean(0xfee);
      FUN_0006a384(uVar12,"RunLabelRequestOnContentEndpoint",uVar13,4);
      uVar12 = Mso::Telemetry::Activity::DataFields();
      uVar13 = FUN_0003427c();
      FUN_0006a384(uVar12,"CanHostNotificationsFeatureRunForLicense",uVar13,4);
      uVar12 = Mso::Telemetry::Activity::DataFields();
      uVar13 = Storage::Configuration::GetBoolean(0xfcd);
      FUN_0006a384(uVar12,"ListenToHostNotifications",uVar13,4);
      uVar12 = Mso::Telemetry::Activity::DataFields();
      uVar13 = Storage::Configuration::GetBoolean(0xfe6);
      FUN_0006a384(uVar12,"ListenToHostNotificationsForODConsumer",uVar13,4);
      uVar12 = Mso::Telemetry::Activity::DataFields();
      uVar13 = Storage::Configuration::GetBoolean(0xfea);
      FUN_0006a384(uVar12,"StopSecondaryMetadataRequestsForApp",uVar13,4);
      uVar12 = Mso::Telemetry::Activity::DataFields();
      uVar13 = Storage::Configuration::GetUnsignedInteger32(0xfce);
      FUN_000833ec(uVar12,"HostNotificationsHeartbeatIntervalInSeconds",uVar13,4);
      uVar12 = Mso::Telemetry::Activity::DataFields();
      uVar13 = Storage::Configuration::GetUnsignedInteger32(0xfcf);
      FUN_000833ec(uVar12,"HostNotificationsVerifyPingIntervalPct",uVar13,4);
      uVar12 = Mso::Telemetry::Activity::DataFields();
      uVar13 = Storage::Configuration::GetBoolean(0xfd2);
      FUN_0006a384(uVar12,"SubscribeToEditorsTableNotification",uVar13,4);
      uVar12 = Mso::Telemetry::Activity::DataFields();
      uVar13 = Storage::Configuration::GetBoolean(0xfd3);
      FUN_0006a384(uVar12,"SubscribeToQueryChangesNotification",uVar13,4);
      uVar12 = Mso::Telemetry::Activity::DataFields();
      uVar13 = Storage::Configuration::GetBoolean(0xfd4);
      FUN_0006a384(uVar12,"SubscribeToLabelUpdates",uVar13,4);
      uVar12 = Mso::Telemetry::Activity::DataFields();
      uVar13 = Storage::Configuration::GetUnsignedInteger32(0xfd5);
      FUN_000833ec(uVar12,"PollingIntervalWhileSubscribedInSec",uVar13,4);
      uVar12 = Mso::Telemetry::Activity::DataFields();
      uVar13 = FUN_000b5934(*puVar25,1);
      FUN_0006a384(uVar12,"IsCurrentlySubscribedToETHostNotifications",uVar13,4);
      uVar12 = Mso::Telemetry::Activity::DataFields();
      uVar13 = FUN_000b5934(*puVar25,4);
      FUN_0006a384(uVar12,"IsCurrentlySubscribedToQCHostNotifications",uVar13,4);
      uVar12 = Mso::Telemetry::Activity::DataFields();
      uVar13 = Storage::Configuration::GetBoolean(0xfe7);
      FUN_0006a384(uVar12,"EnableRetryJoinCoauthOnOpen",uVar13,4);
      uVar12 = Mso::Telemetry::Activity::DataFields();
      FUN_000686ac(uVar12,"HostBatchCorrelationId",*(undefined8 *)plVar26[2],
                   ((undefined8 *)plVar26[2])[1],4);
      plVar18 = (long *)(**(code **)(*local_360 + 0xb8))();
      uVar12 = (**(code **)(*plVar18 + 0x38))();
      uVar13 = Mso::Telemetry::Activity::DataFields();
      FUN_00211b24(uVar12,uVar13);
      FUN_000ebfbc(aAStack_3b8);
      if (iVar7 == 0) {
        FUN_00295780(*puVar25,aAStack_3b8);
        uVar12 = Mso::Telemetry::Activity::DataFields();
        FUN_0006a384(uVar12,"IsClpLabeledUpload",*(undefined1 *)(*plVar26 + 0x1c0),4);
        uVar12 = Mso::Telemetry::Activity::DataFields();
        FUN_000bc410(local_1d8,&local_360,&DAT_00a79e40);
        if ((long *)local_1d8._0_8_ == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
          FUN_009a4668();
        }
        uVar13 = (**(code **)(*(long *)local_1d8._0_8_ + 0x38))();
        FUN_00389ccc(uVar12,"MRTCount",uVar13,4);
        uVar12 = local_1d8._0_8_;
        if ((long *)local_1d8._0_8_ != (long *)0x0) {
          local_1d8._0_8_ = 0;
          (**(code **)(*(long *)uVar12 + 0x10))();
        }
        uVar12 = Mso::Telemetry::Activity::DataFields();
        uVar13 = (**(code **)(*local_360 + 0xa8))();
        FUN_000833ec(uVar12,"DownloadFragmentSize",uVar13,4);
        uVar12 = Mso::Telemetry::Activity::DataFields();
        uVar13 = (**(code **)(*local_360 + 0xb0))();
        FUN_000833ec(uVar12,"UploadFragmentSize",uVar13,4);
        uVar12 = Mso::Telemetry::Activity::DataFields();
        FUN_0006a384(uVar12,"ReceivedUpdates",*(undefined1 *)plVar26[3],4);
        uVar12 = Mso::Telemetry::Activity::DataFields();
        FUN_0006a384(uVar12,"ServerOnlyFirstTimeDownload",*(undefined1 *)plVar26[4],4);
        uVar12 = Mso::Telemetry::Activity::DataFields();
        uVar13 = Storage::Configuration::GetBoolean(0xfb8);
        FUN_0006a384(uVar12,"IsRefreshUponRestorationEnabled",uVar13,4);
        uVar12 = Mso::Telemetry::Activity::DataFields();
        FUN_0006a384(uVar12,"IsSaveAs",*(undefined1 *)(*plVar26 + 300),4);
        FUN_00296e28(*puVar25,aAStack_3b8);
        if ((iVar8 == 6) || (iVar8 == 3)) {
          uVar12 = Mso::Telemetry::Activity::DataFields();
          FUN_000ec018(plVar18,uVar12);
        }
        uVar12 = Mso::Telemetry::Activity::DataFields();
        puVar19 = (undefined8 *)(**(code **)(*plVar18 + 0x20))(plVar18);
        if (*(char *)((long)puVar19 + 0x17) < '\0') {
          FUN_0002a254(&local_3d0,*puVar19,puVar19[1]);
        }
        else {
          uStack_3c8 = puVar19[1];
          local_3d0 = (void *)*puVar19;
          local_3c0 = puVar19[2];
        }
        FUN_000a9ca8(uVar12,"ServerResponseStats",&local_3d0,4);
        if (local_3c0 < 0) {
          operator_delete(local_3d0);
        }
        uVar12 = Mso::Telemetry::Activity::DataFields();
        uVar13 = (**(code **)(*plVar18 + 0x30))(plVar18);
        FUN_00389ccc(uVar12,"MRTRecordCount",uVar13,4);
      }
      if ((iVar8 == 6) || (iVar8 == 3)) {
        uVar12 = (**(code **)(*local_360 + 0x50))();
        uVar13 = Mso::Telemetry::Activity::DataFields();
        FUN_00389ccc(uVar13,"RequestTime",uVar12,4);
        uVar12 = Mso::Telemetry::Activity::DataFields();
        uVar13 = (**(code **)(*local_360 + 0xa0))();
        FUN_00389ccc(uVar12,"FinishedTime",uVar13,4);
      }
      uVar12 = Mso::Telemetry::Activity::DataFields();
      FUN_0028f2fc(uVar12,"SyncRequestStatus",local_364,4);
      uVar12 = *puVar25;
      FUN_0029dc34(auStack_350,1,0,0x1d7ce20b);
      lVar20 = FUN_000c5f58();
      FUN_0029de84(&local_358,*(undefined8 *)(lVar20 + 0x10),uVar12,0x1d7ce20b);
      iVar8 = Storage::Configuration::GetBoolean(0x419);
      if (iVar8 == 0) {
        FUN_00733f98(local_1d8,local_358,0x1d7ce20e,0);
        uVar13 = (**(code **)(*(long *)local_1d8._0_8_ + 0x50))();
        uVar9 = (**(code **)(*(long *)local_1d8._0_8_ + 0x88))();
        iVar8 = (**(code **)(*(long *)local_1d8._0_8_ + 0x98))();
        uVar15 = (**(code **)(*(long *)local_1d8._0_8_ + 0xb8))();
        uVar12 = local_1d8._0_8_;
        local_1d8._0_8_ = 0;
        auVar2._8_8_ = 0;
        auVar2._0_8_ = local_1d8._8_8_;
        auVar1 = auVar2 << 0x40;
        if ((long *)uVar12 != (long *)0x0) {
          (**(code **)(*(long *)uVar12 + 8))();
          auVar1._8_8_ = local_1d8._8_8_;
          auVar1._0_8_ = local_1d8._0_8_;
        }
      }
      else {
        uVar13 = FUN_00433948(local_358);
        uVar9 = FUN_001b0598(local_358);
        iVar8 = FUN_003df124(local_358);
        uVar15 = FUN_00431884(local_358);
        auVar1 = local_1d8;
      }
      local_1d8 = auVar1;
      uVar12 = Mso::Telemetry::Activity::DataFields();
      FUN_0006a384(uVar12,"IsCloudCollabEnabledFlagSet",uVar13,4);
      uVar10 = FUN_000446d8(0x1d7ce20d,*puVar25);
      if (local_358 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
        FUN_009a49bc();
      }
      uVar11 = (**(code **)(*local_358 + 0xd8))();
      uVar22 = 0x10;
      if (iVar8 == 0) {
        uVar22 = 2;
      }
      if (((uVar11 | uVar9 ^ 0xffffffff | uVar10) & 1) == 0) {
        uVar22 = 4;
      }
      uVar12 = Mso::Telemetry::Activity::DataFields();
      FUN_000833ec(uVar12,"RequestedProtocol",uVar22,4);
      local_1d8._0_8_ = local_1d8._0_8_ & 0xffffffff00000000;
      FUN_004319ec(0x1d7ce20c,*puVar25,local_1d8,0,uVar15,0);
      uVar12 = Mso::Telemetry::Activity::DataFields();
      FUN_0028f2fc(uVar12,"CoauthStatus",local_1d8._0_8_ & 0xffffffff,4);
      plVar18 = local_358;
      local_358 = (long *)0x0;
      if (plVar18 != (long *)0x0) {
        (**(code **)(*plVar18 + 0x10))();
      }
      FUN_0029e094(auStack_350);
      uVar12 = Mso::Telemetry::Activity::DataFields();
      FUN_0006a384(uVar12,"IsFileOpen",*(undefined1 *)plVar26[5],4);
      local_3e0 = 0;
      local_3d8 = 0;
      local_400[0] = local_400[0] & 0xffffff00;
      local_3e8 = 0;
      bVar5 = FUN_00299b60(local_370,&local_3e0,local_400);
      if ((bVar5 & local_3e8) == 1) {
        if ((local_3d8 & 1) != 0) {
          uVar12 = Mso::Telemetry::Activity::DataFields();
          FUN_00389ccc(uVar12,"HttpStatusCode",CONCAT71(uStack_3df,local_3e0),4);
          if (local_3e8 != 1) goto LAB_00763cbc;
        }
        uVar12 = Mso::Telemetry::Activity::DataFields();
        FUN_000833ec(uVar12,"HttpResultValue",local_400[0],4);
        uVar12 = Mso::Telemetry::Activity::DataFields();
        FUN_0028f1fc(uVar12,"HttpResultExtValue",local_3f8,4);
        uVar12 = Mso::Telemetry::Activity::DataFields();
        FUN_000833ec(uVar12,"HttpResultTag",local_3f0,4);
      }
LAB_00763cbc:
      if (*(long **)plVar26[6] != (long *)0x0) {
        (**(code **)(**(long **)plVar26[6] + 0xa0))(local_1d8);
        if (local_130 != (long *)0x0) {
          uVar12 = Mso::Telemetry::Activity::DataFields();
          puVar19 = (undefined8 *)(**(code **)(*local_130 + 0x20))(local_130);
          FUN_000686ac(uVar12,"Identity",*puVar19,puVar19[1],0x100);
          uVar12 = Mso::Telemetry::Activity::DataFields();
          uVar13 = (**(code **)(*local_130 + 0x30))(local_130);
          FUN_000833ec(uVar12,"IdentityProvider",uVar13,4);
        }
        local_1e8 = (**(code **)(**(long **)plVar26[6] + 0x40))();
        uVar12 = Mso::Telemetry::Activity::DataFields();
        if (cStack_111 < '\0') {
          FUN_0002a254(&local_420,local_128,uStack_120);
        }
        else {
          uStack_418 = uStack_120;
          local_420 = local_128;
          cStack_409 = cStack_111;
        }
        FUN_000a9ca8(uVar12,"CorrelationVector",&local_420,4);
        if (cStack_409 < '\0') {
          operator_delete(local_420);
        }
        uVar12 = Mso::Telemetry::Activity::DataFields();
        FUN_000686ac(uVar12,"ClientCorrelationID",local_1e8._0_8_,local_1e8._8_8_,0x100);
        (**(code **)(**(long **)plVar26[6] + 0xa0))(&local_348);
        FUN_001d057c(&local_348);
        if (local_27f == '\x01') {
          uVar12 = Mso::Telemetry::Activity::DataFields();
          if ((local_10f & 1) == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_00442230();
          }
          FUN_0006a384(uVar12,"IsHybridStore",local_110,4);
          if ((local_10f & 1) == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_00442230();
          }
          FUN_000ec868(*puVar25,local_110);
          uVar12 = *puVar25;
          local_348 = (long *)Mso::Memory::AllocateEx(0x10,0);
          if (local_348 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
            FUN_009a4e3c();
          }
          *local_348 = (long)&PTR_FUN_00d09038;
          *(undefined4 *)(local_348 + 1) = 1;
          *(uint *)((long)local_348 + 0xc) = (uint)local_110;
          FUN_000c187c(uVar12,&local_348,0x1d7ce20a);
          plVar26 = local_348;
          if (local_348 != (long *)0x0) {
            local_348 = (long *)0x0;
            (**(code **)(*plVar26 + 0x10))();
          }
        }
        FUN_0020767c(&local_348,auStack_e0);
        if (local_330 == 1) {
          lVar20 = FUN_0017c96c(&local_348,L"MIRA",0);
          uVar12 = Mso::Telemetry::Activity::DataFields();
          pcVar24 = "AFD";
          if (lVar20 != -1) {
            pcVar24 = "MIRA";
          }
          FUN_001b7fe4(uVar12,"FrontDoor",pcVar24,4);
          uVar12 = Mso::Telemetry::Activity::DataFields();
          if ((local_330 & 1) == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_00442230();
          }
          if (cStack_331 < '\0') {
            FUN_0002a254(&local_440,local_348,pvStack_340);
          }
          else {
            pvStack_438 = pvStack_340;
            local_440 = local_348;
            cStack_429 = cStack_331;
          }
          FUN_000a9ca8(uVar12,"FDRef",&local_440,0x100);
          if (cStack_429 < '\0') {
            operator_delete(local_440);
          }
        }
        if ((local_330 == 1) && (cStack_331 < '\0')) {
          operator_delete(local_348);
        }
        OGuid::ToString((_GUID *)local_1e8,false);
        FUN_002b5034(&local_348,6,&local_458);
        if (cStack_441 < '\0') {
          operator_delete(local_458);
        }
        local_470 = (void *)((long)&MACH_HEADER.magic + 1);
        Measurements::GetTimeSplitVerboseRepresentation(&local_458,0,&local_348,0xf,&local_470);
        Measurements::GetNonExclusiveCompactRepresentation(&local_470,0,&local_348,0xf,0);
        Measurements::ExtractCompactRepresentation(&local_488,0,&local_348,0xf);
        uVar12 = Mso::Telemetry::Activity::DataFields();
        if (cStack_471 < '\0') {
          FUN_00012604(&local_4a0,local_488,uStack_480);
        }
        else {
          uStack_498 = uStack_480;
          local_4a0 = local_488;
          cStack_489 = cStack_471;
        }
        FUN_000ac148(uVar12,"HttpMeasurements",&local_4a0,4);
        if (cStack_489 < '\0') {
          operator_delete(local_4a0);
        }
        uVar12 = Mso::Telemetry::Activity::DataFields();
        if (cStack_441 < '\0') {
          FUN_00012604(&local_4c0,local_458,uStack_450);
        }
        else {
          uStack_4b8 = uStack_450;
          local_4c0 = local_458;
          cStack_4a9 = cStack_441;
        }
        FUN_000ac148(uVar12,"HttpMeasurementsTimeSplit",&local_4c0,4);
        if (cStack_4a9 < '\0') {
          operator_delete(local_4c0);
        }
        uVar12 = Mso::Telemetry::Activity::DataFields();
        if (cStack_459 < '\0') {
          FUN_00012604(&local_4e0,local_470,uStack_468);
        }
        else {
          uStack_4d8 = uStack_468;
          local_4e0 = local_470;
          cStack_4c9 = cStack_459;
        }
        FUN_000ac148(uVar12,"HttpMeasurementsInclusive",&local_4e0,4);
        if (cStack_4c9 < '\0') {
          operator_delete(local_4e0);
        }
        if (local_a0 == '\x01') {
          uVar12 = Mso::Telemetry::Activity::DataFields();
          if (local_a0 != '\x01') goto LAB_0076444c;
          if (cStack_a1 < '\0') {
            FUN_00012604(&local_500,local_b8,uStack_b0);
          }
          else {
            uStack_4f8 = uStack_b0;
            local_500 = local_b8;
            cStack_4e9 = cStack_a1;
          }
          FUN_000ac148(uVar12,"ConfiguredHttpVersion",&local_500,4);
          if (cStack_4e9 < '\0') {
            operator_delete(local_500);
          }
        }
        if (local_80 == 1) {
          uVar12 = Mso::Telemetry::Activity::DataFields();
          if ((local_80 & 1) == 0) {
LAB_0076444c:
                    /* WARNING: Subroutine does not return */
            FUN_00442230();
          }
          if (cStack_81 < '\0') {
            FUN_00012604(&local_520,local_98,uStack_90);
          }
          else {
            uStack_518 = uStack_90;
            local_520 = local_98;
            cStack_509 = cStack_81;
          }
          FUN_000ac148(uVar12,"ActualHttpVersion",&local_520,4);
          if (cStack_509 < '\0') {
            operator_delete(local_520);
          }
        }
        if (cStack_471 < '\0') {
          operator_delete(local_488);
        }
        if (cStack_459 < '\0') {
          operator_delete(local_470);
        }
        if (cStack_441 < '\0') {
          operator_delete(local_458);
        }
        if (local_329 < '\0') {
          operator_delete(pvStack_340);
        }
        FUN_001d057c(local_1d8);
      }
      uVar12 = Mso::Telemetry::Activity::DataFields();
      FUN_0006a384(uVar12,"FileExist",1,4);
      plVar26 = local_370;
      if (local_370 == (long *)0x0) {
LAB_00764318:
        if (iVar23 == 0xe) {
          FUN_00061b8c(local_1d8,1,2,0x6e);
          puVar25 = (undefined8 *)Mso::Telemetry::Activity::Flags();
          *puVar25 = local_1d8._0_8_;
        }
        puVar21 = (undefined2 *)Mso::Telemetry::Activity::Success();
        *puVar21 = 0x101;
      }
      else {
        local_1d8._0_8_ = (long *)0x0;
        FUN_003927ac(local_1d8,local_370);
        if ((long *)local_1d8._0_8_ != (long *)0x0) {
          iVar8 = (**(code **)(*(long *)local_1d8._0_8_ + 0x48))();
          uVar12 = local_1d8._0_8_;
          local_1d8._0_8_ = (undefined **)0x0;
          if ((long *)uVar12 != (long *)0x0) {
            (**(code **)(*(long *)uVar12 + 0x10))();
          }
          if (iVar8 == 0x5ec) goto LAB_00764318;
        }
        local_1d8._0_8_ = (undefined **)0x0;
        FUN_003927ac(local_1d8,plVar26);
        if ((undefined **)local_1d8._0_8_ != (undefined **)0x0) {
          iVar8 = (**(code **)(*(undefined **)local_1d8._0_8_ + 0x48))();
          uVar12 = local_1d8._0_8_;
          local_1d8._0_8_ = (undefined **)0x0;
          if ((undefined **)uVar12 != (undefined **)0x0) {
            (**(code **)(*(undefined **)uVar12 + 0x10))();
          }
          if (iVar8 == 0x1e25) goto LAB_00764318;
        }
        FUN_000e01d8(aAStack_3b8,local_370,0);
      }
      Mso::Telemetry::Activity::~Activity(aAStack_3b8);
      if (local_398 != (long *)0x0) {
        LOAcquire();
        lVar20 = local_398[1];
        local_398[1] = lVar20 + -1;
        LORelease();
        if (lVar20 == 0) {
          (**(code **)(*local_398 + 0x10))(local_398);
          std::__shared_weak_count::__release_weak();
        }
      }
      plVar26 = local_390;
      if (local_390 != (long *)0x0) {
        local_390 = (long *)0x0;
        (**(code **)(*plVar26 + 0x10))();
      }
      if (local_388 != (uchar *)0x0) {
        local_380 = local_388;
        operator_delete(local_388);
      }
    }
    plVar26 = local_370;
    local_370 = (long *)0x0;
    if (plVar26 != (long *)0x0) {
      (**(code **)(*plVar26 + 0x10))();
    }
  }
  plVar26 = local_528;
  if (local_528 != (long *)0x0) {
    local_528 = (long *)0x0;
    (**(code **)(*plVar26 + 0x10))();
  }
LAB_007643f8:
  if (*(long *)PTR____stack_chk_guard_00c8a488 != local_78) {
                    /* WARNING: Subroutine does not return */
    ___stack_chk_fail();
  }
  return;
}


