// keithleyadapt.cpp : Implementation of Main Adaptor class
// $Revision: 1.1.6.1 $
// $Date: 2003/10/15 18:31:31 $

// Copyright 2002-2003 The MathWorks, Inc. 
// Coded by OPTI-NUM solutions

#include "stdafx.h"
#include "mwkeithley.h"
#include "keithleyadapt.h"
#include "drvlinx.h"	// DriverLINX API
#include "dlcodes.h"	// DriverLINX message and result codes

#include "sarrayaccess.h" // safe array helper routines for use with daq adaptors
#include "keithleyain.h"
#include "keithleyaout.h"
#include "keithleydio.h"

// Definition of the static member variable, which holds the adaptor
// "friendly name"
OLECHAR Ckeithleyadapt::ConstructorName[100] = {L'\0'};

/////////////////////////////////////////////////////////////////////////////
// Ckeithleyadapt constructor
/////////////////////////////////////////////////////////////////////////////
Ckeithleyadapt::Ckeithleyadapt()
{
	if (ConstructorName[0]=='\0')
	{
		LPOLESTR str=NULL;
		HRESULT res = OleRegGetUserType( CLSID_keithleyadapt, USERCLASSTYPE_SHORT, &str );
		if (SUCCEEDED(res))
		{
			StringToLower(str,ConstructorName);
		}
		else
		{
			wcscpy(ConstructorName,L"Fix Me");	// This should obviously never happen
		}
		CoTaskMemFree(str);
	}
	
	// Get the current window or create one if one is not already created.
	m_KeithleyWnd = MessageWindow::GetKeithleyWnd(); 

} // end of constructor


/////////////////////////////////////////////////////////////////////////////
// ~Ckeithleyadapt()
//
// Ckeithleyadapt destructor
/////////////////////////////////////////////////////////////////////////////
Ckeithleyadapt::~Ckeithleyadapt()
{
	// Release this copy of Window
	m_KeithleyWnd->Release();

	//DEBUG: ATLTRACE("DumpUnfreed() called in Ckeithleyadapt.\n");
	//DEBUG: DumpUnfreed(); // Call Our Memory Checker.
} // end of destructor


/////////////////////////////////////////////////////////////////////////////
// TranslateError()
//
// Function is called by the engine to translate an error code into..
//..a readable error message.
// Ckeithleyadapt::TranslateError() calls CmwDevice::TranslateError, defined in..
//..AdaptorKit.cpp
/////////////////////////////////////////////////////////////////////////////
HRESULT Ckeithleyadapt::TranslateError(HRESULT code,BSTR *out)
{
    return CmwDevice::TranslateError(code,out);
} // end TranslateError()


/////////////////////////////////////////////////////////////////////////////
// AdaptorInfo()
//
// The function is used to elicit relevant info about the current HW..
//..configuration from the HW API.
// The function is called by the engine in response to the ML user..
//..command DAQHWINFO 
/////////////////////////////////////////////////////////////////////////////
HRESULT Ckeithleyadapt::AdaptorInfo(IPropContainer *Container)
{
	int i = 0;          // Index variable

    //place the adaptor name in the appropriate struct in the engine.
    HRESULT hRes = Container->put_MemberValue(L"adaptorname",variant_t(ConstructorName));
    if (!(SUCCEEDED(hRes))) return hRes;

	//get the name of the adaptor module
    TCHAR name[256];
    GetModuleFileName(_Module.GetModuleInstance(),name,256); 
    hRes = Container->put_MemberValue(L"adaptordllname",CComVariant(name));
    if (!(SUCCEEDED(hRes)))
		return hRes;

    short len = m_KeithleyWnd->m_numberOfDevices;
    
	// Return a list of board numbers and number of installed boards. 
    TSafeArrayVector<CComBSTR> IDs;
	IDs.Allocate(len);

	CComVariant var;
	// The following Code sets the board names for the available devices.
	TSafeArrayVector<CComBSTR> Names; // Now Create A SafeArrayVactor to store the Names in
	Names.Allocate(m_KeithleyWnd->m_numberOfDevices); // Allocate the memory for the number of devices

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
   
    wchar_t str[40];
	
	// Iterate through the device map to build up the valid constructors for the
	//  subsystems for each board.
	for (std::vector<DEVICEDETAILS>::iterator it = m_KeithleyWnd->m_deviceMap.begin(); it != m_KeithleyWnd->m_deviceMap.end(); it++)
	{
		short id = (*it).deviceID; // Get the deviceID from the device map
		char* string;
		string = new char[20];
		_itoa(id, string, 10);
		IDs[i] = CComBSTR(string); // Set the ID
		
		// Select the relevant Driver and use it to get the LDD for the card.
		SelectDriverLINX(m_KeithleyWnd->m_driverMap[(*it).driverLookup].driverHandle);
		HANDLE ldd = ::GetLDD(NULL, (*it).deviceID); 
		if (ldd==NULL)
		{
			// Something wrong. Probably not a configured device.
			char tempMsg[255];
			sprintf(tempMsg, "Keithley Error: Device %d not found. Check DriverLINX	Configuration Panel!", (*it).deviceID);
			return CComCoClass<ImwDevice>::Error(tempMsg);
		}

		// Set the Board Name
		char tempstr[15];

		::ReturnMessageString(NULL, ((LDD*)ldd)->DevCap.ModelCode, (LPSTR)tempstr, 15);
		Names[i] = CComBSTR(tempstr); // Set the names

		// Check to see which subsystems the current board supports.
		subsystems[i].Append("");
		subsystems[i+len]=(BSTR)NULL;
		if (SupportsSubSystem((LDD*)ldd, AI))
		{
			swprintf(str, L"analoginput('%s',%s)", (wchar_t*)ConstructorName, (wchar_t*)IDs[i]);
			subsystems[i]=str;
		}
		
		if (SupportsSubSystem((LDD*)ldd, AO))
		{
			swprintf(str, L"analogoutput('%s',%s)", (wchar_t*)ConstructorName, (wchar_t*)IDs[i]);
			subsystems[i+len]=str;
		}
		// MATLAB groups the digital Input and Output subsystems together, but driverLINX
		// does not, so if we support Digital input or ouput, then the MATLAB subsystem is
		// valid.		
		if (SupportsSubSystem((LDD*)ldd, DI) || SupportsSubSystem((LDD*)ldd, DO))
		{
			swprintf(str, L"digitalio('%s',%s)",(wchar_t*) ConstructorName, (wchar_t*)IDs[i]);
			subsystems[i+2*len]=str;
		}  
		
		i++;
		FreeLDD(ldd);
    }	//end for
    SafeArrayUnaccessData (ps);    
    hRes = Container->put_MemberValue(CComBSTR(L"objectconstructorname"),var);
    if (!(SUCCEEDED(hRes))) return hRes; 
   
    // Return the board numbers to the engine
	var.Clear();			//reuse the same 'var' variable for the IDs[]
	IDs.Detach(&var);
    RETURN_HRESULT(Container->put_MemberValue(CComBSTR(L"installedboardids"),var));   

	//Send the Board Names to engine
	var.Clear();	// resuse the same 'var' variable for the boardnames.
	Names.Detach(&var);
	hRes = Container->put_MemberValue(CComBSTR(L"boardnames"),var);
    if (!(SUCCEEDED(hRes))) 
		return hRes; 
       
    return S_OK;
}	// end of AdaptorInfo()


