// #$Demo$#Out.cpp : Implementation of C#$Demo$#Aout
// Copyright 2002-2003 The MathWorks, Inc.
// $Revision: 1.1.6.3 $  $Date: 2003/08/29 04:44:26 $

#include "stdafx.h"
#include "#$Demo$#.h"
#include "#$Demo$#Aout.h"
#include "#$Demo$#Adapt.h"
#include "#$Demo$#PropDefs.h"

/////////////////////////////////////////////////////////////////////////////
// C#$Demo$#Aout()  default constructor for the Analog output subsystem object
//
// Function performs all the necessary initializations.
//
// Function is MODIFIED for ALL adaptors.
//
// Review TO_DO/END TO_DO sections and make the appropriate changes
//
/////////////////////////////////////////////////////////////////////////////

C#$Demo$#Aout::C#$Demo$#Aout()
{
// Initialize class data members
	
	// TODO  	ADD CODE FOR INITIALIZATION 
	//			AS REQUIRED BY THE ADAPTOR PROGRAM AND THE HARDWARE
	//
	// END TO_DO

} // end of default constructor


/////////////////////////////////////////////////////////////////////////////
// Open()	:	local function
//
// This function is called by the C#$Demo$#Adapt::OpenDevice() during the Analog output
// subsystem object creation process. This function is called when the user enters
// "analogoutput('<this_adaptor_name>', ID)" at the MATLAB command line.
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
HRESULT C#$Demo$#Aout::Open(IUnknown *Interface,long ID)
{
	// Call through the hierarchical class chain: 
	// C#$Demo$#AOUT::Open() -> CmwDevice::Open()
	
	// CmwDevice::Open() defines CmwDevice::_engine which is the global pointer to the DAQ ENGINE	
	RETURN_HRESULT(TBaseObj::Open(Interface));

	// Configure DAQHWINFO properties
	RETURN_HRESULT(SetDaqHwInfo());

	// ************************************************************	
	// *** Configure COMMON Analog Input object base properties ***
	// ************************************************************
	
	// Define temporary variables
	HRESULT hRes; 
	double range[2];
	CComVariant val;
	CComPtr<IProp> IPropPtr;

	// TODO: Determine if software clocking is to be provided	
	//  Enable Software Clocking
	EnableSwClocking(true);

	// TODO: Set the ClockSource property values to reflect software clock
	pClockSource.Attach(_EnginePropRoot,L"ClockSource");
	pClockSource->AddMappedEnumValue(CLOCKSOURCE_SOFTWARE, L"Software"); 
	pClockSource->RemoveEnumValue(CComVariant(L"internal")); // Device has no driver clocking
	pClockSource.SetDefaultValue(CLOCKSOURCE_SOFTWARE); // Default Value
	pClockSource = CLOCKSOURCE_SOFTWARE;

	// TODO: Set SampleRate property parameters
	// These values are hardcoded, but should be set as needed	
	pSampleRate.Attach(_EnginePropRoot,L"SampleRate");
	pSampleRate.SetDefaultValue(100); // Default value
    pSampleRate = 100;	// Current value
	pSampleRate.SetRange(1,500); // Min and Max range

 	// TODO: Set OutputType property parameters
	pOutputType.Attach(_EnginePropRoot, L"OutputType");
	pOutputType->AddMappedEnumValue(0, L"Simulated");

#$AddCode$#	
	
	// **************************************************************************
	// *** Configure ADAPTOR SPECIFIC properties for the Analog Input objects ***
	// **************************************************************************
	
#$AddDevSpecificCode#$
	
	// **********************************
	// *** Configure Channel Property ***
	// **********************************
	
	// Channel Properties are handled slightly differently in that, 
	// local variables aren't generally created for each channel property for each channel.
	// The general case will be to set the valid range and values and register property 
	// set notification by defining a constant value to use.
    
    // TODO: Configure the OutputRange channel property
    hRes = GetChannelProperty(L"OutputRange", &IPropPtr); // Connect to default property
    hRes = IPropPtr->put_User((long)OUTPUTRANGE); // Configure for property set notification
    // hRes = IPropPtr->put_DefaultValue(val);	// Configure default value
	// hRes = IPropPtr->SetRange(&minVal,&maxVal);	// Configure valid range

    // TODO: Configure the UnitsRange channel property
    
    // TODO: Configure the Units channel property   

	// Must free property pointer
   IPropPtr.Release();
	
	// END TO_DO

    return S_OK;
} // end of Open()


