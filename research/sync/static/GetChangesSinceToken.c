/* Ghidra pseudocode; inferred types and names; not Microsoft source. */
/* Default Ghidra analysis requested with 600-second per-file limit. Consult analysis log for completion; types remain inferred. */

/* Csi::GetChangesSinceToken(wchar_t const*, wchar_t const*, wchar_t const*, wchar_t const*, int&,
   int&, int&, wchar_t const*, MsoCF::CWzInBuffer_T<MsoCF::String<MsoCF::WzTraits>,
   MsoCF::CBuffer<wchar_t> >&, Csi::T_ISkyDriveList<Csi::ISkyDriveItemDescriptor>**,
   MsoCF::CWzInBuffer_T<MsoCF::String<MsoCF::WzTraits>, MsoCF::CBuffer<wchar_t> >&,
   MsoCF::CWzInBuffer_T<MsoCF::String<MsoCF::WzTraits>, MsoCF::CBuffer<wchar_t> >&) */

ulong Csi::GetChangesSinceToken
                (wchar_t *param_1,wchar_t *param_2,wchar_t *param_3,wchar_t *param_4,int *param_5,
                int *param_6,int *param_7,wchar_t *param_8,CWzInBuffer_T *param_9,
                T_ISkyDriveList **param_10,CWzInBuffer_T *param_11,CWzInBuffer_T *param_12)

