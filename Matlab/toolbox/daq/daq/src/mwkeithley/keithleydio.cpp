// keithleydio.cpp - The implementation of the keithley digitalIO device
// $Revision: 1.1.6.2 $
// $Date: 2003/12/04 18:39:41 $

// Copyright 2002-2003 The MathWorks, Inc. 
// Coded by OPTI-NUM solutions


#include "stdafx.h"
#include "mwkeithley.h"
#include "keithleyadapt.h"
#include "math.h"
#include "keithleypropdef.h"
#include "keithleydio.h"
#include "keithleyUtil.h"

#define INPORT 1
#define OUTPORT 0

//////////////////////////////////////////////////////////////////////////////
// Ckeithleydio - Class implementation										//
//////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////
// Ckeithleydio()
//
// Default constructor
//////////////////////////////////////////////////////////////////////////////
Ckeithleydio::Ckeithleydio()
{
	m_pParent = MessageWindow::GetKeithleyWnd(); 

	// Set up the space for the service request
	m_pSR = (DL_ServiceRequest *) new DL_ServiceRequest;
	
	if (m_pSR != NULL)
	{
		memset(m_pSR, 0, sizeof(DL_ServiceRequest));
	}
	//Set the size of the service request
	m_pSR->dwSize = sizeof(DL_ServiceRequest);

	m_isInitializedDI = false;
	m_isInitializedDO = false;
}

Ckeithleydio::~Ckeithleydio()
{
	//Free memory associated with Service Request
	if ( m_pSR != NULL )
	{
		delete m_pSR;
		m_pSR = NULL;
	}

    m_pParent->Release();
}

/////////////////////////////////////////////////////////////////////////////
// InterfaceSupportsErrorInfo()
//
// Function indicates whether or not an interface supports the IErrorInfo..
//..interface. It is created by the wizard.
// Function is NOT MODIFIED by the adaptor programmer.
/////////////////////////////////////////////////////////////////////////////
STDMETHODIMP Ckeithleydio::InterfaceSupportsErrorInfo(REFIID riid)
{
    static const IID* arr[] = 
    {
        &IID_IKeithleyDIO
    };
    for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
    {
        if (InlineIsEqualGUID(*arr[i],riid))
            return S_OK;
    }
    return S_FALSE;
}


/////////////////////////////////////////////////////////////////////////////// 
// Open()
//
// Description:
//  This routine is called when MatLab executes the 'digitalio' instruction. 
//  Several things should be validated at this point. 
///////////////////////////////////////////////////////////////////////////////
HRESULT Ckeithleydio::Open(IUnknown *Interface,long ID)
{
   	if (ID<0) 
	{
		CComBSTR _error;
		_error.LoadString(IDS_ERR_INVALID_DEVICE_ID);
		return CComCoClass<ImwDevice>::Error(_error);
	}

	// assign the engine access pointer
    RETURN_HRESULT(CmwDevice::Open(Interface));

	m_deviceID = static_cast<WORD>(ID);	// Set the Device Number to the requested device number

	for( std::vector<DEVICEDETAILS>::iterator it = GetParent()->m_deviceMap.begin();
					it != GetParent()->m_deviceMap.end(); it++)
	{
		if( (*it).deviceID == m_deviceID)
			m_driverHandle = GetParent()->m_driverMap[(*it).driverLookup].driverHandle;
	}

	if (SelectDriverLINX(m_driverHandle) == NULL)
		return Error(_T("Selected DriverLINX driver not found."));

	m_ldd = ::GetLDD(NULL, m_deviceID); // Now get the LDD for the Device and store the handle in m_ldd
	if (m_ldd==NULL)
	{
		// Something wrong. Probably not a configured device.
		char tempMsg[255];
		sprintf(tempMsg, "Keithley Error: Device %d not found. Check DriverLINX Configuration Panel!", m_deviceID);
		return CComCoClass<ImwDevice>::Error(tempMsg);
	}
    
	if (!SupportsSubSystem((LDD*)m_ldd, DI) && !SupportsSubSystem((LDD*)m_ldd, DO))
		return Error(_T("Keithley: DigitalIO is not supported on this device."));

	// Get a dummy window handle for the digitalIO stuff
	m_pSR->hWnd = GetDesktopWindow();

	// More DriverLINX: Add the DeviceID to the SR
	m_pSR->device = m_deviceID;		// Device ID
	// Now initialize the device if it hasn't already been done.
	if (!((LDD*)m_ldd)->DevCap.DeviceInit)
	{
		WORD ResultCode;

		if (SelectDriverLINX(m_driverHandle) == NULL)
			return Error(_T("Selected DriverLINX driver not found."));
		RETURN_CODE(InitializeDriverLINXDevice(m_pSR, &ResultCode));
		if (ResultCode != 0)
		{
			char tempMsg[255];
			ReturnMessageString(NULL, ResultCode,tempMsg, 255 );
			return CComCoClass<ImwDevice>::Error(tempMsg);
		}

	}
		
	RETURN_HRESULT(SetDaqHwInfo()); // Set the daqhwinfo for the digitalio subsytem
	
	return S_OK;
}

