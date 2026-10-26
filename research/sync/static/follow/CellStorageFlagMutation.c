/* Ghidra pseudocode; inferred types and names; not Microsoft source. */
/* Default Ghidra analysis requested with 600-second per-file limit. Consult analysis log for completion; types remain inferred. */

void FUN_00736a88(long param_1,undefined1 param_2)

{
  std::recursive_mutex::lock();
  *(undefined1 *)(param_1 + 0xf0) = param_2;
  if (param_1 == -0x60) {
    return;
  }
  std::recursive_mutex::unlock();
  return;
}


