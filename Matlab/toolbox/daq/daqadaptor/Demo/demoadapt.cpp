// DemoAdapt.cpp : Implementation of CDemoAdapt class
// Copyright 1998-2003 The MathWorks, Inc.
// $Revision: 1.3.4.3 $  $Date: 2003/08/29 04:44:16 $


#include "stdafx.h"
#include "Demo.h"
#include "DemoAdapt.h"


#include "sarrayaccess.h" // safe array helper routines for use with daq adaptors
#include "DemoAin.h"
#include "DemoAout.h"

//definition of the static member variable, which holds the adaptor..
//.."friendly name"
OLECHAR CDemoAdapt::ConstructorName[100] = {L'\0'};

/////////////////////////////////////////////////////////////////////////////
// Default constructor
//
// The default constructor extracts the adaptor "friendly name" from the ..
//..program name in the registry (where it is put by the DECLARE_REGISTRY..
//..macro.
// Function is NOT MODIFIED for the simple adaptor.
/////////////////////////////////////////////////////////////////////////////
CDemoAdapt::CDemoAdapt()
{
	if (ConstructorName[0]=='\0')
	{
		LPOLESTR str=NULL;
		HRESULT res = OleRegGetUserType( CLSID_DemoAdapt,
										 USERCLASSTYPE_SHORT, &str );
		if (SUCCEEDED(res)) // if this fails the else probaby will to..
		{
			StringToLower(str,ConstructorName);
		}
		else
		{
			wcscpy(ConstructorName,L"Fix Me");
		}
		CoTaskMemFree(str);
	}
} // end of default constructor


/////////////////////////////////////////////////////////////////////////////
// Destructor
//
// Function is NOT MODIFIED for the simple adaptor.
/////////////////////////////////////////////////////////////////////////////
CDemoAdapt::~CDemoAdapt()
{
} // end of destructor


/////////////////////////////////////////////////////////////////////////////
// TranslateError()
//
// Function is called by the engine to translate an error code into..
//..a readable error message.
// CDemoAdapt::TranslateError() calls CmwDevice::TranslateError, defined in..
//..AdaptorKit.cpp
// Function is NOT MODIFIED by the adaptor programmer.
/////////////////////////////////////////////////////////////////////////////
HRESULT CDemoAdapt::TranslateError(HRESULT code,BSTR *out)
{
    return CmwDevice::TranslateError(code,out);
} // end TranslateError()


/////////////////////////////////////////////////////////////////////////////
// AdaptorInfo()
//
// The function is used to elicit relevant info about the current HW..
//..configuration from the HW API.
//  The info to extract is:
//..1)number of boards installed
//..2)board names
//..3)supported subsystems (AnalogInput, AnalogOutput, DigitalIO)
// The function is called by the engine in response to the ML user..
//..command DAQHWINFO
// Function MUST BE MODIFIED by the adaptor programmer.
/////////////////////////////////////////////////////////////////////////////
HRESULT CDemoAdapt::AdaptorInfo(IPropContainer * Container)
{
    int i = 0;          // Index variable

    //place the adaptor name in the appropriate struct in the engine.
    HRESULT hRes = Container->put_MemberValue(L"adaptorname",variant_t(ConstructorName));
    if (!(SUCCEEDED(hRes))) return hRes;

	//get the name of the adaptor module
    TCHAR name[256];
    CComVariant var;

    GetModuleFileName(_Module.GetModuleInstance(),name,256); // null returns matlabs version (non existant)

    hRes = Container->put_MemberValue(L"adaptordllname",CComVariant(name));
    if (!(SUCCEEDED(hRes)))
		return hRes;

    // Make a list of board names the easy way
    LPCOLESTR boardnames[]={L"Demo Board 0",L"Demo Board 1"};
    RETURN_HRESULT(CreateSafeVector(boardnames,2,&var));
    RETURN_HRESULT(Container->put_MemberValue(L"boardnames",var));

    var.Clear();
    // Return a list of board numbers and number of installed boards.

    TSafeArrayVector<CComBSTR> IDs;


//TO_DO: find the actual number of boards and their IDs from the HW via API
// remove the lines, marked as "bogus"  if the "real" values are educed from the HW

    // Number of boards installed
	short len = 2;		//--bogus-- Get it from HW

    IDs.Allocate(len);

	IDs[0] = L"0";		//--bogus-- Get it from HW
	IDs[1] = L"1";		//--bogus-- Get it from HW
//END TO_DO


    // Now build up subsystems arrays -- up to 3 subsystems per board
	SAFEARRAY *ps;
    CComBSTR *subsystems;
    SAFEARRAYBOUND arrayBounds[2];

    arrayBounds[0].lLbound = 0;
    arrayBounds[0].cElements = len;
    arrayBounds[1].lLbound = 0;
    arrayBounds[1].cElements = 3;

    ps = SafeArrayCreate(VT_BSTR, 2, arrayBounds);
    if (ps==NULL)
        throw "Failure to access SafeArray.";

    var.parray = ps;
    var.vt = VT_ARRAY | VT_BSTR;
    hRes = SafeArrayAccessData(ps, (void **)&subsystems);
    if (FAILED (hRes))
    {
        SafeArrayDestroy (ps);
        return hRes;
    }

//TO_DO: elicit the available subsystems for each board from the HW (via API)
// Remove the lines, marked as "bogus"  if the "real" values are educed from the HW
    wchar_t str[40];

	for (i=0; i<len; i++)
    {
		bool ai=true;		//--bogus--
		bool ao=true;		//--bogus--
		bool dio=false;		//--bogus--
//END TO_DO

		//initialize subsystems[] to change it later inside if statements (if needed)
		subsystems[i].Append("");  // Showing three different ways to set safearray.
		subsystems[i+len]=(BSTR)NULL;
		subsystems[i+2*len].Append((BSTR)NULL);

		if (ai)
		{
			swprintf(str, L"analoginput('%s',%s)", (wchar_t*)ConstructorName, (wchar_t*)IDs[i]);
			subsystems[i]=str;
		}

		if (ao)
		{
			swprintf(str, L"analogoutput('%s',%s)", (wchar_t*)ConstructorName, (wchar_t*)IDs[i]);
			subsystems[i+len]=str;
		}

		if (dio)
		{
			swprintf(str, L"digitalio('%s',%s)",(wchar_t*) ConstructorName, (wchar_t*)IDs[i]);
			subsystems[i+2*len]=str;
		}
    }//enf for

    SafeArrayUnaccessData (ps);
    hRes = Container->put_MemberValue(L"objectconstructorname",var);
    if (!(SUCCEEDED(hRes))) return hRes;

    // Return the board numbers to the engine
	var.Clear();			//reuse the same 'var' variable for the IDs[]
	IDs.Detach(&var);
    RETURN_HRESULT(Container->put_MemberValue(L"installedboardids",var));

    return S_OK;
} // end of AdaptorInfo()