///////////////////////////////////////////////////////////////////////////////
// SetDaqHWInfo()
//
// Description:
// Set the fields needed for DaqHwInfo. 
//  It is used when you call daqhwinfo(analoginput('keithley'))
///////////////////////////////////////////////////////////////////////////////
HRESULT Ckeithleydio::SetDaqHwInfo()
{
	//Adaptor Name
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"adaptorname"), CComVariant(Ckeithleyadapt::ConstructorName)));
	
	
    // Device Name - The device name is made up of three things:
	char tempstr[15] = "";
	char devname[25] = "";
	
	::ReturnMessageString(NULL, ((LDD*)m_ldd)->DevCap.ModelCode, (LPSTR)tempstr, 15); // the vendor
	// model code	
	strcat(devname, tempstr);
	sprintf(tempstr, " (Device %d)", m_deviceID); // The words (Device x) hardcoded and the 
	strcat(devname, tempstr);					// number of the device in place of x.
	
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"devicename"), CComVariant( devname )));
	
    // device Id
	wchar_t idStr[8];
    swprintf(idStr, L"%d", m_deviceID);
    RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"id"), CComVariant(idStr)));		
	
	// Sort out the daqhwinfo for the ports
	
	// This calculates the total number of lines that we have available. We do this first so we know how many
	// different ports we have in total.
	
	CComVariant _totallines(0);
	short	_numinports, _numoutports;
	long _totalnumberofports = 0;
	long temp = 0;
	short numInTrgClkPorts = 0;
		
	_numinports = ((LDD*)m_ldd)->DigChan[1].NDiChan;	// Get the number of ports so we know how many
	// there are.
	// First count up the number of lines in the digital Input subsytem		
	for (int i = 0; i < _numinports; i++) // we have _numinports Input ports, and each has x lines
	{	
		if(IsChanClockOrTrig(INPORT, i))
		{
			numInTrgClkPorts++;
		}
		// Here we total up the number of lines. Get number of lines converts the channel mask into
		//  the number lines available
		else
			temp = temp + PortLineWidth(((LDD*)m_ldd)->DigChan[1].lpDiCapabilities[i].DiMask);
	}
	
	_totalnumberofports = _totalnumberofports + _numinports - numInTrgClkPorts;
	// Now do the same for the digital Output subsytem
	_numoutports = ((LDD*)m_ldd)->DigChan[0].NDiChan; // Get the number of output ports
	
	for( i = 0; i < _numoutports; i++)
	{ 
		// But we have a problem. If there are programmable ports, then they will overlap between the
		// input and output subsytems and we only want the total number of lines, so we only count
		// the ports which are fixed to output only.
		if( ((LDD*)m_ldd)->DigChan[0].lpDiCapabilities[i].DiConfig == dcFixed)
		{
			if(!(IsChanClockOrTrig(OUTPORT, i)))
			{
				temp = temp + PortLineWidth(((LDD*)m_ldd)->DigChan[0].lpDiCapabilities[i].DiMask);
				_totalnumberofports = _totalnumberofports + 1;
			}
		}
	}
	
	_totallines = temp;
	
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"totallines"), _totallines));
	
	// Set the rest of the port info
	CComVariant var;
	
	long ports = _totalnumberofports;
	
	// Here we create the SafeArray we are going to use to set all out port values.        
	SAFEARRAY *ps = SafeArrayCreateVector(VT_I4, 0, ports );
	if (ps==NULL) 
		throw "Failure to create SafeArray.";
	
	// set the data type and values
	V_VT(&var)=VT_ARRAY | VT_I4;
	V_ARRAY(&var)=ps;
	TSafeArrayAccess <long> ar(&var);  // used to access the array
	
	// What are our port directions?
	int _position = 0;
	for (i=0;i<_numinports;i++) // First check the input ports.
	{
		// if the DiConfig is dcFixed, that means that you can't change the configuration for the 
		//  port, and it is therefore only going in one direction. Cause we are dealing with the 
		//  digital input subsytem, that direction is input.
		if ( ((LDD*)m_ldd)->DigChan[1].lpDiCapabilities[i].DiConfig == dcFixed)
		{
			if(!(IsChanClockOrTrig(INPORT, i)))
			{
				ar[_position]=0;
				_position++;
				
				m_portNum2Channel.push_back(i);

			}
		}
		else
		{
			ar[_position]=2; // Other wise we can change the config, making them in / out
			_position++;

			m_portNum2Channel.push_back(i);

		}
	}
	
	for (i=0;i<_numoutports;i++) // then check the output ports.
	{
		// If the DiConfig is dcFixed, that means that you can't change the configuration for the 
		//  port, and it is therefore only going in one direction. Cause we are dealing with the 
		//  digital input subsytem, that direction is input.
		
		if ( ((LDD*)m_ldd)->DigChan[0].lpDiCapabilities[i].DiConfig == dcFixed)
		{
			if(!(IsChanClockOrTrig(OUTPORT, i)))
			{
				ar[_position]=1;
				_position++;
				m_portNum2Channel.push_back(i);

			}
		}
	}
	
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"portdirections"),var) );
	
	// Now setup the Port ID's
	// How many ports do we have? well, loop through and setup the id's.
	for (i=0;i<ports;i++)
		ar[i]=i;
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"portids"),var) );
	
	// And the port line config 0:port 1: line
	for (i=0;i<ports;i++)
		ar[i]=0;
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"portlineconfig"),var) );
	
	// Now setup the port masks        
	_position = 0;
	for (i=0;i<_numinports;i++) // First check the input ports.
	{ 
		// Set the port masks from the LDD for each channel
		if(!(IsChanClockOrTrig(INPORT, i)))
		{
			ar[_position]=((LDD*)m_ldd)->DigChan[1].lpDiCapabilities[i].DiMask;
			_position++;
		}
	}
	
	for (i=0;i<_numoutports;i++) // then check the output ports.
	{
		// Set the port masks from the LDD for each channel, but not the overlapping channels.
		if ( ((LDD*)m_ldd)->DigChan[0].lpDiCapabilities[i].DiConfig == dcFixed)
		{
			if(!(IsChanClockOrTrig(OUTPORT, i)))
			{
				ar[_position]=((LDD*)m_ldd)->DigChan[0].lpDiCapabilities[i].DiMask;
				_position++;
			}
		}
	}
	
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"portlinemasks"),var) );
	
	// Vendor Driver Description
	char driverdescrip[30]; // The place to store the driver description
	// This call gets the value which corresponds to the description, and converts it to a string
	::ReturnMessageString(NULL, ((LDD*)m_ldd)->DevCap.VendorCode, (LPSTR)driverdescrip, 30);
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"vendordriverdescription"),CComVariant(driverdescrip)));
	
	//Vendor Driver Version
	//The following code does not work (always returns 0) due to a Keithley bug
