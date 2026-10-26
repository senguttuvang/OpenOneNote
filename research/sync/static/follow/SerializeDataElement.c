/* Ghidra pseudocode; inferred types and names; not Microsoft source. */
/* Default Ghidra analysis requested with 600-second per-file limit. Consult analysis log for completion; types remain inferred. */

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

void FUN_00281f20(long *param_1,long *param_2,undefined8 param_3,undefined8 param_4,ulong *param_5)

{
  undefined **ppuVar1;
  undefined **ppuVar2;
  int *piVar3;
  undefined ***pppuVar4;
  int iVar5;
  ulong *puVar6;
  ulong *puVar7;
  ulong uVar8;
  long lVar9;
  long *plVar10;
  long *plVar11;
  ulong uVar12;
  long lVar13;
  undefined8 local_208;
  undefined8 local_200;
  undefined4 local_1f4;
  undefined **local_1f0;
  undefined **local_1e8;
  long *local_1e0;
  undefined **ppuStack_1d8;
  int *local_1d0;
  undefined **local_1c8;
  ulong local_1c0;
  undefined **ppuStack_1b8;
  undefined **local_1b0;
  undefined **ppuStack_1a8;
  undefined **local_1a0;
  undefined **ppuStack_198;
  int *piStack_190;
  int *local_188;
  long *plStack_180;
  undefined1 local_178;
  undefined8 local_170;
  undefined **ppuStack_168;
  undefined4 local_160;
  undefined4 uStack_15c;
  undefined4 uStack_158;
  undefined4 uStack_154;
  undefined4 uStack_150;
  undefined4 uStack_14c;
  undefined4 uStack_148;
  undefined4 uStack_144;
  undefined4 uStack_140;
  undefined4 local_13c;
  undefined4 uStack_138;
  undefined4 uStack_134;
  undefined8 local_130;
  undefined8 uStack_128;
  long *local_120;
  undefined8 local_110;
  undefined **ppuStack_108;
  undefined4 local_100;
  undefined ***local_f8 [16];
  long local_78;
  
  local_78 = *(long *)PTR____stack_chk_guard_00c8a488;
  iVar5 = (**(code **)(*param_1 + 0x58))();
  if (iVar5 == 0) {
    local_1f0 = &PTR_FUN_00cabe10;
    local_1e8 = &PTR_FUN_00ca77e8;
    local_1c8 = &PTR_FUN_00ca9dc8;
    ppuStack_1a8 = &PTR_FUN_00ca29d0;
    puVar7 = (ulong *)&DAT_00a90818;
    if ((int)param_3 != 1) {
      puVar7 = param_5;
    }
    puVar6 = (ulong *)(**(code **)(*param_1 + 0x18))(param_1);
    ppuStack_1d8 = (undefined **)puVar6[1];
    local_1e0 = (long *)*puVar6;
    local_1d0 = (int *)CONCAT44(local_1d0._4_4_,(int)puVar6[2]);
    if (puVar7 == (ulong *)0x0) {
      puVar7 = (ulong *)(**(code **)(*param_1 + 0x28))(param_1);
    }
    ppuStack_1b8 = (undefined **)puVar7[1];
    local_1c0 = *puVar7;
    local_1b0 = (undefined **)puVar7[2];
    uVar8 = (**(code **)(*param_1 + 0x20))(param_1);
    lVar13 = 0;
    uVar12 = 0;
    local_1a0 = (undefined **)(uVar8 & 0xffffffff);
    local_f8[0] = &local_1e8;
    local_f8[1] = &local_1c8;
    local_f8[2] = &ppuStack_1a8;
    local_f8[3] = (undefined ***)0x0;
    do {
      if (*(long **)((long)local_f8 + lVar13) == (long *)0x0) break;
      lVar9 = (**(code **)(**(long **)((long)local_f8 + lVar13) + 0x10))();
      uVar12 = lVar9 + uVar12;
      lVar13 = lVar13 + 8;
    } while (lVar13 != 0x80);
    if (uVar12 < 0x7f) {
      local_170 = (long *)(CONCAT62(local_170._2_6_,(short)((int)uVar12 << 9)) | 0xc);
      (**(code **)(*param_2 + 0x18))(param_2,&local_170,2);
    }
    else if (uVar12 < 0x7fff) {
      local_170 = (long *)(CONCAT44(local_170._4_4_,(int)uVar12 << 0x11) | 0xe);
      (**(code **)(*param_2 + 0x18))(param_2,&local_170,4);
    }
    else {
      local_170 = (long *)CONCAT44(local_170._4_4_,0xfffe000e);
      (**(code **)(*param_2 + 0x18))(param_2,&local_170,4);
      FUN_003bd55c(param_2,uVar12);
    }
    lVar13 = 0;
    do {
      plVar10 = *(long **)((long)local_f8 + lVar13);
      if (plVar10 == (long *)0x0) break;
      (**(code **)(*plVar10 + 8))(plVar10,param_2);
      lVar13 = lVar13 + 8;
    } while (lVar13 != 0x80);
    iVar5 = (**(code **)(*param_1 + 0x20))(param_1);
    if (iVar5 < 4) {
      if (iVar5 == 1) {
        local_200 = (long *)0x0;
        FUN_0052886c(&local_200,param_1);
        plVar10 = local_200;
        iVar5 = (**(code **)(*local_200 + 0x88))(local_200,&local_110,&local_170);
        if (iVar5 != 0) {
          lVar13 = 0;
          uVar12 = 0;
          local_1f0 = &PTR_FUN_00cabe50;
          local_1e8 = &PTR_FUN_00ca77e8;
          local_1c8 = &PTR_FUN_00ca9dc8;
          local_1d0 = (int *)CONCAT44(local_1d0._4_4_,local_100);
          local_1b0 = (undefined **)CONCAT44(uStack_15c,local_160);
          ppuStack_1d8 = ppuStack_108;
          local_1e0 = local_110;
          ppuStack_1b8 = ppuStack_168;
          local_1c0 = (ulong)local_170;
          local_f8[0] = &local_1e8;
          local_f8[1] = &local_1c8;
          local_f8[2] = (undefined ***)0x0;
          do {
            if (*(long **)((long)local_f8 + lVar13) == (long *)0x0) break;
            lVar9 = (**(code **)(**(long **)((long)local_f8 + lVar13) + 0x10))();
            uVar12 = lVar9 + uVar12;
            lVar13 = lVar13 + 8;
          } while (lVar13 != 0x80);
          if (uVar12 < 0x7f) {
            local_208 = (long *)(CONCAT62(local_208._2_6_,(short)((int)uVar12 << 9)) | 0x88);
            (**(code **)(*param_2 + 0x18))(param_2,&local_208,2);
          }
          else if (uVar12 < 0x7fff) {
            local_208 = (long *)(CONCAT44(local_208._4_4_,(int)uVar12 << 0x11) | 0x8a);
            (**(code **)(*param_2 + 0x18))(param_2,&local_208,4);
          }
          else {
            local_208 = (long *)CONCAT44(local_208._4_4_,0xfffe008a);
            (**(code **)(*param_2 + 0x18))(param_2,&local_208,4);
            FUN_003bd55c(param_2,uVar12);
          }
          lVar13 = 0;
          do {
            plVar11 = *(long **)((long)local_f8 + lVar13);
            if (plVar11 == (long *)0x0) break;
            (**(code **)(*plVar11 + 8))(plVar11,param_2);
            lVar13 = lVar13 + 8;
          } while (lVar13 != 0x80);
        }
        local_110 = (long *)0x0;
        (**(code **)(*plVar10 + 0xa8))(plVar10,&local_110);
        uStack_150 = 0;
        uStack_14c = 0;
        ppuStack_168 = (undefined **)0x0;
        local_170 = (long *)0x0;
        uStack_158 = 0;
        uStack_154 = 0;
        local_160 = 0;
        uStack_15c = 0;
        if (local_110 == (long *)0x0) {
LAB_002833a4:
                    /* WARNING: Subroutine does not return */
          FUN_009a49bc();
        }
        while (iVar5 = (**(code **)(*local_110 + 0x18))(local_110,1,&local_170,0),
              plVar11 = local_110, iVar5 != 0) {
          lVar13 = 0;
          uVar12 = 0;
          local_1c0 = CONCAT44(uStack_14c,uStack_150);
          local_1a0 = (undefined **)CONCAT44(local_1a0._4_4_,uStack_138);
          plStack_180 = local_120;
          local_1f0 = &PTR_FUN_00cabe90;
          local_1e8 = &PTR_FUN_00cabed0;
          ppuStack_1b8 = &PTR_FUN_00ca77e8;
          ppuStack_198 = &PTR_FUN_00ca9dc8;
          local_1c8 = (undefined **)CONCAT44(uStack_154,uStack_158);
          local_1d0 = (int *)CONCAT44(uStack_15c,local_160);
          ppuStack_1d8 = ppuStack_168;
          local_1e0 = local_170;
          ppuStack_1a8 = (undefined **)CONCAT44(local_13c,uStack_140);
          local_1b0 = (undefined **)CONCAT44(uStack_144,uStack_148);
          local_188 = (int *)uStack_128;
          piStack_190 = (int *)local_130;
          local_f8[0] = &local_1e8;
          local_f8[1] = &ppuStack_1b8;
          local_f8[2] = &ppuStack_198;
          local_f8[3] = (undefined ***)0x0;
          do {
            if (*(long **)((long)local_f8 + lVar13) == (long *)0x0) break;
            lVar9 = (**(code **)(**(long **)((long)local_f8 + lVar13) + 0x10))();
            uVar12 = lVar9 + uVar12;
            lVar13 = lVar13 + 8;
          } while (lVar13 != 0x80);
          if (uVar12 < 0x7f) {
            local_208 = (long *)(CONCAT62(local_208._2_6_,(short)((int)uVar12 << 9)) | 0x70);
            (**(code **)(*param_2 + 0x18))(param_2,&local_208,2);
          }
          else if (uVar12 < 0x7fff) {
            local_208 = (long *)(CONCAT44(local_208._4_4_,(int)uVar12 << 0x11) | 0x72);
            (**(code **)(*param_2 + 0x18))(param_2,&local_208,4);
          }
          else {
            local_208 = (long *)CONCAT44(local_208._4_4_,0xfffe0072);
            (**(code **)(*param_2 + 0x18))(param_2,&local_208,4);
            FUN_003bd55c(param_2,uVar12);
          }
          lVar13 = 0;
          do {
            plVar11 = *(long **)((long)local_f8 + lVar13);
            if (plVar11 == (long *)0x0) break;
            (**(code **)(*plVar11 + 8))(plVar11,param_2);
            lVar13 = lVar13 + 8;
          } while (lVar13 != 0x80);
          if (local_110 == (long *)0x0) goto LAB_002833a4;
        }
        local_110 = (long *)0x0;
        if (plVar11 != (long *)0x0) {
          (**(code **)(*plVar11 + 0x10))();
        }
        local_110 = (long *)0x0;
        (**(code **)(*plVar10 + 0xb0))(plVar10,&local_110);
        if (local_110 == (long *)0x0) goto LAB_00283580;
        while (iVar5 = (**(code **)(*local_110 + 0x18))(local_110,1,&local_170,0),
              plVar10 = local_110, iVar5 != 0) {
          lVar13 = 0;
          uVar12 = 0;
          local_1d0 = (int *)CONCAT44(local_1d0._4_4_,local_160);
          local_1b0 = (undefined **)CONCAT44(local_1b0._4_4_,uStack_14c);
          piStack_190 = (int *)CONCAT44(uStack_134,uStack_138);
          local_1f0 = &PTR_FUN_00cabf10;
          local_1e8 = &PTR_FUN_00ca77e8;
          local_1c8 = &PTR_FUN_00ca77e8;
          ppuStack_1a8 = &PTR_FUN_00ca9dc8;
          ppuStack_1d8 = ppuStack_168;
          local_1e0 = local_170;
          ppuStack_1b8 = (undefined **)CONCAT44(uStack_150,uStack_154);
          local_1c0 = CONCAT44(uStack_158,uStack_15c);
          ppuStack_198 = (undefined **)CONCAT44(local_13c,uStack_140);
          local_1a0 = (undefined **)CONCAT44(uStack_144,uStack_148);
          local_f8[0] = &local_1e8;
          local_f8[1] = &local_1c8;
          local_f8[2] = &ppuStack_1a8;
          local_f8[3] = (undefined ***)0x0;
          do {
            if (*(long **)((long)local_f8 + lVar13) == (long *)0x0) break;
            lVar9 = (**(code **)(**(long **)((long)local_f8 + lVar13) + 0x10))();
            uVar12 = lVar9 + uVar12;
            lVar13 = lVar13 + 8;
          } while (lVar13 != 0x80);
          if (uVar12 < 0x7f) {
            local_208 = (long *)(CONCAT62(local_208._2_6_,(short)((int)uVar12 << 9)) | 0x68);
            (**(code **)(*param_2 + 0x18))(param_2,&local_208,2);
          }
          else if (uVar12 < 0x7fff) {
            local_208 = (long *)(CONCAT44(local_208._4_4_,(int)uVar12 << 0x11) | 0x6a);
            (**(code **)(*param_2 + 0x18))(param_2,&local_208,4);
          }
          else {
            local_208 = (long *)CONCAT44(local_208._4_4_,0xfffe006a);
            (**(code **)(*param_2 + 0x18))(param_2,&local_208,4);
            FUN_003bd55c(param_2,uVar12);
          }
          lVar13 = 0;
          do {
            plVar10 = *(long **)((long)local_f8 + lVar13);
            if (plVar10 == (long *)0x0) break;
            (**(code **)(*plVar10 + 8))(plVar10,param_2);
            lVar13 = lVar13 + 8;
          } while (lVar13 != 0x80);
          if (local_110 == (long *)0x0) {
LAB_00283580:
                    /* WARNING: Subroutine does not return */
            FUN_009a49bc();
          }
        }
        local_110 = (long *)0x0;
        if (plVar10 != (long *)0x0) {
          (**(code **)(*plVar10 + 0x10))();
        }
        plVar10 = local_200;
        local_200 = (long *)0x0;
        if (plVar10 != (long *)0x0) {
          (**(code **)(*plVar10 + 0x10))();
        }
      }
      else {
        if (iVar5 == 2) {
          local_200 = (long *)0x0;
          FUN_00283e24(&local_200,param_1);
          plVar10 = local_200;
          local_1f0 = &PTR_FUN_00cabf50;
          local_1e8 = &PTR_FUN_00cabf90;
          puVar7 = (ulong *)(**(code **)(*local_200 + 0x80))(local_200);
          lVar13 = 0;
          uVar12 = 0;
          ppuStack_1d8 = (undefined **)puVar7[1];
          local_1e0 = (long *)*puVar7;
          local_f8[0] = &local_1e8;
          local_f8[1] = (undefined ***)0x0;
          do {
            if (*(long **)((long)local_f8 + lVar13) == (long *)0x0) break;
            lVar9 = (**(code **)(**(long **)((long)local_f8 + lVar13) + 0x10))();
            uVar12 = lVar9 + uVar12;
            lVar13 = lVar13 + 8;
          } while (lVar13 != 0x80);
          if (uVar12 < 0x7f) {
            local_170 = (long *)(CONCAT62(local_170._2_6_,(short)((int)uVar12 << 9)) | 0x60);
            (**(code **)(*param_2 + 0x18))(param_2,&local_170,2);
          }
          else if (uVar12 < 0x7fff) {
            local_170 = (long *)(CONCAT44(local_170._4_4_,(int)uVar12 << 0x11) | 0x62);
            (**(code **)(*param_2 + 0x18))(param_2,&local_170,4);
          }
          else {
            local_170 = (long *)CONCAT44(local_170._4_4_,0xfffe0062);
            (**(code **)(*param_2 + 0x18))(param_2,&local_170,4);
            FUN_003bd55c(param_2,uVar12);
          }
          lVar13 = 0;
          do {
            plVar11 = *(long **)((long)local_f8 + lVar13);
            if (plVar11 == (long *)0x0) break;
            (**(code **)(*plVar11 + 8))(plVar11,param_2);
            lVar13 = lVar13 + 8;
          } while (lVar13 != 0x80);
          local_110 = (long *)0x0;
          (**(code **)(*plVar10 + 0x88))(plVar10,&local_110);
          local_13c = 0;
          uStack_138 = 0;
          uStack_144 = 0;
          uStack_140 = 0;
          uStack_14c = 0;
          uStack_148 = 0;
          uStack_154 = 0;
          uStack_150 = 0;
          uStack_15c = 0;
          uStack_158 = 0;
          if (local_110 != (long *)0x0) {
            do {
              iVar5 = (**(code **)(*local_110 + 0x18))(local_110,1,&local_170,0);
              plVar10 = local_110;
              if (iVar5 == 0) {
                local_110 = (long *)0x0;
                if (plVar10 != (long *)0x0) {
                  (**(code **)(*plVar10 + 0x10))();
                }
                plVar10 = local_200;
                local_200 = (long *)0x0;
                if (plVar10 != (long *)0x0) {
                  (**(code **)(*plVar10 + 0x10))();
                }
                goto LAB_002835b8;
              }
              lVar13 = 0;
              uVar12 = 0;
              local_1d0 = (int *)CONCAT44(local_1d0._4_4_,local_160);
              local_1a0 = (undefined **)CONCAT44(uStack_138,local_13c);
              local_1f0 = &PTR_FUN_00cabfd0;
              local_1e8 = &PTR_FUN_00ca77e8;
              local_1c8 = &PTR_FUN_00cabed0;
              ppuStack_1d8 = ppuStack_168;
              local_1e0 = local_170;
              ppuStack_1b8 = (undefined **)CONCAT44(uStack_150,uStack_154);
              local_1c0 = CONCAT44(uStack_158,uStack_15c);
              ppuStack_1a8 = (undefined **)CONCAT44(uStack_140,uStack_144);
              local_1b0 = (undefined **)CONCAT44(uStack_148,uStack_14c);
              local_f8[0] = &local_1e8;
              local_f8[1] = &local_1c8;
              local_f8[2] = (undefined ***)0x0;
              do {
                if (*(long **)((long)local_f8 + lVar13) == (long *)0x0) break;
                lVar9 = (**(code **)(**(long **)((long)local_f8 + lVar13) + 0x10))();
                uVar12 = lVar9 + uVar12;
                lVar13 = lVar13 + 8;
              } while (lVar13 != 0x80);
              if (uVar12 < 0x7f) {
                local_208 = (long *)(CONCAT62(local_208._2_6_,(short)((int)uVar12 << 9)) | 0x38);
                (**(code **)(*param_2 + 0x18))(param_2,&local_208,2);
              }
              else if (uVar12 < 0x7fff) {
                local_208 = (long *)(CONCAT44(local_208._4_4_,(int)uVar12 << 0x11) | 0x3a);
                (**(code **)(*param_2 + 0x18))(param_2,&local_208,4);
              }
              else {
                local_208 = (long *)CONCAT44(local_208._4_4_,0xfffe003a);
                (**(code **)(*param_2 + 0x18))(param_2,&local_208,4);
                FUN_003bd55c(param_2,uVar12);
              }
              lVar13 = 0;
              do {
                plVar10 = *(long **)((long)local_f8 + lVar13);
                if (plVar10 == (long *)0x0) break;
                (**(code **)(*plVar10 + 8))(plVar10,param_2);
                lVar13 = lVar13 + 8;
              } while (lVar13 != 0x80);
            } while (local_110 != (long *)0x0);
          }
                    /* WARNING: Subroutine does not return */
          FUN_009a49bc();
        }
        if (iVar5 == 3) {
          local_170 = (long *)0x0;
          FUN_00285150(&local_170,param_1);
          local_1f0 = &PTR_FUN_00cac010;
          local_1e8 = &PTR_FUN_00ca77e8;
          puVar7 = (ulong *)(**(code **)(*local_170 + 0x80))();
          lVar13 = 0;
          uVar12 = 0;
          ppuStack_1d8 = (undefined **)puVar7[1];
          local_1e0 = (long *)*puVar7;
          local_1d0 = (int *)CONCAT44(local_1d0._4_4_,(int)puVar7[2]);
          local_f8[0] = &local_1e8;
          local_f8[1] = (undefined ***)0x0;
          do {
            if (*(long **)((long)local_f8 + lVar13) == (long *)0x0) break;
            lVar9 = (**(code **)(**(long **)((long)local_f8 + lVar13) + 0x10))();
            uVar12 = lVar9 + uVar12;
            lVar13 = lVar13 + 8;
          } while (lVar13 != 0x80);
          if (uVar12 < 0x7f) {
            local_110 = (long *)(CONCAT62(local_110._2_6_,(short)((int)uVar12 << 9)) | 0x58);
            (**(code **)(*param_2 + 0x18))(param_2,&local_110,2);
          }
          else if (uVar12 < 0x7fff) {
            local_110 = (long *)(CONCAT44(local_110._4_4_,(int)uVar12 << 0x11) | 0x5a);
            (**(code **)(*param_2 + 0x18))(param_2,&local_110,4);
          }
          else {
            local_110 = (long *)CONCAT44(local_110._4_4_,0xfffe005a);
            (**(code **)(*param_2 + 0x18))(param_2,&local_110,4);
            FUN_003bd55c(param_2,uVar12);
          }
          lVar13 = 0;
          do {
            plVar10 = *(long **)((long)local_f8 + lVar13);
            if (plVar10 == (long *)0x0) break;
            (**(code **)(*plVar10 + 8))(plVar10,param_2);
            lVar13 = lVar13 + 8;
          } while (lVar13 != 0x80);
          plVar10 = local_170;
          local_170 = (long *)0x0;
          if (plVar10 != (long *)0x0) {
            (**(code **)(*plVar10 + 0x10))();
          }
        }
      }
    }
    else if (iVar5 < 6) {
      if (iVar5 == 4) {
        local_208 = (long *)0x0;
        FUN_001dd360(&local_208,param_1);
        plVar10 = local_208;
        local_1f0 = &PTR_FUN_00cac050;
        local_1e8 = &PTR_FUN_00ca77e8;
        local_1c8 = &PTR_FUN_00ca77e8;
        puVar7 = (ulong *)(**(code **)(*local_208 + 0x80))(local_208);
        ppuStack_1d8 = (undefined **)puVar7[1];
        local_1e0 = (long *)*puVar7;
        local_1d0 = (int *)CONCAT44(local_1d0._4_4_,(int)puVar7[2]);
        puVar7 = (ulong *)(**(code **)(*plVar10 + 0x88))(plVar10);
        lVar13 = 0;
        uVar12 = 0;
        ppuStack_1b8 = (undefined **)puVar7[1];
        local_1c0 = *puVar7;
        local_1b0 = (undefined **)CONCAT44(local_1b0._4_4_,(int)puVar7[2]);
        local_f8[0] = &local_1e8;
        local_f8[1] = &local_1c8;
        local_f8[2] = (undefined ***)0x0;
        do {
          if (*(long **)((long)local_f8 + lVar13) == (long *)0x0) break;
          lVar9 = (**(code **)(**(long **)((long)local_f8 + lVar13) + 0x10))();
          uVar12 = lVar9 + uVar12;
          lVar13 = lVar13 + 8;
        } while (lVar13 != 0x80);
        if (uVar12 < 0x7f) {
          local_170 = (long *)(CONCAT62(local_170._2_6_,(short)((int)uVar12 << 9)) | 0xd0);
          (**(code **)(*param_2 + 0x18))(param_2,&local_170,2);
        }
        else if (uVar12 < 0x7fff) {
          local_170 = (long *)(CONCAT44(local_170._4_4_,(int)uVar12 << 0x11) | 0xd2);
          (**(code **)(*param_2 + 0x18))(param_2,&local_170,4);
        }
        else {
          local_170 = (long *)CONCAT44(local_170._4_4_,0xfffe00d2);
          (**(code **)(*param_2 + 0x18))(param_2,&local_170,4);
          FUN_003bd55c(param_2,uVar12);
        }
        lVar13 = 0;
        do {
          plVar11 = *(long **)((long)local_f8 + lVar13);
          if (plVar11 == (long *)0x0) break;
          (**(code **)(*plVar11 + 8))(plVar11,param_2);
          lVar13 = lVar13 + 8;
        } while (lVar13 != 0x80);
        local_110 = (long *)0x0;
        (**(code **)(*plVar10 + 0x90))(plVar10,&local_110);
        if (local_110 == (long *)0x0) {
LAB_00282e7c:
                    /* WARNING: Subroutine does not return */
          FUN_009a49bc();
        }
        while (iVar5 = (**(code **)(*local_110 + 0x18))(local_110,1,&local_170,0),
              plVar11 = local_110, iVar5 != 0) {
          lVar13 = 0;
          uVar12 = 0;
          local_1d0 = (int *)CONCAT44(local_1d0._4_4_,local_160);
          local_1b0 = (undefined **)CONCAT44(local_1b0._4_4_,uStack_14c);
          local_1f0 = &PTR_FUN_00cac090;
          local_1e8 = &PTR_FUN_00ca77e8;
          local_1c8 = &PTR_FUN_00ca77e8;
          ppuStack_1d8 = ppuStack_168;
          local_1e0 = local_170;
          ppuStack_1b8 = (undefined **)CONCAT44(uStack_150,uStack_154);
          local_1c0 = CONCAT44(uStack_158,uStack_15c);
          local_f8[0] = &local_1e8;
          local_f8[1] = &local_1c8;
          local_f8[2] = (undefined ***)0x0;
          do {
            if (*(long **)((long)local_f8 + lVar13) == (long *)0x0) break;
            lVar9 = (**(code **)(**(long **)((long)local_f8 + lVar13) + 0x10))();
            uVar12 = lVar9 + uVar12;
            lVar13 = lVar13 + 8;
          } while (lVar13 != 0x80);
          if (uVar12 < 0x7f) {
            local_200 = (long *)(CONCAT62(local_200._2_6_,(short)((int)uVar12 << 9)) | 0x50);
            (**(code **)(*param_2 + 0x18))(param_2,&local_200,2);
          }
          else if (uVar12 < 0x7fff) {
            local_200 = (long *)(CONCAT44(local_200._4_4_,(int)uVar12 << 0x11) | 0x52);
            (**(code **)(*param_2 + 0x18))(param_2,&local_200,4);
          }
          else {
            local_200 = (long *)CONCAT44(local_200._4_4_,0xfffe0052);
            (**(code **)(*param_2 + 0x18))(param_2,&local_200,4);
            FUN_003bd55c(param_2,uVar12);
          }
          lVar13 = 0;
          do {
            plVar11 = *(long **)((long)local_f8 + lVar13);
            if (plVar11 == (long *)0x0) break;
            (**(code **)(*plVar11 + 8))(plVar11,param_2);
            lVar13 = lVar13 + 8;
          } while (lVar13 != 0x80);
          if (local_110 == (long *)0x0) goto LAB_00282e7c;
        }
        local_110 = (long *)0x0;
        if (plVar11 != (long *)0x0) {
          (**(code **)(*plVar11 + 0x10))();
        }
        local_110 = (long *)0x0;
        (**(code **)(*plVar10 + 0x98))(plVar10,&local_110);
        local_200 = (long *)0x0;
        if (local_110 == (long *)0x0) goto LAB_00283014;
        while (iVar5 = (**(code **)(*local_110 + 0x18))(local_110,1,&local_200,&local_170,0),
              plVar10 = local_200, iVar5 != 0) {
          lVar13 = 0;
          uVar12 = 0;
          local_1f0 = &PTR_FUN_00cac0d0;
          local_1e8 = &PTR_FUN_00ca77e8;
          ppuStack_1d8 = ppuStack_168;
          local_1e0 = local_170;
          local_1d0 = (int *)CONCAT44(local_1d0._4_4_,local_160);
          local_f8[0] = &local_1e8;
          local_f8[1] = (undefined ***)0x0;
          do {
            if (*(long **)((long)local_f8 + lVar13) == (long *)0x0) break;
            lVar9 = (**(code **)(**(long **)((long)local_f8 + lVar13) + 0x10))();
            uVar12 = lVar9 + uVar12;
            lVar13 = lVar13 + 8;
          } while (lVar13 != 0x80);
          if (uVar12 < 0x7f) {
            local_1f4 = CONCAT22(local_1f4._2_2_,(short)((int)uVar12 << 9)) | 200;
            (**(code **)(*param_2 + 0x18))(param_2,&local_1f4,2);
          }
          else if (uVar12 < 0x7fff) {
            local_1f4 = (int)uVar12 << 0x11 | 0xca;
            (**(code **)(*param_2 + 0x18))(param_2,&local_1f4,4);
          }
          else {
            local_1f4 = 0xfffe00ca;
            (**(code **)(*param_2 + 0x18))(param_2,&local_1f4,4);
            FUN_003bd55c(param_2,uVar12);
          }
          lVar13 = 0;
          do {
            plVar10 = *(long **)((long)local_f8 + lVar13);
            if (plVar10 == (long *)0x0) break;
            (**(code **)(*plVar10 + 8))(plVar10,param_2);
            lVar13 = lVar13 + 8;
          } while (lVar13 != 0x80);
          if (local_110 == (long *)0x0) {
LAB_00283014:
                    /* WARNING: Subroutine does not return */
            FUN_009a49bc();
          }
        }
        local_200 = (long *)0x0;
        if (plVar10 != (long *)0x0) {
          (**(code **)(*plVar10 + 0x10))();
        }
        plVar10 = local_110;
        local_110 = (long *)0x0;
        if (plVar10 != (long *)0x0) {
          (**(code **)(*plVar10 + 0x10))();
        }
        plVar10 = local_208;
        local_208 = (long *)0x0;
        if (plVar10 != (long *)0x0) {
          (**(code **)(*plVar10 + 0x10))();
        }
      }
      else if (iVar5 == 5) {
        local_f8[0] = (undefined ***)0x0;
        FUN_001e0ff0(local_f8,param_1);
        FUN_0051ae84(local_f8[0],param_2);
        pppuVar4 = local_f8[0];
        local_f8[0] = (undefined ***)0x0;
        if (pppuVar4 != (undefined ***)0x0) {
          (*(code *)(*pppuVar4)[2])();
        }
      }
    }
    else if (iVar5 == 10) {
      local_110 = (long *)0x0;
      FUN_005288e4(&local_110,param_1);
      local_170 = (long *)0x0;
      (**(code **)(*local_110 + 0x80))(local_110,&local_170);
      local_1f0 = &PTR_FUN_00cac110;
      local_1e8 = &PTR_FUN_00ca7828;
      ppuStack_1d8 = (undefined **)0x0;
      local_1e0 = (long *)0x0;
      local_1c8 = (undefined **)0x0;
      local_1d0 = (int *)0x0;
      local_1c0 = local_1c0 & 0xffffffffffffff00;
      FUN_0018e78c(&local_1c8,local_170);
      local_1c0 = local_1c0 & 0xffffffffffffff00;
      (*(code *)local_1f0[2])(&local_1f0,local_f8,0x10);
      lVar13 = 0;
      uVar12 = 0;
      do {
        if (*(long **)((long)local_f8 + lVar13) == (long *)0x0) break;
        lVar9 = (**(code **)(**(long **)((long)local_f8 + lVar13) + 0x10))();
        uVar12 = lVar9 + uVar12;
        lVar13 = lVar13 + 8;
      } while (lVar13 != 0x80);
      if (uVar12 < 0x7f) {
        local_200 = (long *)(CONCAT62(local_200._2_6_,(short)((int)uVar12 << 9)) | 0x10);
        (**(code **)(*param_2 + 0x18))(param_2,&local_200,2);
      }
      else if (uVar12 < 0x7fff) {
        local_200 = (long *)(CONCAT44(local_200._4_4_,(int)uVar12 << 0x11) | 0x12);
        (**(code **)(*param_2 + 0x18))(param_2,&local_200,4);
      }
      else {
        local_200 = (long *)CONCAT44(local_200._4_4_,0xfffe0012);
        (**(code **)(*param_2 + 0x18))(param_2,&local_200,4);
        FUN_003bd55c(param_2,uVar12);
      }
      lVar13 = 0;
      do {
        plVar10 = *(long **)((long)local_f8 + lVar13);
        if (plVar10 == (long *)0x0) break;
        (**(code **)(*plVar10 + 8))(plVar10,param_2);
        lVar13 = lVar13 + 8;
      } while (lVar13 != 0x80);
      ppuVar1 = local_1c8;
      local_1f0 = &PTR_FUN_00cac110;
      local_1e8 = &PTR_FUN_00ca7828;
      local_1c8 = (undefined **)0x0;
      if (ppuVar1 != (undefined **)0x0) {
        (**(code **)(*ppuVar1 + 0x10))();
      }
      piVar3 = local_1d0;
      local_1d0 = (int *)0x0;
      if (piVar3 != (int *)0x0) {
        LOAcquire();
        iVar5 = *piVar3;
        *piVar3 = iVar5 + -1;
        LORelease();
        if (iVar5 + -1 < 1) {
          MsoCF::IAtom::Release_Core();
        }
      }
      ppuVar1 = ppuStack_1d8;
      ppuStack_1d8 = (undefined **)0x0;
      if (ppuVar1 != (undefined **)0x0) {
        LOAcquire();
        iVar5 = *(int *)ppuVar1;
        *(int *)ppuVar1 = iVar5 + -1;
        LORelease();
        if (iVar5 + -1 < 1) {
          MsoCF::IAtom::Release_Core();
        }
      }
      plVar10 = local_1e0;
      local_1e0 = (long *)0x0;
      if (plVar10 != (long *)0x0) {
        (**(code **)(*plVar10 + 0x10))();
      }
      plVar10 = local_170;
      local_170 = (long *)0x0;
      if (plVar10 != (long *)0x0) {
        (**(code **)(*plVar10 + 0x10))();
      }
      plVar10 = local_110;
      local_110 = (long *)0x0;
      if (plVar10 != (long *)0x0) {
        (**(code **)(*plVar10 + 0x10))();
      }
    }
    else if (iVar5 == 6) {
      local_200 = (long *)0x0;
      FUN_0027e0c0(&local_200,param_1);
      plVar10 = local_200;
      ppuVar2 = _UNK_00a8b418;
      ppuVar1 = _DAT_00a8b410;
      local_160 = SUB84(_UNK_00a8b418,0);
      uStack_15c = (undefined4)((ulong)_UNK_00a8b418 >> 0x20);
      ppuStack_168 = _DAT_00a8b410;
      (**(code **)(*local_200 + 0x80))(local_200,&local_170);
      local_110 = (long *)0x0;
      (**(code **)(*plVar10 + 0x88))(plVar10,&local_110);
      local_1f0 = &PTR_FUN_00cac1d0;
      local_1e8 = &PTR_FUN_00ca77e8;
      local_1c8 = &PTR_FUN_00ca29d0;
      ppuStack_1b8 = &PTR_FUN_00ca2980;
      ppuStack_1a8 = ppuVar2;
      local_1b0 = ppuVar1;
      local_1a0 = &PTR_FUN_00ca7828;
      piStack_190 = (int *)0x0;
      ppuStack_198 = (undefined **)0x0;
      plStack_180 = (long *)0x0;
      local_188 = (int *)0x0;
      local_178 = 0;
      puVar7 = (ulong *)(**(code **)(*plVar10 + 0x78))(plVar10);
      ppuStack_1d8 = (undefined **)puVar7[1];
      local_1e0 = (long *)*puVar7;
      local_1d0 = (int *)CONCAT44(local_1d0._4_4_,(int)puVar7[2]);
      local_1c0 = (ulong)local_170;
      ppuStack_1a8 = (undefined **)CONCAT44(uStack_15c,local_160);
      local_1b0 = ppuStack_168;
      FUN_0018e78c(&plStack_180,local_110);
      local_178 = 0;
      (*(code *)local_1f0[2])(&local_1f0,local_f8,0x10);
      lVar13 = 0;
      uVar12 = 0;
      do {
        if (*(long **)((long)local_f8 + lVar13) == (long *)0x0) break;
        lVar9 = (**(code **)(**(long **)((long)local_f8 + lVar13) + 0x10))();
        uVar12 = lVar9 + uVar12;
        lVar13 = lVar13 + 8;
      } while (lVar13 != 0x80);
      if (uVar12 < 0x7fff) {
        local_208 = (long *)(CONCAT44(local_208._4_4_,(int)uVar12 << 0x11) | 0x352);
        (**(code **)(*param_2 + 0x18))(param_2,&local_208,4);
      }
      else {
        local_208 = (long *)CONCAT44(local_208._4_4_,0xfffe0352);
        (**(code **)(*param_2 + 0x18))(param_2,&local_208,4);
        FUN_003bd55c(param_2,uVar12);
      }
      lVar13 = 0;
      do {
        plVar10 = *(long **)((long)local_f8 + lVar13);
        if (plVar10 == (long *)0x0) break;
        (**(code **)(*plVar10 + 8))(plVar10,param_2);
        lVar13 = lVar13 + 8;
      } while (lVar13 != 0x80);
      plVar10 = plStack_180;
      local_1f0 = &PTR_FUN_00cac1d0;
      local_1a0 = &PTR_FUN_00ca7828;
      plStack_180 = (long *)0x0;
      if (plVar10 != (long *)0x0) {
        (**(code **)(*plVar10 + 0x10))();
      }
      piVar3 = local_188;
      local_188 = (int *)0x0;
      if (piVar3 != (int *)0x0) {
        LOAcquire();
        iVar5 = *piVar3;
        *piVar3 = iVar5 + -1;
        LORelease();
        if (iVar5 + -1 < 1) {
          MsoCF::IAtom::Release_Core();
        }
      }
      piVar3 = piStack_190;
      piStack_190 = (int *)0x0;
      if (piVar3 != (int *)0x0) {
        LOAcquire();
        iVar5 = *piVar3;
        *piVar3 = iVar5 + -1;
        LORelease();
        if (iVar5 + -1 < 1) {
          MsoCF::IAtom::Release_Core();
        }
      }
      ppuVar1 = ppuStack_198;
      ppuStack_198 = (undefined **)0x0;
      if (ppuVar1 != (undefined **)0x0) {
        (**(code **)(*ppuVar1 + 0x10))();
      }
      plVar10 = local_110;
      local_110 = (long *)0x0;
      if (plVar10 != (long *)0x0) {
        (**(code **)(*plVar10 + 0x10))();
      }
      plVar10 = local_200;
      local_200 = (long *)0x0;
      if (plVar10 != (long *)0x0) {
        (**(code **)(*plVar10 + 0x10))();
      }
    }
LAB_002835b8:
    local_f8[0] = (undefined ***)CONCAT71(local_f8[0]._1_7_,5);
    (**(code **)(*param_2 + 0x18))(param_2,local_f8,1);
    if (*(long *)PTR____stack_chk_guard_00c8a488 == local_78) {
      return;
    }
  }
  else if (*(long *)PTR____stack_chk_guard_00c8a488 == local_78) {
                    /* WARNING: Could not recover jumptable at 0x00281fc0. Too many branches */
                    /* WARNING: Treating indirect jump as call */
    (**(code **)(*param_1 + 0x60))(param_1,param_2,param_4,param_3);
    return;
  }
                    /* WARNING: Subroutine does not return */
  ___stack_chk_fail();
}


