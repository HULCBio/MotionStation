// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.3.4.4 $  $Date: 2003/10/15 18:32:42 $


#ifndef _NIUTIL_H
#define _NIUTIL_H
#ifdef _DEBUG
inline long _CheckNIResult(long status,char *Message,char *file,int line)
{
    if (status) 
    {
         if ((1 == _CrtDbgReport(_CRT_WARN, file, line, NULL,"%s Returned %d\n", Message, (long)status))) 
                _CrtDbgBreak(); 
    }
    return status;
}

#define DAQ_CHECK(_function) { long stat=_CheckNIResult(_function,#_function,__FILE__,__LINE__);if (stat<0) return stat;}
//#define DAQ_CHECK(status) { _CrtCheckMemory() ;long stat=status; _CrtCheckMemory(); if (stat) return stat;}
#define DAQ_TRACE(_function) _CheckNIResult(_function,#_function,__FILE__,__LINE__)
#else
#define DAQ_CHECK(_function) { long stat=_function; if (stat < 0) return stat;}
#define DAQ_TRACE(_function) _function
#endif

#include <comdef.h>

#ifdef _DEBUG
#define DEBUG_NEW new(_NORMAL_BLOCK, __FILE__, __LINE__)
#define new DEBUG_NEW
#endif 

//bstr_t daqTranslateErrorCode(short);
CComBSTR TranslateErrorCode(HRESULT code);

int GetDriverVersion(LPSTR);
double Timebase2ClockResolution(int timeBase);
_bstr_t StringToLower(const _bstr_t& in);

//void ClearEventMessages(short);
char *ChanList2Str(short*, int, SSType, char*);
//HWND CreateNIDAQWindow(HINSTANCE*);
void WfmCallback(HWND, UINT, WPARAM, LPARAM);

#endif