/*
	WORD minmaxver;		// this is a WORD that contains the major version in the high byte and the minor
						// version in the low byte
	BYTE minver, maxver;	// Place holders for the major and minor versions
	char driverver[10];
	
	minmaxver = ((LDD*)m_ldd)->DriverVersion; // get the version
	
	minver = minmaxver & 0x00FF;			// Mask off the high bits
	maxver = (minmaxver & 0xFF00) >> 8;		// Mask off the low bits and shift right to get the value
*/

	// Place holders for the major and minor versions
	int maxver, minver;
		
	char driverver[10];

	// Get the driver version using Windows API
	GetKeithleyVersion(maxver, minver);
	
	sprintf(driverver, "%d.%d", maxver, minver); // Create a version string x.y

	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"vendordriverversion"),CComVariant(driverver)));
	
    return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
// ReadValues
//
// Description:
//  Read Digital I/O port values.
/////////////////////////////////////////////////////////////////////////////
HRESULT Ckeithleydio::ReadValues(LONG NumberOfPorts, LONG * PortList, ULONG * Data)
{
	WORD ResultCode;
	CComBSTR _error;

	m_pSR->subsystem = DI;
    if (Data == NULL)
        return E_POINTER;

	// Initialize a service request (can be local) to start digitalIO
	if (!m_isInitializedDI)
	{
		if (SelectDriverLINX(m_driverHandle) == NULL)
			return Error(_T("Selected DriverLINX driver not found."));
		RETURN_CODE(InitializeDriverLINXSubsystem(m_pSR, &ResultCode));
		m_isInitializedDI = true;
	}

	// Now set up the basics of the SR for a single channel read.
	// Group Start
	if (SelectDriverLINX(m_driverHandle) == NULL)
		return Error(_T("Selected DriverLINX driver not found."));
	RETURN_CODE(AddRequestGroupStart(m_pSR, SYNC));
	// Event Group: Timing, Start, Stop
	AddTimingEventNullEvent(m_pSR);
	AddStartEventNullEvent(m_pSR);
	AddStopEventNullEvent(m_pSR);
	// Channel group: Dummy for now (manually coded)
	m_pSR->channels.nChannels = 1;
	m_pSR->channels.numberFormat = tNATIVE;
	m_pSR->channels.chanGain[0].gainOrRange = 0;
	m_pSR->channels.chanGain[1].channel = 0;
	m_pSR->channels.chanGain[1].gainOrRange = 0;
	m_pSR->channels.chanGainList = NULL;		//zero when not used

	// Buffers group
	if (SelectDriverLINX(m_driverHandle) == NULL)
		return Error(_T("Selected DriverLINX driver not found."));
	AddSelectBuffers(m_pSR, 0, 0, 0);
	// Flags: No start/done msgs
	m_pSR->taskFlags = (NO_SERVICESTART | NO_SERVICEDONE);

	//m_pSR->start.typeEvent = DIEVENT;

	int channel;

    for (int i=0;i<NumberOfPorts;i++)
    {
	
		channel = m_portNum2Channel[PortList[i]];

		// Set the correct channel:
		m_pSR->channels.chanGain[0].channel = channel;
	
		if (SelectDriverLINX(m_driverHandle) == NULL)
			return Error(_T("Selected DriverLINX driver not found."));
		DriverLINX(m_pSR);
		if (m_pSR->result != 0)
		{
			char tempMsg[255];
			ReturnMessageString(NULL, m_pSR->result,tempMsg, 255 );
			return CComCoClass<ImwDevice>::Error(tempMsg);
		}

		// The value is stored in the ioValue field of the status structure:
        Data[i]=m_pSR->status.u.ioValue;
    }
	// Reset the flags:
	m_pSR->taskFlags = 0;
    return S_OK;
}


