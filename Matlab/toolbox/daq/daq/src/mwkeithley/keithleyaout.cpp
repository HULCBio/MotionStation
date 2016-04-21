// keithleyaout.cpp : Implementation of Keithley AnalogOutput device
// $Revision: 1.1.6.2 $
// $Date: 2003/12/04 18:39:39 $

// Copyright 2002-2003 The MathWorks, Inc. 
// Coded by OPTI-NUM solutions

#include "stdafx.h"
#include "string.h"
#include "mwkeithley.h"
#include "keithleyaout.h"
#include "keithleyadapt.h"
#include "keithleypropdef.h"
#include "adaptorkit.h"
#include "keithleyUtil.h"


#define AUTO_LOCK TAtlLock<Ckeithleyaout> _lock(*this)

// So that we can use infinity:
#include <limits>
#define INFINITY std::numeric_limits<double>::infinity()


/////////////////////////////////////////////////////////////////////////////
// Ckeithleyaout() constructor
//
// Function performs all the necessary initializations.
///////////////////////////////////////////////////////////////////////////// 
Ckeithleyaout::Ckeithleyaout():
m_pSR(NULL),
m_subSystem(AO),
m_isInitialized(false),
m_supportsBipolar(false),
m_supportsUnipolar(false),
m_supportsDMA(false),
m_polarity(POLARITY_BIPOLAR),
m_numgains(0),
m_daqStatus(STATUS_STOPPED),
m_triggering(false),
m_maxBoardSampleRate(0),
m_minBoardSampleRate(0),
m_burstModeClockFreq(0),
m_usingDMA(true),
m_fifoSize(0),
m_supportsPolledClockOnly(false),
m_clockDividerWidth(0)
{
	m_pParent = MessageWindow::GetKeithleyWnd(); 

	// Create the DriverLINX Service Request.
	m_pSR = (DL_ServiceRequest *) new DL_ServiceRequest;
	memset(m_pSR, 0, sizeof(DL_ServiceRequest));
	//Set the size of the service request
	m_pSR->dwSize = sizeof(DL_ServiceRequest);

} // end of default constructor

Ckeithleyaout::~Ckeithleyaout()
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
	// If they do delete them and then set the DL_BUFFERLIST data structure to
	// NULL.
	if (pBuffer != NULL)	 // If data structure exists
	{
		int i;
		for (i = 0; i< pBuffer->nBuffers; i++)
		{
			if (pBuffer->BufferAddr[i] != NULL)	   // Delete old buffers
			{
				BufFree(pBuffer->BufferAddr[i]);
			}
		}
		delete [] pBuffer;		// Release memory
		pBuffer = NULL;			// Set data structure to NULL
		m_pSR->lpBuffers = NULL;
	}

	// Free the memory associated with Service Request
	if ( m_pSR != NULL )
	{
		delete m_pSR;
		m_pSR = NULL;
	}
	m_validRanges.clear();
	
	// Finally free the memory associated with the ldd
	SelectDriverLINX(m_driverHandle);
	::FreeLDD(m_ldd);

	//DEBUG: DumpUnfreed(); // Call Our Memory Checker.
}


