/* Ghidra pseudocode; inferred types and names; not Microsoft source. */
/* Default Ghidra analysis requested with 600-second per-file limit. Consult analysis log for completion; types remain inferred. */

/* FileIO::CobaltClient::CreateRequestBatch(std::basic_string<wchar_t, wc16::wchar16_traits,
   std::allocator<wchar_t> > const&, std::basic_string<wchar_t, wc16::wchar16_traits,
   std::allocator<wchar_t> > const&, std::basic_string<wchar_t, wc16::wchar16_traits,
   std::allocator<wchar_t> > const&, std::basic_string<wchar_t, wc16::wchar16_traits,
   std::allocator<wchar_t> > const&, std::basic_string<wchar_t, wc16::wchar16_traits,
   std::allocator<wchar_t> > const&, std::basic_string<wchar_t, wc16::wchar16_traits,
   std::allocator<wchar_t> > const&, std::basic_string<wchar_t, wc16::wchar16_traits,
   std::allocator<wchar_t> > const&, std::basic_string<wchar_t, wc16::wchar16_traits,
   std::allocator<wchar_t> > const&, FileIO::CobaltClient::RequestMetadata const&, bool) */

void FileIO::CobaltClient::CreateRequestBatch
               (basic_string *param_1,basic_string *param_2,basic_string *param_3,
               basic_string *param_4,basic_string *param_5,basic_string *param_6,
               basic_string *param_7,basic_string *param_8,RequestMetadata *param_9,bool param_10)

{
  undefined8 *in_x8;
  undefined8 local_30;
  bool local_21;
  
  local_21 = param_10;
  FUN_000a708c(&local_30);
  *in_x8 = local_30;
  return;
}


