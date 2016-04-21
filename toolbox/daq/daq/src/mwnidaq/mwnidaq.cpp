// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.4.4.5 $  $Date: 2003/12/04 18:40:01 $


// mwnidaq.cpp : Implementation of DLL Exports.


//		To build a separate proxy/stub DLL, 
//		run nmake -f mwnidaqps.mk in the project directory.

#include "stdafx.h"
#include "resource.h"
#include "initguid.h"
#include "mwnidaq.h"
#include <nidaq.h>
#include "nidaqcns.h"
#include "nidaqerr.h"

#include "mwnidaq_i.c"
#include "nia2d.h"
#include "nid2a.h"
#include "niDIO.h"
#include "niDisp.h"

CComModule _Module;


BEGIN_OBJECT_MAP(ObjectMap)
    OBJECT_ENTRY(CLSID_CniAdaptor, CniAdaptor)
    OBJECT_ENTRY_NON_CREATEABLE(Cnia2d)
    OBJECT_ENTRY_NON_CREATEABLE(Cnid2a)
    OBJECT_ENTRY_NON_CREATEABLE(CniDIO)
//    OBJECT_ENTRY(CLSID_niDisp, CniDisp)
END_OBJECT_MAP()

/////////////////////////////////////////////////////////////////////////////
// DLL Entry Point
#ifdef   _DEBUG
static CSemaphore LoadCount(0,_T("NidaqLoadCount"));
#define  SET_CRT_DEBUG_FIELD(a) \
            _CrtSetDbgFlag((a) | _CrtSetDbgFlag(_CRTDBG_REPORT_FLAG))
#define  CLEAR_CRT_DEBUG_FIELD(a) \
            _CrtSetDbgFlag(~(a) & _CrtSetDbgFlag(_CRTDBG_REPORT_FLAG))
#else
#define  SET_CRT_DEBUG_FIELD(a)   ((void) 0)
#define  CLEAR_CRT_DEBUG_FIELD(a) ((void) 0)
#endif




extern "C"
BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, LPVOID lpReserved)
{
    lpReserved;
#ifdef _DEBUG
    _CrtSetReportMode( _CRT_WARN, _CRTDBG_MODE_DEBUG );
    _CrtSetReportMode( _CRT_ERROR, _CRTDBG_MODE_DEBUG );
#endif
    if (dwReason == DLL_PROCESS_ATTACH)
    {        
#ifdef   _DEBUG
            int count=LoadCount.Release(1)+1;
			// For DAQ Partners, change the word mwwinsound to example
            ATLTRACE("mwnidaq process attach. Lock count is %d LoadCount is %d\n",_Module.GetLockCount(),count);
#endif
            _Module.Init(ObjectMap, hInstance);
        DisableThreadLibraryCalls(hInstance);           
    }
    else if (dwReason == DLL_PROCESS_DETACH)
    {
        _Module.Term();
#ifdef   _DEBUG
       SET_CRT_DEBUG_FIELD( _CRTDBG_LEAK_CHECK_DF );

        ATLTRACE("mwnidaq process detach. Lock count is %d LoadCount is %d\n",_Module.GetLockCount(),LoadCount.GetCount());
        LoadCount.Wait(0);
#endif
    }
    return TRUE;    // ok
}

/////////////////////////////////////////////////////////////////////////////
// Used to determine whether the DLL can be unloaded by OLE

STDAPI DllCanUnloadNow(void)
{
    ATLTRACE("Attempt to unload mwnidaq count is %d.\n",_Module.GetLockCount());
    return S_FALSE;
    //return (_Module.GetLockCount()==0) ? S_OK : S_FALSE;
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
    _Module.UnregisterServer();
    return S_OK;
}

CniAdaptor::~CniAdaptor()
{
    // need to delete Device structs
    for (unsigned int i=0;i<BoardIds.size();++i)
    {
        delete(DeviceInfo[BoardIds[i]]);
    }
}

#define MAX_BOARDS (16)

