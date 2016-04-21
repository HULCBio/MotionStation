// #$Demo$#.cpp: Implementation of DLL Exports.
// Copyright 2002-2003 The MathWorks, Inc.
// $Revision: 1.1.6.3 $  $Date: 2003/08/29 04:44:21 $


// Note: Proxy/Stub Information
//      To build a separate proxy/stub DLL,
//      run nmake -f #$demo$#ps.mk in the project directory.

#include "stdafx.h"
#include "resource.h"
#include <initguid.h>
#include "#$demo$#.h"

#include "#$Demo$#_i.c"
#include "#$Demo$#Adapt.h"
#$StartAICut$##include "#$Demo$#Ain.h"#$EndAICut$#
#$StartAOCut$##include "#$Demo$#Aout.h"#$EndAOCut$#
#$StartDIOCut$##include "#$Demo$#DIO.h"#$EndDIOCut$#

// Instanciate COM server 
CComModule _Module;

// Define ATL Object Map to define included objects
BEGIN_OBJECT_MAP(ObjectMap)
    OBJECT_ENTRY(CLSID_#$Demo$#Adapt, C#$Demo$#Adapt)
#$StartAICut$#    OBJECT_ENTRY(CLSID_#$Demo$#Ain, C#$Demo$#Ain)#$EndAICut$#
#$StartAOCut$#    OBJECT_ENTRY(CLSID_#$Demo$#Aout, C#$Demo$#Aout)#$EndAOCut$#
#$StartDIOCut$#    OBJECT_ENTRY(CLSID_#$Demo$#DIO, C#$Demo$#DIO)#$EndDIOCut$#
END_OBJECT_MAP()

/////////////////////////////////////////////////////////////////////////////
// DLL Entry Point

extern "C"
BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, LPVOID /*lpReserved*/)
{
    if (dwReason == DLL_PROCESS_ATTACH)
    {
        _Module.Init(ObjectMap, hInstance, &LIBID_#$Demo$#Lib);
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

