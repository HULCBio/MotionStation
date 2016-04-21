// #$Demo$#DIO.cpp : Implementation of C#$Demo$#DIO
// Copyright 2002-2003 The MathWorks, Inc.
// $Revision: 1.1.6.3 $  $Date: 2003/08/29 04:44:28 $

#include "stdafx.h"
#include "#$Demo$#DIO.h"
#include "#$Demo$#Adapt.h"
#include "#$Demo$#PropDefs.h"

/////////////////////////////////////////////////////////////////////////////
// C#$Demo$#DIO()  default constructor for the Digital Input/Output subsystem object
//
// Function performs all the necessary initializations.
//
// Function is MODIFIED for ALL adaptors.
//
// Review TO_DO/END TO_DO sections and make the appropriate changes
//
/////////////////////////////////////////////////////////////////////////////
C#$Demo$#DIO::C#$Demo$#DIO()
{
    // TODO: Add user defined functionality here
}

/////////////////////////////////////////////////////////////////////////////
// ~C#$Demo$#DIO()  default destructor for the Digital Input/Output subsystem object
//
// Function performs all the necessary initializations.
//
// Function is MODIFIED for ALL adaptors.
//
// Review TO_DO/END TO_DO sections and make the appropriate changes
//
/////////////////////////////////////////////////////////////////////////////

C#$Demo$#DIO::~C#$Demo$#DIO()
{
    // TODO: Add user defined functionality here
}

/////////////////////////////////////////////////////////////////////////////
// Open()	:	local function
//
// This function is called by the C#$Demo$#Adapt::OpenDevice() during the Digital IO
// subsystem object creation process. This function is called when the user enters
// "digitalio('<this_adaptor_name>', ID)" at the MATLAB command line.
//
// This function should be used to:
// 	1. Initialize the specified hardware and hardware dependent properties..
// 	2. Set property connection points (pointers) to the DAQ engine. These are used
//     if a property callback is to be called when the property is set
// 	3. Initialize the DAQHWINFO structure properties for the specified object/hardware
//
// Input:	Interface(IUnknown*): Pointer to main DAQ engine interface
//			ID(long)			: The specified hardware identified to associate with object
//
// Output:	Status(HRESULT)		: Return value from member function 		
//
// Function is MODIFIED for ALL adaptors.
// Review TO_DO/END TO_DO sections and make the appropriate changes
//////////////////////////////////////////////////////////////////////////////
HRESULT C#$Demo$#DIO::Open(IUnknown *Interface, long ID)
{
    HRESULT hRes;

    // Call mwDevice::Open() to initialize Engine pointers
    RETURN_HRESULT(TBaseObj::Open(Interface));

	// Store requested board ID
	_boardID = ID;
	
	// TODO: Open up connection to the requested board and perform any 
	// configuration needed for analog input operation
	// 	EX: HardwareSDKOpenHardware(BOARDID);
	
	// Configure DAQHWINFO properties
	RETURN_HRESULT(SetDaqHwInfo());

	// **************************************************************************
	// *** Configure ADAPTOR SPECIFIC properties for the Digital IO objects ***
	// **************************************************************************
	
#$AddDevSpecificCode#$
	
	// **********************************
	// *** Configure Line Property ***
	// **********************************
	
	// Line Properties are handled slightly differently in that, 
	// local variables aren't generally created for each line property for each channel.
	// The general case will be to set the valid range and values and register property 
	// set notification by defining a constant value to use.

	CComPtr<IProp> IPropPtr;
    
    // TODO: Configure the LineName Line property (optional)
    hRes = GetChannelProperty(L"LineName", &IPropPtr); // Connect to default property
    hRes = IPropPtr->put_User((long)LINENAME); // Configure for property set notification
    hRes = IPropPtr->put_DefaultValue(CComVariant("FunnyName"));	// Configure default value

	// Must free property pointer
   IPropPtr.Release();
	
	// END TO_DO

    return S_OK;
} // end of Open()


/////////////////////////////////////////////////////////////////////////////
// SetDaqHwInfo() :	local funciton
//
// This functions properly configures the DAQHWINFO structure. This structure is called
// when the user enters "daqhwinfo(ao)" at the MATLAB command line. This function must configure
// the following DAQHWINFO properties:
//		AdaptorName: (string)		
//		DeviceName: (string)
//		ID: (integer)
//		Port : (structure)
//		SubsystemType: (string)
//		TotalLines: (integer)
//		VendorDriverDescription: (string)
//		VendorDriverVersion: (string)
//
// NOTE: In most cases, scalars can be passed directly as variants. For non-scalar settings,
// safearrays need to be created to pass the data back to the engine.  
// 
// Function is MODIFIED for ALL adaptors.
// Review TO_DO/END TO_DO sections and make the appropriate changes
/////////////////////////////////////////////////////////////////////////////