/////////////////////////////////////////////////////////////////////////////
// Open()
//
// Function is called by the OpenDevice(), which is in turn called by the engine.
// Ckeithleyaout::Open() function's main goals are ..
// 1)to initialize the hardware and hardware dependent properties..
// 2)to expose pointers to the engine and the adaptor to each other..
// 3)to process the device ID, which is input by a user in the ML command line.
// The call to this function goes through the hierarchical chain: ..
//..Ckeithleyaout::Open() -> CswClockedDevice::Open() -> CmwDevice::Open()
// CmwDevice::Open() in its turn populates the pointer to the..
//..engine (CmwDevice::_engine), which allows to access all engine interfaces.
//////////////////////////////////////////////////////////////////////////////
HRESULT Ckeithleyaout::Open(IUnknown *Interface,long ID)
{
	if (ID<0) 
	{
		CComBSTR _error;
		_error.LoadString(IDS_ERR_INVALID_DEVICE_ID);
		return CComCoClass<ImwDevice>::Error(_error);
	}

	m_deviceID = static_cast<WORD>(ID);
	m_pSR->hWnd = m_pParent->GetHandle();
	RETURN_HRESULT(TBaseObj::Open(Interface));	// Gets pointer to engine in _engine
	// Find the right driver for this device ID.
   	for(std::vector<DEVICEDETAILS>::iterator it = GetParent()->m_deviceMap.begin();
			it != GetParent()->m_deviceMap.end(); it++)
	{
		if((*it).deviceID == m_deviceID)
			m_driverHandle = GetParent()->m_driverMap[(*it).driverLookup].driverHandle;
	}
	// Select and get the LDD
	SELECTMYDRIVERLINX(m_driverHandle);
	m_ldd = ::GetLDD(NULL, m_deviceID);
	if (m_ldd==NULL)
	{
		// Something wrong. Probably not a configured device.
		char tempMsg[255];
		sprintf(tempMsg, "Keithley Error: Device %d not found. Check DriverLINX Configuration Panel!", m_deviceID);
		return CComCoClass<ImwDevice>::Error(tempMsg);
	}
	// Still need to check if this device has AO subsystem.
	if (!SupportsSubSystem((LDD*)m_ldd, AO))
		return Error(_T("Keithley: Analog Output is not supported on this device."));

	if(((LDD*)m_ldd)->AnaChan[0].lpAnGainMult != NULL)
	{
		m_numgains = ((LDD*)m_ldd)->AnaChan[0].lpAnGainMult->Nentries;
	}
	else
	{
		m_numgains = 1;
	}

	m_pSR->device = m_deviceID;		// Device ID
	// Initialize the device if it has not already been done.
	if (!((LDD*)m_ldd)->DevCap.DeviceInit)
	{
		WORD ResultCode;
		SELECTMYDRIVERLINX(m_driverHandle);
		RETURN_CODE(InitializeDriverLINXDevice(m_pSR, &ResultCode));
		if (ResultCode != 0)
		{
			char tempMsg[255];
			ReturnMessageString(NULL, ResultCode,tempMsg, 255);
			return CComCoClass<ImwDevice>::Error(tempMsg);
		}
	}
	
	// This code MUST come after initialization of the device!!!
	m_pSR->subsystem = AO;			// Analog output subsystem

	// Load INI file information into our local variables.
	RETURN_HRESULT(LoadINIInfo());

	m_supportsDMA = (DoesDeviceSupportDMA(m_pSR) == DL_TRUE);


	SELECTMYDRIVERLINX(m_driverHandle);
	if (!m_supportsDMA && (DoesDeviceSupportIRQ(m_pSR) != DL_TRUE))
	{
		m_supportsPolledClockOnly = true;
		EnableSwClocking(true);
	}
	
	// Calculate sample rate ranges.
	double defaultSampleRate = 1000;
	double maxSampleRate;
	double minSampleRate;

	if (!m_supportsPolledClockOnly)
	{
		// Only calculate board sample rates if there is an onboard clock!
		m_aoTicPeriod = static_cast<float>(CalculateMicroSec());
		m_maxBoardSampleRate = CalculateMaxSampleRate(true);	// As well as the maximum samplerate.
		m_minBoardSampleRate = CalculateMinSampleRate( m_clockDividerWidth );
		m_burstModeClockFreq = static_cast<float>(1/__max(m_chanSkew, 2*m_aoTicPeriod)); 
		maxSampleRate = m_maxBoardSampleRate;
		minSampleRate = m_minBoardSampleRate;

	}
	else
	{
		m_aoTicPeriod = 0;
		maxSampleRate = (double)MAX_SW_SAMPLERATE;
		minSampleRate = (double)MIN_SW_SAMPLERATE;
		defaultSampleRate = 100;
	}

	m_channelGainQueueSize = ((LDD*)m_ldd)->AnaChan[0].AnChanGainMaxEntries;

	RETURN_HRESULT(SetDaqHwInfo()); // Set the DaqHwInfo properties.

	//////////////////////////////// Properties ///////////////////////////////////
	// The following Section sets the Propinfo for the Analog output device      //
	///////////////////////////////////////////////////////////////////////////////
	CComPtr<IProp> prop;	// Generic property to be reused on non-attached props

	// The Clock Source Property
	ATTACH_PROP(ClockSource);
	pClockSource->AddMappedEnumValue(CLCK_SOFTWARE, L"Software");
	pClockSource->put_DefaultValue(CComVariant(CLCK_INTERNAL));
	pClockSource = CLCK_INTERNAL;
	if (m_supportsPolledClockOnly)
	{
		pClockSource->RemoveEnumValue(CComVariant(L"internal"));
		pClockSource->put_DefaultValue(CComVariant(CLCK_SOFTWARE));
		pClockSource = CLCK_SOFTWARE;

		//This is the Transfer Mode property -- Polled Mode
		CREATE_PROP(TransferMode);
		pTransferMode->AddMappedEnumValue(TRANSFER_POLLED, L"Polled");
		pTransferMode.SetDefaultValue(TRANSFER_POLLED);
		pTransferMode = TRANSFER_POLLED;

	}
	else 
	{
		// We only support external clocking if internal clocking is
		// supported. See Release Notes!
		int clock = 1<<EXTERNAL;
		if ((((LDD*)m_ldd)->CTChan.lpCTCapabilities->clocks) & clock)
		{
			pClockSource->AddMappedEnumValue(CLCK_EXTERNAL, L"External");
		}

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

	// The Sample Rate Property
	ATTACH_PROP(SampleRate);
	pSampleRate.SetDefaultValue(defaultSampleRate);
	pSampleRate = defaultSampleRate;
	pSampleRate.SetRange(minSampleRate,maxSampleRate);

	// Buffering Config
	// Set the range for the BufferingConfig's first value. This can be done through the 
	// EngineBlockSize property.
	GetProperty(L"EngineBlockSize", &prop);
    CComVariant minblock( ceil(static_cast<double>((m_fifoSize/255)+1)) );
	CComVariant maxblock( (128.0*1024.0) );
	prop->SetRange(&minblock, &maxblock);
	prop.Release();

    // Out of Data Mode
	prop=ATTACH_PROP(OutOfDataMode);
    prop->put_IsHidden(false);

	// Trigger Type
	ATTACH_PROP(TriggerType);
	SELECTMYDRIVERLINX(m_driverHandle);
	int Two2Event = (int) pow(2, DIEVENT);
	if (((LDD*)m_ldd)->AnaChan[0].AnEvents.StartEvents[DMA] & Two2Event) 	// Not All devices supported by DriverLINX
	{
		pTriggerType->AddMappedEnumValue(TRIGGER_HWDIGITAL, L"HwDigital");			// support Digital Start Triggers on the AO.
	}

	//Trigger Condition
	CREATE_PROP(TriggerCondition);
	pTriggerCondition->AddMappedEnumValue(TRIG_COND_NONE, L"None");
	pTriggerCondition->put_Value(CComVariant(TRIG_COND_NONE));
	
	// Repeat Output
	ATTACH_PROP(RepeatOutput);

	// Out Of Data Mode
	ATTACH_PROP(OutOfDataMode);

	////////////////////////////////////////////////////////////////////////
	//Channel Properties: Attach using a CRemoteProp and our CHANUSER enums
	CRemoteProp rp;				// Catch-all remoteprop we can attach to
	CComVariant var, _default;	// Variants for the SafeArray stuff.

	// The Default Channel Value Property
    rp.Attach(_EngineChannelList,L"DefaultChannelValue",DEFAULTCHANVAL);
    rp.SetRange(0L, 0L);
	rp.SetDefaultValue(0L);
    rp.Release();

	// The HwChannel Property
	CComVariant _maxchanrange;
	_maxchanrange = (long)(((LDD*)m_ldd)->AnaChan[0].NAnChan) - 1;
    rp.Attach(_EngineChannelList,L"HwChannel",HWCHANNEL);
    rp.SetRange(0L, _maxchanrange);
    rp.Release();

	// The OutputRange Property
	double _minoutrangediff, _minoutrangesing;
	double _maxoutrangediff, _maxoutrangesing;
	double OutputRange[2];
	GetOutputRange(&_minoutrangediff, &_maxoutrangediff, &_minoutrangesing, &_maxoutrangesing);
	OutputRange[0] = _minoutrangediff;
	OutputRange[1] = _maxoutrangediff;
	CreateSafeVector(OutputRange,2,&var);
    rp.Attach(_EngineChannelList,L"outputrange",OUTPUTRANGE);
    rp->put_DefaultValue(var);
    rp.SetRange(OutputRange[0],OutputRange[1]);
    rp.Release();

	//////////////////////////////////////////////////////////////////////////////////////////////
	// NOTE - SETTING THE DEFAULTS FOR THE FOLLOWING TWO CHANNEL PROPERTIES DOES NOT WORK. THIS //
	//	IS SOMETHING WHICH IS GOING TO NEED TO BE LOOKED AT.									//
	//////////////////////////////////////////////////////////////////////////////////////////////
	// Native Offset
	/*
    rp.Attach(_EngineChannelList,L"NativeOffset",NATIVEOFFSET);
    rp.SetRange(0L, 0L);
	_default = 0.0;
	rp->put_DefaultValue(_default);
    rp.Release();

	// Native Scaling
	double _minscaling = (_maxoutrangesing - _minoutrangesing);	
	double _maxscaling = (_maxoutrangediff - _minoutrangediff);
    rp.Attach(_EngineChannelList,L"NativeScaling",NATIVESCALING);
    rp.SetRange(_minscaling,_maxscaling);
	rp.SetDefaultValue(0);
    rp.Release();
	*/

	return S_OK;
} // end of Open()


//////////////////////////////////////////////////////////////////////////////////////
// SetProperty()
//
// Called by the engine when a property is set
// An interface to the property along with the new value is passed to the method
//////////////////////////////////////////////////////////////////////////////////////
STDMETHODIMP Ckeithleyaout::SetProperty(long User, VARIANT * NewValue)  // return false for fail
{
	if (User)
	{
		// If the device is running, don't allow any registered properties to be modified.
		if (GetParent()->GetDevFromId(analogoutputMask + m_deviceID)!=NULL && 
			GetParent()->GetDevFromId(analogoutputMask + m_deviceID) !=this)
			return Error(_T("Keithley: The device is in use."));
		// Find the property from the user value
        CLocalProp* pProp=PROP_FROMUSER(User);

		variant_t *val = (variant_t*)NewValue;   // variant_t is a more friendly data type to work with
    
		////////////////////////////////////////////////////////////////
		// Which Properties have changed? 
		// Ideally a SWITCH, but we're using USER_VAL, which is dynamic.
		
		// Sample Rate
		if (User==USER_VAL(pSampleRate)) 
        {
			double newrate = *val;
			if(pClockSource == CLCK_SOFTWARE)
				return CswClockedDevice::SetProperty(User, NewValue);
			CalculateNewRate(newrate);	// Make sure it's within limits.
			*val = pSampleRate;
        }

		// Trigger Type
		if (User==USER_VAL(pTriggerType))
		{
			if ((long)(*val)==TRIGGER_HWDIGITAL)
			{
				pTriggerCondition->ClearEnumValues();
				pTriggerCondition->AddMappedEnumValue(TRIG_COND_RISING, L"Rising");
				pTriggerCondition->AddMappedEnumValue(TRIG_COND_FALLING, L"Falling");
				pTriggerCondition.SetDefaultValue(TRIG_COND_RISING);
				pTriggerCondition.SetRemote(TRIG_COND_RISING);
			} 
			else
			{
				pTriggerCondition->ClearEnumValues();
				pTriggerCondition->AddMappedEnumValue(TRIG_COND_NONE, L"None");
				pTriggerCondition.SetDefaultValue(TRIG_COND_NONE);
			}
		}
		
		// Repeat Output
		// Produce a warning about the engine buffer size.
		if (User==USER_VAL(pRepeatOutput))
		{
			if (((double)(*val) == INFINITY) || ((long)(*val) > 0))
					_engine->WarningMessage(CComBSTR("Keithley: To ensure that the repeated outputs are sequential,\nset the BufferingConfig so that the number of points output\nis an integer multiple of the buffer size."));
		}

		// Clock Source
		if (User == USER_VAL(pClockSource))
		{
			if((long)(*val) == CLCK_SOFTWARE)
			{
	
				// First Set the min and max samplerates for software clocking
				double maxSampleRate = (double)MIN_SW_SAMPLERATE;
				double minSampleRate = (double)MAX_SW_SAMPLERATE;
				
				pSampleRate.SetDefaultValue(CComVariant(100));
				pSampleRate = 100;
				pSampleRate.SetRange(minSampleRate,maxSampleRate);
				EnableSwClocking();

				// Remove Digital Start Triggers
				if(pTriggerType == TRIGGER_HWDIGITAL)
					_engine->WarningMessage(CComBSTR("Keithley: Digital Triggers are not supported in Software or External Clock modes.\nDigital trigger will be removed."));
				pTriggerType = TRIG_IMMEDIATE;
				pTriggerType->RemoveEnumValue(CComVariant(TRIGGER_HWDIGITAL));
			}
			else 
			{
				// Now re-set the service request so we don't get an error.
				delete m_pSR;
				m_pSR = (DL_ServiceRequest *) new DL_ServiceRequest;
				if (m_pSR != NULL)
				{
					memset(m_pSR, 0, sizeof(DL_ServiceRequest));
				}
				m_pSR->dwSize = sizeof(DL_ServiceRequest);
				m_pSR->device = m_deviceID;		// Device ID
				m_pSR->subsystem = AO;			// Analog input subsystem
				m_pSR->hWnd = GetParent()->GetHandle();
			
				// Re-set the Sample Rates
				m_aoTicPeriod = static_cast<float>(CalculateMicroSec());
				pSampleRate.SetDefaultValue(CComVariant(1000));
				pSampleRate.SetRange(CComVariant(m_minBoardSampleRate), CComVariant(m_maxBoardSampleRate));
				RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"minsamplerate", CComVariant(m_minBoardSampleRate)));	
				RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"maxsamplerate", CComVariant(m_maxBoardSampleRate)));	
				
				// And the digital start triggers
				pTriggerType->AddMappedEnumValue(TRIGGER_HWDIGITAL, L"HwDigital");

				CalculateNewRate(1000);
			}
		}   
		
		// OutOfDataMode
		if (User == USER_VAL(pOutOfDataMode))
		{
			_updateChildren = true; // Ensure that channel defaults are updated before starting
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
STDMETHODIMP Ckeithleyaout::SetChannelProperty(long UserVal, tagNESTABLEPROP * pChan, VARIANT * NewValue)
{
    int Index=pChan->Index-1;  // we use 0 based index
	variant_t& vtNewValue=reinterpret_cast<variant_t&>(*NewValue);
    
	// Check for valid Output Range
	if (UserVal == OUTPUTRANGE )
	{
        TSafeArrayAccess<double> NewRange(NewValue);
        RANGE_INFO *NewInfo;
        RETURN_HRESULT(FindRange( static_cast<float>(NewRange[0]),
			                      static_cast<float>(NewRange[1]), NewInfo));
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
				{
					_engine->WarningMessage(CComBSTR("Keithley: All channels configured to have the same polarity."));
				}
				SetAllPolarities(l_polarity);
			}
            m_chanGain[Index]=NewInfo->gain;
			
			AOCHANNEL *aochan=NULL;
            _EngineChannelList->GetChannelStructLocal(Index, (NESTABLEPROP**)&aochan);
            _ASSERTE(aochan);
			aochan->ConversionOffset=(m_polarity==POLARITY_BIPOLAR) ? 0 : 1<<15;
        }
        NewRange[0]=NewInfo->minVal;
        NewRange[1]=NewInfo->maxVal;
		_updateChildren = true;
	}
	if (UserVal == DEFAULTCHANVAL)
	{
		RETURN_HRESULT(UpdateDefaultChannelValue(Index, vtNewValue));
	}
	_updateChildren=true;
    return S_OK;
}

