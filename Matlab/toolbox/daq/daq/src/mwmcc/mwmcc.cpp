// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.1.6.1 $  $Date: 2003/10/15 18:32:11 $


// mwcbi.cpp : Implementation of DLL Exports.


// Note: Proxy/Stub Information
//
//      If you are not running WinNT4.0 or Win95 with DCOM, then you
//      need to remove the following define from dlldatax.c
//      #define _WIN32_WINNT 0x0400
//
//      Further, if you are running MIDL without /Oicf switch, you also 
//      need to remove the following define from dlldatax.c.
//      #define USE_STUBLESS_PROXY
//
//      Modify the custom build rule for mwcbi.idl by adding the following 
//      files to the Outputs.
//          mwcbi_p.c
//          dlldata.c
//      To build a separate proxy/stub DLL, 
//      run nmake -f mwcbips.mk in the project directory.

#include "stdafx.h"
#include "resource.h"
#include <initguid.h>
#include "mwmcc.h"

#include "mwmcc_i.c"
#include "Ain.h"
#include "AOut.h"
#include "Dio.h"

#ifdef _DEBUG
#undef THIS_FILE
#undef DEBUG_NEW
static char THIS_FILE[]=__FILE__;
#define DEBUG_NEW new(_NORMAL_BLOCK, THIS_FILE, __LINE__)
#define new DEBUG_NEW
#endif

CComModule _Module;

BEGIN_OBJECT_MAP(ObjectMap)
OBJECT_ENTRY(CLSID_Ain, CAin)
OBJECT_ENTRY(CLSID_Aout, CAout)
OBJECT_ENTRY(CLSID_Dio, CDio)
END_OBJECT_MAP()


/////////////////////////////////////////////////////////////////////////////
// DLL Entry Point

extern "C"
BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, LPVOID lpReserved)
{
    lpReserved;
    if (dwReason == DLL_PROCESS_ATTACH)
    {
        _Module.Init(ObjectMap, hInstance, &LIBID_MWMCCLib);
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


HRESULT CbDevice::OpenDevice(REFIID riid,   long nParams, VARIANT __RPC_FAR *Param,
                             REFIID EngineIID,
                             IUnknown __RPC_FAR *pIEngine,
                             void __RPC_FAR *__RPC_FAR *ppIDevice)
{
    CComPtr<ImwDevice> pDevice;
    long id=0; // default to an id of 0
    if (nParams>1)
          return CComCoClass<CAin>::Error("Too many input arguments to MCC constructor.");
    if (nParams==1)
    {
        RETURN_HRESULT(VariantChangeType(Param,Param,0,VT_I4));
        id=Param[0].lVal;
    }
    if ( InlineIsEqualGUID(__uuidof(ImwInput),riid))
    {
        CAin *Ain=new CComObject<CAin>();
        pDevice=Ain;
        RETURN_HRESULT(Ain->Open(pIEngine,id));
    }
    else if ( InlineIsEqualGUID(__uuidof(ImwOutput),riid))
    {
        CAout *Aout=new CComObject<CAout>();
        pDevice=Aout;
        RETURN_HRESULT(Aout->Open((IDaqEngine*)pIEngine,id));
    }
    else if ( InlineIsEqualGUID(__uuidof(ImwDIO),riid))
    {
        CDio *dio=new CComObject<CDio>();
        pDevice=dio;
        RETURN_HRESULT(dio->Open(pIEngine,id));
    }
    else
        return E_FAIL;
    RETURN_HRESULT(pDevice->QueryInterface(riid,ppIDevice));
    return S_OK;
}

