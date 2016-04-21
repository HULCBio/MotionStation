// advantechdio.cpp - The implementation of the advantech digitalIO device
// $Revision: 1.1.6.3 $
// $Date: 2004/04/08 20:49:28 $
// Copyright 2002-2004 The MathWorks, Inc. 
// Coded by OPTI-NUM solutions


#include "stdafx.h"
#include "mwadvantech.h"
#include "advantechadapt.h"
#include "math.h"
#include "advantechpropdef.h"
#include "advantechdio.h"
#include "advantecherr.h"   // Advantech error codes
#include "advantechUtil.h"	// Advantech Utility functions
#include "driver.h"
#include "adaptorkit.h"

////////////////////////////////////////////////////////////////////////////////////
// Cadvantechdio - Class implementation										      //
////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////
// Cadvantechdio()
//
// Default constructor
////////////////////////////////////////////////////////////////////////////////////
CadvantechDio::CadvantechDio():
m_numInPorts(0),
m_deviceID(0),
m_driverHandle(NULL),
m_configLines(0),
m_inputLines(0),
m_outputLines(0),
m_ports(0)
{
}

////////////////////////////////////////////////////////////////////////////////////
// ~Cadvantechdio()
//
// Destructor
////////////////////////////////////////////////////////////////////////////////////
CadvantechDio::~CadvantechDio()
{
	// Close device handle if it's valid.	
	if (m_driverHandle != NULL)
		DRV_DeviceClose((LONG far *)&m_driverHandle);
}

////////////////////////////////////////////////////////////////////////////////////
// InterfaceSupportsErrorInfo()
//
// Function indicates whether or not an interface supports the IErrorInfo..
//..interface. It is created by the wizard.
// Function is NOT MODIFIED by the adaptor programmer.
////////////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CadvantechDio::InterfaceSupportsErrorInfo(REFIID riid)
{
    static const IID* arr[] = 
    {
        &IID_IadvantechDio
    };
    for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
    {
        if (InlineIsEqualGUID(*arr[i],riid))
            return S_OK;
    }
    return S_FALSE;
}


////////////////////////////////////////////////////////////////////////////////////
// Open()
//  This routine is called when MatLab executes the 'digitalio' instruction. 
//  Several things should be validated at this point. 
////////////////////////////////////////////////////////////////////////////////////
HRESULT CadvantechDio::Open(IUnknown *Interface,long ID)
{
	if (ID<0) 
	{
		return E_INVALID_DEVICE_ID;
	}
	
	RETURN_HRESULT(CmwDevice::Open(Interface));
    
	m_deviceID = static_cast<WORD>(ID);	// Set the Device Number to the requested device number set in Matlab.
	
	short numDevices;
	DEVLIST	deviceList[MaxDev];	// Structure containing list of installed boards (MaxDev is defined in driver.h)
	RETURN_ADVANTECH(DRV_DeviceGetList((DEVLIST far *)&deviceList[0], MaxDev, &numDevices));
	
	DWORD index = -1;
	for (int i=0; i < numDevices; i++)	// Find the deviceID which corresponds to the desired board.
	{
		if (deviceList[i].dwDeviceNum == m_deviceID)
		{
			index = i;
		}
	}
	if (index == -1)
	{
		return E_INVALID_DEVICE_ID;
	}
	strcpy(m_deviceName, deviceList[index].szDeviceName);

	// Open device and check that device number is valid
	RETURN_ADVANTECH(DRV_DeviceOpen(m_deviceID,(LONG far *)&m_driverHandle));
	PT_DeviceGetFeatures ptDevFeatures;
	ptDevFeatures.buffer = (LPDEVFEATURES)&m_devFeatures;
	ptDevFeatures.size = sizeof(DEVFEATURES);
	RETURN_ADVANTECH(DRV_DeviceGetFeatures(m_driverHandle, (LPT_DeviceGetFeatures)&ptDevFeatures));
	
	RETURN_HRESULT(LoadINIInfo());
	RETURN_HRESULT(SetDaqHwInfo());

	return S_OK;
} // end of Open()