////////////////////////////////////////////////////////////////////////////
// SetAllPolarities()
// 
// This function changes all polarities of all channels to be the same.
// This function should be removed if (when) the engine supports mixed
// polarities.
////////////////////////////////////////////////////////////////////////////
void Ckeithleyaout::SetAllPolarities(short polarity)
{
    NESTABLEPROP *chan;
    AOCHANNEL *pchan;

    // Set the native data type for the subsystem
    if (polarity==POLARITY_UNIPOLAR)
    {
        // Native data type    
        _DaqHwInfo->put_MemberValue(CComBSTR(L"nativedatatype"), CComVariant(VT_UI2));	
    }
    else
	{
        _DaqHwInfo->put_MemberValue(CComBSTR(L"nativedatatype"), CComVariant(VT_I2));
	}

	// Change the channel ranges if necessary
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
		pchan=(AOCHANNEL*)chan;

        if (polarity==POLARITY_BIPOLAR)
		{
			pchan->VoltRange[0] = -pchan->VoltRange[1];
			pchan->ConversionOffset= 0;
			
			// Convert the internal gain: -ve for POLARITY_BIPOLAR, +ve for POLARITY_UNIPOLAR
			m_chanGain[i] = -abs(m_chanGain[i]);
		}
		else
		{
			pchan->VoltRange[0] = 0;
			pchan->ConversionOffset = 1 << ((((LDD*)m_ldd)->AnaChan[0].AnBits)-1);
			// Now convert the internal gain: -ve for POLARITY_BIPOLAR, +ve for POLARITY_UNIPOLAR
			m_chanGain[i] = abs(m_chanGain[i]);
		}
	}
	// Store the current polarity
	m_polarity = polarity;
}


///////////////////////////////////////////////////////////////////
// PutSingleValue()
//
// Called by the software clocked task.
///////////////////////////////////////////////////////////////////
HRESULT Ckeithleyaout::PutSingleValue(int chan,RawDataType value)
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
	SetupDriverLINXSingleValueIO(m_pSR,chan, m_chanGain[0], SYNC);
	PutDriverLINXAOData(m_pSR, (unsigned short*)&value ,	0,1,1);
	SELECTMYDRIVERLINX(m_driverHandle);
	DriverLINX(m_pSR);
	if (m_pSR->result != 0)
	{
		return CComCoClass<ImwDevice>::Error(TranslateResultCode(m_pSR->result));
	}
	return S_OK;
} 


/////////////////////////////////////////////////////////////////////////////
// InterfaceSupportsErrorInfo()
//
// Function indicates whether or not an interface supports the IErrorInfo..
//..interface. It is created by the wizard.
// Function is NOT MODIFIED by the adaptor programmer.
/////////////////////////////////////////////////////////////////////////////
STDMETHODIMP Ckeithleyaout::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IKeithleyAOut
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}


