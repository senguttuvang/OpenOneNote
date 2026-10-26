/* Ghidra pseudocode; inferred types and names; not Microsoft source. */
/* Default Ghidra analysis requested with 600-second per-file limit. Consult analysis log for completion; types remain inferred. */

/* Csi::SerializeDataElementPackage(CsiCell::IDataElementPackage*, Csi::ISequentialWriteStream*,
   unsigned short, bool) */

void Csi::SerializeDataElementPackage
               (IDataElementPackage *param_1,ISequentialWriteStream *param_2,ushort param_3,
               bool param_4)

{
  undefined **ppuVar1;
  undefined ***pppuVar2;
  int iVar3;
  long lVar4;
  long *plVar5;
  ulong uVar6;
  long lVar7;
  undefined **local_f8;
  undefined **local_f0;
  undefined1 local_e8;
  undefined4 local_dc;
  undefined ***local_d8 [16];
  long local_58;
  
  local_58 = *(long *)PTR____stack_chk_guard_00c8a488;
  iVar3 = (**(code **)(*(long *)param_1 + 0x58))();
  if (iVar3 == 0) {
    lVar7 = 0;
    uVar6 = 0;
    local_f8 = &PTR_FUN_00cac150;
    local_f0 = &PTR_FUN_00cac190;
    local_e8 = 0;
    local_d8[0] = &local_f0;
    local_d8[1] = (undefined ***)0x0;
    do {
      if (*(long **)((long)local_d8 + lVar7) == (long *)0x0) break;
      lVar4 = (**(code **)(**(long **)((long)local_d8 + lVar7) + 0x10))();
      uVar6 = lVar4 + uVar6;
      lVar7 = lVar7 + 8;
    } while (lVar7 != 0x80);
    if (uVar6 < 0x7f) {
      local_dc = CONCAT22(local_dc._2_2_,(short)((int)uVar6 << 9)) | 0xac;
      (**(code **)(*(long *)param_2 + 0x18))(param_2,&local_dc,2);
    }
    else if (uVar6 < 0x7fff) {
      local_dc = (int)uVar6 << 0x11 | 0xae;
      (**(code **)(*(long *)param_2 + 0x18))(param_2,&local_dc,4);
    }
    else {
      local_dc = 0xfffe00ae;
      (**(code **)(*(long *)param_2 + 0x18))(param_2,&local_dc,4);
      FUN_003bd55c(param_2,uVar6);
    }
    lVar7 = 0;
    do {
      plVar5 = *(long **)((long)local_d8 + lVar7);
      if (plVar5 == (long *)0x0) break;
      (**(code **)(*plVar5 + 8))(plVar5,param_2);
      lVar7 = lVar7 + 8;
    } while (lVar7 != 0x80);
    local_d8[0] = (undefined ***)0x0;
    (**(code **)(*(long *)param_1 + 0x18))(param_1,local_d8);
    local_f8 = (undefined **)0x0;
    while( true ) {
      if (local_d8[0] == (undefined ***)0x0) {
                    /* WARNING: Subroutine does not return */
        FUN_009a49bc();
      }
      iVar3 = (*(code *)(*local_d8[0])[3])(local_d8[0],1,&local_f8,0);
      if (iVar3 == 0) break;
      FUN_00281f20(local_f8,param_2,param_3,param_4,0);
      ppuVar1 = local_f8;
      if (local_f8 != (undefined **)0x0) {
        local_f8 = (undefined **)0x0;
        (**(code **)(*ppuVar1 + 0x10))();
      }
    }
    local_dc = CONCAT31(local_dc._1_3_,0x55);
    (**(code **)(*(long *)param_2 + 0x18))(param_2,&local_dc,1);
    ppuVar1 = local_f8;
    local_f8 = (undefined **)0x0;
    if (ppuVar1 != (undefined **)0x0) {
      (**(code **)(*ppuVar1 + 0x10))();
    }
    pppuVar2 = local_d8[0];
    local_d8[0] = (undefined ***)0x0;
    if (pppuVar2 != (undefined ***)0x0) {
      (*(code *)(*pppuVar2)[2])();
    }
    if (*(long *)PTR____stack_chk_guard_00c8a488 == local_58) {
      return;
    }
  }
  else if (*(long *)PTR____stack_chk_guard_00c8a488 == local_58) {
                    /* WARNING: Could not recover jumptable at 0x0051c6a0. Too many branches */
                    /* WARNING: Treating indirect jump as call */
    (**(code **)(*(long *)param_1 + 0x60))(param_1,param_2,param_4,0);
    return;
  }
                    /* WARNING: Subroutine does not return */
  ___stack_chk_fail();
}


