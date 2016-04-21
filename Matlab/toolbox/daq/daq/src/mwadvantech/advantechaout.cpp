// advantechOut.cpp : Implementation of CadvantechAout
// Copyright 2002-2003 The MathWorks, Inc.
// $Revision: 1.1.6.2 $  $Date: 2003/12/04 18:39:18 $

#include <winbase.h>
#include "stdafx.h"
#include "mwadvantech.h"
#include "advantechAout.h"
#include "advantechadapt.h"
#include "advantecherr.h"   // Advantech error codes
#include "advantechUtil.h"	// Advantech Utility functions
#include "adaptorkit.h"
#include "advantechpropdef.h"
#include <math.h>

#define AUTO_LOCK TAtlLock<CadvantechAout> _lock(*this)	

/////////////////////////////////////////////////////////////////////////////
// CadvantechAout

/////////////////////////////////////////////////////////////////////////////
// CadvantechAout()  default constructor
//
// Function performs all the necessary initializations.
// Function MUST BE MODIFIED by the adaptor programmer. It may use HW API calls.
/////////////////////////////////////////////////////////////////////////////
CadvantechAout::CadvantechAout():
m_pParent(NULL),
m_driverHandle(NULL),
m_deviceID(0),
m_maxAOChl(0),
m_polarity(POLARITY_BIPOLAR),
m_maxSampleRate(0),
m_minSampleRate(0),
m_lastBufferLoaded(false),
m_timerPeriod(0),
m_pointsToAdvBuffer(0),
m_pointsToHardware(0),
m_numUniqueJumperedOutputRanges(0),
m_initialLoad(true),
TimerObj(this)
{
	// Setup Advantech's ptFAOCheck variables 
	m_ptFAOCheck.ActiveBuf = &m_gwActiveBuf;
	m_ptFAOCheck.stopped = &m_gwStopped;
	m_ptFAOCheck.CurrentCount = &m_posted;	
	m_ptFAOCheck.overrun = &m_gwOverrun;
	m_ptFAOCheck.HalfReady = &m_gwHalfReady;
} // end of default constructor

/////////////////////////////////////////////////////////////////////////////
// ~CadvantechAout() 
//
// CadvantechAout destructor
///////////////////////////////////////////////////////////////////////////// 
CadvantechAout::~CadvantechAout()
{
	m_channelRanges.clear();
	// Close device handle if it's valid.
	if (m_driverHandle != NULL)
		DRV_DeviceClose((LONG far *)&m_driverHandle);	
} // end of destructor