/////////////////////////////////////////////////////////////////////////////
// SetDaqHwInfo()
//
// Set the fields needed for DaqHwInfo. 
/////////////////////////////////////////////////////////////////////////////
HRESULT Ckeithleyaout::SetDaqHwInfo()
{
	LoadRangeInfo(); // Load up our input range info into m_validRanges
		
	///////////////////////////
	// Set the adaptor values:

	// Adaptor Name
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"adaptorname"), CComVariant(Ckeithleyadapt::ConstructorName)));
	
	// Bits
	short bits;
	bits = (short) ((LDD*)m_ldd)->AnaChan[0].AnBits; // Get the number of bits from the LDD
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"bits"), CComVariant( bits )));
	
	//Channel IDs
	CComVariant vids;	// Set up a variant to store the values in.
    CreateSafeVector((short*)NULL,(((LDD*)m_ldd)->AnaChan[0].NAnChan),&vids);	
    TSafeArrayAccess<short> chanids(&vids);
	for (int i=0;i<(((LDD*)m_ldd)->AnaChan[0].NAnChan);i++)		// loop through and create the values
    {
        chanids[i]=i;
    }
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"channelids"),vids));

	// Coupling - Hardcoded because none of the keithley boards support anything else.
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"coupling"), CComVariant(L"DC Coupled")));
	
	// Device Name - The device name is made up of three things:
	char tempstr[15] = "";
	char devname[25] = "";

	::ReturnMessageString(NULL, ((LDD*)m_ldd)->DevCap.ModelCode, (LPSTR)tempstr, 15);
	strcat(devname, tempstr);
	sprintf(tempstr, " (Device %d)", m_deviceID); // The words (Device x) hardcoded and the 
	strcat(devname, tempstr);					// number of the device in place of x.

	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"devicename"), CComVariant(devname)));
	
	// Device ID
    wchar_t idStr2[10];
	swprintf(idStr2, L"%d", m_deviceID );// Convert the Device id to a string, and then send it
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"id"), CComVariant(idStr2)));		
	
	// Output Ranges
    // this is a 2-d array of range values
    // there are unipolar and bipolar ranges 
    // both are numgains x 2, where numgains is the 
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
	
    SAFEARRAY *ps = SafeArrayCreate(VT_R8, 2, rgsabound); // use the SafeArrayBound to create the array
    if (ps==NULL) 
		throw "Failure to create SafeArray.";
	
	CComVariant voutrange; // setup our variant
    voutrange.parray=ps;
    voutrange.vt = VT_ARRAY | VT_R8;
	
    double *outRange, *min, *max; // The variable used to get the input range values
    
    HRESULT hr = SafeArrayAccessData(ps, (void **) &outRange);
    if (FAILED (hr)) 
    {
        SafeArrayDestroy (ps);
        throw "Failure to access SafeArray data.";
    }       
	
	min = outRange;
	max = outRange+m_numgains;
	
	// Iterate through the validRanges, and load Matlab up with the Input Ranges.
	for(RangeList_t::iterator rIt=m_validRanges.begin();rIt!=m_validRanges.end();rIt++)
	{
		*min++ = (*rIt).minVal;
		*max++ = (*rIt).maxVal;
	}
    SafeArrayUnaccessData (ps);
    RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"outputranges"), voutrange));
	
	//Sample Rate
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

	// Polarity and NativeDataType
	if (m_supportsUnipolar&&m_supportsBipolar)// Support Bipolar and unipolar?
	{
		RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"nativedatatype"), CComVariant(VT_I2)));	
        SAFEARRAY *ps = SafeArrayCreateVector(VT_BSTR, 0, 2); // Create the array for our strings
        if (ps==NULL) 
			throw "Failure to create SafeArray.";
		CComVariant val;
        // set the data type and values
        V_VT(&val)=VT_ARRAY | VT_BSTR;
        V_ARRAY(&val)=ps;
        CComBSTR *polarities; // create the pointer to the data string
        
        HRESULT hRes = SafeArrayAccessData (ps, (void **) &polarities); // Connect it to the safe array
        if (FAILED (hRes)) 
        {
            SafeArrayDestroy (ps);
			throw "Failure to access SafeArray data.";
        }
        
        polarities[0]=L"Unipolar"; // Set the data string values
        polarities[1]=L"Bipolar";
        
		RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"polarity"), val));
		
		SafeArrayUnaccessData (ps);
        val.Clear();    
	}
	else if(m_supportsBipolar)	// Just bipolar
	{
		RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"nativedatatype"), CComVariant(VT_I2)));	
		RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"polarity"), CComVariant(L"Bipolar")));
	}
    else 
	{
		RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"nativedatatype"), CComVariant(VT_UI2)));	
		RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"polarity"), CComVariant(L"Unipolar")));
	}
	
	// Sample Type - This value is hardcoded because all of the Keithley boards support scanning.
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"sampletype"),CComVariant(0L)));
	
	// total channels
	WORD numchannels = ((LDD*)m_ldd)->AnaChan[0].NAnChan; // Get the value from the LDD
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"totalchannels"),CComVariant(numchannels)));
	
	// Vendor Driver Description
	char driverdescrip[30]; // The place to store the driver description
	::ReturnMessageString(NULL, ((LDD*)m_ldd)->DevCap.VendorCode, (LPSTR)driverdescrip, 30);
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"vendordriverdescription"),CComVariant(driverdescrip)));
	
	//Vendor Driver Version
	//The following code does not work (always returns 0) due to a Keithley bug
