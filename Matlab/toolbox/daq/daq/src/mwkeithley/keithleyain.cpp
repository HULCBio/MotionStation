// keithleyain.cpp : Implementation of the Keithley AnalogInput device
// $Revision: 1.1.6.2 $
// $Date: 2003/12/04 18:39:37 $

// Copyright 2002-2003 The MathWorks, Inc. 
// Coded by OPTI-NUM solutions

#include "stdafx.h"
#include "mwkeithley.h"
#include "keithleyain.h"
#include "keithleyadapt.h"
#include "math.h"
#include "keithleypropdef.h"
#include <limits>
#include "keithleyUtil.h"

#define AUTO_LOCK TAtlLock<Ckeithleyain> _lock(*this)
#define INFINITY std::numeric_limits<double>::infinity()


/////////////////////////////////////////////////////////////////////////////
// Ckeithleyain() constructor
//
// Performs all the necessary initialization.
///////////////////////////////////////////////////////////////////////////// 
Ckeithleyain::Ckeithleyain():
m_termination(CHAN_SEDIFF_SE),
m_pSR(NULL),
m_subSystem(AI),
m_isInitialized(false),
m_supportsBipolar(false),
m_supportsUnipolar(false),
m_supportsDMA(false),
m_supportsPolledClockOnly(false),
m_numgains(0),
m_daqStatus(STATUS_STOPPED),
m_minBoardSampleRate(0),
m_maxBoardSampleRate(0),
m_minManChanSkew(0),
m_maxManChanSkew(0),
m_polarity(POLARITY_BIPOLAR),	// Default to bipolar max range!
m_triggering(false),
m_triggerPosted(false),
m_usingDMA(true),
m_numSEOnBoard(0),
m_numDIOnBoard(0),
m_maxValidSEChan(0),
m_maxValidDIChan(0),
m_clockDividerWidth(0),
m_supportsBurstMode(FALSE),
m_terminationMode(IN_SINGLEENDED),
m_driverHandle(NULL),
m_chanSkewSafetyRange(0),
m_chanSkewSafetyUnits(CHAN_SKEW_SAFE_TICS),
m_aiTicPeriod(0),
m_channelGainQueueSize(0),
m_triggersProcessed(0),
m_samplesThisRun(0),
m_engineBufferSamples(0),
m_deviceID(0),
m_ldd(NULL)
{
	m_pParent = MessageWindow::GetKeithleyWnd(); 
	m_pSR = (DL_ServiceRequest *) new DL_ServiceRequest;
	memset(m_pSR, 0, sizeof(DL_ServiceRequest));
	//Set the size of the service request
	m_pSR->dwSize = sizeof(DL_ServiceRequest);
} // end of constructor


/////////////////////////////////////////////////////////////////////////////
// ~Ckeithleyain() 
//
// Ckeithleyain destructor
///////////////////////////////////////////////////////////////////////////// 
Ckeithleyain::~Ckeithleyain()
{
    m_pParent->Release();

	// Free up all the DriverLINX service request pointers
	// Clean up the Channel Gain List,...
	if (m_pSR->channels.chanGainList != NULL)
	{
		delete [] m_pSR->channels.chanGainList;
		m_pSR->channels.chanGainList = NULL;
	}
	
	// Clean up the buffers,...
	DL_BUFFERLIST *pBuffer = m_pSR->lpBuffers;
	// Check to see if any buffers exist in the service request data structure.
	// If they do, delete them and then set the DL_BUFFERLIST data structure to
	// NULL.
	if (pBuffer != NULL)	 // If data structure exists
	{
		int i;
		for (i = 0; i< pBuffer->nBuffers; i++)
		{
			if (pBuffer->BufferAddr[i] != NULL)	   //Delete old buffers
			{
				BufFree(pBuffer->BufferAddr[i]);
			}
		}
		delete [] pBuffer;	// Release memory
		pBuffer = NULL;		// Set data structure to NULL
		m_pSR->lpBuffers = NULL;
	}
	
	// Free the memory associated with Service Request
	if ( m_pSR != NULL )
	{
		delete m_pSR;
		m_pSR = NULL;
	}
	m_validRanges.clear();

	// Finally free the memory associated with the LDD
	::FreeLDD(m_ldd);
	//DEBUG: ATLTRACE("DumpUnfreed() called in Ckeithleyain.\n");
	//DEBUG: DumpUnfreed(); // Call Our Memory Checker.}
}


/////////////////////////////////////////////////////////////////////////////
// Open()
//
// Function is called by the OpenDevice(), which is in turn called by the engine.
// Ckeithleyain::Open() function's main goals are ..
// 1)to initialize the hardware and hardware dependent properties..
// 2)to expose pointers to the engine and the adaptor to each other..
// 3)to process the device ID, which is input by a user in the ML command line.
// The call to this function goes through the hierarchical chain: ..
//..Ckeithleyain::Open() -> CswClockedDevice::Open() -> CmwDevice::Open()
// CmwDevice::Open() in its turn populates the pointer to the..
//..engine (CmwDevice::_engine), which allows to access all engine interfaces.
//////////////////////////////////////////////////////////////////////////////
HRESULT Ckeithleyain::Open(IUnknown *Interface,long ID)
{
	if (ID<0) 
	{
		CComBSTR _error;
		_error.LoadString(IDS_ERR_INVALID_DEVICE_ID);
		return CComCoClass<ImwDevice>::Error(_error);
	}
	
	m_pSR->hWnd = GetParent()->GetHandle();
	
	RETURN_HRESULT(TBaseObj::Open(Interface));
	
	m_deviceID = static_cast<WORD>(ID);	// Set the Device Number to the requested device number
	
	for( std::vector<DEVICEDETAILS>::iterator it = GetParent()->m_deviceMap.begin();
							it != GetParent()->m_deviceMap.end(); it++)
	{
		if( (*it).deviceID == m_deviceID)
			m_driverHandle = GetParent()->m_driverMap[(*it).driverLookup].driverHandle;
	}

	SELECTMYDRIVERLINX(m_driverHandle);
	m_ldd = ::GetLDD(NULL, m_deviceID); // Now get the LDD for the Device and store the handle
	if (m_ldd==NULL)
	{
		// Something is wrong. Probably not a configured device.
		char tempMsg[255];
		sprintf(tempMsg, "Keithley Error: Device %d not found. Check DriverLINX Configuration Panel!", m_deviceID);
		return CComCoClass<ImwDevice>::Error(tempMsg);
	}
	
	if (!SupportsSubSystem((LDD*)m_ldd, AI))
		return Error(_T("Keithley: Analog Input is not supported on this device."));

	// Add the DeviceID to the Service Request
	m_pSR->device = m_deviceID;		// Device ID
	// Initialize the device if it hasn't already been done.
	if (!((LDD*)m_ldd)->DevCap.DeviceInit)
	{
		WORD ResultCode;
		SELECTMYDRIVERLINX(m_driverHandle);
		RETURN_CODE(InitializeDriverLINXDevice(m_pSR, &ResultCode));
		if (ResultCode != 0)
		{
			char tempMsg[255];
			ReturnMessageString(NULL, ResultCode,tempMsg, 255 );
			return CComCoClass<ImwDevice>::Error(tempMsg);
		}
	}
	
	m_pSR->subsystem = AI;			// Analog input subsystem
	// Load all the needed information from the INI file.
	RETURN_HRESULT(LoadINIInfo());
	
	m_supportsDMA = (DoesDeviceSupportDMA(m_pSR) == DL_TRUE);
	SELECTMYDRIVERLINX(m_driverHandle);
	if ((!m_supportsDMA) && (DoesDeviceSupportIRQ(m_pSR) != DL_TRUE)) // Only supports polled
	{
		m_supportsPolledClockOnly = true;
		EnableSwClocking(true);
	}
	
	if(((LDD*)m_ldd)->AnaChan[1].lpAnGainMult != NULL)
	{
		m_numgains = ((LDD*)m_ldd)->AnaChan[1].lpAnGainMult->Nentries;	// Get the number of gains in the Gain
	}
	else
		m_numgains = 1;

	m_channelGainQueueSize = ((LDD*)m_ldd)->AnaChan[1].AnChanGainMaxEntries;

	double defaultSampleRate = 1000;
	double maxSampleRate;
	double minSampleRate;
	if (!m_supportsPolledClockOnly)
	{
		// Only calculate board sample rates if there is an onboard clock!
		m_aiTicPeriod = static_cast<float>(CalculateMicroSec());
		m_maxBoardSampleRate = CalculateMaxSampleRate(true);	// As well as the maximum samplerate.
		m_minBoardSampleRate =  CalculateMinSampleRate(m_clockDividerWidth);// NOTE - 0.000233 - Only for the lower speed clocks; 
		maxSampleRate = m_maxBoardSampleRate;
		minSampleRate = m_minBoardSampleRate;
	}
	else
	{
		m_aiTicPeriod = 0;
		maxSampleRate = (float)MAX_SW_SAMPLERATE;
		minSampleRate = (float)MIN_SW_SAMPLERATE;
		defaultSampleRate = 100;
	}

	RETURN_HRESULT(FindNumberOfChannels());
	
	RETURN_HRESULT(SetDaqHwInfo()); // Set the DaqHwInfo properties.
	
	//////////////////////////////// Properties ///////////////////////////////////
	// The following Section sets the Propinfo for the Analog input device      //
	///////////////////////////////////////////////////////////////////////////////
	
	// This is the Sample Rate property
	ATTACH_PROP(SampleRate);
	pSampleRate.SetDefaultValue(CComVariant(defaultSampleRate));
	pSampleRate = defaultSampleRate;
	pSampleRate.SetRange(minSampleRate,maxSampleRate);

	// This is the Clock Source Property
	CComPtr<IProp> prop;
 	ATTACH_PROP(ClockSource);
	pClockSource->AddMappedEnumValue(CLCK_SOFTWARE, L"Software");
	pClockSource->AddMappedEnumValue(CLCK_EXTERNAL, L"External");
	pClockSource->put_DefaultValue(CComVariant(CLCK_INTERNAL));
	pClockSource = CLCK_INTERNAL;
	
	int clock = (int) pow(2, EXTERNAL);
	if (m_supportsPolledClockOnly)
	{
		pClockSource->RemoveEnumValue(CComVariant(L"internal"));
		pClockSource->RemoveEnumValue(CComVariant(L"External"));
		pClockSource->put_DefaultValue(CComVariant(CLCK_SOFTWARE));
		pClockSource = CLCK_SOFTWARE;

		//This is the Transfer Mode property -- Polled Mode
		CREATE_PROP(TransferMode);
		pTransferMode->AddMappedEnumValue(TRANSFER_POLLED, L"Polled");
		pTransferMode.SetDefaultValue(TRANSFER_POLLED);
		pTransferMode = TRANSFER_POLLED;

	}
	else  //!supportsPolledClockOnly
	{
		if (!((((LDD*)m_ldd)->CTChan.lpCTCapabilities->clocks) & clock)) // Does not support external clock
		{
			pClockSource->RemoveEnumValue(CComVariant(L"External"));
		}
				
		// This is the Channel Skew property
		// Channel Skew is not defined for systems with software clocking only
		ATTACH_PROP(ChannelSkew);
		CComVariant _minchannelskew(m_minManChanSkew);
		CComVariant _maxchannelskew(m_maxManChanSkew);
		pChannelSkew.SetRange(_minchannelskew, _maxchannelskew);
		double defaultskew = m_minManChanSkew;
		pChannelSkew.SetDefaultValue(defaultskew);
		pChannelSkew->put_Value(CComVariant(defaultskew));
	
		// This is the Channel Skew Mode property
		// Channel Skew is not defined for systems with software clocking only
		ATTACH_PROP(ChannelSkewMode);
		pChannelSkewMode->AddMappedEnumValue(CHAN_SKEW_EQUISAMPLE, L"Equisample");
		if(m_supportsBurstMode == FALSE) 
		{
			pChannelSkewMode = CHAN_SKEW_EQUISAMPLE;
			pChannelSkewMode.SetDefaultValue(CComVariant(CHAN_SKEW_EQUISAMPLE));
		}
		else
		{
			pChannelSkewMode->AddMappedEnumValue(CHAN_SKEW_MANUAL, L"Manual");
			pChannelSkewMode->AddMappedEnumValue(CHAN_SKEW_MIN, L"Minimum");
			pChannelSkewMode = CHAN_SKEW_MIN;
			pChannelSkewMode.SetDefaultValue(CComVariant(CHAN_SKEW_MIN));
		}
	}
	
	// This is the Input Type property
	// We need to know when it changes, so we can destroy all channels!!
	ATTACH_PROP(InputType);
	pInputType->AddMappedEnumValue(IN_SINGLEENDED, L"SingleEnded");
	pInputType->AddMappedEnumValue(IN_DIFFERENTIAL, L"Differential");
	if(m_terminationMode == IN_SINGLEENDED)
	{
		pInputType->put_DefaultValue(CComVariant(IN_SINGLEENDED));
		pInputType = IN_SINGLEENDED;
	}
	else
	{
		pInputType->put_DefaultValue(CComVariant(IN_DIFFERENTIAL));
		pInputType = IN_DIFFERENTIAL;
	}
	
	// This is the Samples Per Trigger property
	// Change the Samples Per Trigger Default value to 1000
	ATTACH_PROP(SamplesPerTrigger);
	pSamplesPerTrigger->put_DefaultValue(CComVariant(defaultSampleRate));
	pSamplesPerTrigger = defaultSampleRate;
	
	// This is the Trigger Condition property
	ATTACH_PROP(TriggerCondition);
	
	// This is the Trigger Condition Value property
	ATTACH_PROP(TriggerConditionValue);
	SetDefaultTriggerConditionValues();
	
	// This is the Trigger Delay property
	ATTACH_PROP(TriggerDelay);
	
	// This is the Samples Per Trigger property
	ATTACH_PROP(SamplesPerTrigger);
	
	// This is the Total points To Acquire property
	ATTACH_PROP(TotalPointsToAcquire);
    
	// This is the TriggerRepeat property
	ATTACH_PROP(TriggerRepeat);
	
	// What follows are the device specific properties
	
	// Need to add entries in privatePropDesc.m in \toolbox\daq\daq\private 
	// for each device specific property
	if (!m_supportsPolledClockOnly)
	{
		// This is the Trigger Type property
		ATTACH_PROP(TriggerType);
		SELECTMYDRIVERLINX(m_driverHandle);
		int Two2Event = (int) pow(2, DIEVENT);
		if (((LDD*)m_ldd)->AnaChan[1].AnEvents.StartEvents[DMA] & Two2Event) 
		{
			pTriggerType->AddMappedEnumValue(TRIGGER_HWDIGITAL, L"HwDigital");
		}

		// This is the Stop Trigger Type property
		CREATE_PROP(StopTriggerType);
		pStopTriggerType->AddMappedEnumValue(STP_TRIGT_NONE, L"None");
		if (((LDD*)m_ldd)->AnaChan[1].AnEvents.StopEvents[DMA] & Two2Event) 
		{
			pStopTriggerType->AddMappedEnumValue(STP_TRIGT_HWDIGITAL, L"HwDigital");
		}
		Two2Event = (int) pow(2, AIEVENT);
		if (((LDD*)m_ldd)->AnaChan[1].AnEvents.StopEvents[DMA] & Two2Event) 
		{
			pStopTriggerType->AddMappedEnumValue(STP_TRIGT_HWANALOG, L"HwAnalog");
		}
		pStopTriggerType.SetDefaultValue(STP_TRIGT_NONE);
		
		// This is the Stop Trigger Condition Property
		CREATE_PROP(StopTriggerCondition);
		pStopTriggerCondition->AddMappedEnumValue(STP_TRIGC_NONE, L"None");
		
		pStopTriggerCondition.SetDefaultValue(STP_TRIGC_NONE);
		
		
		// This is the Stop Trigger Channel property
		//////////////////////////////////////////////////////////////////////////////////////////
		// NOTE - THE PROBLEM IS THAT ACCORDING TO DOCUMENTATION, THE DEFAULT VALUE SHOULD BE []  
		// BUT THE FOLLOWING CODE SETS IT TO 0.													  
		//////////////////////////////////////////////////////////////////////////////////////////	
		CREATE_PROP(StopTriggerChannel);
		long _minstoptriggerchan = 0;
		long _maxstoptriggerchan = ((LDD*)m_ldd)->AnaChan[1].NAnChan;
		pStopTriggerChannel.SetRange(CComVariant(_minstoptriggerchan),CComVariant(_maxstoptriggerchan));
		pStopTriggerChannel.SetDefaultValue(_minstoptriggerchan);
		pStopTriggerChannel = _minstoptriggerchan;
		
		// This is the Stop Trigger Condition Value property
		CREATE_PROP(StopTriggerConditionValue);
		double loVal = ((LDD*)m_ldd)->AnaChan[1].lpAnMinMaxRange->min;
		double hiVal = ((LDD*)m_ldd)->AnaChan[1].lpAnMinMaxRange->max;
		pStopTriggerConditionValue.SetRange(loVal,hiVal);
		pStopTriggerConditionValue.SetDefaultValue(0);
		pStopTriggerConditionValue = 0;
		
		// This is the Stop Trigger Delay property
		CREATE_PROP(StopTriggerDelay);
		pStopTriggerDelay.SetRange(CComVariant(0),CComVariant(INFINITY));
		pStopTriggerDelay.SetDefaultValue(0);
		pStopTriggerDelay = 0;
		
		// This is the Stop Trigger Delay Units property
		CREATE_PROP(StopTriggerDelayUnits);
		pStopTriggerDelayUnits->AddMappedEnumValue(STDU_SECONDS, L"Seconds");
		pStopTriggerDelayUnits->AddMappedEnumValue(STDU_SAMPLES, L"Samples");
		pStopTriggerDelayUnits.SetDefaultValue(STDU_SECONDS);
		
		// This is the Transfer Mode property
		CREATE_PROP(TransferMode);
		SELECTMYDRIVERLINX(m_driverHandle);
		if (DoesDeviceSupportIRQ(m_pSR) == DL_TRUE)
		{
			pTransferMode->AddMappedEnumValue(TRANSFER_INTERRUPTS, L"Interrupts");
			pTransferMode.SetDefaultValue(TRANSFER_INTERRUPTS);
			pTransferMode = TRANSFER_INTERRUPTS;
			m_usingDMA = false;

		}
		if (m_supportsDMA)
		{
			pTransferMode->AddMappedEnumValue(TRANSFER_DMA, L"DMA");
			pTransferMode.SetDefaultValue(TRANSFER_DMA);
			pTransferMode = TRANSFER_DMA;
			m_usingDMA = true;
		}
	}

	/////////////////////////////////////////////////////////////////////////////////////////////////
	// Channel properties																		   //
	/////////////////////////////////////////////////////////////////////////////////////////////////	
	CRemoteProp rp;
	
	// The HwChannel property
	rp.Attach(_EngineChannelList,L"HwChannel",HWCHANNEL);
	CComVariant _maxchanrange;
    _maxchanrange = (long)(((LDD*)m_ldd)->AnaChan[1].NAnChan) - 1;
	rp.SetRange(0L, _maxchanrange);
    rp.Release();
	
	// The Input Range property
	double _mininrangediff, _mininrangesing;
	double _maxinrangediff, _maxinrangesing;
	double InputRange[2];
	CComVariant var, _default;
	GetInputRange(&_mininrangediff, &_maxinrangediff, &_mininrangesing, &_maxinrangesing);
	InputRange[0] = _mininrangediff;
	InputRange[1] = _maxinrangediff;
	CreateSafeVector(InputRange,2,&var);
    rp.Attach(_EngineChannelList,L"inputrange",INPUTRANGE);
    rp->put_DefaultValue(var);
    rp.SetRange(InputRange[0],InputRange[1]);
    rp.Release();
	
	// Native Offset prperty
    rp.Attach(_EngineChannelList,L"NativeOffset",NATIVEOFFSET);
    rp.SetRange(0L, 0L);
	_default = 0.0;
	rp->put_DefaultValue(_default);
	rp->put_Value(_default);
    rp.Release();
	
	// Native Scaling property
	double _minscaling = (_maxinrangesing - _mininrangesing) / 65535;
	double _maxscaling = (_maxinrangediff - _mininrangediff) / 65535;
    rp.Attach(_EngineChannelList,L"NativeScaling",NATIVESCALING);
    rp.SetRange(_minscaling,_maxscaling);
	_default = _maxinrangesing;
	rp.SetDefaultValue(0);
	rp->put_Value(CComVariant(0));
    rp.Release();

	return S_OK;
} // end of Open()


