/* Ghidra pseudocode; inferred types and names; not Microsoft source. */
/* Default Ghidra analysis requested with 600-second per-file limit. Consult analysis log for completion; types remain inferred. */

void FUN_003a3ee8(int *param_1,undefined8 param_2,long *param_3,long *param_4,int param_5)

{
  ulonglong uVar1;
  int iVar2;
  undefined **ppuVar3;
  long lVar4;
  undefined8 uVar5;
  long lVar6;
  undefined1 extraout_w1;
  undefined8 *****pppppuVar7;
  undefined8 *****pppppuVar8;
  undefined8 *****pppppuVar9;
  undefined8 ****ppppuVar10;
  undefined1 auVar11 [16];
  undefined **local_158;
  char *pcStack_150;
  undefined1 local_148;
  undefined1 uStack_147;
  undefined2 uStack_146;
  undefined4 uStack_144;
  void *local_140;
  undefined8 local_138;
  long lStack_130;
  char *local_128;
  undefined **local_120;
  char *local_118;
  undefined1 local_110 [2];
  undefined2 local_10e;
  undefined8 *****local_108;
  undefined8 local_100;
  long lStack_f8;
  uint local_f0;
  char local_ec;
  long local_e8;
  char local_e0;
  long local_d8;
  char local_d0;
  void *local_98;
  char local_81;
  char local_80;
  long local_58;
  
  local_58 = *(long *)PTR____stack_chk_guard_00c8a488;
  *param_1 = 4;
  param_1[4] = 0;
  param_1[5] = 0;
  *(long *)(param_1 + 2) = 0;
  *(undefined1 *)(param_1 + 0xe) = 0;
  param_1[8] = 0;
  param_1[9] = 0;
  param_1[6] = 0;
  param_1[7] = 0;
  *(undefined8 *)((long)param_1 + 0x29) = 0;
  *(undefined8 *)((long)param_1 + 0x21) = 0;
  FUN_00001eb8(param_1 + 0x10,"");
  FUN_00001eb8(param_1 + 0x16,"");
  FUN_00001eb8(param_1 + 0x1c,"");
  FUN_00001eb8(param_1 + 0x22,"");
  FUN_00001eb8(param_1 + 0x28,"");
  auVar11 = FUN_000b3c6c(0x1e05c700,param_2);
  ppuVar3 = auVar11._0_8_;
  local_118 = (char *)CONCAT71(local_118._1_7_,auVar11[8]);
  local_120 = ppuVar3;
  if ((auVar11._8_8_ & 1) != 0) {
    lVar4 = std::chrono::system_clock::now();
    lVar4 = lVar4 - (long)ppuVar3;
    lVar6 = lVar4 / 1000000;
    if ((ulong)(lVar4 / 1000) < 1000 && 999 < lVar4) {
      lVar6 = 1;
    }
    *(long *)(param_1 + 10) = lVar6;
    uVar5 = FUN_006c6fb4(0x1e285820,param_2,&local_120);
    *(undefined8 *)(param_1 + 0xc) = uVar5;
    *(undefined1 *)(param_1 + 0xe) = extraout_w1;
  }
  param_3 = (long *)*param_3;
  if ((param_3 == (long *)0x0) || (*param_4 == 0)) {
    local_128 = 
    "HostNotifications::QueryRtcStatus: failed to get rtc status because could not get rtcConnection or rtcConnectionManager"
    ;
    local_148 = *param_4 != 0;
    local_120 = &PTR_DAT_00c8b158;
    local_118 = "RtcConnection";
    local_110[0] = param_3 != (long *)0x0;
    local_10e = 4;
    local_100 = 0;
    lStack_f8 = 0;
    local_108 = (undefined8 *****)0x0;
    local_158 = &PTR_DAT_00c8b158;
    pcStack_150 = "RtcConnectionManager";
    uStack_146 = 4;
    local_138 = 0;
    lStack_130 = 0;
    local_140 = (void *)0x0;
    FUN_000dcfe8(0x1e3515a0,0x1a1,0xf,2,&local_128,param_2,&local_120,&local_158);
    local_158 = &PTR_DAT_00c8b158;
    if (lStack_130 < 0) {
      operator_delete(local_140);
    }
    local_120 = &PTR_DAT_00c8b158;
    if (lStack_f8 < 0) {
      operator_delete(local_108);
    }
  }
  else {
    iVar2 = (**(code **)(*param_3 + 0x10))();
    *param_1 = iVar2;
    if ((long *)*param_4 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
      FUN_009a4668();
    }
    auVar11 = (**(code **)(*(long *)*param_4 + 0x70))();
    if ((auVar11._8_8_ & 1) != 0) {
      lVar4 = std::chrono::system_clock::now();
      lVar4 = lVar4 - auVar11._0_8_;
      lVar6 = lVar4 / 1000000;
      if ((ulong)(lVar4 / 1000) < 1000 && 999 < lVar4) {
        lVar6 = 1;
      }
      *(long *)(param_1 + 6) = lVar6;
    }
    if (*param_1 - 1U < 2) {
      if ((long *)*param_4 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
        FUN_009a4668();
      }
      auVar11 = (**(code **)(*(long *)*param_4 + 0x68))();
      if ((auVar11._8_8_ & 1) != 0) {
        lVar4 = std::chrono::system_clock::now();
        lVar4 = lVar4 - auVar11._0_8_;
        lVar6 = lVar4 / 1000000;
        if ((ulong)(lVar4 / 1000) < 1000 && 999 < lVar4) {
          lVar6 = 1;
        }
        *(long *)(param_1 + 2) = lVar6;
      }
    }
    else if (*param_1 == 0) {
      if ((long *)*param_4 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
        FUN_009a4668();
      }
      auVar11 = (**(code **)(*(long *)*param_4 + 0x60))();
      if ((auVar11._8_8_ & 1) != 0) {
        lVar4 = std::chrono::system_clock::now();
        lVar4 = lVar4 - auVar11._0_8_;
        lVar6 = lVar4 / 1000000;
        if ((ulong)(lVar4 / 1000) < 1000 && 999 < lVar4) {
          lVar6 = 1;
        }
        *(long *)(param_1 + 4) = lVar6;
      }
    }
    if (param_5 != 0) {
      FUN_000b5a9c(&local_120,0x1e05c6df,param_2);
      pppppuVar9 = &local_108;
      if (local_108 != (undefined8 *****)0x0) {
        pppppuVar7 = &local_108;
        pppppuVar8 = local_108;
        do {
          lVar6 = 8;
          if (0 < *(int *)(pppppuVar8 + 4)) {
            lVar6 = 0;
            pppppuVar7 = pppppuVar8;
          }
          pppppuVar8 = *(undefined8 ******)((long)pppppuVar8 + lVar6);
        } while (pppppuVar8 != (undefined8 *****)0x0);
        if ((undefined8 ******)pppppuVar7 != &local_108) {
          if (*(int *)(pppppuVar7 + 4) < 2) {
            pppppuVar9 = pppppuVar7;
          }
        }
      }
      if (local_ec == '\x01') {
        std::to_string(local_f0);
      }
      else {
        FUN_00001eb8(&local_158,"");
      }
      if (*(char *)((long)param_1 + 0x57) < '\0') {
        operator_delete(*(void **)(param_1 + 0x10));
      }
      *(char **)(param_1 + 0x12) = pcStack_150;
      *(undefined ***)(param_1 + 0x10) = local_158;
      *(ulong *)(param_1 + 0x14) =
           CONCAT44(uStack_144,CONCAT22(uStack_146,CONCAT11(uStack_147,local_148)));
      if (local_e0 == '\x01') {
        lVar6 = std::chrono::system_clock::now();
        lVar6 = lVar6 - local_e8;
        uVar1 = lVar6 / 1000000;
        if ((ulong)(lVar6 / 1000) < 1000 && 999 < lVar6) {
          uVar1 = 1;
        }
        std::to_string(uVar1);
      }
      else {
        FUN_00001eb8(&local_158,"");
      }
      if (*(char *)((long)param_1 + 0x6f) < '\0') {
        operator_delete(*(void **)(param_1 + 0x16));
      }
      *(char **)(param_1 + 0x18) = pcStack_150;
      *(undefined ***)(param_1 + 0x16) = local_158;
      *(ulong *)(param_1 + 0x1a) =
           CONCAT44(uStack_144,CONCAT22(uStack_146,CONCAT11(uStack_147,local_148)));
      if (local_d0 == '\x01') {
        lVar6 = std::chrono::system_clock::now();
        lVar6 = lVar6 - local_d8;
        uVar1 = lVar6 / 1000000;
        if ((ulong)(lVar6 / 1000) < 1000 && 999 < lVar6) {
          uVar1 = 1;
        }
        std::to_string(uVar1);
      }
      else {
        FUN_00001eb8(&local_158,"");
      }
      if (*(char *)((long)param_1 + 0x87) < '\0') {
        operator_delete(*(void **)(param_1 + 0x1c));
      }
      *(char **)(param_1 + 0x1e) = pcStack_150;
      *(undefined ***)(param_1 + 0x1c) = local_158;
      *(ulong *)(param_1 + 0x20) =
           CONCAT44(uStack_144,CONCAT22(uStack_146,CONCAT11(uStack_147,local_148)));
      if ((undefined8 ******)pppppuVar9 == &local_108) {
        FUN_00001eb8(&local_158,"");
      }
      else {
        ppppuVar10 = pppppuVar9[7];
        lVar6 = std::chrono::system_clock::now();
        lVar6 = lVar6 - (long)ppppuVar10;
        uVar1 = lVar6 / 1000000;
        if ((ulong)(lVar6 / 1000) < 1000 && 999 < lVar6) {
          uVar1 = 1;
        }
        std::to_string(uVar1);
      }
      if (*(char *)((long)param_1 + 0x9f) < '\0') {
        operator_delete(*(void **)(param_1 + 0x22));
      }
      *(char **)(param_1 + 0x24) = pcStack_150;
      *(undefined ***)(param_1 + 0x22) = local_158;
      *(ulong *)(param_1 + 0x26) =
           CONCAT44(uStack_144,CONCAT22(uStack_146,CONCAT11(uStack_147,local_148)));
      if ((undefined8 ******)pppppuVar9 == &local_108) {
        FUN_00001eb8(&local_158,"");
      }
      else {
        ppppuVar10 = pppppuVar9[8];
        lVar6 = std::chrono::system_clock::now();
        lVar6 = lVar6 - (long)ppppuVar10;
        uVar1 = lVar6 / 1000000;
        if ((ulong)(lVar6 / 1000) < 1000 && 999 < lVar6) {
          uVar1 = 1;
        }
        std::to_string(uVar1);
      }
      if (*(char *)((long)param_1 + 0xb7) < '\0') {
        operator_delete(*(void **)(param_1 + 0x28));
      }
      *(char **)(param_1 + 0x2a) = pcStack_150;
      *(undefined ***)(param_1 + 0x28) = local_158;
      *(ulong *)(param_1 + 0x2c) =
           CONCAT44(uStack_144,CONCAT22(uStack_146,CONCAT11(uStack_147,local_148)));
      if ((local_80 == '\x01') && (local_81 < '\0')) {
        operator_delete(local_98);
      }
      FUN_0001be9c(local_110,local_108);
    }
  }
  if (*(long *)PTR____stack_chk_guard_00c8a488 != local_58) {
                    /* WARNING: Subroutine does not return */
    ___stack_chk_fail();
  }
  return;
}