/////////////////////////////////////////////////////////////////////////////
// PutSingleValues()	:	Imwoutput Interface
// 
// This function is called when the user performs a "PutSample" call at the
// MATLAB command prompt. The data to send must include one sample for each configured
// channel.
//
// This function differs from the PutSingleValue() function in that this function
// will be called to put a single point of data to multiple channels,
// if configured. This function is called to put a single data point to the 
// hardware, wereas PutSingleValue() is called to put data from a filled buffer.
//
// Input:	none
//
// Output:	Status(HRESULT)			: Return value from member function 		
//			Values(VARIANT*)		: A pointer to a SafeArray containing a 
//									  sampled value for each channel
//	
// Function is MODIFIED for ALL adaptors.
// Review TO_DO/END TO_DO sections and make the appropriate changes
//////////////////////////////////////////////////////////////////////////////

// TODO: Define function for PutSingleValues - single point output
// *** NOT IMPLEMENTED *** Using base class's implementation 
// Uncomment local function to implement

/*
STDMETHOD C#$Demo$#Aout::PutSingleValues(VARIANT* Values)
{
	return E_NOTIMPL;;
}
*/

//////////////////////////////////////////////////////////////////////////////////////
// PutSingleValue() :	local function
//
// This function puts one single data point to the specified channel.
// This function is called by the engine from within the TADDevice::PutSingleValues() 
// function either while processing a "putsample()" user command or while putting 
// data during software clocking (if implemented).
//
// Input:	chan(int)			: Address of the property being modified
//
// Output:	Status(HRESULT)		: Return value from member function 
//			value(RawDataType)	: pointer to the buffer for the sampled data		
//
// Function is MODIFIED for ALL adaptors.
// Review TO_DO/END TO_DO sections and make the appropriate changes
//////////////////////////////////////////////////////////////////////////////////////
HRESULT C#$Demo$#Aout::PutSingleValue(int chan, RawDataType value)
{
	// TODO:	Add implementation to actually output data to the device
	//		Ex: Nothing is being done here currently
	return S_OK;
}


/////////////////////////////////////////////////////////////////////////////
// SetDaqHwInfo() :	local funciton
//
// This functions properly configures the DAQHWINFO structure. This structure is called
// when the user enters "daqhwinfo(ao)" at the MATLAB command line. This function must configure
// the following DAQHWINFO properties:
//		AdaptorName: (string)		
//		Bits: (integer)
//		ChannelIDs  (vector of integers)
//		Coupling: (string)
//		DeviceName: (string)
//		ID: (integer)
//		MaxSampleRate : (double)
//		MinSampleRate: (double)
//		NativeDataType: (string)
//		OutputRanges: (array of doubles)
//		Polarity: (string)
//		SampleType: (string)
//		SubsystemType: (string)
//		TotalChannels: (integer)
//		VendorDriverDescription: (string)
//		VendorDriverVersion: (string)
//
// NOTE: In most cases, scalars can be passed directly as variants. For non-scalar settings,
// safearrays need to be created to pass the data back to the engine.  
// 
// Function is MODIFIED for ALL adaptors.
// Review TO_DO/END TO_DO sections and make the appropriate changes
/////////////////////////////////////////////////////////////////////////////