/////////////////////////////////////////////////////////////////////////////
// OpenDevice()
//
// Function is called by the engine in the response to the ML user request..
//..to open an adaptor. It has two goals:
//..1)to dispatch the correct Open() function, defined in the demo.cpp
//..2)to populate and return to the engine the pointer to the ImwDevice ..
//..interface, which is used in consequtive calls from the engine into the..
//..adaptor.
// Function MUST BE MODIFIED by the adaptor programmer.
//////////////////////////////////////////////////////////////////////////////
HRESULT CDemoAdapt::OpenDevice(REFIID riid,   long nParams, VARIANT __RPC_FAR *Param,
                               REFIID EngineIID,
                               IUnknown __RPC_FAR *pIEngine,
                               void __RPC_FAR *__RPC_FAR *ppIDevice)
{
    if (ppIDevice == NULL)
        return E_POINTER;

    long id = 0; // default to an id of 0
    if (nParams>1)
          return Error("Too many input arguments to DEMO constructor.");
    if (nParams == 1)
    {
        RETURN_HRESULT(VariantChangeType(Param,Param,0,VT_I4));
        id = Param[0].lVal;
    }

    bool Success = FALSE;
	CComPtr<ImwDevice> pDevice;

//TO_DO: remove this block if Analog input is NOT implemented
	if ( InlineIsEqualGUID(__uuidof(ImwInput),riid))
    {
        CDemoAin *Ain = new CComObject<CDemoAin>();
		RETURN_HRESULT(Ain->Open((IDaqEngine*)pIEngine,id));
        pDevice=Ain;
		Success = TRUE;
    }
//END TO_DO

//TO_DO: remove this block if Analog output is NOT implemented

	if ( InlineIsEqualGUID(__uuidof(ImwOutput),riid))
	{
        CDemoAout *Aout = new CComObject<CDemoAout>();
		RETURN_HRESULT(Aout->Open((IDaqEngine*)pIEngine,id));
        pDevice=Aout;
		Success = TRUE;
	}

//END TO_DO

//TO_DO: remove this block if Digital input/output is NOT implemented
/*
	if ( InlineIsEqualGUID(__uuidof(ImwDIO),riid))
	{
        CDemoDio *dio = new CComObject<CDemoDio>();
		RETURN_HRESULT(dio->Open((IDaqEngine*)pIEngine,id));
        pDevice=dio;
		Success = TRUE;
	}
*/
//END TO_DO

    if ( Success )
	    return pDevice->QueryInterface(riid,ppIDevice);
    else
        return E_FAIL;
} // end of OpenDevice()