///////////////////////////////////////////////////////////////////////////////
// WriteValues
//
// Description:
//  Write Digital I/O port values.
////////////////////////////////////////////////////////////////////////////////
HRESULT Ckeithleydio::WriteValues(LONG NumberOfPorts, LONG * PortList, ULONG * Data, ULONG * Mask)
{
	WORD ResultCode;
	CComBSTR _error;

    if (Data == NULL)
        return E_POINTER;
	// Initialize a service request (can be local) to start digitalIO
	m_pSR->subsystem = DO;
	if (!(((LDD*)m_ldd)->DigChan[0].Diinit))//!m_isInitializedDO)
	{
		SELECTMYDRIVERLINX(m_driverHandle);
		RETURN_CODE(InitializeDriverLINXSubsystem(m_pSR, &ResultCode));
		m_isInitializedDO = true;
	}

	SELECTMYDRIVERLINX(m_driverHandle);
	ERRORCODES Code = AddRequestGroupStart(m_pSR, true);
	if (Code != DL_TRUE)
	{
		return Code;
	}


	/*--------------------------- Event Group -------------------------*/
	//Specify timing event
	AddTimingEventNullEvent(m_pSR);

	//Specify start event
	AddStartEventNullEvent(m_pSR);
	//Specify stop event
	AddStopEventNullEvent(m_pSR);


	/*----------------------- Select Channel Group --------------------*/
	//Specify the channels, gain and data format
	
	//	AddChannelGainList(m_pSR, 1, 0, 0, CHAN_SEDIFF_DEFAULT);
	// Channel group: Dummy for now (manually coded)
	m_pSR->channels.nChannels = 1;
	m_pSR->channels.numberFormat = tNATIVE;
	m_pSR->channels.chanGain[0].gainOrRange = 0;
	m_pSR->channels.chanGain[1].channel = 0;
	m_pSR->channels.chanGain[1].gainOrRange = 0;
	m_pSR->channels.chanGainList = NULL;		//zero when not used


	/*----------------------- Select Buffers Group --------------------*/
	//Single value transfers do not use buffers
	SELECTMYDRIVERLINX(m_driverHandle);
	AddSelectBuffers(m_pSR, 0, 0, 0);

	/*--------------------------- Select Flags ------------------------*/
	//Single-value I/O doesn't need ServiceStart or ServiceDone events
	WORD flags = (NO_SERVICESTART | NO_SERVICEDONE);
	m_pSR->taskFlags = flags;
	
	// m_pSR->start.typeEvent = DIEVENT;

	int channel;

	for (int i=0;i<NumberOfPorts;i++)
	{
		
		channel = m_portNum2Channel[PortList[i]];
		
		// Set up a single service request for this data:
		m_pSR->channels.chanGain[0].channel = channel;
		// Now add the mask to this start event.
		m_pSR->start.u.diEvent.mask = static_cast<WORD>(Mask[i]);
		m_pSR->start.u.diEvent.match = FALSE;
		m_pSR->start.u.diEvent.pattern = 0;
		// Put the data into the ioValue area:
		m_pSR->status.typeStatus = IOVALUE;
		m_pSR->status.u.ioValue = Data[i];
		
		SELECTMYDRIVERLINX(m_driverHandle);
		DriverLINX(m_pSR);
		
		if (m_pSR->result != 0)
		{
			char tempMsg[255];
			ReturnMessageString(NULL, m_pSR->result,tempMsg, 255 );
			return CComCoClass<ImwDevice>::Error(tempMsg);
		}
		// Reset the flags:
		m_pSR->taskFlags = 0;
		
	}
	
    return S_OK;
}