//////////////////////////////////////////////////////////////////////////////////////
// SetProperty()
//
// Called by the engine when a property is set
// An interface to the property along with the new value is passed to the method
//////////////////////////////////////////////////////////////////////////////////////
STDMETHODIMP Ckeithleyain::SetProperty(long User, VARIANT * NewValue)  // return false for fail
{
	if (User)
	{
		// Prevent multiple objects pointing to the same device changing properties while
		// a device is running...
		if (GetParent()->GetDevFromId(analoginputMask + m_deviceID)!=NULL && 
			GetParent()->GetDevFromId(analoginputMask + m_deviceID) !=this)
			return Error(_T("Keithley: The device is in use."));

        CLocalProp* pProp=PROP_FROMUSER(User);
        
		variant_t *val = (variant_t*)NewValue;  // variant_t is a more friendly data type to work with.
		
		// Sample Rate property
		if (User==USER_VAL(pSampleRate))	//	Which properties have changed?
		{
			double newrate = *val;
			if(pClockSource == CLCK_SOFTWARE)
				return CswClockedDevice::SetProperty(User, NewValue);
			
			double newperiod = QuantiseValue(1.0/newrate);
			newrate = 1.0/newperiod;
			CalculateRateAndSkew(newrate, pChannelSkewMode); // Work out if the requested sample rate is valid.
			*val = pSampleRate;
		}
		
		// Channel Skew Mode property
		if (User== USER_VAL(pChannelSkewMode))
		{
			// Has the Channel Skew Mode changed from anything to Manual or from manual to anything?
			// If so, update the Channel Skew property to reflect the changes.
			if((m_supportsBurstMode == TRUE) && (pClockSource != CLCK_SOFTWARE))
			{
				CalculateRateAndSkew(pSampleRate, *val);
			}
			else
				return Error(_T("Keithley: Channel Skew mode cannot be changed. Device does not support burst mode clocking\nor is externally or software clocked."));
		}
		
		// Channel Skew property
		if (User== USER_VAL(pChannelSkew))
		{
			if((m_supportsBurstMode == TRUE) && (pClockSource != CLCK_SOFTWARE))
			{
				double newskew = QuantiseValue(*val);
				if(((newskew * _nChannels) <= pSampleRate))
				{
					pChannelSkewMode = CHAN_SKEW_MANUAL;
					pChannelSkew = newskew;
				}
				else
					return Error(_T("Keithley: Channel Skew * Number of Channels must be smaller than the sample period."));
				
				CalculateRateAndSkew(pSampleRate, pChannelSkewMode);
				*val = pChannelSkew;
			}
			else
				return Error(_T("Keithley: Channel Skew mode cannot be changed. Device does not support burst mode clocking\nor is externally or software clocked."));
		}
		
		// Trigger Type property
		if (User==USER_VAL(pTriggerType))
		{
			// Has Trigger Type been changed to HwDigital? If so, change the Trigger Delay accordingly.
			if ((long)(*val)==TRIGGER_HWDIGITAL)
			{
				pTriggerCondition->ClearEnumValues();
				pTriggerCondition->AddMappedEnumValue(TRIG_COND_RISING, L"Rising");
				pTriggerCondition->AddMappedEnumValue(TRIG_COND_FALLING, L"Falling");
				pTriggerCondition->AddMappedEnumValue(TRIG_COND_GATEHIGH, L"GateHigh");
				pTriggerCondition->AddMappedEnumValue(TRIG_COND_GATELOW, L"GateLow");
				
				// If StopTrigCondition already defined as HwDigital, use that value
				TriggerConditionTypes defaultTrigCond = TRIG_COND_RISING;
				if ((pStopTriggerType==STP_TRIGT_HWDIGITAL) && (pStopTriggerCondition==STP_TRIGC_FALLING))
					defaultTrigCond = TRIG_COND_FALLING;
				pTriggerCondition.SetDefaultValue(defaultTrigCond);
				pTriggerCondition.SetRemote(defaultTrigCond);
				
				if (pTriggerRepeat > 0)
				{
					_engine->WarningMessage(CComBSTR("Keithley: Trigger Repeat is not supported by Hardware Triggers.\n Device will Trigger Once."));
					pTriggerRepeat = 0;
				}
				pTriggerRepeat.SetRange(CComVariant(0), CComVariant(0));

				// Disable HwAnalog Stop trigger.
				bool resetValue = (pStopTriggerType==STP_TRIGT_HWANALOG);
				pStopTriggerType->ClearEnumValues();
				pStopTriggerType->AddMappedEnumValue(STP_TRIGT_NONE, L"None");
				pStopTriggerType->AddMappedEnumValue(STP_TRIGT_HWDIGITAL, L"HwDigital");
				if (resetValue)
					pStopTriggerType.SetRemote(STP_TRIGT_NONE);
			} 
			else
			{
				/////////////////////////////////////////////////////////////////////////////////////////////////
				// NOTE - WE ARE NOT SURE WHY MATHWORKS HAS USED THESE VALUES AS DEFAULTS OR HOW TO GET THEM   //
				//  BACK ONCE WE HAVE CHANGED THEM, SO WE HAVE HARDCODED THEM. THIS NEEDS TO BE QUERIED.       //
				/////////////////////////////////////////////////////////////////////////////////////////////////	
				double _mintriggerdelay = -2147483;
				double _maxtriggerdelay = 2147483;
				double _defaulttriggerdelay = 0;
				pTriggerDelay.SetRange(_mintriggerdelay,_maxtriggerdelay);
				pTriggerDelay.SetDefaultValue(_defaulttriggerdelay);
				pTriggerCondition->ClearEnumValues();
				pTriggerCondition->AddMappedEnumValue(TRIG_COND_NONE, L"None");
				pTriggerCondition.SetDefaultValue(TRIG_COND_NONE);
				pTriggerRepeat.SetRange(CComVariant(0), CComVariant(INFINITY));
				pStopTriggerType->ClearEnumValues();
				pStopTriggerType->AddMappedEnumValue(STP_TRIGT_NONE, L"None");
				int Two2Event = (int) pow(2, DIEVENT);
				if (((LDD*)m_ldd)->AnaChan[1].AnEvents.StopEvents[DMA] & Two2Event) 
				{
					pStopTriggerType->AddMappedEnumValue(STP_TRIGT_HWDIGITAL, L"HwDigital");
				}
				Two2Event = (int) pow(2, AIEVENT);
				if (((LDD*)m_ldd)->AnaChan[1].AnEvents.StopEvents[DMA] & Two2Event) 
				{
					pStopTriggerType->AddMappedEnumValue(STP_TRIGT_HWANALOG, L"HwAnalog");
				}
			}
		}
		
		// Trigger Condition property
		if (User==USER_VAL(pTriggerCondition))
		{
			// Stop Triggers are not supported with gating.
			// If the user wants to use Gating, then remove the stop triggers.
			if(((long)(*val) == TRIG_COND_GATEHIGH) || ((long)(*val) == TRIG_COND_GATELOW))
			{
				if (pStopTriggerType != STP_TRIGT_NONE) // If they have already added a stop trigger, warn them and remove.
					_engine->WarningMessage(CComBSTR("Keithley: Stop Triggering not supported when Gating is Active. Stop Trigger will be Disabled."));
				
				// Remove Stop Trigger Types
				pStopTriggerType = STP_TRIGT_NONE;
				pStopTriggerType->ClearEnumValues();
				pStopTriggerType->AddMappedEnumValue(STP_TRIGT_NONE, L"None");
				pStopTriggerType.SetDefaultValue(STP_TRIGT_NONE);
				
				// Remove Stop Trigger Conditions
				pStopTriggerCondition = STP_TRIGC_NONE;
				pStopTriggerCondition->ClearEnumValues();
				pStopTriggerCondition->AddMappedEnumValue(STP_TRIGC_NONE, L"None");
				pStopTriggerCondition.SetDefaultValue(STP_TRIGC_NONE);
			}
			else
			{
				// If the user is changing from a Gating Condition, Put the Stop Triggers back.
				pStopTriggerType->AddMappedEnumValue(STP_TRIGT_NONE, L"None");
				int Two2Event = (int) pow(2, DIEVENT);
				if (((LDD*)m_ldd)->AnaChan[1].AnEvents.StopEvents[DMA] & Two2Event) 
				{
					pStopTriggerType->AddMappedEnumValue(STP_TRIGT_HWDIGITAL, L"HwDigital");
				}
				Two2Event = (int) pow(2, AIEVENT);
				if (((LDD*)m_ldd)->AnaChan[1].AnEvents.StopEvents[DMA] & Two2Event) 
				{
					pStopTriggerType->AddMappedEnumValue(STP_TRIGT_HWANALOG, L"HwAnalog");
				}
				pStopTriggerType.SetDefaultValue(STP_TRIGT_NONE);
			}
			
			if(pTriggerType == TRIGGER_HWDIGITAL)
			{
				switch((long)(*val))
				{
				case TRIG_COND_RISING :
					if(pStopTriggerType == STP_TRIGT_HWDIGITAL)
					{
						if (pStopTriggerCondition != STP_TRIGC_RISING)
						{
							_engine->WarningMessage(CComBSTR("Keithley: Digital Start and Stop Triggers must be the same. Setting Digital Stop Trigger to 'Rising'."));
							pStopTriggerCondition = STP_TRIGC_RISING;
						}
					}
					break;
				case TRIG_COND_FALLING:
					if(pStopTriggerType == STP_TRIGT_HWDIGITAL)
					{
						if (pStopTriggerCondition != STP_TRIGC_FALLING)
						{
							_engine->WarningMessage(CComBSTR("Keithley: Digital Start and Stop Triggers must be the same. Setting Digital Stop Trigger to 'Falling'."));
							pStopTriggerCondition = STP_TRIGC_FALLING;
						}
					}
					break;
				}
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
					_engine->WarningMessage(CComBSTR("Keithley: Negative trigger delay is invalid for Digital Triggers."));
				}
				*val = pTriggerDelay;
			}
		}
		
		// Stop Trigger Type property
		if (User==USER_VAL(pStopTriggerType))
		{
			if ((long)*val == STP_TRIGT_HWDIGITAL)
			{
				pStopTriggerCondition->ClearEnumValues();
				pStopTriggerCondition->AddMappedEnumValue(STP_TRIGC_RISING, L"Rising");
				pStopTriggerCondition->AddMappedEnumValue(STP_TRIGC_FALLING, L"Falling");
				// If TrigCondition already defined as HwDigital, use that value
				StopTriggerConditionTypes defaultStopTrigCond = STP_TRIGC_RISING;
				if ((pTriggerType==TRIGGER_HWDIGITAL) && (pTriggerCondition==TRIG_COND_FALLING))
					defaultStopTrigCond = STP_TRIGC_FALLING;
				pStopTriggerCondition.SetDefaultValue(defaultStopTrigCond);
				pStopTriggerCondition=defaultStopTrigCond;

				if (pSamplesPerTrigger != INFINITY)
				{
					pSamplesPerTrigger = INFINITY;
				}
			} 
			else if ((long)*val == STP_TRIGT_HWANALOG)
			{
				if (m_supportsDMA && m_usingDMA)
				{
					pStopTriggerCondition->ClearEnumValues();
					pStopTriggerCondition->AddMappedEnumValue(STP_TRIGC_RISING, L"Rising");
					pStopTriggerCondition->AddMappedEnumValue(STP_TRIGC_FALLING, L"Falling");
					
					pStopTriggerCondition.SetDefaultValue(STP_TRIGC_RISING);
					pStopTriggerCondition=STP_TRIGC_RISING;
				}
				else
				{
					if (!(m_usingDMA) && m_supportsDMA)
					{
						return Error(_T("Keithley: Analog Stop Triggers are only supported with a DMA Transfer Mode."));
					}
					
					return Error(_T("Keithley: This device does not Support DMA Transfers, so Analog Stop Triggering can not be used."));
				}

				if (pSamplesPerTrigger != INFINITY)
					pSamplesPerTrigger = INFINITY;
			} 
			else
			{
				pStopTriggerCondition->ClearEnumValues();
				pStopTriggerCondition->AddMappedEnumValue(STP_TRIGC_NONE, L"None");
				pStopTriggerCondition.SetDefaultValue(STP_TRIGC_NONE);
				pStopTriggerCondition=STP_TRIGC_NONE;

				if (pSamplesPerTrigger == INFINITY)
				{
					pSamplesPerTrigger = pSampleRate;
					_engine->WarningMessage(CComBSTR("Keithley: Setting analogInput object to acquire 1 second of data."));
				}
			}
		}
		
		// Stop Trigger Condition property		
		if (User==USER_VAL(pStopTriggerCondition))
		{
			// Need to check the STType because our enums overlap!
			if( pStopTriggerType == STP_TRIGT_HWDIGITAL)
			{
				if((long)(*val) == STP_TRIGC_RISING)
				{
					if(pTriggerType == TRIGGER_HWDIGITAL)
					{
						if (pTriggerCondition != TRIG_COND_RISING)
						{
							_engine->WarningMessage(CComBSTR("Keithley: Digital Start and Stop Triggers must be the same. Setting Digital Start Trigger to 'Rising'."));
							pTriggerCondition = TRIG_COND_RISING;
						}
					}
				}
				else // ((long)(*val) == STP_TRIGC_FALLING)
				{
					if(pTriggerType == TRIGGER_HWDIGITAL)
					{
						if (pTriggerCondition != TRIG_COND_FALLING)
						{
							_engine->WarningMessage(CComBSTR("Keithley: Digital Start and Stop Triggers must be the same. Setting Digital Start Trigger to 'Falling'."));
							pTriggerCondition = TRIG_COND_FALLING;
						}
					}
				}
			}
			else if(pStopTriggerType == STP_TRIGT_HWANALOG)
			{
				double lo=-10.0;
				double hi=10.0;
				// Attempt to set valid range for StopTriggerConditionValue
				CComPtr<IProp> pProp;
				HRESULT hr =GetProperty(L"StopTriggerConditionValue", &pProp);
				if (FAILED(hr)) return hr;	                           
				pProp->SetRange(&CComVariant(lo), &CComVariant(hi));	    
			}
		}
		
		// Stop Trigger Delay Units property
		if (User == USER_VAL(pStopTriggerDelayUnits))
		{
			if ((long)*val == STDU_SECONDS)
			{
				pStopTriggerDelay = (pStopTriggerDelay / pSampleRate);
			} 
			else	// tics
			{
				pStopTriggerDelay = ceil(pStopTriggerDelay * pSampleRate);
			}
		}

		// Stop Trigger Delay property
		// Prevent fractional numbers of samples!
		if (User == USER_VAL(pStopTriggerDelay))
		{
			if (pStopTriggerDelayUnits == STDU_SAMPLES)
			{
				double origVal = (double) *val;
				*val = (double) ceil(origVal);
			}
		}
		
		// Input Type property
		if (User == USER_VAL(pInputType))
		{
			// Convert DAQ property value to DriverLINX gain code and remove all created channels.
			// Borrowed from mwnidaq:
			CComPtr<IProp> pProp;
			HRESULT hr =GetChannelProperty(L"HwChannel", &pProp);
			if (FAILED(hr)) return hr;	   
			
			if ((long)*val==IN_DIFFERENTIAL)
			{
				// delete all channels? Must check each channel ID!!!
				for(int k=0 ; k<_nChannels; k++)
				{
					if (_chanList[k] > m_maxValidDIChan)
					{
						_engine->WarningMessage(CComBSTR("Keithley: Deleting existing channels because of input type change."));
						_EngineChannelList->DeleteAllChannels();
					}
				}
				
				m_termination = CHAN_SEDIFF_DIFF;
				
				hr=pProp->SetRange(&CComVariant(0L),&CComVariant(m_maxValidDIChan));
				if (FAILED(hr)) return hr;	   
			}
			else
			{
				m_termination = CHAN_SEDIFF_SE;
				hr=pProp->SetRange(&CComVariant(0L),&CComVariant(m_maxValidSEChan));
				if (FAILED(hr)) return hr;
			}
			_updateChildren=false;
		}
		
		// Transfer Mode property
		if (User == USER_VAL(pTransferMode))
		{
			if((long)(*val) == TRANSFER_DMA)
			{
				if(!(m_supportsDMA))
				{
					return Error(_T("Keithley: This device does not support DMA Transfers."));
				}
				m_usingDMA = true;
			}
			else
			{
				m_usingDMA = false;
			}
		}

		// Clock Source property
		if (User == USER_VAL(pClockSource))
		{
			long newval = (long)(*val);
			if((long)(*val) == CLCK_SOFTWARE)
			{
				// First Set the min and max samplerates for software clocking
				pSampleRate.SetDefaultValue(CComVariant(100));
				pSampleRate = 100;
				pSampleRate.SetRange(CComVariant((double)MIN_SW_SAMPLERATE),CComVariant((double)MAX_SW_SAMPLERATE));
				
				// Then set up the samples per trigger to give us 1s acquisition
				pSamplesPerTrigger->put_DefaultValue(CComVariant(100));
				pSamplesPerTrigger = 100;
				EnableSwClocking();
				
				// Now Remove Stop Triggers
				if(pStopTriggerType != STP_TRIGT_NONE)
					_engine->WarningMessage(CComBSTR("Keithley: Stop Triggers are not valid for Software Clocking.\nStop Triggers will be removed."));
				pStopTriggerType->ClearEnumValues();
				pStopTriggerType->AddMappedEnumValue(STP_TRIGT_NONE, L"None");
				pStopTriggerType = STP_TRIGT_NONE;
				pStopTriggerCondition->ClearEnumValues();
				pStopTriggerCondition->AddMappedEnumValue(STP_TRIGC_NONE, L"None");
				
				// Remove Digital Start Triggers
				if(pTriggerType == TRIGGER_HWDIGITAL)
					_engine->WarningMessage(CComBSTR("Keithley: Digital Triggers are not supported in Software Clocked mode.\nDigital trigger will be removed."));
				pTriggerType = TRIGGER_IMMEDIATE;
				pTriggerType->RemoveEnumValue(CComVariant(TRIGGER_HWDIGITAL));
				pChannelSkewMode = CHAN_SKEW_EQUISAMPLE;
			}
			else
			{
				// Re-set the Sample Rates
				m_aiTicPeriod = static_cast<float>(CalculateMicroSec());
				pSampleRate.SetDefaultValue(CComVariant(1000));
				pSampleRate.SetRange(CComVariant(m_minBoardSampleRate), CComVariant(m_maxBoardSampleRate));
				RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"minsamplerate", CComVariant(m_minBoardSampleRate)));	
				RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"maxsamplerate", CComVariant(m_maxBoardSampleRate)));	
				
				// Then set up the samples per trigger to give us 1s acquisition
				pSamplesPerTrigger->put_DefaultValue(CComVariant(1000));
				pSamplesPerTrigger = 1000;
				
				// Then re-insert the Stop Triggers
				pStopTriggerType->ClearEnumValues();
				pStopTriggerType->AddMappedEnumValue(STP_TRIGT_NONE, L"None");
				int Two2Event = (int) pow(2, DIEVENT);
				if (((LDD*)m_ldd)->AnaChan[1].AnEvents.StopEvents[DMA] & Two2Event) 
				{
					pStopTriggerType->AddMappedEnumValue(STP_TRIGT_HWDIGITAL, L"HwDigital");
				}
				Two2Event = (int) pow(2, AIEVENT);
				if (((LDD*)m_ldd)->AnaChan[1].AnEvents.StopEvents[DMA] & Two2Event) 
				{
					pStopTriggerType->AddMappedEnumValue(STP_TRIGT_HWANALOG, L"HwAnalog");
				}
				pStopTriggerType.SetDefaultValue(STP_TRIGT_NONE);
				
				// and the digital start triggers
				pTriggerType->AddMappedEnumValue(TRIGGER_HWDIGITAL, L"HwDigital");
				
				// then change the channelskew mode to minimum
				CalculateRateAndSkew(1000, CHAN_SKEW_MIN);
				
				// Now re-set the service request so that it does not error.
				delete m_pSR;
				m_pSR = (DL_ServiceRequest *) new DL_ServiceRequest;
				
				if (m_pSR != NULL)
				{
					memset(m_pSR, 0, sizeof(DL_ServiceRequest));
				}

				//Set the size of the service request
				m_pSR->dwSize = sizeof(DL_ServiceRequest);
				m_pSR->device = m_deviceID;		// Device ID
				m_pSR->subsystem = AI;			// Analog input subsystem
				m_pSR->hWnd = GetParent()->GetHandle();
			}
		}
		
        // Finally, set the actual value
        pProp->SetLocal(*val);
	}
    return S_OK;
}

