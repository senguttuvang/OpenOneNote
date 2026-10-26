/* Ghidra pseudocode; inferred types and names; not Microsoft source. */
/* Default Ghidra analysis requested with 600-second per-file limit. Consult analysis log for completion; types remain inferred. */

/* WARNING: Removing unreachable block (ram,0x001c2da8) */
/* WARNING: Removing unreachable block (ram,0x001c2cd0) */
/* WARNING: Removing unreachable block (ram,0x001c3370) */

void FUN_001c2c58(long *param_1,undefined8 ****param_2,undefined8 *param_3,undefined8 param_4)

{
  ulonglong uVar1;
  undefined1 uVar2;
  undefined8 ****ppppuVar3;
  bool bVar4;
  undefined8 uVar5;
  undefined8 uVar6;
  char *pcVar7;
  long *plVar8;
  ostream *this;
  undefined2 *puVar9;
  ulong uVar10;
  long *plVar11;
  long *plVar12;
  long *plVar13;
  long lVar14;
  long *plVar15;
  undefined8 *puVar16;
  undefined8 ****local_2d0;
  ulong uStack_2c8;
  undefined8 local_2c0;
  undefined8 ****local_2b8;
  ulong uStack_2b0;
  byte bStack_2a1;
  ulong local_2a0;
  char *pcStack_298;
  undefined8 local_290;
  undefined8 uStack_288;
  undefined8 uStack_280;
  undefined1 local_278;
  undefined7 uStack_277;
  undefined1 uStack_270;
  undefined8 uStack_26f;
  void *local_260;
  void *pvStack_258;
  char cStack_249;
  undefined7 local_248;
  char cStack_241;
  undefined8 uStack_240;
  char cStack_231;
  void *local_230;
  undefined8 uStack_228;
  char cStack_219;
  void *local_218;
  undefined8 uStack_210;
  char cStack_201;
  void *local_200;
  undefined8 uStack_1f8;
  char cStack_1e9;
  void *local_190;
  undefined8 uStack_188;
  undefined8 local_180;
  void *local_170;
  undefined8 uStack_168;
  undefined8 local_160;
  void *local_150;
  undefined8 uStack_148;
  undefined8 local_140;
  void *local_130;
  undefined8 uStack_128;
  undefined8 local_120;
  void *local_110;
  void *pvStack_108;
  undefined8 ***local_f0;
  undefined8 ***pppuStack_e8;
  undefined8 ***local_e0;
  Activity aAStack_d0 [16];
  undefined8 *local_c0;
  undefined8 uStack_b8;
  long *local_b0;
  long *plStack_a8;
  undefined8 ***local_a0;
  undefined8 ***pppuStack_98;
  undefined8 ***local_90;
  undefined1 uStack_79;
  undefined1 local_78 [16];
  
  if (*(char *)((long)param_2 + 0x17) < '\0') {
    FUN_0002a254(&local_a0,*param_2,param_2[1]);
  }
  else {
    pppuStack_98 = param_2[1];
    local_a0 = *param_2;
    local_90 = param_2[2];
  }
  (**(code **)(*param_1 + 0x18))(param_1,&local_a0,8);
  plStack_a8 = (long *)param_3[1];
  plVar8 = (long *)*param_3;
  if (param_3[1] != 0) {
    plVar11 = (long *)(param_3[1] + 8);
    *plVar11 = *plVar11 + 1;
  }
  plVar11 = (long *)param_3[3];
  uStack_b8 = param_3[3];
  puVar16 = (undefined8 *)param_3[2];
  if (plVar11 != (long *)0x0) {
    plVar11[1] = plVar11[1] + 1;
  }
  local_c0 = puVar16;
  local_b0 = plVar8;
  local_2a0 = Office::FileIO::CSI::GetNamespace();
  pcStack_298 = "EditorDiscoveryEvent";
  FUN_00061b8c(&local_2b8,0xbf,2,0x6e);
  uVar5 = FUN_00061c00();
  Mso::Telemetry::Activity::Activity(aAStack_d0,&local_2a0,uVar5,0x100,&local_2b8);
  uVar5 = Mso::Telemetry::Activity::DataFields();
  if (*(char *)((long)param_2 + 0x17) < '\0') {
    FUN_0002a254(&local_f0,*param_2,param_2[1]);
  }
  else {
    pppuStack_e8 = param_2[1];
    local_f0 = *param_2;
    local_e0 = param_2[2];
  }
  FUN_000a9ca8(uVar5,"Id",&local_f0,4);
  plVar12 = (long *)*plVar8;
  while (plVar12 != plVar8 + 1) {
    lVar14 = plVar12[4];
    uVar2 = *(undefined1 *)(plVar12 + 5);
    uVar5 = Mso::Telemetry::Activity::DataFields();
    FUN_0006a384(uVar5,(&PTR_s_Existing_00cbe4b0)[lVar14],uVar2,4);
    plVar15 = (long *)plVar12[1];
    plVar13 = plVar12;
    if ((long *)plVar12[1] == (long *)0x0) {
      do {
        plVar12 = (long *)plVar13[2];
        bVar4 = plVar13 != (long *)*plVar12;
        plVar13 = plVar12;
      } while (bVar4);
    }
    else {
      do {
        plVar12 = plVar15;
        plVar15 = (long *)*plVar12;
      } while ((long *)*plVar12 != (long *)0x0);
    }
  }
  uVar5 = Mso::Telemetry::Activity::DataFields();
  plVar8 = param_1 + 0x15;
  FUN_000686ac(uVar5,"CacheFileID",*plVar8,param_1[0x16],0x100);
  uVar5 = Mso::Telemetry::Activity::DataFields();
  FUN_0006a384(uVar5,"RTCAlwaysOn",param_4,4);
  uVar5 = Mso::Telemetry::Activity::DataFields();
  uVar6 = FUN_0003427c();
  FUN_0006a384(uVar5,"CanHostNotificationsFeatureRunForLicense",uVar6,4);
  uVar5 = Mso::Telemetry::Activity::DataFields();
  uVar6 = Storage::Configuration::GetBoolean(0xfcd);
  FUN_0006a384(uVar5,"ListenToHostNotifications",uVar6,4);
  uVar5 = Mso::Telemetry::Activity::DataFields();
  uVar6 = Storage::Configuration::GetBoolean(0xfe6);
  FUN_0006a384(uVar5,"ListenToHostNotificationsForODConsumer",uVar6,4);
  uVar5 = Mso::Telemetry::Activity::DataFields();
  uVar6 = Storage::Configuration::GetBoolean(0xfea);
  FUN_0006a384(uVar5,"StopSecondaryMetadataRequestsForApp",uVar6,4);
  uVar5 = Mso::Telemetry::Activity::DataFields();
  uVar6 = Storage::Configuration::GetUnsignedInteger32(0xfce);
  FUN_000833ec(uVar5,"HostNotificationsHeartbeatIntervalInSeconds",uVar6,4);
  uVar5 = Mso::Telemetry::Activity::DataFields();
  uVar6 = Storage::Configuration::GetUnsignedInteger32(0xfcf);
  FUN_000833ec(uVar5,"HostNotificationsVerifyPingIntervalPct",uVar6,4);
  uVar5 = Mso::Telemetry::Activity::DataFields();
  uVar6 = Storage::Configuration::GetBoolean(0xfd2);
  FUN_0006a384(uVar5,"SubscribeToEditorsTableNotification",uVar6,4);
  uVar5 = Mso::Telemetry::Activity::DataFields();
  uVar6 = Storage::Configuration::GetBoolean(0xfd3);
  FUN_0006a384(uVar5,"SubscribeToQueryChangesNotification",uVar6,4);
  uVar5 = Mso::Telemetry::Activity::DataFields();
  uVar6 = Storage::Configuration::GetBoolean(0xfd4);
  FUN_0006a384(uVar5,"SubscribeToLabelUpdates",uVar6,4);
  uVar5 = Mso::Telemetry::Activity::DataFields();
  uVar6 = Storage::Configuration::GetUnsignedInteger32(0xfd5);
  FUN_000833ec(uVar5,"PollingIntervalWhileSubscribedInSec",uVar6,4);
  uVar5 = Mso::Telemetry::Activity::DataFields();
  uVar6 = Storage::Configuration::GetUnsignedInteger32(0xfce);
  FUN_000833ec(uVar5,"HostNotificationsHeartbeatIntervalInSeconds",uVar6,4);
  uVar5 = Mso::Telemetry::Activity::DataFields();
  uVar6 = Storage::Configuration::GetUnsignedInteger32(0xfcf);
  FUN_000833ec(uVar5,"HostNotificationsVerifyPingIntervalPct",uVar6,4);
  uVar5 = Mso::Telemetry::Activity::DataFields();
  uVar6 = FUN_0003a698();
  FUN_000833ec(uVar5,"BatchSchedulerTimerTolerableDelayInMilliseconds",uVar6,4);
  uVar5 = Mso::Telemetry::Activity::DataFields();
  uVar6 = FUN_001c4414();
  FUN_000833ec(uVar5,"PingIntervalFastInSec",uVar6,4);
  uVar5 = Mso::Telemetry::Activity::DataFields();
  uVar6 = FUN_001c441c();
  FUN_000833ec(uVar5,"PingIntervalMediumInSec",uVar6,4);
  uVar5 = Mso::Telemetry::Activity::DataFields();
  uVar6 = FUN_00211a78();
  FUN_0006a384(uVar5,"CsiSafeModeEnabled",uVar6,4);
  uVar5 = Mso::Telemetry::Activity::DataFields();
  pcVar7 = (char *)FUN_0019c620();
  if (*pcVar7 < '\0') {
    uVar10 = Mso::AB::Optimized::FeatureGate::Evaluate();
  }
  else {
    uVar10 = (ulong)(*pcVar7 != '\0');
  }
  FUN_0006a384(uVar5,"EnableSignalRCore",uVar10,4);
  uVar5 = Mso::Telemetry::Activity::DataFields();
  pcVar7 = (char *)FUN_0019c62c();
  if (*pcVar7 < '\0') {
    uVar10 = Mso::AB::Optimized::FeatureGate::Evaluate();
  }
  else {
    uVar10 = (ulong)(*pcVar7 != '\0');
  }
  FUN_0006a384(uVar5,"DeprecateCppRestSdk",uVar10,4);
  FUN_0016a6ec(aAStack_d0,plVar8,0xffffffffffffffff,0);
  lVar14 = FUN_000e35f4(0x1e22311a,plVar8);
  if (lVar14 != 0x7fffffffffffffff) {
    uVar5 = Mso::Telemetry::Activity::DataFields();
    FUN_0028f1fc(uVar5,"ServerTimeDelta",lVar14,4);
  }
  FUN_003fc460(&local_2a0);
  std::recursive_mutex::lock();
  plVar8 = (long *)FUN_00097d08(param_1 + 10,param_2);
  if (param_1 + 0xb != plVar8) {
    local_2b8 = param_2;
    lVar14 = FUN_003fc550(param_1 + 10,param_2,&DAT_00a8c900,&local_2b8,local_78);
    pcStack_298 = *(char **)(lVar14 + 0x40);
    local_2a0 = *(ulong *)(lVar14 + 0x38);
    uStack_288 = *(undefined8 *)(lVar14 + 0x50);
    local_290 = *(undefined8 *)(lVar14 + 0x48);
    uStack_280 = *(undefined8 *)(lVar14 + 0x58);
    uStack_26f = *(undefined8 *)(lVar14 + 0x69);
    uStack_270 = (undefined1)((ulong)*(undefined8 *)(lVar14 + 0x61) >> 0x38);
    local_278 = (undefined1)*(undefined8 *)(lVar14 + 0x60);
    uStack_277 = (undefined7)((ulong)*(undefined8 *)(lVar14 + 0x60) >> 8);
    std::string::operator=((string *)&local_260,(string *)(lVar14 + 0x78));
    std::string::operator=((string *)&local_248,(string *)(lVar14 + 0x90));
    std::string::operator=((string *)&local_230,(string *)(lVar14 + 0xa8));
    std::string::operator=((string *)&local_218,(string *)(lVar14 + 0xc0));
    std::string::operator=((string *)&local_200,(string *)(lVar14 + 0xd8));
    uVar5 = Mso::Telemetry::Activity::DataFields();
    FUN_0028f2fc(uVar5,"RtcConnectionState",local_2a0 & 0xffffffff,4);
    uVar5 = Mso::Telemetry::Activity::DataFields();
    FUN_00389ccc(uVar5,"TimeSinceRtcReconnectingStartInSec",pcStack_298,4);
    uVar5 = Mso::Telemetry::Activity::DataFields();
    FUN_00389ccc(uVar5,"TimeSinceRtcConnectingStartInSec",local_290,4);
    uVar5 = Mso::Telemetry::Activity::DataFields();
    FUN_00389ccc(uVar5,"TimeSinceRtcTokenRefreshStartInSec",uStack_288,4);
    uVar5 = Mso::Telemetry::Activity::DataFields();
    FUN_00389ccc(uVar5,"TimeSincePowerRestoreInSec",CONCAT71(uStack_277,local_278),4);
    uVar5 = Mso::Telemetry::Activity::DataFields();
    if (cStack_249 < '\0') {
      FUN_00012604(&local_110,local_260,pvStack_258);
    }
    else {
      pvStack_108 = pvStack_258;
      local_110 = local_260;
    }
    FUN_000ac148(uVar5,"CallbackDurationInSeconds",&local_110,4);
    uVar5 = Mso::Telemetry::Activity::DataFields();
    if (cStack_231 < '\0') {
      FUN_00012604(&local_130,CONCAT17(cStack_241,local_248),uStack_240);
    }
    else {
      local_130 = (void *)CONCAT17(cStack_241,local_248);
      uStack_128 = uStack_240;
      local_120._7_1_ = cStack_231;
    }
    FUN_000ac148(uVar5,"TimeSinceCallbackDurationReceived",&local_130,4);
    if (local_120._7_1_ < '\0') {
      operator_delete(local_130);
    }
    uVar5 = Mso::Telemetry::Activity::DataFields();
    if (cStack_219 < '\0') {
      FUN_00012604(&local_150,local_230,uStack_228);
    }
    else {
      uStack_148 = uStack_228;
      local_150 = local_230;
      local_140._7_1_ = cStack_219;
    }
    FUN_000ac148(uVar5,"TimeSinceExtendSubscription",&local_150,4);
    if (local_140._7_1_ < '\0') {
      operator_delete(local_150);
    }
    uVar5 = Mso::Telemetry::Activity::DataFields();
    if (cStack_201 < '\0') {
      FUN_00012604(&local_170,local_218,uStack_210);
    }
    else {
      uStack_168 = uStack_210;
      local_170 = local_218;
      local_160._7_1_ = cStack_201;
    }
    FUN_000ac148(uVar5,"TimeSinceLastHostUpdate",&local_170,4);
    if (local_160._7_1_ < '\0') {
      operator_delete(local_170);
    }
    uVar5 = Mso::Telemetry::Activity::DataFields();
    if (cStack_1e9 < '\0') {
      FUN_00012604(&local_190,local_200,uStack_1f8);
    }
    else {
      uStack_188 = uStack_1f8;
      local_190 = local_200;
      local_180._7_1_ = cStack_1e9;
    }
    FUN_000ac148(uVar5,"TimeSinceLastHeartbeatCycleRan",&local_190,4);
    if (local_180._7_1_ < '\0') {
      operator_delete(local_190);
    }
  }
  if (param_1 != (long *)0xfffffffffffffff0) {
    std::recursive_mutex::unlock();
  }
  if (cStack_1e9 < '\0') {
    operator_delete(local_200);
  }
  if (cStack_201 < '\0') {
    operator_delete(local_218);
  }
  if (cStack_219 < '\0') {
    operator_delete(local_230);
  }
  if (cStack_231 < '\0') {
    operator_delete((void *)CONCAT17(cStack_241,local_248));
  }
  if (cStack_249 < '\0') {
    operator_delete(local_260);
  }
  FUN_002b7290(&local_2a0);
  FUN_0015a9a8(&local_2a0,"{",1);
  plVar8 = (long *)*puVar16;
  if (plVar8 != puVar16 + 1) {
    bVar4 = true;
    do {
      uVar10 = plVar8[4];
      uVar1 = plVar8[5];
      if (!bVar4) {
        FUN_0015a9a8(&local_2a0,",",1);
      }
      uVar5 = FUN_0015a9a8(&local_2a0,"\"",1);
      std::to_string(uVar10);
      uVar10 = uStack_2b0;
      ppppuVar3 = local_2b8;
      if (-1 < (char)bStack_2a1) {
        uVar10 = (ulong)bStack_2a1;
        ppppuVar3 = &local_2b8;
      }
      uVar5 = FUN_0015a9a8(uVar5,ppppuVar3,uVar10);
      uVar5 = FUN_0015a9a8(uVar5,"\"",1);
      this = (ostream *)FUN_0015a9a8(uVar5,":",1);
      std::ostream::operator<<(this,uVar1);
      if ((char)bStack_2a1 < '\0') {
        operator_delete(local_2b8);
      }
      plVar12 = (long *)plVar8[1];
      plVar15 = plVar8;
      if ((long *)plVar8[1] == (long *)0x0) {
        do {
          plVar8 = (long *)plVar15[2];
          bVar4 = plVar15 != (long *)*plVar8;
          plVar15 = plVar8;
        } while (bVar4);
      }
      else {
        do {
          plVar8 = plVar12;
          plVar12 = (long *)*plVar8;
        } while ((long *)*plVar8 != (long *)0x0);
      }
      bVar4 = false;
    } while (plVar8 != puVar16 + 1);
  }
  FUN_0015a9a8(&local_2a0,"}",1);
  local_78 = FUN_0015ac4c(&pcStack_298);
  FUN_0015ac98(&local_2b8,local_78,&uStack_79);
  uVar5 = Mso::Telemetry::Activity::DataFields();
  if ((char)bStack_2a1 < '\0') {
    FUN_00012604(&local_2d0,local_2b8,uStack_2b0);
  }
  else {
    uStack_2c8 = uStack_2b0;
    local_2d0 = local_2b8;
    local_2c0._7_1_ = bStack_2a1;
  }
  FUN_000ac148(uVar5,"Actions",&local_2d0,4);
  if ((char)local_2c0._7_1_ < '\0') {
    operator_delete(local_2d0);
  }
  puVar9 = (undefined2 *)Mso::Telemetry::Activity::Success();
  *puVar9 = 0x101;
  if ((char)bStack_2a1 < '\0') {
    operator_delete(local_2b8);
  }
  local_2a0 = *(ulong *)PTR_VTT_00c8a348;
  *(undefined8 *)((long)&local_2a0 + *(long *)(local_2a0 - 0x18)) =
       *(undefined8 *)(PTR_VTT_00c8a348 + 0x18);
  pcStack_298 = PTR_vtable_00c8a378 + 0x10;
  if (cStack_241 < '\0') {
    operator_delete(pvStack_258);
  }
  pcStack_298 = PTR_vtable_00c8a370 + 0x10;
  std::locale::~locale((locale *)&local_290);
  std::ostream::~ostream((ostream *)&local_2a0);
  std::ios::~ios((ios *)&local_230);
  Mso::Telemetry::Activity::~Activity(aAStack_d0);
  if (plVar11 != (long *)0x0) {
    LOAcquire();
    lVar14 = plVar11[1];
    plVar11[1] = lVar14 + -1;
    LORelease();
    if (lVar14 == 0) {
      (**(code **)(*plVar11 + 0x10))(plVar11);
      std::__shared_weak_count::__release_weak();
    }
  }
  if (plStack_a8 != (long *)0x0) {
    LOAcquire();
    lVar14 = plStack_a8[1];
    plStack_a8[1] = lVar14 + -1;
    LORelease();
    if (lVar14 == 0) {
      (**(code **)(*plStack_a8 + 0x10))(plStack_a8);
      std::__shared_weak_count::__release_weak();
    }
  }
  return;
}


