// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.1.6.2 $  $Date: 2003/12/04 18:39:50 $


// Dio.cpp : Implementation of CDio
#include "stdafx.h"
#include "Mwmcc.h"
#include "Dio.h"
#include "cbw.h"
#include <sarrayaccess.h>
#ifdef _DEBUG
#undef THIS_FILE
#undef DEBUG_NEW
static char THIS_FILE[]=__FILE__;
#define DEBUG_NEW new(_NORMAL_BLOCK, THIS_FILE, __LINE__)
#define new DEBUG_NEW
#endif

/////////////////////////////////////////////////////////////////////////////
// CDio

STDMETHODIMP CDio::InterfaceSupportsErrorInfo(REFIID riid)
{
    static const IID* arr[] = 
    {
        &IID_IDio
    };
    for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
    {
        if (InlineIsEqualGUID(*arr[i],riid))
            return S_OK;
    }
    return S_FALSE;
}

// 
// Open
//
// Description:
//  This routine is called when MatLab executes the 'digitalio' instruction. 
//  Several things should be validated at this point. The first is the
//  board number being passed in.
//
// UL Routines:
//

HRESULT CDio::Open(IUnknown *Interface,long ID)
{
    // assign the engine access pointer
    RETURN_HRESULT(CmwDevice::Open(Interface));
    
    // Get the board number and verify.
    _BoardNum=ID;

    if (_BoardNum < 0 || _BoardNum > GINUMBOARDS)
        return ERR_XLATE(ERR_INVALID_ID);

    int chans=0;
    CBI_CHECK(cbGetConfig (BOARDINFO, _BoardNum, 0, BIDINUMDEVS, &chans));
    if (chans==0)
        return ERR_XLATE(ERR_INVALID_ID);

    SetDaqHwInfo();

    // TODO: Add default to input
    
    return S_OK;
}



//
// Set the hardware information for the Digial I/O Subsystem of this board
//
HRESULT CDio::Legacy_SetDaqHwInfo()
{

    int ports,port=0;
    
	//
	// Chech the mwmcc.ini file to see if we support Configurable Digital I/O for this board
	//
	_DirConfigurable = GetFromIni("DIOConfigurable",false);

    	//
	// Call the universal library to see how many digital devices are available on this board.
	// This information comes from the CB.CFG file, located in the Instacal Directory
	//
    CBI_CHECK(cbGetConfig (BOARDINFO, _BoardNum, 0, BIDINUMDEVS, &ports));
    if (ports==0)
        return ERR_XLATE(ERR_INVALID_ID);

   
	//
	// Check to see if digital device 0 is of type AUXPORT
	// (XXX) Should this check all avaiable digital devices?
	//
    int DevType;
    CBI_CHECK(cbGetConfig (DIGITALINFO, _BoardNum, 0, DIDEVTYPE, &DevType));
  
	// 
	// Check the functionality of the AUXPORT
	//
    if (DevType==AUXPORT)
    {
		// Attempt to read a value from the port
		unsigned short DataValue;
		int status = cbDIn(_BoardNum, AUXPORT, &DataValue);

		// On error reduce the total number of available ports
		// Also increase the starting point for port configuration
        if (status!=0)
        {
            ports--;
            port=1;
        }

    }

    //
	// Allocate the port and port direction vectors
	//
    PortNum.resize(ports);
    Dir.resize(ports);
	
	
	//
	// Create a SafeArray vector to serve as access to the CComVar var
	// This is confusing code, and I'd like to do it differently
	//
	CComVariant var; // a re-used variable
	SAFEARRAY *ps = SafeArrayCreateVector(VT_I4, 0, ports);
    if (ps==NULL) return E_OUTOFMEMORY;    

    //
	// Set the data type and values for var
    //
	V_VT(&var) = VT_ARRAY | VT_I4;
    V_ARRAY(&var) = ps;

	//
	// Create an array access vector for 'var' called 'ar'
	//
	TSafeArrayAccess <long> ar(&var);

	//
	// Do this for all the DIO ports on the board
	// (*) If port 0 is an auxport && failed above : it will be bypassed
	//
	long lines = 0; // The total number of DIO lines for this board
	int NumBits;    // The number of lines for port 'i'
	int i;
    for (i=0; i<ports; i++)
    {
		//
		// Get the number of 'lines' for port 'i' 
        // (*) The mask DIMASK is not a bitmask do not use
		//
        CBI_CHECK(cbGetConfig (DIGITALINFO, _BoardNum, port, DINUMBITS, &NumBits));
		
		// Increase the line total
        lines += NumBits;
		
		// Generate this port's line mask 
        ar[i]=(1<<NumBits)-1;

		// Check the Universal Library for the current direction of this port  
        CBI_CHECK(cbGetConfig (DIGITALINFO, _BoardNum, port, DICONFIG,  &Dir[i]));

		// Check the Universal Library for the type (AUXPORT, FIRSTPORTA, etc...) of this port 
        CBI_CHECK(cbGetConfig (DIGITALINFO, _BoardNum, port++, DIDEVTYPE, &PortNum[i]));
    }

	// 
	// Set the portlinemasks and totallines fields for the DaqHWInfo object
	//
    DEBUG_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"portlinemasks"),var) );
    DEBUG_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"totallines"),CComVariant(lines)) );
        
    //
	// Set up 'var' to contain port direction information about the board
	//
    if (_DirConfigurable) // From mwmcc.ini file
    {
		// set all ports to be bidirectional
        for (i=0;i<ports;i++)
            ar[i]=DIO_BIDIRECTIONAL;
    }
    else
    {	
		// set all ports to be the direction they are currently set at
        for (i=0;i<ports;i++)
            ar[i]=Dir[i]==DIGITALIN ? DIO_INPUT : DIO_OUTPUT ;
    }
    
	//
	// Set the portdirections field for the DaqHwInfo object
	//
	DEBUG_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"portdirections"),var) );
    

	// Generate increasing indeces for the portids field of the DaqHwInfo object
    for (i=0;i<ports;i++)
        ar[i]=i;

    DEBUG_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"portids"),var) );
    
    
	//
	// Set the 'line' configurability for the ports ::
	// (*) We make FALSE assumtion that all ports are port configurable. 0=port, 1=line
	//
    for (i=0;i<ports;i++)
        ar[i]=0;

    DEBUG_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"portlineconfig"),var) );
    
    
    return S_OK;
}

