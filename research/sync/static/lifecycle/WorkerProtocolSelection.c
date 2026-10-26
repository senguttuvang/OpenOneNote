/* Ghidra pseudocode; inferred types and names; not Microsoft source. */
/* Default Ghidra analysis requested with 600-second per-file limit. Consult analysis log for completion; types remain inferred. */

void FUN_00106af0(undefined8 *param_1,long param_2,int *param_3,undefined8 param_4,long *param_5,
                 undefined8 param_6,long *param_7,undefined8 param_8,undefined8 param_9,
                 undefined8 param_10,int *param_11)

{
  undefined8 *puVar1;
  int iVar2;
  bool bVar3;
  uint uVar4;
  int iVar5;
  undefined4 uVar6;
  undefined8 uVar7;
  long *plVar8;
  undefined8 *puVar9;
  char *pcVar10;
  ulong uVar11;
  byte bVar12;
  long lVar13;
  long *plVar14;
  long ****pppplVar15;
  ulong uVar16;
  int iVar17;
  long *plVar18;
  undefined1 auVar19 [16];
  long *local_288;
  long *plStack_280;
  long *local_278;
  char local_269;
  long *local_268;
  long ****local_260;
  long ****local_258;
  long *local_248;
  long *local_240;
  long *local_238;
  long *local_230;
  long *local_228;
  long *local_220;
  long *local_218;
  long *local_210;
  long *local_208;
  long *local_200;
  long *local_1f8;
  long *local_1f0;
  int local_1e4;
  long local_1e0;
  long ****local_1d8;
  long ****local_1d0;
  long local_1c8;
  char local_1b9;
  long *local_1b8;
  long *local_1b0;
  void *local_1a8;
  void *local_1a0;
  char local_191;
  undefined8 local_190;
  long *plStack_188;
  undefined8 local_180;
  undefined1 local_178 [8];
  long **local_170;
  long local_70;
  
  local_70 = *(long *)PTR____stack_chk_guard_00c8a488;
  iVar5 = *param_3;
  local_1e0 = *param_5;
  local_1e4 = *param_11;
  lVar13 = *(long *)(param_2 + 0x20);
  if ((lVar13 != 0) && (*(int *)(lVar13 + 8) != 0)) {
    iVar17 = *(int *)(lVar13 + 8);
    do {
      iVar2 = *(int *)(lVar13 + 8);
      if (iVar2 == iVar17) {
        *(int *)(lVar13 + 8) = iVar17 + 1;
        plVar14 = *(long **)(param_2 + 0x18);
        if (plVar14 != (long *)0x0) {
          if (*(long *)(param_2 + 0x10) == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_009a5674();
          }
          FUN_00108660(&local_190,*(long *)(param_2 + 0x10),&DAT_00a8e250);
          if ((long *)local_190 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
            FUN_009a4668();
          }
          uVar4 = (**(code **)(*(long *)local_190 + 0x210))();
          plVar8 = (long *)local_190;
          if ((long *)local_190 != (long *)0x0) {
            local_190 = (char *)0x0;
            (**(code **)(*plVar8 + 0x10))();
          }
          if (iVar5 == 0) {
            uVar4 = 1;
          }
          if ((uVar4 & 1) == 0) {
            local_190 = "GetDefaultOpWorkerFactory: Protocol unavailable";
            FUN_000bfb18(0x1f298885,0x9d4,0xf,2,&local_190);
            *param_1 = 0;
          }
          else {
            lVar13 = *(long *)(param_2 + 0x10);
            if (lVar13 == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_009a5674();
            }
            local_190 = (char *)lVar13;
            FUN_0010869c(&local_230,&local_190,&DAT_00a8e250);
            if (local_230 == (long *)0x0) {
              local_1f0 = (long *)0x0;
LAB_001071e0:
              local_190 = "GetDefaultOpWorkerFactory: Incomplete session info";
              FUN_000bfb18(0x1f015090,0x9d4,10,2,&local_190);
              *param_1 = 0;
            }
            else {
              (**(code **)(*local_230 + 0x30))(&local_260);
              FUN_002b4d38(&local_1b0,lVar13);
              FUN_0015d5dc(&local_288,lVar13);
              if (local_230 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
                FUN_009a4668();
              }
              (**(code **)(*local_230 + 0xa0))(&local_1b8);
              if (local_1b8 == (long *)0x0) {
LAB_00106db8:
                plVar8 = plStack_280;
                if (-1 < (long)local_278) {
                  plVar8 = (long *)((ulong)local_278 >> 0x38);
                }
                if (plVar8 == (long *)0x0) {
                  local_190 = "GetSessionInfo: Missing web and file url";
                  FUN_000bfb18(0x1f015094,0x9d4,10,2,&local_190);
                  local_1f0 = (long *)0x0;
                }
                else {
                  local_190 = "GetSessionInfo: Using file url";
                  FUN_000bfb18(0x1f015096,0x9d4,0x32,2,&local_190);
                  if ((long)local_278 < 0) {
                    FUN_0002a254(&local_190,local_288,plStack_280);
                  }
                  else {
                    plStack_188 = plStack_280;
                    local_190 = (char *)local_288;
                    local_180 = local_278;
                  }
                  if ((long)local_180._7_1_ < 0) {
                    if (plStack_188 != (long *)0x0) {
                      plVar8 = plStack_188;
                      plVar18 = (long *)local_190;
                      goto LAB_00106f38;
                    }
                  }
                  else if (local_180._7_1_ != '\0') {
                    plVar8 = (long *)(long)local_180._7_1_;
                    plVar18 = &local_190;
LAB_00106f38:
                    if (*(short *)((long)plVar18 + (long)plVar8 * 2 + -2) == 0x2f) {
                      uVar7 = FUN_0015dec8(&local_190,(long)plVar8 + -1,0xffffffffffffffff);
                      FUN_0002b044(&local_190,uVar7);
                    }
                  }
                  uVar7 = FUN_00001a9c(L"/_vti_bin/cellstorage.svc/CellStorageService");
                  uVar7 = FUN_001b59b8(&local_190,L"/_vti_bin/cellstorage.svc/CellStorageService",
                                       uVar7);
                  FUN_0002b044(&local_190,uVar7);
                  local_1d0 = local_260;
                  FUN_0041c9ec(&local_1f0,&local_190,&local_288,&local_1d0,&local_1b0);
                  if ((long)local_180 < 0) {
                    operator_delete(local_190);
                  }
                }
              }
              else {
                local_190 = (char *)0x0;
                plStack_188 = (long *)0x0;
                local_178 = (undefined1  [8])((ulong)local_178 & 0xffffffff00000000);
                local_180 = (long *)0x0;
                local_190 = (char *)MsoCF::GetFastBufferAllocator();
                plVar8 = (long *)(local_178 + 4);
                local_180 = (long *)0x10200000102;
                local_178._4_2_ = 0;
                plStack_188 = plVar8;
                if (local_1b8 == (long *)0x0) {
                  FUN_009a4994();
                  goto LAB_00108384;
                }
                (**(code **)(*local_1b8 + 0x30))(local_1b8,&local_190);
                if (plStack_188 == (long *)0x0) {
                  Mso::Memory::Free((void *)0x0);
                  plVar8 = local_1b8;
                  local_1b8 = (long *)0x0;
                  if (plVar8 != (long *)0x0) {
                    (**(code **)(*plVar8 + 0x10))();
                  }
                  goto LAB_00106db8;
                }
                local_1d0 = (long ****)0xba2687;
                FUN_000bfb18(0x1f646313,0x9d4,0x32,2,&local_1d0);
                FUN_000019ec(&local_1d0,plStack_188);
                if ((long)local_1b9 < 0) {
                  if (local_1c8 != 0) {
                    pppplVar15 = local_1d0;
                    goto LAB_00106e58;
                  }
                }
                else if (local_1b9 != '\0') {
                  local_1c8 = (long)local_1b9;
                  pppplVar15 = (long ****)&local_1d0;
LAB_00106e58:
                  if (*(short *)((long)pppplVar15 + local_1c8 * 2 + -2) == 0x2f) {
                    uVar7 = FUN_0015dec8(&local_1d0,local_1c8 + -1,0xffffffffffffffff);
                    FUN_0002b044(&local_1d0,uVar7);
                  }
                }
                uVar7 = FUN_00001a9c(L"/_vti_bin/cellstorage.svc/CellStorageService");
                uVar7 = FUN_001b59b8(&local_1d0,L"/_vti_bin/cellstorage.svc/CellStorageService",
                                     uVar7);
                FUN_0002b044(&local_1d0,uVar7);
                local_1d8 = local_260;
                FUN_0041c9ec(&local_1f0,&local_1d0,&local_288,&local_1d8,&local_1b0);
                if (local_1b9 < '\0') {
                  operator_delete(local_1d0);
                }
                if (plStack_188 != plVar8) {
                  Mso::Memory::Free(plStack_188);
                }
                plVar8 = local_1b8;
                local_1b8 = (long *)0x0;
                if (plVar8 != (long *)0x0) {
                  (**(code **)(*plVar8 + 0x10))();
                }
              }
              if ((long)local_278 < 0) {
                operator_delete(local_288);
              }
              if (local_191 < '\0') {
                operator_delete(local_1a8);
              }
              pppplVar15 = local_260;
              if (local_260 != (long ****)0x0) {
                local_260 = (long ****)0x0;
                (*(code *)(*pppplVar15)[2])();
              }
              plVar8 = local_230;
              if (local_230 != (long *)0x0) {
                local_230 = (long *)0x0;
                (**(code **)(*plVar8 + 0x10))();
              }
              if (local_1f0 == (long *)0x0) goto LAB_001071e0;
              if (*(long *)(param_2 + 0x10) == 0) {
LAB_00108384:
                    /* WARNING: Subroutine does not return */
                FUN_009a5674();
              }
              FUN_0015d5dc(&local_1d0);
              FUN_000603c0(&local_1b8);
              if (*(long **)(param_2 + 0x10) == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
                FUN_009a5668();
              }
              uVar7 = (**(code **)(**(long **)(param_2 + 0x10) + 0x18))();
              FUN_00060444(&local_1d8,plVar14,uVar7,&local_1e4);
              if (iVar5 == 1) {
                local_230 = (long *)0x0;
                local_228 = (long *)0x0;
                local_220 = (long *)0x0;
                FUN_001d3f10(&local_230,*param_7,param_7[1],param_7[1] - *param_7 >> 4);
                FUN_0006057c(&local_1f8,param_4,&DAT_00aa57b0);
                FUN_000d92a8(&local_200);
                if (*(long **)(param_2 + 0x10) == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
                  FUN_009a5668();
                }
                uVar7 = (**(code **)(**(long **)(param_2 + 0x10) + 0x18))();
                plVar18 = local_1f8;
                plVar8 = local_200;
                if (local_200 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
                  FUN_009a5674();
                }
                puVar9 = operator_new(0x58);
                puVar9[2] = 0;
                *puVar9 = &PTR_FUN_00ccf5e8;
                puVar9[1] = 0;
                puVar1 = puVar9 + 3;
                FUN_00060614(puVar1,uVar7,plVar18,plVar8);
                if (local_228 < local_220) {
                  *local_228 = (long)puVar1;
                  local_228[1] = (long)puVar9;
                  plVar8 = local_228 + 2;
                }
                else {
                  lVar13 = (long)local_228 - (long)local_230;
                  uVar11 = (lVar13 >> 4) + 1;
                  if (uVar11 >> 0x3c != 0) goto LAB_001083f4;
                  uVar16 = (long)local_220 - (long)local_230 >> 3;
                  if (uVar16 <= uVar11) {
                    uVar16 = uVar11;
                  }
                  if (0x7fffffffffffffef < (ulong)((long)local_220 - (long)local_230)) {
                    uVar16 = 0xfffffffffffffff;
                  }
                  local_170 = &local_220;
                  auVar19 = FUN_0000baf8(&local_220,uVar16);
                  plVar18 = (long *)(auVar19._0_8_ + lVar13);
                  *plVar18 = (long)puVar1;
                  plVar18[1] = (long)puVar9;
                  plVar8 = plVar18 + 2;
                  plVar18 = (long *)((long)plVar18 - ((long)local_228 - (long)local_230));
                  _memcpy(plVar18,local_230,(long)local_228 - (long)local_230);
                  local_180 = local_230;
                  local_178 = (undefined1  [8])local_220;
                  local_190 = (char *)local_230;
                  plStack_188 = local_230;
                  local_230 = plVar18;
                  local_228 = plVar8;
                  local_220 = (long *)(auVar19._0_8_ + auVar19._8_8_ * 0x10);
                  FUN_0000bb2c(&local_190);
                }
                local_228 = plVar8;
                iVar5 = FileIO::Clp::IsFilePolicySupported();
                if (iVar5 != 0) {
                  if (*(long **)(param_2 + 0x10) == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
                    FUN_009a5668();
                  }
                  uVar7 = (**(code **)(**(long **)(param_2 + 0x10) + 0x18))();
                  plVar8 = local_1f8;
                  puVar9 = operator_new(0x48);
                  puVar9[2] = 0;
                  *puVar9 = &PTR_FUN_00ccf638;
                  puVar9[1] = 0;
                  puVar1 = puVar9 + 3;
                  FUN_00606110(puVar1,uVar7,plVar8);
                  if (local_228 < local_220) {
                    *local_228 = (long)puVar1;
                    local_228[1] = (long)puVar9;
                    plVar8 = local_228 + 2;
                  }
                  else {
                    lVar13 = (long)local_228 - (long)local_230;
                    uVar11 = (lVar13 >> 4) + 1;
                    if (uVar11 >> 0x3c != 0) goto LAB_001083f4;
                    uVar16 = (long)local_220 - (long)local_230 >> 3;
                    if (uVar16 <= uVar11) {
                      uVar16 = uVar11;
                    }
                    if (0x7fffffffffffffef < (ulong)((long)local_220 - (long)local_230)) {
                      uVar16 = 0xfffffffffffffff;
                    }
                    local_170 = &local_220;
                    auVar19 = FUN_0000baf8(&local_220,uVar16);
                    plVar18 = (long *)(auVar19._0_8_ + lVar13);
                    *plVar18 = (long)puVar1;
                    plVar18[1] = (long)puVar9;
                    plVar8 = plVar18 + 2;
                    plVar18 = (long *)((long)plVar18 - ((long)local_228 - (long)local_230));
                    _memcpy(plVar18,local_230,(long)local_228 - (long)local_230);
                    local_180 = local_230;
                    local_178 = (undefined1  [8])local_220;
                    local_190 = (char *)local_230;
                    plStack_188 = local_230;
                    local_230 = plVar18;
                    local_228 = plVar8;
                    local_220 = (long *)(auVar19._0_8_ + auVar19._8_8_ * 0x10);
                    FUN_0000bb2c(&local_190);
                  }
                  local_228 = plVar8;
                }
                plVar8 = local_200;
                if (local_200 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
                  FUN_009a5674();
                }
                puVar9 = operator_new(0x28);
                puVar9[2] = 0;
                *puVar9 = &PTR_FUN_00ccf688;
                puVar9[1] = 0;
                puVar1 = puVar9 + 3;
                FUN_000606f4(puVar1,plVar8);
                if (local_228 < local_220) {
                  *local_228 = (long)puVar1;
                  local_228[1] = (long)puVar9;
                  plVar8 = local_228 + 2;
                }
                else {
                  lVar13 = (long)local_228 - (long)local_230;
                  uVar11 = (lVar13 >> 4) + 1;
                  if (uVar11 >> 0x3c != 0) goto LAB_001083f4;
                  uVar16 = (long)local_220 - (long)local_230 >> 3;
                  if (uVar16 <= uVar11) {
                    uVar16 = uVar11;
                  }
                  if (0x7fffffffffffffef < (ulong)((long)local_220 - (long)local_230)) {
                    uVar16 = 0xfffffffffffffff;
                  }
                  local_170 = &local_220;
                  auVar19 = FUN_0000baf8(&local_220,uVar16);
                  plVar18 = (long *)(auVar19._0_8_ + lVar13);
                  *plVar18 = (long)puVar1;
                  plVar18[1] = (long)puVar9;
                  plVar8 = plVar18 + 2;
                  plVar18 = (long *)((long)plVar18 - ((long)local_228 - (long)local_230));
                  _memcpy(plVar18,local_230,(long)local_228 - (long)local_230);
                  local_180 = local_230;
                  local_178 = (undefined1  [8])local_220;
                  local_190 = (char *)local_230;
                  plStack_188 = local_230;
                  local_230 = plVar18;
                  local_228 = plVar8;
                  local_220 = (long *)(auVar19._0_8_ + auVar19._8_8_ * 0x10);
                  FUN_0000bb2c(&local_190);
                }
                local_228 = plVar8;
                if (*(long **)(param_2 + 0x10) == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
                  FUN_009a5668();
                }
                uVar7 = (**(code **)(**(long **)(param_2 + 0x10) + 0x18))();
                pppplVar15 = local_1d8;
                plVar8 = local_200;
                if (local_200 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
                  FUN_009a5674();
                }
                puVar9 = operator_new(0x48);
                puVar9[1] = 0;
                puVar9[2] = 0;
                *puVar9 = &PTR_FUN_00ccf6d8;
                puVar1 = puVar9 + 3;
                FUN_00060730(puVar1,uVar7,plVar8,pppplVar15,local_1e4);
                if (local_228 < local_220) {
                  *local_228 = (long)puVar1;
                  local_228[1] = (long)puVar9;
                  plVar8 = local_228 + 2;
                }
                else {
                  lVar13 = (long)local_228 - (long)local_230;
                  uVar11 = (lVar13 >> 4) + 1;
                  if (uVar11 >> 0x3c != 0) goto LAB_001083f4;
                  uVar16 = (long)local_220 - (long)local_230 >> 3;
                  if (uVar16 <= uVar11) {
                    uVar16 = uVar11;
                  }
                  if (0x7fffffffffffffef < (ulong)((long)local_220 - (long)local_230)) {
                    uVar16 = 0xfffffffffffffff;
                  }
                  local_170 = &local_220;
                  auVar19 = FUN_0000baf8(&local_220,uVar16);
                  plVar18 = (long *)(auVar19._0_8_ + lVar13);
                  *plVar18 = (long)puVar1;
                  plVar18[1] = (long)puVar9;
                  plVar8 = plVar18 + 2;
                  plVar18 = (long *)((long)plVar18 - ((long)local_228 - (long)local_230));
                  _memcpy(plVar18,local_230,(long)local_228 - (long)local_230);
                  local_180 = local_230;
                  local_178 = (undefined1  [8])local_220;
                  local_190 = (char *)local_230;
                  plStack_188 = local_230;
                  local_230 = plVar18;
                  local_228 = plVar8;
                  local_220 = (long *)(auVar19._0_8_ + auVar19._8_8_ * 0x10);
                  FUN_0000bb2c(&local_190);
                }
                local_228 = plVar8;
                if (*(long **)(param_2 + 0x10) == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
                  FUN_009a5668();
                }
                uVar7 = (**(code **)(**(long **)(param_2 + 0x10) + 0x18))();
                plVar8 = local_200;
                if (local_200 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
                  FUN_009a5674();
                }
                puVar9 = operator_new(0x30);
                puVar9[2] = 0;
                *puVar9 = &PTR_FUN_00ccf728;
                puVar9[1] = 0;
                puVar1 = puVar9 + 3;
                FUN_000607b0(puVar1,uVar7,plVar8);
                if (local_228 < local_220) {
                  *local_228 = (long)puVar1;
                  local_228[1] = (long)puVar9;
                  plVar8 = local_228 + 2;
                }
                else {
                  lVar13 = (long)local_228 - (long)local_230;
                  uVar11 = (lVar13 >> 4) + 1;
                  if (uVar11 >> 0x3c != 0) goto LAB_001083f4;
                  uVar16 = (long)local_220 - (long)local_230 >> 3;
                  if (uVar16 <= uVar11) {
                    uVar16 = uVar11;
                  }
                  if (0x7fffffffffffffef < (ulong)((long)local_220 - (long)local_230)) {
                    uVar16 = 0xfffffffffffffff;
                  }
                  local_170 = &local_220;
                  auVar19 = FUN_0000baf8(&local_220,uVar16);
                  plVar18 = (long *)(auVar19._0_8_ + lVar13);
                  *plVar18 = (long)puVar1;
                  plVar18[1] = (long)puVar9;
                  plVar8 = plVar18 + 2;
                  plVar18 = (long *)((long)plVar18 - ((long)local_228 - (long)local_230));
                  _memcpy(plVar18,local_230,(long)local_228 - (long)local_230);
                  local_180 = local_230;
                  local_178 = (undefined1  [8])local_220;
                  local_190 = (char *)local_230;
                  plStack_188 = local_230;
                  local_230 = plVar18;
                  local_228 = plVar8;
                  local_220 = (long *)(auVar19._0_8_ + auVar19._8_8_ * 0x10);
                  FUN_0000bb2c(&local_190);
                }
                local_228 = plVar8;
                if (local_1f8 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
                  FUN_009a4668();
                }
                uVar7 = (**(code **)(*local_1f8 + 0x58))();
                pppplVar15 = local_1d8;
                puVar9 = operator_new(0x30);
                puVar9[2] = 0;
                *puVar9 = &PTR_FUN_00ccf778;
                puVar9[1] = 0;
                puVar1 = puVar9 + 3;
                FUN_000607f0(puVar1,uVar7,pppplVar15);
                if (local_228 < local_220) {
                  *local_228 = (long)puVar1;
                  local_228[1] = (long)puVar9;
                  plVar8 = local_228 + 2;
                }
                else {
                  lVar13 = (long)local_228 - (long)local_230;
                  uVar11 = (lVar13 >> 4) + 1;
                  if (uVar11 >> 0x3c != 0) goto LAB_001083f4;
                  uVar16 = (long)local_220 - (long)local_230 >> 3;
                  if (uVar16 <= uVar11) {
                    uVar16 = uVar11;
                  }
                  if (0x7fffffffffffffef < (ulong)((long)local_220 - (long)local_230)) {
                    uVar16 = 0xfffffffffffffff;
                  }
                  local_170 = &local_220;
                  auVar19 = FUN_0000baf8(&local_220,uVar16);
                  plVar18 = (long *)(auVar19._0_8_ + lVar13);
                  *plVar18 = (long)puVar1;
                  plVar18[1] = (long)puVar9;
                  plVar8 = plVar18 + 2;
                  plVar18 = (long *)((long)plVar18 - ((long)local_228 - (long)local_230));
                  _memcpy(plVar18,local_230,(long)local_228 - (long)local_230);
                  local_180 = local_230;
                  local_178 = (undefined1  [8])local_220;
                  local_190 = (char *)local_230;
                  plStack_188 = local_230;
                  local_230 = plVar18;
                  local_228 = plVar8;
                  local_220 = (long *)(auVar19._0_8_ + auVar19._8_8_ * 0x10);
                  FUN_0000bb2c(&local_190);
                }
                local_228 = plVar8;
                if (local_1f8 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
                  FUN_009a4668();
                }
                uVar7 = (**(code **)(*local_1f8 + 0x58))();
                pppplVar15 = local_1d8;
                puVar9 = operator_new(0x30);
                puVar9[2] = 0;
                *puVar9 = &PTR_FUN_00ccf7c8;
                puVar9[1] = 0;
                puVar1 = puVar9 + 3;
                FUN_00060834(puVar1,uVar7,pppplVar15);
                if (local_228 < local_220) {
                  *local_228 = (long)puVar1;
                  local_228[1] = (long)puVar9;
                  plVar8 = local_228 + 2;
                }
                else {
                  lVar13 = (long)local_228 - (long)local_230;
                  uVar11 = (lVar13 >> 4) + 1;
                  if (uVar11 >> 0x3c != 0) goto LAB_001083f4;
                  uVar16 = (long)local_220 - (long)local_230 >> 3;
                  if (uVar16 <= uVar11) {
                    uVar16 = uVar11;
                  }
                  if (0x7fffffffffffffef < (ulong)((long)local_220 - (long)local_230)) {
                    uVar16 = 0xfffffffffffffff;
                  }
                  local_170 = &local_220;
                  auVar19 = FUN_0000baf8(&local_220,uVar16);
                  plVar18 = (long *)(auVar19._0_8_ + lVar13);
                  *plVar18 = (long)puVar1;
                  plVar18[1] = (long)puVar9;
                  plVar8 = plVar18 + 2;
                  plVar18 = (long *)((long)plVar18 - ((long)local_228 - (long)local_230));
                  _memcpy(plVar18,local_230,(long)local_228 - (long)local_230);
                  local_180 = local_230;
                  local_178 = (undefined1  [8])local_220;
                  local_190 = (char *)local_230;
                  plStack_188 = local_230;
                  local_230 = plVar18;
                  local_228 = plVar8;
                  local_220 = (long *)(auVar19._0_8_ + auVar19._8_8_ * 0x10);
                  FUN_0000bb2c(&local_190);
                }
                pppplVar15 = local_1d8;
                local_228 = plVar8;
                puVar9 = operator_new(0x28);
                puVar9[2] = 0;
                *puVar9 = &PTR_FUN_00ccf818;
                puVar9[1] = 0;
                puVar1 = puVar9 + 3;
                FUN_00060878(puVar1,pppplVar15);
                if (local_228 < local_220) {
                  *local_228 = (long)puVar1;
                  local_228[1] = (long)puVar9;
                  plVar8 = local_228 + 2;
                }
                else {
                  lVar13 = (long)local_228 - (long)local_230;
                  uVar11 = (lVar13 >> 4) + 1;
                  if (uVar11 >> 0x3c != 0) goto LAB_001083f4;
                  uVar16 = (long)local_220 - (long)local_230 >> 3;
                  if (uVar16 <= uVar11) {
                    uVar16 = uVar11;
                  }
                  if (0x7fffffffffffffef < (ulong)((long)local_220 - (long)local_230)) {
                    uVar16 = 0xfffffffffffffff;
                  }
                  local_170 = &local_220;
                  auVar19 = FUN_0000baf8(&local_220,uVar16);
                  plVar18 = (long *)(auVar19._0_8_ + lVar13);
                  *plVar18 = (long)puVar1;
                  plVar18[1] = (long)puVar9;
                  plVar8 = plVar18 + 2;
                  plVar18 = (long *)((long)plVar18 - ((long)local_228 - (long)local_230));
                  _memcpy(plVar18,local_230,(long)local_228 - (long)local_230);
                  local_180 = local_230;
                  local_178 = (undefined1  [8])local_220;
                  local_190 = (char *)local_230;
                  plStack_188 = local_230;
                  local_230 = plVar18;
                  local_228 = plVar8;
                  local_220 = (long *)(auVar19._0_8_ + auVar19._8_8_ * 0x10);
                  FUN_0000bb2c(&local_190);
                }
                pppplVar15 = local_1d8;
                local_228 = plVar8;
                puVar9 = operator_new(0x28);
                puVar9[2] = 0;
                *puVar9 = &PTR_FUN_00ccf868;
                puVar9[1] = 0;
                puVar1 = puVar9 + 3;
                FUN_000608b4(puVar1,pppplVar15);
                if (local_228 < local_220) {
                  *local_228 = (long)puVar1;
                  local_228[1] = (long)puVar9;
                  plVar8 = local_228 + 2;
                }
                else {
                  lVar13 = (long)local_228 - (long)local_230;
                  uVar11 = (lVar13 >> 4) + 1;
                  if (uVar11 >> 0x3c != 0) goto LAB_001083f4;
                  uVar16 = (long)local_220 - (long)local_230 >> 3;
                  if (uVar16 <= uVar11) {
                    uVar16 = uVar11;
                  }
                  if (0x7fffffffffffffef < (ulong)((long)local_220 - (long)local_230)) {
                    uVar16 = 0xfffffffffffffff;
                  }
                  local_170 = &local_220;
                  auVar19 = FUN_0000baf8(&local_220,uVar16);
                  plVar18 = (long *)(auVar19._0_8_ + lVar13);
                  *plVar18 = (long)puVar1;
                  plVar18[1] = (long)puVar9;
                  plVar8 = plVar18 + 2;
                  plVar18 = (long *)((long)plVar18 - ((long)local_228 - (long)local_230));
                  _memcpy(plVar18,local_230,(long)local_228 - (long)local_230);
                  local_180 = local_230;
                  local_178 = (undefined1  [8])local_220;
                  local_190 = (char *)local_230;
                  plStack_188 = local_230;
                  local_230 = plVar18;
                  local_228 = plVar8;
                  local_220 = (long *)(auVar19._0_8_ + auVar19._8_8_ * 0x10);
                  FUN_0000bb2c(&local_190);
                }
                local_228 = plVar8;
                if (DAT_00d9a060 < '\0') {
                  iVar5 = Mso::AB::Optimized::ChangeGate::Evaluate();
                  if (iVar5 != 0) goto LAB_00107ae4;
                }
                else if (DAT_00d9a060 != '\0') {
LAB_00107ae4:
                  pppplVar15 = local_1d8;
                  puVar9 = operator_new(0x28);
                  puVar9[2] = 0;
                  *puVar9 = &PTR_FUN_00ccf8b8;
                  puVar9[1] = 0;
                  puVar1 = puVar9 + 3;
                  FUN_000608f0(puVar1,pppplVar15);
                  if (local_228 < local_220) {
                    *local_228 = (long)puVar1;
                    local_228[1] = (long)puVar9;
                    plVar8 = local_228 + 2;
                  }
                  else {
                    lVar13 = (long)local_228 - (long)local_230;
                    uVar11 = (lVar13 >> 4) + 1;
                    if (uVar11 >> 0x3c != 0) goto LAB_001083f4;
                    uVar16 = (long)local_220 - (long)local_230 >> 3;
                    if (uVar16 <= uVar11) {
                      uVar16 = uVar11;
                    }
                    if (0x7fffffffffffffef < (ulong)((long)local_220 - (long)local_230)) {
                      uVar16 = 0xfffffffffffffff;
                    }
                    local_170 = &local_220;
                    auVar19 = FUN_0000baf8(&local_220,uVar16);
                    plVar18 = (long *)(auVar19._0_8_ + lVar13);
                    *plVar18 = (long)puVar1;
                    plVar18[1] = (long)puVar9;
                    plVar8 = plVar18 + 2;
                    plVar18 = (long *)((long)plVar18 - ((long)local_228 - (long)local_230));
                    _memcpy(plVar18,local_230,(long)local_228 - (long)local_230);
                    local_180 = local_230;
                    local_178 = (undefined1  [8])local_220;
                    local_190 = (char *)local_230;
                    plStack_188 = local_230;
                    local_230 = plVar18;
                    local_228 = plVar8;
                    local_220 = (long *)(auVar19._0_8_ + auVar19._8_8_ * 0x10);
                    FUN_0000bb2c(&local_190);
                  }
                  local_228 = plVar8;
                }
                pcVar10 = (char *)FUN_0006092c();
                if (*pcVar10 < '\0') {
                  iVar5 = Mso::AB::Optimized::FeatureGate::Evaluate();
                  if (iVar5 != 0) goto LAB_00107bd8;
                }
                else if (*pcVar10 != '\0') {
LAB_00107bd8:
                  pppplVar15 = local_1d8;
                  puVar9 = operator_new(0x28);
                  puVar9[2] = 0;
                  *puVar9 = &PTR_FUN_00ccf908;
                  puVar9[1] = 0;
                  puVar1 = puVar9 + 3;
                  FUN_00060938(puVar1,pppplVar15);
                  if (local_228 < local_220) {
                    *local_228 = (long)puVar1;
                    local_228[1] = (long)puVar9;
                    plVar8 = local_228 + 2;
                  }
                  else {
                    lVar13 = (long)local_228 - (long)local_230;
                    uVar11 = (lVar13 >> 4) + 1;
                    if (uVar11 >> 0x3c != 0) {
LAB_001083f4:
                    /* WARNING: Subroutine does not return */
                      FUN_00439360();
                    }
                    uVar16 = (long)local_220 - (long)local_230 >> 3;
                    if (uVar16 <= uVar11) {
                      uVar16 = uVar11;
                    }
                    if (0x7fffffffffffffef < (ulong)((long)local_220 - (long)local_230)) {
                      uVar16 = 0xfffffffffffffff;
                    }
                    local_170 = &local_220;
                    auVar19 = FUN_0000baf8(&local_220,uVar16);
                    plVar18 = (long *)(auVar19._0_8_ + lVar13);
                    *plVar18 = (long)puVar1;
                    plVar18[1] = (long)puVar9;
                    plVar8 = plVar18 + 2;
                    plVar18 = (long *)((long)plVar18 - ((long)local_228 - (long)local_230));
                    _memcpy(plVar18,local_230,(long)local_228 - (long)local_230);
                    local_180 = local_230;
                    local_178 = (undefined1  [8])local_220;
                    local_190 = (char *)local_230;
                    plStack_188 = local_230;
                    local_230 = plVar18;
                    local_228 = plVar8;
                    local_220 = (long *)(auVar19._0_8_ + auVar19._8_8_ * 0x10);
                    FUN_0000bb2c(&local_190);
                  }
                  local_228 = plVar8;
                }
                FUN_0006057c(&local_208,param_4,&DAT_00aa57b0);
                local_190 = (char *)DAT_00ab0df0;
                FUN_003e86ac(&plStack_188);
                local_1b0 = DAT_00ab0df8;
                FUN_003e86ac(&local_1a8);
                pcVar10 = (char *)FUN_00060974();
                if (*pcVar10 < '\0') {
                  uVar11 = Mso::AB::Optimized::ChangeGate::Evaluate();
                  if ((uVar11 & 1) == 0) goto LAB_00107d58;
LAB_00107d04:
                  if (local_208 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
                    FUN_009a4668();
                  }
                  iVar5 = (**(code **)(*local_208 + 0x58))();
                  if (iVar5 == 0) {
                    FUN_00108660(&local_288,*(undefined8 *)(param_2 + 0x10),&DAT_00a8e250);
                    if (local_288 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
                      FUN_009a4668();
                    }
                    uVar7 = (**(code **)(*local_288 + 0xd8))();
                    plVar8 = local_288;
                    if (local_288 != (long *)0x0) {
                      local_288 = (long *)0x0;
                      (**(code **)(*plVar8 + 0x10))();
                    }
                    local_260 = (long ****)
                                CONCAT71(local_260._1_7_,
                                         (byte)((ulong)uVar7 >> 0x20) & (int)uVar7 != 0);
                    if (local_208 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
                      FUN_009a4668();
                    }
                    goto LAB_001080c8;
                  }
                  if (local_208 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
                    FUN_009a4668();
                  }
                  (**(code **)(*local_208 + 0x58))();
                  uVar6 = FUN_00060980();
                  local_288 = (long *)CONCAT44(local_288._4_4_,uVar6);
                  FUN_005f834c(&local_210,param_6,&local_288,&local_190);
                }
                else {
                  if (*pcVar10 != '\0') goto LAB_00107d04;
LAB_00107d58:
                  if (local_208 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
                    FUN_009a4668();
                  }
                  iVar5 = (**(code **)(*local_208 + 0x58))();
                  if (iVar5 == 0) {
                    (**(code **)(*plVar14 + 0x40))(&local_288,plVar14,0x1e39a68c,0x80,0);
                    if (local_288 == (long *)0x0) {
                      (**(code **)(*plVar14 + 0x40))(&local_260,plVar14,0x1e39a68b,0x7f,0);
                      pppplVar15 = local_260;
                      bVar3 = local_260 == (long ****)0x0;
                      if (local_260 != (long ****)0x0) {
                        local_260 = (long ****)0x0;
                        (*(code *)(*pppplVar15)[2])();
                      }
                      plVar8 = local_288;
                      if (local_288 != (long *)0x0) goto LAB_001080a8;
                    }
                    else {
                      bVar3 = false;
                      plVar8 = local_288;
LAB_001080a8:
                      local_288 = (long *)0x0;
                      (**(code **)(*plVar8 + 0x10))();
                    }
                    bVar12 = bVar3 ^ 1;
                  }
                  else {
                    bVar12 = 1;
                  }
                  local_260 = (long ****)CONCAT71(local_260._1_7_,bVar12);
                  if (local_208 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
                    FUN_009a4668();
                  }
LAB_001080c8:
                  (**(code **)(*local_208 + 0x58))();
                  uVar6 = FUN_00060980();
                  local_288 = (long *)CONCAT44(local_288._4_4_,uVar6);
                  FUN_000609b0(&local_210,param_6,&local_288,&local_190,&local_1b0,&local_260);
                }
                if (local_1e0 == 0) {
                  local_218 = (long *)0x0;
                }
                else {
                  FUN_00106454(&local_218,&local_1e0,&DAT_00ab0e18);
                }
                local_288 = local_218;
                FUN_00060ae8(&local_238,param_4,&local_288,local_1d8,local_210,&local_230,param_8,
                             param_9);
                FUN_00061438(&local_240,plVar14);
                FUN_000615a0(&local_260,param_10);
                plVar8 = local_240;
                if (local_240 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
                  FUN_009a5674();
                }
                if (*(long **)(param_2 + 0x10) == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
                  FUN_009a5668();
                }
                uVar7 = (**(code **)(**(long **)(param_2 + 0x10) + 0x18))();
                FUN_000616f4(&local_268,&local_1d0,uVar7);
                plVar18 = local_268;
                FUN_002b4d38(&local_288,*(undefined8 *)(param_2 + 0x10));
                FUN_001e8398(&local_248,plVar14,&local_260,&local_1e4,plVar8,plVar18,&local_288);
                if (local_269 < '\0') {
                  operator_delete(plStack_280);
                }
                plVar8 = local_268;
                if (local_268 != (long *)0x0) {
                  local_268 = (long *)0x0;
                  (**(code **)(*plVar8 + 8))();
                }
                if (local_260 != (long ****)0x0) {
                  local_258 = local_260;
                  operator_delete(local_260);
                }
                FUN_001e8784(&local_288);
                FUN_001e87cc(param_1,local_208,local_238,local_210,local_1b8,local_248,local_1f0,
                             local_288);
                plVar8 = local_288;
                if (local_288 != (long *)0x0) {
                  local_288 = (long *)0x0;
                  (**(code **)(*plVar8 + 8))();
                }
                plVar8 = local_248;
                if (local_248 != (long *)0x0) {
                  local_248 = (long *)0x0;
                  (**(code **)(*plVar8 + 0x10))();
                }
                plVar8 = local_240;
                if (local_240 != (long *)0x0) {
                  local_240 = (long *)0x0;
                  (**(code **)(*plVar8 + 8))();
                }
                FUN_000d2a70(&local_238);
                plVar8 = local_218;
                if (local_218 != (long *)0x0) {
                  local_218 = (long *)0x0;
                  (**(code **)(*plVar8 + 0x10))();
                }
                plVar8 = local_210;
                if (local_210 != (long *)0x0) {
                  local_210 = (long *)0x0;
                  (**(code **)(*plVar8 + 0x10))();
                }
                if (local_1a8 != (void *)0x0) {
                  local_1a0 = local_1a8;
                  operator_delete(local_1a8);
                }
                if (plStack_188 != (long *)0x0) {
                  local_180 = plStack_188;
                  operator_delete(plStack_188);
                }
                plVar8 = local_208;
                if (local_208 != (long *)0x0) {
                  local_208 = (long *)0x0;
                  (**(code **)(*plVar8 + 0x10))();
                }
                plVar8 = local_200;
                if (local_200 != (long *)0x0) {
                  local_200 = (long *)0x0;
                  (**(code **)(*plVar8 + 8))();
                }
                plVar8 = local_1f8;
                if (local_1f8 != (long *)0x0) {
                  local_1f8 = (long *)0x0;
                  (**(code **)(*plVar8 + 0x10))();
                }
                local_190 = (char *)&local_230;
                FUN_00132428(&local_190);
              }
              else {
                if (iVar5 != 0) {
                  local_190 = "GetDefaultOpWorkerFactory: Unexpected protocol";
                  FUN_000bfb18(0x1f64630b,0x9d4,10,2,&local_190);
                    /* WARNING: Subroutine does not return */
                  FUN_00438dc4(0x1f851099,0);
                }
                FUN_005f82d4(&local_260,param_4,&DAT_00ab0978);
                if (*(long **)(param_2 + 0x10) == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
                  FUN_009a5668();
                }
                uVar7 = (**(code **)(**(long **)(param_2 + 0x10) + 0x18))();
                pppplVar15 = local_260;
                plVar8 = operator_new(0x30);
                plVar8[2] = 0;
                *plVar8 = (long)&PTR_FUN_00ccf598;
                plVar8[1] = 0;
                local_190 = (char *)FUN_005f3214(plVar8 + 3,uVar7,pppplVar15);
                plStack_280 = (long *)0x0;
                local_278 = (long *)0x0;
                local_288 = (long *)0x0;
                plStack_188 = plVar8;
                FUN_005f8594(&local_288,&local_190,&local_180,1);
                FUN_0005c2a0(&local_190);
                FUN_005f8310(&local_190,*(undefined8 *)(param_2 + 0x10),&DAT_00a8e240);
                if ((long *)local_190 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
                  FUN_009a4668();
                }
                iVar5 = (**(code **)(*(long *)local_190 + 0x28))();
                plVar8 = (long *)local_190;
                if ((long *)local_190 != (long *)0x0) {
                  local_190 = (char *)0x0;
                  (**(code **)(*plVar8 + 0x10))();
                }
                uVar6 = 3;
                if (iVar5 != 1) {
                  uVar6 = 0x14;
                }
                local_190 = (char *)CONCAT44(1,uVar6);
                FUN_003e86ac(&plStack_188);
                if (local_260 == (long ****)0x0) {
                    /* WARNING: Subroutine does not return */
                  FUN_009a4668();
                }
                (*(code *)(*local_260)[0xb])();
                uVar6 = FUN_005f6254();
                local_1b0 = (long *)CONCAT44(local_1b0._4_4_,uVar6);
                FUN_005f834c(&local_1f8,param_6,&local_1b0,&local_190);
                if (local_1e4 == 4) {
                  if (local_260 == (long ****)0x0) {
                    /* WARNING: Subroutine does not return */
                    FUN_009a4668();
                  }
                  iVar5 = (*(code *)(*local_260)[0xb])();
                  if (iVar5 != 1) goto LAB_00107d7c;
                  local_1b0 = (long *)0xba25f3;
                  FUN_000bfb18(0x1e559084,0x9d4,0xf,2,&local_1b0);
                  *param_1 = 0;
                }
                else {
LAB_00107d7c:
                  if (local_1e4 == 0) {
                    if (local_260 == (long ****)0x0) {
                    /* WARNING: Subroutine does not return */
                      FUN_009a4668();
                    }
                    iVar5 = (*(code *)(*local_260)[0xb])();
                    if (iVar5 == 0) {
                      pppplVar15 = local_1d0;
                      if (-1 < local_1b9) {
                        pppplVar15 = (long ****)&local_1d0;
                      }
                      FUN_00060064(&local_1b0,3,pppplVar15);
                      if (local_1f0 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
                        FUN_009a4668();
                      }
                      Measurements::MergeIdentifiers(1,&local_1b0,local_1f0 + 9);
                      if (local_191 < '\0') {
                        operator_delete(local_1a8);
                      }
                    }
                  }
                  if (local_1e0 == 0) {
                    local_200 = (long *)0x0;
                  }
                  else {
                    FUN_005f7984(&local_200,&local_1e0,&DAT_00ab0e28);
                  }
                  local_1b0 = local_200;
                  FUN_005f83a4(&local_208,param_4,&local_1b0,local_1d8,local_1f8,&local_288,param_8,
                               param_9);
                  FUN_00061438(&local_210,plVar14);
                  FUN_000615a0(&local_230,param_10);
                  plVar8 = local_210;
                  if (local_210 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
                    FUN_009a5674();
                  }
                  if (*(long **)(param_2 + 0x10) == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
                    FUN_009a5668();
                  }
                  uVar7 = (**(code **)(**(long **)(param_2 + 0x10) + 0x18))();
                  FUN_000616f4(&local_238,&local_1d0,uVar7);
                  plVar18 = local_238;
                  FUN_002b4d38(&local_1b0,*(undefined8 *)(param_2 + 0x10));
                  FUN_001e8398(&local_218,plVar14,&local_230,&local_1e4,plVar8,plVar18,&local_1b0);
                  if (local_191 < '\0') {
                    operator_delete(local_1a8);
                  }
                  plVar8 = local_238;
                  if (local_238 != (long *)0x0) {
                    local_238 = (long *)0x0;
                    (**(code **)(*plVar8 + 8))();
                  }
                  if (local_230 != (long *)0x0) {
                    local_228 = local_230;
                    operator_delete(local_230);
                  }
                  FUN_001e8784(&local_1b0);
                  FUN_004b9f18(param_1,local_260,local_208,local_1f8,local_1b8,local_218,local_1f0,
                               local_1b0);
                  plVar8 = local_1b0;
                  if (local_1b0 != (long *)0x0) {
                    local_1b0 = (long *)0x0;
                    (**(code **)(*plVar8 + 8))();
                  }
                  plVar8 = local_218;
                  if (local_218 != (long *)0x0) {
                    local_218 = (long *)0x0;
                    (**(code **)(*plVar8 + 0x10))();
                  }
                  plVar8 = local_210;
                  if (local_210 != (long *)0x0) {
                    local_210 = (long *)0x0;
                    (**(code **)(*plVar8 + 8))();
                  }
                  FUN_000d2a70(&local_208);
                  plVar8 = local_200;
                  if (local_200 != (long *)0x0) {
                    local_200 = (long *)0x0;
                    (**(code **)(*plVar8 + 0x10))();
                  }
                }
                plVar8 = local_1f8;
                if (local_1f8 != (long *)0x0) {
                  local_1f8 = (long *)0x0;
                  (**(code **)(*plVar8 + 0x10))();
                }
                if (plStack_188 != (long *)0x0) {
                  local_180 = plStack_188;
                  operator_delete(plStack_188);
                }
                local_190 = (char *)&local_288;
                FUN_00132428(&local_190);
                pppplVar15 = local_260;
                if (local_260 != (long ****)0x0) {
                  local_260 = (long ****)0x0;
                  (*(code *)(*pppplVar15)[2])();
                }
              }
              FUN_001e9f20(&local_1d8);
              plVar8 = local_1b8;
              if (local_1b8 != (long *)0x0) {
                local_1b8 = (long *)0x0;
                (**(code **)(*plVar8 + 0x10))();
              }
              if (local_1b9 < '\0') {
                operator_delete(local_1d0);
              }
            }
            plVar8 = local_1f0;
            if (local_1f0 != (long *)0x0) {
              local_1f0 = (long *)0x0;
              (**(code **)(*plVar8 + 8))();
            }
          }
          (**(code **)(*plVar14 + 0x10))();
          goto LAB_00106d28;
        }
        break;
      }
      iVar17 = iVar2;
    } while (iVar2 != 0);
  }
  local_190 = "GetDefaultOpWorkerFactory: Graph is closed";
  FUN_000bfb18(0x1f64630d,0x9d4,0x32,2,&local_190);
  *param_1 = 0;
LAB_00106d28:
  if (*(long *)PTR____stack_chk_guard_00c8a488 != local_70) {
                    /* WARNING: Subroutine does not return */
    ___stack_chk_fail();
  }
  return;
}


