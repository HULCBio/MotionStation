// advantechAin.cpp : Implementation of CadvantechAin class
// Copyright 2002-2003 The MathWorks, Inc.
// $Revision: 1.1.6.2 $  $Date: 2003/12/04 18:39:16 $

#include <winbase.h>
#include "stdafx.h"
#include "mwadvantech.h"
#include "advantechAin.h"
#include "advantechadapt.h"
#include "advantecherr.h"   // Advantech error codes
#include "advantechUtil.h"	// Advantech utility functions
#include "advantechpropdef.h"
#include <limits>
#include "adaptorkit.h"

#define AUTO_LOCK TAtlLock<CadvantechAin> _lock(*this)	
#define INFINITY std::numeric_limits<double>::infinity()
#define SUPPORTS_IPP (m_aiInterruptMode & 1)
#define SUPPORTS_IPB (m_aiInterruptMode & 2)


////////////////////////////////////////////////////////////////////////////////////
// CadvantechAin() default constructor
//
// Function performs all the necessary initializations.
////////////////////////////////////////////////////////////////////////////////////
CadvantechAin::CadvantechAin():
	m_pParent(NULL),
	m_inputType(IT_SINGLE_ENDED),
	m_scanStatus(IDLE),
	m_triggersToGo(0),
	m_singleShot(false),
	m_engBuffSizePoints(0),
	m_pointsLeftInTrigger(0),
	m_timerPeriod(0),
	m_swInputType(false),
	m_aiDiffMult(1),
	m_pointsThisRun(0),
	m_aiInterruptMode(0),
	m_polarity(POLARITY_BIPOLAR),
	m_maxAIDiffChl(0),	
	m_maxAISiglChl(0),
	m_supportsHwTrigger(false),
	m_aiFifo(0),
	m_deviceID(0),
	m_driverHandle(NULL),
	m_numGains(0),
	m_maxSampleRate(0),
	m_minSampleRate(0),
	m_supportsScanning(true),
	TimerObj(this)
{
	// Setup Advantech's ptFAICheck variables 
	m_ptFAICheck.ActiveBuf = &m_gwActiveBuf;
	m_ptFAICheck.stopped = &m_gwStopped;
	m_ptFAICheck.retrieved = &m_retrieved;	
	m_ptFAICheck.overrun = &m_gwOverrun;
	m_ptFAICheck.HalfReady = &m_gwHalfReady;
} // end of default constructor

/////////////////////////////////////////////////////////////////////////////
// ~CadvantechAin() 
//
// CadvantechAin destructor
///////////////////////////////////////////////////////////////////////////// 
CadvantechAin::~CadvantechAin()
{
	m_validRanges.clear();
	
	// Stop the device if it's running
	StopDeviceIfRunning();
	
	// Delete the buffers
	m_circBuff.Initialize(0, false, 0);
	
	// Close device handle if it's valid.	
	if (m_driverHandle != NULL)
		DRV_DeviceClose((LONG far *)&m_driverHandle);	
}

///////////////////////////////////////////////////////////////////////////////////
// Open()
//
// Description:
// Function is called by the OpenDevice(), which is in turn called by the engine.
// CadvantechAin::Open() function's main goals are ..
// 1)to initialize the hardware and hardware dependent properties..
// 2)to expose pointers to the engine and the adaptor to each other..
// 3)to process the device ID, which is input by a user in the ML command line.
// The call to this function goes through the hierarchical chain: ..
//..CadvantechAin::Open() -> CswClockedDevice::Open() -> CmwDevice::Open()
// CmwDevice::Open() in its turn populates the pointer to the..
//..engine (CmwDevice::_engine), which allows to access all engine interfaces.
////////////////////////////////////////////////////////////////////////////////////
HRESULT CadvantechAin::Open(IUnknown *Interface,long ID)
{
	if (ID<0) 
	{
		return E_INVALID_DEVICE_ID;
	}
	
	RETURN_HRESULT(TBaseObj::Open(Interface));
    EnableSwClocking(true);
	
	DEVLIST	deviceList[MaxDev];	// Structure containing list of installed boards (MaxDev is defined in driver.h)
	short numDevices;
	RETURN_ADVANTECH(DRV_DeviceGetList((DEVLIST far *)&deviceList[0], MaxDev, &numDevices));

	m_deviceID = static_cast<WORD>(ID);
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
	
	strcpy(m_DeviceName, deviceList[index].szDeviceName);
	
	// Open device and check that device number is valid
	RETURN_ADVANTECH(DRV_DeviceOpen(m_deviceID,(LONG far *)&m_driverHandle));
	// Send the driver handle to the circular buffer for DMA buffer allocation.
	m_circBuff.SetDriverHandle(m_driverHandle);
	
	PT_DeviceGetFeatures ptDevFeatures;
	ptDevFeatures.buffer = (LPDEVFEATURES)&m_DevFeatures;
	ptDevFeatures.size = sizeof(DEVFEATURES);
	RETURN_ADVANTECH(DRV_DeviceGetFeatures(m_driverHandle, (LPT_DeviceGetFeatures)&ptDevFeatures));
	PT_AIGetConfig ptAIGetConfig;
	ptAIGetConfig.buffer = (LPDEVCONFIG_AI)&m_DevConfigAI;
	ptAIGetConfig.size = sizeof(DEVCONFIG_AI);
	RETURN_ADVANTECH(DRV_AIGetConfig(m_driverHandle, (LPT_AIGetConfig)&ptAIGetConfig));	// Get pointer to DEVCONFIG_AI struct
	
	// Load all the needed information from the INI file.
	RETURN_HRESULT(LoadINIInfo());
	RETURN_HRESULT(SetDaqHwInfo());

	//////////////////////////////// Properties ///////////////////////////////////
	// The following Section sets the Propinfo for the Analog input device      //
	///////////////////////////////////////////////////////////////////////////////
	CComPtr<IProp> prop;
	
	// Channel Skew Property (NOT configurable, but changed in SampleRate method)
	// NOTE: Channel skew is set to 0 when there are less than 2 channels created as channel skew is defined 
	//       as the time between consecutively sampled channels.
	ATTACH_PROP(ChannelSkew);
	pChannelSkew->put_IsReadOnly(true);   // ChannelSkew is ReadOnly
	pChannelSkew.SetRange(1/(m_maxSampleRate),1/m_minSampleRate);
	pChannelSkew = 0;
	
	// Channel Skew Mode Property (NOT configurable, only equisample supported)
	ATTACH_PROP(ChannelSkewMode);
	// Ensure that EQUISAMPLE is the only enum'd value. Best to remove all and add only this.
	pChannelSkewMode->ClearEnumValues();
	pChannelSkewMode->AddMappedEnumValue(CHAN_SKEW_EQUISAMPLE, L"Equisample");
	pChannelSkewMode.SetDefaultValue(CHAN_SKEW_EQUISAMPLE);
	
	// Clock Source
	// ATTACH_PROP because sample rate and Channel Skew is affected.
	ATTACH_PROP(ClockSource);
	// Add the Clock Source enumerated values, and set the default
	pClockSource->ClearEnumValues();
	pClockSource->AddMappedEnumValue(CLCK_SOFTWARE, L"Software"); // Software is supported by all
	pClockSource->put_DefaultValue(CComVariant(CLCK_SOFTWARE));	
	pClockSource = CLCK_SOFTWARE;

	if (m_DevFeatures.dwPermutation[0] & DWP_EXTERNAL_AI) // Is external clocking supported?
	{														
		pClockSource->AddMappedEnumValue(CLCK_EXTERNAL, L"External");
	}
	if (m_DevFeatures.dwPermutation[0] & DWP_INTERNAL_AI)  // Is internal clocking supported?
	{														
		pClockSource->AddMappedEnumValue(CLCK_INTERNAL, L"Internal");	
		pClockSource->put_DefaultValue(CComVariant(CLCK_INTERNAL));		
		pClockSource = CLCK_INTERNAL;
	}
	
	// Input Type Property
	ATTACH_PROP(InputType);		
	pInputType->ClearEnumValues();
	pInputType->put_IsReadOnly(true);	 // As no devices software configurable.
	pInputType = GetInputTypeConfiguration();
	if (pInputType == IT_SINGLE_ENDED) 
	{
		pInputType->AddMappedEnumValue(IT_SINGLE_ENDED, L"SingleEnded");
		pInputType.SetDefaultValue(IT_SINGLE_ENDED);
	}
	else 
	{
		pInputType->AddMappedEnumValue(IT_DIFFERENTIAL, L"Differential");
		pInputType.SetDefaultValue(IT_DIFFERENTIAL);
	}
	
	// Sample Rate Property
	// Must change to software clocking (default rate 100) if the board doesn't have an onboard pacer clock.
	ATTACH_PROP(SampleRate);
	if (pClockSource == CLCK_INTERNAL)
	{
		pSampleRate.SetRange(m_minSampleRate,m_maxSampleRate); // default is internal hardware clocking
		pSampleRate.SetDefaultValue(1000); 
		pSampleRate = 1000;
	}
	else
	{
		pSampleRate.SetRange(MIN_SW_SAMPLERATE,MAX_SW_SAMPLERATE);
		pSampleRate.SetDefaultValue(100); 
		pSampleRate = 100;
	}
	
	// Samples Per Trigger Property - set limits
	// Change the Samples Per Trigger Default value to equal the default sample rate
	ATTACH_PROP(SamplesPerTrigger);
	pSamplesPerTrigger.SetDefaultValue(pSampleRate);
	pSamplesPerTrigger = pSampleRate;
	
	// Trigger properties for hardware triggers:
	ATTACH_PROP(TriggerType);						
	// Trigger Condition Property: Do not add rising/falling just yet!
	ATTACH_PROP(TriggerCondition);
	
	// Trigger Condition Value Property: Not sure we need this!
	ATTACH_PROP(TriggerConditionValue);
	// SetDefaultTriggerConditionValues();
	
	// Trigger Delay Property: Attach to (re)set defaults
	ATTACH_PROP(TriggerDelay);
	
	// Only the PCI-1712 can support hwdigital triggers.
	// We read the capability from an INI file setting in LoadINIInfo
	if(m_supportsHwTrigger)	
	{					
		pTriggerType->AddMappedEnumValue(TRIGGER_HWDIGITAL, L"HwDigital");
		pTriggerType->AddMappedEnumValue(TRIGGER_HWANALOG, L"HwAnalog");
	}	
	
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
		// Test m_aiInterruptMode (obtained from INI file) to find Interrupt TransferModes supported:
		// 1 => Only Interrupt Per Point supported
		// 2 => Only Interrupt Per Block supported
		// 3 => Both Interrupt Per Point and Interrupt Per Block supported
		
		if (SUPPORTS_IPB)
		{
			pTransferMode->AddMappedEnumValue(TRANSFER_INTERRUPT_PB, L"InterruptPerBlock");
			pTransferMode.SetDefaultValue(TRANSFER_INTERRUPT_PB);	
			pTransferMode = TRANSFER_INTERRUPT_PB;
		}
		if (SUPPORTS_IPP)	// Is Interrupt Per Point available?
		{
			pTransferMode->AddMappedEnumValue(TRANSFER_INTERRUPT_PP, L"InterruptPerPoint");
			pTransferMode.SetDefaultValue(TRANSFER_INTERRUPT_PP);	
			pTransferMode = TRANSFER_INTERRUPT_PP;
		}
		// Does it support DMA (start DMA boards with the DRV_FAIDMAScanStart() or DRV_FAIDMAExStart()
		if ((m_DevFeatures.dwPermutation[0] & DWP_DMA_AI) || m_supportsHwTrigger)	
		{
			pTransferMode->AddMappedEnumValue(TRANSFER_DMA, L"DMA");
			pTransferMode.SetDefaultValue(TRANSFER_DMA);
			pTransferMode = TRANSFER_DMA; 
		}
	}
	
	///////////////// Attached for convenience //////////////////
	// Total points to acquire
	ATTACH_PROP(TotalPointsToAcquire);
    
	// TriggerRepeat
	ATTACH_PROP(TriggerRepeat);
	
	// ManualTriggerHwOn required for manual triggering.
	ATTACH_PROP(ManualTriggerHwOn);

	/////////////////////////////////////////////////////////////////////////////////////////////////
	// Channel Properties																		   //
	/////////////////////////////////////////////////////////////////////////////////////////////////	
	CRemoteProp rp;
	// The HwChannel Property
	CComVariant maxchanrange;
	if (pInputType == IT_SINGLE_ENDED)		// Check if single-ended inputs supported
	{
		maxchanrange = m_maxAISiglChl-1;	// If they are then use that value as default value
	}
	else
	{
		maxchanrange = m_maxAIDiffChl-1;	// If only differential inputs supported...
	}
    rp.Attach(_EngineChannelList,L"HwChannel",HWCHANNEL);
    rp.SetRange(0L, maxchanrange);
    rp.Release();
	
	// The Input Range Property
	// Default to maximum possible range, which is the first range in our m_rangeInfo table.
	double InputRange[2];
	CComVariant var;
	MaxInputRange(m_polarity, &InputRange[0], &InputRange[1]);
	CreateSafeVector(InputRange,2,&var);
    rp.Attach(_EngineChannelList,L"inputrange",INPUTRANGE);
    rp->put_DefaultValue(var);
    rp.SetRange(InputRange[0],InputRange[1]);
    rp.Release();

	// Make sure the Units range is the same 
	rp.Attach(_EngineChannelList,L"unitsrange");
    rp->put_DefaultValue(var);

	// Make sure the Sensor range is the same 
    rp.Attach(_EngineChannelList,L"sensorrange");
    rp->put_DefaultValue(var);

	// ConversionOffset changes depending on the Number of bits. The engine doesnt automatically change the 
	// conversion offset, so it MUST be set here
	rp.Attach(_EngineChannelList,L"conversionoffset");
    rp->put_DefaultValue(CComVariant(1<<(m_DevFeatures.usNumADBit-1)));	// Note that the conversion offset uses the resolution of the device
    rp.Release();								
	
	// NOTE: We don't need to change native scaling or offset values. Advantech devices always return 
	//		 unsigned 12 bit samples. Thus only VT_UI2 datatype used in conjunction with the conversion offset 
	//		 when bipolar inputs are used.
	
    return S_OK;
} // end of Open()