/////////////////////////////////////////////////////////////////////////////
// Open()
//
// Function is called by the OpenDevice(), which is in turn called by the engine.
// CadvantechAin::Open() function's main goals are ..
// 1)to initialize the hardware and hardware dependent properties..
// 2)to expose pointers to the engine and the adaptor to each other..
// 3)to process the device ID, which is input by a user in the ML command line.
// The call to this function goes through the hierarchical chain: ..
//..CadvantechAin::Open() -> CswClockedDevice::Open() -> CmwDevice::Open()
// CmwDevice::Open() in its turn populates the pointer to the..
//..engine (CmwDevice::_engine), which allows to access all engine interfaces.
// Function MUST BE MODIFIED by the adaptor programmer.
//////////////////////////////////////////////////////////////////////////////
HRESULT CadvantechAout::Open(IUnknown *Interface,long ID)
{
	if (ID<0) 
	{
		return E_INVALID_DEVICE_ID;
	}
	
	RETURN_HRESULT(TBaseObj::Open(Interface));
    EnableSwClocking(true);
    
	m_deviceID = static_cast<WORD>(ID);	// Set the Device Number to the requested device number set in Matlab.
	DWORD index = -1;
	short numDevices;
	DEVLIST	deviceList[MaxDev];	// Structure containing list of installed boards (MaxDev is defined in driver.h)
	RETURN_ADVANTECH(DRV_DeviceGetList((DEVLIST far *)&deviceList[0], MaxDev, &numDevices));
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
	// Send the driver handle to the circular buffer for DMA buffer allocation.
	m_circBuff.SetDriverHandle(m_driverHandle);
	
	PT_DeviceGetFeatures ptDevFeatures;
	ptDevFeatures.buffer = (LPDEVFEATURES)&m_devFeatures;
	ptDevFeatures.size = sizeof(DEVFEATURES);
	RETURN_ADVANTECH(DRV_DeviceGetFeatures(m_driverHandle, (LPT_DeviceGetFeatures)&ptDevFeatures));
	m_maxAOChl = m_devFeatures.usMaxAOChl;

	// Load all the needed information 
	RETURN_HRESULT(LoadINIInfo());
	RETURN_HRESULT(SetDaqHwInfo());

	//////////////////////////////// Properties ///////////////////////////////////
	// The following Section sets the Propinfo for the Analog output device      //
	///////////////////////////////////////////////////////////////////////////////

	CComPtr<IProp> prop;
	
	// Clock Source
	ATTACH_PROP(ClockSource);
	// Add the Clock Source enumerated values, and set the default
	pClockSource->ClearEnumValues();
	pClockSource->AddMappedEnumValue(CLCK_SOFTWARE, L"Software"); // Software is supported by all
	pClockSource->put_DefaultValue(CComVariant(CLCK_SOFTWARE));
	pClockSource = CLCK_SOFTWARE;
	
	// Sample Rate Property
	// Must change to software clocking (default rate 100) if the board doesn't have an onboard pacer clock.
	ATTACH_PROP(SampleRate);
	
	// For HW clocking, add Internal and External ClockSource if supported (AOMaxSR in INI file) and 
	// change the SR and Transfer Mode
	if (m_maxSampleRate > 0)
	{
		pClockSource->AddMappedEnumValue(CLCK_INTERNAL, L"Internal");
		pClockSource->AddMappedEnumValue(CLCK_EXTERNAL, L"External");
		pClockSource->put_DefaultValue(CComVariant(CLCK_INTERNAL));
		pClockSource = CLCK_INTERNAL;
	}
	ATTACH_PROP(OutOfDataMode);

	// Set the SampleRate range and defaults.
	RangeAndDefaultSR(true);

	// Transfer Mode Property
	CREATE_PROP(TransferMode);			
	pTransferMode->ClearEnumValues();
	if (pClockSource == CLCK_SOFTWARE)
	{
		pTransferMode->AddMappedEnumValue(TRANSFER_SOFTWARE, L"Software");
		pTransferMode.SetDefaultValue(TRANSFER_SOFTWARE);
		pTransferMode = TRANSFER_SOFTWARE;
	}
	else 
	{
		// Advantech does not support interrupt based AO
		// UNCOMMENT the following when boards support interrupt AO
		/*if (m_devFeatures.dwPermutation[0] & DWP_INT_AO)
		{
			pTransferMode->AddMappedEnumValue(TRANSFER_INTERRUPT_PP, L"InterruptPerPoint");
			pTransferMode.SetDefaultValue(TRANSFER_INTERRUPT_PP);	
			pTransferMode = TRANSFER_INTERRUPT_PP;
		}*/
		// if (m_devFeatures.dwPermutation[0] & DWP_DMA_AO)
		{
			pTransferMode->AddMappedEnumValue(TRANSFER_DMA, L"DMA");
			pTransferMode.SetDefaultValue(TRANSFER_DMA);
			pTransferMode = TRANSFER_DMA; 
		}
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////
	// Channel Properties																		   //
	/////////////////////////////////////////////////////////////////////////////////////////////////	
	CRemoteProp rp;

	// The Default Channel Value Property
    rp.Attach(_EngineChannelList,L"DefaultChannelValue",DEFAULTCHANVAL);
	// NOTE: If the PCL-1800 INI entry specifies m_maxSampleRate = 0 then only software clocking
	// is available and so both channels can be added.
	if ((strncmp(m_deviceName, "PCL-1800", 8)==0) && (m_maxSampleRate != 0))
	{
		// Default transfermode for PCL-1800 is DMA - only channel 1 supports this
		rp.SetRange(1, 1);
		rp.SetDefaultValue(1);
	}
	else
	{
		rp.SetRange(0L, m_maxAOChl-1);
		rp.SetDefaultValue(0L);
	}    
    
    rp.Release();

	// The HwChannel Property
	rp.Attach(_EngineChannelList,L"HwChannel",HWCHANNEL);
	// NOTE: If the PCL-1800 INI entry specifies m_maxSampleRate = 0 then only software clocking
	// is available and so both channels can be added.
	if ((strncmp(m_deviceName, "PCL-1800", 8)==0) && (m_maxSampleRate != 0))
	{
		// Default transfermode for PCL-1800 is DMA - only channel 1 supports this
		rp.SetRange((CComVariant)(1), (CComVariant)(1)); 
	}
	else
	{
		rp.SetRange(0L, (CComVariant)(m_maxAOChl-1));	// 0 based index so -1
	}        
    rp.Release();
	
	// The Output Range Property	
	double OutputRange[2];
	// Set the default output range to the range of the first channel, but set the output range of
	// each channel to the value in the Advantech device manager. This is done so that if the user uses the
	// Device manager to configure the device (and particularly in the case of jumpered devices) these settings
	// are retained. Note that the DAQ engine only allows a single default output range, which is arbitrarily set 
	// to the range of the first channel.
	OutputRange[0] = m_channelRanges[0].minVal;
	OutputRange[1] = m_channelRanges[0].maxVal;
	CComVariant var;
	CreateSafeVector(OutputRange, 2, &var);
    rp.Attach(_EngineChannelList, L"outputrange", OUTPUTRANGE);
	// Set the output range to Read-only if the device is jumper-configurable
	if (!m_swOutputRange)
	{
		rp->put_IsReadOnly(true);   
	}
    rp->put_DefaultValue(var);
	GetMaxOutputRange(&OutputRange[0], &OutputRange[1]);
    rp.SetRange(OutputRange[0],OutputRange[1]);
    rp.Release();

	// UnitsRange: Change default value to OutputRange value
	rp.Attach(_EngineChannelList,L"unitsrange");
    rp->put_DefaultValue(var);
	rp.Release();

	// ConversionOffset changes depending on the number of bits. The engine doesnt automatically change the 
	// conversion offset, and MUST be set here
	rp.Attach(_EngineChannelList,L"conversionoffset");
    rp->put_DefaultValue(CComVariant(1<<(m_devFeatures.usNumDABit-1)));	// Note that the conversion offset uses 
																		// the resolution of the device
    rp.Release();							
	
	return S_OK;
} // end of Open()


////////////////////////////////////////////////////////////////////////////////////
// SetDaqHwInfo()
// Sets the fields needed for DaqHwInfo. Is used when you call 
// daqhwinfo(analogoutput('advantech'))
////////////////////////////////////////////////////////////////////////////////////
HRESULT CadvantechAout::SetDaqHwInfo()
{
	// Adaptor Name
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"adaptorname"), CComVariant(Cadvantechadapt::ConstructorName)));
	
	// Bits
	unsigned short bits = m_devFeatures.usNumDABit; // Get the number of bits
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"bits"), CComVariant(bits)));
	
	// Coupling
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"coupling"), CComVariant(L"DC Coupled")));
	
	// Device Name - The device name is made up of three things:
	char tempstr[15] = "";
	sprintf(tempstr, " (Device %d)", m_deviceID); 
	strcat(m_deviceName, tempstr);					
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"devicename"), CComVariant(m_deviceName)));
	
	// Analog output channels IDs
	CComVariant vAOIds;
	// NOTE: If the PCL-1800 INI entry specifies m_maxSampleRate = 0 then only software clocking
	// is available and so both channels can be added. 
	if ((strncmp(m_deviceName, "PCL-1800", 8)==0) && (m_maxSampleRate != 0))
	{
		CreateSafeVector((short*)NULL, (1), &vAOIds);
		TSafeArrayAccess<short> AOIds(&vAOIds);
		// Default transfermode for PCL-1800 is DMA - only channel 1 supports this
		AOIds[0] = 1; 
	}
	else
	{
		CreateSafeVector((short*)NULL, (m_maxAOChl), &vAOIds);
		TSafeArrayAccess<short> AOIds(&vAOIds);
		for (int i=0; i < (m_maxAOChl); i++)
		{
			AOIds[i] = i;
		}
	}
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"channelids"), vAOIds));
	
	// Device ID
	wchar_t idStr2[10];
	swprintf(idStr2, L"%d", m_deviceID );	// Convert the Device id to a string
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"id"), CComVariant(idStr2)));
	
	// Output Ranges:
	int numUniqueOutputRanges = 2;	// We have 2 output ranges for all devices.
	if (m_aoBipolar && m_swOutputRange)
	{
		numUniqueOutputRanges = 4;
	}
	else if (!m_swOutputRange)
	{
		numUniqueOutputRanges = m_numUniqueJumperedOutputRanges;
	}
	CComVariant val;
	
	//Output Ranges		
	// this is a 2-d array of range values
    // there are unipolar and bipolar ranges 
    // both are m_numgains x 2, where m_numgains is the 
	// number of gains supported
	//
	// we want something like this:
	//  
	//  [-.05 .05]
	//  [-.1   .1]
	//  [-.25 .25]
	//   .
	//   .
	//   .
	//  [0  .05]
	//  [0   .1]
	//  [0  .25]
	//  [0   .5]
	SAFEARRAYBOUND rgsabound[2];  // the number of dimensions
	rgsabound[0].lLbound = 0;
	rgsabound[0].cElements = numUniqueOutputRanges; // bipolar and unipolar - size of dimension 1
	rgsabound[1].lLbound = 0;
	rgsabound[1].cElements = 2;     // upper and lower range values - size of dimension 2
	
	SAFEARRAY *ps = SafeArrayCreate(VT_R8, 2, rgsabound); //use the SafeArrayBound to create the array
	if (ps==NULL) 
		throw "Failure to create SafeArray.";
	
	CComVariant var; // setup our variant container of the input range info
	var.parray=ps;
	var.vt = VT_ARRAY | VT_R8;
	double *inRange;
	HRESULT hr = SafeArrayAccessData(ps, (void **) &inRange);
	if (FAILED (hr)) 
	{
		SafeArrayDestroy (ps);
		throw "Failure to access SafeArray data.";
	}    

	double *min, *max; // Pointers to the input range columns
	min = inRange;
	max = inRange + numUniqueOutputRanges;

	// The output ranges are hardcoded because they are common to all supported boards:
	// Bipolar ranges first, lowest to highest:
	if (m_aoBipolar)
	{
		// -5 to 5 V
		if (m_swOutputRange || m_supportedRanges[3])
		{
			*min++ = -5;
			*max++ = 5;
		}
		// -10 to 10 V
		if (m_swOutputRange || m_supportedRanges[2])
		{
			*min++ = -10;
			*max++ = 10;
		}
	}
	// Unipolar ranges are always added:
	// 0 to 5V
	if (m_swOutputRange || m_supportedRanges[0])
	{
		*min++ = 0;
		*max++ = 5;
	}
	// 0 to 10V
	if (m_swOutputRange || m_supportedRanges[1])
	{
		*min++ = 0;
		*max++ = 10;
	}
	
	
	SafeArrayUnaccessData(ps);
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"outputranges"), var));
	
	// Polarity: 

	// Find this based on output ranges. Only the current setting is reported.
	if (m_aoBipolar)	// Supports both unipolar and bipolar ranges
	{
		SAFEARRAY *ps = SafeArrayCreateVector(VT_BSTR, 0, 2); // Create the array for our strings
        if (ps==NULL) 
		{
			return E_FAIL;
		}
        val.Clear();	// Clear the variant
        // set the data type and values
        V_VT(&val)=VT_ARRAY | VT_BSTR;
        V_ARRAY(&val)=ps;
        CComBSTR *polarities; // create the pointer to the data string
		HRESULT    hRes = SafeArrayAccessData (ps, (void **) &polarities);	// Connect it to the safe array
        if (FAILED (hRes)) 
        {
            SafeArrayDestroy (ps);
			return E_FAIL;
        }
        polarities[0]=L"Unipolar";	// Set the data string values
        polarities[1]=L"Bipolar";
		RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"polarity"), val));
		SafeArrayUnaccessData (ps);
        val.Clear(); 
	}
	else	// Only supports unipolar outputs
	{
		RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"polarity"), CComVariant(L"Unipolar")));
	}
	
	// Sample Rate Limits m_minSampleRate
	double maxSR = MAX_SW_SAMPLERATE;
	double minSR = MIN_SW_SAMPLERATE;

	if (m_maxSampleRate > 0) // If not software clcoking
	{
		maxSR = m_maxSampleRate;
		minSR = m_minSampleRate;
	}

	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"maxsamplerate"), CComVariant(maxSR)));
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"minsamplerate"), CComVariant(minSR)));
	
	// Native Data Type: A 16-bit Unsigned Integer
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"nativedatatype"), CComVariant(VT_UI2)));
	
	// Sample Type - This value is hardcoded
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"sampletype"),CComVariant(0)));
	
	// Total number of channels
	// NOTE: If the PCL-1800 INI entry specifies m_maxSampleRate = 0 then only software clocking
	// is available and so both channels can be added. 
	if ((strncmp(m_deviceName, "PCL-1800", 8)==0) && (m_maxSampleRate != 0))
	{
		// Default transfermode for PCL-1800 is DMA - only channel 1 supports this
		RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"totalchannels"),CComVariant(1))); 
	}
	else
	{
		RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"totalchannels"),CComVariant(m_maxAOChl)));
	}
	
	// Vendor Driver Description
	char vendorDriverDescription[30];
	strcpy(vendorDriverDescription, m_devFeatures.szDriverName);
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"vendordriverdescription"),CComVariant(vendorDriverDescription)));
	
	// Vendor Driver Version
	char vendorDriverVersion[30]; 
	strcpy(vendorDriverVersion, m_devFeatures.szDriverVer);
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"vendordriverversion"),CComVariant(vendorDriverVersion)));

	return S_OK;
} // end of SetDaqHwInfo()


