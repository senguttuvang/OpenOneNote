/* Ghidra pseudocode; inferred types and names; not Microsoft source. */
/* Default Ghidra analysis requested with 600-second per-file limit. Consult analysis log for completion; types remain inferred. */

/* Csi::CreateRevisionManifestScaffold(MsoCF::ExtendedGUID const&, MsoCF::ExtendedGUID const&,
   CsiCell::SerialNumber const&, Csi::CRevisionManifestScaffold**) */

void Csi::CreateRevisionManifestScaffold
               (ExtendedGUID *param_1,ExtendedGUID *param_2,SerialNumber *param_3,
               CRevisionManifestScaffold **param_4)

{
  undefined4 uVar1;
  long *plVar2;
  long lVar3;
  undefined8 uVar4;
  long lVar5;
  long *local_48;
  
  plVar2 = (long *)FUN_001dc12c(0);
  if (plVar2 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
    FUN_00438dc4(0x1d7815cf,0);
  }
  (**(code **)(*plVar2 + 8))();
  uVar1 = *(undefined4 *)(param_1 + 0x10);
  uVar4 = *(undefined8 *)param_1;
  *(undefined8 *)((long)plVar2 + 0x15) = *(undefined8 *)(param_1 + 8);
  *(undefined8 *)((long)plVar2 + 0xd) = uVar4;
  *(undefined4 *)((long)plVar2 + 0x1d) = uVar1;
  uVar1 = *(undefined4 *)(param_2 + 0x10);
  uVar4 = *(undefined8 *)param_2;
  *(undefined8 *)((long)plVar2 + 0x29) = *(undefined8 *)(param_2 + 8);
  *(undefined8 *)((long)plVar2 + 0x21) = uVar4;
  *(undefined4 *)((long)plVar2 + 0x31) = uVar1;
  lVar3 = *(long *)(param_3 + 0x10);
  lVar5 = *(long *)param_3;
  plVar2[0xb] = *(long *)(param_3 + 8);
  plVar2[10] = lVar5;
  plVar2[0xc] = lVar3;
  local_48 = plVar2;
  FUN_001dc4fc(&local_48,param_4);
  plVar2 = local_48;
  local_48 = (long *)0x0;
  if (plVar2 != (long *)0x0) {
    (**(code **)(*plVar2 + 0x10))();
  }
  return;
}


