/* Ghidra pseudocode; inferred types and names; not Microsoft source. */
/* Default Ghidra analysis requested with 600-second per-file limit. Consult analysis log for completion; types remain inferred. */

/* Csi::CreateCellStorageOverHttp(wchar_t const*, wchar_t const*, bool) */

void __thiscall
Csi::CreateCellStorageOverHttp(Csi *this,wchar_t *param_1,wchar_t *param_2,bool param_3)

{
  long *plVar1;
  long *in_x8;
  
  plVar1 = (long *)FUN_0023d100(0,param_1,param_2,param_3);
  if (plVar1 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
    FUN_00438dc4(0x1d7815cf,0);
  }
  (**(code **)(*plVar1 + 8))();
  FUN_0023d464(plVar1,this,param_1,&DAT_00b7c5a8);
  FUN_00736a88(plVar1,param_2);
  *in_x8 = (long)plVar1;
  (**(code **)(*plVar1 + 8))(plVar1);
  (**(code **)(*plVar1 + 0x10))(plVar1);
  return;
}