////////////////////////////////////////////////////////////////////////////////////
// GetSingleValue()
//
// This function gets one single data point form one A/D channel, specified..
//..as a parameter.
// Function is called by GetSingleValues() of the TADDevice class, which..
// ..in turn is called by the engine as a responce to the ML user command GETSAMPLE.
// Function MUST BE MODIFIED by the adaptor programmer.
////////////////////////////////////////////////////////////////////////////////////
HRESULT CadvantechAin::GetSingleValue(int chan,RawDataType *value)
{
	// Set up channel:
	int	advantechChan = _chanList[chan];	// Convert to actual hardware channel number
	if (pInputType == IT_DIFFERENTIAL)		// Scaling for boards with non-consecutive DI channels
		advantechChan = _chanList[chan]*m_aiDiffMult; 

	// Channel input range configuation set up in UpdateChans()
	
	// Now read data
	PT_AIBinaryIn ptAIBinaryIn;
	ptAIBinaryIn.chan = advantechChan;	// Select channel
	ptAIBinaryIn.TrigMode = 0;			// Select software clock source
	ptAIBinaryIn.reading = (USHORT far*)&*value;
	RETURN_ADVANTECH(DRV_AIBinaryIn(m_driverHandle, (LPT_AIBinaryIn)&ptAIBinaryIn));
	
	return S_OK;
} // end of GetSingleValue()


////////////////////////////////////////////////////////////////////////////////////
// InterfaceSupportsErrorInfo()
//
// Function indicates whether or not an interface supports the IErrorInfo..
//..interface. It is created by the wizard.
// Function is NOT MODIFIED by the adaptor programmer.
////////////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CadvantechAin::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IadvantechAin
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
} // end of InterfaceSupportsErrorInfo()

////////////////////////////////////////////////////////////////////////////////////
// SetDaqHwInfo()
//
// Description:
// Sets the fields needed for DaqHwInfo. Is used when you call 
// daqhwinfo(analoginput('advantech')) and in the Open() method
////////////////////////////////////////////////////////////////////////////////////
HRESULT CadvantechAin::SetDaqHwInfo()
{
	// Adaptor Name
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"adaptorname"), CComVariant(Cadvantechadapt::ConstructorName)));
	
	// Number of bits
	unsigned short bits = m_DevFeatures.usNumADBit; // Get the number of bits
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"bits"), CComVariant(bits)));
	
	// Coupling
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"coupling"), CComVariant(L"DC Coupled")));
	
	// Device Name - The device name is made up of three things:
	char tempstr[15] = "";
	sprintf(tempstr, " (Device %d)", m_deviceID); 
	strcat(m_DeviceName, tempstr);					
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"devicename"), CComVariant(m_DeviceName)));
	
	// Single ended/Differential IDs
	// Only the current configuration set in the Advantech Utility is returned
	m_maxAIDiffChl = m_DevFeatures.usMaxAIDiffChl;	
	m_maxAISiglChl = m_DevFeatures.usMaxAISiglChl;
	ITInputType inputType = GetInputTypeConfiguration();
	
	// Now find out which configuration the device is currently supporting
	if (inputType == IT_SINGLE_ENDED)	
	{
		// Single ended IDs 
		CComVariant vSingIds;	// same as the differential ids
		CreateSafeVector((short*)NULL, (m_maxAISiglChl), &vSingIds);
		TSafeArrayAccess<short> singIds(&vSingIds);
		for (int i=0; i< (m_maxAISiglChl); i++)
		{
			singIds[i]=i;
		}
		RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"singleendedids"), vSingIds));
	}
	if (inputType == IT_DIFFERENTIAL)
	{
		// Differential IDs 
		CComVariant vIds;	// Set up a variant to store the values in.
		CreateSafeVector((short*)NULL, (m_maxAIDiffChl) ,&vIds);	// Create a SafeVector
		TSafeArrayAccess<short> difIds(&vIds);		
		for (int i=0; i < (m_maxAIDiffChl); i++)	// loop through and create the values
		{
			difIds[i]=i;
		}
		RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"differentialids"),vIds));
	}
	if (inputType == IT_ERROR)
	{
		return E_IT_SNGLDIFF;
	}
	
	// Device ID
	wchar_t idStr2[10];
	swprintf(idStr2, L"%d", m_deviceID );	// Convert the Device id to a string
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"id"), CComVariant(idStr2)));
	
	// Gains and Input Ranges below 
	CComVariant val;
    
    if (m_DevFeatures.usNumGain != 0)
	{
		m_numGains = m_DevFeatures.usNumGain;
	}
    else
	{
		return E_DEMOBOARD; // Demo board lists no gains!
	}
	
	// All devices support bipolar ranges. Check the range info for Unipolar support
	bool supportsUnipolar;	
	LoadRangeInfo(&supportsUnipolar);
	
	//Input Ranges		
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
	//  [0   .5]2
	SAFEARRAYBOUND rgsabound[2];  // the number of dimensions
	rgsabound[0].lLbound = 0;
	rgsabound[0].cElements = m_numGains; // bipolar and unipolar - size of dimension 1
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
	RangeList_t::iterator rIt;
	double *min, *max; // Pointers to the input range columns, 
	min = inRange;
	max = inRange+m_numGains;
	// Iterate through the validRanges, and transfer the Input Ranges.
	for(rIt = m_validRanges.begin(); rIt != m_validRanges.end(); rIt++)
	{
		*min++ = (*rIt).minVal;
		*max++ = (*rIt).maxVal;
	}
	
	SafeArrayUnaccessData (ps);
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"inputranges"), var));
	
	// Gains
	int j;
	double uniqueGains[32];
	int numUniqueGains = 0;
	bool isUnique = true;
	
	// Iterate through the m_validRanges and find all the gains (some values are repeated)
	if (lstrcmp(m_DeviceName, "Advantech DEMO"))
	{
		isUnique = true;
		for (RangeList_t::iterator rIt = m_validRanges.begin(); rIt != m_validRanges.end(); rIt++)
		{
			for (j = 0; j < numUniqueGains; j++)
			{
				if ((double)(*rIt).gain == uniqueGains[j])
					isUnique = false;
			}
			if (isUnique)
			{
				uniqueGains[numUniqueGains] = (double)(*rIt).gain;
				numUniqueGains++;
			}
		}
	}
	else
	{
		return E_DEMOBOARD;
	}
	
	SAFEARRAY * psArr = SafeArrayCreateVector(VT_R8, 0, numUniqueGains);
	if (psArr==NULL)												
	{
		return E_FAIL;
	}
	val.parray=psArr;
	val.vt = VT_ARRAY | VT_R8;
	double *Gains;	// Create a pointer to the list of gains		
	hr = SafeArrayAccessData(psArr, (void **) &Gains);	// Set the SafeArray Data to the 
	if (FAILED(hr))										// pointer for the gains
	{
		SafeArrayDestroy(psArr);
		return E_FAIL;
	}
	for (int i =0; i<numUniqueGains; i++)
	{
		Gains[i] = uniqueGains[i];
	}
	SafeArrayUnaccessData(psArr);
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"gains"), val));
	
	// Polarity
	// Assumption: Bipolar supported by all devices.
	if (supportsUnipolar)	// Supports both unipolar and bipolar ranges
	{
		SAFEARRAY *ps = SafeArrayCreateVector(VT_BSTR, 0, 2); // Create the array for our strings
        if (ps==NULL) 
		{
			return E_FAIL;
		}
        val.Clear();	// Clear the variant
        // set the data type and values
        V_VT(&val) = VT_ARRAY | VT_BSTR;
        V_ARRAY(&val) = ps;
        CComBSTR *polarities;		// create the pointer to the data string
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
	else	// Only supports bipolar inputs
	{
		RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"polarity"), CComVariant(L"Bipolar")));
	}
	
	// Sample Rate Limits (max read from INI file)
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"maxsamplerate"), CComVariant(m_maxSampleRate)));
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"minsamplerate"), CComVariant(m_minSampleRate)));
	
	// Native Data Type: A 16-bit Unsigned Integer
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"nativedatatype"), CComVariant(VT_UI2)));
	
	// Sample Type - This value is hardcoded
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"sampletype"),CComVariant(0)));
	
	// Total number of channels
	if (m_maxAISiglChl > 0)
	{
		RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"totalchannels"),CComVariant(m_maxAISiglChl)));
	}
	else
	{ 
		RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"totalchannels"),CComVariant(m_maxAIDiffChl)));
	}
	
	// Vendor Driver Description
	char vendorDriverDescription[30];
	strcpy(vendorDriverDescription, m_DevFeatures.szDriverName);
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"vendordriverdescription"),CComVariant(vendorDriverDescription)));
	
	// Vendor Driver Version
	char vendorDriverVersion[30]; 
	strcpy(vendorDriverVersion, m_DevFeatures.szDriverVer);
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"vendordriverversion"),CComVariant(vendorDriverVersion)));

	return S_OK;
} // end of SetDaqHwInfo()