{
  uint uVar1;
  wchar_t ****ppppwVar2;
  short *psVar3;
  code *pcVar4;
  bool bVar5;
  bool bVar6;
  byte bVar7;
  uint uVar8;
  int iVar9;
  undefined8 uVar10;
  undefined8 uVar11;
  undefined8 uVar12;
  undefined8 uVar13;
  ulong uVar14;
  wchar_t *pwVar15;
  long *plVar16;
  long lVar17;
  wchar_t *pwVar18;
  _WS_ERROR *p_Var19;
  ulong uVar20;
  uint uVar21;
  wchar_t *pwVar23;
  wchar_t *pwVar22;
  byte bVar24;
  undefined1 auVar25 [16];
  long *local_16f0;
  int local_16e4;
  undefined8 local_16e0;
  undefined8 local_16d8;
  undefined8 local_16d0;
  wchar_t ****local_16c8;
  wchar_t *local_16c0;
  uint local_16b8;
  undefined2 uStack_16b4;
  undefined1 uStack_16b2;
  char cStack_16b1;
  long *local_668;
  long *local_660;
  long *local_658;
  wchar_t *local_650;
  long *local_648;
  long local_640;
  wchar_t *local_638;
  undefined *local_630;
  long *local_628;
  long *local_620;
  undefined2 *local_618;
  undefined8 local_610;
  undefined4 local_608;
  undefined2 local_604 [130];
  undefined8 local_500;
  undefined2 *local_4f8;
  undefined8 local_4f0;
  undefined4 local_4e8;
  undefined2 local_4e4 [130];
  undefined8 local_3e0;
  undefined2 *local_3d8;
  undefined8 local_3d0;
  undefined4 local_3c8;
  undefined2 local_3c4 [130];
  undefined8 local_2c0;
  undefined2 *local_2b8;
  undefined8 local_2b0;
  undefined4 local_2a8;
  undefined2 local_2a4 [130];
  undefined8 local_1a0;
  undefined2 *local_198;
  undefined8 local_190;
  undefined4 local_188;
  undefined2 local_184 [130];
  long local_80;
  
  auVar25 = (*(code *)PTR____chkstk_darwin_00c8a438)();
  lVar17 = auVar25._8_8_;
  local_80 = *(long *)PTR____stack_chk_guard_00c8a488;
  uVar20 = 0x80070057;
  if ((((auVar25._0_8_ == 0) || (lVar17 == 0)) || (param_3 == (wchar_t *)0x0)) ||
     ((param_4 == (wchar_t *)0x0 || (param_8 == (wchar_t *)0x0)))) goto LAB_007a0b54;
  local_628 = (long *)0x0;
  uVar20 = FUN_0079e734(&local_628,auVar25._0_8_,param_4,0x5000000,0x5000000);
  if (-1 < (int)uVar20) {
    local_630 = PTR_u_v1_0_00da1da0;
    local_648 = (long *)0x0;
    local_650 = param_8;
    local_640 = lVar17;
    local_638 = param_3;
    if (local_628 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
      FUN_009a49bc();
    }
    uVar10 = (**(code **)(*local_628 + 0x60))();
    if (local_628 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
      FUN_009a49bc();
    }
    uVar11 = (**(code **)(*local_628 + 0x68))();
    if (local_628 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
      FUN_009a49bc();
    }
    uVar12 = (**(code **)(*local_628 + 0x88))();
    if (local_628 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
      FUN_009a49bc();
    }
    uVar20 = (**(code **)(*local_628 + 0x90))();
    uVar21 = (uint)uVar20;
    if (local_628 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
      FUN_009a49bc();
    }
    uVar13 = (**(code **)(*local_628 + 0x80))();
    uVar14 = FUN_0079dc78(uVar10,&local_640,param_4,param_5,param_6,param_7,&local_648,&local_650,
                          uVar11,uVar12,uVar21,0,uVar13);
    if ((int)uVar14 < 0) {
      if ((int)uVar14 == -0x7fc2ffed) {
        FUN_0079de08(&local_16c8);
        if (local_628 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
          FUN_009a49bc();
        }
        uVar10 = (**(code **)(*local_628 + 0x80))();
        if (local_628 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
          FUN_009a49bc();
        }
        uVar11 = (**(code **)(*local_628 + 0x68))();
        iVar9 = _WsGetFaultErrorDetail(uVar10,&PTR_DAT_00d4dea0,1,uVar11,&local_16c8,0x18);
        if (-1 < iVar9) {
          MsoCF::Strings::CopyWzToWz(local_16c0,param_11,(int *)0x0);
          psVar3 = (short *)CONCAT17(cStack_16b1,
                                     CONCAT16(uStack_16b2,CONCAT24(uStack_16b4,local_16b8)));
          if ((psVar3 != (short *)0x0) && (*psVar3 != 0)) {
            MsoCF::Strings::AppendArrayOfCharactersToWz
                      ((wchar_t *)&DAT_00c30272,2,param_11,(int *)0x0);
            pwVar15 = (wchar_t *)
                      CONCAT17(cStack_16b1,CONCAT16(uStack_16b2,CONCAT24(uStack_16b4,local_16b8)));
            if (pwVar15 == (wchar_t *)0x0) {
              iVar9 = 0;
            }
            else {
              iVar9 = wc16::wcslen(pwVar15);
            }
            MsoCF::Strings::AppendArrayOfCharactersToWz(pwVar15,iVar9,param_11,(int *)0x0);
          }
        }
        uVar20 = 0x803d0013;
        if (**(short **)(param_11 + 8) != 0) goto LAB_007a0b3c;
      }
      if (local_628 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
        FUN_009a49bc();
      }
      p_Var19 = (_WS_ERROR *)(**(code **)(*local_628 + 0x80))();
      Mso::WebServices::GetErrorString(p_Var19);
      ppppwVar2 = local_16c8;
      iVar9 = (int)local_16c0;
      if (-1 < cStack_16b1) {
        ppppwVar2 = (wchar_t ****)&local_16c8;
        iVar9 = (int)cStack_16b1;
      }
      MsoCF::Strings::SetWzFromArrayOfCharacters(param_11,(wchar_t *)ppppwVar2,iVar9);
      if (cStack_16b1 < '\0') {
        operator_delete(local_16c8);
      }
      uVar20 = uVar14;
    }
    else {
      if (local_628 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
        FUN_009a49bc();
      }
      pwVar15 = (wchar_t *)(**(code **)(*local_628 + 0xc0))();
      if (pwVar15 != (wchar_t *)0x0) {
        MsoCF::Strings::CopyWzToWz(pwVar15,param_12,(int *)0x0);
      }
      plVar16 = (long *)FUN_007a0d7c(0);
      local_658 = (long *)0x0;
      if (plVar16 != (long *)0x0) {
        (**(code **)(*plVar16 + 8))(plVar16);
      }
      local_658 = plVar16;
      FUN_007a0da4(&local_658,param_10);
      if (local_650 != (wchar_t *)0x0) {
        MsoCF::Strings::CopyWzToWz(local_650,param_9,(int *)0x0);
      }
      local_660 = (long *)0x0;
      if ((local_648 == (long *)0x0) || (*local_648 == 0)) {
        uVar8 = 1;
      }
      else {
        uVar14 = FUN_0072aee4(*local_648,&local_660,1,1);
        uVar21 = (uint)uVar14;
        if ((int)uVar21 < 0) {
          uVar8 = 0;
          plVar16 = local_660;
        }
        else {
          local_668 = (long *)0x0;
          if (local_660 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
            FUN_009a49bc();
          }
          (**(code **)(*local_660 + 0x18))();
          do {
            uVar21 = (uint)uVar20;
            if (local_660 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
              FUN_009a49bc();
            }
            uVar8 = (**(code **)(*local_660 + 0x20))(local_660,&local_668);
            if (uVar8 == 0) break;
            local_16c8 = (wchar_t ****)0x0;
            local_16c0 = (wchar_t *)0x0;
            local_16b8 = 0;
            local_16c8 = (wchar_t ****)MsoCF::GetFixedBufferAllocator();
            local_16b8 = 0x104a;
            uStack_16b4 = 0;
            local_198 = (undefined2 *)0x0;
            local_1a0 = 0;
            local_188 = 0;
            local_190 = 0;
            local_16c0 = (wchar_t *)&uStack_16b4;
            local_1a0 = MsoCF::GetFastBufferAllocator();
            local_190 = 0x10200000102;
            local_184[0] = 0;
            local_2b8 = (undefined2 *)0x0;
            local_2c0 = 0;
            local_2a8 = 0;
            local_2b0 = 0;
            local_198 = local_184;
            local_2c0 = MsoCF::GetFastBufferAllocator();
            local_2b0 = 0x10200000102;
            local_2a4[0] = 0;
            local_16d8 = 0;
            local_16d0 = 0;
            local_16e0 = 0;
            local_3d8 = (undefined2 *)0x0;
            local_3e0 = 0;
            local_3c8 = 0;
            local_3d0 = 0;
            local_2b8 = local_2a4;
            local_3e0 = MsoCF::GetFastBufferAllocator();
            local_3d0 = 0x10200000102;
            local_3c4[0] = 0;
            local_4f8 = (undefined2 *)0x0;
            local_500 = 0;
            local_4e8 = 0;
            local_4f0 = 0;
            local_3d8 = local_3c4;
            local_500 = MsoCF::GetFastBufferAllocator();
            local_4f0 = 0x10200000102;
            local_4e4[0] = 0;
            local_16e4 = 200;
            local_4f8 = local_4e4;
            if ((int)local_16b8 < 2) {
              (*(code *)**local_16c8)(local_16c8,&local_16c8,2,0);
            }
            *(undefined2 *)local_16c0 = 0;
            uVar20 = (**(code **)(*local_668 + 0x18))(local_668,L"href",local_16c0,local_16b8 >> 1);
            if ((uVar20 & 1) == 0) {
LAB_007a0884:
              bVar5 = false;
              uVar20 = 0x800705b9;
            }
            else {
              MsoCF::Strings::CopyWzToWz(local_16c0,(CWzInBuffer_T *)&local_1a0,(int *)0x0);
              if ((int)local_16b8 < 2) {
                (*(code *)**local_16c8)(local_16c8,&local_16c8,2,0);
              }
              *(undefined2 *)local_16c0 = 0;
              iVar9 = (**(code **)(*local_668 + 0x18))
                                (local_668,L"displayname",local_16c0,local_16b8 >> 1);
              if (iVar9 != 0) {
                MsoCF::Strings::CopyWzToWz(local_16c0,(CWzInBuffer_T *)&local_2c0,(int *)0x0);
              }
              if ((int)local_16b8 < 2) {
                (*(code *)**local_16c8)(local_16c8,&local_16c8,2,0);
              }
              *(undefined2 *)local_16c0 = 0;
              iVar9 = (**(code **)(*local_668 + 0x18))
                                (local_668,L"isFolder",local_16c0,local_16b8 >> 1);
              pwVar15 = local_16c0;
              bVar5 = false;
              if (iVar9 != 0) {
                if ((local_16c0 == (wchar_t *)0x0) || (iVar9 = wc16::wcslen(local_16c0), iVar9 == 0)
                   ) goto LAB_007a0884;
                bVar5 = (*pwVar15 & L'￟') == L'T';
              }
              if ((int)local_16b8 < 2) {
                (*(code *)**local_16c8)(local_16c8,&local_16c8,2,0);
              }
              *(short *)local_16c0 = 0;
              iVar9 = (**(code **)(*local_668 + 0x18))
                                (local_668,L"ishidden",local_16c0,local_16b8 >> 1);
              bVar6 = false;
              if (iVar9 != 0) {
                bVar6 = (short)*local_16c0 == 0x31;
              }
              if (bVar5 == false) {
                if ((int)local_16b8 < 2) {
                  (*(code *)**local_16c8)(local_16c8,&local_16c8,2,0);
                }
                *(short *)local_16c0 = 0;
                iVar9 = (**(code **)(*local_668 + 0x18))
                                  (local_668,L"getcontentlength",local_16c0,local_16b8 >> 1);
                if (iVar9 != 0) {
                  _MsoParseUInt64Wz(local_16c0,&local_16d0);
                }
              }
              if ((int)local_16b8 < 2) {
                (*(code *)**local_16c8)(local_16c8,&local_16c8,2,0);
              }
              *(short *)local_16c0 = 0;
              iVar9 = (**(code **)(*local_668 + 0x18))
                                (local_668,L"creationdate",local_16c0,local_16b8 >> 1);
              if ((iVar9 != 0) &&
                 (iVar9 = MsoParseTimeWz(local_16c0,(_SYSTEMTIME *)&local_620), iVar9 != 0)) {
                _SystemTimeToFileTime(&local_620,&local_16e0);
              }
              if ((int)local_16b8 < 2) {
                (*(code *)**local_16c8)(local_16c8,&local_16c8,2,0);
              }
              *(undefined2 *)local_16c0 = 0;
              iVar9 = (**(code **)(*local_668 + 0x18))
                                (local_668,L"getlastmodified",local_16c0,local_16b8 >> 1);
              if ((iVar9 != 0) &&
                 (iVar9 = Mso::DateTime::TryRfc1123DateToSystemTime
                                    (local_16c0,(_SYSTEMTIME *)&local_620), iVar9 != 0)) {
                _SystemTimeToFileTime(&local_620,&local_16d8);
              }
              if ((int)local_16b8 < 2) {
                (*(code *)**local_16c8)(local_16c8,&local_16c8,2,0);
              }
              *(undefined2 *)local_16c0 = 0;
              iVar9 = (**(code **)(*local_668 + 0x18))
                                (local_668,L"resourceId",local_16c0,local_16b8 >> 1);
              if (iVar9 != 0) {
                MsoCF::Strings::CopyWzToWz(local_16c0,(CWzInBuffer_T *)&local_3e0,(int *)0x0);
              }
              if ((int)local_16b8 < 2) {
                (*(code *)**local_16c8)(local_16c8,&local_16c8,2,0);
              }
              *(undefined2 *)local_16c0 = 0;
              iVar9 = (**(code **)(*local_668 + 0x18))
                                (local_668,L"progid",local_16c0,local_16b8 >> 1);
              if (iVar9 != 0) {
                MsoCF::Strings::CopyWzToWz(local_16c0,(CWzInBuffer_T *)&local_500,(int *)0x0);
              }
              if ((int)local_16b8 < 2) {
                (*(code *)**local_16c8)(local_16c8,&local_16c8,2,0);
              }
              *(short *)local_16c0 = 0;
              iVar9 = (**(code **)(*local_668 + 0x18))
                                (local_668,L"status",local_16c0,local_16b8 >> 1);
              if (iVar9 != 0) {
                local_16e4 = 0;
                local_618 = (undefined2 *)0x0;
                local_620 = (long *)0x0;
                local_608 = 0;
                local_610 = 0;
                local_620 = (long *)MsoCF::GetFastBufferAllocator();
                local_610 = 0x10200000102;
                local_604[0] = 0;
                local_618 = local_604;
                lVar17 = wc16::wcschr(local_16c0,L' ');
                if (lVar17 != 0) {
                  pwVar15 = (wchar_t *)(lVar17 + 2);
                  pwVar18 = (wchar_t *)wc16::wcschr(pwVar15,L' ');
                  pwVar23 = pwVar15;
                  if (pwVar15 <= pwVar18 && (long)pwVar18 - (long)pwVar15 != 0) {
                    do {
                      pwVar22 = (wchar_t *)((long)pwVar23 + 2);
                      iVar9 = MsoFDigitWch((uint)(ushort)*pwVar23);
                      if (iVar9 == 0) goto LAB_007a07d4;
                      pwVar23 = pwVar22;
                    } while (pwVar22 < pwVar18);
                    MsoCF::Strings::SetWzFromArrayOfCharacters
                              ((CWzInBuffer_T *)&local_620,pwVar15,
                               (int)((ulong)((long)pwVar18 - (long)pwVar15) >> 1));
                    _MsoParseUIntWz(local_618,&local_16e4);
                  }
                }
LAB_007a07d4:
                if (local_618 != local_604) {
                  Mso::Memory::Free(local_618);
                }
              }
              local_620 = (long *)0x0;
              uVar14 = MsoHrCreateUrlSimpleFromUser(&local_620,local_198,0,0,0x2000,0);
              if ((int)uVar14 < 0) {
                bVar24 = 0;
                uVar20 = uVar14;
              }
              else {
                local_16f0 = (long *)0x0;
                uVar14 = MsoHrCreateUrlSimpleFromUser(&local_16f0,param_4,0,0,0x2000,0);
                if ((int)uVar14 < 0) {
                  bVar24 = 0;
                  uVar20 = uVar14;
                }
                else {
                  if (local_16f0 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
                    FUN_009a49bc();
                  }
                  bVar7 = (**(code **)(*local_16f0 + 0x2a0))(local_16f0,local_620);
                  bVar7 = bVar7 & local_16e4 == 0x194;
                  bVar24 = bVar7 ^ 1;
                  uVar1 = 0x80070002;
                  if (bVar7 == 0) {
                    uVar1 = uVar21;
                  }
                  uVar20 = (ulong)uVar1;
                }
                plVar16 = local_16f0;
                local_16f0 = (long *)0x0;
                if (plVar16 != (long *)0x0) {
                  (**(code **)(*plVar16 + 0x10))();
                }
              }
              plVar16 = local_620;
              local_620 = (long *)0x0;
              if (plVar16 != (long *)0x0) {
                (**(code **)(*plVar16 + 0x10))();
              }
              if (bVar24 == 0) {
                bVar5 = false;
              }
              else {
                FUN_007a0dec(&local_620);
                if (local_620 == (long *)0x0) {
                  FUN_009a4c3c();
                    /* WARNING: Does not return */
                  pcVar4 = (code *)SoftwareBreakpoint(1,0x7a0c08);
                  (*pcVar4)();
                }
                FUN_007a0e58(local_620,local_198,local_2b8,bVar5,bVar6,local_16d0,&local_16e0,
                             &local_16d8,local_3d8,local_4f8,local_16e4);
                if (local_658 == (long *)0x0) {
                    /* WARNING: Subroutine does not return */
                  FUN_009a49bc();
                }
                uVar10 = (**(code **)(*local_658 + 0x18))();
                FUN_007a0f18(uVar10,local_620);
                plVar16 = local_620;
                if (local_620 != (long *)0x0) {
                  local_620 = (long *)0x0;
                  (**(code **)(*plVar16 + 0x10))();
                }
                bVar5 = true;
              }
            }
            uVar21 = (uint)uVar20;
            if (local_4f8 != local_4e4) {
              Mso::Memory::Free(local_4f8);
            }
            if (local_3d8 != local_3c4) {
              Mso::Memory::Free(local_3d8);
            }
            if (local_2b8 != local_2a4) {
              Mso::Memory::Free(local_2b8);
            }
            if (local_198 != local_184) {
              Mso::Memory::Free(local_198);
            }
          } while (bVar5);
          uVar8 = uVar8 ^ 1;
          plVar16 = local_660;
        }
        local_660 = (long *)0x0;
        if (plVar16 != (long *)0x0) {
          (**(code **)(*plVar16 + 0x10))();
        }
      }
      plVar16 = local_658;
      local_658 = (long *)0x0;
      if (plVar16 != (long *)0x0) {
        (**(code **)(*plVar16 + 0x10))();
      }
      uVar1 = (uint)uVar14;
      if (uVar8 == 0) {
        uVar1 = uVar21;
      }
      uVar20 = (ulong)uVar1;
    }
  }
LAB_007a0b3c:
  plVar16 = local_628;
  local_628 = (long *)0x0;
  if (plVar16 != (long *)0x0) {
    (**(code **)(*plVar16 + 0x10))();
  }
LAB_007a0b54:
  if (*(long *)PTR____stack_chk_guard_00c8a488 != local_80) {
                    /* WARNING: Subroutine does not return */
    ___stack_chk_fail();
  }
  return uVar20;
}