///////////////////////////////////////////////////////////////////////////////////
// PutSingleValue()
//
// This function gets one single data point form one A/D channel, specified..
//..as a parameter.
// Function is called by GetSingleValues() of the TADDevice class, which..
// ..in turn is called by the engine as a responce to the ML user command GETSAMPLE.
// Function MUST BE MODIFIED by the adaptor programmer.
////////////////////////////////////////////////////////////////////////////////////
HRESULT CadvantechAout::PutSingleValue(int chan,RawDataType value)
{
	PT_AOConfig ptAOConfig;
	ptAOConfig.chan = (USHORT)chan;
	ptAOConfig.RefSrc = (USHORT)0;
    ptAOConfig.MaxValue = (FLOAT)m_channelRanges[chan].maxVal;
	ptAOConfig.MinValue = (FLOAT)m_channelRanges[chan].minVal;

	PT_AOBinaryOut ptAOBinaryOut;
	ptAOBinaryOut.chan = (USHORT)chan;
	ptAOBinaryOut.BinData = (USHORT)value;

	RETURN_ADVANTECH(DRV_AOBinaryOut(m_driverHandle,(LPT_AOBinaryOut)&ptAOBinaryOut));
    return S_OK;
} // end of PutSingleValue()


////////////////////////////////////////////////////////////////////////////////////
// LoadINIInfo()
// Load information from the INI file. 
////////////////////////////////////////////////////////////////////////////////////
HRESULT CadvantechAout::LoadINIInfo()
{
	char demoName1[15];
    char demoName2[15];
	char fname[512];
    
    // we expect the INI file to be in the same directory as the application,
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
		char *ch = strchr(m_deviceName,' ');
		int spaceAddress = ch - m_deviceName + 1;
		StrCpyN(m_deviceName, m_deviceName, spaceAddress);
		m_swOutputRange = GetPrivateProfileBool(m_deviceName, "SWOutputRange", false, fname);	
		m_aoBipolar = GetPrivateProfileBool(m_deviceName, "AOBipolar", false, fname);	
		m_maxSampleRate = GetPrivateProfileDouble(m_deviceName, "AOMaxSR", 0, fname);
		m_minSampleRate = GetPrivateProfileDouble(m_deviceName, "AOMinSR", 0, fname);
		// Now we read the current output range settings from the registry:
		RETURN_HRESULT(LoadOutputRanges());
	}
	// The PCI-1712L does not support hardware clocked AO. This device has the same m_DeviceName
	// as the PCI-1712, for which the INI file records the max samplerate as 1e6. It is necessary to
	// setup the correct values for samplerate here.
	if ((!lstrcmp(m_deviceName, "PCI-1712")) && (!(m_devFeatures.dwPermutation[0] & (1<<5))))
	{
		m_maxSampleRate = 0;	
		m_minSampleRate = 0;
	}
	return S_OK;
} // end of LoadINIInfo()


