/* Ghidra pseudocode; inferred types and names; not Microsoft source. */
/* Default Ghidra analysis requested with 600-second per-file limit. Consult analysis log for completion; types remain inferred. */

uint FUN_0079e734(ISoapWebService **param_1,undefined8 param_2,undefined8 param_3,undefined8 param_4
                 ,undefined8 param_5)

{
  uint uVar1;
  ISoapWebService *pIVar2;
  
  Mso::WebServices::CreateSoapWebService(param_1);
  pIVar2 = *param_1;
  if (pIVar2 == (ISoapWebService *)0x0) {
    uVar1 = 0x640;
  }
  else {
    (**(code **)(*(long *)pIVar2 + 0x70))(pIVar2,param_4);
    (**(code **)(*(long *)*param_1 + 0x78))(*param_1,param_5);
    uVar1 = (**(code **)(*(long *)*param_1 + 0x18))(*param_1,param_2,param_3,0,0,0);
    uVar1 = uVar1 & (int)uVar1 >> 0x1f;
  }
  return uVar1;
}


