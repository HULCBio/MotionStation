// ParallelAdapt.cpp : Implementation of CParallelAdapt
//
// Copyright 1998-2003 The MathWorks, Inc.
// $Author: batserve $
// $Revision: 1.1.6.1 $  $Date: 2003/10/15 18:32:30 $


#include "stdafx.h"
#include "mwparallel.h"
#include "ParallelAdapt.h"
#include "ParallelDriver.h"
#include "ParallelDio.h"

#include "sarrayaccess.h" // safe array helper routines for use with daq adaptors

/////////////////////////////////////////////////////////////////////////////
// CParallelAdapt

// definition of the static member variable, which holds the adaptor "friendly name"
// The default constructor extracts the adaptor "friendly name" from the ..
// program name in the registry (where it is put by the DECLARE_REGISTRY macro. 
// Function is NOT MODIFIED for the simple adaptor.

OLECHAR CParallelAdapt::ConstructorName[100] = {L'\0'};

CComVariant CParallelAdapt::DeviceName = L"PC Parallel Port Hardware";

/////////////////////////////////////////////////////////////////////////////
//
// Default constructor
//
/////////////////////////////////////////////////////////////////////////////
CParallelAdapt::CParallelAdapt()
{
    // Set the ParallelPort Driver to the not initialized state;
    ParallelPort.bInitialized = FALSE;

    // Clear the available BoardIDs
    BoardIDs.Empty();

    // Initialize PortAddrs
    PortAddrs[0] = NULL;
    PortAddrs[1] = NULL;
    PortAddrs[2] = NULL;

    // Get the contructor name
    if (ConstructorName[0]=='\0')
    {
	LPOLESTR str=NULL;
	// Read value from registry
	HRESULT res = OleRegGetUserType( CLSID_ParallelAdapt, USERCLASSTYPE_SHORT, &str );
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
/////////////////////////////////////////////////////////////////////////////

CParallelAdapt::~CParallelAdapt()
{
    // Remove the ParallelPort Driver
    ParallelPort.CloseDriver();
    
} // end of destructor


/////////////////////////////////////////////////////////////////////////////
// TranslateError()
//
// Function is called by the engine to translate an error code into..
//..a readable error message.
// CParallelAdapt::TranslateError() calls CmwDevice::TranslateError, defined in..
//..AdaptorKit.cpp
/////////////////////////////////////////////////////////////////////////////

HRESULT CParallelAdapt::TranslateError(HRESULT code,BSTR *out)
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

HRESULT CParallelAdapt::AdaptorInfo(IPropContainer * Container)
{
    // Check to see if Driver is intialized
    if (!ParallelPort.bInitialized)
	if (SUCCEEDED(ParallelPort.InitDriver()))
	{
	    ParallelPort.bInitialized = TRUE;
	    
	    // Determine avaliable Ports and IDs
	    HRESULT hRes = ParallelPort.GetAvailPorts(BoardIDs, &PortAddrs[0]);
	}
	else
	    return E_FAIL;

        // Initialize Driver


    // Determine the Adaptor Name
    
    //place the adaptor name in the appropriate struct in the engine.
    HRESULT hRes = Container->put_MemberValue(L"adaptorname",variant_t(ConstructorName));
    if (!(SUCCEEDED(hRes))) return hRes;
    
    
    // Determine the Adaptor DLL Name
    
    TCHAR name[256];  // store the Adaptor DLL Name
    GetModuleFileName(_Module.GetModuleInstance(),name,256); // null returns matlabs version (non existant)
    hRes = Container->put_MemberValue(L"adaptordllname",CComVariant(name));
    if (!(SUCCEEDED(hRes)))
	return hRes;
    
    // Determine BoardNames
    
    hRes = Container->put_MemberValue(L"boardnames",DeviceName);
    if (!(SUCCEEDED(hRes))) return hRes;
    
    // extract the number of ports
    int numports = BoardIDs.Length();
    
    // Create constructor string Array (NumOfPorts x 3 DAQ Subsystems)
    // Now build up subsystems arrays -- up to 3 subsystems per board
//    CComVariant varSubSytem;
    VARIANT varSubSytem;
    CComBSTR *subsystems;
    SAFEARRAY *pSubSys;
    SAFEARRAYBOUND arrayBounds[2]; 
    
    // Define array bounds
    arrayBounds[0].lLbound = 0;	//Rows
    arrayBounds[0].cElements = numports;    
    arrayBounds[1].lLbound = 0; // Columns
    arrayBounds[1].cElements = 3;    
    
    // Construct a SafeArray
    pSubSys = SafeArrayCreate(VT_BSTR, 2, arrayBounds);
    if (pSubSys!=NULL)
    {    
	// Associate SafeArray with Variant
	varSubSytem.parray = pSubSys;
	varSubSytem.vt = VT_ARRAY | VT_BSTR;
	hRes = SafeArrayAccessData(pSubSys, (void **)&subsystems);
	if (SUCCEEDED(hRes)) 
	{	    
	    // Create an array to hold the BoardIDs
	    VARIANT varIDS;
	    SAFEARRAY *pIDS;
	    CComBSTR *bstrIDs;
	    SAFEARRAYBOUND aBounds[1]; 
	    
	    aBounds[0].lLbound = 0;
	    aBounds[0].cElements = numports;    
	    
	    // Construct a SafeArray
	    pIDS = SafeArrayCreate(VT_BSTR, 1, arrayBounds);
	    if (pIDS!=NULL)
	    {
		// Associate SafeArray with Variant
		varIDS.parray = pIDS;
		varIDS.vt = VT_ARRAY | VT_BSTR;
		hRes = SafeArrayAccessData(pIDS, (void **)&bstrIDs);
		if (SUCCEEDED(hRes)) 
		{	   		    
		    // Define Constructor strings and IDs
		    wchar_t str[40];
		    
		    // Loop through each found port   
		    for (int i=0; i<numports; i++)
		    {	
			// Store Board ID in array
			swprintf(str, L"LPT%c", BoardIDs[i]);
			bstrIDs[i] = str;
			
			//initialize subsystems[] to change it later inside if statements (if needed)
			subsystems[i] =(BSTR)NULL; //AnalogInput
			subsystems[i+numports]=(BSTR)NULL; //AnalogOutput
			
			// Supports Digital I/O
			swprintf(str, L"digitalio('%s','LPT%c')",(wchar_t*)ConstructorName, BoardIDs[i]);
			subsystems[i+2*numports]=str;
			
		    }//end for
		    
		    // Send Constructor names to DAQENGING
		    hRes = Container->put_MemberValue(L"objectconstructorname",varSubSytem);
		    
		    // Send Board IDs to DAQENGING		    
		    hRes = Container->put_MemberValue(L"installedboardids",varIDS);
		}
		// Destroy IDs SafeArray
		SafeArrayUnaccessData (pIDS);    
		SafeArrayDestroy (pIDS);
	    }
	}
	// Destroy SubSystem SafeArray
	SafeArrayUnaccessData (pSubSys);    
	SafeArrayDestroy (pSubSys);
    }
    return hRes;
    
} // end of AdaptorInfo()

//
//
//
   

/////////////////////////////////////////////////////////////////////////////
// OpenDevice()
//
// Function is called by the engine in the response to the ML user request..
//..to open an adaptor. It has two goals:
//..1)to dispatch the correct Open() function for CParallelDIO class
//..2)to populate and return to the engine the pointer to the ImwDevice ..
//..interface, which is used in consequtive calls from the engine into the..
//..adaptor.
// Function MUST BE MODIFIED by the adaptor programmer.
//////////////////////////////////////////////////////////////////////////////
HRESULT CParallelAdapt::OpenDevice(REFIID riid,   long nParams, VARIANT __RPC_FAR *Param,
                               REFIID EngineIID,
                               IUnknown __RPC_FAR *pIEngine,
                               void __RPC_FAR *__RPC_FAR *ppIDevice)
{
    // Check to see if Driver is intialized
    if (!ParallelPort.bInitialized)
	if (SUCCEEDED(ParallelPort.InitDriver()))
	{
	    ParallelPort.bInitialized = TRUE;
	    
	    // Determine avaliable Ports and IDs
	    HRESULT hRes = ParallelPort.GetAvailPorts(BoardIDs, &PortAddrs[0]);
	}
	else
	    return E_FAIL;

    CComBSTR port;
    BSTR temp1, temp2;
    long PortAddress;

    if (ppIDevice == NULL)
        return E_POINTER;
    
    // Too many arguments specified
    if (nParams>=2)
		return E_INVALIDARG;
    
    // If no ID is specified, assume LPT1 
    if (nParams==0)
	{
		PortAddress = 1;
		port = "LPT1";
	}
    else if (nParams==1)
    {
		// get ID specified
		port = Param->bstrVal;
		// If in the format of 'LPTx'
		if (port.Length() == 4)
		{	    
			// Get the last character (ID NUMBER x)
			// Extract the string (BSTR)
			temp1 = port.Copy();
			// Get the 4th character
			temp2 = temp1+3;
			// Use as port address
			PortAddress = _wtoi(temp2);
		}
		// ID format, use as ID
		else if (port.Length() == 1)
		{
			PortAddress = _wtoi(port);
			// Convert to 'LPTx' format
			temp1 = port.Copy();
			port = L"LPT";
			port.Append(temp1);
		}
		// Incorrect ID specifier
		else
			return Error(E_INVALID_DEVICE_ID);	    
    }
    // Determine Port Address
    if ((PortAddress >= 1) && (PortAddress <=3))
    {
		PortAddress = PortAddrs[PortAddress-1];
		if (PortAddress==NULL)
			return E_FAIL;
    }	
    else 
		return E_INVALID_DEVICE_ID;
    
	
    bool Success = FALSE;
    CComPtr<ImwDevice> pDevice;
    
    // Create DIO Class Object
    
    if ( InlineIsEqualGUID(__uuidof(ImwDIO),riid))
    {
		CParallelDio *ParDio = new CComObject<CParallelDio>();
		RETURN_HRESULT(ParDio->Open((IDaqEngine*)pIEngine, port, PortAddress));
		pDevice=ParDio;
		Success = TRUE;
    }
    
    // Get a pointer to the new DIO object
    if ( Success )
		return pDevice->QueryInterface(riid,ppIDevice);
    else
        return E_FAIL;

} // end of OpenDevice()
