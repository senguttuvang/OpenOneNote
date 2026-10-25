/* Ghidra pseudocode; inferred types and names; not Microsoft source. */
/* No whole-program analysis. Sample cannot establish complete behavior. */

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

ulong ONPageView_method_10026dbe8
                (undefined8 param_1,undefined8 param_2,undefined8 param_3,undefined8 param_4)

{
  undefined *puVar1;
  undefined8 uVar2;
  long *plVar3;
  long *plVar4;
  ulong uVar5;
  undefined8 uVar6;
  undefined8 extraout_x1;
  undefined8 extraout_x1_00;
  undefined8 extraout_x1_01;
  long lVar7;
  long lVar8;
  long lVar9;
  float fVar10;
  double extraout_d0;
  undefined1 auVar11 [16];
  long *plStack_60;
  undefined8 uStack_58;
  undefined *puStack_50;
  ulong uStack_48;
  
  puStack_50 = PTR_PTR_101780cc8;
  uStack_58 = param_1;
  auVar11 = _objc_msgSendSuper2(*(undefined8 *)PTR__NSZeroRect_10157b410,
                                *(undefined8 *)(PTR__NSZeroRect_10157b410 + 8),
                                *(undefined8 *)(PTR__NSZeroRect_10157b410 + 0x10),
                                *(undefined8 *)(PTR__NSZeroRect_10157b410 + 0x18),&uStack_58,
                                PTR_s_initWithFrame__101775bc8);
  uVar5 = auVar11._0_8_;
  if (uVar5 == 0) {
    return 0;
  }
  *(undefined8 *)(uVar5 + (long)_DAT_101781914) = param_3;
  uStack_48 = uVar5;
  func_0x0001010ffcc0(uVar5,auVar11._8_8_,1);
  fVar10 = (float)func_0x0001000c0730();
  func_0x000101106540((double)fVar10,uVar5);
  func_0x000101103aa0(uVar5,extraout_x1,0);
  auVar11 = func_0x0001010ebee0(PTR__OBJC_CLASS___NSNotificationCenter_10177fcc0);
  uVar2 = auVar11._0_8_;
  func_0x0001010e6380(uVar2,auVar11._8_8_,uVar5,PTR_s_pageMouseCursorDidUpdate__101771468,
                      PTR_PTR_10158af48,0);
  func_0x0001010e6380(uVar2,extraout_x1_00,uVar5,PTR_s_onPageTooltipUpdateNotification__101771470,
                      &PTR____CFConstantStringClassReference_101738fc8,0);
  auVar11 = func_0x00010110cda0(uVar5);
  puVar1 = PTR_s_pressedEnterOnPage__101771478;
  uVar6 = auVar11._0_8_;
  func_0x0001010e6380(uVar2,auVar11._8_8_,uVar5,PTR_s_pressedEnterOnPage__101771478,
                      PTR_PTR_10159ed28,uVar6);
  func_0x0001010e6380(uVar2,extraout_x1_01,uVar5,puVar1,PTR_PTR_10159ed38,uVar6);
  auVar11 = _objc_alloc(PTR_PTR_10177feb0);
  auVar11 = func_0x0001010f1d80(auVar11._0_8_,auVar11._8_8_,uVar6,uVar5);
  *(long *)(uVar5 + (long)_DAT_101781918) = auVar11._0_8_;
  func_0x0001010e6380(uVar2,auVar11._8_8_,uVar5,PTR_s_onPageShowContextMenuNotificatio_101771480,
                      &PTR____CFConstantStringClassReference_101738fe8,uVar6);
  auVar11 = _objc_alloc_init(PTR_PTR_10177feb8);
  *(long *)(uVar5 + (long)_DAT_10178191c) = auVar11._0_8_;
  func_0x000101100ac0(auVar11._0_8_,auVar11._8_8_,uVar5);
  uVar2 = _objc_alloc_init(PTR_PTR_10177fec0);
  *(undefined8 *)(uVar5 + (long)_DAT_101781920) = uVar2;
  *(undefined1 *)(uVar5 + (long)_DAT_101781910) = 1;
  *(undefined4 *)(uVar5 + (long)_DAT_101781924) = 6;
  uVar2 = _objc_alloc_init(PTR__OBJC_CLASS___OIInkInputAdaptor_10177fec8);
  lVar8 = (long)_DAT_101781928;
  *(undefined8 *)(uVar5 + lVar8) = uVar2;
  func_0x00010026e680(&plStack_60,&uStack_48);
  uVar5 = uStack_48;
  plVar4 = plStack_60;
  lVar9 = (long)_DAT_10178192c;
  plVar3 = *(long **)(uStack_48 + lVar9);
  if (plStack_60 != plVar3) {
    if (plStack_60 != (long *)0x0) {
      (**(code **)*plStack_60)(plStack_60);
      plVar3 = *(long **)(uVar5 + lVar9);
    }
    *(long **)(uVar5 + lVar9) = plVar4;
    if (plVar3 != (long *)0x0) {
      (**(code **)(*plVar3 + 8))();
    }
  }
  plVar4 = plStack_60;
  if (plStack_60 != (long *)0x0) {
    plStack_60 = (long *)0x0;
    (**(code **)(*plVar4 + 8))();
  }
  uVar2 = _objc_retain(param_4);
  lVar7 = (long)_DAT_101781930;
  *(undefined8 *)(uStack_48 + lVar7) = uVar2;
  __ZN4OInk5Input25ICALayerInkInputPresenter14CreateInkInputERNS0_5IUserEP6NSViewP17OIInkInputAdaptorNS0_7EventIdENS0_14EventAttributeENS0_7FeatureE
            (&plStack_60,*(undefined8 *)(uStack_48 + lVar9),*(undefined8 *)(uStack_48 + lVar7),
             *(undefined8 *)(uStack_48 + lVar8),0,0,0);
  plVar4 = plStack_60;
  lVar8 = (long)_DAT_101781934;
  plStack_60 = (long *)0x0;
  plVar3 = *(long **)(uStack_48 + lVar8);
  *(long **)(uStack_48 + lVar8) = plVar4;
  if (plVar3 != (long *)0x0) {
    (**(code **)(*plVar3 + 8))();
  }
  plVar4 = plStack_60;
  plStack_60 = (long *)0x0;
  if (plVar4 != (long *)0x0) {
    (**(code **)(*plVar4 + 8))();
  }
  plVar4 = *(long **)(uStack_48 + lVar8);
  if (plVar4 == (long *)0x0) {
    func_0x0001010bb910();
  }
  else {
    (**(code **)(*plVar4 + 0x30))(plVar4,4);
    plVar4 = *(long **)(uStack_48 + lVar8);
    if (plVar4 != (long *)0x0) {
      (**(code **)(*plVar4 + 0x28))(plVar4,1);
      return uStack_48;
    }
  }
  uVar5 = func_0x0001010bb910();
  if (extraout_d0 != *(double *)(uVar5 + (long)_DAT_1017818fc)) {
    *(double *)(uVar5 + (long)_DAT_1017818fc) = extraout_d0;
    func_0x00010110aec0();
    func_0x00010110cda0(uVar5);
    func_0x0001010e5680();
    func_0x000101106540((float)extraout_d0);
    func_0x00010110cba0(uVar5);
    uVar2 = func_0x00010110cc00();
    uVar6 = _objc_opt_class(PTR_PTR_10177fea8);
    uVar5 = _objc_opt_isKindOfClass(uVar2,uVar6);
    if ((uVar5 & 1) != 0) {
                    /* WARNING: Could not recover jumptable at 0x00010110c170. Too many branches */
                    /* WARNING: Treating indirect jump as call */
      uVar5 = (*(code *)PTR__objc_msgSend_10157bb70)(uVar2,PTR_s_updateWindowUI_10177c7d8);
      return uVar5;
    }
  }
  return uVar5;
}