HRESULT C#$Demo$#Aout::SetDaqHwInfo()
{
	CComVariant tempVar;	// temp COM variant
	int i;					// temp index
    
	// 	_DaqHwInfo :	Holds the pointer to the DAQ Engines daqhwinfo structure.
	//					Inherited from CmwDevice and set during object construction			

	// ADAPTORNAME: (string): name of the adaptor
    RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"adaptorname", CComVariant(L"#$demo$#")));

	//	TODO: Configure Adaptor Hardware Info properties

	// BITS: (integer): number of bits or resolution
	// Ex:	short_bits = HardwareSDKGetBoardAIResolution(_boardID);
	//		RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"bits",CComVariant(_bits)));
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"bits",CComVariant(16))); // Example of hardcoding to 16
	
	// CHANNELIDS: (vector): the ID numbers of the output channels
		// short _Outchannels = HardwareSDKGetNumberOfOutputChannels(_boardID);

	short _OutChannels = 4;	// Example of hardcoded value

	//************************************************************
	//*** The following code creates a safearray(vector) representing channel IDs
    CreateSafeVector((short*)NULL, _OutChannels, &tempVar);
    TSafeArrayAccess<short> ids(&tempVar);
    // Add channel IDs starting with the first channel having ID of '0'
    for (i=0;i<_OutChannels;i++)
        ids[i]=i;

    RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"channelIDs", tempVar));
	//************************************************************
    
	// COUPLING: (string): the input coupling types. Selectable through the object's OutputType property 
		// Ex: 	char _coupling[100]
		//		_coupling = HardwareSDKGetCouplingType(_boardID);
		// 		RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"coupling", CComVariant(_coupling)));
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"coupling", CComVariant(L"DC Coupled"))); // Example of hardcoding to "DC Coupled"

	// DEVICENAME: (string): the name of the device with the specified device ID
		// Ex: 	char _boardName[50];
		// 		HardwareSDKGetBoardName(_boardID, &_boardName);
		//		RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"devicename",CComVariant(_boardName)));
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"devicename",CComVariant("#$Demo$# Emulator-1"))); // Example of hardcoded name

	// ID: (integer): the board id associated with this AI object
	wchar_t idStr[8];
	swprintf(idStr, L"%d", _boardID); // Converts from integer to a char
	RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"id", CComVariant(idStr)));		

	// MAXSAMPLERATE : (double): Defines the maximum sample rate the specified board
		// Ex:	double _maxSampleRate = HardwareSDKGetMaxAISampleRate(_boardID);
		//		RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"maxsamplerate",CComVariant(_maxSampleRate)));
   RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"maxsamplerate"), CComVariant(500)));	// Example of hardcoding value

	// MINSAMPLERATE: (double): Defines the minimum sample rate the specified board
		// Ex:	double _minSampleRate = HardwareSDKGetMinAISampleRate(_boardID);
		//		RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"maxsamplerate",CComVariant(_minSampleRate)));
    RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"minsamplerate", CComVariant(.001)));	// Example of hardcoding value

	// NATIVEDATATYPE: (string): Defines the data type for representing acquired data
	short _dataSize = sizeof(RawDataType);
    RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"nativedatatype", CComVariant(_dataSize)));
    
	// OUPUTRANGES: (array of doubles): min/max pairs of valid output range settings
	//		Each range (row) has a minimum value (column 0) and a maximum value (column 1)

	// Should create a 2 dimensional array as following:
  	  //  Bipolar
	  //  [-10.0  10.0]
	  //  [-5.0   5.0 ]
	  //  [-2.5   2.5 ]
	  //  [-1.25  1.25]
	  //   
	  //  Unipolar
	  //  [0  10.0]
	  //  [0  5.0 ]
	  //  [0  2.5 ]
	  //  [0  1.25]

	/* Ex:	short _ranges[10]
			HardwareSDKGetInputRanges(_boardID, &_ranges); */
   
 	int _ranges[3][2] = 	{-10,10,	// Example of hardcoding InputRanges
							 -5, 5,
							 -1,1};

	//************************************************************
	//** The following code converts an array into a SafeArray

	int _numOfRanges = sizeof(_ranges)/(2*sizeof(int));

    // Define the bounds for a safe array that is bound by the number of ranges and 2 columns (min,max)
    SAFEARRAYBOUND rgsabound[2];  // 2 dimensional array
    rgsabound[0].lLbound = 0;
    rgsabound[0].cElements = _numOfRanges; // number of elements
    rgsabound[1].lLbound = 0;
    rgsabound[1].cElements = 2;     // column 0 = Range Min, column 1 = Range Max
    
    // Create a safe array with the specified bounds
    SAFEARRAY *ptempArray = SafeArrayCreate(VT_R8, 2, rgsabound);
    if (ptempArray == NULL) return E_OUTOFMEMORY;       
    
    double *ranges; // pointer to range values
 
    if (FAILED (SafeArrayAccessData (ptempArray, (void **) &ranges))) 
    {
        SafeArrayDestroy (ptempArray);
        return E_OUTOFMEMORY;
    }
   
	// iterate through rows placing range values in SafeArray
	for (i=0; i< _numOfRanges; i++)
	{
		ranges[i] = _ranges[i][0]; // minimum value
		ranges[i+_numOfRanges] = _ranges[i][1]; // maximum value
	}
	
	// Load save array into variant
    tempVar.Clear();
    V_VT(&tempVar)=(VT_ARRAY | VT_R8);    
    V_ARRAY(&tempVar)=ptempArray;
    
    SafeArrayUnaccessData (ptempArray);

	// Call into DAQ Engine to set DAQHWINFO InputRange property
    RETURN_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"outputranges"), tempVar));

    tempVar.Clear();    	

	// POLARITY: (sting): Defines if the board supports 'UNIPOLAR' and/or 'BIPOLAR' input ranges
		// Ex:	bool _IsUnipolarSupported, _IsBipolarSupported;
		//		char[10] _option;
		//		_IsUnipolarSupported = HardwareSDKSupportsUnipolar(_boardID);
		//		_IsBipolarSupported = HardwareSDKSupportsBipolar(_boardID);
		//		if (_IsUnipolarSupported & _IsBipolarSupported)
					// Need to populate a safearray with both options (see InputRange)
		//		else if(_IsUnipolarSupported)
		//				_option = 'Unipolar';
		//		else if(_IsBipolarSupported)
		//				_option = 'Bipolar';
		//		RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"polarity", CComVariant(option)));
	
   RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"polarity", CComVariant(L"Bipolar")));	// Example of hardcoding value

	// SAMPLETYPE: (string): defines which input sampling type is supported (simultaneous or scanned)
		// Ex:	bool _scanning = HardwareSDKSupportsScanning(_boardID);		
		//		bool _simultaneous = HardwareSDKSupportsSimultaneous(_boardID);
		//		int _sampleType;		
		//		if (_scanning)
		//			_sampleType = SAMPLE_TYPE_SCANNING;
		//		else if (_simultaneous)
		//			_sampleType = SAMPLE_TYPE_SIMULTANEOUS_SAMPLE;
		//							
	    //		RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"sampletype",CComVariant(_sampleType)));
	
    RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"sampletype",CComVariant(SAMPLE_TYPE_SCANNING))); // Example of hardcoding value

	// SUBSYSTEMTYPE: (string): the substem identifier string
   RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"subsystemtype",CComVariant(L"AnalogOutput")));
 
	// TOTALCHANNELS: (integer): total number of channels supported by the board
		// Ex:	short _maxChannels = HardwareSDKGetNumberOfChannels(_boardID);    
		//		RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"totalchannels",CComVariant(_MaxChannels)));
	short _maxChannels = _OutChannels;
    RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"totalchannels",CComVariant(_maxChannels)));

	// VENDORDRIVERDESCRIPTION: (string): A descriptive name of the underlying hardware driver
		//	This value may be queried from the hardware SDK if supported.
   RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"vendordriverdescription",
			CComVariant(L"Simulated Hardware Driver")));
 
	// VENDORDRIVERVERSION: (string): A description of the version number of the underlying driver
		//	This value may be queried from the hardware SDK if supported.
    RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"vendordriverversion",CComVariant(L"Version 1.0a")));
 
	//	END TO_DO

    return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