void CniAdaptor::InitDeviceInfo()
{
    DWORD devCode;
    for (int i=1; i<=MAX_BOARDS; i++)
    {
        long status=Get_DAQ_Device_Info(i, ND_DEVICE_TYPE_CODE, &devCode);                
        
        // if the device code is not 0 or 1, it's a valid board id
        if (status==0 && devCode>1)
	{
            BoardIds.push_back(i);
	}
    }
    if (!BoardIds.empty())
    {
        DeviceInfo.resize(BoardIds.back()+1,NULL);
        for (unsigned i=0;i<BoardIds.size();++i)
        {
            int id=BoardIds[i];
            DevCaps* dc=new DevCaps();
            dc->GetDeviceData(id);
            DeviceInfo[id]=dc;
        }
    }
}


HRESULT CniAdaptor::OpenDevice(REFIID riid,   long nParams, VARIANT __RPC_FAR *Param,
                             REFIID EngineIID,
                             IUnknown __RPC_FAR *pIEngine,
                             void __RPC_FAR *__RPC_FAR *ppIDevice)
{
    CComQIPtr<ImwDevice> pDevice;
    CComQIPtr<IDaqEngine> pEngine=pIEngine;

    long id=1; // default to an id of 1
    if (nParams==1)
    {
        RETURN_HRESULT(VariantChangeType(Param,Param,0,VT_I4));
        id=Param[0].lVal;
    }
    if (nParams>1)
        return Error("Too many input arguments to NIDAQ constructor.");
     if (id<1 
        || id > MAX_BOARDS
        || id > static_cast<long>(DeviceInfo.size())
        || !GetDevCaps(id)->IsValid())
     return E_INVALID_DEVICE_ID;


    if ( InlineIsEqualGUID(__uuidof(ImwInput),riid))
    {
        //CComPtr<CComObject<Cnia2d> > Ain;
        //RETURN_HRESULT(CComObject<Cnia2d>::CreateInstance(&Ain));
        CComObject<Cnia2d> *Ain=NULL;
        switch (GetDevCaps(id)->GetType())
        {
        case DSA_SERIES:

            RETURN_HRESULT(CComObject<CDSAInput>::CreateInstance(reinterpret_cast <CComObject<CDSAInput> **>(&Ain)) );
            break;
//        case DAQCARD_700:
        case PC_LPM_16:
        case LAB_PC:
            RETURN_HRESULT(CComObject<CLabInput>::CreateInstance(reinterpret_cast <CComObject<CLabInput> **>(&Ain)));
            break;
        default:
            RETURN_HRESULT(CComObject<CESeriesInput>::CreateInstance(reinterpret_cast <CComObject<CESeriesInput> **>(&Ain)));
        }
        pDevice=Ain;
        RETURN_HRESULT(Ain->Open(pEngine,id,GetDevCaps(id)));
    }
    else if ( InlineIsEqualGUID(__uuidof(ImwOutput),riid))
    {
        if (GetDevCaps(id)->IsDSA())
        {
            CComObject<CDSAOutput> *Aout;
            RETURN_HRESULT(CComObject<CDSAOutput>::CreateInstance(&Aout));
            pDevice=Aout;
            RETURN_HRESULT(Aout->Open(pEngine,id,GetDevCaps(id)));
        }
        else
        {
            CComObject<CESeriesOutput> *Aout;
            RETURN_HRESULT(CComObject<CESeriesOutput>::CreateInstance(&Aout));
            pDevice=Aout;
            RETURN_HRESULT(Aout->Open(pEngine,id,GetDevCaps(id)));
        }
    }
    else if ( InlineIsEqualGUID(__uuidof(ImwDIO),riid))
    {
        //CniDIO *dio=new CniDIO((IDaqEngine*)pIEngine,id);
        CniDIO *dio=new CComObject<CniDIO>();
        pDevice=dio;
        RETURN_HRESULT(dio->Open(pEngine,id,GetDevCaps(id)));
    }
// Here is the actual addref
    RETURN_HRESULT(pDevice->QueryInterface(riid,ppIDevice));
    return S_OK;
}

CniAdaptor::CniAdaptor()
{
    InitDeviceInfo();   
}

