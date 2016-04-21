#ifndef PORT32_H
#define PORT32_H

#ifdef WINIO_DLL
#define PORT32API _declspec(dllexport)
#else
#define PORT32API _declspec(dllimport)
#endif

#pragma pack(1)

struct GDT_DESCRIPTOR
{
  WORD Limit_0_15;
  WORD Base_0_15;
  BYTE Base_16_23;
  BYTE Type         : 4;
  BYTE System       : 1;
  BYTE DPL          : 2;
  BYTE Present      : 1;
  BYTE Limit_16_19  : 4;
  BYTE Available    : 1;
  BYTE Reserved     : 1;
  BYTE D_B          : 1;
  BYTE Granularity  : 1;
  BYTE Base_24_31;
};

struct CALLGATE_DESCRIPTOR
{
  WORD Offset_0_15;
  WORD Selector;
  WORD ParamCount   : 5;
  WORD Unused       : 3;
  WORD Type         : 4;
  WORD System       : 1;
  WORD DPL          : 2;
  WORD Present      : 1;
  WORD Offset_16_31;
};

struct GDTR
{
  WORD wGDTLimit;
  DWORD dwGDTBase;
};

#pragma pack()


extern "C"
{
  PORT32API bool _stdcall GetPortVal(WORD wPortAddr, PDWORD pdwPortVal, BYTE bSize);
  PORT32API bool _stdcall SetPortVal(WORD wPortAddr, DWORD dwPortVal, BYTE bSize);
}

#endif