/*
	WORD minmaxver;	// this contains the major version in the high byte and the minor version in the low byte
	BYTE minver, maxver;
	char driverver[10];
	minmaxver = ((LDD*)m_ldd)->DriverVersion;	// get the version
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

////////////////////////////////////////////////////////////////////////////////////
// SetParent()
//
// Description:
//	This function sets this objects pointer to its parent class.
////////////////////////////////////////////////////////////////////////////////////
void Ckeithleyaout::SetParent(MessageWindow * pParent)
{
    pParent->AddRef();
	m_pParent = pParent;
}


////////////////////////////////////////////////////////////////////////////////////
// GetParent()
//
// Description:
//	This function returns this objects pointer to its parent class.
////////////////////////////////////////////////////////////////////////////////////
MessageWindow * Ckeithleyaout::GetParent()
{
	return m_pParent;
}

////////////////////////////////////////////////////////////////////////////////////
// GetOutputRange
//
// Returns the Output ranges for the card
// The first parameter: The minimum differential value.
// The second parameter: The maximum differential value.
// The third parameter: The minimum single ended value.
// the fourth parameter: The maximum single ended value.
//////////////////////////////////////////////////////////////////////////////////////
void Ckeithleyaout::GetOutputRange(double *mindiff, double *maxdiff, double *minsing, double *maxsing)
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
	// Do the same as for the differential, but use the absolute value.
	for (i = m_validRanges.begin(); i != m_validRanges.end() ;i++)
    {
		if (mintemp > abs((*i).minVal))
			mintemp = abs((*i).minVal);
		if (maxtemp < abs((*i).maxVal))
			maxtemp = abs((*i).maxVal);
    }
	*minsing = mintemp;
	*maxsing = maxtemp;
}	

////////////////////////////////////////////////////////////////////////////////////
// PutSingleValues()
//
// This function outputs a single analog value to each channel in the list, using
// one DriverLINX call.
////////////////////////////////////////////////////////////////////////////////////
STDMETHODIMP Ckeithleyaout::PutSingleValues(VARIANT* values)
{              
	ERRORCODES Code;
	WORD ResultCode;
	CComBSTR _error;
	
	UpdateChans(true);
	
	// Reset the flags for our service request:
	m_pSR->taskFlags = 0;
	
    if ( V_ISARRAY (values) || V_ISVECTOR (values))
    {
        SAFEARRAY *ps = V_ARRAY(values);
        if (ps==NULL) 
            return CComCoClass<ImwDevice>::Error(_T("Keithley: Error creating Safe Array."));
        unsigned short *voltArray;
        HRESULT hr = SafeArrayAccessData (ps, (void **) &voltArray);
        if (FAILED (hr)) 
        {
            SafeArrayDestroy (ps);
            return CComCoClass<ImwDevice>::Error(_T("Keithley: Error accessing Safe Array data."));
        }
		
		if (!m_isInitialized)
		{
			SELECTMYDRIVERLINX(m_driverHandle);
			Code = InitializeDriverLINXSubsystem(m_pSR, &ResultCode);
			if (Code != DL_TRUE)	//Error occured
			{
				SafeArrayUnaccessData(ps);
				// Must cast to USHORT for CComBSTR::LoadString to work
				_error.LoadString((USHORT)InterpretDriverLINXError(Code));
				return CComCoClass<ImwDevice>::Error(_error);
			}
			if (ResultCode != 0)
			{
				SafeArrayUnaccessData(ps);
				char tempMsg[255];
				ReturnMessageString(NULL, ResultCode,tempMsg, 255 );
				return CComCoClass<ImwDevice>::Error(tempMsg);
			}
			m_isInitialized = true;
		}
		// Set up a single Service Request with ALL channels in default fastest sampling mode.
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
		AddChannelGainList(m_pSR, _nChannels, &_chanList[0], &m_chanGain[0], CHAN_SEDIFF_DEFAULT);
		// Buffers Group
		SELECTMYDRIVERLINX(m_driverHandle);
		AddSelectBuffers(m_pSR, 1, 1, _nChannels);
		// Flags: Don't tell anything
		m_pSR->taskFlags = (NO_SERVICESTART | NO_SERVICEDONE);
		SELECTMYDRIVERLINX(m_driverHandle);
		Code = PutDriverLINXAOData(m_pSR, &voltArray[0], 0 , _nChannels, 1);
		if (Code == DL_TRUE)
		{
			// If data was transferred into the buffers, submit Service Request.
			m_pSR->taskFlags = 0;
			if(m_pSR->result == 0)
			{
				SELECTMYDRIVERLINX(m_driverHandle);
				DriverLINX(m_pSR); // Execute the Service Request
				m_pSR->taskFlags = 0; //Reset them immediately!
			}
			if (m_pSR->result != 0)
			{
				SafeArrayUnaccessData(ps);
				char tempMsg[255];
				ReturnMessageString(NULL, m_pSR->result,tempMsg, 255 );
				return CComCoClass<ImwDevice>::Error(tempMsg);
			}
		}
		else
		{
			SafeArrayUnaccessData(ps);
			char tempMsg[255];
			ReturnMessageString(NULL, m_pSR->result,tempMsg, 255 );
			return CComCoClass<ImwDevice>::Error(tempMsg);
		}
        SafeArrayUnaccessData (ps);
    }
    else
        return CComCoClass<ImwDevice>::Error(_T("Keithley: Data must be passed in a Safe Array."));
	
    return S_OK;
}

////////////////////////////////////////////////////////////////////////////////////
// UpdateChans()
//
// This function overrides CswClockedDevice::UpdateChans. It updates the local 
// channellist and channel range variables with the current values.
////////////////////////////////////////////////////////////////////////////////////
HRESULT Ckeithleyaout::UpdateChans(bool ForStart)
{
    m_defaultChannelValues.resize(_nChannels);
    _chanList.resize(_nChannels);
    m_chanGain.resize(_nChannels);
	AOCHANNEL *aochan=NULL;

	for (int i=0; i<_nChannels; i++) 
	{    
		RETURN_HRESULT(_EngineChannelList->GetChannelStructLocal(i, (NESTABLEPROP**)&aochan));
		_chanList[i]=aochan->Nestable.HwChan;
		RANGE_INFO *NewInfo;
		RETURN_HRESULT(FindRange(static_cast<float>(aochan->VoltRange[0]),
			                     static_cast<float>(aochan->VoltRange[1]), NewInfo));
		m_chanGain[i]=NewInfo->gain;
		aochan->ConversionOffset=(m_polarity==POLARITY_BIPOLAR) ? 0 : 1<<((((LDD*)m_ldd)->AnaChan[0].AnBits)-1);
		RETURN_HRESULT(UpdateDefaultChannelValue(i,aochan->DefaultValue));
	}
	_updateChildren=false;
    return S_OK;
}

////////////////////////////////////////////////////////////////////////////////////
// FindRange()
//
// This function checks to see if the range passed to it is supported by the card.
// It returns either the selected range or the closest larger range.
////////////////////////////////////////////////////////////////////////////////////
HRESULT Ckeithleyaout::FindRange(float low, float high, RANGE_INFO *&pRange)
{
    if (low>high)
        return DE_INVALID_CHAN_RANGE;
    if (low==high)
    {
        return CComCoClass<ImwDevice>::Error(_T("Keithley: Low value must not be the same as high value."));
    }

    pRange=NULL;
    double range=HUGE_VAL;
    // search all reanges (saves having to include a sort (sort by what? range.)
    for (RangeList_t::iterator i=m_validRanges.begin();i!=m_validRanges.end();i++)
    {
        if ((*i).minVal<=low && (*i).maxVal >=high && range>high-low)
        {
            // range is valid and better 
            pRange=&(*i);
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
// This routine is used to load the m_validRanges variable with the input  
// range values from the LDD. It also calculates the gain for the specific 
// input range.
///////////////////////////////////////////////////////////////////////////////
HRESULT Ckeithleyaout::LoadRangeInfo()
{
    std::vector<short> ranges;
	
	//	RANGE_INFO *NewInfo;
	float _gain;
	if (((LDD*)m_ldd)->AnaChan[0].lpAnGainMult != NULL)
	{
		double _minval, _maxval;
		for ( int loop = 0; loop < m_numgains; loop++) // This loops through the valuse to check which  
		{										// polarities we support
			_minval = ((LDD*)m_ldd)->AnaChan[0].lpAnGainMult->ArrayList[loop].min;
			_maxval = ((LDD*)m_ldd)->AnaChan[0].lpAnGainMult->ArrayList[loop].max;
			
			if( (_minval <0) && (_maxval > 0) ) // Bipolar??
				m_supportsBipolar = true;
			
			if( (_minval == 0) && (_maxval>0) ) // Unipolar??
				m_supportsUnipolar = true;
		}
		
		if(m_supportsBipolar&&m_supportsUnipolar)	// If there are bipolar and unipolar gains, they need to be separated 
		{							// with unipolar occuring first.
			for(loop = (m_numgains/2); loop < m_numgains ; loop++)
			{
				// Get the Gains and place them in the array.
				//			NewInfo = new RANGE_INFO;
				RANGE_INFO NewInfo;
				
				NewInfo.minVal = RoundRange(((LDD*)m_ldd)->AnaChan[0].lpAnGainMult->ArrayList[loop].min);
				NewInfo.maxVal = RoundRange(((LDD*)m_ldd)->AnaChan[0].lpAnGainMult->ArrayList[loop].max);
				
				NewInfo.gainCode = ((LDD*)m_ldd)->AnaChan[0].lpAnGainMult->ArrayList[loop].GainCode;
				Code2Gain( m_deviceID, m_subSystem, 
					NewInfo.gainCode, &_gain);	
				NewInfo.gain = _gain;
				m_validRanges.push_back(NewInfo);
			}
			
			for(loop = 0; loop < (m_numgains/2) ; loop++)
			{
				// Get the Gains and place them in the array.
				//			NewInfo = new RANGE_INFO;
				RANGE_INFO NewInfo;
				
				NewInfo.minVal = RoundRange(((LDD*)m_ldd)->AnaChan[0].lpAnGainMult->ArrayList[loop].min);
				NewInfo.maxVal = RoundRange(((LDD*)m_ldd)->AnaChan[0].lpAnGainMult->ArrayList[loop].max);
				
				NewInfo.gainCode = ((LDD*)m_ldd)->AnaChan[0].lpAnGainMult->ArrayList[loop].GainCode;
				Code2Gain( m_deviceID, m_subSystem, 
					NewInfo.gainCode, &_gain);	
				NewInfo.gain = _gain;
				m_validRanges.push_back(NewInfo);
			}
		}
		else // Else just go through the whole list and plugem in.
		{
			for(loop = 0; loop < m_numgains ; loop++)
			{
				// Get the Gains and place them in the array.
				//			NewInfo = new RANGE_INFO;
				RANGE_INFO NewInfo;
				
				NewInfo.minVal = RoundRange(((LDD*)m_ldd)->AnaChan[0].lpAnGainMult->ArrayList[loop].min);
				NewInfo.maxVal = RoundRange(((LDD*)m_ldd)->AnaChan[0].lpAnGainMult->ArrayList[loop].max);
				
				NewInfo.gainCode = ((LDD*)m_ldd)->AnaChan[0].lpAnGainMult->ArrayList[loop].GainCode;
				Code2Gain( m_deviceID, m_subSystem, 
					NewInfo.gainCode, &_gain);	
				NewInfo.gain = _gain;
				m_validRanges.push_back(NewInfo);
			}
		}
	}
	else
	{
		// The board only has a MinMax Range table, so build it up using this
		RANGE_INFO NewInfo;
		NewInfo.minVal = RoundRange(((LDD*)m_ldd)->AnaChan[0].lpAnMinMaxRange->min);
		NewInfo.maxVal = RoundRange(((LDD*)m_ldd)->AnaChan[0].lpAnMinMaxRange->max);
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
// This rounds numbers above 1 to three decimal places and numbers below 1
// to 4 decimal places.
// The reason for this, is that DriverLINX returns maximum voltage range values 
// as 9.99984 etc instead of 10.
///////////////////////////////////////////////////////////////////////////////
double Ckeithleyaout::RoundRange(double inputvalue)
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
	tempvalue =  ceil(tempvalue*1e2)/1e2; // round the value.
	return (tempvalue / pow(10, count));
}


///////////////////////////////////////////////////////////////////////////////
// Start()
//
// Called by the engine when the user starts an acquisition task.
///////////////////////////////////////////////////////////////////////////////
STDMETHODIMP Ckeithleyaout::Start()
{
	// We don't handle software clocking in this method, pass on to owner.
	if (pClockSource == CLCK_SOFTWARE)
		return OutputType::Start();

	// Check to see if we are already added to the message window.
	if(GetParent()->IsOpen((analogoutputMask + m_deviceID)))
		return CComCoClass<ImwDevice>::Error(CComBSTR("Keithley: The device is in use."));

	WORD ResultCode;
	CComBSTR _error;
	_samplesOutput=0;
	m_triggerPosted = false;
    if (_updateChildren) 
    {
        RETURN_HRESULT(UpdateChans(true));
    }

	// Initialise the subsystem. Must do this for buffered acquisition.
	SELECTMYDRIVERLINX(m_driverHandle);
	RETURN_CODE(InitializeDriverLINXSubsystem(m_pSR, &ResultCode));
	m_isInitialized = true;

	// All of the configuration is done in SetupSR
	RETURN_HRESULT(SetupSR(true));

	// Audit the Service Request to trap silly problems:
	Ops ops = m_pSR->operation;
	m_pSR->operation = AUDITONLY;
	SELECTMYDRIVERLINX(m_driverHandle);
	DriverLINX(m_pSR);
	if (m_pSR->result != 0)
	{
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
// The trigger method, called automatically after Start if the TriggerType is Immediate
// otherwise called by the user.
///////////////////////////////////////////////////////////////////////////////////////
STDMETHODIMP Ckeithleyaout::Trigger()
{
	AUTO_LOCK;
	CComBSTR _error;
	
	ATLTRACE("In AO Trigger.\n");

	// Add device ID to window handler.
	//DEBUG: ATLTRACE("AO Adding Device to Window.\n");
	if (GetParent()->AddDev((analogoutputMask + m_deviceID),this))
	{
		return Error(_T("Keithley: The device is in use."));
	}
	
	// Now that we've added this device to the window, pass it on if we don't handle triggers.
	if (pClockSource == CLCK_SOFTWARE)
		return OutputType::Trigger();

	// We set the daqStatus to Running before starting DriverLINX because we receive 
	// a message instantaneously in the message handler thread.
	m_daqStatus = STATUS_RUNNING;

	SELECTMYDRIVERLINX(m_driverHandle);
	DriverLINX(m_pSR);
	if (m_pSR->result != 0)
	{
		m_daqStatus = STATUS_STOPPED;
		// Now remove the device from the message window:
        GetParent()->DeleteDev((analogoutputMask + m_deviceID));
		return CComCoClass<ImwDevice>::Error(TranslateResultCode(m_pSR->result));
	}
	//_running = true;
    return S_OK;
}

////////////////////////////////////////////////////////////////////////////////////
// LoadData()
//
// Transfer data from DAQ engine to DriverLINX buffers
////////////////////////////////////////////////////////////////////////////////////
void Ckeithleyaout::LoadData(UINT bufIndex )
{
	CComBSTR _error;
    BUFFER_ST* pBuf=NULL;
	unsigned short* pLoadPtr;
	long matlabValidPoints = 0;

	HRESULT hRes = _engine->GetBuffer(0, &pBuf);
	if (pBuf==NULL)
	{
		ATLTRACE("Buffer Is NULL.\n");
		unsigned short* dummyBuffer = (unsigned short*)_alloca(m_dlBufferPoints * sizeof(unsigned short));
		for (int i = 0; i<m_dlBufferPoints; i++)
		{
			dummyBuffer[i] = m_defaultChannelValues[i % _nChannels];
		}
		pLoadPtr = dummyBuffer;
	}  
	else 
	{
		ATLTRACE("Got MATLAB buffer.\n");
		pLoadPtr = (unsigned short*) pBuf->ptr;
		matlabValidPoints = pBuf->ValidPoints;// / _nChannels;
		if(pBuf->Flags & BUFFER_IS_LAST)
		{
			//DEBUG: ATLTRACE("Buffer Is Last.\n");
			// Fill the ODM values. If ODM is ODM_HOLD, store the last values...
			if (pOutOfDataMode == ODM_HOLD)
			{
				// We need to grab the last valid value from this buffer
				// We store them in m_defaultChannelValues, as we don't really need the defaults!!!
				unsigned short* plast = (unsigned short *)(pBuf->ptr) + pBuf->ValidPoints - _nChannels;
				for (int i=0; i<_nChannels; i++)
				{
					m_defaultChannelValues[i] = plast[i];
				}
			}
			
			// Now fill the engine buffer with ODM values
			unsigned short* pfill =  (unsigned short*)pBuf->ptr;
			for (int i=pBuf->ValidPoints; i<(m_dlBufferPoints); i++)
			{
				pfill[i]=m_defaultChannelValues[i % _nChannels];
			}
			// That's the buffer filled.
		}
	}
	// Now send this buffer to DriverLINX
	SelectDriverLINX(m_driverHandle);
	ERRORCODES Code = PutDriverLINXAOData(m_pSR, pLoadPtr, bufIndex,
		_nChannels, (m_dlBufferPoints / _nChannels));
	if (Code != DL_TRUE)
	{
		// Must cast to USHORT for CComBSTR::LoadString to work
		_error.LoadString((USHORT)InterpretDriverLINXError(Code));
		CComCoClass<ImwDevice>::Error(_error);
	}
	m_validPointsToDL += matlabValidPoints;
	//DEBUG: ATLTRACE("Valid Points From Matlab = %d : ", matlabValidPoints);
	//DEBUG: ATLTRACE("Valid Points To DriverLINX = %d\n", m_validPointsToDL);
	if (pBuf!=NULL)
	{
		pBuf->Flags = 0; // Reset the flag for last buffer bug in engine.
		_engine->PutBuffer(pBuf);
	}
}

///////////////////////////////////////////////////////////////////////////////////////
// ReceivedMessage()
//
// Deal with the messages sent to the message window by DriverLINX
///////////////////////////////////////////////////////////////////////////////////////
void Ckeithleyaout::ReceivedMessage(UINT wParam, long lParam)
{
	CComBSTR _error;
	// WORD ResultCode;
	const int Length = 80;
	// ERRORCODES Code;
	CComBSTR _msg;
	const UINT bufIndex = getBufIndex( lParam );
	//DEBUG: ATLTRACE("Received Message for AO. wParam = %d bufIndex = %d\n",wParam,bufIndex);
	switch (LOWORD(wParam))
	{
	case DL_SERVICESTART:
		//DEBUG: ATLTRACE("AO Service Start Message Received.\n");
		break;
	case 0x8001:	// Catch the Unmasked service done message.
	case DL_SERVICEDONE:
		//DEBUG: ATLTRACE("AO Service Done Message Received.\n");
		break;
	case DL_TIMERTIC:
		//DEBUG: ATLTRACE("AO Timer Tic Message Received.\n");
		break;
	case DL_CRITICALERROR:
		//DEBUG: ATLTRACE("AO Critical Error Message Received.\n");
		_engine->DaqEvent(EVENT_ERR, -1, _samplesOutput, NULL);
		Stop();
		break;
	case DL_BUFFERFILLED:
		//DEBUG: ATLTRACE("Buffer %d empty.\n", bufIndex);
		if (m_daqStatus == STATUS_RUNNING)
		{
			m_actualPointsToFIFO += m_dlBufferPoints;
			UpdateSamplesOutput();
			//DEBUG: ATLTRACE("The Samples Output = %d", _samplesOutput);
			//DEBUG: double messagetime;             
			//DEBUG: _engine->GetTime(&messagetime);
			//DEBUG: ATLTRACE("Actual Points sent to FIFO = %d ", m_actualPointsToFIFO);
			//DEBUG: ATLTRACE("at time %f, ", messagetime);
			//DEBUG: ATLTRACE("with %d points output.\n",_samplesOutput);
			//Should we stop? Strange heuristic due to FIFO interference!
			if ((m_actualPointsToFIFO - m_validPointsToDL) >= m_fifoSize)
			{
				// The last buffer from MATLAB has already been loaded. 
				Stop();
			}
			else
			{
				// We're not out of buffers. Fill this one up from MATLAB
				LoadData(bufIndex);
			}
			// Any trigger events to send to MATLAB?
			if (m_triggering && (pTriggerType==TRIGGER_HWDIGITAL) && !m_triggerPosted)        
			{
				double time;             
				m_triggering=false;
				m_triggerPosted = true;
				_engine->GetTime(&time);
				double triggerTime = time - m_actualPointsToFIFO/(pSampleRate * _nChannels);
				_engine->DaqEvent(EVENT_TRIGGER, triggerTime,0 , NULL);
			}
		}
		break;
		
	case DL_DATALOST:
		//DEBUG: ATLTRACE("AO Data Lost Message Received.\n");
		_engine->DaqEvent(EVENT_DATAMISSED, -1, _samplesOutput,NULL);
		Stop();
		break;
	}
}


////////////////////////////////////////////////////////////////////////
// Stop
//
// Stop the analog output session
////////////////////////////////////////////////////////////////////////
STDMETHODIMP Ckeithleyaout::Stop()
{
	if (pClockSource == CLCK_SOFTWARE)
	{
		GetParent()->DeleteDev((analogoutputMask + m_deviceID));
		return OutputType::Stop();
	}

	AUTO_LOCK;
	if (m_daqStatus == STATUS_RUNNING)
	{
		SELECTMYDRIVERLINX(m_driverHandle);
		WORD ResultCode = StopDriverLINXSR(m_pSR);
		if(ResultCode !=0)
		{
			// Just issue a warning here!
			char tempMsg[255];
			ReturnMessageString(NULL, ResultCode,tempMsg, 255 );
			_engine->WarningMessage(CComBSTR(tempMsg));
		}
		m_daqStatus = STATUS_STOPPED;
		_engine->DaqEvent(EVENT_STOP, -1, _samplesOutput,NULL);
		GetParent()->DeleteDev((analogoutputMask + m_deviceID));
	}
	//_running = false;
	return S_OK;
}


////////////////////////////////////////////////////////////////////////
// UpdateDefaultChannelValue
//
// Store default channel values in local variable for fast access during
// acquisition tasks.
////////////////////////////////////////////////////////////////////////
HRESULT Ckeithleyaout::UpdateDefaultChannelValue(int channel,double value)
{
    CComPtr<IChannel> pcont;
    RETURN_HRESULT(GetChannelContainer(channel, &pcont));
    CComVariant var;
    RETURN_HRESULT(pcont->UnitsToBinary(value,&var));
    m_defaultChannelValues[channel]=var.iVal;
    return S_OK;
}


////////////////////////////////////////////////////////////////////////
// UpdateSamplesOutput
//
// Provide the engine with information on the samples sent to the driver
////////////////////////////////////////////////////////////////////////
void Ckeithleyaout::UpdateSamplesOutput()
{ 
     _samplesOutput= min(m_actualPointsToFIFO, m_validPointsToDL )/_nChannels;
}


////////////////////////////////////////////////////////////////////////
// CalculateMaxSampleRate
//
// Call DriverLINX with a single channel unity gain to find max sample 
// rate.
////////////////////////////////////////////////////////////////////////
double Ckeithleyaout::CalculateMaxSampleRate( BOOL firstTime )
{
	CComBSTR _error;
	double period = 0;

	if (!firstTime)
	{
		//Setup the service request in the same way as the start method, but don't load data!
		SetupSR(false);
	}
	else
	{
		// Start and Stop events
		SELECTMYDRIVERLINX(m_driverHandle);
		AddStartEventOnCommand(m_pSR);
		SELECTMYDRIVERLINX(m_driverHandle);
		AddStopEventOnCommand(m_pSR);
		//Setup Transfer Mode
		// Transfer Mode can be DMA or Interrupts. For now, keep it DMA
		SELECTMYDRIVERLINX(m_driverHandle);
		AddRequestGroupStart(m_pSR, ASYNC);
		SELECTMYDRIVERLINX(m_driverHandle);
		AddTimingEventDefault(m_pSR, 1000.0);
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
		for (int i = 0; i < 1; i++)
		{
			SELECTMYDRIVERLINX(m_driverHandle);
			m_pSR->channels.chanGain[i].gainOrRange = 
				Gain2Code(m_deviceID, m_subSystem, 1);		
		}
		// Add select Buffer Group
		SELECTMYDRIVERLINX(m_driverHandle);
		AddSelectBuffers(m_pSR, 1,1000,1);
	}

	//Now calculate the minimum sampling period for the service request
	SELECTMYDRIVERLINX(m_driverHandle);
	DLMinPeriod(m_pSR);
	if (m_pSR->result != 0)
	{
		_engine->WarningMessage(TranslateResultCode(m_pSR->result));
	}
	if (!(Tics2Sec(m_pSR->timing.u.rateEvent.period , &period)))
	{
		_engine->WarningMessage(CComBSTR("Keithley: Error occured while calculating maximum SampleRate.\nMaximum SampleRate may not be valid."));
	}
	return (1.0/period);
}


////////////////////////////////////////////////////////////////////
// CalculateNewRate
//
// Calculate the new sample rate based on number of channels only.
////////////////////////////////////////////////////////////////////
void Ckeithleyaout::CalculateNewRate(double newrate)
{
	// NOTE: This algorithm assumes min channelskew for analog output.

    // Make sure channel is at least 1
    long nChannels;
    if ( _nChannels > 0 )
        nChannels = _nChannels;
    else
        nChannels = 1;

    // Recalculate max sample rate based on number of channels
	double maxSR = m_maxBoardSampleRate/nChannels;
	maxSR = 1/QuantiseValue(1/maxSR);
	pSampleRate.SetRange(CComVariant(m_minBoardSampleRate), CComVariant(maxSR));
	
    // Check newrate against max sample rate
    if (newrate > maxSR)
	{
		_engine->WarningMessage(CComBSTR(L"Keithley: Reducing sampling rate based on new limits."));
		newrate = maxSR;
	}

	// If we're violating burst mode clock requirements, fix: but only if we support burst mode clocking
	if (((newrate*nChannels) > m_burstModeClockFreq) && m_supportsBurstMode)
	{
		newrate = m_burstModeClockFreq/_nChannels;
	}
    
	pSampleRate = newrate;
}


////////////////////////////////////////////////////////////////////////////////
// ChildChange
//
// Called by the engine whenever a channel property changes.
////////////////////////////////////////////////////////////////////////////////
STDMETHODIMP Ckeithleyaout::ChildChange(DWORD typeofchange, NESTABLEPROP *pChan)
{
	if ((typeofchange & CHILDCHANGE_REASON_MASK)== ADD_CHILD)	//Do stuff before we add the channel	
    {
		if (_nChannels >= m_channelGainQueueSize)
		{
			return Error(_T("Keithley: Channel Gain Queue Full."));
		}
		// Now check to see that the new channel is not already defined.
		AOCHANNEL* newAOChan=reinterpret_cast<AOCHANNEL*>(pChan);
		AOCHANNEL *aochan=NULL;
		for (int i=0; i<_nChannels; i++) 
		{    
			RETURN_HRESULT(_EngineChannelList->GetChannelStructLocal(i, (NESTABLEPROP**)&aochan));
			if (newAOChan->Nestable.HwChan == aochan->Nestable.HwChan)
				return Error(_T("Keithley: Duplicate channels not allowed in analogoutput."));
		}
    }
    if (typeofchange & END_CHANGE)
    {
		// Do Stuff after we have added the channel.
		long numChans; // First we need to update the number of channels that have been added, by querying
		_EngineChannelList->GetNumberOfChannels(&numChans); // the engine.
		_nChannels=numChans; // Put it in the local variable _nChannels
		
		UpdateChans(true); // Then we udate all related channel information
		// The number of channels affects the valid sample rates
		if(pClockSource != CLCK_SOFTWARE)
		{   
			CalculateNewRate(pSampleRate); 

			/*			
			if (_nChannels > 0)
			{
				m_maxSampleRate = CalculateMaxSampleRate();
				pSampleRate.SetRange(m_minSampleRate, (m_maxSampleRate/_nChannels));
			}
			else
			{
				m_maxSampleRate = CalculateMaxSampleRate(true);
				pSampleRate.SetRange(m_minSampleRate, m_maxSampleRate);
			}
			*/
		}
    }
    return S_OK;
}