STDMETHODIMP CniAdaptor::AdaptorInfo(IPropContainer *pCont)
{
    int len=BoardIds.size();           
    HRESULT hRes = pCont->put_MemberValue(CComBSTR(L"adaptorname"),CComVariant(L"nidaq"));
    if (!(SUCCEEDED(hRes))) return hRes;

    TCHAR name[256];
    GetModuleFileName(_Module.GetModuleInstance(),name,256); // null returns MATLABs version (non existant)

    hRes = pCont->put_MemberValue(CComBSTR(L"adaptordllname"),CComVariant(name));
    if (!(SUCCEEDED(hRes))) return hRes;

    // find all installed boards and report ids:
    // 
	SAFEARRAY *boardids = SafeArrayCreateVector(VT_BSTR, 0, len);
	if (boardids==NULL) 
            return E_SAFEARRAY_ERR;   
    
    CComBSTR *stringids=NULL;
    CComVariant bids;   
    
    bids.parray=boardids;
    bids.vt = VT_ARRAY | VT_BSTR;           
    
    hRes = SafeArrayAccessData(boardids, (void **) &stringids);
    if (FAILED (hRes)) {
        SafeArrayDestroy (boardids);
        return E_SAFEARRAY_ERR;
    }

    wchar_t str[80];
    for (int i=0;i<len;i++) {	
		swprintf(str,L"%d",BoardIds[i]);
		stringids[i] = str;
    }  

	SafeArrayUnaccessData(boardids);
    hRes = pCont->put_MemberValue(CComBSTR(L"installedboardids"),bids);   
    if (!(SUCCEEDED(hRes))) return hRes;    

	bids.Clear();

    // build up an array of device names
    CComVariant val;    
    SAFEARRAY *ps = SafeArrayCreateVector(VT_BSTR, 0, len);
    if (ps==NULL) 
        return E_SAFEARRAY_ERR;

    val.parray=ps;
    val.vt = VT_ARRAY | VT_BSTR;

    CComBSTR *strings;
    
    HRESULT hr = SafeArrayAccessData(ps, (void **) &strings);
    if (FAILED (hr)) 
    {
        SafeArrayDestroy (ps);
        return E_SAFEARRAY_ERR;
    }             

    for (i=0;i<len;i++)
    {	
	strings[i]=DeviceInfo[BoardIds[i]]->deviceName;	
    }

    hRes = pCont->put_MemberValue(CComBSTR(L"boardnames"),val);
    if (!(SUCCEEDED(hRes))) return hRes;

    SafeArrayUnaccessData(ps);

    // up to 3 subsystems per board
    SAFEARRAYBOUND arrayBounds[2];  
    arrayBounds[0].lLbound = 0;
    arrayBounds[0].cElements = len;    
    arrayBounds[1].lLbound = 0;
    arrayBounds[1].cElements = 3;    
    ps = SafeArrayCreate(VT_BSTR, 2, arrayBounds);
    if (ps==NULL)
        return E_SAFEARRAY_ERR;
   
    val.Clear();
    val.parray=ps;
    val.vt = VT_ARRAY | VT_BSTR;
    CComBSTR *subsystems;
    hr = SafeArrayAccessData(ps, (void **) &subsystems);
    if (FAILED (hr)) 
    {
        SafeArrayDestroy (ps);
        return E_SAFEARRAY_ERR;
    }       
   
    // walk through the board list and determine the available subsystems
    for (i=0;i<len;i++)
    {	
        wchar_t str[80];
        DevCaps* dc=GetDevCaps(BoardIds[i]);
	if (dc->HasAI())
        {
            swprintf(str,L"analoginput('nidaq',%d)", BoardIds[i]);
	    subsystems[i]=str;
        }
        else
            subsystems[i]=(BSTR)NULL;
	if (dc->HasAO())
        {
            swprintf(str,L"analogoutput('nidaq',%d)", BoardIds[i]);
	    subsystems[i+len]=str;
        }
        else
            subsystems[i+len]=(BSTR)NULL;
	if (dc->HasDIO())
        {
            swprintf(str,L"digitalio('nidaq',%d)", BoardIds[i]);
	    subsystems[i+2*len]=str;
        }
        else
            subsystems[i+2*len]=(BSTR)NULL;
    }

    hRes = pCont->put_MemberValue(L"objectconstructorname",val);
    if (!(SUCCEEDED(hRes))) return hRes;
  
   
    SafeArrayUnaccessData (ps);

    return S_OK;

}