HRESULT C#$Demo$#DIO::SetDaqHwInfo()
{
	CComVariant tempVar;	// temp COM variant
    
	// 	_DaqHwInfo :	Holds the pointer to the DAQ Engines daqhwinfo structure.
	//					Inherited from CmwDevice and set during object construction			

	// ADAPTORNAME: (string): name of the adaptor
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"adaptorname",variant_t(C#$Demo$#Adapt::ConstructorName)));

	// SUBSYSTEMTYPE: (string): the substem identifier string
    DEBUG_HRESULT(_DaqHwInfo->put_MemberValue(L"subsystemtype",CComVariant(L"DigitalIO")));

	//	TODO: Configure Adaptor Hardware Info properties

	// DEVICENAME: (string): the name of the device with the specified device ID
		// Ex: 	char _boardName[50];
		// 		HardwareSDKGetBoardName(_boardID, &_boardName);
		//		RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"devicename",CComVariant(_boardName)));
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"devicename",CComVariant("#$Demo$# Emulator"))); // Example of hardcoded name

	// ID: (integer): the board id associated with this AI object
	wchar_t idStr[8];
	swprintf(idStr, L"%d", _boardID); // Converts from integer to a char
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"id", CComVariant(idStr)));		

	// PORT: (structure): defines the numebr of ports, the included lines,
	//						direction, and the configuration of the port(s).
	
		// Define the number of ports
		short NumPorts = 2;
		
		// Create a SafeArray Vector to hold port struture
	    CreateSafeVector((long*)NULL, NumPorts, &tempVar);
	    TSafeArrayAccess<long> pPorts(&tempVar);
	
		// Define Port Line Masks
		pPorts[0] = 0xff; // 8 lines 
		pPorts[1] = 0x0f; // 4 lines 
		    
		// Total number of lines
		int NumOfLines = 8+4;
		    
		// Define internal port line masks (defines which lines are in use in which ports)    
		RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"portlinemasks",tempVar));
	
		// Define Port Directions
		pPorts[0] = DIO_OUTPUT; 	// OUTPUT ONLY
		pPorts[1] = DIO_INPUT;	    // INPUT ONLY 
		RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"portdirections",tempVar));
	
		// Define Port IDs
		pPorts[0] = 0; // Port 0
		pPorts[1] = 1; // Port 1
		RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"portids",tempVar));
	
		// Define Port/Line Configuration 
		//  		0 = PORT conifgurable, all lines need to be the same direction
		//			1 = LINE configurable, line direction can vary within the same port
		pPorts[0] = 0; // PORT Configurable
		pPorts[1] = 0; // PORT Configurable
		RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"portlineconfig",tempVar));

	// TOTALLINES:	The total number of lines for the specified hardware    
		// Ex:	short _maxLines = HardwareSDKGetNumberOfLines(_boardID);    
		//		RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"totallines",CComVariant(_maxLines)));
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"totallines",CComVariant(NumOfLines)));
	    	    
	// VENDORDRIVERDESCRIPTION: (string): A descriptive name of the underlying hardware driver
		//	This value may be queried from the hardware SDK if supported.
   RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"vendordriverdescription",
			CComVariant(L"Simulated Hardware Driver")));
 
	// VENDORDRIVERVERSION: (string): A description of the version number of the underlying driver
		//	This value may be queried from the hardware SDK if supported.
    RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"vendordriverversion",CComVariant(L"Version 1.0a")));
 
	// END TO_DO
	    
    return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
// ReadValues()	:	ImwDIO Interface
//
// This function is called to read values from the specified digital ports.
// This function is called when the user enters "getvalue()" at the MATLAB
// command line.
//
// Input:	NumberOfPorts(LONG)	: Number of Ports to be read
//			PortList(LONG*)		: Pointer to the list of port identifiers
//			Data(UNSIGNED LONG*): Pointer to location where data should be placed		
//
// Output:	Status(HRESULT)		: Return value from member function
//			Data(UNSIGNED LONG*): Read data place at defined address 		
//
// Function is MODIFIED for ALL adaptors.
// Review TO_DO/END TO_DO sections and make the appropriate changes
//////////////////////////////////////////////////////////////////////////////
	    
STDMETHODIMP C#$Demo$#DIO::ReadValues(long NumberOfPorts, long *PortList, unsigned long *Data)
{   
	
    int iLoop;
    HRESULT hr = S_OK;  //HRESULT status

    // if Data is NULL pointer, return error
    if (Data == NULL)
	return E_FAIL;

    // Loop through each port, reading data and then placing it at Data Pointer
    // NOTE: Each port, place data into consecutive locations at Data.

    for (iLoop = 0; iLoop<NumberOfPorts; iLoop++)
    {
    	// TODO: Define implementation to read data from digital input port
    	
    	// Read from port *(PortList+iLoop)
    	// Store read data *(Data+iLoop)
    	// Ex
 
	 	//*************************************
		// TODO:  THE FOLLOWING IS CODE IS ONLY PROVIDED FOR DEMONSTATION USE 
		//        and should be REMOVED.
		*(Data+iLoop) = 0x0A; 	// 00001010
		
		//*************************************
 
     	// END TO_DO

		if (!SUCCEEDED(hr))
		    return E_FAIL;
    }
    return hr;
}