////////////////////////////////////////////////////////////////////////////////
// TranslateResultCode()
//
// Returns an error string from a DriverLINX error code.
////////////////////////////////////////////////////////////////////////////////
CComBSTR Ckeithleyaout::TranslateResultCode(UINT resultCode)
{
	char tempMsg[255];
	char kTempMsg[255];
	ReturnMessageString(NULL, m_pSR->result,tempMsg, 255 );
	sprintf(kTempMsg, "Keithley: %s", tempMsg);
	return CComBSTR(kTempMsg);
}


double Ckeithleyaout::CalculateMicroSec()
{
	WORD ResultCode = 0;
	CComBSTR _error;
	
    short defAITimerChannel = ((LDD *)m_ldd)->AnaChan[0].AnDefaultTimingChan;

	if (defAITimerChannel < 0)
	{
		// Use the default timer channel on the board
		defAITimerChannel = ((LDD *)m_ldd)->CTChan.CTDefaultTimingChan;
		if (defAITimerChannel < 0)
		{
			_engine->WarningMessage(CComBSTR("Keithley: No onboard clock detected! Cannot determine minimum sample rate!"));
			return 10e-6;	// Assume 10uS. Probably wrong, but no alternative.
		}
	}
	return (((LDD *)m_ldd)->CTChan.lpCTCapabilities[defAITimerChannel].microseconds * 1e-6);
}