//
// Set the hardware information for the Digial I/O Subsystem of this board
//
HRESULT CDio::SetDaqHwInfo()
{
	//
	// Set the common information for a DAQ object
	//
	DEBUG_HRESULT(SetBaseHwInfo());

	//
	// Set the type of this object to be DIGITALIO
	//
	DEBUG_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"subsystemtype"), CComVariant(L"DigitalIO")));
	
	//
	// Retrieve the total Digial IO port count for this device
	// If this call fails, try using the old SetDaqHwInfo()
	//
	int totalPorts = getPortCount();
	if(totalPorts == -1)
		return Legacy_SetDaqHwInfo();

	//
	// Resize the port type and direction vectors
	//
	PortNum.resize(totalPorts);
	Dir.resize(totalPorts);
	vPortLineCount.resize(totalPorts);

	//
	// Create temporary vectors for port information storage
	//
	CComVariant lineMasks;
	CComVariant portConfig;
	CComVariant lineConfig;
	CComVariant portIds;

	//
	// Allocate the memory and point the variants to the right place
	//
	SAFEARRAY *	lm_Array = SafeArrayCreateVector(VT_I4, 0, totalPorts);
	SAFEARRAY *	pc_Array = SafeArrayCreateVector(VT_I4, 0, totalPorts);
	SAFEARRAY *	lc_Array = SafeArrayCreateVector(VT_I4, 0, totalPorts);
	SAFEARRAY *	pi_Array = SafeArrayCreateVector(VT_I4, 0, totalPorts);


	//
	// Check for proper memory allocation
	//
	if((lm_Array == NULL)|(pc_Array == NULL)|(lc_Array == NULL)|(pi_Array == NULL))
		return E_OUTOFMEMORY;

	V_VT(&lineMasks) = VT_ARRAY | VT_I4;
    V_ARRAY(&lineMasks) = lm_Array;

	V_VT(&portConfig) = VT_ARRAY | VT_I4;
    V_ARRAY(&portConfig) = pc_Array;

	V_VT(&lineConfig) = VT_ARRAY | VT_I4;
    V_ARRAY(&lineConfig) = lc_Array;

	V_VT(&portIds) = VT_ARRAY | VT_I4;
    V_ARRAY(&portIds) = pi_Array;

	//
	// Now create access (a_)liases to the memory 
	//
	TSafeArrayAccess <long> a_lineMasks(&lineMasks);
	TSafeArrayAccess <long> a_portConfig(&portConfig);
	TSafeArrayAccess <long> a_lineConfig(&lineConfig);
	TSafeArrayAccess <long> a_portIds(&portIds);

	//
	// Loop through the available ports and retrive information about them
	//
	int totalLines = 0;
	int portLines = 0;
	int configuration = 0;
	int mccPortId = 0;
	int status = 0;
	for(int currentPort = 0; currentPort < totalPorts; currentPort++)
	{
		//
		// Get the number of lines (bits) for port[currentPort]
		//
		status = getPortLines(currentPort);
		if(status == -1)
			return ERR_XLATE(ERR_INVALID_ID);

		totalLines += portLines = status;
		vPortLineCount[currentPort] = portLines;
		
		//
		// Generate the line (bit) mask for this port
		//
		a_lineMasks[currentPort] = (1 << portLines) - 1;


		//
		// Get the current direction of the port from Universal Library
		//
		CBI_CHECK(cbGetConfig (DIGITALINFO, _BoardNum, mccPortId, DICONFIG,  &Dir[currentPort]));
		
		
		//
		// Get the possible configurations of this port (DIO_INPUT, DIO_OUTPUT, DIO_BIDIRECTIONAL)
		// and line (0=no, 1=yes)
		//
		if(getDeviceConfigurability(currentPort, &a_portConfig[currentPort], &a_lineConfig[currentPort]) == -1)
			return ERR_XLATE(ERR_INVALID_ID);

		//
		// Get the ports "type", this is a designation from MCC : AUXPORT, FIRTSPORTA, FIRSTPORTB, etc
		//
		if((PortNum[currentPort] = getPortType(currentPort)) == -1)
			return ERR_XLATE(ERR_INVALID_ID);

		//
		// The mccPortId needs to be incremented only if the current port is NOT and AUXPORT,
		// and the next port is NOT an AUXPORT. The reason for this is that the Universal Library
		// does not consider AUXPORTs with separate IN/OUT hardware lines to be separate ports.
		//
		if(!(PortNum[currentPort] == AUXPORT) && (getPortType(currentPort + 1) == AUXPORT)) 
		{
			mccPortId++;
		}

		
		//
		// Add another entry into the 'indeces' vector.
		//
		a_portIds[currentPort] = currentPort;

	}
	
	//
	// Store the gathered information (call to DAQMEX)
	//

	// The line masks (positions) for each port
	DEBUG_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"portlinemasks"), lineMasks) );

	// The total amount of lines on the hardware
    DEBUG_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"totallines"),CComVariant(totalLines)) );
	
	// The PORT and LINE configurability
	DEBUG_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"portdirections"),portConfig) );
	DEBUG_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"portlineconfig"),lineConfig) );

	// The vector of port indeces
	DEBUG_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"portids"),portIds) );

	return S_OK;
}