////////////////////////////////////////////////////////////////////////////////////
// SetProperty()
// Called by the engine when a property is set
// An interface to the property along with the new value is passed to the method
////////////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CadvantechAin::SetProperty(long User, VARIANT *NewValue)
{
	if (User)
	{
		CLocalProp* pProp=PROP_FROMUSER(User);
		variant_t *val = (variant_t*)NewValue;  // variant_t is a more friendly data type to work with.
		
		// Sample Rate
		if (User == USER_VAL(pSampleRate))
		{
			// Check validity of new user entered sample rate
			if (pClockSource == CLCK_SOFTWARE)	
			{
				return CswClockedDevice::SetProperty(User, NewValue);
			}
													  
			if (pClockSource == CLCK_INTERNAL)
			{
				// Quantise the given sample rate
				double newrate = *val;	
				pSampleRate = QuantiseValue(newrate);						 
				ValidateNewRate(pSampleRate, m_maxSampleRate);
				UpdateRateandSkew();
				*val = pSampleRate;	
			}
			// To avoid excessive interrupt generation, change between IPP and IPB if the sample rate
			// exceeds a given threshold
			CheckTransferMode(true);
		}
		
		// Clock Source Property: affects SampleRate and ChannelSkew and TransferMode
		if (User == USER_VAL(pClockSource))
		{
			pClockSource = *val;
			UpdateRateandSkew();
			// TransferMode changes when we change Clock Source.
			pTransferMode->ClearEnumValues();
			if (pClockSource == CLCK_SOFTWARE)
			{	
				pTransferMode->AddMappedEnumValue(TRANSFER_SOFTWARE, L"Software");
				pTransferMode.SetDefaultValue(TRANSFER_SOFTWARE);
				pTransferMode = TRANSFER_SOFTWARE; 
				pSampleRate = RoundRate(pSampleRate );
				// Remove HwDigital and HwAnalog sources
				if((pTriggerType == TRIGGER_HWDIGITAL) || (pTriggerType == TRIGGER_HWANALOG))
					_engine->WarningMessage(CComBSTR("Advantech: Hardware Triggers are not supported in Software Clocked mode.\nDigital trigger will be removed."));
				pTriggerType = TRIGGER_IMMEDIATE;
				pTriggerType->RemoveEnumValue(CComVariant(TRIGGER_HWDIGITAL));
				pTriggerType->RemoveEnumValue(CComVariant(TRIGGER_HWANALOG));
			}
			else 
			{	
				if (SUPPORTS_IPB)
				{
					pTransferMode->AddMappedEnumValue(TRANSFER_INTERRUPT_PB, L"InterruptPerBlock");
					pTransferMode.SetDefaultValue(TRANSFER_INTERRUPT_PB);	
					pTransferMode = TRANSFER_INTERRUPT_PB;
				}
				if (SUPPORTS_IPP)
				{
					pTransferMode->AddMappedEnumValue(TRANSFER_INTERRUPT_PP, L"InterruptPerPoint");
					pTransferMode.SetDefaultValue(TRANSFER_INTERRUPT_PP);	
					pTransferMode = TRANSFER_INTERRUPT_PP;
				}
				// To avoid excessive interrupt generation, change between IPP and IPB if the sample rate
				// exceeds a given threshold
				CheckTransferMode(false);
				if ((m_DevFeatures.dwPermutation[0] & DWP_DMA_AI) || 
					m_supportsHwTrigger)	
				{
					pTransferMode->AddMappedEnumValue(TRANSFER_DMA, L"DMA");
					pTransferMode.SetDefaultValue(TRANSFER_DMA);
					pTransferMode = TRANSFER_DMA; 
				}
				// Put back the hardware triggers if supported
				if (m_supportsHwTrigger)	
				{					
					pTriggerType->AddMappedEnumValue(TRIGGER_HWDIGITAL, L"HwDigital");
					pTriggerType->AddMappedEnumValue(TRIGGER_HWANALOG, L"HwAnalog");
				}
			}
		}	
		
		// SamplesPerTrigger: Just check the TransferMode
		if (User == USER_VAL(pSamplesPerTrigger))
		{
			pSamplesPerTrigger = *val;
			// To avoid excessive interrupt generation, change between IPP and IPB if the sample rate
			// exceeds a given threshold
			CheckTransferMode(true);
		}
		
		// TriggerType: If changed, we need to reconfigure a whole range of things
		if (User==USER_VAL(pTriggerType))
		{
			// Has Trigger Type been changed to HwDigital? If so, change the Trigger Delay accordingly.
			if ((long)(*val)==TRIGGER_HWDIGITAL)
			{
				pTriggerCondition->ClearEnumValues();
				pTriggerCondition->AddMappedEnumValue(TRIG_COND_RISING, L"Rising");
				pTriggerCondition->AddMappedEnumValue(TRIG_COND_FALLING, L"Falling");
				
				pTriggerCondition.SetDefaultValue(TRIG_COND_RISING);
				pTriggerCondition.SetRemote(TRIG_COND_RISING);
				
								/* 
				if (pTriggerRepeat > 0)
				{
					_engine->WarningMessage(CComBSTR("Advantech: Trigger Repeat is not supported by Hardware Triggers.\n Device will Trigger Once."));
					pTriggerRepeat = 0;
				}
				pTriggerRepeat.SetRange(CComVariant(0), CComVariant(0));
				*/

				// Force the TriggerDelay to 0
				pTriggerDelay.SetDefaultValue(0.0);
				pTriggerDelay.SetRemote(0.0);
				pTriggerDelay = 0.0;
				pTriggerDelay.SetRange(CComVariant(0),CComVariant(0));
				
				// Force the TriggerConditionValue to read only
				SetDefaultTriggerConditionValues(0, 0);
				pTriggerConditionValue->put_IsReadOnly(true);
			} 
			else if ((long)(*val)==TRIGGER_HWANALOG)
			{
				pTriggerCondition->ClearEnumValues();
				pTriggerCondition->AddMappedEnumValue(TRIG_COND_ABOVE, L"Above");
				pTriggerCondition->AddMappedEnumValue(TRIG_COND_BELOW, L"Below");
				
				pTriggerCondition.SetDefaultValue(TRIG_COND_ABOVE);
				pTriggerCondition.SetRemote(TRIG_COND_ABOVE);
				
								/*
				if (pTriggerRepeat > 0)
				{
					_engine->WarningMessage(CComBSTR("Advantech: Trigger Repeat is not supported by Hardware Triggers.\n Device will Trigger Once."));
					pTriggerRepeat = 0;
				}
				pTriggerRepeat.SetRange(CComVariant(0), CComVariant(0));
				*/

				// Force the TriggerDelay to 0
				pTriggerDelay.SetDefaultValue(0.0);
				pTriggerDelay.SetRemote(0.0);
				pTriggerDelay = 0.0;
				pTriggerDelay.SetRange(CComVariant(0),CComVariant(0));

				// Force the TriggerConditionValue to read only
				pTriggerConditionValue->put_IsReadOnly(false);
				SetDefaultTriggerConditionValues(-10, 10);
			} 
			else
			{
				//////////////////////////////////////////////////////////
				// NOTE - Using the same values as other adaptors       //
				//////////////////////////////////////////////////////////	
				double _mintriggerdelay = -2147483;
				double _maxtriggerdelay = 2147483;
				double _defaulttriggerdelay = 0;
				pTriggerDelay.SetRange(_mintriggerdelay,_maxtriggerdelay);
				pTriggerDelay.SetDefaultValue(_defaulttriggerdelay);
				pTriggerCondition->ClearEnumValues();
				pTriggerCondition->AddMappedEnumValue(TRIG_COND_NONE, L"None");
				pTriggerCondition.SetDefaultValue(TRIG_COND_NONE);
				pTriggerConditionValue->put_IsReadOnly(false);
			}
		}
		
		// Trigger Delay property
		if (User==USER_VAL(pTriggerDelay))
		{
			long temp = *val;
			if(pTriggerType == TRIGGER_HWDIGITAL)
			{
				if (temp != 0)
				{
					_engine->WarningMessage(CComBSTR("Advantech: Non-zero trigger delay is invalid for Digital Triggers."));
					temp = static_cast<long>(pTriggerDelay);
				}
				*val = pTriggerDelay;
			}
		}
		if (User==USER_VAL(pTransferMode))
		{
			if ((long)(*val)==TRANSFER_INTERRUPT_PP)
			{
				_engine->WarningMessage(CComBSTR("Advantech: Interrupt Per Point transfer mode is not recommended for sample rates above 20kHz."));
			}
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
STDMETHODIMP CadvantechAin::SetChannelProperty(long UserVal, tagNESTABLEPROP *pChan, VARIANT *NewValue)
{
	int Index = pChan->Index-1;  // we use 0 based index
	variant_t& vtNewValue = reinterpret_cast<variant_t&>(*NewValue);
	if(UserVal == INPUTRANGE)
	{
		TSafeArrayAccess<double> NewRange(NewValue);
		RANGE_INFO *NewInfo; 
		RETURN_HRESULT(FindRange(static_cast<float>(NewRange[0]), 
		                         static_cast<float>(NewRange[1]), NewInfo));
		
		// Check the polarity: If changed, set ALL to new polarity
		PolarityType l_polarity = (NewInfo->minVal < 0) ? POLARITY_BIPOLAR : POLARITY_UNIPOLAR;
		if (l_polarity != m_polarity)
		{
			if (_nChannels>1)
				_engine->WarningMessage(CComBSTR("ADVANTECH: All channels will be configured to have the same polarity."));
			SetAllPolarities(l_polarity);
		}
		// 
		NewRange[0] = (float) NewInfo->minVal;
		NewRange[1] = (float) NewInfo->maxVal;
	}
	_updateChildren = true;
	
	return S_OK;
} // end of SetChannelProperty()


////////////////////////////////////////////////////////////////////////////////////
// LoadINIInfo()
// The following values are obtained from the INI file:
//			- Size of AI FIFO buffer.
//			- AI Maximum sample rate.
//			- Multiplier for Differential InputType channel mapping.
//			- The available interrupt transfer modes available.
//			- AO Maximum Sample Rate.
//			- Whether the input type is software configurable
//			- Whether the polarity is software configurable
////////////////////////////////////////////////////////////////////////////////////
HRESULT CadvantechAin::LoadINIInfo()
{
	char fname[512];
    
    // INI file must be in the same directory as the application.
    if (GetModuleFileName(_Module.GetModuleInstance(), fname, 512)==0)
        return E_FAIL;
    
    // replace .dll with .ini
    strrchr(fname, '.' )[1]='\0';
    strcat(fname,"ini"); 
	// create a key to search on - The Device Name.
	char *ch = strchr(m_DeviceName,' ');
	int spaceAddress = ch - m_DeviceName + 1;
	StrCpyN(m_DeviceName, m_DeviceName, spaceAddress);
	
	m_maxSampleRate = GetPrivateProfileDouble(m_DeviceName, "AIMaxSR", 0, fname);
	m_minSampleRate = GetPrivateProfileDouble(m_DeviceName, "AIMinSR", 0, fname);	
	m_aiFifo = GetPrivateProfileInt(m_DeviceName, "AIFifo", 0, fname);
	m_swInputType = GetPrivateProfileBool(m_DeviceName, "SWInputType", false, fname);	
	m_aiInterruptMode = GetPrivateProfileInt(m_DeviceName, "AIInterruptMode", 0, fname);
	m_aiDiffMult = GetPrivateProfileInt(m_DeviceName, "AIDiffMult", 0, fname);
	m_supportsHwTrigger = GetPrivateProfileBool(m_DeviceName, "AIHwTrigger", false, fname);
	m_swPolarityConfig = GetPrivateProfileBool(m_DeviceName, "SWPolarityConfig", true, fname);

	// The PCL-812PG does not support multiple channels
	if ((!lstrcmp(m_DeviceName, "PCL-812PG")) || (!lstrcmp(m_DeviceName, "PCL-812")))
	{
		m_supportsScanning = false; 
	}
	
	return S_OK;
} //end of LoadINIInfo()


////////////////////////////////////////////////////////////////////////////////////
// GetFreqArea()
// Queries registry for current frequency measurement area 
// - applicable to PCI-1712 series only
////////////////////////////////////////////////////////////////////////////////////
int CadvantechAin::GetFreqArea()
{
	// Get the input type from the registry using the following path:
	// HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\<drivername>s\device<ID=%03d>\ChanConfig
	// Recent Advantech devices use ADS****s as the registry key name
	// or:
	// HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\ADSIO\device<ID=%03d>\ChanConfig
	// Older Advantech devices use ADSIO (and not the driver name) as the registry key name.

	DWORD freqArea;
	HKEY hMainKey = HKEY_LOCAL_MACHINE;
	char deviceKey[10];
	int res = sprintf(deviceKey, "device%03d", m_deviceID);
	HKEY hSubKey;

	char driverName[30];
	int drvNameLen = strlen(m_DevFeatures.szDriverName);
	strncpy(driverName, m_DevFeatures.szDriverName, drvNameLen-4);
	// Append the zero
	driverName[drvNameLen-4]=0;
	strcat(driverName,"s");	// Append "s"

	if (::RegOpenKey(hMainKey, "SYSTEM", &hSubKey) == ERROR_SUCCESS)
	{
		HKEY hSubKey1;
		if (::RegOpenKey(hSubKey, "CurrentControlSet", &hSubKey1) == ERROR_SUCCESS)
		{
			HKEY hSubKey2;
			if (::RegOpenKey(hSubKey1, "Services", &hSubKey2) == ERROR_SUCCESS)
			{
				HKEY hSubKey3;
				if ((::RegOpenKey(hSubKey2, driverName, &hSubKey3) == ERROR_SUCCESS) || 
					(::RegOpenKey(hSubKey2, "ADSIO", &hSubKey3) == ERROR_SUCCESS))	// Case sensitive? No.
				{
					HKEY hSubKey4;
					if (::RegOpenKeyEx(hSubKey3, deviceKey, 0, KEY_QUERY_VALUE, &hSubKey4) == ERROR_SUCCESS)
					{
						DWORD freqAreaSize = sizeof(DWORD);
						DWORD Type;

						HRESULT HValRes = RegQueryValueEx(hSubKey4, "FreqArea", NULL, &Type, 
							(UCHAR *) &freqArea, &freqAreaSize);
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
	return freqArea;
}


////////////////////////////////////////////////////////////////////////////////////
// UpdateChans()
//		
// Description:
// This function is overloaded. It updates the local channel list and channel
// range variables with the current values.
////////////////////////////////////////////////////////////////////////////////////
HRESULT CadvantechAin::UpdateChans(bool ForStart)
{
	_chanList.resize(_nChannels);
	m_chanGainCode.resize (_nChannels); 
	
	AICHANNEL *aichan=NULL;
	
	for (int i=0; i < _nChannels; i++) 
	{    
		_EngineChannelList->GetChannelStructLocal(i, (NESTABLEPROP**)&aichan);
		_chanList[i] = aichan->Nestable.HwChan;
		RANGE_INFO *NewInfo;
		RETURN_HRESULT(FindRange(static_cast<float>(aichan->VoltRange[0]),
		                         static_cast<float>(aichan->VoltRange[1]), NewInfo));
		// Update channel gain code list
		m_chanGainCode[i] = NewInfo->gainCode; 

		// Update the device channels input ranges
		// Placed here so that this does not have to be repeated during software clocked
		// acquistion
		PT_AIConfig ptAIConfig;
		ptAIConfig.DasGain = m_chanGainCode[i];
 		ptAIConfig.DasChan = static_cast<USHORT>(aichan->Nestable.HwChan);
		RETURN_ADVANTECH(DRV_AIConfig(m_driverHandle, (LPT_AIConfig)&ptAIConfig));
	}
	_updateChildren = false; // Avoid calling this function too often.
    return S_OK;             
} // end of UpdateChans()

///////////////////////////////////////////////////////////////////////////////////////
// ChildChange()
// This function is overloaded. Called when channels are added, removed or reordered
///////////////////////////////////////////////////////////////////////////////////////
STDMETHODIMP CadvantechAin::ChildChange(DWORD typeofchange, NESTABLEPROP *pChan)
{
	long numChans; 
    HRESULT hRes = _EngineChannelList->GetNumberOfChannels(&numChans);

	// Do we have a channel to work with?
	if (pChan)	
	{
		if ((typeofchange & CHILDCHANGE_REASON_MASK) == ADD_CHILD) 	// Note bit wise comparison
		{
			// Channels must be consecutive (ascending) and not repeated
			// The following is implemented:
			//       If I'm the first channel, just add me to the list
			//       If I'm not the first channel, I must be one more than the last.

			// NOTE: This is not actually necessary for software clocking, but if the user changes from software
			// to Internal, then if we have not ensured that the channels are added in ascending order, we will have
			// to remove all the channels added so far and start all over again

			if (numChans >= 2)
			{
				// Boards that do not support scanning will error on start()
				/*if (!m_supportsScanning)
				{
					//error
					return E_CHANNUM;
				}*/

				// Get the HWID of the last channel in the list.
				NESTABLEPROP *lastChan;
				_EngineChannelList->GetChannelStructLocal(numChans-2, &lastChan);
				if (pChan->HwChan != lastChan->HwChan + 1)	// Only consecutive channels allowed
				{
					return E_CHANORDER;
				}
			}			
		}
		
		if ((typeofchange & CHILDCHANGE_REASON_MASK)== DELETE_CHILD)
		{
			// Channels can only be deleted from the ends of the channels list in consecutive order
			if (numChans > 2)	// If there are only two channels, either can be deleted, so no need to check.
			{
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
	if (typeofchange & END_CHANGE)
	{
		_nChannels = numChans;
		UpdateChans(true);
		UpdateRateandSkew();
		// To avoid excessive interrupt generation, change between IPP and IPB if the sample rate
		// exceeds a given threshold
		CheckTransferMode(true);				
	}		
	return S_OK;
} // end of ChildChange()


//////////////////////////////////////////////////////////////////////////////////////////
// FindRange()
// This function checks to see if the range passed to it is valid according to what
// the card supports. It returns either the selected range or the closest (larger) range.
//////////////////////////////////////////////////////////////////////////////////////////
HRESULT CadvantechAin::FindRange(float low, float high, RANGE_INFO *&pRange)
{
	if (low > high)
	{
        return E_INPRANGE;
	}
    if (low == high)
	{
        return E_INPRANGE;
	}

	pRange = NULL;
	// Don't keep track of the current best fit range because the input range list is sorted. 
	// Iterrate through input range list to find the closest values
    for (RangeList_t::iterator it = m_validRanges.begin(); it != m_validRanges.end(); it++)
    {
		if (((*it).minVal <= low*0.9999) && ((*it).maxVal >= high*0.9999))
		{
			pRange=&(*it);
		}
    }
    if (!pRange)
	{
		return E_INPUNKNOWN;
	}
	else
	{
		return S_OK;
	}
} // end of FindRange()


//////////////////////////////////////////////////////////////////////////////////////////
// LoadRangeInfo()
//  This routine is used to load the m_validRanges variable with the input  
//  range values from the Advantech device. It also calculates the gain for the specific 
//  input range.
//////////////////////////////////////////////////////////////////////////////////////////
HRESULT CadvantechAin::LoadRangeInfo(bool* supportsUnipolar)	
{
    std::vector<short> ranges;
	RANGE_INFO NewInfo;
	
	USHORT		gainCdeTemp[32];
	FLOAT		inRangeTemp[32];
	double		bipolarBaseVolts = 0;
	double		unipolarBaseVolts = 0;

	//GAINLIST
	*supportsUnipolar = false;

	// Find m_polarity from the registry
	GetPolarityConfiguration();
	int numBipolarGains = 0;
	int numUnipolarGains = 0;
	
    //if (m_numGains > 1)
	if (lstrcmp(m_DeviceName, "Advantech DEMO"))
	{
		// This loop finds the base voltages and polarities which the device supports.
		// Base voltages are necessary to calculate the gains.
		for (int i = 0; i < m_numGains; i++) 
		{									
			inRangeTemp[i] = m_DevFeatures.glGainList[i].fMinGainVal;
			inRangeTemp[m_numGains + i] = m_DevFeatures.glGainList[i].fMaxGainVal;
			gainCdeTemp[i] = m_DevFeatures.glGainList[i].usGainCde; 
			if (gainCdeTemp[i] == USHORT(0)) // We assume that gain code 0 ALWAYS corresponds to bipolar base voltage
			{														
				bipolarBaseVolts = inRangeTemp[i+m_numGains] - inRangeTemp[i];				
			}
			if (gainCdeTemp[i] == USHORT(16)) // We assume that gain code 16 SOMETIMES! corresponds to unipolar base voltage
			{								  
				unipolarBaseVolts = inRangeTemp[i+m_numGains] - inRangeTemp[i]; 
				// All devices support bipolar inputs, so only necessary to test for unipolar inputs
				*supportsUnipolar = true;				
			}
			if (inRangeTemp[i] < 0)		
			{
				numBipolarGains++;
			}
		}

		numUnipolarGains = m_numGains - numBipolarGains;

		// Need to sort the input ranges into descending order of range, 1st bipolar then unipolar.
		float curMinValue = 1000; // Initialise the minimum value of next range to be added to m_validRanges
		float curMaxRange = -1000; // Initialise the range value of next range to be added to m_validRanges
		int curInd = 0; // Index into inRangeTemp of current range to be added to m_validRanges 

		for (i = 0; i < m_numGains; i++)
		{
			for (int m = 0; m < m_numGains; m++)
			{
				if ((inRangeTemp[m] < curMinValue) || ((inRangeTemp[m] < curMinValue) && 
					((inRangeTemp[m + m_numGains] - inRangeTemp[m]) >= curMaxRange)))
				{
					curInd = m;
					curMinValue = inRangeTemp[m];
					curMaxRange = inRangeTemp[m + m_numGains] - inRangeTemp[m];
				}
			}

			// If the device's polarity is jumper configured, then only add the range if it 
			// matches the current polarity setting
			if (((m_polarity == POLARITY_BIPOLAR) && (inRangeTemp[curInd] < 0)) || ((m_polarity == POLARITY_UNIPOLAR) && (inRangeTemp[curInd] == 0)) || m_swPolarityConfig)
			{				
				NewInfo.minVal = inRangeTemp[curInd];
				NewInfo.maxVal = inRangeTemp[m_numGains + curInd];
				NewInfo.gainCode = gainCdeTemp[curInd];
				NewInfo.gain = static_cast<float>((double)bipolarBaseVolts/(inRangeTemp[curInd + m_numGains] - inRangeTemp[curInd]));
				m_validRanges.push_back(NewInfo);
			}

			inRangeTemp[curInd] = 1000;
			inRangeTemp[curInd + m_numGains] = 1000;//-1000;

			curMinValue = 1000; // Reset for next iteration
			curMaxRange = -1000; // Reset for next iteration
		}
	}
    else
	{
		return E_DEMOBOARD;
	}
	
	if (!m_swPolarityConfig)
	{		
		// If this device is jumpered then set m_numGains to the total number gains 
		// to be displayed for the current polarity setting - this affects SetDaqHWInfo().
		m_numGains = (m_polarity == POLARITY_BIPOLAR) ? numBipolarGains : numUnipolarGains;
	}

	return S_OK;
} // end of LoadRangeInfo()


//////////////////////////////////////////////////////////////////////////////////////////
// MaxInputRange(polarity, lowRange, highRange)
// Returns the Maximum Input ranges for the card given the current polarity
//////////////////////////////////////////////////////////////////////////////////////////
void CadvantechAin::MaxInputRange(PolarityType polarity, double *lowRange, double *highRange)
{
	// Some values in case the list is broken:
	*lowRange = 0;
	*highRange = 0;
	if (polarity==POLARITY_BIPOLAR)
	{
		// The largest input range for bipolar is ALWAYS the first element in our
		// Range table
		*lowRange = m_validRanges[0].minVal;
		*highRange = m_validRanges[0].maxVal;
	}
	else
	{
		// The largest unipolar input range is the first input range with 0 minVal:
		for (RangeList_t::iterator it = m_validRanges.begin(); it != m_validRanges.end(); it++)
		{
			if ((*it).minVal==0)
			{
				*lowRange = (*it).minVal;
				*highRange = (*it).maxVal;
				// Don't test any more of these ranges
				break;
			}
		}
	}
} // end of MaxInputRange()


////////////////////////////////////////////////////////////////////////////////////
// SetAllPolarities()
// This method changes all polarities of all channels to be the same.
// This function should be removed if (when) the engine supports mixed
// polarities.
//////////////////////////////////////////////////////////////////////////////////////
void CadvantechAin::SetAllPolarities(PolarityType polarity)
{
	NESTABLEPROP *chan;
    AICHANNEL *pchan;
	
    // For Advantech: If there is a polarity change on one channel then the other channels must have
	// their their input ranges changed to the most logical option based on their previous value. So if 
	// the input range of a channel was -10 to 10 then the unipolar equivalent is 0 to 10...
	// The FindRange method will be used to find this new input range.
	
	for (int i=0; i < _nChannels; i++) 
    {	    
		_EngineChannelList->GetChannelStructLocal(i, &chan);
		if (chan == NULL) break;
		pchan = (AICHANNEL*)chan;
        if (polarity == POLARITY_BIPOLAR)
		{
			RANGE_INFO *NewInfo;
			FindRange(static_cast<float>(-pchan->VoltRange[1]), 
				      static_cast<float>(pchan->VoltRange[1]), NewInfo);
			pchan->VoltRange[0] = NewInfo->minVal;
			pchan->VoltRange[1] = NewInfo->maxVal;			
			m_chanGainCode[i] = NewInfo->gainCode; 
		}
		else
		{
			RANGE_INFO *NewInfo;
			FindRange(0, static_cast<float>(pchan->VoltRange[1]), NewInfo);
			pchan->VoltRange[0] = 0;
			pchan->VoltRange[1] = NewInfo->maxVal;			
			m_chanGainCode[i] = NewInfo->gainCode;
		}
    }
	// Store the current polarity
	m_polarity = polarity;
	
	// Deal with the default input range:
    CComPtr<IProp> prop;
    CComVariant val;
	HRESULT hRes = GetChannelProperty(L"InputRange", &prop);
	VARIANT oldVal;
	prop->get_DefaultValue(&oldVal);
	double VoltRange[2];
	double lowRange, highRange;
	MaxInputRange(m_polarity, &lowRange, &highRange);
	VoltRange[0] = lowRange;
	VoltRange[1] = highRange;
    CreateSafeVector(VoltRange,2,&val);
    hRes = prop->put_DefaultValue(val);
    prop.Release();
} // end of SetAllPolarities()


///////////////////////////////////////////////////////////////////////////////////
// ValidateNewRate(double newrate, double maxCurrentRate)
// The sample rate passed to this method is compared to the current maximum sample  
// rate, if this sample rate exceeds the max value then the sample rate is changed
// to the current maximum sample rate.
////////////////////////////////////////////////////////////////////////////////////
void CadvantechAin::ValidateNewRate(double newrate, double maxCurrentRate)
{
    // Make sure channel is at least 1
    long nChannels;
    if ( _nChannels > 0 )
        nChannels = _nChannels;
    else
        nChannels = 1;

	double maxSR = QuantiseValue(maxCurrentRate/nChannels);
	if (newrate > maxSR)
	{
		_engine->WarningMessage(CComBSTR(L"ADVANTECH: Reducing sampling rate based on new limits."));
		newrate = maxSR;
	}
	pSampleRate = newrate;
} // end of ValidateNewRate()

///////////////////////////////////////////////////////////////////////////////////
// QuantiseValue()
// The new sample rate is passed to this method which selects the closest quantised 
// equivelent sample rate.  
////////////////////////////////////////////////////////////////////////////////////
double CadvantechAin::QuantiseValue(double rate)
{
	// Advantech drivers require an INTEGER sample rate (unsigned long) so we have no choice but to...
	return ceil(rate);
} // end of QuantiseValue()


///////////////////////////////////////////////////////////////////////////////////
// UpdateRateandSkew()
// This method sets sample rate range and channelskew value based on the currently   
// selected clock source and number of channels created.
////////////////////////////////////////////////////////////////////////////////////
void CadvantechAin::UpdateRateandSkew()
{
	if (pClockSource == CLCK_SOFTWARE)
	{
		pSampleRate.SetRange(MIN_SW_SAMPLERATE, MAX_SW_SAMPLERATE);
		pSampleRate.SetDefaultValue(MAX_SW_SAMPLERATE);
	}
	if (pClockSource == CLCK_INTERNAL)
	{
		ValidateNewRate(pSampleRate, m_maxSampleRate);
		if (_nChannels > 0)
		{
			pSampleRate.SetRange(m_minSampleRate, m_maxSampleRate/_nChannels);
			if (m_maxSampleRate/_nChannels < 1000)
			{
				pSampleRate.SetDefaultValue(m_maxSampleRate/_nChannels);
			}
			else 
			{
				pSampleRate.SetDefaultValue(1000);
			}
		}
		else 
		{
			pSampleRate.SetRange(m_minSampleRate, m_maxSampleRate);
			pSampleRate.SetDefaultValue(1000);
		}
	}

	// Update channel skew
	// NOTE: Channel skew is set to 0 when there are less than 2 channels created as channel skew is defined 
	//       as the time between consecutively sampled channels.
	if (_nChannels >= 2)
	{
		pChannelSkew = 1/(pSampleRate*_nChannels);	
	}
	else 
	{
		pChannelSkew = 0;
	}
} // end of UpdateRateandSkew()


////////////////////////////////////////////////////////////////////////////////////
// GetInputTypeConfiguration()	
// This method queries the registry in order to find the InputType of the device.
////////////////////////////////////////////////////////////////////////////////////
ITInputType CadvantechAin::GetInputTypeConfiguration()	
{
	// Get the input type from the registry using the following path:
	// HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\<drivername>s\device<ID=%03d>\ChanConfig
	// Recent Advantech devices use ADS****s as the registry key name
	// or:
	// HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\ADSIO\device<ID=%03d>\ChanConfig
	// Older Advantech devices use ADSIO (and not the driver name) as the registry key name.

	ITInputType inputType = IT_SINGLE_ENDED;
	HKEY hMainKey = HKEY_LOCAL_MACHINE;
	char deviceKey[10];
	int res = sprintf(deviceKey, "device%03d", m_deviceID);
	HKEY hSubKey;

	char driverName[30];
	int drvNameLen = strlen(m_DevFeatures.szDriverName);
	strncpy(driverName, m_DevFeatures.szDriverName, drvNameLen-4);
	// Append the zero
	driverName[drvNameLen-4]=0;
	strcat(driverName,"s");	// Append "s"

	if (::RegOpenKey(hMainKey, "SYSTEM", &hSubKey) == ERROR_SUCCESS)
	{
		HKEY hSubKey1;
		if (::RegOpenKey(hSubKey, "CurrentControlSet", &hSubKey1) == ERROR_SUCCESS)
		{
			HKEY hSubKey2;
			if (::RegOpenKey(hSubKey1, "Services", &hSubKey2) == ERROR_SUCCESS)
			{
				HKEY hSubKey3;
				if ((::RegOpenKey(hSubKey2, driverName, &hSubKey3) == ERROR_SUCCESS) || (::RegOpenKey(hSubKey2, "ADSIO", &hSubKey3) == ERROR_SUCCESS))	// Case sensitive? No.
				{
					HKEY hSubKey4;
					if (::RegOpenKeyEx(hSubKey3, deviceKey, 0, KEY_QUERY_VALUE, &hSubKey4) == ERROR_SUCCESS)
					{
						DWORD inputConfig;
						DWORD inputConfigSize = sizeof(DWORD);
						DWORD Type;

						HRESULT HValRes = RegQueryValueEx(hSubKey4, "ChanConfig", NULL, &Type, 
							(UCHAR *) &inputConfig, &inputConfigSize);
						if (HValRes == ERROR_SUCCESS)
						{
							// Jumpered devices contain different registry input type (ChanConfig)
							// information to software settable devices. Jumpered devices have the ChanConfig 
							// field set to either 0 (SE) or 1 (Diff) whereas software configurable devices have
							// the bits in ChanConfig corresponding to the channels set to either 1 or 0, depending 
							// on the setup inthe Advantech Utility. The m_swInputType variable is set up in the ini 
							// file so that we know which interpretation to use.

							if (m_swInputType) // Input type (single-ended/differential) is software configurable
							{
								int bits = static_cast<int>(pow(2,2*m_maxAIDiffChl)-1);
								if ((inputConfig != 0) && (inputConfig != (bits)))	 
								{
									inputType = IT_ERROR;	
								}
								else
								{
									if (inputConfig == 0)
										inputType = IT_SINGLE_ENDED;
									else 
										inputType = IT_DIFFERENTIAL;
								}
							}
							else // jumpered
							{
								if(inputConfig == 0) // if single ended...
									inputType = IT_SINGLE_ENDED;
								else
									inputType = IT_DIFFERENTIAL;
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
	return inputType;
} // end of GetInputTypeConfiguration()


////////////////////////////////////////////////////////////////////////////////////
// GetPolarityConfiguration()	
// This method queries the registry in order to check 
// if the device polarity is jumpered. If the polarity is jumpered
// the current polarity setting is returned			
////////////////////////////////////////////////////////////////////////////////////
void CadvantechAin::GetPolarityConfiguration()	
{
	// Get the input type from the registry using the following path:
	// HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\<drivername>s\device<ID=%03d>\ChanConfig
	// Recent Advantech devices use ADS****s as the registry key name
	// or:
	// HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\ADSIO\device<ID=%03d>\ChanConfig
	// Older Advantech devices use ADSIO (and not the driver name) as the registry key name.
	
	HKEY hMainKey = HKEY_LOCAL_MACHINE;
	char deviceKey[10];
	// Assume that the kernel key is the <drivername>s option
	int res = sprintf(deviceKey, "device%03d", m_deviceID);
	HKEY hSubKey;

	char driverName[30];
	int drvNameLen = strlen(m_DevFeatures.szDriverName);
	// All devices have 4 numbers appended, hence delete
	strncpy(driverName, m_DevFeatures.szDriverName, drvNameLen-4);
	// Append the zero
	driverName[drvNameLen-4]=0;
	strcat(driverName,"s");	// Append "s"

	if (m_swPolarityConfig == 0)
	{
		if (::RegOpenKey(hMainKey, "SYSTEM", &hSubKey) == ERROR_SUCCESS)
		{
			HKEY hSubKey1;
			if (::RegOpenKey(hSubKey, "CurrentControlSet", &hSubKey1) == ERROR_SUCCESS)
			{
				HKEY hSubKey2;
				if (::RegOpenKey(hSubKey1, "Services", &hSubKey2) == ERROR_SUCCESS)
				{
					HKEY hSubKey3;
					if ((::RegOpenKey(hSubKey2, driverName, &hSubKey3) == ERROR_SUCCESS) || 
						(::RegOpenKey(hSubKey2, "ADSIO", &hSubKey3) == ERROR_SUCCESS))
					{
						HKEY hSubKey4;
						if (::RegOpenKeyEx(hSubKey3, deviceKey, 0, KEY_QUERY_VALUE, &hSubKey4) == ERROR_SUCCESS)
						{
							DWORD polarityConfig;
							DWORD polarityConfigSize = sizeof(DWORD);
							DWORD Type;

							HRESULT HValRes = RegQueryValueEx(hSubKey4, "Polarity", NULL, &Type, 
								(UCHAR *) &polarityConfig, &polarityConfigSize);
							if (HValRes == ERROR_SUCCESS)
							{							
								m_polarity = (polarityConfig == 0)? POLARITY_BIPOLAR : POLARITY_UNIPOLAR;														
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
	}
	
} // end of GetPolarityConfiguration()

////////////////////////////////////////////////////////////////////////////////////
// Start()	
//
// Set up the acquisition
//				
////////////////////////////////////////////////////////////////////////////////////
HRESULT CadvantechAin::Start()
{
	if (_updateChildren) 
    {
        RETURN_HRESULT(UpdateChans(true));
    }

	// Add this device to the running list if we can.
	if (GetParent()->AddDev((analoginputMask + m_deviceID),this))
	{
		return E_DEVICE_RUNNING;
	}
	
	if (pClockSource == CLCK_SOFTWARE)
		return InputType::Start();
	
	RETURN_HRESULT(StopDeviceIfRunning()); 
	m_triggerPosted = false;

	m_pointsThisRun = 0;	
	// THERE APPEARS TO BE A BUG IN THE ENGINE WHICH PREVENTS THE CODE BELOW FROM WORKING. 
	// TOM G KNOWS ABOUT THIS AND WILL RESOLVE THE ISSUE EITHER WAY. FOR NOW WE LEAVE THE CODE
	// COMMENTED OUT.
	/*
	// We want to stop in between triggers if manualtriggerhwon is set to Trigger.
	if (pManualTriggerHwOn == MTHO_TRIGGER)
	{
		m_triggersToGo = pTriggerRepeat;
		m_pointsLeftInTrigger = pSamplesPerTrigger * _nChannels;
	}
	else
	*/
	{
		m_triggersToGo = 0;	
		m_pointsLeftInTrigger = MAXLONG;
	}
	
	// Allocate buffer sizes for DMA and then Interrupts
	long bufferSize = 0;
	if ((pTransferMode == TRANSFER_DMA) && (!m_supportsHwTrigger))
	{
		// Determine the buffer size:
		_engine->GetBufferingConfig(&m_engBuffSizePoints, NULL);

		// Convert the result from GetBufferingConfig to the total number of points in the engine buffer
		m_engBuffSizePoints *= _nChannels;

		bufferSize = m_engBuffSizePoints * 8;  // try 8 engine buffers in total
		// DMA buffer allocation rules - Advantech driver
		// If the buffer size is less then 2kB, make it 2kB,
		// else if the buffer size is greater than 16K points, make it 16K points.
		if (bufferSize < 2*1024)
		{
			bufferSize = 2*1024;
		}
		else if (bufferSize > 16*1024)
		{
			bufferSize = 16*1024;
		}
	
		if (bufferSize < 2*m_engBuffSizePoints)
		{
			// The circular buffer must be at least 2 engine buffers in size to avoid overruns.
			GetParent()->DeleteDev((analoginputMask + m_deviceID));
			return E_BUFDMASIZE;
		}
	}
	else // TransferMode is interrupt
	{
		// Determine the buffer size:
		_engine->GetBufferingConfig(&m_engBuffSizePoints, NULL);
		// Note: BufferingConfig returns the number of samples in an engine buffer.
		// For DAQ, one sample is one measurement for each channel in the list. That is 1 sample is one point if
		// there is one channel in the list and 1 sample is 2 points if there are two channels etc.

		// Convert the result from GetBufferingConfig to the total number of points in the engine buffer
		m_engBuffSizePoints *= _nChannels;	

		bufferSize = m_engBuffSizePoints * 8;  // 8 engine buffers in total
		// Interrupt buffer allocation rules:
		// If the buffer size is less than one FIFO, make it one FIFO,
		// else if the buffer size is greater than 128K points, make it 128K points.
		if ((m_supportsHwTrigger) && (bufferSize < 4096))
		{
			// For DMAExStart we get interrupts (that update FAICheck) every 2048 points, so if the acquisition 			 
			// is not single shot the minimum buffersize is 4096 - setting this regardless of single shot. 
			bufferSize = 4096; 
		}
		else if (bufferSize < m_aiFifo)
		{
			bufferSize = m_aiFifo;
		}
		else if (bufferSize > 128*1024)
		{
			bufferSize = 128*1024;
		}
	}

	// Decide on whether it is single shot or cyclic
	long totalPoints = (m_pointsLeftInTrigger == MAXLONG) ? pTotalPointsToAcquire : m_pointsLeftInTrigger;
	m_singleShot = ((totalPoints > 0) && (totalPoints <= bufferSize)) ? true : false;
	
	if (m_singleShot)
	{
		m_pointsLeftInTrigger = totalPoints;
	}
		
	int cyclicMode = m_singleShot ? 0: 1;
	// Advantech's DRV_FAIDMAExStart uses DMA, but does not require initialisation of the 
	// buffer through a call to DRV_DMAAllocate. Consequently, the second param below:
	// bufferSize = 128*1024;
	HRESULT hRes = m_circBuff.Initialize(bufferSize, 
		((pTransferMode == TRANSFER_DMA) && (!m_supportsHwTrigger)), cyclicMode);
	if (hRes != 0)
	{
		GetParent()->DeleteDev((analoginputMask + m_deviceID));
	}
	RETURN_HRESULT(hRes);

	//DEBUG: ATLTRACE("Buffer size of %d points allocated.\n", bufferSize);

	NESTABLEPROP *firstChan;
	_EngineChannelList->GetChannelStructLocal(0, &firstChan);

	// Setup interrupts acquisition
	if ((pTransferMode == TRANSFER_INTERRUPT_PB) || (pTransferMode == TRANSFER_INTERRUPT_PP))
	{	
		// We will have to assign the transfer methods DataBuffer the engine buffer
		m_ptFAIIntScanStart.buffer	   = (USHORT far *) m_circBuff.GetPtr();
		m_ptFAIIntScanStart.TrigSrc    = (pClockSource == CLCK_EXTERNAL) ? 1: 0;	
		m_ptFAIIntScanStart.StartChan  = static_cast<USHORT>(firstChan->HwChan);
		m_ptFAIIntScanStart.NumChans   = static_cast<USHORT>(_nChannels);
		m_ptFAIIntScanStart.GainList   = &m_chanGainCode[0];	// Pointer to first element in array           
		m_ptFAIIntScanStart.SampleRate = static_cast<DWORD>(pSampleRate*_nChannels);
		m_ptFAIIntScanStart.count      = bufferSize; 
		m_ptFAIIntScanStart.cyclic     = cyclicMode; 
		m_ptFAIIntScanStart.IntrCount  = 1;	// This is overwritten below if the device has a FIFO buffer and interrupt
											// per block transfermode is selected
		if ((m_aiFifo > 0) && (pTransferMode == TRANSFER_INTERRUPT_PB))
			m_ptFAIIntScanStart.IntrCount = m_aiFifo/2;	
	}
	else if (m_supportsHwTrigger)	// Device needs a DMAExStart call
	{
		// This portion cannot be checked, as the driver doesn't return valid DRV_FAICheck data!
        m_ptFAIDmaExStart.TrigSrc    = ((pTriggerType == TRIGGER_HWDIGITAL)||(pTriggerType == TRIGGER_HWANALOG))? 1: 0;
		// Now use pacer triggering or post-triggering!
		m_ptFAIDmaExStart.TrigMode   = ((pTriggerType == TRIGGER_HWDIGITAL)||(pTriggerType == TRIGGER_HWANALOG))? 1: 0;
		m_ptFAIDmaExStart.ClockSrc   = (pClockSource == CLCK_EXTERNAL) ? 1: 0;
		m_ptFAIDmaExStart.TrigEdge   = static_cast<USHORT>(pTriggerCondition);
		m_ptFAIDmaExStart.SRCType    = (pTriggerType == TRIGGER_HWDIGITAL) ? 0 : 1;
		m_ptFAIDmaExStart.TrigVol    = static_cast<FLOAT>((pTriggerType == TRIGGER_HWANALOG) ? pTriggerConditionValue : 0.0);
		m_ptFAIDmaExStart.CyclicMode = cyclicMode;
		m_ptFAIDmaExStart.NumChans   = static_cast<USHORT>(_nChannels);
        m_ptFAIDmaExStart.StartChan  = static_cast<USHORT>(firstChan->HwChan);
        m_ptFAIDmaExStart.ulDelayCnt = 2;
        m_ptFAIDmaExStart.count      = bufferSize; 
        m_ptFAIDmaExStart.SampleRate = static_cast<ULONG>(pSampleRate*_nChannels);
        m_ptFAIDmaExStart.GainList   = &m_chanGainCode[0];
		m_ptFAIDmaExStart.CondList   = NULL;
		m_ptFAIDmaExStart.LevelList  = NULL;
        m_ptFAIDmaExStart.buffer0    = (USHORT far *)m_circBuff.GetPtr();
		m_ptFAIDmaExStart.buffer1    = NULL;
	}
	else
	{
		if (m_supportsScanning)
		{
			m_ptFAIDmaScanStart.buffer = (USHORT far *)m_circBuff.GetPtr();
			m_ptFAIDmaScanStart.TrigSrc    = (pClockSource == CLCK_EXTERNAL) ? 1: 0;
			m_ptFAIDmaScanStart.StartChan  = static_cast<USHORT>(firstChan->HwChan);
			m_ptFAIDmaScanStart.NumChans   = static_cast<USHORT>(_nChannels);
			m_ptFAIDmaScanStart.GainList   = &m_chanGainCode[0];
			m_ptFAIDmaScanStart.SampleRate = static_cast<DWORD>(pSampleRate*_nChannels);
			m_ptFAIDmaScanStart.count  = bufferSize; 
		}
		else
		{
			// Setup acquisition for devices which do not support multiple channel scanning
			m_ptFAIDmaStart.buffer = (USHORT far *)m_circBuff.GetPtr();
			m_ptFAIDmaStart.TrigSrc    = (pClockSource == CLCK_EXTERNAL) ? 1: 0;
			m_ptFAIDmaStart.chan  = static_cast<USHORT>(firstChan->HwChan);			
			m_ptFAIDmaStart.gain   = m_chanGainCode[0];			
			m_ptFAIDmaStart.SampleRate = static_cast<DWORD>(pSampleRate);
			m_ptFAIDmaStart.count  = bufferSize; 
		}
	}
        
	// Two timer ticks per smallest buffer
	m_timerPeriod = static_cast<double>(min(m_pointsLeftInTrigger,min(bufferSize, m_engBuffSizePoints))/_nChannels/pSampleRate/2);
	return S_OK;
} // end of Start()


////////////////////////////////////////////////////////////////////////////////////
// Trigger()	
//
// Description: Start the acquisition
//				
////////////////////////////////////////////////////////////////////////////////////
HRESULT CadvantechAin::Trigger()     
{	
	AUTO_LOCK;	
	if (pClockSource == CLCK_SOFTWARE)
	{
		return InputType::Trigger();
	}
	
	StopDeviceIfRunning();

	// Disable all events explicitly (but setup the Count correctly)
	PT_EnableEvent ptEnableEvent;
	ptEnableEvent.EventType = 15;
    ptEnableEvent.Enabled = 0;

	int count = 0; // This is the number of points between interrupt updates
	if (m_supportsHwTrigger)
	{
		count = 2048; // This is the minimum value between interrupts for DMAExStart
	}
	else
	{
		count = (m_aiFifo>0)? m_aiFifo : 1;	// Can't be zero for non-FIFO boards.
	}
	ptEnableEvent.Count = count;	
	HRESULT hRes = DRV_EnableEvent(m_driverHandle,(LPT_EnableEvent)&ptEnableEvent);
	if (hRes != 0)
	{
		GetParent()->DeleteDev((analoginputMask + m_deviceID));
	}
	RETURN_ADVANTECH(hRes);

	// Finally start the device!		
	if ((pTransferMode == TRANSFER_INTERRUPT_PB) || (pTransferMode == TRANSFER_INTERRUPT_PP))
	{
		hRes = DRV_FAIIntScanStart(m_driverHandle, (LPT_FAIIntScanStart)&m_ptFAIIntScanStart);
	}
	else if (m_supportsHwTrigger)
	{
		hRes = DRV_FAIDmaExStart(m_driverHandle, (LPT_FAIDmaExStart)&m_ptFAIDmaExStart);
	}
	else // Start DMA acqisition
	{
		if (m_supportsScanning)
		{
			hRes = DRV_FAIDmaScanStart(m_driverHandle, (LPT_FAIDmaScanStart)&m_ptFAIDmaScanStart);
		}
		else
		{
			long numChans; 
			HRESULT hRes = _EngineChannelList->GetNumberOfChannels(&numChans);
			// Error out if multiple channels are configured for boards which do not support scanning (PCL-812PG)
			if (numChans > 1)
			{
				return E_CHANNUM;
			}
			hRes = DRV_FAIDmaStart(m_driverHandle, (LPT_FAIDmaStart)&m_ptFAIDmaStart);
		}
	}
	if (hRes != 0)
	{
		GetParent()->DeleteDev((analoginputMask + m_deviceID));
	}
	RETURN_ADVANTECH(hRes);
	
	m_scanStatus = RUNNING;
	_running = true;
	TimerObj.CallPeriod(m_timerPeriod);	

	return S_OK;
} // end of Trigger()


////////////////////////////////////////////////////////////////////////////////////
// Stop()	
//
// Description: Stop the acquisition.
//				
////////////////////////////////////////////////////////////////////////////////////
HRESULT CadvantechAin::Stop()
{
	//DEBUG: ATLTRACE("\nIn Stop()\n");
	// Call DeleteDev even if the device is not running, so we trap manual trigger
	// conditions.
	GetParent()->DeleteDev((analoginputMask + m_deviceID));
	if (pClockSource == CLCK_SOFTWARE)
	{
		return InputType::Stop();
	}

	// Stop acquisition
	if (_running)
    {	
		TimerObj.Stop();
		AUTO_LOCK;
		RETURN_HRESULT(StopDeviceIfRunning()); 
		GetScanData();
		_running = false; // Reset flag
	}

	return S_OK;
} // end of Stop()


////////////////////////////////////////////////////////////////////////////////////
// GetScanData()	
//
// Description: Timer callback. Transfer data between our buffer and the engine.
//				
////////////////////////////////////////////////////////////////////////////////////
HRESULT CadvantechAin::GetScanData()
{
    AUTO_LOCK;
    if (!_running)
	{
		RETURN_HRESULT(StopDeviceIfRunning()); 
		GetParent()->DeleteDev((analoginputMask + m_deviceID));
        return E_FAIL;
	}

    BUFFER_ST  *BuffPtr;
	LRESULT checkerror = DRV_FAICheck(m_driverHandle, (LPT_FAICheck)&m_ptFAICheck);
	if (checkerror !=0)
	{
		StopDeviceIfRunning();
		GetParent()->DeleteDev((analoginputMask + m_deviceID));
		return E_FAIL;
	}
	/*
	if (m_gwOverrun)
	{
		LRESULT overrunerror = DRV_ClearOverrun(m_driverHandle);
		_engine->DaqEvent(EVENT_DATAMISSED, 0, m_pointsThisRun/_nChannels,NULL);
		StopDeviceIfRunning();
		GetParent()->DeleteDev((analoginputMask + m_deviceID));
		return E_FAIL;
	}
	*/
	//DEBUG: ATLTRACE("In GetScanData: m_retrieved on entry is %d\n", m_retrieved);

    // Hardware triggers need to be posted.
	if ((pTriggerType & TRIG_TRIGGER_IS_HARDWARE) && !m_triggerPosted)
	{
		//DEBUG: ATLTRACE("Must post a trigger.\n", m_triggersToGo);
		m_triggerPosted=true;
		double time;             
		_engine->GetTime(&time);
		// Is sampleRate the correct value here when multiple chans are sampled?
		double triggerTime = time - m_retrieved/_nChannels/pSampleRate;
		_engine->DaqEvent(EVENT_TRIGGER, triggerTime, m_pointsThisRun/_nChannels, NULL);
	}

    // Check for data missed via internal buffer overrun.
    if (!m_singleShot && m_circBuff.IsWriteOverrun(m_retrieved)) 
    {
        _engine->DaqEvent(EVENT_DATAMISSED, 0, m_pointsThisRun/_nChannels,NULL);
		RETURN_HRESULT(StopDeviceIfRunning()); 
		GetParent()->DeleteDev((analoginputMask + m_deviceID));
        return E_FAIL;
    }

    m_circBuff.SetWriteLocation((int) m_retrieved);

    // Check to see if enough data has been collected to fill a buffer.
    long flags=0;
	//DEBUG: ATLTRACE("m_engBuffSizePoints is %d\n", m_engBuffSizePoints);
	//DEBUG: ATLTRACE("m_pointsLeftInTrigger is %d\n", m_pointsLeftInTrigger);
	//DEBUG: ATLTRACE("Valid data number is: %d\n", m_circBuff.ValidData());
    while ( m_circBuff.ValidData() >= min(m_engBuffSizePoints,m_pointsLeftInTrigger))
    {
		//DEBUG: ATLTRACE("GetScanData loop. Circbuff Valid is %d, compare with %d\n", m_circBuff.ValidData(), min(m_engBuffSizePoints,m_pointsLeftInTrigger));
        // Get buffer from engine
        long bufferstatus = _engine->GetBuffer(0, &BuffPtr);
        if (bufferstatus == S_OK)
        {
            long pointstocopy = min(BuffPtr->ValidPoints, m_pointsLeftInTrigger);
            flags = BuffPtr->Flags;  
			//DEBUG: ATLTRACE("\t\tWant %d points for an engine buffer..", pointstocopy);
            m_circBuff.CopyOut((CIRCBUFFER::CBT*)BuffPtr->ptr,pointstocopy);
			//DEBUG: ATLTRACE("Done\n");
            BuffPtr->ValidPoints = pointstocopy;
            BuffPtr->StartPoint = m_pointsThisRun;
            m_pointsThisRun += pointstocopy;
            if (m_pointsLeftInTrigger != MAXLONG) 
                m_pointsLeftInTrigger -= pointstocopy;
            // Put the buffer back to the engine
            _engine->PutBuffer(BuffPtr);
        }

        if ((flags & BUFFER_IS_LAST ) || m_pointsLeftInTrigger==0 || bufferstatus==DE_NOT_RUNNING)
        {
			if ((m_scanStatus==RUNNING) && (!m_triggersToGo))
			{
				_engine->DaqEvent(EVENT_STOP, -1, m_pointsThisRun/_nChannels, NULL);
			}
			//DEBUG: ATLTRACE("Stopping Device..");
			RETURN_HRESULT(StopDeviceIfRunning()); 
			// Now deleting device from list so that another acquisition can take place
			//DEBUG: ATLTRACE("Deleting device..");
			GetParent()->DeleteDev((analoginputMask + m_deviceID));
			//DEBUG: ATLTRACE("Done\n");

            break;
        }
        if (bufferstatus) break;
    }

    if (m_scanStatus==IDLE && m_triggersToGo)
    {
		//DEBUG: ATLTRACE("m_scanStatus==IDLE and Triggers to go is %d\n", m_triggersToGo);
        --m_triggersToGo;
        m_circBuff.Reset();
        m_pointsLeftInTrigger= static_cast<long>(pSamplesPerTrigger * _nChannels);
		if (pManualTriggerHwOn == MTHO_START)
		{
			LRESULT lRes = 0;
			{
				lRes = DRV_FAIDmaExStart(m_driverHandle, (LPT_FAIDmaExStart)&m_ptFAIDmaExStart);
				if (lRes != 0)
				{
					GetParent()->DeleteDev((analoginputMask + m_deviceID));
				}
				RETURN_ADVANTECH(lRes);
			}
	        m_scanStatus = RUNNING;
			m_triggerPosted = false;
		}
    }
    
	return (m_scanStatus == IDLE ? 1 : S_OK);
} // end of GetScanData()


////////////////////////////////////////////////////////////////////////////////////
// StopDeviceIfRunning()	
//
// Description: Call driver stop if required.
//				
////////////////////////////////////////////////////////////////////////////////////
HRESULT CadvantechAin::StopDeviceIfRunning()
{
	if (m_scanStatus==RUNNING)
	{
		//DEBUG: ATLTRACE("Asking the driver to stop the device..");
		RETURN_ADVANTECH(DRV_FAIStop(m_driverHandle));
		//DEBUG: ATLTRACE("Done..\n");
		m_scanStatus=IDLE;		
	}

	return S_OK;
} // end of StopDeviceIfRunning()


////////////////////////////////////////////////////////////////////////////////////
// CheckTransferMode()	
//
// Description: Check for automatic changover of transfer modes.
//				
////////////////////////////////////////////////////////////////////////////////////
void CadvantechAin::CheckTransferMode(bool showWarnings)
{
	// Switch to IPP if sample rate is less than 20kHz
	if (SUPPORTS_IPP && (pTransferMode == TRANSFER_INTERRUPT_PB) && 
		(_nChannels > 0) && (pSampleRate < 20000))
	{
		pTransferMode = TRANSFER_INTERRUPT_PP;
		if (showWarnings)
		{
			_engine->WarningMessage(CComBSTR(L"ADVANTECH: TransferMode changed to InterruptPerPoint."));
		}
	}
	// Switch to IPB if sample rate > 20 kHz
	if (SUPPORTS_IPB && (pSampleRate >= 20000) && (pTransferMode == TRANSFER_INTERRUPT_PP))
	{
		{
			pTransferMode = TRANSFER_INTERRUPT_PB;
			if (showWarnings)
			{
				_engine->WarningMessage(CComBSTR(L"ADVANTECH: TransferMode changed to InterruptPerBlock."));
			}
		}
	}
}

////////////////////////////////////////////////////////////////////////////////////
// SetDefaultTriggerConditionValues()
//
// Description: Set up default Trigger Condition Value for Analog HW Trigger
//				
////////////////////////////////////////////////////////////////////////////////////
HRESULT CadvantechAin::SetDefaultTriggerConditionValues(double minVol, double maxVol)
{
	// Trigger condition values are read-only until
	// the trigger condition is set. The default
	// value is an empty array
    HRESULT hRes;
    SAFEARRAY *ps = SafeArrayCreateVector(VT_R8, 0, 1);
    if (ps==NULL) E_FAIL;
    CComVariant val;
	
    // set the data type and values
    V_VT(&val)=VT_ARRAY | VT_R8;
    V_ARRAY(&val)=ps;
    double *range = NULL;
    hRes = SafeArrayAccessData(ps, (void **) &range);
    if (FAILED (hRes)) 
    {
        SafeArrayDestroy(ps);
        return E_FAIL;
    }
    range=0;
    hRes = pTriggerConditionValue->put_Value(val);
    if (!SUCCEEDED(hRes)) 
    {
        SafeArrayUnaccessData(ps);
		return hRes;        
    }
	hRes = pTriggerConditionValue->put_DefaultValue(val);
    if (!SUCCEEDED(hRes)) 
    {
        SafeArrayUnaccessData(ps);
		return hRes;        
    }
	hRes = pTriggerConditionValue->SetRange(&CComVariant(minVol),&CComVariant(maxVol));
    if (!SUCCEEDED(hRes)) 
    {
        SafeArrayUnaccessData(ps);
		return hRes;        
    }
    SafeArrayUnaccessData(ps);
    return S_OK;
}