double Ckeithleyaout::CalculateMinSampleRate( UINT countersize )
{
	double minsr = 1.0/(QuantiseValue((m_aoTicPeriod * (pow(2,countersize) - 1)), false));

	/// The next code adds a safety factor to the minimum sample rate of 0.1%
	//   The reason we do this is because we have found a floating point error in calculating the
	//   minimum sample rate for certain boards (KPCI-3104, KPCI-3110).
	double safety = (minsr * 0.1) / 100;

	minsr += safety;
	
	return minsr;
}


HRESULT Ckeithleyaout::LoadINIInfo()
{
    char Section[16];
	char fname[512];
    
    // we expect the ini file to be in the same directory as the application,
    // namely, this DLL. It's the only way to find the file if it's not
    // in the windows subdirectory
    if (GetModuleFileName(_Module.GetModuleInstance(), fname, 512)==0)
        return E_FAIL;
    // replace .dll with .ini
    strrchr(fname, '.' )[1]='\0';
    strcat(fname,"ini"); 
    // create a key to search on - The Model Name.
    ::ReturnMessageString(NULL, ((LDD*)m_ldd)->DevCap.ModelCode, (LPSTR)Section, 16);
	m_clockDividerWidth = GetPrivateProfileInt(Section, "aoclockdivwidth", 0, fname);
	m_chanSkew = GetPrivateProfileDouble(Section, "aochanskew", 0, fname);
	m_fifoSize = GetPrivateProfileInt(Section, "aofifosize", 0, fname);
	m_supportsBurstMode = GetPrivateProfileInt(Section, "aoburstmode", 0, fname);
    return S_OK;
}


