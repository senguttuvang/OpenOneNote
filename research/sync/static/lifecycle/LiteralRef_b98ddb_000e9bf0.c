/* Ghidra pseudocode; inferred types and names; not Microsoft source. */
/* Default Ghidra analysis requested with 600-second per-file limit. Consult analysis log for completion; types remain inferred. */

void FUN_000e9bf0(undefined8 *param_1,long *param_2,long *param_3,undefined8 param_4,
                 undefined8 param_5,undefined8 param_6,undefined8 param_7)

{
  long *plVar1;
  bool bVar2;
  bool bVar3;
  byte bVar4;
  undefined2 uVar5;
  undefined4 uVar6;
  int iVar7;
  int iVar8;
  uint uVar9;
  uint uVar10;
  uint uVar11;
  ulong uVar12;
  undefined8 uVar13;
  undefined8 *puVar14;
  long lVar15;
  undefined8 uVar16;
  long *plVar17;
  undefined2 *puVar18;
  undefined4 uVar19;
  undefined8 uVar20;
  char *pcVar21;
  void *local_570;
  undefined8 uStack_568;
  undefined8 local_560;
  char cStack_559;
  void *local_550;
  undefined8 uStack_548;
  undefined8 local_540;
  char cStack_539;
  void *local_530;
  undefined8 uStack_528;
  undefined8 local_520;
  char cStack_519;
  void *local_510;
  undefined8 uStack_508;
  undefined8 local_500;
  char cStack_4f9;
  void *local_4f0;
  undefined8 uStack_4e8;
  undefined8 local_4e0;
  char cStack_4d9;
  void *local_4d8;
  undefined8 uStack_4d0;
  char cStack_4c1;
  void *local_4c0;
  undefined8 uStack_4b8;
  char cStack_4a9;
  void *local_4a8;
  undefined8 uStack_4a0;
  char cStack_491;
  long *local_490;
  void *pvStack_488;
  undefined8 local_480;
  char cStack_479;
  void *local_470;
  undefined8 uStack_468;
  undefined8 local_460;
  char cStack_459;
  long *local_450;
  undefined8 local_448;
  undefined4 local_440;
  byte local_438;
  undefined1 local_430;
  undefined7 uStack_42f;
  byte local_428;
  void *local_420;
  undefined8 uStack_418;
  long local_410;
  Activity aAStack_400 [16];
  undefined1 auStack_3f0 [8];
  long *local_3e8;
  undefined8 local_3e0;
  undefined8 local_3d8;
  undefined8 local_3d0;
  undefined8 local_3c8;
  long *local_3c0;
  undefined8 *local_3b8;
  long *local_3b0;
  undefined2 local_3a2;
  uchar *local_3a0;
  uchar *local_398;
  undefined8 local_390;
  int local_388;
  int local_384;
  long *local_380;
  int local_378;
  char local_371;
  long *local_370;
  undefined1 auStack_368 [8];
  long *local_360;
  void *pvStack_358;
  char cStack_349;
  byte local_348;
  char local_341;
  char local_297;
  undefined1 local_200 [16];
  long *local_1f0;
  int *piStack_1e8;
  long **local_1e0;
  int *local_1d8;
  int *local_1d0;
  uchar **local_1c8;
  long local_1c0;
  undefined2 *local_1b8;
  undefined8 **local_1b0;
  long **local_1a8;
  long **local_1a0;
  long local_198;
  undefined8 *local_190;
  undefined8 *local_188;
  undefined8 *local_180;
  undefined8 *local_178;
  char *local_170;
  long *local_148;
  void *local_140;
  undefined8 uStack_138;
  char cStack_129;
  byte local_128;
  byte local_127;
  undefined1 auStack_f8 [40];
  void *local_d0;
  undefined8 uStack_c8;
  char cStack_b9;
  char local_b8;
  void *local_b0;
  undefined8 uStack_a8;
  char cStack_99;
  byte local_98;
  long *local_90;
  undefined8 uStack_88;
  long local_78;
  
  local_78 = *(long *)PTR____stack_chk_guard_00c8a488;
  uVar20 = *param_1;
  FUN_000695a8(&local_360,0,0,0x31134c7);
  FUN_002a44b0(&local_450,uVar20,0x31134c7);
  plVar17 = local_450;
  piStack_1e8 = (int *)DAT_00b7c5b0;
  local_1f0 = DAT_00b7c5a8;
  (**(code **)(*local_450 + 0x18))(local_450,&local_1f0);
  uVar6 = (**(code **)(*plVar17 + 0x30))(plVar17,&local_1f0,0);
  plVar17 = local_450;
  if (local_450 != (long *)0x0) {
    local_450 = (long *)0x0;
    (**(code **)(*plVar17 + 0x10))();
  }
  FUN_0006a0b0(&local_360);
  local_371 = '\0';
  local_378 = 1;
  local_380 = (long *)0x0;
  local_384 = 0;
  local_388 = 3;
  local_3a0 = (uchar *)0x0;
  local_398 = (uchar *)0x0;
  local_390 = 0;
  local_3a2 = 0;
  local_3b8 = (undefined8 *)0x0;
  local_3b0 = (long *)0x0;
  uStack_88 = DAT_00b7c5b0;
  local_90 = DAT_00b7c5a8;
  local_3c8 = 0;
  local_3c0 = (long *)0x0;
  local_3d8 = 0;
  local_3d0 = 0;
  local_3e0 = 0;
  uVar20 = *param_1;
  piStack_1e8 = &local_378;
  local_1e0 = &local_380;
  local_1d8 = &local_384;
  local_1d0 = &local_388;
  local_1c8 = &local_3a0;
  local_1c0 = (long)&local_3a2 + 1;
  local_1b8 = &local_3a2;
  local_1b0 = &local_3b8;
  local_1a8 = &local_90;
  local_1a0 = &local_3c0;
  local_198 = (long)&local_3d0 + 4;
  local_190 = &local_3d0;
  local_188 = &local_3d8;
  local_180 = &local_3e0;
  local_178 = &local_3c8;
  local_170 = &local_371;
  local_1f0 = param_2;
  local_360 = (long *)Mso::Memory::AllocateEx(0x20,0);
  if (local_360 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
    FUN_009a4e3c();
  }
  *(undefined4 *)(local_360 + 1) = 1;
  *local_360 = (long)&PTR_FUN_00d08f30;
  local_360[2] = (long)(param_2 + 2);
  local_360[3] = (long)&local_1f0;
  FUN_00291d78(0x2780589,uVar20,&local_360,1);
  plVar17 = local_360;
  if (local_360 != (long *)0x0) {
    local_360 = (long *)0x0;
    (**(code **)(*plVar17 + 0x10))();
  }
  iVar8 = local_378;
  if (local_371 != '\x01') goto LAB_000ead90;
  bVar2 = local_384 == 1;
  bVar3 = local_388 == 2;
  uVar12 = FUN_0017688c();
  if (((uVar12 & 1) == 0) && (!bVar2 || !bVar3)) goto LAB_000ead90;
  if (local_3a0 == local_398) {
    Mso::Telemetry::Activity::ThreadCurrent();
    FUN_004262f4(&local_3e8);
  }
  else {
    Mso::Telemetry::IActivityParenter::Deserialize(local_3a0,(long)local_398 - (long)local_3a0);
  }
  iVar7 = 0;
  if (local_3b8 != (undefined8 *)0x0) {
    iVar7 = (**(code **)*local_3b8)();
  }
  if (bVar2 && bVar3) {
    FUN_003d905c(auStack_3f0,2,2);
    pcVar21 = "FileRequestFinishedEditorsTablePartition";
  }
  else {
    FUN_00061b8c(auStack_3f0,0xbf,2,0x6e);
    pcVar21 = "FileRequestFinished";
  }
  local_1f0 = (long *)Office::FileIO::CSI::GetNamespace();
  plVar17 = local_3e8;
  piStack_1e8 = (int *)pcVar21;
  uVar5 = FUN_000eb83c(0,*param_1,(iVar7 == 1 || iVar7 == 0xe) || bVar2 && bVar3);
  Mso::Telemetry::Activity::Activity(aAStack_400,&local_1f0,plVar17,uVar5,auStack_3f0);
  FUN_001765e0(aAStack_400,*param_1,1);
  FUN_002116b4(aAStack_400,&local_90,local_384,local_3a2._1_1_,(undefined1)local_3a2,iVar7,local_388
               ,(char)param_2[0xf]);
  uVar20 = Mso::Telemetry::Activity::DataFields();
  uVar13 = Storage::Configuration::GetBoolean(0xfee);
  FUN_0006a384(uVar20,"RunLabelRequestOnContentEndpoint",uVar13,4);
  uVar20 = Mso::Telemetry::Activity::DataFields();
  uVar13 = FUN_0003427c();
  FUN_0006a384(uVar20,"CanHostNotificationsFeatureRunForLicense",uVar13,4);
  uVar20 = Mso::Telemetry::Activity::DataFields();
  uVar13 = Storage::Configuration::GetBoolean(0xfcd);
  FUN_0006a384(uVar20,"ListenToHostNotifications",uVar13,4);
  uVar20 = Mso::Telemetry::Activity::DataFields();
  uVar13 = Storage::Configuration::GetBoolean(0xfe6);
  FUN_0006a384(uVar20,"ListenToHostNotificationsForODConsumer",uVar13,4);
  uVar20 = Mso::Telemetry::Activity::DataFields();
  uVar13 = Storage::Configuration::GetBoolean(0xfea);
  FUN_0006a384(uVar20,"StopSecondaryMetadataRequestsForApp",uVar13,4);
  uVar20 = Mso::Telemetry::Activity::DataFields();
  uVar13 = Storage::Configuration::GetUnsignedInteger32(0xfce);
  FUN_000833ec(uVar20,"HostNotificationsHeartbeatIntervalInSeconds",uVar13,4);
  uVar20 = Mso::Telemetry::Activity::DataFields();
  uVar13 = Storage::Configuration::GetUnsignedInteger32(0xfcf);
  FUN_000833ec(uVar20,"HostNotificationsVerifyPingIntervalPct",uVar13,4);
  uVar20 = Mso::Telemetry::Activity::DataFields();
  uVar13 = Storage::Configuration::GetBoolean(0xfd2);
  FUN_0006a384(uVar20,"SubscribeToEditorsTableNotification",uVar13,4);
  uVar20 = Mso::Telemetry::Activity::DataFields();
  uVar13 = Storage::Configuration::GetBoolean(0xfd3);
  FUN_0006a384(uVar20,"SubscribeToQueryChangesNotification",uVar13,4);
  uVar20 = Mso::Telemetry::Activity::DataFields();
  uVar13 = Storage::Configuration::GetBoolean(0xfd4);
  FUN_0006a384(uVar20,"SubscribeToLabelUpdates",uVar13,4);
  uVar20 = Mso::Telemetry::Activity::DataFields();
  uVar13 = Storage::Configuration::GetUnsignedInteger32(0xfd5);
  FUN_000833ec(uVar20,"PollingIntervalWhileSubscribedInSec",uVar13,4);
  uVar20 = Mso::Telemetry::Activity::DataFields();
  uVar13 = FUN_000b5934(*param_1,1);
  FUN_0006a384(uVar20,"IsCurrentlySubscribedToETHostNotifications",uVar13,4);
  uVar20 = Mso::Telemetry::Activity::DataFields();
  uVar13 = FUN_000b5934(*param_1,4);
  FUN_0006a384(uVar20,"IsCurrentlySubscribedToQCHostNotifications",uVar13,4);
  uVar20 = Mso::Telemetry::Activity::DataFields();
  uVar13 = Storage::Configuration::GetBoolean(0xfe7);
  FUN_0006a384(uVar20,"EnableRetryJoinCoauthOnOpen",uVar13,4);
  uVar20 = Mso::Telemetry::Activity::DataFields();
  FUN_000686ac(uVar20,"HostBatchCorrelationId",param_6,param_7,4);
  uVar20 = (**(code **)(*local_3c0 + 0x38))();
  uVar13 = Mso::Telemetry::Activity::DataFields();
  FUN_00211b24(uVar20,uVar13);
  FUN_000ebfbc(aAStack_400);
  if (local_388 == 0) {
    FUN_00295780(*param_1,aAStack_400);
    uVar20 = Mso::Telemetry::Activity::DataFields();
    FUN_0006a384(uVar20,"IsClpLabeledUpload",(char)param_2[0x38],4);
    uVar20 = Mso::Telemetry::Activity::DataFields();
    FUN_00389ccc(uVar20,"MRTCount",local_3c8,4);
    uVar20 = Mso::Telemetry::Activity::DataFields();
    FUN_000833ec(uVar20,"DownloadFragmentSize",local_3d0._4_4_,4);
    uVar20 = Mso::Telemetry::Activity::DataFields();
    FUN_000833ec(uVar20,"UploadFragmentSize",local_3d0 & 0xffffffff,4);
    uVar20 = Mso::Telemetry::Activity::DataFields();
    FUN_0006a384(uVar20,"ReceivedUpdates",param_4,4);
    uVar20 = Mso::Telemetry::Activity::DataFields();
    FUN_0006a384(uVar20,"ServerOnlyFirstTimeDownload",param_5,4);
    uVar20 = Mso::Telemetry::Activity::DataFields();
    uVar13 = Storage::Configuration::GetBoolean(0xfb8);
    FUN_0006a384(uVar20,"IsRefreshUponRestorationEnabled",uVar13,4);
    uVar20 = Mso::Telemetry::Activity::DataFields();
    FUN_0006a384(uVar20,"IsSaveAs",*(undefined1 *)((long)param_2 + 300),4);
    FUN_00296e28(*param_1,aAStack_400);
    plVar17 = local_3c0;
    if ((iVar8 == 6) || (iVar8 == 3)) {
      uVar20 = Mso::Telemetry::Activity::DataFields();
      FUN_000ec018(plVar17,uVar20);
    }
    uVar20 = Mso::Telemetry::Activity::DataFields();
    puVar14 = (undefined8 *)(**(code **)(*local_3c0 + 0x20))();
    if (*(char *)((long)puVar14 + 0x17) < '\0') {
      FUN_0002a254(&local_420,*puVar14,puVar14[1]);
    }
    else {
      uStack_418 = puVar14[1];
      local_420 = (void *)*puVar14;
      local_410 = puVar14[2];
    }
    FUN_000a9ca8(uVar20,"ServerResponseStats",&local_420,4);
    if (local_410 < 0) {
      operator_delete(local_420);
    }
    uVar20 = Mso::Telemetry::Activity::DataFields();
    uVar13 = (**(code **)(*local_3c0 + 0x30))();
    FUN_00389ccc(uVar20,"MRTRecordCount",uVar13,4);
  }
  if ((iVar8 == 6) || (iVar8 == 3)) {
    uVar20 = Mso::Telemetry::Activity::DataFields();
    FUN_00389ccc(uVar20,"RequestTime",local_3d8,4);
    uVar20 = Mso::Telemetry::Activity::DataFields();
    FUN_00389ccc(uVar20,"FinishedTime",local_3e0,4);
  }
  uVar20 = Mso::Telemetry::Activity::DataFields();
  FUN_0028f2fc(uVar20,"SyncRequestStatus",local_378,4);
  uVar20 = *param_1;
  FUN_0029dc34(auStack_368,1,0,0x204144db);
  lVar15 = FUN_000c5f58();
  FUN_0029de84(&local_370,*(undefined8 *)(lVar15 + 0x10),uVar20,0x204144db);
  iVar8 = Storage::Configuration::GetBoolean(0x419);
  if (iVar8 == 0) {
    FUN_00733f98(&local_1f0,local_370,0x22820482,0);
    uVar20 = (**(code **)(*local_1f0 + 0x50))();
    uVar9 = (**(code **)(*local_1f0 + 0x88))();
    iVar8 = (**(code **)(*local_1f0 + 0x98))();
    uVar13 = (**(code **)(*local_1f0 + 0xb8))();
    plVar17 = local_1f0;
    local_1f0 = (long *)0x0;
    if (plVar17 != (long *)0x0) {
      (**(code **)(*plVar17 + 8))();
    }
  }
  else {
    uVar20 = FUN_00433948(local_370);
    uVar9 = FUN_001b0598(local_370);
    iVar8 = FUN_003df124(local_370);
    uVar13 = FUN_00431884(local_370);
  }
  uVar16 = Mso::Telemetry::Activity::DataFields();
  FUN_0006a384(uVar16,"IsCloudCollabEnabledFlagSet",uVar20,4);
  uVar10 = FUN_000446d8(0x30df607,*param_1);
  if (local_370 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
    FUN_009a49bc();
  }
  uVar11 = (**(code **)(*local_370 + 0xd8))();
  uVar19 = 0x10;
  if (iVar8 == 0) {
    uVar19 = 2;
  }
  if (((uVar11 | uVar9 ^ 0xffffffff | uVar10) & 1) == 0) {
    uVar19 = 4;
  }
  uVar20 = Mso::Telemetry::Activity::DataFields();
  FUN_000833ec(uVar20,"RequestedProtocol",uVar19,4);
  local_1f0 = (long *)((ulong)local_1f0 & 0xffffffff00000000);
  FUN_004319ec(0x236df397,*param_1,&local_1f0,0,uVar13,0);
  uVar20 = Mso::Telemetry::Activity::DataFields();
  FUN_0028f2fc(uVar20,"CoauthStatus",(ulong)local_1f0 & 0xffffffff,4);
  plVar17 = local_370;
  local_370 = (long *)0x0;
  if (plVar17 != (long *)0x0) {
    (**(code **)(*plVar17 + 0x10))();
  }
  FUN_0029e094(auStack_368);
  uVar20 = Mso::Telemetry::Activity::DataFields();
  FUN_0006a384(uVar20,"IsFileOpen",uVar6,4);
  local_430 = 0;
  local_428 = 0;
  local_450 = (long *)((ulong)local_450 & 0xffffffffffffff00);
  local_438 = 0;
  bVar4 = FUN_00299b60(local_380,&local_430,&local_450);
  if ((bVar4 & local_438) == 1) {
    if ((local_428 & 1) != 0) {
      uVar20 = Mso::Telemetry::Activity::DataFields();
      FUN_00389ccc(uVar20,"HttpStatusCode",CONCAT71(uStack_42f,local_430),4);
      if (local_438 != 1) goto LAB_000ea6cc;
    }
    uVar20 = Mso::Telemetry::Activity::DataFields();
    FUN_000833ec(uVar20,"HttpResultValue",(ulong)local_450 & 0xffffffff,4);
    uVar20 = Mso::Telemetry::Activity::DataFields();
    FUN_0028f1fc(uVar20,"HttpResultExtValue",local_448,4);
    uVar20 = Mso::Telemetry::Activity::DataFields();
    FUN_000833ec(uVar20,"HttpResultTag",local_440,4);
  }
LAB_000ea6cc:
  if (param_3 != (long *)0x0) {
    (**(code **)(*param_3 + 0xa0))(&local_1f0,param_3);
    if (local_148 != (long *)0x0) {
      uVar20 = Mso::Telemetry::Activity::DataFields();
      puVar14 = (undefined8 *)(**(code **)(*local_148 + 0x20))(local_148);
      FUN_000686ac(uVar20,"Identity",*puVar14,puVar14[1],0x100);
      uVar20 = Mso::Telemetry::Activity::DataFields();
      uVar13 = (**(code **)(*local_148 + 0x30))(local_148);
      FUN_000833ec(uVar20,"IdentityProvider",uVar13,4);
    }
    local_200 = (**(code **)(*param_3 + 0x40))(param_3);
    uVar20 = Mso::Telemetry::Activity::DataFields();
    if (cStack_129 < '\0') {
      FUN_0002a254(&local_470,local_140,uStack_138);
    }
    else {
      uStack_468 = uStack_138;
      local_470 = local_140;
      cStack_459 = cStack_129;
    }
    FUN_000a9ca8(uVar20,"CorrelationVector",&local_470,4);
    if (cStack_459 < '\0') {
      operator_delete(local_470);
    }
    uVar20 = Mso::Telemetry::Activity::DataFields();
    FUN_000686ac(uVar20,"ClientCorrelationID",local_200._0_8_,local_200._8_8_,0x100);
    (**(code **)(*param_3 + 0xa0))(&local_360,param_3);
    FUN_001d057c(&local_360);
    if (local_297 == '\x01') {
      uVar20 = Mso::Telemetry::Activity::DataFields();
      if ((local_127 & 1) == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_00442230();
      }
      FUN_0006a384(uVar20,"IsHybridStore",local_128,4);
      if ((local_127 & 1) == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_00442230();
      }
      FUN_000ec868(*param_1,local_128);
      uVar20 = *param_1;
      plVar17 = (long *)Mso::Memory::AllocateEx(0x10,0);
      if (plVar17 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
        FUN_009a4e3c();
      }
      *plVar17 = (long)&PTR_FUN_00d08f88;
      *(undefined4 *)(plVar17 + 1) = 1;
      *(uint *)((long)plVar17 + 0xc) = (uint)local_128;
      local_360 = plVar17;
      FUN_000c187c(uVar20,&local_360,0x1e898819);
      plVar17 = local_360;
      if (local_360 != (long *)0x0) {
        local_360 = (long *)0x0;
        (**(code **)(*plVar17 + 0x10))();
      }
    }
    FUN_0020767c(&local_360,auStack_f8);
    if (local_348 == 1) {
      lVar15 = FUN_0017c96c(&local_360,L"MIRA",0);
      uVar20 = Mso::Telemetry::Activity::DataFields();
      pcVar21 = "AFD";
      if (lVar15 != -1) {
        pcVar21 = "MIRA";
      }
      FUN_001b7fe4(uVar20,"FrontDoor",pcVar21,4);
      uVar20 = Mso::Telemetry::Activity::DataFields();
      if ((local_348 & 1) == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_00442230();
      }
      if (cStack_349 < '\0') {
        FUN_0002a254(&local_490,local_360,pvStack_358);
      }
      else {
        pvStack_488 = pvStack_358;
        local_490 = local_360;
        cStack_479 = cStack_349;
      }
      FUN_000a9ca8(uVar20,"FDRef",&local_490,0x100);
      if (cStack_479 < '\0') {
        operator_delete(local_490);
      }
    }
    if ((local_348 == 1) && (cStack_349 < '\0')) {
      operator_delete(local_360);
    }
    OGuid::ToString((_GUID *)local_200,false);
    FUN_002b5034(&local_360,6,&local_4a8);
    if (cStack_491 < '\0') {
      operator_delete(local_4a8);
    }
    local_4c0 = (void *)((long)&MACH_HEADER.magic + 1);
    Measurements::GetTimeSplitVerboseRepresentation(&local_4a8,0,&local_360,0xf,&local_4c0);
    Measurements::GetNonExclusiveCompactRepresentation(&local_4c0,0,&local_360,0xf,0);
    Measurements::ExtractCompactRepresentation(&local_4d8,0,&local_360,0xf);
    uVar20 = Mso::Telemetry::Activity::DataFields();
    if (cStack_4c1 < '\0') {
      FUN_00012604(&local_4f0,local_4d8,uStack_4d0);
    }
    else {
      uStack_4e8 = uStack_4d0;
      local_4f0 = local_4d8;
      cStack_4d9 = cStack_4c1;
    }
    FUN_000ac148(uVar20,"HttpMeasurements",&local_4f0,4);
    if (cStack_4d9 < '\0') {
      operator_delete(local_4f0);
    }
    uVar20 = Mso::Telemetry::Activity::DataFields();
    if (cStack_491 < '\0') {
      FUN_00012604(&local_510,local_4a8,uStack_4a0);
    }
    else {
      uStack_508 = uStack_4a0;
      local_510 = local_4a8;
      cStack_4f9 = cStack_491;
    }
    FUN_000ac148(uVar20,"HttpMeasurementsTimeSplit",&local_510,4);
    if (cStack_4f9 < '\0') {
      operator_delete(local_510);
    }
    uVar20 = Mso::Telemetry::Activity::DataFields();
    if (cStack_4a9 < '\0') {
      FUN_00012604(&local_530,local_4c0,uStack_4b8);
    }
    else {
      uStack_528 = uStack_4b8;
      local_530 = local_4c0;
      cStack_519 = cStack_4a9;
    }
    FUN_000ac148(uVar20,"HttpMeasurementsInclusive",&local_530,4);
    if (cStack_519 < '\0') {
      operator_delete(local_530);
    }
    if (local_b8 == '\x01') {
      uVar20 = Mso::Telemetry::Activity::DataFields();
      if (local_b8 != '\x01') goto LAB_000eae54;
      if (cStack_b9 < '\0') {
        FUN_00012604(&local_550,local_d0,uStack_c8);
      }
      else {
        uStack_548 = uStack_c8;
        local_550 = local_d0;
        cStack_539 = cStack_b9;
      }
      FUN_000ac148(uVar20,"ConfiguredHttpVersion",&local_550,4);
      if (cStack_539 < '\0') {
        operator_delete(local_550);
      }
    }
    if (local_98 == 1) {
      uVar20 = Mso::Telemetry::Activity::DataFields();
      if ((local_98 & 1) == 0) {
LAB_000eae54:
                    /* WARNING: Subroutine does not return */
        FUN_00442230();
      }
      if (cStack_99 < '\0') {
        FUN_00012604(&local_570,local_b0,uStack_a8);
      }
      else {
        uStack_568 = uStack_a8;
        local_570 = local_b0;
        cStack_559 = cStack_99;
      }
      FUN_000ac148(uVar20,"ActualHttpVersion",&local_570,4);
      if (cStack_559 < '\0') {
        operator_delete(local_570);
      }
    }
    if (cStack_4c1 < '\0') {
      operator_delete(local_4d8);
    }
    if (cStack_4a9 < '\0') {
      operator_delete(local_4c0);
    }
    if (cStack_491 < '\0') {
      operator_delete(local_4a8);
    }
    if (local_341 < '\0') {
      operator_delete(pvStack_358);
    }
    FUN_001d057c(&local_1f0);
  }
  uVar20 = Mso::Telemetry::Activity::DataFields();
  FUN_0006a384(uVar20,"FileExist",1,4);
  plVar17 = local_380;
  if (local_380 == (long *)0x0) {
LAB_000ead20:
    if (iVar7 == 0xe) {
      FUN_00061b8c(&local_1f0,1,2,0x6e);
      plVar17 = (long *)Mso::Telemetry::Activity::Flags();
      *plVar17 = (long)local_1f0;
    }
    puVar18 = (undefined2 *)Mso::Telemetry::Activity::Success();
    *puVar18 = 0x101;
  }
  else {
    local_1f0 = (long *)0x0;
    FUN_003927ac(&local_1f0,local_380);
    if (local_1f0 != (long *)0x0) {
      iVar8 = (**(code **)(*local_1f0 + 0x48))();
      plVar1 = local_1f0;
      local_1f0 = (long *)0x0;
      if (plVar1 != (long *)0x0) {
        (**(code **)(*plVar1 + 0x10))();
      }
      if (iVar8 == 0x5ec) goto LAB_000ead20;
    }
    local_1f0 = (long *)0x0;
    FUN_003927ac(&local_1f0,plVar17);
    if (local_1f0 != (long *)0x0) {
      iVar8 = (**(code **)(*local_1f0 + 0x48))();
      plVar17 = local_1f0;
      local_1f0 = (long *)0x0;
      if (plVar17 != (long *)0x0) {
        (**(code **)(*plVar17 + 0x10))();
      }
      if (iVar8 == 0x1e25) goto LAB_000ead20;
    }
    FUN_000e01d8(aAStack_400,local_380,0);
  }
  Mso::Telemetry::Activity::~Activity(aAStack_400);
  plVar17 = local_3e8;
  if (local_3e8 != (long *)0x0) {
    local_3e8 = (long *)0x0;
    (**(code **)(*plVar17 + 0x10))();
  }
LAB_000ead90:
  plVar17 = local_3c0;
  local_3c0 = (long *)0x0;
  if (plVar17 != (long *)0x0) {
    (**(code **)(*plVar17 + 0x98))();
  }
  if (local_3b0 != (long *)0x0) {
    LOAcquire();
    lVar15 = local_3b0[1];
    local_3b0[1] = lVar15 + -1;
    LORelease();
    if (lVar15 == 0) {
      (**(code **)(*local_3b0 + 0x10))(local_3b0);
      std::__shared_weak_count::__release_weak();
    }
  }
  if (local_3a0 != (uchar *)0x0) {
    local_398 = local_3a0;
    operator_delete(local_3a0);
  }
  plVar17 = local_380;
  local_380 = (long *)0x0;
  if (plVar17 != (long *)0x0) {
    (**(code **)(*plVar17 + 0x10))();
  }
  if (*(long *)PTR____stack_chk_guard_00c8a488 != local_78) {
                    /* WARNING: Subroutine does not return */
    ___stack_chk_fail();
  }
  return;
}


