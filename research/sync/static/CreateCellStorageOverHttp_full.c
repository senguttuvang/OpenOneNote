/* Ghidra pseudocode; inferred types and names; not Microsoft source. */
/* Default Ghidra analysis requested with 600-second per-file limit. Consult analysis log for completion; types remain inferred. */

/* Csi::CreateCellStorageOverHttp(wchar_t const*, CsiCell::ICellStorage**, _GUID const&,
   Csi::IWebServiceSubRequestUserManager*, Csi::IWebServiceRequest*, wchar_t const*, bool) */

void Csi::CreateCellStorageOverHttp
               (wchar_t *param_1,ICellStorage **param_2,_GUID *param_3,
               IWebServiceSubRequestUserManager *param_4,IWebServiceRequest *param_5,
               wchar_t *param_6,bool param_7)

{
  ICellStorage *pIVar1;
  ICellStorage *pIVar2;
  
  pIVar1 = (ICellStorage *)FUN_0023d100(0);
  if (pIVar1 == (ICellStorage *)0x0) {
                    /* WARNING: Subroutine does not return */
    FUN_00438dc4(0x1d7815cf,0);
  }
  (**(code **)(*(long *)pIVar1 + 8))();
  FUN_0023d464(pIVar1,param_1,param_6,param_3);
  if ((param_4 != (IWebServiceSubRequestUserManager *)0x0) && (param_5 != (IWebServiceRequest *)0x0)
     ) {
    pIVar2 = pIVar1 + 0x10;
    (**(code **)(*(long *)pIVar2 + 8))(pIVar2);
    (**(code **)(*(long *)pIVar2 + 0x18))(pIVar2,param_4,param_5,0,0);
    (**(code **)(*(long *)pIVar2 + 0x10))(pIVar2);
  }
  if (param_7) {
    GetCellStorageMultiRoundTrip(pIVar1,(IMultiRoundTripSuspend *)0x0,param_2);
  }
  else if (param_2 != (ICellStorage **)0x0) {
    *param_2 = pIVar1;
    (**(code **)(*(long *)pIVar1 + 8))(pIVar1);
  }
  (**(code **)(*(long *)pIVar1 + 0x10))(pIVar1);
  return;
}


