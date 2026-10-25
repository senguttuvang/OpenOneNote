/* Ghidra pseudocode; inferred types and names; not Microsoft source. */
/* No whole-program analysis. Sample cannot establish complete behavior. */

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

void ONPageView_method_10026dfa8(long param_1)

{
  undefined8 *puVar1;
  long lVar2;
  undefined8 uVar3;
  double dVar4;
  double dVar5;
  undefined8 uStack_d0;
  undefined8 uStack_c8;
  undefined8 uStack_c0;
  undefined8 uStack_b8;
  undefined8 uStack_b0;
  undefined8 uStack_a8;
  undefined8 uStack_a0;
  undefined8 uStack_98;
  undefined8 uStack_90;
  undefined8 uStack_88;
  undefined8 uStack_80;
  undefined8 uStack_78;
  double dStack_70;
  double dStack_68;
  undefined8 uStack_60;
  undefined8 uStack_58;
  undefined8 uStack_50;
  undefined8 uStack_48;
  undefined8 uStack_40;
  undefined8 uStack_38;
  
  lVar2 = (long)_DAT_1017818fc;
  dVar5 = *(double *)(param_1 + lVar2);
  _CGAffineTransformMakeScale(&uStack_60,dVar5 * _UNK_10131b6b8,dVar5 * _UNK_10131b6b8);
  dStack_70 = -*(double *)(param_1 + _DAT_101781900) / dVar5;
  dStack_68 = -((double *)(param_1 + _DAT_101781900))[1] / dVar5;
  uVar3 = func_0x00010026e114(&dStack_70);
  uStack_c8 = uStack_58;
  uStack_d0 = uStack_60;
  uStack_b8 = uStack_48;
  uStack_c0 = uStack_50;
  uStack_a8 = uStack_38;
  uStack_b0 = uStack_40;
  _CGAffineTransformTranslate(&uStack_a0,uVar3,dVar5,&uStack_d0);
  puVar1 = (undefined8 *)(param_1 + _DAT_101781904);
  puVar1[1] = uStack_98;
  *puVar1 = uStack_a0;
  puVar1[3] = uStack_88;
  puVar1[2] = uStack_90;
  puVar1[5] = uStack_78;
  puVar1[4] = uStack_80;
  uStack_c8 = uStack_58;
  uStack_d0 = uStack_60;
  uStack_b8 = uStack_48;
  uStack_c0 = uStack_50;
  uStack_a8 = uStack_38;
  uStack_b0 = uStack_40;
  dVar4 = 1.0 / *(double *)(param_1 + lVar2);
  _CGAffineTransformScale(&uStack_a0,dVar4,dVar4,&uStack_d0);
  puVar1 = (undefined8 *)(param_1 + _DAT_101781908);
  puVar1[1] = uStack_98;
  *puVar1 = uStack_a0;
  puVar1[3] = uStack_88;
  puVar1[2] = uStack_90;
  puVar1[5] = uStack_78;
  puVar1[4] = uStack_80;
  _CGAffineTransformMakeScale
            (&uStack_a0,*(undefined8 *)(param_1 + lVar2),*(undefined8 *)(param_1 + lVar2));
  puVar1 = (undefined8 *)(param_1 + _DAT_10178190c);
  puVar1[1] = uStack_98;
  *puVar1 = uStack_a0;
  puVar1[3] = uStack_88;
  puVar1[2] = uStack_90;
  puVar1[5] = uStack_78;
  puVar1[4] = uStack_80;
  uStack_c8 = puVar1[1];
  uStack_d0 = *puVar1;
  uStack_b8 = puVar1[3];
  uStack_c0 = puVar1[2];
  uStack_a8 = puVar1[5];
  uStack_b0 = puVar1[4];
  _CGAffineTransformTranslate(&uStack_a0,uVar3,dVar5,&uStack_d0);
  puVar1[1] = uStack_98;
  *puVar1 = uStack_a0;
  puVar1[3] = uStack_88;
  puVar1[2] = uStack_90;
  puVar1[5] = uStack_78;
  puVar1[4] = uStack_80;
  return;
}


