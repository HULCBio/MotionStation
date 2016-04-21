// advantech.cpp : Implementation of DLL Exports.
// $Revision: 1.1.6.2 $
// $Date: 2004/04/08 20:49:31 $
// Copyright 2002-2004 The MathWorks, Inc. 
// Coded by OPTI-NUM solutions


// Note: Proxy/Stub Information
//      To build a separate proxy/stub DLL, 
//      run nmake -f advantechps.mk in the project directory.

#include "stdafx.h"
#include "resource.h"
#include <initguid.h>
#include "mwadvantech.h"

#include "mwadvantech_i.c"
#include "advantechadapt.h"
#include "advantechain.h"
#include "advantechaout.h"
#include "advantechdio.h"

CComModule _Module;

BEGIN_OBJECT_MAP(ObjectMap)
	OBJECT_ENTRY(CLSID_advantechadapt, Cadvantechadapt)
	OBJECT_ENTRY_NON_CREATEABLE(CadvantechAin)
	OBJECT_ENTRY_NON_CREATEABLE(CadvantechAout)
	OBJECT_ENTRY_NON_CREATEABLE(CadvantechDio)
END_OBJECT_MAP()

/////////////////////////////////////////////////////////////////////////////
// DLL Entry Point

extern "C"
BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, LPVOID /*lpReserved*/)
{
    if (dwReason == DLL_PROCESS_ATTACH)
    {
        _Module.Init(ObjectMap, hInstance, &LIBID_ADVANTECHLib);
        DisableThreadLibraryCalls(hInstance);
    }
    else if (dwReason == DLL_PROCESS_DETACH)
        _Module.Term();
    return TRUE;    // ok
}

/////////////////////////////////////////////////////////////////////////////
// Used to determine whether the DLL can be unloaded by OLE

STDAPI DllCanUnloadNow(void)
{
    return (_Module.GetLockCount()==0) ? S_OK : S_FALSE;
}

/////////////////////////////////////////////////////////////////////////////
// Returns a class factory to create an object of the requested type

STDAPI DllGetClassObject(REFCLSID rclsid, REFIID riid, LPVOID* ppv)
{
    return _Module.GetClassObject(rclsid, riid, ppv);
}

/////////////////////////////////////////////////////////////////////////////
// DllRegisterServer - Adds entries to the system registry

STDAPI DllRegisterServer(void)
{
    // registers object, typelib and all interfaces in typelib
    return _Module.RegisterServer(TRUE);
}

/////////////////////////////////////////////////////////////////////////////
// DllUnregisterServer - Removes entries from the system registry

STDAPI DllUnregisterServer(void)
{
    return _Module.UnregisterServer(TRUE);
}