//
// ReadValues
//
// Description:
//  Read Digital I/O port values.
//
// UL Routines:
//  cbDIn
//
HRESULT CDio::ReadValues(LONG NumberOfPorts, LONG * PortList, ULONG * Data)
{

    if (Data == NULL)
        return E_POINTER;
    USHORT val;
    for (int i=0;i<NumberOfPorts;i++)
    {
        CBI_CHECK(cbDIn(_BoardNum,PortNum[PortList[i]],&val));
        Data[i]=val;
    }
    return S_OK;
}


//
// WriteValues
//
// Description:
//  Write Digital I/O port values.
//
// UL Routines:
//  cbDOut    : port-wise writing
//  cbDBitOut : bit-wise writing
//
HRESULT CDio::WriteValues(LONG NumberOfPorts, LONG * PortList, ULONG * Data, ULONG * Mask)
{

    for (int i=0;i<NumberOfPorts;i++)
    {

		if(Mask[i] == 0x0){
			//Throw an error
			CBI_CHECK(BADPORTNUM);
		}
        else if(Mask[i]==0xff)
        {
            // Use port write
            CBI_CHECK(cbDOut(_BoardNum,PortNum[PortList[i]],static_cast<USHORT>(Data[i])));
        }
        else
        {		
			// Use Bit Configuration
			ULONG linebit;
			ULONG lineval;

			for (int iLoop=0; iLoop<8; iLoop++)
			{
				linebit = (Mask[i]>>iLoop);
				linebit = (linebit & (0x01));
				
				// This line should be written
				if(linebit){
					
					// Compute value for this line
					lineval = (Data[i] >> iLoop);
					lineval = (lineval & (0x01));
					
					// Perform the bitwise line write
					CBI_CHECK(cbDBitOut(_BoardNum, PortNum[PortList[i]], iLoop, static_cast<USHORT>(lineval)));
				}
			}
		}
    }
    return S_OK;
}

