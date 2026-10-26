/* Ghidra pseudocode; inferred types and names; not Microsoft source. */
/* Default Ghidra analysis requested with 600-second per-file limit. Consult analysis log for completion; types remain inferred. */

/* Csi::FGetCellKnowledge(Csi::IKnowledge*, CsiCell::ICellKnowledge**) */

bool Csi::FGetCellKnowledge(IKnowledge *param_1,ICellKnowledge **param_2)

{
  long *plVar1;
  long *local_28;
  
  local_28 = (long *)0x0;
  if (param_1 != (IKnowledge *)0x0) {
    (**(code **)(*(long *)param_1 + 0x18))(param_1,&DAT_00a95a40,0,&DAT_00a909d8,&local_28);
  }
  FUN_00542d68(&local_28,param_2);
  plVar1 = local_28;
  local_28 = (long *)0x0;
  if (plVar1 != (long *)0x0) {
    (**(code **)(*plVar1 + 0x10))(plVar1);
  }
  return plVar1 != (long *)0x0;
}