////////////////////////////////////////////////////////////////////////////////////
// LoadOutputRanges()
//		
// Description: This method Reads currently configured channel output ranges for
// setting default output range in our adaptor.
//					
////////////////////////////////////////////////////////////////////////////////////
HRESULT CadvantechAout::LoadOutputRanges()	
{
	// Get the input type from the registry using the following path:
	// HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\<drivername>s\device<ID=%03d>\ChanConfig
	// Recent Advantech devices use ADS****s as the registry key name
	// or:
	// HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\ADSIO\device<ID=%03d>\ChanConfig
	// Older Advantech devices use ADSIO (and not the driver name) as the registry key name.

	m_supportedRanges[0] = false;
	m_supportedRanges[1] = false;
	m_supportedRanges[2] = false;
	m_supportedRanges[3] = false;
	
	std::vector<short> ranges;
	RANGE_INFO NewInfo;

	HKEY hMainKey = HKEY_LOCAL_MACHINE;
	char deviceKey[10];
	int res = sprintf(deviceKey, "device%03d", m_deviceID);
	HKEY hSubKey;

	char vendordriverdescription[30]; // The place to store the driver description
	int drvNameLen = strlen(m_devFeatures.szDriverName);
	strncpy(vendordriverdescription, m_devFeatures.szDriverName, drvNameLen-4);
	// Append the zero
	vendordriverdescription[drvNameLen-4]=0;
	strcat(vendordriverdescription,"s");	// Append "s"

	if (::RegOpenKey(hMainKey, "SYSTEM", &hSubKey) == ERROR_SUCCESS)
	{
		HKEY hSubKey1;
		if (::RegOpenKey(hSubKey, "CurrentControlSet", &hSubKey1) == ERROR_SUCCESS)
		{
			HKEY hSubKey2;
			if (::RegOpenKey(hSubKey1, "Services", &hSubKey2) == ERROR_SUCCESS)
			{
				HKEY hSubKey3;
				if ((::RegOpenKey(hSubKey2, vendordriverdescription, &hSubKey3) == ERROR_SUCCESS) || 
						(::RegOpenKey(hSubKey2, "ADSIO", &hSubKey3) == ERROR_SUCCESS))				
				{
					HKEY hSubKey4;
					if (::RegOpenKeyEx(hSubKey3, deviceKey, 0, KEY_QUERY_VALUE, &hSubKey4) == ERROR_SUCCESS)
					{
						char outputRange[35];
						DWORD outputRangeSize = 35;
						DWORD Type;
						char buffer[4];
						char AOChannel[13];
						
						for (int i=0; i < m_maxAOChl; i++)
						{
							strcpy(AOChannel,"AOSettings ");
							_itoa(i, buffer, 10); // Convert i to a string
							strcat(AOChannel, buffer);
							HRESULT HValRes = RegQueryValueEx(hSubKey4, AOChannel, NULL, &Type, (UCHAR *) &outputRange, &outputRangeSize);
							if (HValRes == ERROR_SUCCESS)
							{		
								bool legalChannel = false;
								if(!StrCmpN("     0     5     0",outputRange, 18))
								{
									NewInfo.minVal = 0;
									NewInfo.maxVal = 5;
									legalChannel = true;
									if (!m_supportedRanges[0])
										m_numUniqueJumperedOutputRanges++;								
									m_supportedRanges[0] = true;									
										
								}
								if(!StrCmpN("     0    10     0",outputRange, 18))
								{
									NewInfo.minVal = 0;
									NewInfo.maxVal = 10;
									legalChannel = true;
									if (!m_supportedRanges[1])
										m_numUniqueJumperedOutputRanges++;									
									m_supportedRanges[1] = true;
								}
								if(!StrCmpN("     0    10   -10",outputRange, 18))
								{
									NewInfo.minVal = -10;
									NewInfo.maxVal = 10;
									legalChannel = true;
									if (!m_supportedRanges[2])
										m_numUniqueJumperedOutputRanges++;
									m_supportedRanges[2] = true;
								}
								if(!StrCmpN("     0     5    -5",outputRange, 18))
								{
									NewInfo.minVal = -5;
									NewInfo.maxVal = 5;
									legalChannel = true;
									if (!m_supportedRanges[3])
										m_numUniqueJumperedOutputRanges++;									
									m_supportedRanges[3] = true;
								}

								if (!legalChannel)
								{
									return E_AOCHANEXT;
								}
							
								m_channelRanges.push_back(NewInfo);
							}
						}
						::RegCloseKey(hSubKey4);
					}
					::RegCloseKey(hSubKey3);
				}
				::RegCloseKey(hSubKey2);
			}
			::RegCloseKey(hSubKey1);
		}
		::RegCloseKey(hSubKey);
	}
	return S_OK;
} // end of GetOutputRanges()


////////////////////////////////////////////////////////////////////////////////////
// GetMaxOutputRange()
// Find the largest output range
//					
////////////////////////////////////////////////////////////////////////////////////
void CadvantechAout::GetMaxOutputRange(double *lowRange, double *highRange)
{

	RangeList_t::iterator it = m_channelRanges.begin();
	*lowRange = (*it).minVal;
	*highRange = (*it).maxVal;
	// For jumpered boards, return the highest current value.
	if (!m_swOutputRange)
	{
		for (it = m_channelRanges.begin(); it != m_channelRanges.end(); it++)
		{
			if ((it != m_channelRanges.begin()) && ((*it).maxVal > (*(it-1)).maxVal))
			{
				*lowRange = (*it).minVal;
				*highRange = (*it).maxVal;
			}
		}
	}
	else
	{
		if (m_aoBipolar) // If Bipolar
		{
			*lowRange = -10;
			*highRange = 10;
		}
		else
		{
			*lowRange = 0;
			*highRange = 10;
		}
	}
} // end of GetMaxOutputRange()