// SetChannelProperty()	:	ImwDevice Interface
//
// This function is called when a set is performed on a channel property that has 
// previously been configured by the adaptor as requiring notification on a set. 
// This function must check which property is being set, as specified by UserVal,
// for the specified channel (pChan). The new value is passed in as NewValue
//
// Input:	UserVal(long)			: Address of the property being modified
//			pChan(tagNESTABLEPROP*)	: Pointer to the channel structure being modified
//			NewValue(VARIANT*)		: The new value for the specified property
//
// Output:	Status(HRESULT)		: Return value from member function 		
//
// Function is MODIFIED for ALL adaptors.
// Review TO_DO/END TO_DO sections and make the appropriate changes
//////////////////////////////////////////////////////////////////////////////

STDMETHODIMP C#$Demo$#Aout::SetChannelProperty(long UserVal, tagNESTABLEPROP * pChan, VARIANT * NewValue)

{
    // Convert to 0 based channel index
    int Index=pChan->Index-1;   
    _ASSERTE(Index<_nChannels);
    variant_t& vtNewValue=reinterpret_cast<variant_t&>(*NewValue);

	// The tagNESTABLEPROP structure (pChan) has the following fields
    // 		long StructSize;
    //		long Index;
    //		NESTABLEPROPTYPES Type;
    //		long HwChan;
    //		BSTR Name;
  
    // Switch on the Channel property
    switch (UserVal)
    {
    case HWCHANNEL:
        {
			// TODO: Add HwChannel set() processing
            break;
        }
    case OUTPUTRANGE:
        {
		// TODO: Add InputRange set() processing
         break;
       }
    case UNITSRANGE:
        {
		// TODO: Add UnitsRange set() processing
         break;
       }
    case UNITS:
        {
		// TODO: Add Units set() processing
         break;
       }
    default:
    	break;
    }
	// Set flag that properties were updated
    _updateChildren=true;
    
    return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
// SetProperty() :	ImwDevice Interface
//
// This function is called when a set is performed on a subsystem's property that has 
// previously been configured by the adaptor as requiring notification on a set. 
// This function must check which property is being set, as specified by UserVal.
// The new value is passed in as NewValue and may be modified and passed back out.
//
//
// Input:	UserVal(long)			: Address of the property being modified
//			NewValue(VARIANT*)		: The new value for the specified property
//
// Output:	Status(HRESULT)			: Return value from member function 		
//			NewValue(VARIANT*)		: The new value, as modified, for the specified property
//
// Function is MODIFIED for ALL adaptors.
// Review TO_DO/END TO_DO sections and make the appropriate changes
//////////////////////////////////////////////////////////////////////////////

STDMETHODIMP C#$Demo$#Aout::SetProperty(long User, VARIANT * NewValue)
{    
    if (User)    
    {
		CLocalProp* pProp=PROP_FROMUSER(User);
		variant_t *val=(variant_t*)NewValue;

		if(User==USER_VAL(pOutputType))
		{
			// TODO: Add InputType set() code here
		}
		else if(User==USER_VAL(pSampleRate))
		{
			// TODO: Add SampleRate set() code here
		}
		else if(User==USER_VAL(pClockSource))
		{
			// TODO: Add ClockSource set() code here
		}
		#$NotifyProp$#
		#$DevSpecificNotify$#

		// END TO_DO:
		
		// Set flag that properties were updated
        _updateProps=true;
    }
    return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
// Start()	:	ImwDevice Interface
//
// This function is called when a "start" command is issued at the MATLAB command line.
// This function must perform all required steps to start the hardware. Data will not be 
// returned back to the MATLAB environment until the device is triggered (TRIGGER()).
//
// Input:	none
//
// Output:	Status(HRESULT)		: Return value from member function 		
//
// Function is MODIFIED for ALL adaptors.
// Review TO_DO/END TO_DO sections and make the appropriate changes
//////////////////////////////////////////////////////////////////////////////

// TODO: Define function for Start acquisition
// *** NOT IMPLEMENTED *** Using base class's implementation 
// Uncomment local function to implement
/*
STDMETHODIMP C#$Demo$#Ain::Start()
{
	// TODO: Add START() processing code
    return S_OK;
    // END TO_DO:
}

/////////////////////////////////////////////////////////////////////////////
// Stop()	:	ImwDevice Interface
//
// This function is called when a "stop" command is issued at the MATLAB command line.
// This function must perform all required steps to stop the hardware and clean up any 
// unprocessed data.
//
// Input:	none
//
// Output:	Status(HRESULT)		: Return value from member function 		
//
// Function is MODIFIED for ALL adaptors.
// Review TO_DO/END TO_DO sections and make the appropriate changes
//////////////////////////////////////////////////////////////////////////////

// TODO: Define function for Stop acquisition
// *** NOT IMPLEMENTED *** Using base class's implementation 
// Uncomment local function to implement
/*
STDMETHODIMP C#$Demo$#Ain::Stop()
{
	// TODO: Add STOP() processing code
    return S_OK;
    // END TO_DO:
}
*/

/////////////////////////////////////////////////////////////////////////////
// Trigger()	:	ImwOutput Interface
// 
// This function is called when the user calls "Trigger" from the
// MATLAB command prompt or when the DAQ engine determines it is the correct 
// condition to trigger the device. 
//
// This function will need to initiate data output on the hardware.
//
// Depending on the acquisition/buffering scheme utilized, data should be
// sent and then used buffers should be returned back to the DAQ Engine.
//
// Input:	none
//
// Output:	Status(HRESULT)			: Return value from member function 		
//	
// Function is MODIFIED for ALL adaptors.
// Review TO_DO/END TO_DO sections and make the appropriate changes
//////////////////////////////////////////////////////////////////////////////

// TODO: Define function for Trigger acquisition
// *** NOT IMPLEMENTED *** Using base class's implementation 
// Uncomment local function to implement
/*
STDMETHODIMP C#$Demo$#Ain::Trigger()
{
	// TODO: Add TRIGGER() processing code
    return S_OK;
    // END TO_DO:
}
*/


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

STDMETHODIMP C#$Demo$#Aout::ChildChange(DWORD typeofchange, NESTABLEPROP *pChan)
{
    if (typeofchange & START_CHANGE)
    {
		// TODO: Process start of channel change
    }
    if ((typeofchange & CHILDCHANGE_REASON_MASK)== ADD_CHILD)
    {
		// TODO: Process added channel
		// Increment internal channel counter
		++_nChannels;

    }
    else if ((typeofchange & CHILDCHANGE_REASON_MASK)== REINDEX_CHILD)
    {
		// TODO: Process re-indexed channel
    }
    else if ((typeofchange & CHILDCHANGE_REASON_MASK)== DELETE_CHILD)
    {
		// TODO: Process deleted channel
		
		// Decrement internal channel counter
		--_nChannels;
    }
    if (typeofchange & END_CHANGE)
    {
		// TODO: Process end of channel change
    }
    
    return S_OK;
}

/////////////////////////////////////////////////////////////////////////////
// GetStatus()	:	ImwDevice Interface
//
// This function is called by the DAQ engine to determine the number of samples sent. 
// This function only needs to be overloaded if special processing is required.
// The base class implementation should surfice in most scenarios
//
// Input:	none
//
// Output:	Status(HRESULT)				: Return value from member function 		
//			samplesProcessed(__int64*)	: Pointer to the number of samples acquired
//			running(bool*)				: Set to true if running, false if not. 
//	
// Function is MODIFIED for ALL adaptors.
// Review TO_DO/END TO_DO sections and make the appropriate changes
//////////////////////////////////////////////////////////////////////////////

// TODO: Define function for GetStatus 
// *** NOT IMPLEMENTED *** Using base class's implementation 
// Uncomment local function to implement
/*
STDMETHODIMP C#$Demo$#Aout::GetStatus(__int64* samplesProcessed, int* running)
{
    return S_OK;
}
*/