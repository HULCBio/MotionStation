// advantechadapt.cpp : Implementation of Cadvantechadapt class
// Copyright 2002-2003 The MathWorks, Inc.
// $Revision: 1.1.6.1 $  $Date: 2003/10/15 18:30:25 $

#include "stdafx.h"
#include "mwadvantech.h"
#include "advantechadapt.h"
#include "advantecherr.h"   // Advantech error codes

#include "sarrayaccess.h"	// safe array helper routines for use with daq adaptors
#include "advantechain.h"	// Advantech Analog Input class
#include "advantechaout.h"
#include "advantechdio.h"
#include "driver.h"

// Definition of the static member variable, which holds the adaptor "friendly name"
OLECHAR Cadvantechadapt::ConstructorName[100] = {L'\0'};

/////////////////////////////////////////////////////////////////////////////
// Default constructor
//
// The default constructor extracts the adaptor "friendly name" from the
// program name in the registry (where it is put by the DECLARE_REGISTRY
// macro. 
// Function is NOT MODIFIED for the simple adaptor.
/////////////////////////////////////////////////////////////////////////////
Cadvantechadapt::Cadvantechadapt()
{
	if (ConstructorName[0]=='\0')
	{
		LPOLESTR str=NULL;
		HRESULT res = OleRegGetUserType( CLSID_advantechadapt,
			USERCLASSTYPE_SHORT, &str );
		if (SUCCEEDED(res)) // if this fails the else probaby will to..
		{
			StringToLower(str,ConstructorName);
		}
		else
		{
			wcscpy(ConstructorName,L"Constructor Name not found!!!");
		}
		CoTaskMemFree(str);
	}
} // end of default constructor


/////////////////////////////////////////////////////////////////////////////
// Destructor
//
// Function is NOT MODIFIED for the simple adaptor.
/////////////////////////////////////////////////////////////////////////////
Cadvantechadapt::~Cadvantechadapt()
{
	// Clear the OpenDevs vector.
    if (OpenDevs.size()>=1)
    {
        long opencount=reinterpret_cast<long&>(OpenDevs.front());
        if (opencount>0)
        {
#ifdef _DEBUG
            _RPT0(_CRT_ERROR,"Deleting adaptor with open devices.\n");
#endif
            OpenDevs.clear();
        }
    }
} // end of destructor