////////////////////////////////////////////////////////////////////////////////////
// SetProperty()
// Called by the engine when a property is set
// An interface to the property along with the new value is passed to the method.
////////////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CadvantechAout::SetProperty(long User, VARIANT *NewValue)
{
	if (User)
	{
		CLocalProp* pProp=PROP_FROMUSER(User);
		variant_t *val = (variant_t*)NewValue;  // variant_t is a more friendly data type to work with.
		
		// Sample Rate
		if (User==USER_VAL(pSampleRate))
		{
			if (pClockSource == CLCK_SOFTWARE)
			{
				// Check validity of new user entered sample rate
				return CswClockedDevice::SetProperty(User, NewValue);
			}
			if (pClockSource == CLCK_INTERNAL)
			{
				// Quantise the given sample rate
				double newrate = *val;	
				pSampleRate = QuantiseValue(newrate);						 
				*val = pSampleRate;	
			}
		}
		// Clock Source Property: affects SampleRate and TransferMode
		if (User == USER_VAL(pClockSource))
		{

			// Error if changing to INTERNAL or EXTERNAL and more than one channel
			if ((((long)(*val) == CLCK_INTERNAL) || ((long)(*val) == CLCK_EXTERNAL)) && (_nChannels > 1))
			{
				return E_AOHWMULTCHAN;
			}
			pClockSource = *val;
			// TransferMode changes when we change Clock Source.
			pTransferMode->ClearEnumValues();
			if (pClockSource == CLCK_SOFTWARE)
			{	
				pTransferMode->AddMappedEnumValue(TRANSFER_SOFTWARE, L"Software");
				pTransferMode.SetDefaultValue(TRANSFER_SOFTWARE);
				pTransferMode = TRANSFER_SOFTWARE; 
				pSampleRate = RoundRate(pSampleRate );
			}
			else 
			{	
				// Advantech does not support interrupt AO
				// UNCOMMENT when they do
				/*
				if (m_devFeatures.dwPermutation[0] & DWP_INT_AO)
				{
					pTransferMode->AddMappedEnumValue(TRANSFER_INTERRUPT_PP, L"InterruptPerPoint");
					pTransferMode.SetDefaultValue(TRANSFER_INTERRUPT_PP);	
					pTransferMode = TRANSFER_INTERRUPT_PP;
				}
				if (m_devFeatures.dwPermutation[0] & DWP_DMA_AO)		*/
				{
					pTransferMode->AddMappedEnumValue(TRANSFER_DMA, L"DMA");
					pTransferMode.SetDefaultValue(TRANSFER_DMA);
					pTransferMode = TRANSFER_DMA; 
				}
			}
			// Reset defaults for Sample rates, but not the rate itself
			RangeAndDefaultSR(false);

			// The PCL-1800 must use channel 1 for hardware clocking. If the clocksource (and hence
			// transfermode) is changed then the channel range, default channel etc. must also be updated. 
			// then if the device 
			CComVariant vAOIds;
			int totalNumChans;
			CRemoteProp rp;
			rp.Attach(_EngineChannelList,L"DefaultChannelValue",DEFAULTCHANVAL);
			// NOTE: If the PCL-1800 INI entry specifies m_maxSampleRate = 0 then only software clocking
			// is available and so both channels can be added. 
			if ((strncmp(m_deviceName, "PCL-1800", 8)==0) && (m_maxSampleRate != 0))
			{
				//if (pTransferMode == TRANSFER_DMA)
				if (pClockSource == CLCK_INTERNAL)
				{
					// Analog output channels IDs, we only have channel ID 1 for DMA			
					CreateSafeVector((short*)NULL, (1), &vAOIds);
					TSafeArrayAccess<short> AOIds(&vAOIds);									
					AOIds[0] = 1; 							

					// Total number of channels					
					totalNumChans = 1; 

					// The HwChannel Property
					rp.Attach(_EngineChannelList,L"HwChannel",HWCHANNEL);
					rp.SetRange((CComVariant)(1), (CComVariant)(1)); 				
				}	
				else
				{
					// Changing back to software clocking, so change setup for 2 channels
					// Analog output channels IDs
					CreateSafeVector((short*)NULL, (m_maxAOChl), &vAOIds);
					TSafeArrayAccess<short> AOIds(&vAOIds);
					for (int i=0; i < (m_maxAOChl); i++)
					{
						AOIds[i] = i;
					}

					// Total number of channels
					totalNumChans = m_maxAOChl;

					// The HwChannel Property
					rp.Attach(_EngineChannelList,L"HwChannel",HWCHANNEL);
					rp.SetRange(0L, (CComVariant)(m_maxAOChl-1));	// 0 based index so -1
				}
				// Setup properties
				RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"channelids"), vAOIds));
				RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"totalchannels"),CComVariant(totalNumChans)));
				rp.Release();
			}	
		}
		

		// OutOfDataMode property.
		if (User == USER_VAL(pOutOfDataMode))
		{
			_updateChildren = true; // Ensure that channel defaults are updated before starting
		}

		// Finally, set the actual value
        pProp->SetLocal(*val);
	}
	return S_OK;
} // end of SetProperty()


////////////////////////////////////////////////////////////////////////////////////
// SetChannelProperty()
// Called by the engine when a channel property is set
// An interface to the property, the new value and as a link to the channel are passed 
// to the method
////////////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CadvantechAout::SetChannelProperty(long UserVal, tagNESTABLEPROP *pChan, VARIANT *NewValue)
{
	int Index = pChan->Index-1;
	variant_t& vtNewValue = reinterpret_cast<variant_t&>(*NewValue);
    
	if(UserVal == OUTPUTRANGE)
	{
		TSafeArrayAccess<double> NewRange(NewValue);
		if (!m_swOutputRange)	// If the device is not software configurable...
		{
			// Ignore their setting. Set it back to the original value.
			NewRange[0] = m_channelRanges[pChan->HwChan].minVal;
			NewRange[1] = m_channelRanges[pChan->HwChan].maxVal;
		}
		else  
		{
			// If the device is software configurable then set the output range to the value closest
			// to, but not smaller than, the users desired range

			// Find best upper value
			if (NewRange[1] > 5)
				NewRange[1] = 10;
			else
				NewRange[1] = 5;

			// Find best lower value
			if (NewRange[0] >= 0)
				NewRange[0] = 0;
			else if (NewRange[0] < -5)
				NewRange[0] = -10;
			else
				NewRange[0] = -5;

			PT_AOConfig ptAOConfig;
			ptAOConfig.chan = (USHORT)pChan->HwChan;
			ptAOConfig.RefSrc = 0; // Hardcoded to internal. This adaptor does not support external ref voltages.
			ptAOConfig.MaxValue = (float)NewRange[1];
			ptAOConfig.MinValue = (float)NewRange[0];
			RETURN_ADVANTECH(DRV_AOConfig(m_driverHandle, (LPT_AOConfig)&ptAOConfig));
		}
	}
	
	
	return S_OK;
} // end of SetChannelProperty()

