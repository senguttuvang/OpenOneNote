/* Ghidra pseudocode; inferred types and names; not Microsoft source. */
/* Default Ghidra analysis requested with 600-second per-file limit. Consult analysis log for completion; types remain inferred. */

/* WARNING: Removing unreachable block (ram,0x0009d1fc) */
/* WARNING: Removing unreachable block (ram,0x0009cd34) */
/* WARNING: Removing unreachable block (ram,0x0009d2c8) */

void FUN_0009c7a4(undefined8 *param_1,long param_2)

{
  uint uVar1;
  bool bVar2;
  undefined1 auVar3 [16];
  long *plVar4;
  char *pcVar5;
  DispatchQueueExecutor **ppDVar6;
  void *pvVar7;
  long *plVar8;
  undefined1 uVar9;
  undefined8 uVar10;
  long lVar11;
  CobaltClient *this;
  long *plVar12;
  wchar_t *pwVar13;
  IDispatchQueue *pIVar14;
  long *plVar15;
  uint uVar16;
  wchar_t *****pppppwVar17;
  DispatchQueueExecutor *pDVar18;
  DispatchQueueExecutor **ppDVar19;
  wchar16 *pwVar20;
  long *plVar21;
  undefined1 auVar22 [16];
  undefined1 auVar23 [16];
  long *local_500;
  long *local_4f8 [2];
  char local_4e1;
  long *local_4e0;
  ulong local_4d8;
  char local_4c9;
  long *local_4c8;
  DispatchQueueExecutor *local_4c0;
  undefined8 local_4b8;
  undefined4 local_4b0;
  undefined1 local_4ac;
  char local_4a9;
  wchar_t *local_4a8;
  wchar_t *local_4a0;
  void *local_498;
  undefined8 uStack_490;
  long local_488;
  wchar_t *****local_480;
  undefined8 uStack_478;
  long local_470;
  void *local_468;
  undefined8 uStack_460;
  long local_458;
  wchar_t ****local_450;
  undefined8 uStack_448;
  long local_440;
  char local_438;
  ushort local_430;
  long *local_420;
  DispatchQueueExecutor *local_418;
  char *local_410;
  undefined8 uStack_408;
  long lStack_400;
  long lStack_3f8;
  DispatchQueueExecutor **local_3f0;
  long *plStack_3e8;
  long *local_3e0;
  undefined1 auStack_3d8 [40];
  undefined8 local_3b0;
  wchar_t *local_3a8;
  undefined8 local_3a0;
  undefined4 local_398;
  short local_394 [130];
  long local_290;
  long lStack_288;
  char *local_280;
  undefined2 *local_278;
  undefined8 local_270;
  undefined4 local_268;
  undefined2 local_264 [130];
  _GUID a_Stack_160 [16];
  int local_150 [2];
  wchar_t *****local_148;
  undefined8 uStack_140;
  long local_138;
  void *local_130;
  undefined8 uStack_128;
  long local_120;
  wchar_t ****local_118;
  undefined8 uStack_110;
  long local_108;
  char local_100;
  ushort local_f8;
  DispatchQueueExecutor **local_f0;
  long *plStack_e8;
  undefined8 local_e0;
  undefined8 uStack_d8;
  long local_d0;
  long *local_c8;
  long *plStack_c0;
  undefined8 local_b8;
  undefined8 uStack_b0;
  wchar_t *local_a0;
  long lStack_98;
  long local_90;
  long local_78;
  
  local_78 = *(long *)PTR____stack_chk_guard_00c8a488;
  std::recursive_mutex::lock();
  FUN_0009d450(local_150,param_2);
  pvVar7 = local_130;
  lVar11 = local_138;
  if (local_150[0] == 1) {
    FUN_00735404(param_1,&local_148);
    goto LAB_0009d340;
  }
  if (local_150[0] != 0) {
                    /* WARNING: Subroutine does not return */
    FUN_009a46c4();
  }
  uStack_478 = uStack_140;
  local_480 = local_148;
  uStack_140 = 0;
  local_148 = (wchar_t *****)0x0;
  local_130 = (void *)0x0;
  local_138 = 0;
  uStack_460 = uStack_128;
  local_468 = pvVar7;
  local_470 = lVar11;
  local_458 = local_120;
  uStack_128 = 0;
  local_120 = 0;
  local_450 = (wchar_t ****)((ulong)local_450 & 0xffffffffffffff00);
  local_438 = '\0';
  if (local_100 == '\x01') {
    pppppwVar17 = &local_450;
    uStack_448 = uStack_110;
    local_450 = local_118;
    local_440 = local_108;
    local_108 = 0;
    local_118 = (wchar_t ****)0x0;
    uStack_110 = 0;
    local_438 = '\x01';
    local_430 = local_f8;
    local_498 = (void *)0x0;
    uStack_490 = 0;
    local_488 = 0;
    if (((local_f8 ^ 0xffff) & 0x101) == 0) {
      pwVar20 = L"/_vti_bin/Cobalt.ashx";
    }
    else {
      pwVar20 = L"/_vti_bin/cellstorage.svc/CellStorageService";
    }
    uVar10 = FUN_00001a9c(pwVar20);
  }
  else {
    local_430 = local_f8;
    local_498 = (void *)0x0;
    uStack_490 = 0;
    local_488 = 0;
    if (((local_f8 ^ 0xffff) & 0x101) == 0) {
      local_280 = "Server is SP w/Cobalt but webUrl is missing. Using CellStorageSvc endpoint.";
      FUN_000bfb18(0x220dc463,0x1ab,0xf,2,&local_280);
    }
    pwVar20 = L"/_vti_bin/cellstorage.svc/CellStorageService";
    uVar10 = FUN_00001a9c(L"/_vti_bin/cellstorage.svc/CellStorageService");
    pppppwVar17 = (wchar_t *****)&local_480;
  }
  uVar10 = FUN_001b59b8(pppppwVar17,pwVar20,uVar10);
  FUN_0002b044(&local_498,uVar10);
  Mso::Http::GetCurrentUserAgentInfo(a_Stack_160,&local_4a0,&local_4a8);
  local_278 = (undefined2 *)0x0;
  local_280 = (char *)0x0;
  local_268 = 0;
  local_270 = 0;
  local_280 = (char *)MsoCF::GetFastBufferAllocator();
  local_270 = 0x10200000102;
  local_264[0] = 0;
  uVar16 = DAT_00d99320 & 0xf;
  local_278 = local_264;
  if (uVar16 == 0) {
    lVar11 = Mso::Process::GetVersion();
    uVar1 = *(ushort *)(lVar11 + 2) + 6;
    uVar16 = uVar1 & 0xf;
    DAT_00d99320 = (uint)*(ushort *)(lVar11 + 4) << 0x12 | (*(ushort *)(lVar11 + 6) & 0x3fff) << 4 |
                   uVar1 & 0xf;
  }
  uVar1 = DAT_00d99320;
  local_3b0 = MsoCF::GetFixedBufferAllocator();
  local_3a8 = (wchar_t *)((long)&local_3a0 + 4);
  local_3a0 = CONCAT44(local_3a0._4_4_,0x32);
  MsoCF::Strings::SetWzFromNumber((CWzInBuffer_T *)&local_3b0,uVar16 + 10,10,0,(int *)0x0);
  pwVar13 = local_3a8;
  local_418 = (DispatchQueueExecutor *)MsoCF::GetFixedBufferAllocator();
  local_410 = (char *)((long)&uStack_408 + 4);
  uStack_408 = CONCAT44(uStack_408._4_4_,0x32);
  MsoCF::Strings::SetWzFromNumber((CWzInBuffer_T *)&local_418,uVar1 >> 4 & 0x3fff,10,0,(int *)0x0);
  pcVar5 = local_410;
  local_f0 = (DispatchQueueExecutor **)MsoCF::GetFixedBufferAllocator();
  plStack_e8 = (long *)((long)&local_e0 + 4);
  local_e0 = (wchar_t *****)CONCAT44(local_e0._4_4_,0x32);
  MsoCF::Strings::SetWzFromNumber((CWzInBuffer_T *)&local_f0,uVar1 >> 0x12,10,0,(int *)0x0);
  local_a0 = pwVar13;
  lStack_98 = (long)pcVar5;
  local_90 = (long)plStack_e8;
  MsoCF::Strings::SetWzFromPattern
            ((CWzInBuffer_T *)&local_280,(wchar_t *)L"|0.0.|1.|2",&local_a0,3,(int *)0x0);
  auVar22 = OGuid::Create();
  auVar23 = Mso::Logging::GetCurrentCorrelation();
  auVar3._8_8_ = DAT_00b7c5b0;
  auVar3._0_8_ = DAT_00b7c5a8;
  local_290 = auVar23._0_8_;
  if (auVar23 == auVar3) {
    local_290 = auVar22._0_8_;
  }
  lStack_288 = auVar22._8_8_;
  FUN_0009d99c(&local_4a9,&local_290);
  OGuid::ToString((_GUID *)&local_290,false);
  local_4b8 = 0x100000000010101;
  local_4ac = 0;
  local_4b0 = 0;
  local_3b0 = 0;
  local_3a8 = (wchar_t *)0x0;
  local_398 = 0;
  local_3a0 = 0;
  local_3b0 = MsoCF::GetFastBufferAllocator();
  local_3a0 = 0x10200000102;
  local_394[0] = 0;
  local_3a8 = (wchar_t *)local_394;
  this = (CobaltClient *)Storage::Configuration::GetBoolean(0x3aa1);
  if ((int)this != 0) {
    FUN_0029dc34(&local_418,1,0,0x1d896255);
    lVar11 = FUN_000c5f58();
    FUN_0029de84(&local_f0,*(undefined8 *)(lVar11 + 0x10),param_2 + 0x30,0x1d896255);
    if (local_f0 == (DispatchQueueExecutor **)0x0) {
                    /* WARNING: Subroutine does not return */
      FUN_009a49bc();
    }
    (**(code **)(*local_f0 + 0xf8))(local_f0,&local_3b0);
    ppDVar19 = local_f0;
    local_f0 = (DispatchQueueExecutor **)0x0;
    if (ppDVar19 != (DispatchQueueExecutor **)0x0) {
      (**(code **)(*ppDVar19 + 0x10))();
    }
    this = (CobaltClient *)FUN_0029e094(&local_418);
    if ((short)*local_3a8 == 0) {
      pppppwVar17 = local_480;
      if (-1 < local_470) {
        pppppwVar17 = (wchar_t *****)&local_480;
      }
      plVar12 = (long *)Mso::Authentication::GetIdentityForUrl((wchar_t *)pppppwVar17,false);
      this = (CobaltClient *)0x0;
      if (plVar12 != (long *)0x0) {
        pwVar13 = (wchar_t *)(**(code **)(*plVar12 + 0x28))();
        this = (CobaltClient *)
               MsoCF::Strings::CopyWzToWz(pwVar13,(CWzInBuffer_T *)&local_3b0,(int *)0x0);
      }
    }
  }
  pDVar18 = *(DispatchQueueExecutor **)(param_2 + 0xa8);
  if (pDVar18 == (DispatchQueueExecutor *)0x0) {
    FileIO::CobaltClient::CreateRequestFactory(this);
    pDVar18 = local_418;
    local_418 = (DispatchQueueExecutor *)0x0;
    plVar12 = *(long **)(param_2 + 0xa8);
    *(DispatchQueueExecutor **)(param_2 + 0xa8) = pDVar18;
    if (plVar12 != (long *)0x0) {
      (**(code **)(*plVar12 + 8))();
      pDVar18 = local_418;
      if (local_418 != (DispatchQueueExecutor *)0x0) {
        local_418 = (DispatchQueueExecutor *)0x0;
        (**(code **)(*(long *)pDVar18 + 8))();
      }
      pDVar18 = *(DispatchQueueExecutor **)(param_2 + 0xa8);
    }
    if (pDVar18 == (DispatchQueueExecutor *)0x0) {
                    /* WARNING: Subroutine does not return */
      FUN_009a4668();
    }
  }
  plVar12 = *(long **)(param_2 + 0x18);
  local_410 = (char *)0x0;
  uStack_408 = 0;
  local_418 = (DispatchQueueExecutor *)0x0;
  lVar11 = 0;
  if (plVar12 != (long *)0x0) {
    plVar15 = plVar12;
    do {
      lVar11 = lVar11 + 1;
      plVar15 = (long *)*plVar15;
    } while (plVar15 != (long *)0x0);
  }
  FUN_0009eba4(&local_418,plVar12,0,lVar11);
  (**(code **)(*(long *)pDVar18 + 0x10))(&local_4c0,pDVar18,&local_418);
  local_f0 = &local_418;
  FUN_0000fa28(&local_f0);
  OGuid::ToString(a_Stack_160,false);
  FUN_000019ec(&local_f0,local_4a0);
  FUN_000019ec(&local_4e0,local_4a8);
  FUN_000019ec(local_4f8,local_278);
  uVar9 = FUN_0039e008(param_2 + 0x30);
  FUN_000a6f84(&local_4c8,&local_498,&local_480,&local_468,&local_418,&local_f0,&local_4e0,&local_a0
               ,local_4f8,&local_4b8,uVar9,local_3a8);
  if (local_4e1 < '\0') {
    operator_delete(local_4f8[0]);
  }
  if (local_4c9 < '\0') {
    operator_delete(local_4e0);
  }
  if (uStack_408 < 0) {
    operator_delete(local_418);
  }
  plVar12 = local_4c8;
  if (local_4c8 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
    FUN_009a4668();
  }
  local_418 = local_4c0;
  if (local_4c0 != (DispatchQueueExecutor *)0x0) {
    (**(code **)(*(long *)local_4c0 + 8))();
  }
  (**(code **)(*plVar12 + 0x18))(plVar12,&local_418);
  pDVar18 = local_418;
  if (local_418 != (DispatchQueueExecutor *)0x0) {
    local_418 = (DispatchQueueExecutor *)0x0;
    (**(code **)(*(long *)pDVar18 + 0x10))();
  }
  local_f0 = (DispatchQueueExecutor **)0xbcc8f2;
  local_418 = (DispatchQueueExecutor *)&PTR_DAT_0004ef90_4_00c8df00;
  local_410 = "ClientCorrelationId";
  lStack_400 = lStack_288;
  uStack_408 = local_290;
  lStack_3f8 = CONCAT62(lStack_3f8._2_6_,0x100);
  plStack_3e8 = (long *)0x0;
  local_3e0 = (long *)0x0;
  local_3f0 = (void *)0x0;
  FUN_000271a8(0x220dc461,0x1ab,0x32,2,&local_f0,param_2 + 0x30,&local_418);
  local_418 = (DispatchQueueExecutor *)&PTR_DAT_0004ef90_4_00c8df00;
  if ((long)local_3e0 < 0) {
    operator_delete(local_3f0);
  }
  ppDVar19 = *(DispatchQueueExecutor ***)(param_2 + 0xb0);
  if (ppDVar19 == (DispatchQueueExecutor **)0x0) {
    thunk_FUN_0009e9a4(&local_f0);
    FUN_0009e8d0(&local_418,&local_f0);
    pDVar18 = local_418;
    local_418 = (DispatchQueueExecutor *)0x0;
    plVar12 = *(long **)(param_2 + 0xb0);
    *(DispatchQueueExecutor **)(param_2 + 0xb0) = pDVar18;
    if ((plVar12 != (long *)0x0) &&
       ((**(code **)(*plVar12 + 8))(), pDVar18 = local_418,
       local_418 != (DispatchQueueExecutor *)0x0)) {
      local_418 = (DispatchQueueExecutor *)0x0;
      (**(code **)(*(undefined **)pDVar18 + 8))();
    }
    ppDVar19 = local_f0;
    if (local_f0 != (DispatchQueueExecutor **)0x0) {
      local_f0 = (DispatchQueueExecutor **)0x0;
      (**(code **)(*ppDVar19 + 8))();
    }
    ppDVar19 = *(DispatchQueueExecutor ***)(param_2 + 0xb0);
    if (ppDVar19 != (DispatchQueueExecutor **)0x0) goto LAB_0009ce80;
    bVar2 = true;
  }
  else {
LAB_0009ce80:
    (**(code **)*ppDVar19)(ppDVar19);
    bVar2 = false;
  }
  plVar12 = operator_new(0x20);
  plVar21 = plVar12 + 1;
  *plVar21 = 0;
  plVar12[2] = 0;
  *plVar12 = (long)&PTR_FUN_00d020d8;
  plVar15 = plVar12 + 3;
  *(undefined1 *)plVar15 = 0;
  if (bVar2) {
                    /* WARNING: Subroutine does not return */
    FUN_009a4668();
  }
  (**(code **)(*ppDVar19 + 0x10))(&local_500,ppDVar19,&local_4c8);
  pIVar14 = (IDispatchQueue *)Mso::Async::ConcurrentQueue();
  local_f0 = ppDVar19;
  (**(code **)*ppDVar19)(ppDVar19);
  plStack_e8 = local_4c8;
  if (local_4c8 != (long *)0x0) {
    (**(code **)(*local_4c8 + 8))();
  }
  if (local_470 < 0) {
    FUN_0002a254(&local_e0,local_480,uStack_478);
  }
  else {
    uStack_d8 = uStack_478;
    local_e0 = local_480;
    local_d0 = local_470;
  }
  plVar12[1] = plVar12[1] + 1;
  uStack_b0 = *(undefined8 *)(param_2 + 0x38);
  local_b8 = *(undefined8 *)(param_2 + 0x30);
  local_c8 = plVar15;
  plStack_c0 = plVar12;
  if (local_500 == (long *)0x0) {
    FUN_009a4b44();
  }
  else {
    local_418 = (DispatchQueueExecutor *)0x0;
    local_410 = (char *)0x0;
    Mso::Futures::MakeFuture((FutureTraits *)&DAT_00d02038,0x50,(ArrayView *)&local_418);
    if ("" < local_410) {
      Mso::Futures::DispatchQueueExecutor::DispatchQueueExecutor(local_418,pIVar14);
      plVar8 = plStack_e8;
      ppDVar6 = local_f0;
      plVar4 = local_500;
      if (local_410 < "") {
                    /* WARNING: Subroutine does not return */
        FUN_009a465c();
      }
      plStack_e8 = (long *)0x0;
      local_f0 = (DispatchQueueExecutor **)0x0;
      *(long **)(local_418 + 0x10) = plVar8;
      *(DispatchQueueExecutor ***)(local_418 + 8) = ppDVar6;
      *(long *)(local_418 + 0x28) = local_d0;
      *(undefined8 *)(local_418 + 0x20) = uStack_d8;
      *(wchar_t ******)(local_418 + 0x18) = local_e0;
      local_d0 = 0;
      uStack_d8 = 0;
      local_e0 = (wchar_t *****)0x0;
      *(long **)(local_418 + 0x38) = plStack_c0;
      *(long **)(local_418 + 0x30) = local_c8;
      plStack_c0 = (long *)0x0;
      local_c8 = (long *)0x0;
      *(undefined8 *)(local_418 + 0x48) = uStack_b0;
      *(undefined8 *)(local_418 + 0x40) = local_b8;
      if (local_500 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
        FUN_009a4668();
      }
      local_4f8[0] = local_4e0;
      if (local_4e0 != (long *)0x0) {
        (**(code **)(*local_4e0 + 8))();
      }
      (**(code **)(*plVar4 + 0x38))(plVar4,local_4f8);
      plVar4 = local_4f8[0];
      if (local_4f8[0] != (long *)0x0) {
        local_4f8[0] = (long *)0x0;
        (**(code **)(*plVar4 + 0x10))();
      }
      plVar4 = local_4e0;
      local_418 = local_4c0;
      if (local_4c0 != (DispatchQueueExecutor *)0x0) {
        (**(code **)(*(long *)local_4c0 + 8))();
      }
      uStack_408 = *(long *)(param_2 + 0x38);
      local_410 = *(char **)(param_2 + 0x30);
      lStack_3f8 = lStack_288;
      lStack_400 = local_290;
      local_3f0 = ppDVar19;
      (**(code **)*ppDVar19)(ppDVar19);
      lVar11 = plVar12[1];
      plVar12[1] = lVar11 + 1;
      plStack_3e8 = plVar15;
      local_3e0 = plVar12;
      FUN_0009c730(lVar11,auStack_3d8,param_2 + 8);
      if (plVar4 == (long *)0x0) {
        FUN_009a4cbc();
      }
      else {
        local_4e0 = (long *)0x0;
        local_4d8 = 0;
        Mso::Futures::MakeFuture((FutureTraits *)&DAT_00d02068,0x70,(ArrayView *)&local_4e0);
        ppDVar6 = local_3f0;
        pDVar18 = local_418;
        if (0x6f < local_4d8) {
          local_418 = (DispatchQueueExecutor *)0x0;
          local_4e0[1] = (long)pDVar18;
          local_4e0[3] = uStack_408;
          local_4e0[2] = (long)local_410;
          local_4e0[5] = lStack_3f8;
          local_4e0[4] = lStack_400;
          local_3f0 = (DispatchQueueExecutor **)0x0;
          local_4e0[7] = (long)plStack_3e8;
          local_4e0[6] = (long)ppDVar6;
          local_4e0[8] = (long)local_3e0;
          plStack_3e8 = (long *)0x0;
          local_3e0 = (long *)0x0;
          FUN_00099500(local_4e0 + 9,auStack_3d8);
          local_420 = local_4f8[0];
          if (local_4f8[0] != (long *)0x0) {
            (**(code **)(*local_4f8[0] + 8))();
          }
          (**(code **)(*plVar4 + 0x38))(plVar4,&local_420);
          plVar15 = local_420;
          if (local_420 != (long *)0x0) {
            local_420 = (long *)0x0;
            (**(code **)(*plVar15 + 0x10))();
          }
          *param_1 = local_4f8[0];
          FUN_000db8d0(auStack_3d8);
          if (local_3e0 != (long *)0x0) {
            LOAcquire();
            lVar11 = local_3e0[1];
            local_3e0[1] = lVar11 + -1;
            LORelease();
            if (lVar11 == 0) {
              (**(code **)(*local_3e0 + 0x10))(local_3e0);
              std::__shared_weak_count::__release_weak();
            }
          }
          ppDVar6 = local_3f0;
          if (local_3f0 != (DispatchQueueExecutor **)0x0) {
            local_3f0 = (DispatchQueueExecutor **)0x0;
            (**(code **)((long)*ppDVar6 + 8))();
          }
          pDVar18 = local_418;
          if (local_418 != (DispatchQueueExecutor *)0x0) {
            local_418 = (DispatchQueueExecutor *)0x0;
            (**(code **)(*(long *)pDVar18 + 0x10))();
          }
          (**(code **)(*plVar4 + 0x10))(plVar4);
          if (plStack_c0 != (long *)0x0) {
            LOAcquire();
            lVar11 = plStack_c0[1];
            plStack_c0[1] = lVar11 + -1;
            LORelease();
            if (lVar11 == 0) {
              (**(code **)(*plStack_c0 + 0x10))(plStack_c0);
              std::__shared_weak_count::__release_weak();
            }
          }
          plVar15 = plStack_e8;
          if (plStack_e8 != (long *)0x0) {
            plStack_e8 = (long *)0x0;
            (**(code **)(*plVar15 + 0x10))();
          }
          ppDVar6 = local_f0;
          if (local_f0 != (DispatchQueueExecutor **)0x0) {
            local_f0 = (DispatchQueueExecutor **)0x0;
            (**(code **)(*ppDVar6 + 8))();
          }
          plVar15 = local_500;
          if (local_500 != (long *)0x0) {
            local_500 = (long *)0x0;
            (**(code **)(*plVar15 + 0x10))();
          }
          LOAcquire();
          lVar11 = *plVar21;
          *plVar21 = lVar11 + -1;
          LORelease();
          if (lVar11 == 0) {
            (**(code **)(*plVar12 + 0x10))(plVar12);
            std::__shared_weak_count::__release_weak();
          }
          (**(code **)(*ppDVar19 + 8))(ppDVar19);
          plVar12 = local_4c8;
          if (local_4c8 != (long *)0x0) {
            local_4c8 = (long *)0x0;
            (**(code **)(*plVar12 + 0x10))();
          }
          pDVar18 = local_4c0;
          if (local_4c0 != (DispatchQueueExecutor *)0x0) {
            local_4c0 = (DispatchQueueExecutor *)0x0;
            (**(code **)(*(long *)pDVar18 + 0x10))();
          }
          if (local_3a8 != (wchar_t *)local_394) {
            Mso::Memory::Free(local_3a8);
          }
          if (local_4a9 == '\x01') {
            Mso::Logging::EndCurrentCorrelation();
          }
          if (local_278 != local_264) {
            Mso::Memory::Free(local_278);
          }
          if (local_488 < 0) {
            operator_delete(local_498);
          }
          if ((local_438 == '\x01') && (local_440 < 0)) {
            operator_delete(local_450);
          }
          if (local_458 < 0) {
            operator_delete(local_468);
          }
          if (local_470 < 0) {
            operator_delete(local_480);
          }
LAB_0009d340:
          FUN_000db94c(local_150);
          std::recursive_mutex::unlock();
          if (*(long *)PTR____stack_chk_guard_00c8a488 != local_78) {
                    /* WARNING: Subroutine does not return */
            ___stack_chk_fail();
          }
          return;
        }
      }
                    /* WARNING: Subroutine does not return */
      FUN_009a465c();
    }
  }
                    /* WARNING: Subroutine does not return */
  FUN_009a465c();
}


