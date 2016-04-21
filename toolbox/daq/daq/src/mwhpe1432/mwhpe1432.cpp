// mwwinsound.cpp : Implementation of DLL Exports.
// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.1.6.1 $  $Date: 2003/10/15 18:31:06 $



// Note: Proxy/Stub Information
//
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
#include "mwhpe1432.h"
#include "mwhpe1432_i.c"
#include "hpvxiAD.h"
#include "hpvxiDA.h"
#include "util.h"
#include <vector>
#include "errors.h"

CComModule _Module;
bool globalCallbackInstalled = false;

ViInt32 globalGidAO = NULL;
ViInt32 globalGidAI = NULL;
std::vector<long> _installedCallbackIDs;
std::vector<long> globalIdList;
long numFound = 0;
ViInt32 addList[255] = {0};

BEGIN_OBJECT_MAP(ObjectMap)
	OBJECT_ENTRY(CLSID_hpvxiDA, hpvxiDA)
	OBJECT_ENTRY(CLSID_hpvxiAD, hpvxiAD)
END_OBJECT_MAP()

/////////////////////////////////////////////////////////////////////////////
// DLL Entry Point

extern "C"
BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, LPVOID lpReserved)
{
	lpReserved;
	if (dwReason == DLL_PROCESS_ATTACH)
	{
            ATLTRACE("hpe1432 process attach.\n");
		_Module.Init(ObjectMap, hInstance);
		DisableThreadLibraryCalls(hInstance);

		// Need to initialize for all hardware at once.
		// get info on installed hardware.
		//ViChar rsrc[255];

		// 0        (input ) - not used so can be 0.
		// addList  (output) - An array to hold VXI logical addresses of HP E1432 modules.
		// 255      (input ) - the size of addList;
		// numFound (output) - the number of HP E1432 modules found.
		// rsrc -   (output) - resource name for the first module found.
		// 255 -    (input ) - size of the rsrc buffer.
//		ViStatus findStatus = hpe1432_find(0, addList, 255, &numFound, rsrc, 255);
//		if (findStatus != 0){
		//	numFound = 0;
//		}
	}
	else if (dwReason == DLL_PROCESS_DETACH)
        {
             ATLTRACE("hpe1432 process detach.\n");

            _Module.Term();
        }
	return TRUE;    // ok
}

/////////////////////////////////////////////////////////////////////////////
// Used to determine whether the DLL can be unloaded by OLE

STDAPI DllCanUnloadNow(void)
{
#ifdef _DEBUG
        if (_Module.GetLockCount()>0)
        {
            ATLTRACE("Attempt to unload hpvxi driver\n");
        }
#endif
	return (_Module.GetLockCount()==0) ? S_OK : S_FALSE;
}


HRESULT hpvxiAD::OpenDevice(REFIID riid,   long nParams, VARIANT __RPC_FAR *Param,
                             REFIID EngineIID,
                             IUnknown __RPC_FAR *pIEngine,
                             void __RPC_FAR *__RPC_FAR *ppIDevice)
{
    CComPtr<ImwDevice> pDevice;
    bstr_t devName;

    //long id=0; // default to an id of 0
    if (nParams>2)
          return Error("Too many input arguments to HPE1432 constructor.");
    if (nParams==2)
    {
        bstr_t bstr(Param[0]);
        bstr_t bstr2(Param[1]);
        if (iswpunct(((wchar_t*)bstr)[0]))
            return E_INVALID_DEVICE_ID;
        else if (iswpunct(((wchar_t*)bstr)[0]))
            return E_INVALID_DEVICE_ID;
        else if (iswdigit(((wchar_t*)bstr)[0]))
            devName=L"VXI"+bstr2+"::"+bstr+"::INSTR"; 

    } 
    else if (nParams==1)
    {
        bstr_t bstr(Param[0]);
        if (iswdigit(((wchar_t*)bstr)[0]))   
            devName=L"VXI0::"+bstr+"::INSTR";     
        else if (iswpunct(((wchar_t*)bstr)[0])){
            // A negative ID value was given.
            return E_INVALID_DEVICE_ID;
        }else{
            devName=bstr;
        }
    }
    else 
        return E_MUST_DEFINE_ID;

    if ( InlineIsEqualGUID(__uuidof(ImwInput),riid))
    {
        hpvxiAD *Ain=new CComObject<hpvxiAD>();
        pDevice=Ain;
        RETURN_HRESULT(Ain->Open((IDaqEngine*)pIEngine,devName));
    }
    else if ( InlineIsEqualGUID(__uuidof(ImwOutput),riid))
    {
        hpvxiDA *Aout=new CComObject<hpvxiDA>();
        pDevice=Aout;
        RETURN_HRESULT(Aout->Open((IDaqEngine*)pIEngine,devName));
    }
    else
        return E_FAIL;

    RETURN_HRESULT(pDevice->QueryInterface(riid,ppIDevice));
    return S_OK;
}

