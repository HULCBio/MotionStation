/* 
 *   Copyright 1995-1999 The MathWorks, Inc.
 *   $Revision: 1.4.2.1 $ 
 */
#include <windows.h>


BOOL _stdcall LibMain(HANDLE hModule, 
                      DWORD  ul_reason_for_call, 
                      LPVOID lpReserved)
{
#ifdef REGISTER_BBEXIT
	extern void bbexit(void);
    switch( ul_reason_for_call ) {
    case DLL_PROCESS_ATTACH:
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
		break;
    case DLL_PROCESS_DETACH:
		bbexit();		
    }
#endif /* #ifdef REGISTER_BBEXIT */
    return TRUE;
}
