// mwwinsound.cpp : Implementation of DLL Exports.
// For DAQ Partners, mwexample.cpp

// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.1.6.1 $  $Date: 2003/10/15 18:33:49 $


//		If you are not running WinNT4.0 or Win95 with DCOM, then you
//		need to remove the following define from dlldatax.c
//		#define _WIN32_WINNT 0x0400
//
//		Further, if you are running MIDL without /Oicf switch, you also 
//		need to remove the following define from dlldatax.c.
//		#define USE_STUBLESS_PROXY
//
//		Modify the custom build rule for mwwinsound.idl by adding the following 
//		files to the Outputs.
//			mwwinsound_p.c
//			dlldata.c
//		To build a separate proxy/stub DLL, 
//		run nmake -f mwwinsoundps.mk in the project directory.

#include "stdafx.h"
#include "resource.h"
#include "initguid.h"
#include "daqmex.h"
//For DAQ Partners, comment out the following three lines
#include "mwwinsound.h"
#include "mwwinsound_i.c"
//For DAQ Partners, uncomment the following line
//#include "mwexample.h"
//#include "mwexample_i.c"

#include "SoundAD.h"
#include "SoundDA.h"

#ifdef _DEBUG
#undef THIS_FILE
#undef DEBUG_NEW
static char THIS_FILE[]=__FILE__;
#define DEBUG_NEW new(_NORMAL_BLOCK, THIS_FILE, __LINE__)
#define new DEBUG_NEW
#endif

CComModule _Module;

BEGIN_OBJECT_MAP(ObjectMap)
        OBJECT_ENTRY(CLSID_Adaptor, CAdaptor)
//	OBJECT_ENTRY_NON_CREATEABLE( SoundAD)
	OBJECT_ENTRY_NON_CREATEABLE( SoundDA)
END_OBJECT_MAP()

/////////////////////////////////////////////////////////////////////////////
// DLL Entry Point

static CSemaphore LoadCount(0,_T("WinsoundLoadCount"));
extern "C"
BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, LPVOID lpReserved)
{
	lpReserved;
	if (dwReason == DLL_PROCESS_ATTACH)
	{
            int count=LoadCount.Release(1)+1;
			// For DAQ Partners, change the word mwwinsound to example
            ATLTRACE("mwwinsound process attach. Lock count is %d LoadCount is %d\n",_Module.GetLockCount(),count);
		_Module.Init(ObjectMap, hInstance);
		DisableThreadLibraryCalls(hInstance);
	}
	else if (dwReason == DLL_PROCESS_DETACH)
        {
		// For DAQ Partners, change the word mwwinsound to example
             ATLTRACE("mwwinsound process detach.\n");

            _Module.Term();
            LoadCount.Wait(0);
        }
	return TRUE;    // ok
}

/////////////////////////////////////////////////////////////////////////////
// Used to determine whether the DLL can be unloaded by OLE

STDAPI DllCanUnloadNow(void)
{
#ifdef _DEBUG
			// For DAQ Partners, change the word Sound to example
        ATLTRACE("Attempt to unload Sound driver count is %d.\n",_Module.GetLockCount());
#endif
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
	_Module.UnregisterServer();
	return S_OK;
}

STDMETHODIMP CAdaptor::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&__uuidof(ImwAdaptor)
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


STDMETHODIMP CAdaptor::OpenDevice(REFIID riid,   long nParams, VARIANT __RPC_FAR *Param,
                             REFIID EngineIID,
                             IUnknown __RPC_FAR *pIEngine,
                             void __RPC_FAR *__RPC_FAR *ppIDevice)
{
    CComPtr<ImwDevice> pDevice;
    long id=0; // default to an id of 0
    if (nParams>=1)
    {
        if (nParams>1)
            return Error("Too many input arguments to WINSOUND constructor.");

        RETURN_HRESULT(VariantChangeType(Param,Param,0,VT_I4));
        id=Param[0].lVal;
    }
    if ( InlineIsEqualGUID(__uuidof(ImwInput),riid))
    {
        SoundAD *Ain=new CComObject<SoundAD>();
        pDevice=Ain;
        RETURN_HRESULT(Ain->Open((IDaqEngine*)pIEngine,id));
    }
    else if ( InlineIsEqualGUID(__uuidof(ImwOutput),riid))
    {
        SoundDA *Aout=new CComObject<SoundDA>();
        pDevice=Aout;
        RETURN_HRESULT(Aout->Open((IDaqEngine*)pIEngine,id));
    }
    else
        return E_FAIL;

    RETURN_HRESULT(pDevice->QueryInterface(riid,ppIDevice));
    return S_OK;
}

STDMETHODIMP CAdaptor::TranslateError(HRESULT code,BSTR *out)
{
    TCHAR lpMsgBuf[401];
    
    int size=LoadString(_Module.GetResourceInstance(), code, lpMsgBuf,400);
    
    if (size)         
        *out = CComBSTR(lpMsgBuf).Detach();
    else
    {
        if (waveInGetErrorText (code, lpMsgBuf, sizeof(lpMsgBuf))==MMSYSERR_BADERRNUM)
        {
            _tcscpy(lpMsgBuf,_T("Unknown Error"));
            FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM /*| FORMAT_MESSAGE_FROM_HMODULE */,_Module.GetResourceInstance() , code,
                MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), // Default language
                lpMsgBuf, 400,   NULL ); 
            
        }
        *out = CComBSTR(lpMsgBuf).Detach();
    } 
    return S_OK;
}