HRESULT hpvxiAD::AdaptorInfo(IPropContainer *pCont)
{    
	// Initialize variables.
	ViSession session;

        if (numFound == 0){
            DAQ_CHECK(Find1432Boards());
        }

	// If the hardware has not been initialized yet.  Initialize it.
    DAQ_CHECK(GetGlobalSession(session));
		
	// Get the hardware config information.
    ViInt32 *configInfo = new ViInt32[27*numFound];        
    memset(configInfo, 0, 27*numFound*sizeof(long));
    hpe1432_getHWConfig(0, numFound, addList, configInfo);    
    
    // Set the AdaptorName to hpe1432.
    DAQ_CHECK(pCont->put_MemberValue(CComBSTR(L"adaptorname"),CComVariant(L"hpe1432")));

    // Set the AdaptorDLLName.
    TCHAR name[256];
    GetModuleFileName(_Module.GetModuleInstance(),name,256); // null returns MATLABs version (non existant)
    
    DAQ_CHECK(pCont->put_MemberValue(CComBSTR(L"adaptordllname"),CComVariant(name)));        


	// determine if analog input is supported.
    int *inputChans=new int[numFound];
    memset(inputChans, 0, numFound*sizeof(int));

    for (int i=0; i<numFound; i++) {
        inputChans[i]=configInfo[21+(27*i)];
    }

    // determine the number of sources available
    int *sourceChans=new int[numFound];
    memset(sourceChans, 0, numFound*sizeof(int));

    for (i=0; i<numFound; i++) {
        sourceChans[i]=configInfo[22+(27*i)];
    }

	// InstalledBoardIds.
    long nDevs=numFound;

	SAFEARRAY *boardids = SafeArrayCreateVector(VT_BSTR, 0, nDevs);
	if (boardids==NULL) 
        throw "Failure to create SafeArray.";   
    
    CComBSTR *stringids=NULL;
    CComVariant bids;   
    
    bids.parray=boardids;
    bids.vt = VT_ARRAY | VT_BSTR;           
    
    HRESULT hRes = SafeArrayAccessData(boardids, (void **) &stringids);
    if (FAILED (hRes)) {
        SafeArrayDestroy (boardids);
        throw "Failure to access SafeArray data.";
    }

    wchar_t str[80];
    for (i=0;i<nDevs;i++) {	
		swprintf(str,L"VXI::%d::INSTR",addList[i]);
		stringids[i] = str;
    }  

	SafeArrayUnaccessData(boardids);
    DAQ_CHECK(pCont->put_MemberValue(CComBSTR(L"installedboardids"),bids));   

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
    if (FAILED (hRes)) {
        SafeArrayDestroy (ps);
        throw "Failure to access SafeArray data.";
    }
    
    for (i=0;i<nDevs;i++){	
	    switch (configInfo[6+(27*i)]) {
		case HPE1432_SCA_ID_VIBRATO:
			strings[i]=L"HP E1432A";
			break;
		case HPE1432_SCA_ID_NONE:               
			strings[i]=L"HP E1434A";
			break;
	    case HPE1432_SCA_ID_SONATA:
	        strings[i]="HP E1433A";
		case -842150451:
			strings[i]=L"HP E1433A";
 			break;
		default:
			strings[i] = L"unknown";
		}
    }  
    
    SafeArrayUnaccessData(ps);
    hRes = pCont->put_MemberValue(CComBSTR(L"boardnames"),val);
    if (!(SUCCEEDED(hRes))) return hRes;
        
    val.Clear();  
    
    // ObjectConstructorName.
    // There are at most two subsystems for each card.
    SAFEARRAYBOUND arrayBounds[2];  
    arrayBounds[0].lLbound = 0;
    arrayBounds[0].cElements = nDevs;    
    arrayBounds[1].lLbound = 0;
    arrayBounds[1].cElements = 2;    
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
        wchar_t str[80];

		// Create analog input constructor if supported.
		if (inputChans[i]){
			swprintf(str,L"analoginput('hpe1432','VXI::%d::INSTR')",addList[i]);
			strings[i]=str;
		}else{
			strings[i]=(BSTR)NULL;
		}

		// Create analog output constructor if supported.
        if (sourceChans[i]){
            swprintf(str,L"analogoutput('hpe1432','VXI::%d::INSTR')",addList[i]);
            strings[i+nDevs]=str;
        }else{
            strings[i+nDevs]=(BSTR)NULL;     
		}
    }    

    SafeArrayUnaccessData(ps);

    hRes = pCont->put_MemberValue(CComBSTR(L"objectconstructorname"),val);
    if (!(SUCCEEDED(hRes))) return hRes;

	delete [] inputChans;  inputChans  = NULL;
    delete [] sourceChans; sourceChans = NULL;
    delete [] configInfo;

    return S_OK;
}

// Callback.
void globalCallback(ViInt32 a, ViInt32 b){

	// This calls the appropriate callback (either AD or DA);
	if (hpvxiDA::RunningDAPtr) 
		hpvxiDA::RunningDAPtr->srcCallback(b);
	if (hpvxiAD::RunningADPtr)
		hpvxiAD::RunningADPtr->Callback(b);
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


