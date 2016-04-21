// #$Demo$#Adapt.cpp : Implementation of C#$Demo$#Adapt class
// Copyright 2002-2003 The MathWorks, Inc.
// $Revision: 1.1.6.3 $  $Date: 2003/08/29 04:44:31 $

#include "stdafx.h"
#include "#$Demo$#.h"
#include "#$Demo$#Adapt.h"

#include "sarrayaccess.h" // safe array helper routines for use with daq adaptors

#$StartAICut$##include "#$Demo$#Ain.h"#$EndAICut$#
#$StartAOCut$##include "#$Demo$#Aout.h"#$EndAOCut$#
#$StartDIOCut$##include "#$Demo$#DIO.h"#$EndDIOCut$#

// definition of the static member variable, which holds the adaptor "friendly name"
OLECHAR C#$Demo$#Adapt::ConstructorName[100] = {L'\0'};

/////////////////////////////////////////////////////////////////////////////
// Default constructor
//
// The default constructor extracts the adaptor "friendly name" from the 
// program name in the registry (where it is put by the DECLARE_REGISTRY macro
//
// Function is NOT MODIFIED for the simple adaptor.
/////////////////////////////////////////////////////////////////////////////
C#$Demo$#Adapt::C#$Demo$#Adapt()
{
	if (ConstructorName[0]=='\0')
	{
		LPOLESTR str=NULL;
		HRESULT res = OleRegGetUserType(CLSID_#$Demo$#Adapt, USERCLASSTYPE_SHORT, &str );
		// Check to see if registry entry was found
		if (SUCCEEDED(res)) 
		{
		    StringToLower(str,ConstructorName);
		}
		else
		{
		    // Registry entry was not found, use temporary name
		    wcscpy(ConstructorName,L"Fix Me");
		}
		CoTaskMemFree(str);
	} // end if
} // end of default constructor


/////////////////////////////////////////////////////////////////////////////
// Destructor
//
// Function is NOT MODIFIED for the simple adaptor.
/////////////////////////////////////////////////////////////////////////////
C#$Demo$#Adapt::~C#$Demo$#Adapt()
{
} // end of destructor


/////////////////////////////////////////////////////////////////////////////
// TranslateError()
//
// Function is called by the engine to translate an error code into 
// a readable error message.

// C#$Demo$#Adapt::TranslateError() calls CmwDevice::TranslateError, defined 
// in AdaptorKit.cpp

// Function is NOT MODIFIED for the simple adaptor.
/////////////////////////////////////////////////////////////////////////////
HRESULT C#$Demo$#Adapt::TranslateError(HRESULT code,BSTR *out)
{
    return CmwDevice::TranslateError(code,out);
} // end TranslateError()


/////////////////////////////////////////////////////////////////////////////
// AdaptorInfo()
//
// The function is used to determine relevant information about the hardware  
// supported by this adaptor. Most of the information gathered in this function 
// will be used to populate the DAQHWINFO() structure.
//
// This function must be modifed to define the specifics of this adaptor. Most
// likely, calls into the hardware SDK will be used to determine and return 
// approriate values.
//
// This function must populate the following DAQHWINFO fields:
//		adaptorname
//		adaptordllname
// 		adaptordllversion
//		boardnames
//		boardIDs
//		objectconstructors
//
// Function is MODIFIED for ALL adaptors.
// Review TO_DO/END TO_DO sections and make the appropriate changes
/////////////////////////////////////////////////////////////////////////////

HRESULT C#$Demo$#Adapt::AdaptorInfo(IPropContainer * Container)
{
    int i = 0;          // Index variable
    
    ////////////////////////////////////////////////////////////////
    // Define the adaptor name (ADAPTORNAME)
    ////////////////////////////////////////////////////////////////
    HRESULT hRes = Container->put_MemberValue(L"adaptorname",variant_t(ConstructorName));
    if (!(SUCCEEDED(hRes))) return hRes;
    
    ////////////////////////////////////////////////////////////////
    // Define the name of the adaptor module (file) (ADAPTORDLLNAME)
    ////////////////////////////////////////////////////////////////
    TCHAR name[256];
    CComVariant var;
    GetModuleFileName(_Module.GetModuleInstance(),name,256); // null returns matlabs version (non existant)
    hRes = Container->put_MemberValue(L"adaptordllname",CComVariant(name));
    if (!(SUCCEEDED(hRes)))
	return hRes;
    
    ////////////////////////////////////////////////////////////////
    // Define the version of the adaptor file (dll) (ADAPTORDLLVERSION)
    ////////////////////////////////////////////////////////////////
 
    // This is done automatically by the DAQ ENGINE. The DAQ ENGINE extracts the VS_VERISON_INFO
    // structure and uses this data to fill in this field. The information can be set in the 
    // adaptors resource file (#$Demo$#.rc)
        
    ////////////////////////////////////////////////////////////////
    // Define the boards currently installed and supported by this adaptor (BOARDNAMES)
    ////////////////////////////////////////////////////////////////
    
    /* TODO: Need to populate array with boards found
    Ex: LPCOLESTR ARRAY[]= HardwareSDKFindBoards();
    
    Ex: Statically defines two boards found */
    LPCOLESTR boardnames[]={L"#$Demo$# Board 0",L"#$Demo$# Board 1"};
    int iNumBoardsFound = 2;
    // END TO_DO
    
    // Put board names into COM Variant as a safevector
    RETURN_HRESULT(CreateSafeVector(boardnames, iNumBoardsFound, &var));
    RETURN_HRESULT(Container->put_MemberValue(L"boardnames",var));
    var.Clear();
    
    ////////////////////////////////////////////////////////////////
    // Define a list of board index numbers along with the appropriate
    // constructors for the supported subsystems (i.e. AI,AO, DIO)
    ////////////////////////////////////////////////////////////////
     
    TSafeArrayVector<CComBSTR> IDs;
    
    // Set up array to hold Board ID numbers
    IDs.Allocate(iNumBoardsFound);
    
    // TODO: Determine board ID numbers
    //  	Ex IDs[x] = HardwareSDKFindBoardIDs();
    IDs[0] = L"0";		// Example Board 0
    IDs[1] = L"1";		// Example Board 1
    // END TO_DO
    
    
    // Define supported subsystems and store in array
    // Subsystems include; AnalogInput, AnalogOutput, DigitalIO
    
    SAFEARRAY *ps;
    CComBSTR *subsystems;
    SAFEARRAYBOUND arrayBounds[2];
    
    arrayBounds[0].lLbound = 0;
    arrayBounds[0].cElements = iNumBoardsFound;
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

    wchar_t str[40]; // temporary constructor string
    
    // Loop through each board found, and build appropriate constructor string
    for (i=0; i<iNumBoardsFound; i++)
    {
	// Determine if board supports Analog Input
	// Determine if board supports Analog Output
	// Determine if board supports Digital Input/Output
	
	// Ex ai = HardwareSDKIsAnalogInputSupported(BOARDID);
	// Ex ao = HardwareSDKIsAnalogOutputSupported(BOARDID);
	// Ex dio = HardwareSDKIsDigitalIOSupported(BOARDID);
	
	// TODO:	Define supported subsystems
	bool ai = #$StartAICut$#true;  // or #$EndAICut$# false;		// Example: AI supported?
	bool ao = #$StartAOCut$#true;  // or #$EndAOCut$# false;		// Example: AO supported?
	bool dio = #$StartDIOCut$#true;  // or #$EndDIOCut$# false;		// Example: DIO supported?
	
	// END TO_DO
	
	// initialize subsystems[] to change it later inside if statements (if needed)
	subsystems[i].Append("");  // Showing three different ways to set safearray.
	subsystems[i+iNumBoardsFound]=(BSTR)NULL;
	subsystems[i+2*iNumBoardsFound].Append((BSTR)NULL);
	
	if (ai)
	{
	    swprintf(str, L"analoginput('%s',%s)", (wchar_t*)ConstructorName, (wchar_t*)IDs[i]);
	    subsystems[i]=str;
	}
	
	if (ao)
	{
	    swprintf(str, L"analogoutput('%s',%s)", (wchar_t*)ConstructorName, (wchar_t*)IDs[i]);
	    subsystems[i+iNumBoardsFound]=str;
	}
	
	if (dio)
	{
	    swprintf(str, L"digitalio('%s',%s)", (wchar_t*)ConstructorName, (wchar_t*)IDs[i]);
	    subsystems[i+2*iNumBoardsFound]=str;
	}
    }//end for

    ////////////////////////////////////////////////////////////////
    // Define the subsystem constructor strings for installed boards (OBJECTCONSTRUCTORNAME)
    ////////////////////////////////////////////////////////////////
    SafeArrayUnaccessData (ps);
    hRes = Container->put_MemberValue(L"objectconstructorname",var);
    if (!(SUCCEEDED(hRes))) return hRes;
    var.Clear();			//reuse the same 'var' variable for the IDs[]

    ////////////////////////////////////////////////////////////////
    // Define the Board IDs for installed boards (INSTALLEDBOARDIDS)
    ////////////////////////////////////////////////////////////////
    // Return the board numbers to the engine
    IDs.Detach(&var);
    RETURN_HRESULT(Container->put_MemberValue(L"installedboardids",var));

    return S_OK;
} // end of AdaptorInfo()


/////////////////////////////////////////////////////////////////////////////
// OpenDevice()
//
// This function is called by the DAQ engine during MATLAB object creation.
// The goals of this function are to:
// 1) Call the correct Open() function for the specified subsystem. The Open()
//	function actually creates an object and defines default values for that object
// 2)Return a pointer to the DAQMEX engine with the pointer to the subsystem (ImwDevice  
//	interface), which is used in consequtive calls from the engine into the 
//	adaptor.

// Function is NOT MODIFIED for simple adaptors.
//////////////////////////////////////////////////////////////////////////////
HRESULT C#$Demo$#Adapt::OpenDevice(REFIID riid,   long nParams, VARIANT __RPC_FAR *Param,
                               REFIID EngineIID,
                               IUnknown __RPC_FAR *pIEngine,
                               void __RPC_FAR *__RPC_FAR *ppIDevice)
{
    // Check input parameters
    if (ppIDevice == NULL)
        return E_POINTER;
    
    long id = 0; // default to an id of 0
    if (nParams>1)
	return Error("Too many input arguments to #$DEMO$# constructor.");
    if (nParams == 1)
    {
        RETURN_HRESULT(VariantChangeType(Param,Param,0,VT_I4));
        id = Param[0].lVal;
    }
    
    bool Success = FALSE;
    CComPtr<ImwDevice> pDevice;    
#$StartAICut$#
    // Construct new Analog Input subsystem COM object
    if ( InlineIsEqualGUID(__uuidof(ImwInput),riid))
    {
        C#$Demo$#Ain *Ain = new CComObject<C#$Demo$#Ain>();
	RETURN_HRESULT(Ain->Open((IDaqEngine*)pIEngine,id));
        pDevice=Ain;
	Success = TRUE;
    }#$EndAICut$#    
#$StartAOCut$#
    // Construct new Analog Output subsystem COM object    
    if ( InlineIsEqualGUID(__uuidof(ImwOutput),riid))
    {
        C#$Demo$#Aout *Aout = new CComObject<C#$Demo$#Aout>();
	RETURN_HRESULT(Aout->Open((IDaqEngine*)pIEngine,id));
        pDevice=Aout;
	Success = TRUE;
    } #$EndAOCut$#   
#$StartDIOCut$#
    // Construct new Digital Input/Output subsystem COM object    
    if ( InlineIsEqualGUID(__uuidof(ImwDIO),riid))
    {
        C#$Demo$#DIO *dio = new CComObject<C#$Demo$#DIO>();
	RETURN_HRESULT(dio->Open((IDaqEngine*)pIEngine,id));
        pDevice=dio;
	Success = TRUE;
    }#$EndDIOCut$#
    
    // If subsystem was succesfully created, return pointer to it
    if ( Success )
	return pDevice->QueryInterface(riid,ppIDevice);
    else
        return E_FAIL;
} // end of OpenDevice()