////////////////////////////////////////////////////////////////////////////////
// SetChannelProperty()
//
// Called by the engine when a channel property is set
// An interface to the property, the new value and as a link to the channel are passed 
// to the method
////////////////////////////////////////////////////////////////////////////////
STDMETHODIMP Ckeithleyain::SetChannelProperty(long UserVal, tagNESTABLEPROP * pChan, VARIANT * NewValue)
{
    int Index=pChan->Index-1;  // we use 0 based index
	variant_t& vtNewValue=reinterpret_cast<variant_t&>(*NewValue);
	
	// Input Range property
	if(UserVal == INPUTRANGE)
	{
		TSafeArrayAccess<double> NewRange(NewValue);
		RANGE_INFO *NewInfo;
		RETURN_HRESULT(FindRange(NewRange[0],NewRange[1],NewInfo));
		if (m_chanGain[Index]!=NewInfo->gain)
		{
			if (m_validRanges.size()<=1)
			{
				return(Error(_T("Keithley: Device is not software range configurable.  Please set your range with DriverLINX Configuration Panel.")));
			}
			
			// Check the polarity: If changed, set ALL to new polarity
			short l_polarity = (NewInfo->minVal < 0) ? POLARITY_BIPOLAR : POLARITY_UNIPOLAR;
			if (l_polarity !=m_polarity)
			{
				if (_nChannels>1)
					_engine->WarningMessage(CComBSTR("Keithley: All channels configured to have the same polarity."));
				SetAllPolarities(l_polarity);
			}
			m_chanGain[Index]=NewInfo->gain;
		}
		NewRange[0]=NewInfo->minVal;
		NewRange[1]=NewInfo->maxVal;
		_updateChildren = true;
	}
	_updateChildren=true;
    return S_OK;
}