////////////////////////////////////////////////////////////////////////////////////
// ChildChange()
// Check the validity of adding/deleting channels and updates the 
// relevant properties.
//	
////////////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CadvantechAout::ChildChange(DWORD typeofchange, NESTABLEPROP *pChan)
{
	long numChans; 
    HRESULT hRes = _EngineChannelList->GetNumberOfChannels(&numChans);

	// When a channel is deleted, the ChildChange method is called 3 times. On the initial call, pChan is given 
	// the value NULL and thus an error would occur when analysing the DELETE_CHILD section. For this reason 
	// we wait for pChan to be returned with a value, before analysing the current situation.
	if (pChan)	
	{
		if ((typeofchange & CHILDCHANGE_REASON_MASK) == ADD_CHILD) 	// Note bit wise comparison
		{
			// Channels must be consecutive (ascending) and not repeated
			// The following is implemented:
			//       If I'm the first channel, just add me to the list
			//       If I'm not the first channel, I must be one more than the last.
			// NOTE 1: The range of Hwchan is set according to the currently set input type, so its not necessary 
			//		 to check how many channels have been added, as this is checked by the engine.

			// NOTE 2: This is not actually necessary for software clocking, but if the user changes from software
			// to Internal, then if we have not ensured that the channels are added in ascending order, we will have
			// to remove all the channels added so far and start all over again
			
			// Error if the channel is added in an incorrect order, or repeated.
			// Error if using hardware clocks and trying to add channels
			if ((pTransferMode == TRANSFER_DMA) && (pChan->HwChan != 1) && (strncmp(m_deviceName, "PCL-1800", 8)==0))
			{
				// This code specific to the PCL-1800: Only channel 1 is available for DMA transfer mode
				return E_NOTDMACHAN; 
			}

			if (numChans >= 2)
			{
				// Get the HWID of the last channel in the list.
				NESTABLEPROP *lastChan;
				_EngineChannelList->GetChannelStructLocal(numChans-2, &lastChan);
				if (pChan->HwChan != lastChan->HwChan + 1) // only consecutive channels allowed
				{
					// Advantech can support channel lists of the form 5 6 7 0 1 2 ...
					// but we will only support channels in consecutive, ascending order, eg 3 4 5 6 7
					return E_CHANORDER;
				}
			}
			// Note all clocked AO is for one channel only
			if ((numChans > 1) && (pClockSource != CLCK_SOFTWARE))
			{
				return E_AOHWCHANADD;
			}
		}
		
		if ((typeofchange & CHILDCHANGE_REASON_MASK)== DELETE_CHILD)
		{
			// Channels can only be deleted from the ends of the channels list in consecutive order
			if (numChans > 2)	// If there are only two channels, either can be deleted
			{
				// Get the HWID of the last channel in the list.
				NESTABLEPROP *lastChan;
				NESTABLEPROP *firstChan;
				_EngineChannelList->GetChannelStructLocal(numChans-1, &lastChan);
				_EngineChannelList->GetChannelStructLocal(0, &firstChan);
				if ((pChan->HwChan != lastChan->HwChan) && (pChan->HwChan != firstChan->HwChan))
				{
					return E_CHANDELETE;
				}
			}
		}
	}
	if (typeofchange & END_CHANGE)	// If deleting a channel, ChildChange called with NULL pchan so must check this here
	{
		_nChannels = numChans;	// Store data in the local variable _nChannels
		
		// When a channel is added pChan is returned with a value, when a channel is deleted 
		// pChan is returned as NULL
		if (pChan)	
		{
			CRemoteProp rp;
			AOCHANNEL *pchan;
			pchan = (AOCHANNEL*)pChan;

			// Set new channels range to default value...
			pchan->VoltRange[0] = m_channelRanges[(pChan->HwChan)].minVal;	
			pchan->VoltRange[1] = m_channelRanges[(pChan->HwChan)].maxVal;
			pchan->UnitRange[0] = m_channelRanges[(pChan->HwChan)].minVal;	
			pchan->UnitRange[1] = m_channelRanges[(pChan->HwChan)].maxVal;

			// Advantech devices have only one clocked AO channel - so it is not
			// necessary to change the sample rate range.
			/*
			// Evaluate SampleRate range/default value based on number of channels created
			pSampleRate.SetRange(MIN_SW_SAMPLERATE, MAX_SW_SAMPLERATE);
			pSampleRate.SetDefaultValue(MAX_SW_SAMPLERATE);
			*/
		}
	}
			
	return S_OK;
} // end of ChildChange()


////////////////////////////////////////////////////////////////////////////////////
// Start()
// Prepare for analog output task.
////////////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CadvantechAout::Start()
{
	// Add this device to the running list
	if (GetParent()->AddDev((analogoutputMask + m_deviceID),this))
	{
		return E_DEVICE_RUNNING;
	}

	if (pClockSource == CLCK_SOFTWARE)
		return OutputType::Start();
	
	// Arbitrarily assign a default value to be output when the acquisition ends
    m_defaultChannelValue=0;

	// We keep track of what's gone to Advantech using two variables.
	m_pointsToAdvBuffer = 0;
	m_pointsToHardware = 0;
	m_lastBufferLoaded = false;
	m_prevPosted = 0;

	// Determine the buffer size:
	_engine->GetBufferingConfig(&m_engBuffSizePoints, NULL);
	m_engBuffSizePoints *= _nChannels; 
	long advBuffSizePoints =  m_engBuffSizePoints * 8;  // 8 engine buffers in total.
	if (advBuffSizePoints < 8*1024)
	{
		advBuffSizePoints = 8*1024; 
	}

	// Advantech ISA DMA devices require a DMA buffer of at most 16k points, this 
	// results in a restriction on the engine buffer sizes
	if (advBuffSizePoints > 16*1024)
	{
        advBuffSizePoints = 16*1024;
		// Are there enough engine buffers
		if (advBuffSizePoints < 2*m_engBuffSizePoints)
		{
			return E_BUFDMASIZE;
		}
	} 

	// But if it's a PCI-1712, you HAVE to have 32k buffers!
	if (strncmp(m_deviceName, "PCI-1712", 8)==0)
	{
		advBuffSizePoints = 32768;
		if (m_engBuffSizePoints > 16*1024)
		{
			return E_BUFSIZELARGE;
		}
	}
	int cyclicMode = 1;	// Always assume cyclic mode, since we don't know when to stop!
	HRESULT hRes = m_circBuff.Initialize(advBuffSizePoints, false, cyclicMode);
	
	if (hRes != 0)
	{
		GetParent()->DeleteDev((analogoutputMask + m_deviceID));
	}
	RETURN_HRESULT(hRes);

	NESTABLEPROP *firstChan;
	_EngineChannelList->GetChannelStructLocal(0, &firstChan);

	// Setup acquisition
	// No Advantech boards support interrupt AO
	// UNCOMMENT if this is not the case
	/*
	if (pTransferMode == TRANSFER_INTERRUPT_PP)
	{	
		m_ptFAOIntStart.TrigSrc    = (pClockSource == CLCK_EXTERNAL) ? 1: 0;	
		m_ptFAOIntStart.SampleRate = pSampleRate*_nChannels;
		m_ptFAOIntStart.chan       = firstChan->HwChan;
		m_ptFAOIntStart.buffer	   = (LONG far *) m_circBuff.GetPtr();
		m_ptFAOIntStart.count      = advBuffSizePoints; 
		m_ptFAOIntStart.cyclic     = cyclicMode; 
	}
	else	*/
	{
        m_ptFAODmaStart.TrigSrc    = (pClockSource == CLCK_EXTERNAL) ? 1: 0;
        m_ptFAODmaStart.SampleRate = static_cast<DWORD>(pSampleRate*_nChannels);
        m_ptFAODmaStart.chan       = static_cast<USHORT>(firstChan->HwChan);
        m_ptFAODmaStart.buffer     = (LONG far *)m_circBuff.GetPtr();
        m_ptFAODmaStart.count      = advBuffSizePoints; 

		// Even though the DMA buffer (m_DMABuffer) is never used we must still allocate it's memory
		// Advantech ISA DMA devices require a DMA buffer of at most 16k points, this 
		// results in a restriction on the engine buffer sizes
		PT_AllocateDMABuffer  ptAllocateDMABuffer;
		ptAllocateDMABuffer.CyclicMode = cyclicMode;
		ptAllocateDMABuffer.RequestBufSize = advBuffSizePoints * 2;
		ptAllocateDMABuffer.ActualBufSize = (ULONG *) &advBuffSizePoints;
		ptAllocateDMABuffer.buffer = &m_DMABuffer;
		HRESULT hRes = DRV_AllocateDMABuffer(m_driverHandle, (LPT_AllocateDMABuffer)&ptAllocateDMABuffer);
		if (hRes != SUCCESS)
		{
			return E_ADVALLOCDMA;
		}
	}
        
	// Two timer ticks per smallest buffer
	m_timerPeriod = static_cast<double>(min(advBuffSizePoints,m_engBuffSizePoints)/_nChannels/pSampleRate/2);

	// Now we need to load the initial data	
	m_initialLoad = true; // Set flag to indicate that memcpy should be used in CopyIn as output has not started yet 
	RETURN_HRESULT(LoadData());
	m_initialLoad = false; // Set flag to indicate that FAOLoad should be used in CopyIn when output starts

	return S_OK;
}