/////////////////////////////////////////////////////////////////////////////
// WriteValues()	:	ImwDIO Interface
//
// This function is called to write values to the specified digital ports.
// This function is called when the user enters "putvalue()" at the MATLAB
// command line. The MASK argument is used to know which lines are to be written
// to when the port is configured for bi-directional operation.
//
// Input:	NumberOfPorts(LONG)	: Number of Ports to be read
//			PortList(LONG*)		: Pointer to the list of port identifiers
//			Data(UNSIGNED LONG*): Pointer to location where the data to output is
//			Mask(UNSIGNED LONG*): Pointer to write mask		
//
// Output:	Status(HRESULT)		: Return value from member function
//
// Function is MODIFIED for ALL adaptors.
// Review TO_DO/END TO_DO sections and make the appropriate changes
//////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////
STDMETHODIMP C#$Demo$#DIO::WriteValues(long NumberOfPorts, long *PortList, unsigned long *Data, unsigned long *Mask)
{
    int iLoop;
    HRESULT hr = S_OK;  //HRESULT status

    // if Data is NULL pointer, return error
    if (Data == NULL)
	return E_FAIL;

    // Loop through each port, writing data at Data Pointer
    // NOTE: Each port, read data from consecutive locations at Data.

    for (iLoop = 0; iLoop<NumberOfPorts; iLoop++)
    {
    	// TODO: define implementation to write data out digital output ports
    	
    	// Read data *(Data+iLoop)
    	// Write data to port *(PortList+iLoop)

    	// END TO_DO
 
		if (!SUCCEEDED(hr))
		    return E_FAIL;
    }
    return hr;
}

/////////////////////////////////////////////////////////////////////////////
// SetPortDirection()	:	ImwDIO Interface
//
// This function is called when the user changes the direction of any line in 
// the specified port. The DirectionValue argument specifies a mask that indicates
// the direction if each line in the port.
//
// Input:	Port(long)			: Port that has changed
//			DirectionValues(unsigned long)	: Pointer to line direction mask
//												1 - INPUT
//												0 - OUTPUT
//
// Output:	Status(HRESULT)		: Return value from member function 		
//
// Function is MODIFIED for ALL adaptors.
// Review TO_DO/END TO_DO sections and make the appropriate changes
//////////////////////////////////////////////////////////////////////////////
STDMETHODIMP C#$Demo$#DIO::SetPortDirection(long Port, unsigned long DirectionValues)
{
    
    	// TODO: Define port direction change implementation
    	
    	// Ex.: Call into hardware to change port/line direction.
    	
    	// END TO_DO
    	
    	return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
// ChildChange()	:	ImwDevice Interface
// 
// This function is called any time there is a change to a channel  
// configuration. The engine may call this function several times for
// one change to the channel group:
// For ADD:		called once,	 	(1) START_CHANGE|ADD_CHILD|END_CHANGE
//	   DELETE:	called three times,	(1) START_CHANGE|DELETE_CHILD
//									(2) DELETE_CHILD
//									(3) DELETE_CHILD|END_CHANGE
// The objective 
// is to prepair a channel list and check for any settings
// that might conflict. 
//
// Input:	typeofchange(DWORD)		: Indicates the type of change as specified 
//										in daqmexstructs.h
//			pChan(NESTABLEPROP*)	: A pointer to the channel structure for 
//										channel being modified
//
// Output:	Status(HRESULT)			: Return value from member function 		
//			pChan(NESTABLEPROP*)	: A pointer to the channel structure being 
//										returned after modifications
//	
// Function is MODIFIED for ALL adaptors.
// Review TO_DO/END TO_DO sections and make the appropriate changes
//////////////////////////////////////////////////////////////////////////////
STDMETHODIMP C#$Demo$#DIO::ChildChange(DWORD typeofchange, NESTABLEPROP *pChan)
{
    if (typeofchange & START_CHANGE)
    {
		// TODO: Process start of channel change
    }
    if ((typeofchange & CHILDCHANGE_REASON_MASK)== ADD_CHILD)
    {
		// TODO: Process added channel
    }
    else if ((typeofchange & CHILDCHANGE_REASON_MASK)== REINDEX_CHILD)
    {
		// TODO: Process re-indexed channel
    }
    else if ((typeofchange & CHILDCHANGE_REASON_MASK)== DELETE_CHILD)
    {
		// TODO: Process deleted channel
    }
    if (typeofchange & END_CHANGE)
    {
		// TODO: Process end of channel change
    }
    
    return S_OK;
}