//
// SetPortDirection
//
// Description:
//  Set the digital I/O port direction. On AUXPORT devices this function
//  is not supported.
//
// UL Routines:
//  cbDConfigPort
//
HRESULT CDio::SetPortDirection(LONG Port, ULONG DirectionValues)
{

	// Create a dummy Variable
    int dir = 0;

    if ((DirectionValues==0) || (DirectionValues==(0xff >> (8 - vPortLineCount[Port]))))
    {
        // Use Port Configuration
            if (DirectionValues)
                dir = DIGITALOUT;
            else
                dir = DIGITALIN;

        CBI_CHECK(cbDConfigPort(_BoardNum,PortNum[Port],dir));
    }
    else 
    {
        // Use Bit Configuration
        ULONG dirbit = DirectionValues;
        for (int iLoop=0; iLoop<8; iLoop++)
        {
            dirbit = (DirectionValues>>iLoop);
            dirbit = (dirbit & (0x01));
            if (dirbit)
                dir = DIGITALOUT;
            else
                dir = DIGITALIN;

            CBI_CHECK(cbDConfigBit(_BoardNum, PortNum[Port], iLoop, dir));
        }
	}
    return S_OK;
}


//
// Obtain and return the total port count for the specified device
// 
int CDio::getPortCount()
{
	return  GetFromIni("DPORTS",-1);
}

//
// Obtain and return the number of lines on port 'port'
//
int CDio::getPortLines(int port)
{

	//Generate the actual string for querying the INI file
	char queryString[25];
	sprintf(queryString, "DPORT%dLINES", port);

	return GetFromIni(queryString, -1);
}


//
// Obtain the configurability of port 'port'
//
int CDio::getDeviceConfigurability(int port, long *portConfig, long *lineConfig)
{	
	//
	// Set the default value for lineConfig to be FALSE
	//
	*lineConfig = 0;

	//
	// Generate the actual string for querying the INI file
	//
	char queryString[25];
	sprintf(queryString, "DPORT%dCONFIG", port);

	//  
	// Retrieve the configurability setting from the INI file
	// 0 -> Input Only
	// 1 -> Output Only
	// 2 -> Bidirectional by PORT
	// 3 -> Bidirectional by LINE
	//
	int config = GetFromIni(queryString, -1);


	if(config == 0) // Port is for input only
		*portConfig = DIO_INPUT;
	else if(config == 1) // Port is for output only
		*portConfig = DIO_OUTPUT;
	else if(config == 2) // Port is configurable by PORT (all or nothing)
		*portConfig = DIO_BIDIRECTIONAL;
	else if(config == 3){ // Port is configurable by LINE
		*portConfig = DIO_BIDIRECTIONAL;
		*lineConfig = 1;
	}
	else //output not recognized
		return -1;

	return 1; // All is OK
}

//
// Obtain and return the port type for port 'port'
// This could be AUXPORT, FIRSTPORTA, FIRSTPORTB, ect...
//
int CDio::getPortType(int port)
{

	//Generate the actual string for querying the INI file
	char queryString[25];
	sprintf(queryString, "DPORT%dTYPE", port);

	return GetFromIni(queryString, -1);
}