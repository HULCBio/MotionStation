// demo.cpp: Implementation of DLL Exports.
// Copyright 1998-2003 The MathWorks, Inc.
// $Revision: 1.3.4.3 $  $Date: 2003/08/29 04:44:14 $


// Note: Proxy/Stub Information
//      To build a separate proxy/stub DLL,
//      run nmake -f demops.mk in the project directory.

#include "stdafx.h"
#include "resource.h"
#include <initguid.h>
#include "demo.h"

#include "demo_i.c"
#include "DemoAdapt.h"
#include "DemoAin.h"
#include "DemoAout.h"

CComModule _Module;

BEGIN_OBJECT_MAP(ObjectMap)
    OBJECT_ENTRY(CLSID_DemoAdapt, CDemoAdapt)
    OBJECT_ENTRY(CLSID_DemoAin, CDemoAin)
    OBJECT_ENTRY(CLSID_DemoAout, CDemoAout)
END_OBJECT_MAP()

/////////////////////////////////////////////////////////////////////////////
// DLL Entry Point

extern "C"
BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, LPVOID /*lpReserved*/)
{
    if (dwReason == DLL_PROCESS_ATTACH)
    {
        _Module.Init(ObjectMap, hInstance, &LIBID_DEMOLib);
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


#include "DemoAin.h"
#include "DemoAout.h"