////////////////////////////////////////////////////////////////////////////////////
// Trigger()
// Start the task.
////////////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CadvantechAout::Trigger()
{
	if (pClockSource == CLCK_SOFTWARE)
		return OutputType::Trigger();

	StopDeviceIfRunning();

	// Disable all events explicitly
	PT_EnableEvent ptEnableEvent;
	ptEnableEvent.EventType = 15;
    ptEnableEvent.Enabled = 0;
	ptEnableEvent.Count = 1;
	HRESULT hRes = DRV_EnableEvent(m_driverHandle,(LPT_EnableEvent)&ptEnableEvent);
	if (hRes != 0)
	{
		GetParent()->DeleteDev((analogoutputMask + m_deviceID));
	}
	RETURN_ADVANTECH(hRes);
		
	// Advantech does not support interrupt AO
	/*
	if (pTransferMode == TRANSFER_INTERRUPT_PP)
	{
		hRes = DRV_FAOIntStart(m_driverHandle, (LPT_FAOIntStart)&m_ptFAOIntStart);
	}
	else  */    // Start DMA task  
	{
		hRes = DRV_FAODmaStart(m_driverHandle, (LPT_FAODmaStart)&m_ptFAODmaStart);
	}
	if (hRes != 0)
	{
		GetParent()->DeleteDev((analogoutputMask + m_deviceID));
	}
	RETURN_ADVANTECH(hRes);

	m_putStatus=RUNNING;
	_running = true;
	TimerObj.CallPeriod(m_timerPeriod);	
	//DEBUG: ATLTRACE("Starting timer.\n");
	return S_OK;
}


////////////////////////////////////////////////////////////////////////////////////
// Stop()
// Stop the output
////////////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CadvantechAout::Stop()
{
	GetParent()->DeleteDev((analogoutputMask + m_deviceID));
	if (pClockSource == CLCK_SOFTWARE)
	{
		return OutputType::Stop();
	}
	if (_running)
    {	
		TimerObj.Stop();
		AUTO_LOCK;
		RETURN_HRESULT(StopDeviceIfRunning()); 
		_running = false; // Reset flag
	}
	
	return S_OK;
}

//////////////////////////////////////////////////////////////////////////////////////////
// FindRange()
// This function checks to see if the range passed to it is valid according to what
// the card supports. It returns either the selected range or the closest (larger) range. 
//////////////////////////////////////////////////////////////////////////////////////////
HRESULT CadvantechAout::FindRange(float low, float high, RANGE_INFO *&pRange)
{
	// Find best upper value
	if (high > 5)
		(pRange)->maxVal=10;
	else
		(pRange)->maxVal=5;

	// Find best lower value
	if (low > 0)
		(pRange)->minVal=0;
	else if (low < -5)
		(pRange)->minVal=-10;
	else
		(pRange)->minVal=-5;
	
	return S_OK;
}


///////////////////////////////////////////////////////////////////////////////////
// QuantiseValue()
// The new sample rate is passed to this method which selects the closest quantised 
// equivelent sample rate.  
////////////////////////////////////////////////////////////////////////////////////
double CadvantechAout::QuantiseValue(double rate)
{
	// Advantech drivers require an INTEGER sample rate (unsigned long) so we have no choice but to...
	return ceil(rate);
} // end of QuantiseValue()


///////////////////////////////////////////////////////////////////////////////////
// RangeAndDefaultSR()
// This method sets sample rate range and channelskew value based on the currently   
// selected clock source and number of channels created.
////////////////////////////////////////////////////////////////////////////////////
void CadvantechAout::RangeAndDefaultSR(bool updateVal)
{
	if (pClockSource == CLCK_SOFTWARE)
	{
		pSampleRate.SetRange(MIN_SW_SAMPLERATE, MAX_SW_SAMPLERATE);
		pSampleRate.SetDefaultValue(100);
		if (updateVal)
		{
			pSampleRate = 100;
		}
	}
	else // For internal and external clocking:
	{
		pSampleRate.SetRange(m_minSampleRate, m_maxSampleRate);
		pSampleRate.SetDefaultValue(1000);
		if (updateVal)
		{
			pSampleRate = 1000;
		}
	}

} // end of RangeAndDefaultSR()