////////////////////////////////////////////////////////////////////
// SetupSR()
//
// Sets up the DriverLINX service request based on adaptor settings.
// If the argument is true, we're about to start acquisition tasks.
// Otherwise, we're doing this to check a property.
/////////////////////////////////////////////////////////////////////
HRESULT Ckeithleyaout::SetupSR(bool forStart)
{
	// Flags: Safety catch for something that breaks if the flags are set:
	m_pSR->taskFlags = 0;

	// Triggers
	if (pTriggerType == TRIGGER_HWDIGITAL)
	{
		m_triggering = true;
		SELECTMYDRIVERLINX(m_driverHandle);
		AddStartEventDigitalTrigger(m_pSR, DI_EXTTRG, 1, 0, (pTriggerCondition==TRIG_COND_RISING? 0 : 1)); // (SR, Channel, Mask, Pattern)
	}
	else
	{
		SELECTMYDRIVERLINX(m_driverHandle);
		AddStartEventOnCommand(m_pSR);
	}

	SELECTMYDRIVERLINX(m_driverHandle);
	AddStopEventOnCommand(m_pSR); // Output data until we tell DriverLINX to stop.

	// Transfer Mode can be DMA or Interrupts. For now, keep it DMA
	// DMA done automatically by this request!
	SELECTMYDRIVERLINX(m_driverHandle);
	AddRequestGroupStart(m_pSR, ASYNC);

	// Setup Channel Gain list
	SELECTMYDRIVERLINX(m_driverHandle);
	AddChannelGainList(m_pSR, _nChannels, &_chanList[0], &m_chanGain[0], CHAN_SEDIFF_DEFAULT);

	// Setup Timing to be burst mode, fastest sample time
	if ((_nChannels >1) && m_supportsBurstMode)
	{
		SELECTMYDRIVERLINX(m_driverHandle);
		RETURN_CODE(AddTimingEventBurstMode(m_pSR, _nChannels, static_cast<float>(pSampleRate), m_burstModeClockFreq));
	}
	else
	{
		SELECTMYDRIVERLINX(m_driverHandle);
		RETURN_CODE(AddTimingEventDefault(m_pSR, static_cast<float>(pSampleRate * _nChannels)));
	}

	// If we're starting the acquisition, and using external clocks, set it.
	if((pClockSource == CLCK_EXTERNAL) && (forStart))
	{
		m_pSR->timing.u.rateEvent.clock = EXTERNAL;
	}

	// Calculate buffer sizes.
	_engine->GetBufferingConfig(&m_engineBufferSamples, NULL);
	m_dlBufferPoints = m_engineBufferSamples * _nChannels; 
	UINT numDLBuffersInFIFO = m_fifoSize / m_dlBufferPoints; 
	if ((m_engineBufferSamples == 1) | !m_usingDMA)
	{
		// If there is one sample per buffer set the transfer mode to interrupt
		// since you have to have at least two samples per buffer in DMA.
		// If MATLAB sets the buffer size to 1 sample, you should be sampling slowly enough
		// that interrupt sampling is OK
		m_pSR->mode = INTERRUPT;
		pTransferMode = TRANSFER_INTERRUPTS;
		m_usingDMA = false;
	}
	
	UINT fifoBufferMultiple = 2; // For safety, store at least two fifos worth of samples.
	
	int numDLBuffers = fifoBufferMultiple * numDLBuffersInFIFO;
	if (numDLBuffers < 2) // Ensure that we always have at least two DriverLINX buffers
	{
		numDLBuffers = 2;
	}
	// We are allowed a max of 255 DL buffers, so check and post warning if incorrect.
	if (numDLBuffers > 255)
	{
		UINT minBufSize = static_cast<UINT>(ceil( static_cast<double>(fifoBufferMultiple*m_fifoSize)/255 ));
		char temp[255];
		sprintf(temp, "Keithley: BufferingConfig may be too small for safe internal buffer sizes (> %d points per buffer recommended).", 
			minBufSize);
		_engine->WarningMessage(CComBSTR(temp));
		numDLBuffers = 255;
	}
	
	// Initialise Buffering
	SELECTMYDRIVERLINX(m_driverHandle);
	AddSelectBuffers(m_pSR, numDLBuffers, (m_dlBufferPoints / _nChannels), _nChannels);

	if (forStart)
	{
		// Reset the buffer count and internal counts.
		m_pSR->status.u.ioStatus.bufCount = 0;
		m_validPointsToDL = 0;
		m_actualPointsToFIFO = 0;
		// Load all DriverLINX buffers and wait for trigger command.
		for (int i=0; i<numDLBuffers; i++)
		{
			LoadData(i);
		}
	}
	return S_OK;
}

//////////////////////////////////////////////////////////////////////
// Tics2Sec
//
// Conversion from clock tics to seconds. Rewritten version of 
// DriverLINX function.
//////////////////////////////////////////////////////////////////////
bool Ckeithleyaout::Tics2Sec( double Tics, double* Sec )
{
	*Sec = Tics * m_aoTicPeriod;
	return true;
}

//////////////////////////////////////////////////////////////////////
// Sec2Tics
//
// Conversion from seconds to clock tics. Rewritten version of 
// DriverLINX function to get around a bug in their code.
//////////////////////////////////////////////////////////////////////
UINT Ckeithleyaout::Sec2Tics(double secs)
{
	UINT tics = static_cast<UINT>((secs / m_aoTicPeriod) + 0.5f);
	if ((tics == 0)&&(secs != 0.0))
		tics = (UINT)(pow(2,m_clockDividerWidth)-1);
	return tics;
}

//////////////////////////////////////////////////////////////////////
// QuantiseValue
//
// Quantise a given value to clock tics. Returns a float for
// DriverLINX compatibility.
///////////////////////////////////////////////////////////////////////
double Ckeithleyaout::QuantiseValue(double valSecs, bool performcheck)
{
	double reqSecs = valSecs;
	double newtics = Sec2Tics(reqSecs);
	Tics2Sec(newtics, &reqSecs);
	// Check if we're within 0.1%?
	if ((reqSecs > valSecs*1.001) && performcheck)
	{
		Tics2Sec((newtics - 1), &reqSecs);
	}
	return (double) reqSecs;
}