////////////////////////////////////////////////////////////////////////////////////
// SetDaqHWInfo()
// Set the fields needed for DaqHwInfo. 
//  It is used when you call daqhwinfo(analoginput('advantech'))
////////////////////////////////////////////////////////////////////////////////////
HRESULT CadvantechDio::SetDaqHwInfo()
{	
	// Adaptor Name
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"adaptorname"), CComVariant(Cadvantechadapt::ConstructorName)));
	
	// Device Name
	char tempstr[15] = "";
	sprintf(tempstr, " (Device %d)", m_deviceID); 
	strcat(m_deviceName, tempstr);					
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"devicename"), CComVariant(m_deviceName)));
	
	// Device ID
	wchar_t idStr2[10];
	swprintf(idStr2, L"%d", m_deviceID );	// Convert the Device id to a string
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"id"), CComVariant(idStr2)));
	
	// Vendor Driver Description
	char vendorDriverDescription[30]; // The place to store the driver description
	// This call gets the value which corresponds to the description, and converts it to a string
	strcpy(vendorDriverDescription, m_devFeatures.szDriverName);
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"vendordriverdescription"),CComVariant(vendorDriverDescription)));
	
	// Vendor Driver Version
	char vendorDriverVersion[30]; // The place to store the driver description
	// This call gets the value which corresponds to the description, and converts it to a string
	strcpy(vendorDriverVersion, m_devFeatures.szDriverVer);
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"vendordriverversion"),CComVariant(vendorDriverVersion)));

	// Sort out the daqhwinfo for the ports
	// This calculates the total number of lines that we have available. We do this first so we know how many
	// different ports we have in total.
	// NOTE: Advantech hardware has either all configurable lines, or no configurable lines!
	if (m_configLines > 0)	
	{
		RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"totallines"), CComVariant(m_configLines)));
	}
	else
	{
		RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"totallines"), CComVariant((m_inputLines + m_outputLines))));
	}

	// Set the rest of the port info
	CComVariant var;
	
	// Here we create the SafeArray we are going to use to set all port values.        
	SAFEARRAY *ps = SafeArrayCreateVector(VT_I4, 0, m_ports );
	if (ps==NULL) 
	{
		return E_FAIL;
	}
	// set the data type and values
	V_VT(&var)=VT_ARRAY | VT_I4;
	V_ARRAY(&var)=ps;
	TSafeArrayAccess <long> ar(&var);  // used to access the array
	
	// These hold the number of ports supported by the device...
	m_numInPorts = 0;	
	int numOutPorts = 0;
	int numConfPorts = 0;
	
	// NOTE: The line IDs are returned as 0 -> 7 for port1 and 0 -> 7 for port2. For the 1710 and 818
	//		 port2 corresponds to the hi byte ie. lines 8 -> 15.
	// PortMasks defined in advantechUtil.h
	int position = 0;
	if ((m_inputLines + m_outputLines)/m_ports == 8 || m_configLines/m_ports == 8) // If ports are 8 lines wide...
	{
		m_numInPorts = m_inputLines/8;  
		numOutPorts = m_outputLines/8;
		numConfPorts = m_configLines/8;	

		// Set up PortLineMasks here
		int numPorts = max((m_numInPorts + numOutPorts) ,m_configLines/8);
		//for (int i=0; i < (m_numInPorts + numOutPorts); i++)
		for (int i=0; i < (numPorts); i++)
		{ 
			ar[position] = portMask8; 
			position++;
		}
	}
	else if ((m_inputLines + m_outputLines)/m_ports == 16)	// This for PCL730, has ports 16 lines wide
	{
		m_numInPorts = m_inputLines/16;  
		numOutPorts = m_outputLines/16;

		// Set up PortLineMasks here
		for (int i=0; i < (m_numInPorts + numOutPorts); i++) 
		{ 
			ar[position] = portMask16; 
			position++;
		}
	}
	else if (m_inputLines/m_ports == 5) // This for PCL833, has one port of 5 lines
	{
		m_numInPorts = 1;
		// Set up PortLineMasks here
		ar[0] = portMask5;
	}
	else // Else its a PCL735, has one port of 8 lines and another of 4 lines
	{
		numOutPorts = 2;
		// Set up PortLineMasks here
		ar[0] = portMask8;
		ar[1] = portMask4;
	}
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"portlinemasks"),var) );

	// Port Directions
	// NOTE: Advantech names their ports as follows:
	//
	//			Input Ports: 0 1 2 3...
	//			Output Ports: 0 1 2 3...
	//
	//		 Here we give the Port IDs as follows (to conform to Mathworks):
	//
	//			Input Ports: 0 1
	//			Output Ports: 2 3
	//				or
	//			Configurable Ports: 0 1 2 3 4...
	position = 0;
	for (int i = 0; i < m_numInPorts; i++) // First check the input ports.
	{
		ar[position] = 0;
		position++;		
	}
	for (i = 0; i < numOutPorts; i++)
	{
		ar[position] = 1;
		position++;
	}
	for (i = 0; i < numConfPorts; i++)
	{
		ar[position] = 2;
		position++;
	}
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"portdirections"),var));	
	
	// Port IDs
	for (i = 0; i < m_ports; i++)
		ar[i] = i;
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"portids"),var));	
	
	// PortLineConfig 0:port 1: line
	// All will be 0 as advantech only supports port configurations...
	for (i = 0; i < m_ports; i++)
		ar[i] = 0;
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"portlineconfig"),var));

	// If the device has configurable ports then we must set the port direction
	// to "in" for all the ports as this is the default the engine expects.
	if (numConfPorts > 0)
	{
		for (i = 0; i < m_ports; i++)
		{
			SetPortDirection(i, 0);
		}
	}
	
	return S_OK;
} // end of SetDaqHwInfo()