HRESULT CAdaptor::AdaptorInfo(IPropContainer *pCont)
{    
    
    HRESULT hRes = pCont->put_MemberValue(CComBSTR(L"adaptorname"),CComVariant(L"winsound"));
    if (!(SUCCEEDED(hRes))) return hRes;
    
    TCHAR name[256];
    GetModuleFileName(_Module.GetModuleInstance(),name,256); // null returns MATLABs version (non existant)

    hRes = pCont->put_MemberValue(CComBSTR(L"adaptordllname"),CComVariant(name));
    if (!(SUCCEEDED(hRes))) return hRes;  
   
    CWaveInCaps WaveCaps;
    
	// InstalledBoardIds.
    UINT nInputDevs=waveInGetNumDevs();
    UINT nOutputDevs=waveOutGetNumDevs();
    UINT nDevs=max(nInputDevs,nOutputDevs);

    // now allocate tempary buffers

    std::vector<int> ids(nDevs);
    std::vector<CComBSTR> Names(nDevs);

    int validDevs=0;
    UINT i;
    for (i=0;i<nDevs;i++) 
    {
        Names[validDevs]=(BSTR)WaveCaps.GetDeviceName(i);
        if (Names[validDevs])
        {
            ids[validDevs]=i;
            validDevs++;
        }
    }

    nDevs=validDevs;

    SAFEARRAY *boardids = SafeArrayCreateVector(VT_BSTR, 0, nDevs);
    if (boardids==NULL) 
        throw "Failure to create SafeArray.";   
    
    CComBSTR *stringids=NULL;
    CComVariant bids;   
    
    bids.parray=boardids;
    bids.vt = VT_ARRAY | VT_BSTR;           
    
    hRes = SafeArrayAccessData(boardids, (void **) &stringids);
    if (FAILED (hRes)) {
        SafeArrayDestroy (boardids);
        throw "Failure to access SafeArray data.";
    }

    wchar_t str[80];
    for (i=0;i<nDevs;i++) {	
		swprintf(str,L"%d",ids[i]);
		stringids[i] = str;
    }  

	SafeArrayUnaccessData(boardids);
    hRes = pCont->put_MemberValue(CComBSTR(L"installedboardids"),bids);   
    if (!(SUCCEEDED(hRes))) return hRes;    

	bids.Clear();

    // BoardNames.
	SAFEARRAY *ps = SafeArrayCreateVector(VT_BSTR, 0, nDevs);
    if (ps==NULL) 
	throw "Failure to create SafeArray.";   

    CComBSTR *strings=NULL;
    CComVariant val;   

    val.parray=ps;
    val.vt = VT_ARRAY | VT_BSTR;           

    hRes = SafeArrayAccessData(ps, (void **) &strings);
    if (FAILED (hRes)) 
    {
        SafeArrayDestroy (ps);
        throw "Failure to access SafeArray data.";
    }

    for (i=0;i<nDevs;i++)
    {	
	strings[i]=Names[i];
    }  
    SafeArrayUnaccessData(ps);
    hRes = pCont->put_MemberValue(CComBSTR(L"boardnames"),val);
    if (!(SUCCEEDED(hRes))) return hRes;

    val.Clear();  
    
	// ObjectConstructorName.
    // There are 2 subsystems for each card plus dio which is empty
    SAFEARRAYBOUND arrayBounds[2];  
    arrayBounds[0].lLbound = 0;
    arrayBounds[0].cElements = nDevs;    
    arrayBounds[1].lLbound = 0;
    arrayBounds[1].cElements = 3;    
    ps = SafeArrayCreate(VT_BSTR, 2, arrayBounds);
    if (ps==NULL)
        throw "Failure to access SafeArray.";      

    val.parray=ps;
    val.vt = VT_ARRAY | VT_BSTR;           
    
    hRes = SafeArrayAccessData(ps, (void **) &strings);
    if (FAILED (hRes)) 
    {
        SafeArrayDestroy (ps);
        throw "Failure to access SafeArray data.";
    }       

    // allocation handled by the CComBSTR overloaded '='    
    for (i=0;i<nDevs;i++)
    {
        wchar_t str[40];
		// analog input
        if (i<nInputDevs)
        {
            swprintf(str,L"analoginput('winsound',%d)",ids[i]);
            strings[i]=str;
        }
		// analog output
        if (i<nOutputDevs)
        {
            swprintf(str,L"analogoutput('winsound',%d)",ids[i]);
            strings[i+nDevs]=str;
        }
		// digital i/o
		swprintf(str,L"");
	    strings[i+2*nDevs]=str;
    }
    SafeArrayUnaccessData(ps);

    hRes = pCont->put_MemberValue(CComBSTR(L"objectconstructorname"),val);
    if (!(SUCCEEDED(hRes))) return hRes;
    
    return S_OK;
}