//////////////////////////////////////////////////////////////////////////////
// SetPortDirection
//
// Description:
//  Set the digital I/O port direction. 
//////////////////////////////////////////////////////////////////////////////
HRESULT Ckeithleydio::SetPortDirection(LONG Port, ULONG DirectionValues)
{
	delete m_pSR;
	m_pSR = NULL;
		
	m_pSR = (DL_ServiceRequest *) new DL_ServiceRequest;
		
	memset(m_pSR, 0, sizeof(DL_ServiceRequest));
	//Set the size of the service request
	m_pSR->dwSize = sizeof(DL_ServiceRequest);
	// Get a dummy window handle for the digitalIO stuff
	m_pSR->hWnd = GetDesktopWindow();
	// More DriverLINX: Add the DeviceID to the SR
	m_pSR->device = m_deviceID;		// Device ID

	m_pSR->mode = OTHER;
	m_pSR->operation = CONFIGURE;
		
	m_pSR->timing.typeEvent = DIOSETUP;
	m_pSR->timing.u.diSetup.channel = m_portNum2Channel[Port];
	m_pSR->timing.u.diSetup.mode = DIO_BASIC;

    if(DirectionValues == 0) // Input
	{	
		m_pSR->subsystem = DI;
	}
	else // Output, which may be anything except zero!
	{
		
		m_pSR->subsystem = DO;
	}
	
	UINT result = NoErr;
	
	SELECTMYDRIVERLINX(m_driverHandle);
	DriverLINX(m_pSR);
	
	if (m_pSR->result != 0)
	{
		char tempMsg[255];
		ReturnMessageString(NULL, m_pSR->result,tempMsg, 255 );
		return CComCoClass<ImwDevice>::Error(tempMsg);
	}
	
	
	
	return S_OK;
}

////////////////////////////////////////////////////////////////////////////////////
// SetParent()
//
// Description:
//	This function sets this objects pointer to its parent class.
////////////////////////////////////////////////////////////////////////////////////
void Ckeithleydio::SetParent(MessageWindow * pParent)
{
	pParent->AddRef();
	m_pParent = pParent;
}

//////////////////////////////////////////////////////////////////////////////
// GetParent()
//
// Description:
//  Returns a pointer to the adaptor - The parent of this class
/////////////////////////////////////////////////////////////////////////////
MessageWindow * Ckeithleydio::GetParent()
{
	return m_pParent;
}


////////////////////////////////////////////////////////////////////////////
// PortLineWidth()
//
// Description:
//	This function is used to return the number of lines from a channel,
//  given the channel mask.
///////////////////////////////////////////////////////////////////////////
long Ckeithleydio::PortLineWidth( DWORD chanMask )
{
	long retval = 0; // The value we are going to return 
	for (int i = 0; i <32; i++) // The maximum number of bits the mask can be is 32
	{
		retval = retval + (chanMask & 1); // Check if the last bit of the mask is set
		chanMask = (chanMask >> 1); // Right shift the mask, to get the next bit to check
	}

	return retval; // Return the value
}


bool Ckeithleydio::IsChanClockOrTrig(int InOrOut, int chan)
{
	if (m_ldd)
	{
		if ((((LDD*)m_ldd)->DigChan[InOrOut].lpDiCapabilities[chan].DiType == ExtTrgChn) ||
			(((LDD*)m_ldd)->DigChan[InOrOut].lpDiCapabilities[chan].DiType == ExtClkChn))
		{
			return true;
		}
	}

	return false;
}