////////////////////////////////////////////////////////////////////////////////////
// StopDeviceIfRunning()	
// Call driver stop if required.
////////////////////////////////////////////////////////////////////////////////////
HRESULT CadvantechAout::StopDeviceIfRunning()
{
	if (m_putStatus==RUNNING)
	{
		RETURN_ADVANTECH(DRV_FAOStop(m_driverHandle));
		m_putStatus=IDLE;

		if (TRANSFER_DMA)
		{
			// Free the DMA buffer through Advantech
			LRESULT FreeDMABuffererror = DRV_FreeDMABuffer(m_driverHandle, (LPARAM)&m_DMABuffer);
		}
	}
	return S_OK;
} // end of StopDeviceIfRunning()


////////////////////////////////////////////////////////////////////////////////////
// SyncAndLoadData()
// Get data from engine and put into Advantech buffers. Called by timer routine.
////////////////////////////////////////////////////////////////////////////////////
HRESULT CadvantechAout::SyncAndLoadData()
{
    AUTO_LOCK;    
	// Check transfer progress.
	//DEBUG	ATLTRACE("In SyncAndLoadData()\n");
	LRESULT checkerror = DRV_FAOCheck(m_driverHandle, (LPT_FAOCheck)&m_ptFAOCheck);

	// Add delta to m_pointsToHardware
	long deltaPoints = m_posted - m_prevPosted;
	if (deltaPoints < 0)
	{
		// We've had a wrap!
		deltaPoints += m_circBuff.GetBufferSize();
	}
	m_pointsToHardware +=  deltaPoints;
	
	// Update the engine with the number of samples output. This value cant be 
	// greater than the amount of data put by the user		
	_samplesOutput = min(m_pointsToHardware, m_pointsToAdvBuffer);

	m_prevPosted = m_posted;

	if (m_circBuff.IsWriteUnderrun(m_posted) && !m_lastBufferLoaded)
	{
		_engine->DaqEvent(EVENT_ERR, 0, m_pointsToHardware, NULL);
		RETURN_HRESULT(StopDeviceIfRunning()); 
		GetParent()->DeleteDev((analogoutputMask + m_deviceID));
	}

	// Set the read location according to the m_posted value:
	m_circBuff.SetReadLocation((int) m_posted);

	// If last buffer and pointsToHW>pointToAdvantech, stop
	// DEBUG: ATLTRACE("In SyncAndLoadData... m_pointsToHardware: %d\tm_pointsToAdvBuffer: %d\n",m_pointsToHardware, m_pointsToAdvBuffer);
	// DEBUG: ATLTRACE("Address of SyncAndLoadData's m_pointsToAdvBuffer: %d\n", &m_pointsToAdvBuffer);
	// DEBUG: ATLTRACE("m_lastBufferLoaded is: %d\n", m_lastBufferLoaded);
	// DEBUG: ATLTRACE("m_pointsToAdvBuffer: %d\n", m_pointsToAdvBuffer);
	if (m_lastBufferLoaded && (m_pointsToHardware >= m_pointsToAdvBuffer))
	{
		//DEBUG: ATLTRACE("\nSHOULD HAVE STOPPED!!!\n\n");
			_engine->DaqEvent(EVENT_STOP, -1, m_pointsToAdvBuffer, NULL);
			RETURN_HRESULT(StopDeviceIfRunning()); 
			// Now deleting device from list so that another acquisition can take place
			GetParent()->DeleteDev((analogoutputMask + m_deviceID));
			return 1;
	}
	// Load more data
	//DEBUG: ATLTRACE("\tCalling LoadData()...");
	RETURN_HRESULT(LoadData());
	return S_OK;
}


////////////////////////////////////////////////////////////////////////////////////
// LoadData()
// Send one engine buffer to Advantech
////////////////////////////////////////////////////////////////////////////////////
HRESULT CadvantechAout::LoadData()
{
	AUTO_LOCK;
    BUFFER_ST* pBuf=NULL;
	// Keep filling up buffers until there's no space left.
	// BEWARE: We may need to fill the buffer ourselves with OOD values
	// DEBUG: ATLTRACE("In LoadData. Free Space is %d...\n", m_circBuff.FreeSpace());
    while (m_circBuff.FreeSpace() > m_engBuffSizePoints) // NOTE: must be > as we have to leave free space for one engbuffer
    {
		// DEBUG: ATLTRACE("\tFree Space is now %d...\n", m_circBuff.FreeSpace());
		
		// We can handle another buffer
        HRESULT hRes = _engine->GetBuffer(0, &pBuf);
        if (FAILED(hRes) || pBuf==NULL)
        {
			//DEBUG: ATLTRACE("\t\tNo More engine buffers. Making up my own.\n");
			// We've run out of engine buffers. 
			// We make a fake buffer and copy the OOD values without updating the number of points copied.
			int size1,size2;
			CIRCBUFFER::CBT *ptr1, *ptr2;
			CIRCBUFFER::CBT* dummyBuffer = (CIRCBUFFER::CBT*)_alloca(m_engBuffSizePoints * sizeof(unsigned short));
			ATLTRACE("\nm_defaultChannelValue is: %d\n", m_defaultChannelValue);
			for (int i = 0; i<m_engBuffSizePoints; i++)
			{
				dummyBuffer[i] = m_defaultChannelValue;
			}

			m_circBuff.GetWritePointers(&ptr1, &size1, &ptr2, &size2);
			for (i=0;i<size1;i++) 
			{
				*ptr1++=dummyBuffer[i % 1];
			}
            if (ptr2)  // The next line assums that all buffer sizes are a clean multiple of channels
			{
                for (int i=0;i<size2;i++) 
				{
					*ptr2++=dummyBuffer[i % 1];
				}
			}
			return S_OK;
		}
		else
		{
			//DEBUG: ATLTRACE("\t\tCopied %d points from MATLAB into Advantech buffer.\n", pBuf->ValidPoints);
	        m_pointsToAdvBuffer += pBuf->ValidPoints;
			//DEBUG: ATLTRACE("\t\tLoadData's m_pointsToAdvBuffer: %d\n",m_pointsToAdvBuffer);
			//DEBUG:ATLTRACE("\t\tAddress of LoadData's m_pointsToAdvBuffer: %d\n", &m_pointsToAdvBuffer);
	        RETURN_HRESULT(m_circBuff.CopyIn((CIRCBUFFER::CBT*)pBuf->ptr, pBuf->ValidPoints, m_initialLoad));
			if (pBuf->Flags & BUFFER_IS_LAST)
			{				
				m_lastBufferLoaded=true;
				if (pOutOfDataMode == ODM_HOLD)
				{
					// Get the last valid value from this buffer and assign to m_defaultChannelValue
					unsigned short* plast = (unsigned short *)(pBuf->ptr) + pBuf->ValidPoints - _nChannels;
					for (int i=0; i<_nChannels; i++)
					{
						m_defaultChannelValue = plast[i];
					}
				}
			}
			_engine->PutBuffer(pBuf);
		}
    }
	return S_OK;
}