/////////////////////////////////////////////////////////////////////////////
// TranslateError()
//
// Function is called by the engine to translate an error code into
// a readable error message.
// Cadvantechadapt::TranslateError() calls CmwDevice::TranslateError, defined in
// AdaptorKit.cpp
// Function is NOT MODIFIED by the adaptor programmer.
/////////////////////////////////////////////////////////////////////////////
HRESULT Cadvantechadapt::TranslateError(HRESULT code,BSTR *out)
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
/////////////////////////////////////////////////////////////////////////////
HRESULT Cadvantechadapt::AdaptorInfo(IPropContainer * Container)
{
	LONG lDriverHandle = (LONG)NULL;          // driver handle
	PT_DeviceGetFeatures ptDevFeatures;		// Devfeatures table
	DEVFEATURES DevFeatures;					// structure for device features
	
	int i = 0;          // Index variable
	
	// Get the name of the adaptor module
	TCHAR name[256];
	GetModuleFileName(_Module.GetModuleInstance(),name,256); // null returns MATLAB version (non existant)
	RETURN_HRESULT(Container->put_MemberValue(L"adaptordllname",CComVariant(name)));
	
	// Place the adaptor name in the appropriate struct in the engine.
	RETURN_HRESULT(Container->put_MemberValue(L"adaptorname",variant_t(ConstructorName)));
	
	// Find board IDs
	// Start by obtaining the DeviceList. Not stored.
	short numDevices;			// Number of devices
	DEVLIST deviceList[MaxDev]; // Space to store device information.
	CComVariant var;			// General CComVariant to return info to adaptor engine.
	RETURN_ADVANTECH(DRV_DeviceGetList((DEVLIST far *)&deviceList[0], MaxDev, &numDevices));
	
	// Create storage for board IDs, bord names and constructors.
	TSafeArrayVector<CComBSTR> IDs;			// Create A SafeArrayVector to store the IDs in
	IDs.Allocate(numDevices);				// Allocate the memory for the number of devices
	TSafeArrayVector<CComBSTR> Names;		// Create A SafeArrayVector to store the Names in
	Names.Allocate(numDevices);				// Allocate the memory for the number of devices
	SAFEARRAY *ps;							// SafeArray for the subsystem support [nDx3 CComBStrs]
	CComBSTR *subsystems;
	SAFEARRAYBOUND arrayBounds[2]; 
	arrayBounds[0].lLbound = 0;
	arrayBounds[0].cElements = numDevices;    
	arrayBounds[1].lLbound = 0;
	arrayBounds[1].cElements = 3;			// AnalogInput, AnalogOutput, DigitalIO subsystems.
	ps = SafeArrayCreate(VT_BSTR, 2, arrayBounds);
	if (ps==NULL)
		return E_FAIL;      
	
	// Set up the variant to contain subsystem constructor SafeArray
	var.parray = ps;
	var.vt = VT_ARRAY | VT_BSTR;
	HRESULT hRes = SafeArrayAccessData(ps, (void **)&subsystems);
	if (FAILED (hRes)) 
	{
		SafeArrayDestroy (ps);
		return hRes;
	}
	
	// Now loop through each device, getting the ID, BoardName and subsystem support.
	wchar_t str[40];
	for (i=0; i < numDevices; i++)
	{
		// Allocate the ID
		char* string;
		string = new char[20];
		_ltoa(deviceList[i].dwDeviceNum, string, 10);
		IDs[i] = CComBSTR(string);
		
		// Open Device
		RETURN_ADVANTECH(DRV_DeviceOpen(deviceList[i].dwDeviceNum,(LONG far *)&lDriverHandle));
		
		// Get BoardNames info
		Names[i] = CComBSTR(deviceList[i].szDeviceName);
		
		// Check to see which subsystems the current board supports.
		// Get device features
		ptDevFeatures.buffer = (LPDEVFEATURES)&DevFeatures;
		ptDevFeatures.size = sizeof(DEVFEATURES);
		RETURN_ADVANTECH(DRV_DeviceGetFeatures(lDriverHandle, (LPT_DeviceGetFeatures)&ptDevFeatures));
		if ((DevFeatures.usMaxAIDiffChl + DevFeatures.usMaxAISiglChl) > 0) 
		{
			swprintf(str, L"analoginput('%s',%s)", (wchar_t*)ConstructorName, (wchar_t*)IDs[i]);
			subsystems[i]=str;
		}
		if (DevFeatures.usMaxAOChl > 0)
		{
			swprintf(str, L"analogoutput('%s',%s)", (wchar_t*)ConstructorName, (wchar_t*)IDs[i]);
			subsystems[i + numDevices]=str;
		}
		if ((DevFeatures.usMaxDIChl + DevFeatures.usMaxDOChl) > 0)
		{
			swprintf(str, L"digitalio('%s',%s)",(wchar_t*) ConstructorName, (wchar_t*)IDs[i]);
			subsystems[i + 2*numDevices] = str;
		}  
		// Close device
		RETURN_ADVANTECH(DRV_DeviceClose((LONG far *)&lDriverHandle));
	}
	
	// Return Object Constructor Names since they're in var already.
	SafeArrayUnaccessData (ps);    
	RETURN_HRESULT(Container->put_MemberValue(L"objectconstructorname",var));
	
	// Return the board names
	var.Clear();			// resuse the same 'var' variable for the boardnames.
	Names.Detach(&var);
	RETURN_HRESULT(Container->put_MemberValue(L"boardnames",var));
	
	// Return the board numbers
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
//..1)to dispatch the correct Open() function, defined in the advantech.cpp
//..2)to populate and return to the engine the pointer to the ImwDevice ..
//..interface, which is used in consequtive calls from the engine into the..
//..adaptor.
/////////////////////////////////////////////////////////////////////////////
HRESULT Cadvantechadapt::OpenDevice(REFIID riid,   long nParams, VARIANT __RPC_FAR *Param,
                                    REFIID EngineIID,
                                    IUnknown __RPC_FAR *pIEngine,
                                    void __RPC_FAR *__RPC_FAR *ppIDevice)
{
	if (ppIDevice == NULL)
		return E_POINTER;
	
	long id = 0;  // Storage for the device id passed by the user
	if (nParams>1)
		return Error("Too many input arguments to advantech constructor.");
	if (nParams == 1)
	{
		RETURN_HRESULT(VariantChangeType(Param,Param,0,VT_I4));
		id = Param[0].lVal;
	}
	if (nParams==0)
	{
		// The default device is the first in the device list:
		short numDevices;
		DEVLIST deviceList[MaxDev]; // Space to store device information.
		RETURN_ADVANTECH(DRV_DeviceGetList((DEVLIST far *)&deviceList[0], MaxDev, &numDevices));
		id = deviceList[0].dwDeviceNum;
	}
	
	// Attempt to create the device:
	bool Success = false;
	CComPtr<ImwDevice> pDevice;
	
	// Create new AnalogInput object
	if ( InlineIsEqualGUID(__uuidof(ImwInput),riid))
	{
		CadvantechAin *Ain = new CComObject<CadvantechAin>();
		RETURN_HRESULT(Ain->Open((IDaqEngine*)pIEngine,id));
		Ain->SetParent(this);
		pDevice=Ain;
		Success = true;
	}
	
	// Create new AnalogOutput object 	
	if ( InlineIsEqualGUID(__uuidof(ImwOutput),riid))
	{
		CadvantechAout *Aout = new CComObject<CadvantechAout>();
		RETURN_HRESULT(Aout->Open((IDaqEngine*)pIEngine,id));
		Aout->SetParent(this);
		pDevice=Aout;
		Success = true;
	}
	
	// Create new DigitalIO object	
	if (InlineIsEqualGUID(__uuidof(ImwDIO),riid))
	{
		CadvantechDio *DIO = new CComObject<CadvantechDio>();
		RETURN_HRESULT(DIO->Open((IDaqEngine*)pIEngine,id));
		pDevice=DIO;
		Success = true;
    }
	
	if (Success)
		return pDevice->QueryInterface(riid,ppIDevice);
	else
		return E_FAIL;
} // end of OpenDevice()


//////////////////////////////////////////////////////////////////////////////
// AddDev()
//
// Used to maintain a list of running device IDs and subsytems.
//////////////////////////////////////////////////////////////////////////////
HRESULT Cadvantechadapt::AddDev(DWORD id,void *dev)
{
	OPENDEVLIST::iterator devStruct = GetIteratorFromID(id);
	if (devStruct==NULL)
	{
		DEV newStruct;
		newStruct.deviceID = id;
		newStruct.ptr = dev;
		OpenDevs.push_back(newStruct);
	    return S_OK;
	}
	else
	{
		return E_FAIL;
	}
}


//////////////////////////////////////////////////////////////////////////////
// DeleteDev()
//
// Used to maintain a list of running device IDs and subsytems.
//////////////////////////////////////////////////////////////////////////////
HRESULT Cadvantechadapt::DeleteDev(DWORD id)
{
	OPENDEVLIST::iterator devStruct = GetIteratorFromID(id);
	if (devStruct==NULL)
	{
		return E_FAIL;
	}
	else
	{
		OpenDevs.erase(devStruct);
	    return S_OK;
	}
}