////////////////////////////////////////////////////////////////////////////
// SetAllPolarities()
// 
// This method changes all polarities of all channels to be the same.
// This function should be removed if (when) the engine supports mixed
// polarities.
////////////////////////////////////////////////////////////////////////////
void Ckeithleyain::SetAllPolarities(short polarity)
{
    NESTABLEPROP *chan;
    AICHANNEL *pchan;
	
    // Start by setting the native data type for the subsystem
    if (polarity==POLARITY_UNIPOLAR)
    {
		_DaqHwInfo->put_MemberValue(CComBSTR(L"nativedatatype"), CComVariant(VT_UI2));	
    }
    else
	{
        _DaqHwInfo->put_MemberValue(CComBSTR(L"nativedatatype"), CComVariant(VT_I2));
	}
	
	// Now change the channel ranges if necessary
	// Algorithm: Regardless of what happens, set the minimum value of each channel to:
	//		0 if polarity is POLARITY_UNIPOLAR
	//		-max(chan_num) if polarity is POLARITY_BIPOLAR
	//	and keep a check to see whether anything has changed, to warn the user.
	// ASSUMPTION: All boards which support UNI and POLARITY_BIPOLAR do so symmetrically
	//    That is, if a rnge [-x x] is supported, then so is [0 x]
	for (int i=0; i<_nChannels; i++) 
    {	    
		_EngineChannelList->GetChannelStructLocal(i, &chan);
		if (chan==NULL) break;
		pchan=(AICHANNEL*)chan;
		
        if (polarity==POLARITY_BIPOLAR)
		{
			pchan->VoltRange[0] = -pchan->VoltRange[1];
			pchan->ConversionOffset= 0;
			
			// Now convert the internal gain: -ve for POLARITY_BIPOLAR, +ve for POLARITY_UNIPOLAR
			m_chanGain[i] = -abs(m_chanGain[i]);
		}
		else
		{
			pchan->VoltRange[0] = 0;
			pchan->ConversionOffset = 1<<((((LDD*)m_ldd)->AnaChan[1].AnBits)-1);
			
			// Now convert the internal gain: -ve for POLARITY_BIPOLAR, +ve for POLARITY_UNIPOLAR
			m_chanGain[i] = abs(m_chanGain[i]);
		}
    }
	// Store the current polarity
	m_polarity = polarity;
	
	// Deal with the default input range:
    CComPtr<IProp> prop;
    CComVariant val;
	HRESULT hRes =GetChannelProperty(L"InputRange", &prop);
	VARIANT oldVal;
	prop->get_DefaultValue(&oldVal);
    double VoltRange[2];
	double mindiff, maxdiff, minsing, maxsing;
	GetInputRange(&mindiff, &maxdiff, &minsing, &maxsing);
	VoltRange[0] = (polarity==POLARITY_UNIPOLAR) ? minsing: mindiff;
	VoltRange[1] = (polarity==POLARITY_UNIPOLAR) ? maxsing: maxdiff;
    CreateSafeVector(VoltRange,2,&val);
    hRes = prop->put_DefaultValue(val);
    prop.Release();
}


///////////////////////////////////////////////////////////////////
// GetSingleValue()
//
// Called to get samples using software clocking.
///////////////////////////////////////////////////////////////////
HRESULT Ckeithleyain::GetSingleValue(int chan, RawDataType* value)
{
	WORD ResultCode;
	if (!m_isInitialized)
	{
		SELECTMYDRIVERLINX(m_driverHandle);
		RETURN_CODE(InitializeDriverLINXSubsystem(m_pSR, &ResultCode));
		if (ResultCode != 0)
		{
			char tempMsg[255];
			ReturnMessageString(NULL, ResultCode,tempMsg, 255 );
			return CComCoClass<ImwDevice>::Error(tempMsg);
		}
		m_isInitialized = true;
	}
	SELECTMYDRIVERLINX(m_driverHandle);	
	SetupDriverLINXSingleValueIO(m_pSR,chan, m_chanGain[chan], SYNC);
	SELECTMYDRIVERLINX(m_driverHandle);
	DriverLINX(m_pSR);
	if (m_pSR->result != 0)
	{
		return CComCoClass<ImwDevice>::Error(TranslateResultCode(m_pSR->result));
	}
	SELECTMYDRIVERLINX(m_driverHandle);
	GetDriverLINXAIData(m_pSR, (unsigned short*)value ,0,1,1);
	return S_OK;
}


////////////////////////////////////////////////////////////////////////////
/// GetSingleValues()
//
// This function gets a single data point from each of the A/D channels
// specified. The function is called by the engine in response to the ML 
// user command GETSAMPLE (provided software clocking is not specified)
/////////////////////////////////////////////////////////////////////////////
HRESULT Ckeithleyain::GetSingleValues(VARIANT * Values)
{
	ERRORCODES Code;
	WORD ResultCode;
	CComBSTR _error;
    TSafeArrayVector <unsigned short> binarray;    
    binarray.Allocate(_nChannels);
	UpdateChans(true);

	// Reset the flags for our service request:
	m_pSR->taskFlags = 0;
	
	// Only initialize the subsystem if this is not already done
	if (!m_isInitialized)
	{
		SELECTMYDRIVERLINX(m_driverHandle);
		RETURN_CODE(InitializeDriverLINXSubsystem(m_pSR, &ResultCode));
		if (ResultCode != 0)
		{
			char tempMsg[255];
			ReturnMessageString(NULL, ResultCode,tempMsg, 255 );
			return CComCoClass<ImwDevice>::Error(tempMsg);
		}
		m_isInitialized = true;
	}
	
	// Set up a single Service Request with ALL channels
	// Service Request Group
	SELECTMYDRIVERLINX(m_driverHandle);
	RETURN_CODE(AddRequestGroupStart(m_pSR, SYNC));
	
	// Event Group
	SELECTMYDRIVERLINX(m_driverHandle);
	AddTimingEventNullEvent(m_pSR);
	// Start event
	SELECTMYDRIVERLINX(m_driverHandle);
	AddStartEventOnCommand(m_pSR);
	// Stop event
	SELECTMYDRIVERLINX(m_driverHandle);
	AddStopEventOnTerminalCount(m_pSR);
	// Channel Group
	SELECTMYDRIVERLINX(m_driverHandle);

	//Only KPCI-3100 series have Termination mode
	char deviceName[25] = "";
	char tempstr[] = "KPCI-31";
	::ReturnMessageString(NULL, ((LDD*)m_ldd)->DevCap.ModelCode, (LPSTR)deviceName, 25); // the vendor
	if(_strnicmp( deviceName, tempstr, 7)!=0) 
	    m_termination = CHAN_SEDIFF_DEFAULT;

	AddChannelGainList(m_pSR, _nChannels, &_chanList[0], &m_chanGain[0], m_termination);
	// Buffers Group
	SELECTMYDRIVERLINX(m_driverHandle);
	AddSelectBuffers(m_pSR, 1, 1, _nChannels);
	// Flags
	m_pSR->taskFlags = (NO_SERVICESTART | NO_SERVICEDONE);
	
	SELECTMYDRIVERLINX(m_driverHandle);
	DriverLINX(m_pSR);
	m_pSR->taskFlags = 0; //Reset them immediately!

	if (m_pSR->result != 0)
	{
		char tempMsg[255];
		ReturnMessageString(NULL, m_pSR->result,tempMsg, 255 );
		return CComCoClass<ImwDevice>::Error(tempMsg);
	}

	// Now convert the values read in from the card to the native data type and pass
	// pointer to buffer
	SELECTMYDRIVERLINX(m_driverHandle);
	Code = GetDriverLINXAIData(m_pSR, &binarray[0], 0, _nChannels, 1);
	
	if (Code != DL_TRUE)
	{
		// Must cast to USHORT for CComBSTR::LoadString to work
		_error.LoadString((USHORT)InterpretDriverLINXError(Code)); 
		return CComCoClass<ImwDevice>::Error(_error);
	}
    return binarray.Detach(Values);
}


/////////////////////////////////////////////////////////////////////////////
// InterfaceSupportsErrorInfo()
//
// Function indicates whether or not an interface supports the IErrorInfo..
//..interface. It is created by the wizard.
// Function is NOT MODIFIED by the adaptor programmer.
/////////////////////////////////////////////////////////////////////////////
STDMETHODIMP Ckeithleyain::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IKeithleyAIn
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
} // end of InterfaceSupportsErrorInfo()