////////////////////////////////////////////////////////////////////////////////////
// ReadValues
//  Read Digital I/O port values.
////////////////////////////////////////////////////////////////////////////////////
HRESULT CadvantechDio::ReadValues(LONG NumberOfPorts, LONG * PortList, ULONG * Data)
{
	PT_DioReadPortByte dioReadPortByte;

	for (int i=0;i<NumberOfPorts;i++)
    {
		dioReadPortByte.port = (USHORT) PortList[i];	// The digital port number
		dioReadPortByte.value = (USHORT*) &Data[i];		// 8 bit digital data read from specified port
		RETURN_ADVANTECH(DRV_DioReadPortByte(m_driverHandle,(LPT_DioReadPortByte) &dioReadPortByte));
		
	}

    return S_OK;
} // end of ReadValues()

////////////////////////////////////////////////////////////////////////////////////
// WriteValues
//  Write Digital I/O port values.
////////////////////////////////////////////////////////////////////////////////////
HRESULT CadvantechDio::WriteValues(LONG NumberOfPorts, LONG * PortList, ULONG * Data, ULONG * Mask)
{
	// As explained in setdaqhwinfo, we have to translate the user selected information (Port ID)
	// into the corresponding Advantech information, for example:
	//
	//		Inputs	  Outputs
	//		0 1 2 3 | 4 5 6 7	Mathworks numbering
	//		0 1 2 3	| 0 1 2 3	Advantech numbering
	//
	// So subtract number of input ports from port number to get correct Advantech port number

	if (Data == NULL)
        return E_POINTER;

	PT_DioWritePortByte dioWritePortByte;

	for (int i = 0; i < NumberOfPorts; i++)
	{
		dioWritePortByte.port = static_cast<USHORT>(PortList[i] - m_numInPorts);	// The digital port number
		dioWritePortByte.mask = (USHORT)Mask[i];	// Specifies which bit(s) of data should be sent to the 
													// digital output and which bits remain unchanged
		dioWritePortByte.state = (USHORT)Data[i];	// New digital logic state

		RETURN_ADVANTECH(DRV_DioWritePortByte(m_driverHandle,(LPT_DioWritePortByte) &dioWritePortByte));
	}
	
    return S_OK;
} // End of WriteValues()

////////////////////////////////////////////////////////////////////////////////////
// SetPortDirection
//  Set the digital I/O port direction. 
////////////////////////////////////////////////////////////////////////////////////
HRESULT CadvantechDio::SetPortDirection(LONG Port, ULONG DirectionValues)
{
	// PCL-722/724/731 and PCI-1753/1756/1751/1712 are only devices supporting this 	
	if (m_configLines > 0)
	{
		PT_DioSetPortMode ptDioSetPortMode;
		ptDioSetPortMode.port = static_cast<USHORT>(Port);
		ptDioSetPortMode.dir = static_cast<USHORT>(DirectionValues);	// NOTE: Need to confirm that this is correct!
		RETURN_ADVANTECH(DRV_DioSetPortMode(m_driverHandle, &ptDioSetPortMode));
	}
	else	// Else return error message if the user tries to change the Port Direction 
	{
		return E_PORT_DIR;
	}

	return S_OK;
} // end of SetPortDirection()

////////////////////////////////////////////////////////////////////////////////////
// LoadINIInfo()
//	Load the input/output/configurable lines data and the number of ports supported
//	by the device
////////////////////////////////////////////////////////////////////////////////////
HRESULT CadvantechDio::LoadINIInfo()
{
	char demoName1[15];
    char demoName2[15];
	char fname[512];
    
    // NOTE: We expect the INI file to be in the same directory as the application,
    // namely, this DLL. It's the only way to find the file if it's not
    // in the windows subdirectory
	
    if (GetModuleFileName(_Module.GetModuleInstance(), fname, 512)==0)
        return E_FAIL;
    
    // replace .dll with .ini
    strrchr(fname, '.' )[1]='\0';
    strcat(fname,"ini"); 
	// create a key to search on - The Device Name.
	
    strcpy(demoName2,"Advantech DEMO");
	StrCpyN(demoName1, m_deviceName, 15);
	if (!StrCmp(demoName1, demoName2))	// if demo board...
	{
		return E_DEMOBOARD;
	}
	else	// if installed board...
	{
		// replace .dll with .ini
		strrchr(fname, '.' )[1]='\0';
		strcat(fname,"ini"); 
		// create a key to search on - The Device Name.
		char *ch = strchr(m_deviceName,' ');
		int spaceAddress = ch - m_deviceName + 1;
		StrCpyN(m_deviceName, m_deviceName, spaceAddress);
	}
	m_configLines = GetPrivateProfileInt(m_deviceName, "DIOConfigWidth", 0, fname);
	m_inputLines = GetPrivateProfileInt(m_deviceName, "DIOInputWidth", 0, fname);
	m_outputLines = GetPrivateProfileInt(m_deviceName, "DIOOutputWidth", 0, fname);
	m_ports = GetPrivateProfileInt(m_deviceName, "DIOPorts", 0, fname);

	return S_OK;
	
} // end of LoadINIInfo()