/////////////////////////////////////////////////////////////////////////////
// OpenDevice()
//
// Function is called by the engine in the response to the ML user request..
//..to open an adaptor. It has two goals:
//..1)to dispatch the correct Open() function, defined in the keithley.cpp
//..2)to populate and return to the engine the pointer to the ImwDevice ..
//..interface, which is used in consequtive calls from the engine into the..
//..adaptor.
//////////////////////////////////////////////////////////////////////////////
HRESULT Ckeithleyadapt::OpenDevice(REFIID riid,   
									long nParams, VARIANT __RPC_FAR *Param,
									REFIID EngineIID,
									IUnknown __RPC_FAR *pIEngine,
									void __RPC_FAR *__RPC_FAR *ppIDevice)
{
	if(m_KeithleyWnd->GetError())	// Unable to create the window
	{
		return Error(_T(m_KeithleyWnd->GetErrorMessage()));
	}

	if (ppIDevice == NULL)
        return E_POINTER;

    long id = 0; // default to an id of 0
    if (nParams == 1)
    {
        RETURN_HRESULT(VariantChangeType(Param,Param,0,VT_I4));
        id = Param[0].lVal;
    }

    bool Success = false;
	CComPtr<ImwDevice> pDevice;

	if ( InlineIsEqualGUID(__uuidof(ImwInput),riid))
    {
        Ckeithleyain *Ain = new CComObject<Ckeithleyain>();
		RETURN_HRESULT(Ain->Open((IDaqEngine*)pIEngine,id));
        pDevice=Ain;
		Success = true;
    }

	if ( InlineIsEqualGUID(__uuidof(ImwOutput),riid))
	{
        Ckeithleyaout *Aout = new CComObject<Ckeithleyaout>();
		RETURN_HRESULT(Aout->Open((IDaqEngine*)pIEngine,id));
        pDevice=Aout;
		Success = true;
	}

	if ( InlineIsEqualGUID(__uuidof(ImwDIO),riid))
	{
        Ckeithleydio *Adio = new CComObject<Ckeithleydio>();
		RETURN_HRESULT(Adio->Open((IDaqEngine*)pIEngine,id));
        pDevice=Adio;
		Success = true;
	}

    if ( Success )
	    return pDevice->QueryInterface(riid,ppIDevice);
    else
        return E_FAIL;
}	// end of OpenDevice()


/////////////////////////////////////////////////////////////////////////////
// GetPrivateProfileDouble()
//
// Reads a double from an ini file. Used by by routines in AI and AO.
/////////////////////////////////////////////////////////////////////////////
double GetPrivateProfileDouble(LPCTSTR lpAppName,LPCTSTR lpKeyName,double Default, LPCTSTR lpFileName)
{
    char buf[30],*ptr;
    int outLen=GetPrivateProfileString(lpAppName,lpKeyName,"",buf,29,lpFileName);
    if (outLen==0) return Default;
    double outval=strtod(buf,&ptr);
    if(ptr!=buf)
        return outval;
    else
        return Default;
}