/////////////////////////////////////////////////////////////////////////////
// SetDaqHwInfo()
//
// Sets the fields needed for DaqHwInfo. Is used when you call 
// daqhwinfo(analoginput('keithley'))
/////////////////////////////////////////////////////////////////////////////
HRESULT Ckeithleyain::SetDaqHwInfo()
{
	LoadRangeInfo(); // Load up our input range info.
	
	//Now we start setting the adaptor values.
	//Adaptor Name
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"adaptorname"), 
		CComVariant(Ckeithleyadapt::ConstructorName)));
	
	//Bits
	float bits;
	bits = (float) ((LDD*)m_ldd)->AnaChan[1].AnBits; // Get the number of bits from the LDD
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"bits"), CComVariant( bits )));
	
	//Coupling - This is hardcoded because none of the keithley boards support anything else.
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"coupling"), CComVariant(L"DC Coupled")));
	
	// Device Name - The device name is made up of three things:
	char tempstr[15] = "";
	char devname[25] = "";
	::ReturnMessageString(NULL, ((LDD*)m_ldd)->DevCap.ModelCode, (LPSTR)tempstr, 15); // the vendor
	// model code	
	strcat(devname, tempstr);
	sprintf(tempstr, " (Device %d)", m_deviceID); // The words (Device x) hardcoded and the 
	strcat(devname, tempstr);					// number of the device in place of x.

	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"devicename"), CComVariant( devname )));
	
	// Differential IDs
	CComVariant vids;	// Set up a variant to store the values in.
    CreateSafeVector((short*)NULL, (m_maxValidDIChan+1) ,&vids);	// Create a SafeVector
    TSafeArrayAccess<short> difids(&vids);		// and an array to store the ids in, the size is calculated
	// by the number of channels divided by 2.
	for (int i=0; i < (m_maxValidDIChan+1); i++)	// loop through and create the values
    {
        difids[i]=i;
    }
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"differentialids"),vids));
	
    // Gains  -- obtain all gains including positive and negative ones
      SAFEARRAY * psArr = SafeArrayCreateVector(VT_R8, 0, (m_numgains)); // Create a Safe Array vector

  
    if (psArr==NULL) 
		throw "Failure to create SafeArray.";
	CComVariant val;	// Create and set a variant to store the values
    val.parray=psArr;
    val.vt = VT_ARRAY | VT_R8;
	
    double *Gains;		// Create a pointer to the list of gains
    HRESULT hr = SafeArrayAccessData(psArr, (void **) &Gains);	// Set the SafeArray Data to the 
    if (FAILED (hr))											//pointer for the gains
    {
        SafeArrayDestroy (psArr);
        throw "Failure to access SafeArray data.";
    }       
	
    int _num=0;
    // Iterate through the m_validRanges and load the Gains into Matlab
    // Show all positive and negative gains in daqhwinfo
    for(RangeList_t::iterator rIt=m_validRanges.begin();rIt!=m_validRanges.end();rIt++)
    {
        // Get the Gains and place them in the array.
        Gains[_num] = (double)(*rIt).gain;
        _num++;
    }

    SafeArrayUnaccessData (psArr);
    RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"gains"), val));
	
    // Device ID
    wchar_t idStr2[10];
    swprintf(idStr2, L"%d", m_deviceID );	// Convert the Device id to a string
    RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"id"), CComVariant(idStr2)));		
	
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
    //  [0   .5]
	
	// The SAFEARRAYBOUND is used to create a multi dimensional array    
	SAFEARRAYBOUND rgsabound[2];  //the number of dimensions
    rgsabound[0].lLbound = 0;
    rgsabound[0].cElements = m_numgains; // bipolar and unipolar - size of dimension 1
    rgsabound[1].lLbound = 0;
    rgsabound[1].cElements = 2;     // upper and lower range values - size of dimension 2
	
    SAFEARRAY *ps = SafeArrayCreate(VT_R8, 2, rgsabound); //use the SafeArrayBound to create the array
    if (ps==NULL) 
		throw "Failure to create SafeArray.";
	
	CComVariant vinrange; // setup our variant
    vinrange.parray=ps;
    vinrange.vt = VT_ARRAY | VT_R8;
    double *inRange, *min, *max; // The variable used to get the input range values
    hr = SafeArrayAccessData(ps, (void **) &inRange);
    if (FAILED (hr)) 
    {
        SafeArrayDestroy (ps);
        throw "Failure to access SafeArray data.";
    }       
	min = inRange;
	max = inRange+m_numgains;
	
	// Iterate through the validRanges, and transfer the Input Ranges.
	for(rIt=m_validRanges.begin();rIt!=m_validRanges.end();rIt++)
	{
		*min++ = (*rIt).minVal;
		*max++ = (*rIt).maxVal;
	}
    SafeArrayUnaccessData (ps);
    RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"inputranges"), vinrange));
	
	//Sample Rate Limits
	double maxSampleRate;
	double minSampleRate;
	if (!m_supportsPolledClockOnly)
	{
		maxSampleRate = m_maxBoardSampleRate;
		minSampleRate = m_minBoardSampleRate;
	}
	else
	{
		maxSampleRate = (double)MAX_SW_SAMPLERATE;
		minSampleRate = (double)MIN_SW_SAMPLERATE;
	}
	
    RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"maxsamplerate"), CComVariant(maxSampleRate)));
    RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"minsamplerate"), CComVariant(minSampleRate)));
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"nativedatatype"), CComVariant(VT_I2)));	
    
	// Polarity
	if (m_supportsUnipolar && m_supportsBipolar)		// Do we support Bipolar and unipolar?
	{
        SAFEARRAY *ps = SafeArrayCreateVector(VT_BSTR, 0, 2); // Create the array for our strings
        if (ps==NULL) 
			throw "Failure to create SafeArray.";
		
        val.Clear();	// Clear the variant
        // set the data type and values
        V_VT(&val)=VT_ARRAY | VT_BSTR;
        V_ARRAY(&val)=ps;
        CComBSTR *polarities; // create the pointer to the data string
		HRESULT    hRes = SafeArrayAccessData (ps, (void **) &polarities);	// Connect it to the safe array
        if (FAILED (hRes)) 
        {
            SafeArrayDestroy (ps);
			throw "Failure to access SafeArray data.";
        }
        
        polarities[0]=L"Unipolar";	// Set the data string values
        polarities[1]=L"Bipolar";
        
		RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"polarity"), val));
		
		SafeArrayUnaccessData (ps);
        val.Clear();    
	}
	else if(m_supportsBipolar)	// Just bipolar
	       RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"polarity"), CComVariant(L"Bipolar")))
		   
		   else if(m_supportsUnipolar)	// Just unipolar
		   RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"polarity"), CComVariant(L"Unipolar")));
	
	// Sample Type - This value is hardcoded cause all of the keithley boards only support scanning.
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"sampletype"),CComVariant(0L)));
	
	// Single ended ID's
	CComVariant vsingids;// same as the differential ids
    CreateSafeVector((short*)NULL, (m_maxValidSEChan+1), &vsingids);
    TSafeArrayAccess<short> singids(&vsingids);
    for ( i=0; i< (m_maxValidSEChan+1); i++)
    {
        singids[i]=i;
    }
	
    RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"singleendedids"), vsingids));
	
	// Total channels
	WORD numchannels; // the total number of channels
	numchannels = ((LDD*)m_ldd)->AnaChan[1].NAnChan; // Get the value from the LDD
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"totalchannels"),CComVariant(numchannels)));
	
	// Vendor Driver Description
	char driverdescrip[30]; // The place to store the driver description
	// This call gets the value which corresponds to the description, and converts it to a string
	::ReturnMessageString(NULL, ((LDD*)m_ldd)->DevCap.VendorCode, (LPSTR)driverdescrip, 30);
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"vendordriverdescription"),CComVariant(driverdescrip)));
	
	//Vendor Driver Version
	//The following code does not work (always returns 0) due to a Keithley bug 
/*
	WORD minmaxver;		// A WORD that contains the major version in the high byte and the minor
						// version in the low byte
	BYTE minver, maxver;	// Place holders for the major and minor versions
	char driverver[10];

	minmaxver = ((LDD*)m_ldd)->DriverVersion;	// Get the version
	minver = minmaxver & 0x00FF;			// Mask off the high bits
	maxver = (minmaxver & 0xFF00) >> 8;		// Mask off the low bits and shift right to get the value
	sprintf(driverver, "%d.%d", maxver, minver); // Create a version string x.y

	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"vendordriverversion"),CComVariant(driverver)));

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





////////////////////////////////////////////////////////////////////////////////////
// GetParent()
//
//	This function returns this objects pointer to its parent class.
////////////////////////////////////////////////////////////////////////////////////
MessageWindow * Ckeithleyain::GetParent()
{
	return m_pParent;
}


////////////////////////////////////////////////////////////////////////////////////
// GetInputRange
//
// Returns the Input ranges for the card
// The first parameter: The minimum differential value.
// The second parameter: The maximum differential value.
// The third parameter: The minimum single ended value.
// the fourth parameter: The maximum single ended value.
//////////////////////////////////////////////////////////////////////////////////////
void Ckeithleyain::GetInputRange(double *mindiff, double *maxdiff, double *minsing, double *maxsing)
{
	double mintemp = 0;
	double maxtemp = 0;
	
	// Calculate the differential values:
	// Set the initial minimum and maximum values
	mintemp = m_validRanges[0].minVal;
	maxtemp = m_validRanges[0].minVal;
	
	// Loop through the Gain table, checking the initial minimum and maximum values against
	// those in the table. If the minimum is bigger then the new value is the minimum. Similarly
	// for the maximum.
	for (RangeList_t::iterator i=m_validRanges.begin();i!=m_validRanges.end();i++)
    {
		if (mintemp > ((*i).minVal))
			mintemp = (*i).minVal;
		
		if (maxtemp < ((*i).maxVal))
			maxtemp = (*i).maxVal;
		
    }
	*mindiff = mintemp;
	*maxdiff = maxtemp;
	
	// Calculate the Single ended values:
	// Set the initial minimum and maximum values
	mintemp = abs(m_validRanges[0].minVal);
	maxtemp = abs(m_validRanges[0].maxVal);
	double temp;

	// Do the same as for the differential, but use the absolute value of the values.
	for (i = m_validRanges.begin(); i != m_validRanges.end() ;i++)
    {
		if (((*i).minVal) < 0)
			temp = -1 * (*i).minVal;
		else
			temp = (*i).minVal;
		if (mintemp > temp )
			mintemp = temp;
		if (((*i).maxVal) < 0)
			temp = -1 * (*i).maxVal;
		else
			temp = (*i).maxVal;
		if (maxtemp > temp)
			maxtemp = temp;
    }
	*minsing = mintemp;
	*maxsing = maxtemp;
}	


////////////////////////////////////////////////////////////////////////////////////
// UpdateChans()
//
// This function is overloaded. It updates the local channel list and channel
// range variables with the current values.
////////////////////////////////////////////////////////////////////////////////////
HRESULT Ckeithleyain::UpdateChans(bool ForStart)
{
    _chanList.resize(_nChannels);
    m_chanGain.resize(_nChannels);
	AICHANNEL *aichan=NULL;
	for (int i=0; i<_nChannels; i++) 
	{    
		_EngineChannelList->GetChannelStructLocal(i, (NESTABLEPROP**)&aichan);
		_chanList[i]=aichan->Nestable.HwChan;
		RANGE_INFO *NewInfo;
		RETURN_HRESULT(FindRange(aichan->VoltRange[0],aichan->VoltRange[1],NewInfo));
		m_chanGain[i]=NewInfo->gain;
		aichan->ConversionOffset=(m_polarity==POLARITY_BIPOLAR) ? 0 : 1<<((((LDD*)m_ldd)->AnaChan[1].AnBits)-1);
	}
	_updateChildren=false;
    return S_OK;
}


////////////////////////////////////////////////////////////////////////////////////
// FindRange()
//
// This function checks to see if the range passed to it is valid according to what
// the card supports. It returns either the selected range or the closest range.
////////////////////////////////////////////////////////////////////////////////////
HRESULT Ckeithleyain::FindRange(double low, double high, RANGE_INFO *&pRange)
{
    if (low>high)
        return DE_INVALID_CHAN_RANGE;
    if (low==high)
    {
        return CComCoClass<ImwDevice>::Error(_T("Keithley: Low value must not be the same as high value."));
    }
    pRange=NULL;
    double range=HUGE_VAL;
    // search all ranges (saves having to sort (sort by what? range.)
    for (RangeList_t::iterator i=m_validRanges.begin();i!=m_validRanges.end();i++)
    {
        if (((*i).minVal<=low*0.9999) && ((*i).maxVal >= high*0.9999) && (range>((*i).maxVal-(*i).minVal)))
        {
            // range is valid and better 
            pRange = &(*i);
            range=(*i).maxVal-(*i).minVal;
        }
    }
    if (!pRange)
        return DE_INVALID_CHAN_RANGE;
    return S_OK;
}


/////////////////////////////////////////////////////////////////////////////// 
// LoadRangeInfo()
//
//  This routine is used to load the m_validRanges variable with the input  
//  range values from the LDD. It also calculates the gain for the specific 
//  input range.
///////////////////////////////////////////////////////////////////////////////
HRESULT Ckeithleyain::LoadRangeInfo()
{
	
    std::vector<short> ranges;
	float _gain;
	float _minval, _maxval;
	int count = 0;
	if (((LDD*)m_ldd)->AnaChan[1].lpAnGainMult != NULL)
	{
		std::vector<RANGE_INFO> difflist;
		std::vector<RANGE_INFO> singlist;
		
		for ( int loop = 0; loop < m_numgains; loop++)	// This loops through the valuse to check which  
		{												// polarities we support
			_minval = ((LDD*)m_ldd)->AnaChan[1].lpAnGainMult->ArrayList[loop].min;
			_maxval = ((LDD*)m_ldd)->AnaChan[1].lpAnGainMult->ArrayList[loop].max;
			if( (_minval <0) && (_maxval > 0) )
			{									// Bipolar??
				m_supportsBipolar = true;
				// Get the Gains and place them in the array.
				//			NewInfo = new RANGE_INFO;
				RANGE_INFO NewInfo;
				NewInfo.minVal = RoundRange(((LDD*)m_ldd)->AnaChan[1].lpAnGainMult->ArrayList[loop].min);
				NewInfo.maxVal = RoundRange(((LDD*)m_ldd)->AnaChan[1].lpAnGainMult->ArrayList[loop].max);
				NewInfo.gainCode = ((LDD*)m_ldd)->AnaChan[1].lpAnGainMult->ArrayList[loop].GainCode;
				Code2Gain( m_deviceID, m_subSystem, NewInfo.gainCode, &_gain);	
				NewInfo.gain = _gain;

				// For historical reasons, some cards don't report the correct number of
				// items in the gain table. Instead they mask the gain codes with the 
				// masks CHAN_SEDIFF_SE, CHAN_SEDIFF_DIFF or CHAN_SEDIFF_DEFAULT. So
				// we need to check which of the codes are not single ended or differential
				// giving us the default gain codes, and the ones we want, so store them
				// in the m_validRanges variable and count how many there are so we can 
				// override the ldd.
				if ((NewInfo.gainCode < min(CHAN_SEDIFF_SE, CHAN_SEDIFF_DIFF)) &&
					(NewInfo.gainCode >= 0))
				{ 
					difflist.push_back(NewInfo);
					count++;
				}			
			}
			
			if( (_minval == 0) && (_maxval>0) )
			{									// Unipolar??
				m_supportsUnipolar = true;
				//NewInfo = new RANGE_INFO;
				RANGE_INFO NewInfo;
				NewInfo.minVal = RoundRange(((LDD*)m_ldd)->AnaChan[1].lpAnGainMult->ArrayList[loop].min);
				NewInfo.maxVal = RoundRange(((LDD*)m_ldd)->AnaChan[1].lpAnGainMult->ArrayList[loop].max);
				NewInfo.gainCode = ((LDD*)m_ldd)->AnaChan[1].lpAnGainMult->ArrayList[loop].GainCode;
				Code2Gain( m_deviceID, m_subSystem, NewInfo.gainCode, &_gain);	
				NewInfo.gain = _gain;
				
				// For historical reasons, some cards don't report the correct number of
				// items in the gain table. Instead they mask the gain codes with the 
				// masks CHAN_SEDIFF_SE, CHAN_SEDIFF_DIFF or CHAN_SEDIFF_DEFAULT. So
				// we need to check which of the codes are not single ended or differential
				// giving us the default gain codes, and the ones we want, so store them
				// in the m_validRanges variable and count how many there are so we can 
				// override the ldd.
				
				if ((NewInfo.gainCode < min(CHAN_SEDIFF_SE, CHAN_SEDIFF_DIFF)) &&
					(NewInfo.gainCode >= 0))
				{
					singlist.push_back(NewInfo);
					count++;
				}			
			}
		}
		
		// Then put the recorded gain-range info in the correct order.
		for(std::vector<RANGE_INFO>::iterator it = singlist.begin(); it != singlist.end(); it++)
		{
			m_validRanges.push_back(*it);
		}
		
		for(it = difflist.begin(); it != difflist.end(); it++)
		{	
			m_validRanges.push_back(*it);
		}
		
		// If this board doesn't support bipolar ranges, change the internal flag.
		// MATLAB DAQ Engine sorts out the default range for the added channels.
		if (!m_supportsBipolar)
			m_polarity = POLARITY_UNIPOLAR;
		m_numgains = count;
	}
	else
	{
		// The board only has a MinMax Range table, so build it up using this
		RANGE_INFO NewInfo;
		NewInfo.minVal = RoundRange(((LDD*)m_ldd)->AnaChan[1].lpAnMinMaxRange->min);
		NewInfo.maxVal = RoundRange(((LDD*)m_ldd)->AnaChan[1].lpAnMinMaxRange->max);
		NewInfo.gainCode = 0;
		Code2Gain( m_deviceID, m_subSystem, NewInfo.gainCode, &_gain);	
		NewInfo.gain = _gain;
		m_validRanges.push_back(NewInfo);
		m_numgains = 1;
	}
	return S_OK;
}


/////////////////////////////////////////////////////////////////////////////// 
// RoundRange()
//
// This routine rounds off the input value which is passed to it. 
// This rounds number above 1 to three decimal places and numbers below 1
// to 4 decimal places.
// The reason for this, is that DriverLINX returns maximum voltage range values 
// as 9.99984 etc instead of 10.
///////////////////////////////////////////////////////////////////////////////
double Ckeithleyain::RoundRange(double inputvalue)
{
	double tempvalue = inputvalue;
	int count = 0;

	// Because of resolution and conversion errors, we need to round our values, so
	// if it is a positive value then we want to shift the value right and then 
	// round to two decimal places.

	// eg. 0.01249344  ->  1.249344  -> 1.25000 -> 0.0125
	if (tempvalue > 0)
	{
		while (tempvalue < 1)
		{
			tempvalue = tempvalue * 10;
			count++;
		}
	}
	tempvalue = ceil(tempvalue*1e2)/1e2; // round the value to two decimal places.
	return (tempvalue / pow(10, count));
}


///////////////////////////////////////////////////////////////////////////////
// Start()
//
// The method called when the user starts the data acquisition with the start 
// function
///////////////////////////////////////////////////////////////////////////////
HRESULT Ckeithleyain::Start()
{
	if (pClockSource == CLCK_SOFTWARE)
		return InputType::Start();
	WORD ResultCode;
	CComBSTR _error;
    m_samplesThisRun=0;
    m_triggersProcessed=0;
	m_triggerPosted = false;

	// First Check if the device is in use.
	if(GetParent()->IsOpen((analoginputMask + m_deviceID)))
		return CComCoClass<ImwDevice>::Error(CComBSTR("Keithley: The device is in use."));

	// Check if there is an active Service request waiting to stop?
	if (m_daqStatus!=STATUS_STOPPED)
	{
		return CComCoClass<ImwDevice>::Error(CComBSTR("Keithley: Attempt to start a device before previous task stopped."));
	}

	// Initialise the Subsystem, since we need to use it exclusively!
	SELECTMYDRIVERLINX(m_driverHandle);
	RETURN_CODE(InitializeDriverLINXSubsystem(m_pSR, &ResultCode));
	if (ResultCode != 0)
	{
		char tempMsg[255];
		ReturnMessageString(NULL, ResultCode,tempMsg, 255 );
		return CComCoClass<ImwDevice>::Error(tempMsg);
	}
	RETURN_HRESULT(SetupSR(true));

	// Audit the Service Request to check for errors.
	Ops ops = m_pSR->operation;
	m_pSR->operation = AUDITONLY;
	SELECTMYDRIVERLINX(m_driverHandle);
	DriverLINX(m_pSR);
	if (m_pSR->result != 0)
	{
		// Now remove the device from the message window:
        GetParent()->DeleteDev((analoginputMask + m_deviceID));
		char tempMsg[255];
		ReturnMessageString(NULL, m_pSR->result,tempMsg, 255 );
		return CComCoClass<ImwDevice>::Error(tempMsg);
	}
	m_pSR->operation = ops;
    return S_OK;
}

///////////////////////////////////////////////////////////////////////////////////////
// Trigger()
//
// The trigger method, called automatically after start unless the TriggerType is
// manual and ManualHwTriggerOn is trigger
///////////////////////////////////////////////////////////////////////////////////////
HRESULT Ckeithleyain::Trigger()
{
    AUTO_LOCK;
	// Register the device ID with the message window
	//DEBUG: ATLTRACE("AI Adding Device with ID %d to Window.\n", m_deviceID);
	if (GetParent()->AddDev((analoginputMask + m_deviceID),this))
	{
		return Error(_T("Keithley: The device is in use."));
	}
	
	// If we're not running using internal clocks, defer to owner:
	if(pClockSource == CLCK_SOFTWARE)
		return InputType::Trigger();

	//Start DriverLINX
	SELECTMYDRIVERLINX(m_driverHandle);
	DriverLINX(m_pSR);
	if (m_pSR->result != 0)	// If the Service request fails
	{
		// Remove the device from the message window:
        GetParent()->DeleteDev((analoginputMask + m_deviceID));
		return CComCoClass<ImwDevice>::Error(TranslateResultCode(m_pSR->result));
	}
	m_daqStatus = STATUS_RUNNING;
    return S_OK;
}


///////////////////////////////////////////////////////////////////////////////////////
// ReceivedMessage()
//
// Deal with the messages sent to the message window by DriverLINX
///////////////////////////////////////////////////////////////////////////////////////
void Ckeithleyain::ReceivedMessage(UINT wParam, long lParam)
{
    CComBSTR _error;
	WORD ResultCode;
	const int Length = 80;

	UINT bufIndex = getBufIndex( lParam );
	const UINT errorMsg = HIWORD(lParam);

	const WORD taskID = getTaskId(lParam);
	DLEVENTMSG * p_StopEvent = NULL;
	UINT samplesToFetch = 0;

	//DEBUG: ATLTRACE("Received Message for AI. wParam = %d bufIndex = %d\n",wParam,bufIndex);
	bool mustStop = false;
	switch (wParam)
	{
	case DL_SERVICESTART:
		//DEBUG: ATLTRACE("AI Start Services Message Received.\n");
		break;
		
	case DL_TIMERTIC:
		//DEBUG: ATLTRACE("AI TimerTIC Message Received.\n");
		break;
		
	case DL_CRITICALERROR:
		//DEBUG: ATLTRACE("AI Critical Error Message %d Received.\n",errorMsg);
		_engine->DaqEvent(EVENT_ERR, 0, m_samplesThisRun, TranslateResultCode(errorMsg));
		Stop();
		break;
		
	case 0x8001:	// Catch the Unmasked service done message.
	case DL_SERVICEDONE:
		//DEBUG: ATLTRACE("AI ServiceDone Message Received.\n");
		break;
	case DL_STOPEVENT:
		// Got a stop event message. Must find out exactly where we stopped!
		// DEBUG: ATLTRACE("Got a stop event.\n");
		mustStop = true;

		// Create and get the event message structure
		p_StopEvent = new DLEVENTMSG;
		if (p_StopEvent != NULL)
		{
			memset(p_StopEvent, 0, DLEVENTMSGSIZE);
			p_StopEvent->size = DLEVENTMSGSIZE;
			GetEvent(p_StopEvent, GetParent()->GetHandle(), getEventHandle(lParam));
			// Now get the index of the sample:
			bufIndex = p_StopEvent->prm1; // The documentation for this is wrong! This works!
			samplesToFetch = p_StopEvent->prm2 / _nChannels;
			//DEBUG: ATLTRACE("Event Message Says:\n  Buffer Index is %d\n",bufIndex);
			//DEBUG: ATLTRACE("  Samples to Fetch is %d\n", samplesToFetch);
			// Now free this event message memory.
			delete p_StopEvent;
			p_StopEvent = NULL;
		}
		
	case DL_BUFFERFILLED:
		//DEBUG: ATLTRACE("AI Buffer Filled Message Received.\n");
		if (m_daqStatus == STATUS_RUNNING)
		{
			BUFFER_ST * pBuffer;
			_engine->GetBuffer(0, &pBuffer);
			
			if (pBuffer==NULL) 
			{
				//DEBUG: ATLTRACE("AI Buffer from Engine is NULL.\n");
				double triggerrep = pTriggerRepeat;
				if(m_samplesThisRun < (pSamplesPerTrigger * (1 + triggerrep)))
				{
					_engine->DaqEvent(EVENT_DATAMISSED, -1, m_samplesThisRun,NULL);
					return;
				}
				mustStop = true;
			}
			else
			{
				if (samplesToFetch == 0)
					// DriverLINX Buffer is full, so convert all the data MATLAB expects back to the engine buffer.
					samplesToFetch = pBuffer->ValidPoints / _nChannels;
				
				// Get the Data from DriverLINX.
				SelectDriverLINX(m_driverHandle);
				GetDriverLINXAIData(m_pSR,(unsigned short*) pBuffer->ptr,
					bufIndex, _nChannels, samplesToFetch);
				//Check status of the GetDriverLINXAIData
				
				char Status[Length];

				SelectDriverLINX(m_driverHandle);
				ResultCode = GetDriverLINXStatus(m_pSR, Status, Length);
				if (ResultCode != 0)
				{
					_engine->WarningMessage(TranslateResultCode(ResultCode));
					mustStop = true;
				}
				else
				{
					// The conversion worked, now send the data back to MATLAB
					long pointsPerBuffer = m_engineBufferSamples*_nChannels;
					pBuffer->StartPoint = m_samplesThisRun * _nChannels;
					m_samplesThisRun+=samplesToFetch;
					
					// Set the number of valid points in this buffer
					pBuffer->ValidPoints = samplesToFetch * _nChannels;
					if ((pBuffer->Flags & BUFFER_IS_LAST)||(pBuffer->ValidPoints < pointsPerBuffer))
					{
						mustStop = true;
					}
					_engine->PutBuffer(pBuffer);
					if (m_triggering && (pTriggerType==TRIGGER_HWDIGITAL) && !m_triggerPosted)        
					{
						double time;             
						m_triggering=false;
						m_triggerPosted = true;
						_engine->GetTime(&time);
						double triggerTime = time - m_engineBufferSamples/pSampleRate;
						_engine->DaqEvent(EVENT_TRIGGER, triggerTime, 
							              static_cast<__int64>(pSamplesPerTrigger*m_triggersProcessed), 
										  NULL);
						m_triggersProcessed++;
					}
				}
			}
			if (mustStop)
			{
				Stop();
			}
		}
		break;
		
	case DL_DATALOST:
		//DEBUG: ATLTRACE("AI Data Lost Message Received.\n");
		_engine->DaqEvent(EVENT_DATAMISSED, -1, m_samplesThisRun,NULL);
		Stop();
		break;
	}
}

////////////////////////////////////////////////////////////////////////
// Stop
//
// Stop the analog input acquisition
////////////////////////////////////////////////////////////////////////
HRESULT Ckeithleyain::Stop()
{
	if (pClockSource == CLCK_SOFTWARE)
	{
		GetParent()->DeleteDev((analoginputMask + m_deviceID));
		return InputType::Stop();
	}

	AUTO_LOCK;

	//DEBUG: ATLTRACE("Stop Message Received. DaqStatus = %d\n", m_daqStatus);
	if (m_daqStatus == STATUS_RUNNING)
	{
		if (pStopTriggerType==STP_TRIGT_NONE)
		{
			SELECTMYDRIVERLINX(m_driverHandle);
			WORD ResultCode = StopDriverLINXSR(m_pSR);
			if(ResultCode !=0)
			{
				_engine->WarningMessage(TranslateResultCode(ResultCode));
			}
		}
		
		// Now remove the device from the message window:
		//DEBUG: ATLTRACE("AI Deleting Device From Window.\n");
		GetParent()->DeleteDev((analoginputMask + m_deviceID));
		m_daqStatus = STATUS_STOPPED;
		_engine->DaqEvent(EVENT_STOP, -1, m_samplesThisRun, NULL);
	}
    return S_OK;
}


///////////////////////////////////////////////////////////////////////////////////
// CalculateRateAndSkew()
//
// Checks SampleRate and ChannelSkew based on new Sampling Rate and Channel Skew 
// Mode. This method also sets maximum sample rate values.
//////////////////////////////////////////////////////////////////////////////////
void Ckeithleyain::CalculateRateAndSkew( double newrate, long newskewmode )
{
	// New algorithm: Post R13beta2
	double maxSR;
	double newskew;
	double csSafetySecs = m_chanSkewSafetyRange * (m_chanSkewSafetyUnits==1? m_aiTicPeriod: 1e-6);
	if (_nChannels>1)
	{
		switch (newskewmode)
		{
		case CHAN_SKEW_MIN:
			maxSR = __min(m_maxBoardSampleRate/_nChannels, 1/(m_minManChanSkew*_nChannels+csSafetySecs));
			maxSR = 1/QuantiseValue(1/maxSR);
			pSampleRate.SetRange(CComVariant(m_minBoardSampleRate), CComVariant(maxSR));
			if (newrate > maxSR)
			{
				_engine->WarningMessage(CComBSTR(L"Keithley: Reducing sampling rate based on new limits."));
				newrate = maxSR;
			}
			pChannelSkew = m_minManChanSkew;
			break;
		case CHAN_SKEW_EQUISAMPLE:
			maxSR = m_maxBoardSampleRate/_nChannels;
			maxSR = 1/QuantiseValue(1/maxSR);
			pSampleRate.SetRange(CComVariant(m_minBoardSampleRate), CComVariant(maxSR));
			if (newrate > maxSR)
			{
				_engine->WarningMessage(CComBSTR(L"Keithley: Reducing sampling rate based on new limits."));
				newrate = maxSR;
			}
			newskew = 1/(newrate*_nChannels);
			pChannelSkew = newskew;
			break;
		case CHAN_SKEW_MANUAL:
			maxSR = __min(m_maxBoardSampleRate/_nChannels, 1/(m_minManChanSkew*_nChannels+csSafetySecs));
			maxSR = 1/QuantiseValue(1/maxSR);
			pSampleRate.SetRange(CComVariant(m_minBoardSampleRate), CComVariant(maxSR));
			if (newrate > maxSR)
			{
				_engine->WarningMessage(CComBSTR(L"Keithley: Reducing sampling rate based on new limits."));
				newrate = maxSR;
			}
			double csMax = __min(m_maxManChanSkew, (1/newrate-csSafetySecs)/_nChannels);
			csMax = QuantiseValue(csMax);
			pChannelSkew.SetRange(CComVariant(m_minManChanSkew),CComVariant(csMax));
			if (pChannelSkew > csMax)
			{
				_engine->WarningMessage(CComBSTR(L"Keithley: Reducing channel skew based on new limits."));
				pChannelSkew = csMax;
			}
		}
	}
	pSampleRate = newrate;
	pChannelSkewMode = newskewmode;
}


////////////////////////////////////////////////////////////////////////////////////
// ChildChange()
//
// This function is overloaded. Called when channels are added, removed or reordered
////////////////////////////////////////////////////////////////////////////////////
STDMETHODIMP Ckeithleyain::ChildChange(DWORD typeofchange, NESTABLEPROP *pChan)
{
	if ((typeofchange & CHILDCHANGE_REASON_MASK)== ADD_CHILD) //Do stuff before we add the channel	
    {
		if (_nChannels >= m_channelGainQueueSize)
		{
			return Error(_T("Keithley: Channel Gain Queue Full."));
		}
    }
	if (typeofchange & END_CHANGE)
    {
		long numChans;	// Update the number of channels that have been added, by querying the engine
		_EngineChannelList->GetNumberOfChannels(&numChans); 
		_nChannels=numChans;	// Store data in the local variable _nChannels
		UpdateChans(true);		// Update all related channel information
		if (pClockSource != CLCK_SOFTWARE)
		{
			CalculateRateAndSkew(pSampleRate, pChannelSkewMode);
		}
	}
    return S_OK;
}


///////////////////////////////////////////////////////////////////////////////////
// CalculateMaxSampleRate()
//
// Uses DriverLINX to calculate the maximum sample rate possible for the current
// acquisition configuration.
///////////////////////////////////////////////////////////////////////////////////
double Ckeithleyain::CalculateMaxSampleRate(bool noChans)
{
	CComBSTR _error;
	double period = 0;

	// Start and Stop events
    SELECTMYDRIVERLINX(m_driverHandle);
    AddStartEventOnCommand(m_pSR);
    SELECTMYDRIVERLINX(m_driverHandle);
    AddStopEventOnCommand(m_pSR);

    //Setup Transfer Mode
    // Transfer Mode can be DMA or Interrupts. For now, keep it DMA
    SELECTMYDRIVERLINX(m_driverHandle);
    AddRequestGroupStart(m_pSR, ASYNC);
    
    // AddTimingEventNullEvent(m_pSR);
    SELECTMYDRIVERLINX(m_driverHandle);
    AddTimingEventDefault(m_pSR, 1000.0);
    
    // Add one channel
    m_pSR->channels.nChannels = 1;
    m_pSR->channels.numberFormat = tNATIVE;
    m_pSR->channels.chanGain[0].channel = 0;
    m_pSR->channels.chanGain[1].channel = 0;
    
    // Clean up the Channel Gain List to make it NULL
    if (m_pSR->channels.chanGainList != NULL)
    {
        delete [] m_pSR->channels.chanGainList;
        m_pSR->channels.chanGainList = NULL;
    }
    SELECTMYDRIVERLINX(m_driverHandle);
    m_pSR->channels.chanGain[0].gainOrRange = 
        Gain2Code(m_deviceID, m_subSystem, -1);     
    
    // Add select Buffer Group
    SELECTMYDRIVERLINX(m_driverHandle);
    AddSelectBuffers(m_pSR, 1,1000,1);
	
	//Now calculate the minimum sampling period for the service request
	SELECTMYDRIVERLINX(m_driverHandle);
	DLMinPeriod(m_pSR);
	if (m_pSR->result != 0)
	{
		char tempMsg[255];
		ReturnMessageString(NULL, m_pSR->result,tempMsg, 255 );
		_engine->WarningMessage(CComBSTR(tempMsg));
	}

	SELECTMYDRIVERLINX(m_driverHandle);
	if (!(Tics2Sec(m_pSR->timing.u.rateEvent.period ,&period)))
	{
		_engine->WarningMessage(CComBSTR("Keithley: Error occured while calculating maximum SampleRate.\nMaximum SampleRate may not be valid."));
	}
	return (1.0/period);
}

//////////////////////////////////////////////////////////////////////
// TranslateResultCode()
//
// Translate a Keithley result code to a readable message
//////////////////////////////////////////////////////////////////////
CComBSTR Ckeithleyain::TranslateResultCode(UINT resultCode)
{
	char tempMsg[255];
	char kTempMsg[255];
	ReturnMessageString(NULL, m_pSR->result,tempMsg, 255 );
	sprintf(kTempMsg, "Keithley: %s", tempMsg);
	return CComBSTR(kTempMsg);
}


/////////////////////////////////////////////////////////////////////
// SetDefaultTriggerConditionValues()
//
// Define the Trigger Condition Values at startup
/////////////////////////////////////////////////////////////////////
int Ckeithleyain::SetDefaultTriggerConditionValues()
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
    hRes = SafeArrayAccessData (ps, (void **) &range);
    if (FAILED (hRes)) 
    {
        SafeArrayDestroy (ps);
        return E_FAIL;
    }
    range=0;
    hRes = pTriggerConditionValue->put_Value(val);
    if (!SUCCEEDED(hRes)) 
    {
        SafeArrayUnaccessData (ps);
		return hRes;        
    }
	hRes = pTriggerConditionValue->put_DefaultValue(val);
    if (!SUCCEEDED(hRes)) 
    {
        SafeArrayUnaccessData (ps);
		return hRes;        
    }
	hRes = pTriggerConditionValue->SetRange(&CComVariant(0L),&CComVariant(0L));
    if (!SUCCEEDED(hRes)) 
    {
        SafeArrayUnaccessData (ps);
		return hRes;        
    }
    SafeArrayUnaccessData (ps);
    return S_OK;
}


//////////////////////////////////////////////////////////////////////////
// CalculateMicroSec()
//
// Determine, using the LDD, how many microseconds in a Keithley tic
//////////////////////////////////////////////////////////////////////////
double Ckeithleyain::CalculateMicroSec()
{
	WORD ResultCode = 0;
	CComBSTR _error;
    short defAITimerChannel = ((LDD *)m_ldd)->AnaChan[1].AnDefaultTimingChan;
	if (defAITimerChannel < 0)
	{
		// Use the default timer channel on the board
		defAITimerChannel = ((LDD *)m_ldd)->CTChan.CTDefaultTimingChan;
		if (defAITimerChannel < 0)
		{
			_engine->WarningMessage(CComBSTR("Keithley: No onboard clock detected! Cannot determine minimum sample rate!"));
			return 10e-6; // Assume 10uS. Probably wrong, but no alternative.
		}
	}
	return (((LDD *)m_ldd)->CTChan.lpCTCapabilities[defAITimerChannel].microseconds * 1e-6);
}


///////////////////////////////////////////////////////////////////////////////
// PeekData()
//
// Not implemented, uses Engine implementation
//////////////////////////////////////////////////////////////////////////////
STDMETHODIMP Ckeithleyain::PeekData(BUFFER_ST *buffer)
{
	return E_NOTIMPL;
}

///////////////////////////////////////////////////////////////////////////////////
// CalculateMinSampleRate()
//
// Calculate the minimum sample rate possible for the subsystem
///////////////////////////////////////////////////////////////////////////////////
double Ckeithleyain::CalculateMinSampleRate( UINT countersize )
{
	double minsr = 1.0/(QuantiseValue((m_aiTicPeriod * (pow(2,countersize) - 1)), false));

	/// The next code adds a safety factor to the minimum sample rate of 0.1%
	//   The reason we do this is because we have found a floating point error in calculating the
	//   minimum sample rate for certain boards (KPCI-3104, KPCI-3110).
	double safety = (minsr * 0.1) / 100;

	minsr += safety;
	
	return minsr;
}


//////////////////////////////////////////////////////////////////////////
// CalcEquiSmplMinSR
//
// Calculate the minimum sample rate assuming Channel Skew Mode set to
// Equisample
//////////////////////////////////////////////////////////////////////////
double Ckeithleyain::CalcEquiSmplMinSR( UINT countersize )
{
	if (_nChannels > 0)
		return 1.0/(_nChannels*m_aiTicPeriod * (pow(2,countersize) - 1));
	else
		return CalculateMinSampleRate(m_clockDividerWidth);
}


/////////////////////////////////////////////////////////////////////////////
// FindNumberOfChannels
//
// Determine the number of single ended and differential channels supported
/////////////////////////////////////////////////////////////////////////////
HRESULT Ckeithleyain::FindNumberOfChannels()
{
	WORD nAnaChan = ((LDD*)m_ldd)->AnaChan[1].NAnChan;
	
	if (nAnaChan == m_numSEOnBoard)
	{
		m_maxValidSEChan = m_numSEOnBoard - 1;
		m_maxValidDIChan = m_numDIOnBoard - 1;
		// In Single Ended Mode
		m_terminationMode = IN_SINGLEENDED;
		return S_OK;
	}
	else if (nAnaChan == m_numDIOnBoard)
	{
		m_maxValidSEChan = m_numDIOnBoard - 1;
		m_maxValidDIChan = m_numDIOnBoard - 1;
		// In Diferential Mode
		m_terminationMode = IN_DIFFERENTIAL;
		return S_OK;
	}
	return Error(_T("The number of channels available on board are not as expected."));
}


///////////////////////////////////////////////////////////////////
// QuantiseValue()
// 
// Quantise sampling rate
///////////////////////////////////////////////////////////////////
double Ckeithleyain::QuantiseValue(double valSecs, bool performcheck)
{
		double reqSecs = valSecs;
		double newtics = Sec2Tics(reqSecs);
		Tics2Sec(newtics, &reqSecs);

		// if we're within 0.1%, that's okay
		if ((reqSecs > valSecs*1.001) && performcheck)// If we're too far out...
		{
			Tics2Sec((newtics - 1), &reqSecs);
		}
		return reqSecs;
}


//////////////////////////////////////////////////////////////////////////////
// ConfigureStopTrigger()
//
// Check and set up stop triggers in service request
// Relies solely on globals, or Property pointers.
//////////////////////////////////////////////////////////////////////////////
HRESULT Ckeithleyain::ConfigureStopTrigger()
{
	// Do we need a stop trigger?
	if (pStopTriggerType==STP_TRIGT_HWDIGITAL)
	{
		// Rising or falling external trigger:
		ATLTRACE("Using Stop on Digital Value.\n");
		SELECTMYDRIVERLINX(m_driverHandle);
		AddStopEventDigitalTrigger(m_pSR, DI_EXTTRG, 1, ((pStopTriggerCondition==STP_TRIGC_RISING)? 0 : 1));
	}
	else if (pStopTriggerType==STP_TRIGT_HWANALOG)
	{
		// Analog triggers can be rising or falling.
		ATLTRACE("Using Stop on Analog Value.\n");
		// Calculate the thresholds:
		float loVal, hiVal;
		WORD trigFlag;
		if (pStopTriggerCondition==STP_TRIGC_FALLING)
		{
			hiVal = (float) pStopTriggerConditionValue;
			loVal = (float) pStopTriggerConditionValue;
			trigFlag = AnaTrgNegInside;
		}
		else // (pStopTriggerCondition==STP_TRIGC_RISING)
		{
			loVal = (float) pStopTriggerConditionValue;
			hiVal = (float) pStopTriggerConditionValue;
			trigFlag = AnaTrgPosOutside;
		}
		// Now set the stop condition:
		short stopTrigChannelGain = 0;
		bool stopTrigChannelFound = false;	// A flag to say it's not been found.
		AICHANNEL *aichan=NULL;
		for (int i=0; i<_nChannels; i++) 
		{   
			_EngineChannelList->GetChannelStructLocal(i, (NESTABLEPROP**)&aichan);
			if (aichan->Nestable.HwChan==pStopTriggerChannel)
			{
				stopTrigChannelGain = static_cast<short>(m_chanGain[i]);
				stopTrigChannelFound = true;
			}
		}
		if (!stopTrigChannelFound)
		{
			// Error out, the channel is invalid.
			return CComCoClass<ImwDevice>::Error("Keithley: Stop Trigger Channel must be in Channel list.");
		}
		short stopTrigChannel = (SINT)pStopTriggerChannel;
		SELECTMYDRIVERLINX(m_driverHandle);
		AddStopEventAnalogTrigger(m_pSR, m_deviceID, stopTrigChannel, m_subSystem, stopTrigChannelGain, 
			hiVal, loVal, trigFlag);

		// Now set up the StopTriggerDelay
		if (pStopTriggerDelay>0)
		{
			ATLTRACE("Have to implement StopTrigger Delays.\n");
			DWORD actualDelay = static_cast<DWORD>(pStopTriggerDelay * _nChannels * (pStopTriggerDelayUnits==STDU_SAMPLES ? 1 : pSampleRate));
			m_pSR->stop.delay = actualDelay;
		}
	}
	else
	{
		// Don't need stop triggers, use Stop on command
		ATLTRACE("Using Stop on Command.\n");
		SELECTMYDRIVERLINX(m_driverHandle);
		AddStopEventOnCommand(m_pSR);
	}
	return S_OK;
}


////////////////////////////////////////////////////////////////////////////////////
// LoadINIInfo
//
// Load property values from the INI file
////////////////////////////////////////////////////////////////////////////////////
HRESULT Ckeithleyain::LoadINIInfo()
{
    char Section[16];
    // The ini file is expected to be in the same directory as the application,
    // namely, this DLL. It's the only way to find the file if it's not
    // in the windows subdirectory
	char fname[512];
    if (GetModuleFileName(_Module.GetModuleInstance(), fname, 512)==0)
        return E_FAIL;
   
    // replace .dll with .ini
    strrchr(fname, '.' )[1]='\0';
    strcat(fname,"ini"); 
    
    // create a key to search on - The Model Name.
    ::ReturnMessageString(NULL, ((LDD*)m_ldd)->DevCap.ModelCode, (LPSTR)Section, 16);
    
	m_clockDividerWidth = GetPrivateProfileInt(Section, "aiclockdivwidth", 0, fname);
	m_numSEOnBoard = GetPrivateProfileInt(Section, "ainumse", 0, fname);
	m_numDIOnBoard = GetPrivateProfileInt(Section, "ainumdiff", 0, fname);
	m_minManChanSkew = GetPrivateProfileDouble(Section, "aiminchanskew", 0, fname);
	m_maxManChanSkew = GetPrivateProfileDouble(Section, "aimaxchanskew", 0, fname);
	m_chanSkewSafetyUnits = (ChannelSkewSafetyUnitTypes)GetPrivateProfileInt(Section, "aichanskewsafetyunits", 0, fname);
	m_chanSkewSafetyRange = static_cast<float>(GetPrivateProfileInt(Section, "aichanskewsafety", 0, fname));
	m_supportsBurstMode = GetPrivateProfileInt(Section, "aiburstmode", 0, fname);
    return S_OK;
}


/////////////////////////////////////////////////////////////////////////
// SetupSR
//
// Construct the DriverLINX Service Request either to start acquisition
// or check the sampling rate and channel skew
/////////////////////////////////////////////////////////////////////////
HRESULT Ckeithleyain::SetupSR( bool forStart )
{
	// Confirm that all channel info is correct.
    if (_updateChildren) 
    {
        RETURN_HRESULT(UpdateChans(true));
    }
	
	// Flags: Safety catch for something that breaks if the flags are set:
	m_pSR->taskFlags = 0;

	// Setup Transfer Mode
	// Transfer Mode can be DMA or Interrupts. For now, keep it DMA
	SELECTMYDRIVERLINX(m_driverHandle);
	AddRequestGroupStart(m_pSR, ASYNC);
	
	// Setup Channels
	// Depends on whether we're faking it or not:
	SELECTMYDRIVERLINX(m_driverHandle);

	//Only KPCI-3100 series have Termination mode
	char deviceName[25] = "";
	char tempstr[] = "KPCI-31";
	::ReturnMessageString(NULL, ((LDD*)m_ldd)->DevCap.ModelCode, (LPSTR)deviceName, 25); // the vendor
	if(_strnicmp( deviceName, tempstr, 7)!=0) 
	    m_termination = CHAN_SEDIFF_DEFAULT;

	AddChannelGainList(m_pSR, _nChannels, &_chanList[0], &m_chanGain[0], m_termination);
	
	// Setup Clock based on whether or not the Channel Skew is equisample
	if ((_nChannels >1) && (pChannelSkewMode != CHAN_SKEW_EQUISAMPLE))
	{
		SELECTMYDRIVERLINX(m_driverHandle);
		RETURN_CODE(AddTimingEventBurstMode(m_pSR, _nChannels, static_cast<float>(pSampleRate),
		                                                       static_cast<float>(1/pChannelSkew)));
	}
	else //if (pClockSource == CLCK_INTERNAL)
	{
		// Multiply the sample rate by the number of channels for timing.
		SELECTMYDRIVERLINX(m_driverHandle);
		RETURN_CODE(AddTimingEventDefault(m_pSR, static_cast<float>(pSampleRate * _nChannels)));
	}
	// If we are using an external clock, overwrite some of the service request.	
	if((pClockSource == CLCK_EXTERNAL) && (forStart))
	{
	//	AddTimingEventExternalDigitalClock(m_pSR);
	//	m_pSR->timing.u.rateEvent.mode = BURSTGEN;
		m_pSR->timing.u.rateEvent.clock = EXTERNAL;
	}

	// Configure the buffers
	_engine->GetBufferingConfig(&m_engineBufferSamples, NULL);
	if (!m_usingDMA | ((m_engineBufferSamples == 1) && (((LDD*)m_ldd)->AnaChan[1].AnFlags & An_Uses32BitXfer)))
	{
		// If there is one sample per buffer set the transfer mode to interrupt
		// since you have to have at least two samples per buffer in DMA.
		// If MATLAB sets the buffer size to 1 sample, you should be sampling slowly enough
		// that interrupt sampling is OK
		m_pSR->mode = INTERRUPT;
		pTransferMode = TRANSFER_INTERRUPTS;
		m_usingDMA = false;
	}
	
	// Heuristic: 1 buffer for the application to process, one buffer for the board to fill and extra
	// buffers capable of holding one second of data + 1 buffer just for luck (actually just in case...)
	int numBuffers = 1 + 1 + int(pSampleRate / m_engineBufferSamples) + 1;
	if (numBuffers > 255)
	{
		// Warning: Cannot have more than 255 DriverLINX buffers
		UINT minBufSize = static_cast<UINT>(ceil(pSampleRate / 252));
		char temp[255];
		sprintf(temp, "Keithley: BufferingConfig may be too small for FIFO buffer size (recommend at least %d points per buffer).", 
			minBufSize);
		_engine->WarningMessage(CComBSTR(temp));
		numBuffers = 255;
	}
	
	// Initialise Buffering.
	SELECTMYDRIVERLINX(m_driverHandle);
	AddSelectBuffers(m_pSR, numBuffers, m_engineBufferSamples, _nChannels);
	
	// Configure Triggers
	if (pTriggerType == TRIGGER_HWDIGITAL)
	{
		m_triggering = true;
		if((pTriggerCondition == TRIG_COND_RISING) || (pTriggerCondition == TRIG_COND_FALLING))
		{
			SELECTMYDRIVERLINX(m_driverHandle);
			AddStartEventDigitalTrigger(m_pSR, DI_EXTTRG, 1, 0, (pTriggerCondition==TRIG_COND_RISING? 0 : 1)); 
		}
		else
		{
			SELECTMYDRIVERLINX(m_driverHandle);
			AddStartEventOnCommand(m_pSR);
			
			if (pTriggerCondition == TRIG_COND_GATEHIGH)
				m_pSR->timing.u.rateEvent.gate = HILEVELGATEN;
			else
				m_pSR->timing.u.rateEvent.gate = LOLEVELGATEN;
		}
	}
	else
	{
		// Start and Stop events
		SELECTMYDRIVERLINX(m_driverHandle);
		AddStartEventOnCommand(m_pSR);
	}

	// Configure the Service Request for Stop Triggers.
	RETURN_HRESULT(ConfigureStopTrigger());

	// Flags: Whenever we're here, reset flags so it reports everything.
	m_pSR->taskFlags = 0;
	return S_OK;
}


////////////////////////////////////////////////////////////////////////
// Tics2Sec()
//
// Internal implementation of DriverLINX Tics2Sec
/////////////////////////////////////////////////////////////////////////
bool Ckeithleyain::Tics2Sec(double Tics, double* Sec)
{
	*Sec = Tics * m_aiTicPeriod;
	return true;
}


////////////////////////////////////////////////////////////////////////
// Sec2Tics()
//
// Internal implementation of DriverLINX Sec2Tics
/////////////////////////////////////////////////////////////////////////
UINT Ckeithleyain::Sec2Tics(double secs)
{
	UINT tics = static_cast<UINT>(secs/m_aiTicPeriod + 0.5);
	if ((tics == 0)&&(secs != 0.0))
		tics = static_cast<UINT>((pow(2,m_clockDividerWidth)-1));
	return tics;
}
