// hpvxiAD.cpp : Implementation of mwwinsound and DLL registration.
// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.1.6.2 $  $Date: 2003/12/04 18:39:24 $



#include "stdafx.h"
#include <assert.h>
#include "daqmex.h"
#include "errors.h"
#include "mwhpe1432.h"
#include "hpvxiAD.h"
#include <comcat.h>
#include <mmreg.h>
#include <math.h>   // modf
#include "util.h"
#include <stdio.h>
#include <sarrayaccess.h>

/////////////////////////////////////////////////////////////////////////////
//
// 
// If there are buffers are in the device,
// return the status of the done flag in the
// next header on the list

#define AUTO_LOCK TAtlLock<hpvxiAD> _lock(*this)

hpvxiAD *hpvxiAD::RunningADPtr=NULL;

// object constructor:
// initialize data members
hpvxiAD::hpvxiAD() : 
_buffer(NULL),
_callbackCnt(0),
_chanSkewMode(CHAN_SKEW_NONE),
_validChanList(NULL),
_numIdSpecified(0),
_callbackRegistered(false),
_chanSkew(0),
_chanList(NULL),
_chasis(0),
_clockSource(0),
_clockFreq(0),
_coupling(NULL),
_nChannels (0),
_gid(0),
_trigGrpID(0),
_groundingMode(NULL),
_inputMode(NULL),
_inputSource(NULL),
_isStarted(false),
_maxChannels(0),
_maxSR(0),
_minSpan(0),
_maxSpan(0),
_running(false),
_samplesAcquired(0),
_sampleRate(52100), 
_session(0),
_span(20000),
_triggerChannel(NULL),
_triggerCondition(HPE1432_TRIGGER_MODE_LEVEL),
_triggerConditionValue(&variant_t(0L)),
_triggerDelay(0),
_triggerDelayUnits(0),      // engine uses seconds by default
_triggerRepeat(0),
_triggerSlope(HPE1432_TRIGGER_SLOPE_POS),
_triggerType(TRIG_TYPE_IMMEDIATE),
_lastBufferGap(false),
_id(""),
//[SK] added
_triggersOccured(0),			
_samplesPerTrigger(0),
_LstBufFlg(false)
{      
	AUTO_LOCK;

    _chanRange[0] = new double[1];
    _chanRange[1] = new double[1];
    
    _chanRange[0][0] = -10.0;
    _chanRange[1][0] =  10.0;      
    
    _triggerChannel = new long[1];
    _triggerChannel[0] = 1;


    ATLTRACE("HPVXI AnalogInput Driver Open\n");    
}




// Set the fields needed for DaqHwInfo
// This is called by Open and is needed by Open to define the _maxSR
// (max sample rate) and _maxChannels.
HRESULT hpvxiAD::SetDaqHwInfo()
{
   HRESULT hRes;
	// prop - pointer to the IProp interface.
	// pCont - pointer to the IPropContainer interface.
    CComPtr<IProp> prop;       
    
    // hwinfo property container.
    CComQIPtr<IPropContainer>  pCont(GetHwInfo());   
    
	// Return hardware configuration information.
    ViInt32 *configInfo = new ViInt32[27*numFound];
	
	// 0          (input)  - not used so can be 0.
	// numFound   (input)  - number of module addresses being sent.
	// addList    (input)  - module addressed.
	// configInfo (output) - returns 27 numbers for each module, so the total array needs
	//                       to be 27*numFound long.
    hpe1432_getHWConfig(0, numFound, addList, configInfo);    
    
	// Initialize variables.
	bstr_t DeviceName;    

    // based on the id, figure out which device is which in the config info            
    long idx=0;        

    for (int i=0; i<numFound; i++){

        char numStr[8]={'\0'};
		char *ptr=strchr(_id,':');
        ptr+=2;
        int j=0;
	
        // search the id string for the address
        // the string is in the form VXI0::address::INSTR
        while (j<8 && *ptr != ':' && *ptr!=','){
            numStr[j++] = *ptr++;         
        }

		if (atoi(numStr)==addList[i]){
			idx=i;
			break;
		}	
    }

    // configInfo element 6 contains the sca_id, five IDs for the SCAs that are present.
	// Only support the HP E1432 and HP E1433.
    switch (configInfo[6+(27*idx)])
    {
    case HPE1432_SCA_ID_NONE:
        break;
    case HPE1432_SCA_ID_INPUT:
        break;
    case HPE1432_SCA_ID_SOURCE:
        break;
    case HPE1432_SCA_ID_TACH:
        break;
    case HPE1432_SCA_ID_CLARINET:
        break;
    case HPE1432_SCA_ID_VIBRATO:
        DeviceName="HP E1432A";
        _maxSR=51200;
		_minSpan = 12.5;
		_maxSpan = 20000;
		_span = 20000;
	    break;
    case HPE1432_SCA_ID_SONATA:
        DeviceName="HP E1433A";
        _maxSR=196608;
		_minSpan = 7.8125; 
		_maxSpan = 76800;
		_span = 20000;
        break;
    case HPE1432_SCA_ID_CLARION:
        break;
	case -842150451:
		// None of the defined names returned by getHWConfig match the HP E1433A - so I defined my own.
        DeviceName="HP E1433A";
        _maxSR=196608;
		_minSpan = 7.8125;
		_maxSpan = 76800;
		_span = 20000;
		break;
	default:
        DeviceName="unknown";
        _maxSR=51200;
		_minSpan = 12.5;
		_maxSpan = 20000;
		_span = 20000;
        break;
    }

	// Since the 1432 and 1433 have different samplerate ranges, if an object created
	// spans a 1432 and a 1433 board, the 1432 ranges are used (the 1433 range includes
	// the 1432 values, however, the 1432 range does not include all the 1433 values).
	int currentId = 0;
	for (i = 0; i<_numIdSpecified;i++){
		// Find the location of the specified ID in addlist.
		for (int j = 0; j<numFound; j++){
			if (UserId[i] == addList[j]){
				currentId = j;
				break;
			}
		}

	    switch (configInfo[6+(27*currentId)]){
		case HPE1432_SCA_ID_VIBRATO:
			_maxSR=51200;
			_minSpan = 12.5;
			_maxSpan = 20000;
			_span = 20000;
			break;
		}
	}
    
    delete [] configInfo;

	// Define the initial clock frequency.
	_clockFreq = 51200;


    // device Id   
	wchar_t idBase[400];
	wchar_t *idList=idBase;

	// Build up the string VXI+chasis+::.
	idList+=swprintf(idList, L"VXI");
	idList+=swprintf(idList, L"%d", _chasis);
	idList+=swprintf(idList, L"::");

	// Add the specified hardware ids to the string.
	for (i=0;i<_numIdSpecified;i++){
		idList+=swprintf(idList, L"%d", UserId[i]);	
		if (i<_numIdSpecified-1)
			idList+=swprintf(idList, L",");	
	}   

	// Close out the string.
	wcscat(idList,L"::INSTR");  

    hRes = pCont->put_MemberValue(CComBSTR(L"id"), CComVariant((BSTR)idBase));	
    if (!(SUCCEEDED(hRes))) return hRes;

	// Maximum number of channels.
    hRes = pCont->put_MemberValue(CComBSTR(L"totalchannels"),CComVariant(_maxChannels));
    if (!(SUCCEEDED(hRes))) return hRes;

    // differential input channels
    CComVariant vids;
	short* ids;
    ids = new short[_maxChannels];
    for (int j=0;j<_maxChannels;j++){
        ids[j]=j+1;
	}

    CreateSafeVector(ids,_maxChannels,&vids);

    hRes = pCont->put_MemberValue(CComBSTR(L"differentialids"), vids);
    if (!(SUCCEEDED(hRes))) return hRes;

	delete [] ids;

    // subsystem type
    hRes = pCont->put_MemberValue(CComBSTR(L"subsystemtype"),CComVariant(L"AnalogInput"));
    if (!(SUCCEEDED(hRes))) return hRes;
        
    hRes = pCont->put_MemberValue(CComBSTR(L"sampletype"),CComVariant(1L));
    if (!(SUCCEEDED(hRes))) return hRes;
    
    hRes = pCont->put_MemberValue(CComBSTR(L"bits"),CComVariant(16));
    if (!(SUCCEEDED(hRes))) return hRes;
    
    hRes = pCont->put_MemberValue(CComBSTR(L"adaptorname"), CComVariant(L"hpe1432"));
    if (!(SUCCEEDED(hRes))) return hRes;
    
    hRes = pCont->put_MemberValue(CComBSTR(L"vendordriverdescription"),
        CComVariant(L"HP VXI Plug & Play Driver"));
    if (!(SUCCEEDED(hRes))) return hRes;
    
    hRes = pCont->put_MemberValue(CComBSTR(L"vendordriverversion"),CComVariant(L"1.0"));
    if (!(SUCCEEDED(hRes))) return hRes;
    
    hRes = pCont->put_MemberValue(CComBSTR(L"polarity"), CComVariant(L"Bipolar"));
    if (!(SUCCEEDED(hRes))) return hRes;
    
    // coupling - can be either AC Coupled or DC Coupled therefore need to create a Safe Array.
	// Create a safearray of type VT_BSTR, the array is zero based and there are two elements.
    SAFEARRAY *ps = SafeArrayCreateVector(VT_BSTR, 0, 2);
    if (ps==NULL) E_SAFEARRAY_FAILURE;
    CComVariant val;

    // set the data type and values
    V_VT(&val)=VT_ARRAY | VT_BSTR;
    V_ARRAY(&val)=ps;
    CComBSTR *coupling;
    
    hRes = SafeArrayAccessData (ps, (void **) &coupling);
    if (FAILED (hRes)) {
        SafeArrayDestroy (ps);
        return E_SAFEARRAY_FAILURE;
    }

    coupling[0]=L"AC Coupled";
    coupling[1]=L"DC Coupled";
      
    hRes = pCont->put_MemberValue(CComBSTR(L"coupling"), val);
    if (!(SUCCEEDED(hRes))) return hRes;
    
    // device name   (DeviceName was defined in the switch statement above).
    hRes = pCont->put_MemberValue(CComBSTR(L"devicename"),CComVariant((BSTR)DeviceName));
    if (!(SUCCEEDED(hRes))) return hRes;
    
    // native data type   
    hRes = pCont->put_MemberValue(CComBSTR(L"nativedatatype"), CComVariant(VT_I2));	
    if (!(SUCCEEDED(hRes))) return hRes;
    
    // min & max sample rates.  
    hRes = pCont->put_MemberValue(CComBSTR(L"minsamplerate"), CComVariant(_minSpan*2.56));	
    if (!(SUCCEEDED(hRes))) return hRes;
    
    hRes = pCont->put_MemberValue(CComBSTR(L"maxsamplerate"), CComVariant(_maxSR));	
    if (!(SUCCEEDED(hRes))) return hRes;    
    
    // create a 2x8 array of input ranges
    val.Clear();

	if (_maxSR == 51200){
		// Create a vector of bounds.
		SAFEARRAYBOUND rgsabound[2];  
		rgsabound[0].lLbound = 0;   // lower index.
		rgsabound[0].cElements = 8; // number of elements.
		rgsabound[1].lLbound = 0;
		rgsabound[1].cElements = 2;     
    
		// Create a safe array with 2 dimensions of type VT_R8.
		ps = SafeArrayCreate(VT_R8, 2, rgsabound);
		if (ps == NULL) return E_SAFEARRAY_FAILURE;           
   
		double *ranges;

		// ranges is a pointer to the safe array data.
		hRes = SafeArrayAccessData (ps, (void **) &ranges);
		if (FAILED (hRes)) {
			SafeArrayDestroy (ps);
			return E_SAFEARRAY_FAILURE;
		}
    
		static const double rangeVals[] = {
                
			-.1, -.2, -.5, -1, -2, -5, -10, -20, 
		  	 .1,  .2,  .5,  1,  2,  5,  10,  20,       
		};

		// Copy rangeVals into the ranges buffer. 16*sizeof(double) is the number
		// of characters to copy.
		memcpy(ranges,rangeVals,16*sizeof(double));
   
		V_VT(&val)=(VT_ARRAY | VT_R8);    
		V_ARRAY(&val)=ps;
    
		SafeArrayUnaccessData (ps);

		hRes = pCont->put_MemberValue(CComBSTR(L"inputranges"), val);
		if (!(SUCCEEDED(hRes))) return hRes;   
	}else{
		// 1433 InputRanges
		// Create a vector of bounds.
		SAFEARRAYBOUND rgsabound[2];  
		rgsabound[0].lLbound = 0;   // lower index.
		rgsabound[0].cElements = 11; // number of elements.
		rgsabound[1].lLbound = 0;
		rgsabound[1].cElements = 2;     
    
		// Create a safe array with 2 dimensions of type VT_R8.
		ps = SafeArrayCreate(VT_R8, 2, rgsabound);
		if (ps == NULL) return E_SAFEARRAY_FAILURE;           
   
		double *ranges;

		// ranges is a pointer to the safe array data.
		hRes = SafeArrayAccessData (ps, (void **) &ranges);
		if (FAILED (hRes)) {
			SafeArrayDestroy (ps);
			return E_SAFEARRAY_FAILURE;
		}
    
		static const double rangeVals1433[] = {
			         -.005, -.01, -.02, -.05, -.1, -.2, -.5, -1, -2, -5, -10,
			          .005,  .01,  .02,  .05,  .1,  .2,  .5,  1,  2,  5,  10};

		// Copy rangeVals into the ranges buffer. 16*sizeof(double) is the number
		// of characters to copy.
		memcpy(ranges,rangeVals1433,22*sizeof(double));
   
		V_VT(&val)=(VT_ARRAY | VT_R8);    
		V_ARRAY(&val)=ps;
    
		SafeArrayUnaccessData (ps);

		hRes = pCont->put_MemberValue(CComBSTR(L"inputranges"), val);
		if (!(SUCCEEDED(hRes))) return hRes;   
	}

	prop.Release();
	pCont.Release();
    
    return S_OK;
}


// This function is called by Open.
// Registers and initializes the TriggerConditionValue property.
int hpvxiAD::SetDefaultTriggerConditionValues()
{
	// prop is a pointer to the IProp interface.
    CComPtr<IProp> prop;

    // trigger condition value
    HRESULT hRes=GetProperty(L"TriggerConditionValue", &prop);
    if (!SUCCEEDED(hRes)) return hRes;        
    
	// register triggerConditionValue with engine for later use.
    hRes=prop->put_User(USER_VAL(_triggerConditionValue));        
    if (!SUCCEEDED(hRes)) return hRes;        
    
    // Create a two element vector (zero based) of type VT_R8.
	SAFEARRAY *ps = SafeArrayCreateVector(VT_R8, 0, 2);
    if (ps==NULL) E_SAFEARRAY_FAILURE;
    
    CComVariant val;

    // set the data type and values
    V_VT(&val)=VT_ARRAY | VT_R8;
    V_ARRAY(&val)=ps;
    
    double *range = NULL;
    
	// range is a pointer to the void pointer of the array data.
    hRes = SafeArrayAccessData (ps, (void **) &range);
    if (FAILED (hRes)) 
    {
        SafeArrayDestroy (ps);
        return E_SAFEARRAY_FAILURE;
    }

	// Default triggerConditionValue is [0 0].
    range[0]=range[1]=0;
    
	// Set the triggerConditionValue property value.
    hRes = prop->put_Value(val);
    if (!SUCCEEDED(hRes)) 
    {
        SafeArrayUnaccessData (ps);
		return hRes;        
    }

	// Set the triggerConditionValue default value.
    hRes = prop->put_DefaultValue(val);
    if (!SUCCEEDED(hRes)) {
        SafeArrayUnaccessData (ps);
		return hRes;        
    }
    
    SafeArrayUnaccessData (ps); 
	
	prop.Release();

    return S_OK;

}

//
// This is called by the engine when the constructor is called
// An engine interface is passed in and stored in a member variable
// Optional parameters such as ID are passed in as s1, s2, s3.
//
HRESULT hpvxiAD::Open(IDaqEngine *engine, wchar_t *devName)
{
    // assign the engine access pointer
    CmwDevice::Open(engine);
    _engine = engine;
    _ASSERTE(engine!=NULL);   
/*    
    bstr_t bstr(s2), devName;
	bstr_t bstr2(s3);
        
	if ((wchar_t*)bstr2!=NULL){
		if (iswpunct(((wchar_t*)bstr)[0]))
			return E_INVALID_DEVICE_ID;
		else if (iswpunct(((wchar_t*)bstr)[0]))
			return E_INVALID_DEVICE_ID;
		else if (iswdigit(((wchar_t*)bstr)[0]))
			devName=L"VXI"+bstr2+"::"+bstr+"::INSTR"; 
	}else{
		if ((wchar_t*)bstr==NULL)       
			return E_MUST_DEFINE_ID;
		else if (iswdigit(((wchar_t*)bstr)[0]))   
			devName=L"VXI0::"+bstr+"::INSTR";     
		else if (iswpunct(((wchar_t*)bstr)[0])){
			// A negative ID value was given.
			return E_INVALID_DEVICE_ID;
		}else{
			devName=bstr;
		}
	}
*/
	// ID string in the form: VXI+chasis+::+ids+::INSTR from the ids that the 
	// user passed in.
    _id = _wcsupr(devName);   
    
	// Determine the chasis number and the hardware ids specified.

	// Initialize variables.
	wchar_t *tmpValue;
    tmpValue=_id;
	int count = 0;

	// Determine the chasis number.
	swscanf(tmpValue, L"VXI%d", &_chasis);

	// Find the second ':'.
	for (unsigned int i=0; i<wcslen(tmpValue); i++) {    
		if (tmpValue[i] == L':'){
			tmpValue += i+1;
			break;
		}
	}

	// Loop through the remainder of the string and find the hardware ids specified.
    while((*tmpValue != 0) && (tmpValue < (wchar_t *)_id+_id.length())) {    
        
		if (iswdigit(*tmpValue)) {
			UserId[count] = wcstol(tmpValue, &tmpValue, 10);
			count++;
		}else{
			tmpValue++;
		}
	}

	// Store the number of ids specified.
	_numIdSpecified = count;


	// Initialize the hardware if it has not been initialized yet.
		// Already initialized.  Use stored session handle.
        DAQ_CHECK(GetGlobalSession(_session));

	// Determine which channels are valid for the specified id.
	bool foundId = false;
	int totalInput = 0;

	// k-loop contains the number of ids that the user specified.
	// Ex. analoginput('hpe1432', [8 32])  k-loop loops twice for the 8 and 32.
	for (int k=0; k<count;k++){

		// Loop through the possible ids found - up to 256 can be found.
		for (i=0; i < static_cast<unsigned int>(numFound); i++){

			if (UserId[k] == globalIdList[i*4])
			{
				foundId = true;

				// Error if the id does not have any of the specified channel type.
				// Ex. error if analoginput is called on a 1434 which has no analoginput channels.
				if (globalIdList[i*4+1] == 0){
					return E_INVALID_DEVICE_ID;
				}

				// Increment the total number of channels by the number of analoginput
				// channels supported by this hardware.
				_maxChannels = globalIdList[i*4+1];

				// Create the list of ids for the total channel array.
				for (int j = 0; j<_maxChannels; j++){
					_validChanList.push_back(totalInput+j+1);
					_validScaleFactor.push_back(globalIdList[i*4+3]);
				}

				// Increment total input so that the validChanList contains the correct values.
				totalInput+=globalIdList[i*4+1];
				_maxChannels = totalInput;
			}
		}

		if (foundId == false){
			// Error if the device id was not found in the list of available ids.
			return E_INVALID_DEVICE_ID;
		}else{
			// Reset and continue on to the next id specified by the user.
			foundId = false;
		}
	}
	if (globalGidAO != NULL){
		globalCallbackInstalled = true;
	}

    // common properties 
    CComPtr<IProp> prop;       
    
	// RegisterProperty passes the address of the property to the engine (using
	// put_User) so that the property value can be updated when the user sets the 
	// property.  RegisterProperty returns a pointer to the IProp interface.

    // ChannelSkewMode is read-only and defaults to NONE.
	// ChannelSkewMode values are hp specific (need to clear and then set).
    prop = RegisterProperty(L"ChannelSkewMode", (DWORD)&_chanSkewMode);
    prop->ClearEnumValues();         
    prop->AddMappedEnumValue(0, L"None");
    prop->put_Value(CComVariant(0));
    prop->put_DefaultValue(CComVariant(0));
    prop.Release();
    
    // ChannelSkew can only be set to 0.
    prop = RegisterProperty(L"ChannelSkew", (DWORD)&_chanSkew);           
    prop->SetRange(&CComVariant(0), &CComVariant(0));
    prop.Release();

	// ClockSource defaults to internal.
	// ClockSource values are hp specific.
    prop = RegisterProperty(L"ClockSource", (DWORD)&_clockSource);
    prop->AddMappedEnumValue(HPE1432_CLOCK_SOURCE_VXI, L"VXIBusSample");
    prop->AddMappedEnumValue(HPE1432_CLOCK_SOURCE_EXTERNAL, L"External");
    prop->AddMappedEnumValue(HPE1432_CLOCK_SOURCE_EXTERNALN, L"InvertedExternal");
    prop->AddMappedEnumValue(HPE1432_CLOCK_VXI_DEC_3, L"VXIBus/3");
    prop->put_Value(CComVariant(0));
    prop->put_DefaultValue(CComVariant(0));
    prop.Release();
    
    // Create a prop container interface for the Root properties
    CComQIPtr<IPropContainer, &__uuidof(IPropContainer)>  pRoot(GetPropRoot());   
    
   
	// maxSR gets set here so it must be called before setting the 
    // range values for the sample rate property
    DAQ_CHECK(SetDaqHwInfo()); 

	// pRoot is a pointer to the IPropContainer interface.  Create the device specific
	// property Span.
	pRoot->CreateProperty(L"Span", &CComVariant(_span), __uuidof(IProp),(void**)&prop);
    CComVariant val(_span);
    prop->put_User((long)&_span);  // Register the property with the engine.
    prop->put_Value(val);
    prop->put_DefaultValue(val);
    
	// Set the limits of the Span property.
	CComVariant minvar(_minSpan);
    CComVariant maxvar(_maxSpan);    
    prop->SetRange(&minvar, &maxvar);
    prop.Release();

    // sample rate
    prop = RegisterProperty(L"SampleRate", (DWORD)&_sampleRate);
    val=_span*2.56;
    prop->put_Value(val);
    prop->put_DefaultValue(val);
    
	// Set the limits on the Span property.
    minvar=_minSpan*2.56;
    maxvar=_maxSR;
    prop->SetRange(&minvar, &maxvar);
    prop.Release();

	// Trigger properties.
    RegisterProperty(L"TriggerDelay", (DWORD)&_triggerDelay);
    RegisterProperty(L"TriggerDelayUnits", (DWORD)&_triggerDelayUnits);   
	RegisterProperty(L"TriggerRepeat", (DWORD)&_triggerRepeat);
	RegisterProperty(L"SamplesPerTrigger", (DWORD)&_samplesPerTrigger);

    DAQ_CHECK(GetProperty(L"TriggerCondition", &prop));    
    prop->put_User((long)&_triggerCondition);    
    prop.Release();
   
    DAQ_CHECK(SetDefaultTriggerConditionValues());    

	// TriggerType has the hp specific values of HwAnalog and HwDigital plus
	// the values common to all hardware (immediate, manual, software)
    prop = RegisterProperty(L"TriggerType", (DWORD)&_triggerType);    
    prop->AddMappedEnumValue(TRIG_TYPE_HW_ANALOG, L"HwAnalog");        
    prop->AddMappedEnumValue(TRIG_TYPE_EXTERNAL,  L"HwDigital");            
    prop.Release();

    // Channel properties.

    // set input range to default to [-10 10]    
    DAQ_CHECK(SetDefaultRange(L"inputrange"));    
    
    // set sensor range to default to [-10 10]    
    DAQ_CHECK(SetDefaultRange(L"unitsrange"));    
    
    // set sensor range to default to [-10 10]    
    DAQ_CHECK(SetDefaultRange(L"sensorrange"));    
    
    // inputType 
    //pRoot->CreateProperty(L"InputType", NULL,__uuidof(IDaqMapedEnum),(void**) &prop);    
    pRoot->CreateProperty(L"InputType", NULL,__uuidof(IProp),(void**) &prop);    
    prop->AddMappedEnumValue(0L, L"Differential");    
    prop.Release();

	// _maxChannels defined in SetDaqHwInfo.
    DAQ_CHECK(GetChannelProperty(L"HwChannel", &prop));    
    prop->put_DefaultValue( CComVariant(1L));
    prop->put_User((long)HWCHAN);    
    prop->SetRange(&CComVariant(1L),&CComVariant(_maxChannels));    
    prop.Release();

    DAQ_CHECK(GetChannelProperty(L"ConversionExtraScaling", &prop));    
    double ExtraScaling=1;
    if (_validScaleFactor[0] == 1){
        // 1432
        ExtraScaling=2.73351459504128; //2.73351459503174;
    }else{
        // 1433
        ExtraScaling=2.25012493133545; //2.25012493134330;   
    }
    prop->put_DefaultValue(CComVariant(ExtraScaling));
    prop.Release();

	// Coupling.
    DAQ_CHECK(_EngineChannelList->CreateProperty(L"Coupling", NULL,__uuidof(IPropRoot), (void**)&prop));        
    prop->AddMappedEnumValue(HPE1432_COUPLING_DC, L"DC"); 
    prop->AddMappedEnumValue(HPE1432_COUPLING_AC, L"AC"); 
    prop->put_DefaultValue(CComVariant(HPE1432_COUPLING_DC));
    prop->put_User((long)COUPLING);       
    prop.Release();
   
    // input mode
    DAQ_CHECK(_EngineChannelList->CreateProperty(L"InputMode", NULL,__uuidof(IPropRoot), (void**)&prop));    
    prop->AddMappedEnumValue(HPE1432_INPUT_MODE_VOLT, L"Voltage");	
    prop->AddMappedEnumValue(HPE1432_INPUT_MODE_ICP, L"ICP");
    prop->AddMappedEnumValue(HPE1432_INPUT_MODE_CHARGE, L"Charge");
    prop->AddMappedEnumValue(HPE1432_INPUT_MODE_MIC, L"Mic");
    prop->AddMappedEnumValue(HPE1432_INPUT_MODE_MIC_200V, L"200VoltMic");    
    prop->put_DefaultValue(CComVariant(HPE1432_INPUT_MODE_VOLT));
    prop->put_User((long)MODE);
    prop.Release();        
 
    //input source
    DAQ_CHECK(_EngineChannelList->CreateProperty(L"InputSource", NULL,__uuidof(IPropRoot), (void**)&prop));    
    prop->AddMappedEnumValue(HPE1432_INPUT_HIGH_NORMAL,L"SwitchBox");
    prop->AddMappedEnumValue(HPE1432_INPUT_HIGH_CALIN, L"CALIN");
    prop->AddMappedEnumValue(HPE1432_INPUT_HIGH_GROUNDED,L"Ground");
    prop->AddMappedEnumValue(HPE1432_INPUT_HIGH_BOB_CALIN,L"BOBCALIN");
    prop->put_DefaultValue(CComVariant(HPE1432_INPUT_HIGH_NORMAL));
    prop->put_User((long)SOURCE);
    prop.Release();
    
	// grounding mode.
    DAQ_CHECK(_EngineChannelList->CreateProperty(L"GroundingMode", NULL,__uuidof(IPropRoot), (void**)&prop));    
    prop->AddMappedEnumValue(HPE1432_INPUT_LOW_GROUNDED, L"Grounded");
    prop->AddMappedEnumValue(HPE1432_INPUT_LOW_FLOATING, L"Floating");
    prop->put_DefaultValue(CComVariant(HPE1432_INPUT_LOW_GROUNDED));
    prop->put_User((long)GROUND);
    prop.Release();

	// Create a hidden ClockFreqency property.
    DAQ_CHECK(pRoot->CreateProperty(L"ClockFrequency", &CComVariant(_clockFreq), __uuidof(IProp),(void**)&prop));    
	prop->put_IsHidden(true);
	prop->put_IsReadOnly(true);
	prop.Release();

	// Set the range for the BufferingConfig's first value.  This can be done through the 
	// EngineBlockSize property.
    DAQ_CHECK(GetProperty(L"EngineBlockSize", &prop));
    CComVariant minblock(2);
    CComVariant maxblock(16777215);    
	prop->SetRange(&minblock, &maxblock);
	prop.Release();

	pRoot.Release();

	if (globalGidAO != NULL){
		hpe1432_reenableInterrupt(_session, globalGidAO);
	}

    return S_OK;
}


// setup the default read-only values for channel range, unit range, 
// and sensor range to be [-10 10]
// Called by hpvxiAD::open.
HRESULT hpvxiAD::SetDefaultRange(LPWSTR name)
{
	// Create a safe array of [-10 10].
	CComVariant val;
    short range[]={-10,10};
    CreateSafeVector(range,2,&val);

	// Initialize variables.
    CComPtr<IProp> prop;
    
	// Create the specified property.
    HRESULT hRes = _EngineChannelList->CreateProperty(name, &val, __uuidof(IProp),(void**)&prop);
    if (!(SUCCEEDED(hRes))) return hRes;        
    
	// Set the range for the InputRange property and register the InputRange property 
	// with the engine.
    if (wcscmp(name, L"inputrange")==0) {
        hRes = prop->put_User((long)INPUTRANGE);
        if (!(SUCCEEDED(hRes))) return hRes;    
        
		// The ranges are dependent upon board.
		CComVariant minvar, maxvar;

		if (_maxSR == 51200){
			// 1432 or 1432 and 1433.
			minvar = -20L;
			maxvar = 20L;
		}else{
			// 1433.
			minvar = -10L;
			maxvar = 10;
		}

        prop->SetRange(&minvar,&maxvar);   
    }
    
	// Set the default value.
    hRes = prop->put_DefaultValue(val);
    if (!(SUCCEEDED(hRes))) return hRes;            
    
    prop.Release();
    
    return S_OK;
}


// Register the property with a local variable. 
// This is so that when SetProperty is called the local variables get updated.
// Called by hpvxiAD::Open.
CComPtr<IProp> hpvxiAD::RegisterProperty(LPWSTR name, DWORD dwUser)
{
	// Get a pointer (prop) to the IProp interface for property, name.
    CComPtr<IProp> prop;
   GetProperty(name, &prop);
    
	// If the property doesn't exist, error.
    if (prop==NULL) 
    {
        _RPT1(_CRT_ERROR,"HPVXI: Invalid property: '%s'.", name);
        return NULL;
    }
    
	// Register the property with the engine so that it can be updated
	// when the user modifies the property.
    prop->put_User(dwUser);
    
    return prop;
}

//
// This is called by the engine when a property is set
// An interface to the property along with the new value is passed in
// prop     - pointer to IProp Interface for the property being set.
// NewValue - new property value.
// If this method fails, false is returned.
STDMETHODIMP hpvxiAD::SetProperty(long User, VARIANT *NewValue)  
{

	// User contains the address of the local data member (of the property
	// being set).
        // variant_t is a more friendly data type to work with
        variant_t *newVal = (variant_t*)NewValue;       
        			
		// when either span or sample rate is set, the other needs
		// to be updated. The driver cares only about span.
        if (User==(long)&_sampleRate || User==(long)&_span)
        {            
        
			bool isSpan;
			CComPtr<IProp> ISpan, ISampleRate, IClockFreq;
            
			HRESULT hRes =GetProperty(L"Span", &ISpan);
			if (FAILED(hRes)) return hRes;

			hRes =GetProperty(L"SampleRate", &ISampleRate);
			if (FAILED(hRes)) return hRes;

			hRes =GetProperty(L"ClockFrequency", &IClockFreq);
			if (FAILED(hRes)) return hRes;

			// SampleRate = span*2.56
			if (User==(long)&_sampleRate){
				isSpan = false;
				_span=((double)*newVal)/2.56;
			}else{
				isSpan = true;
				_span=*newVal;
			}

			ViInt32 group, chanList[1]={1};
	    
            // create a temporary channel group to set/get the span value.
			// Create a one element channel group.  The id is returned to group.
			DAQ_CHECK(hpe1432_createChannelGroup(_session,1,chanList,&group));            
			DAQ_CHECK(hpe1432_setActive(_session, group, HPE1432_CHANNEL_OFF));

			// Determine the corresponding Clock Frequency so that the span can be set
			// to the closest value possible.
			_clockFreq = FindClockFreq(NewValue, isSpan);
			DAQ_CHECK(hpe1432_setClockFreq(_session, group, _clockFreq));
            DAQ_CHECK(hpe1432_setSpan(_session, group, _span));
			IClockFreq->put_Value(CComVariant(_clockFreq));

			// get back the actual span                       
            DAQ_CHECK(hpe1432_getSpan(_session, group, &(double)_span));
 	    
			// done with the temp channel group
			DAQ_CHECK(hpe1432_deleteChannelGroup(_session, group));
	    	    
			// update the data member with the actual value
			_sampleRate=_span*2.56; 


			// Don't set the value of a property that has just
            // been set (could cause recursion)
            //if (User==(long)&_sampleRate){
			if (isSpan == false){
                // update the property value in the engine
                ISpan->put_Value(CComVariant(_span));	    	    
                *newVal=_sampleRate;
            }else{
                // update the engine's value for sampleRate
				ISampleRate->put_Value(CComVariant(_sampleRate));
                *newVal=_span;
            }
			ISpan.Release();
			ISampleRate.Release();
			IClockFreq.Release();

	    return S_OK;
            
        }
		else if (User==(long)&_triggerType)
		{
			long newTrigger=(long)*newVal;

			// If TriggerType changes need to update the TriggerCondition values.
			CComPtr<IProp> ITrigCondition;
			HRESULT hr =GetProperty(L"TriggerCondition", &ITrigCondition);
			if (!SUCCEEDED(hr)) return hr;
            
			if (newTrigger==TRIG_TYPE_HW_ANALOG){
				// analog input channel trigger 
				ITrigCondition->ClearEnumValues();                
		
				ITrigCondition->AddMappedEnumValue(RISING,   L"Rising");
				ITrigCondition->AddMappedEnumValue(FALLING,  L"Falling");
                
				ITrigCondition->AddMappedEnumValue(ENTERING, L"Entering");
				ITrigCondition->AddMappedEnumValue(LEAVING,  L"Leaving");
    
				ITrigCondition->put_Value(CComVariant(RISING));
				ITrigCondition->put_DefaultValue(CComVariant(RISING));
				_triggerCondition=RISING;                                
			}else if (newTrigger==TRIG_TYPE_EXTERNAL){
				// External Trigger
				ITrigCondition->ClearEnumValues();
				ITrigCondition->AddMappedEnumValue(HPE1432_TRIGGER_EXT_POS, L"PositiveEdge");
				ITrigCondition->AddMappedEnumValue(HPE1432_TRIGGER_EXT_NEG, L"NegativeEdge");
				ITrigCondition->put_Value(CComVariant(HPE1432_TRIGGER_EXT_POS));
				ITrigCondition->put_DefaultValue(CComVariant(HPE1432_TRIGGER_EXT_POS));
				_triggerCondition=HPE1432_TRIGGER_EXT_POS; 
		    }

			// Error checking for negative TriggerDelays and for TriggerRepeats with hardware triggering.
			if (newTrigger == TRIG_TYPE_HW_ANALOG || newTrigger == TRIG_TYPE_EXTERNAL){
                if (_triggerDelay<0)
					return(E_PRETRIGGER_NOT_SUPPORTED);
/*[SK]
				if (_triggerRepeat>0)
					return E_TRIGGER_REP_NOT_SUPPORTED;
[SK]*/
			}

			ITrigCondition.Release();
		}
/*[SK]
		else if (User==(long)&_triggerRepeat)
		{
			if ((double)*newVal > 0 && ( _triggerType == TRIG_TYPE_HW_ANALOG || _triggerType == TRIG_TYPE_EXTERNAL)){
				return(E_TRIGGER_REP_NOT_SUPPORTED);
			}
		}
[SK]*/
		else if (User==(long)&_triggerDelay)
		{
			double newTriggerDelay = (double)*newVal;
			
			if (newTriggerDelay < 0 && ( _triggerType == TRIG_TYPE_HW_ANALOG || _triggerType == TRIG_TYPE_EXTERNAL)){
				return(E_PRETRIGGER_NOT_SUPPORTED);
			}

			// When the data size is set to HPE1432_DATA_SIZE_16, then the delay 
			// will be rounded down to an even number (by HP).  I round up.
			if ((_triggerType==TRIG_TYPE_HW_ANALOG) && (((int)newTriggerDelay)%2 == 1)){
				_triggerDelay = ((double)*newVal) + 1;
				*newVal=_triggerDelay;
			}

		}
		else if (User==USER_VAL(_triggerConditionValue))
		{
			if (_triggerType == TRIG_TYPE_HW_ANALOG){
				DAQ_CHECK(VerifyTriggerConditionValue(NewValue));
			}
		}


		// Update the local variable.
		PROP_FROMUSER(User)->SetLocal(*newVal);
    return S_OK;
}

// Verifies that for HwAnalog triggers, TriggerConditionValue is a two-element vector.
int hpvxiAD::VerifyTriggerConditionValue(VARIANT *newValue){

	if (V_VT(newValue) == (VT_ARRAY | VT_R8)) {
        
        long        uBound, lBound;	
        SAFEARRAY * psa = V_ARRAY(newValue);
        double *pr;
        
		// Verify that a two element vector is given.
        SafeArrayGetLBound (psa, 1, &lBound);
        SafeArrayGetUBound (psa, 1, &uBound);
        int size = uBound - lBound + 1;
        
        HRESULT hr = SafeArrayAccessData (psa, (void **) &pr);
        if (FAILED (hr)) {
            SafeArrayDestroy (psa);
            return E_SAFEARRAY_FAILURE;
        }	                                                                    
        
		// Error if first element of array is greater than the second ([10 1]).
        if (pr[1] <= pr[0]) {
            SafeArrayUnaccessData (psa);
            return E_INVALID_TRIGGERCONDITIONVALUE;
        }                                                
        
        SafeArrayUnaccessData (psa);
	}else{
		return E_INVALID_TRIGGERCONDITIONVALUE;
	}

	return S_OK;
}


// Called by SetProperty to determine the valid ClockFrequency for the specified span.
double hpvxiAD::FindClockFreq(VARIANT *newSpan, bool isSpan){

    // variant_t is a more friendly data type to work with
    variant_t *var = (variant_t*)newSpan;       

	// define the valid Clock Frequencies.
	double validClock[] = {40960, ((double)(24576000))/((double)(586)), ((double)(24576000))/((double)(557)),
		48000, 49152, 50000, 51200,((double)(24576000))/((double)(469)), 61400, 62500, 64000, 65536,
		((double)(10000000))/((double)(150)), 76800,78125,80000,81920,96000,98304,100000,102400, 122880,
		125000, 128000, ((double)(10000000))/((double)(75)), 153600, 156250,
	    163840,192000,196608}; 

	// Define how many times ClockFrequency can be divided by 2.
	int div2;
	int numClocks;
	if (_maxSR == 51200){
		div2 = 8;	
		numClocks = 21;
	}else{
		div2 = 16;
		numClocks = 30;
	}

	

	// Define the closest clock frequency.
	double clockFreq = validClock[0];
	double freqdif = validClock[0];

	double span = (double)(*var);
	if (isSpan == false){
		span = span/2.56;
	}
	
	double nextClock;
	double powerClock;

	// Loop through and find the closest clock frequency.
	for (int i=0; i<numClocks; i++){
		// Define the next valid clock frequency to check - must divide by 2.56.
		if (_maxSR == 51200){
			// HP E1432
			if (validClock[i] <= 51200){
				nextClock = validClock[i]/2.56;
			}else{
				nextClock = validClock[i]/5.12;
			}
		}else{
			// HP E1433
			nextClock = validClock[i]/2.56;
			if (validClock[i] > 128000){
				div2 = 0;
			}
		}

		// Incrementally divide by a power of 2 (from 8 back to 0) and determine
		// how close the nextClock is to the specified newSpan.
		for (int j=div2; j>=0; j--){
			powerClock = nextClock/pow(2,j);
			if (span <= powerClock){
				if (freqdif > (powerClock - span)){
					freqdif =  powerClock - span;
					clockFreq = validClock[i];
				}
				break;
			}
		}
	}

	// Try using the divide by 5 values.
	if (freqdif != 0){
		for (int i=0; i<numClocks; i++){
			// Define the next valid clock frequency to check - must divide by 2.56.
			if (_maxSR == 51200){
				// HP E1432
				if (validClock[i] <= 51200){
					nextClock = validClock[i]/(2.56*5);
				}else{	
					nextClock = validClock[i]/(5.12*5);
				}
			}else{
				// HP E1433
				nextClock = validClock[i]/(2.56*5);
				if (validClock[i] > 128000){
					nextClock = validClock[i]/2.56;
					div2 = 0;
				}
			}					

			// Incrementally divide by a power of 2 (from 8 back to 0) and determine
			// how close the nextClock is to the specified newSpan.
			for (int j=div2; j>=0; j--){
				powerClock = nextClock/pow(2,j);
				if (span <= powerClock){
					if (freqdif > (powerClock - span)){
						freqdif =  powerClock - span;
						clockFreq = validClock[i];
					}
					break;
				}
			}
		}
	}

	return clockFreq;
}

// This is called by the engine to set channel properties or if a channel is added.
// Inputs:
//      channel property interface
//      property container interface
//      channel pointer
//      new property value

STDMETHODIMP hpvxiAD::SetChannelProperty(long User, NESTABLEPROP *pChan, VARIANT *newValue)
{
    
    int chan=pChan->Index-1;      
    
    long numChans;
    
    HRESULT hRes = _EngineChannelList->GetNumberOfChannels(&numChans);
    if (FAILED(hRes)) return hRes;
    
        
		variant_t newVal = (variant_t*)newValue;

        switch (User){
		case INPUTRANGE:
	    	DAQ_CHECK(SetInputRange(newValue, pChan->Index));
            break;
		case COUPLING:
			_coupling[chan]=(long)newVal;
			break;
		case SOURCE:
	        _inputSource[chan]=(long)newVal;
			break;
	     case GROUND:
	        _groundingMode[chan]=(long)newVal;
			break;
        case MODE:
            _inputMode[chan]=(long)newVal;
            break;
        default:
	    break;
		}
        
	// If prop is NULL than a channel is being constructed.  The local variable
	// _nChannels needs to be updated to reflect a possible channel that was added.
    if (numChans!=_nChannels)
        _nChannels = numChans;  
    
    return S_OK;
}


// Called by hpvxiAD::SetChannelProperty.
int hpvxiAD::SetInputRange(VARIANT *newValue, int chan)
{
    
    if (V_VT(newValue) == (VT_ARRAY | VT_R8))
    {
        
        long        uBound, lBound;	
        SAFEARRAY * psa = V_ARRAY(newValue);
        double *pr;
        
		// Verify that a two element vector is given?
        SafeArrayGetLBound (psa, 1, &lBound);
        SafeArrayGetUBound (psa, 1, &uBound);
        int size = uBound - lBound + 1;
        _ASSERT(size==2);		
        
        HRESULT hr = SafeArrayAccessData (psa, (void **) &pr);
        if (FAILED (hr)) {
            SafeArrayDestroy (psa);
            return E_SAFEARRAY_FAILURE;
        }	                                                                    
        
		// Error if first element of array is greater than the second ([10 1]).
        if (pr[1] <= pr[0]) {
            SafeArrayUnaccessData (psa);
            return E_INVALID_CHAN_RANGE;
        }                                                
        
        SafeArrayUnaccessData (psa);
                
        double range = max( fabs(pr[0]), fabs(pr[1]) );
            
        long index = chan-1;
		chan = _chanList[index];
        
        switch (_inputMode[index]) {
        case HPE1432_INPUT_MODE_VOLT:
        case HPE1432_INPUT_MODE_ICP:
	    	
			// Set the range and get the actual value.
    	    DAQ_CHECK(hpe1432_setRange(_session, chan, range));	    	    	    	    
			DAQ_CHECK(hpe1432_getRange(_session, chan, &range));	    
	    
			// Update the local variable with actual value range was set to.
			_chanRange[1][index]=range; 
            _chanRange[0][index]=-range; 
    
			break;                    
        case HPE1432_INPUT_MODE_CHARGE:
            
			// Set the range and get the actual value.
            DAQ_CHECK(hpe1432_setRangeCharge(_session, chan, range));
			DAQ_CHECK(hpe1432_getRangeCharge(_session, chan, &range));	    
	    
			// Update the local variable with actual value range was set to.
			_chanRange[1][index]=range; 
            _chanRange[0][index]=-range; 
        	    
            break;
        case HPE1432_INPUT_MODE_MIC:           
        case HPE1432_INPUT_MODE_MIC_200V:
        
			// Set the range and get the actual value.
            DAQ_CHECK(hpe1432_setRangeMike(_session, chan, range));
			DAQ_CHECK(hpe1432_getRangeMike(_session, chan, &range));	    	    

			// Update the local variable with actual value range was set to.
            _chanRange[1][index]=range; 
            _chanRange[0][index]=-range; 
    
            break;
        }
        
        pr[1]=range;
        pr[0]=-range;
                
    }else{
        return E_INVALID_CHAN_RANGE;
    }    
 
    return S_OK;
}


//
// called when a channel is added, reordered or deleted
//
STDMETHODIMP hpvxiAD::ChildChange(DWORD typeofchange,  NESTABLEPROP *pChan)
{
    
    DWORD reason=typeofchange & CHILDCHANGE_REASON_MASK;
    
    if (pChan)
    {
        switch (reason)
        {
        case DELETE_CHILD:
            DAQ_CHECK(hpe1432_setActive(_session, pChan->HwChan, HPE1432_CHANNEL_OFF));
            _nChannels--;
            break;
        case ADD_CHILD :
            {  // Channel constructor.
                // Channels must be in ascending order and contain no repeats.
                long numChans;
                
                HRESULT hRes = _EngineChannelList->GetNumberOfChannels(&numChans);
                
                // Error if the channel is repeated.
                for (int i = 0; i<numChans-1; i++){
                    
                    NESTABLEPROP *loopChan;        
                    
                    // loopchan is a pointer to the NESTABLEPROP struct.
                    _EngineChannelList->GetChannelStructLocal(i, &loopChan);	
                    
                    // compare the HwChannel of the property being added (pChan) to each channel
                    // in the loops HwChannel (loopChan).
                    if (pChan->HwChan == loopChan->HwChan){
                        return E_CHANNEL_REPEAT;
                    }
                }
                
                // Error if the channel is added in an incorrect order.
                if (numChans >= 2){
                    // Get the HWID of the last channel in the list.
                    NESTABLEPROP *lastChan;
                    _EngineChannelList->GetChannelStructLocal(numChans-2, &lastChan);
                    
                    // Compare the two ids.
                    if (_validChanList[pChan->HwChan - 1] < _validChanList[lastChan->HwChan - 1])
                        return E_INVALID_CHANNEL_ORDER;
                    
                }
                
                // Set the ConversionExtraScaling property.
                AICHANNEL *chan;
                _EngineChannelList->GetChannelStructLocal(i,(NESTABLEPROP**)&chan);
                if (_validScaleFactor[pChan->HwChan - 1] == 1){
                    // 1432
                    chan->ConversionExtraScaling=2.73351459504128; //2.73351459503174;
                }else{
                    // 1433
                    chan->ConversionExtraScaling=2.25012493133545; //2.25012493134330;   
                }
                _nChannels++;
            }
            break;
            
        }
    }
    if(typeofchange & END_CHANGE)
    {
        DAQ_CHECK(InitChannels());
    }
    return S_OK;
}


// Called by hpvxiAD::ChildChange.
int hpvxiAD::InitChannels()
{
    
    // Reinitialize local channel variables to their default values.
    DAQ_CHECK(ReallocCGLists());   
    
    // Initialize variables.
    NESTABLEPROP *chan;   
    CComQIPtr<IPropContainer, &_uuidof(IChannel)> Container;
    variant_t val;
    long uBound, lBound;	
    
    // initialize channels params into local member variables
    for (int i=0; i<_nChannels; i++) {    
        _EngineChannelList->GetChannelStructLocal(i, &chan);	
        if (chan==NULL) break;
        
        // Initialize chanList to the channel specified.
        //_chanList[i] = (short)chan->HwChan;
        _chanList[i] = _validChanList[chan->HwChan-1];
        
        GetChannelContainer(i, &Container);
        if (Container == NULL) break;
        
        // Restore _inputMode
        Container->get_MemberValue(CComBSTR(L"inputmode"), &val);
        _inputMode[i] = (long)val;
        
        // Restore _coupling
        Container->get_MemberValue(CComBSTR(L"coupling"), &val);
        _coupling[i] = (long)val;
        
        // Restore _groundingMode
        Container->get_MemberValue(CComBSTR(L"groundingmode"), &val);
        _groundingMode[i] = (long)val;
        
        // Restore _inputSource
        Container->get_MemberValue(CComBSTR(L"inputsource"), &val);
        _inputSource[i] = (long)val;
        
        // Restore _chanrange
        Container->get_MemberValue(CComBSTR(L"inputrange"), &val);
        
        SAFEARRAY * psa = V_ARRAY(&val);
        double *pr;
        
        // Get the lower and upper bound of the array.
        SafeArrayGetLBound (psa, 1, &lBound);
        SafeArrayGetUBound (psa, 1, &uBound);
        
        // pr points to the safe array data.
        HRESULT hr = SafeArrayAccessData (psa, (void **) &pr);
        if (FAILED (hr)) {
            SafeArrayDestroy (psa);
            return E_SAFEARRAY_FAILURE;
        }
        
        _chanRange[0][i] = pr[0];
        _chanRange[1][i] = pr[1];
        SafeArrayUnaccessData (psa);
        
        Container.Release();
    }       
    
    return S_OK;
}


// called by hpvxi::InitChannels.
int hpvxiAD::ReallocCGLists()
{
    
    // Delete the local variables.
    delete [] _chanList;
    delete [] _chanRange[0];
    delete [] _chanRange[1];
    delete [] _coupling;
    delete [] _groundingMode;
    delete [] _inputSource;
    delete [] _inputMode;
    
	// Determine the number of channels in the engine and update local variables.
    long numChans;                    
    _EngineChannelList->GetNumberOfChannels(&numChans);
    _nChannels=numChans;
    
	// If no channels exist set local variables to NULL.
    if (_nChannels==0) {
        _chanList=NULL;
        _chanRange[0]=NULL;
        _chanRange[1]=NULL;
		_coupling=NULL;
        _inputSource=NULL;
        _groundingMode=NULL;
        _inputMode=NULL;
        return DAQ_NO_ERROR;
    }
    
	// Initialize the channel local variables.
    _chanList = new long[_nChannels];
    if (_chanList==NULL) return E_MEM_ERROR;
    
    _chanRange[0] = new double[_nChannels];
    if (_chanRange[0]==NULL) return E_MEM_ERROR;
    
    _chanRange[1] = new double[_nChannels];
    if (_chanRange[1]==NULL) return E_MEM_ERROR;

    _coupling = new long[_nChannels];
    if (_coupling==NULL) return E_MEM_ERROR;

    _groundingMode = new long [_nChannels];
    if (_groundingMode==NULL) return E_MEM_ERROR;

    _inputSource = new long [_nChannels];
    if (_inputSource==NULL) return E_MEM_ERROR;
    
    _inputMode = new long [_nChannels];
    if (_inputSource==NULL) return E_MEM_ERROR;
    
    // set the channel defaults
    for (int i=0; i<_nChannels; i++) 
    {
        _chanRange[0][i]  = -10;
        _chanRange[1][i]  = 10;        
        _chanList[i]      = 0;        
		_coupling[i]      = HPE1432_COUPLING_DC;
        _groundingMode[i] = HPE1432_INPUT_LOW_GROUNDED;
        _inputSource[i]   = HPE1432_INPUT_HIGH_NORMAL;
        _inputMode[i]     = HPE1432_INPUT_MODE_VOLT;
    }
    
    return DAQ_NO_ERROR;
}


// 
// Clean up when object is deleted
//
hpvxiAD::~hpvxiAD()
{

	AUTO_LOCK;

	// Stop the object.
    Stop();
    
    // channels need to be manually deactivated and deleted.
	//if (_callbackRegistered == true){
	//    hpe1432_setActive(_session, _gid, HPE1432_CHANNEL_OFF);
	//	hpe1432_deleteChannelGroup(_session, _gid);
    //}
    //    rmDev(UserId[0]);

    // Close the session only if no other objects exist.

	// Delete local variables.
    delete [] _chanRange[0]; _chanRange[0]= NULL;
    delete [] _chanRange[1]; _chanRange[1]= NULL;
    delete [] _chanList;     _chanList	  = NULL;
    delete [] _coupling;     _coupling	  = NULL;
    delete [] _groundingMode;_groundingMode=NULL;
    delete [] _inputSource;  _inputSource = NULL;
    delete [] _inputMode;    _inputMode   = NULL;
    delete [] _triggerChannel;

    ATLTRACE("HPVXI driver Close\n");
}


// called by the engine to stop the device
STDMETHODIMP hpvxiAD::Stop()
{
	AUTO_LOCK;
    _running=false;
	RunningADPtr = NULL;
	globalGidAI = NULL;

    delete [] _buffer;  
	_buffer=NULL;

	if (_callbackRegistered == true && globalGidAO == NULL){
		// FinishMeasure stops all input and sources.  Should only be done if AO 
		// is not running.  If AO is running, it will be stopped by finishMeasure.
		hpe1432_finishMeasure(_session,_gid);
    }

	// Delete the object.
	if (_callbackRegistered == true){
	    hpe1432_setActive(_session, _gid, HPE1432_CHANNEL_OFF);
		hpe1432_deleteChannelGroup(_session, _gid);
		if (_triggerType==TRIG_TYPE_HW_ANALOG){
			// Delete the object created for the TriggerChannel.
			hpe1432_setActive(_session, _trigGrpID, HPE1432_CHANNEL_OFF);
			hpe1432_deleteChannelGroup(_session, _trigGrpID);
		}
    }

    return S_OK;
}

// Called by the engine to handle errors thrown by the device
STDMETHODIMP hpvxiAD::TranslateError(HRESULT in,BSTR *out)
{
    
    TCHAR lpMsgBuf[401];
    
    int size=LoadString(_Module.GetResourceInstance(), in, lpMsgBuf,400);
    
    if (size) {        
        *out = CComBSTR(lpMsgBuf).Detach();
    }else {
        ViSession	    session;		// session handle    
        GetGlobalSession(session);
        // lpMsgBuf contains error message details.
        hpe1432_error_message(session,in,lpMsgBuf);
        hpe1432_errorDetails(session, lpMsgBuf, 400);
        *out = CComBSTR(lpMsgBuf).Detach();
    } 
    
    return S_OK;
}

// This is called by the engine when a buffer is ready to be
// fed to the hardware
STDMETHODIMP hpvxiAD::BufferReadyForDevice()
{
    return S_OK;
}


void hpvxiAD::Callback(ViInt32 b)
{
     
	AUTO_LOCK;

	// Initialize variables.
    ViStatus	vierr;	
    ViInt32	    reason;
    TCHAR       errStr[401];
    
	if (globalGidAO != NULL){
		hpe1432_reenableInterrupt(_session, globalGidAO);
	}

    // find cause of interrupt
    vierr=hpe1432_getInterruptReason(_session,_chanList[0],&reason);  
    if(vierr) {            
        hpe1432_error_message(_session,vierr,errStr);
        ATLTRACE("error %d = %s\n",vierr,errStr);
        hpe1432_errorDetails(_session, errStr, 400);
        ATLTRACE("error detail: %s\n", errStr);        
        _engine->DaqEvent(EVENT_ERR, 0, _samplesAcquired, L"Unknown error");
        return;
    }    

    if (HPE1432_IRQ_BLOCK_READY & reason) {	//interrupt occured because full buffer was collected
        
		long actualCount;
        BUFFER_ST *engBuf; 
		
		//all data,requested by the engine are collected -- set the LstBuf flag...
		//..Do not attempt to get another buffer for the next block -- the engine will not give any
		if ( _samplesAcquired >= (__int64)((_triggerRepeat.Value+1) * _samplesPerTrigger.Value) )
			_LstBufFlg = true;

		HRESULT status = _engine->GetBuffer(0, &engBuf);

        if ( (engBuf== NULL) || FAILED(status) )
		{
 			if ( _LstBufFlg == true )
			{				
				Stop();	//if beyond last requested buffer -- stop! Othrwise the stray..
				return;	//..DATAMISSED will be posted.
			}
			_engine->DaqEvent(EVENT_DATAMISSED, 0, _samplesAcquired, L"Data Overrun");		
            return; 
        }

 		//once we are already here WITH NO ERRORS -- update _callbackCnt and _samplesAcquired,..
		//..update starting point in the buffer
		engBuf->StartPoint= _samplesAcquired * _nChannels;
		_callbackCnt++;

		//for hardware triggers we will collect only required fraction of the last block
		if ( ( (_blockSize * _callbackCnt) >= _samplesPerTrigger.Value ) &&
			  ((_triggerType==TRIG_TYPE_HW_ANALOG) || (_triggerType==TRIG_TYPE_EXTERNAL) ) )	
			_samplesAcquired += static_cast<__int64>((_samplesPerTrigger.Value - (_callbackCnt-1)*_blockSize));
		else
			_samplesAcquired += _blockSize;
	      
        // Read the data and return data to buffer.    
        vierr=hpe1432_readRawData(_session, _gid, HPE1432_TIME_DATA, 
            (char*)_buffer, _blockSize*_nChannels, &actualCount, HPE1432_WAIT_FLAG);                     

        if (vierr) {            
            hpe1432_error_message(_session,vierr,errStr);
            ATLTRACE("error %d = %s\n",vierr,errStr);
            hpe1432_errorDetails(_session, errStr, 400);
            ATLTRACE("error detail: %s\n", errStr);
			engBuf->ValidPoints=0;
            engBuf->StartPoint=_samplesAcquired * _nChannels;        
			_engine->PutBuffer(engBuf);
	        _engine->DaqEvent(EVENT_ERR, 0, _samplesAcquired, bstr_t(errStr));
			return;
        } 

#if 0
        double scaleFactor;
		// Returns a scaling factor to convert the raw data into volts.
        vierr=hpe1432_getScale(_session, _gid, &scaleFactor);
        if (vierr) {            
            hpe1432_error_message(session,vierr,errStr);
            ATLTRACE("error %d = %s\n",vierr,errStr);
            hpe1432_errorDetails(session, errStr, 400);
            ATLTRACE("error detail: %s\n", errStr);
            _engine->DaqEvent(ERR, 0, _samplesAcquired, bstr_t(errStr));		
            return;
        }    	
#endif

        //build an array arranged by samples from the array arranged by channels..
		//..consider, that last sample can be smaller than the whole block
		ViInt32	blockFraction;

		//again different approach in HW triggers and SW triggers. SW triggering imposes..
		//..collection of integer blocks, whereas SW -- only necessary data points.
		if ( ( (_blockSize * _callbackCnt) >= _samplesPerTrigger.Value ) &&
			  ((_triggerType==TRIG_TYPE_HW_ANALOG) || (_triggerType==TRIG_TYPE_EXTERNAL) ) )	
			blockFraction = static_cast<ViInt32>(_samplesPerTrigger.Value - (_callbackCnt-1)*_blockSize);
		else
			blockFraction = _blockSize;

		for (int j = 0; j < _nChannels; j++) 
        {
            for (int i = 0; i < blockFraction; i++) 
            {
                ((short*)engBuf->ptr)[i*_nChannels+j] = _buffer[j*blockFraction+i];                
            }
        }
        
    	engBuf->ValidPoints = blockFraction * _nChannels;

                
        if ( (_triggerType==TRIG_TYPE_HW_ANALOG) || (_triggerType==TRIG_TYPE_EXTERNAL) )
		{
			// post the trigger event after when the 1st callback is recieved
			if (_callbackCnt == 1)
			{
				double time; 
				double timeCorrect;
				_engine->GetTime(&time);

				if ( (_blockSize * _callbackCnt) >= _samplesPerTrigger.Value )
					timeCorrect = _samplesPerTrigger.Value - (_callbackCnt-1)*_blockSize;
				else
					timeCorrect = _blockSize;
				timeCorrect /= _sampleRate;
				double triggerTime = time - timeCorrect;
				engBuf->Flags |= BUFFER_START_TIME_VALID ;//| BUFFER_GAP_BEFORE;
				engBuf->StartTime = triggerTime;

				_engine->DaqEvent( EVENT_TRIGGER, triggerTime,
					     static_cast<__int64>(_samplesPerTrigger.Value * _triggersOccured * _nChannels),
						 L"Hardware Trigger" );
			}
			// collected enough blocks of data to satisfy one trigger
			if ( (_blockSize * _callbackCnt) >= _samplesPerTrigger.Value )
			{
				hpe1432_initMeasure(_session, _gid);
				_triggersOccured ++;
				_callbackCnt = 0;
			}
			// requested number of triggers have occured -- now stop and post STOP event
			if ( _triggersOccured == (_triggerRepeat.Value+1) )
			{			
				Stop();
				_engine->DaqEvent(EVENT_STOP, 0, _samplesAcquired, L"Stop");
				_triggersOccured = 0;
			}
        }//end if TRIG_TYPE_HW_ANALOG or TRIG_TYPE_EXTERNAL
	
		_engine->PutBuffer(engBuf);
        
    }//end if the interrupt is caused by acquisition of a block 

    else if (HPE1432_IRQ_MEAS_ERROR & reason)
        _engine->DaqEvent(EVENT_ERR, 0, _samplesAcquired * _nChannels, L"FIFO Overflow");		

    else if (HPE1432_IRQ_OVERLOAD_CHANGE & reason)
        ATLTRACE("Overload status changed");
     
    else if (HPE1432_IRQ_MEAS_WARNING & reason) 
    {
        ATLTRACE("Measurement warning");
		return;
    }
    
	// Reenable interrupts so that the next interrupt can be processed.
	if (_running == true)		//otherwise adaptor has been stopped and all channels killed..
	{							//..therefore _gid == NULL, and error is posted
		vierr=hpe1432_reenableInterrupt(_session, _gid);
		if (vierr) {
			hpe1432_error_message(_session,vierr,errStr);
			ATLTRACE("error %d = %s\n",vierr,errStr);
			hpe1432_errorDetails(_session, errStr, 400);
			ATLTRACE("error detail: %s\n", errStr);     
			return;
		}
	}
}

// called by hpvxiAD::Start.
int hpvxiAD::TriggerSetup()
{

	AUTO_LOCK;

	if (globalGidAO != NULL){
		hpe1432_reenableInterrupt(_session, globalGidAO);
	}

    // convert trigger delay to samples if necessary
	long triggerDelay;
    if (_triggerDelayUnits==0){
        triggerDelay = static_cast<long>(_triggerDelay*_sampleRate);
	}else{
		triggerDelay = (long)(_triggerDelay);
    }
    
    if (_triggerType==TRIG_TYPE_HW_ANALOG)
    {
        DAQ_CHECK(hpe1432_setAutoTrigger(_session, _gid, HPE1432_MANUAL_TRIGGER));

		// Error checking for TriggerConditionValue for HwAnalog triggering.
		CComPtr<IProp> ITrigConditionValue;
		HRESULT hr =GetProperty(L"TriggerConditionValue", &ITrigConditionValue);
		if (!SUCCEEDED(hr)) return hr;

		variant_t currentTCV;
		ITrigConditionValue->get_Value(&currentTCV);
		DAQ_CHECK(VerifyTriggerConditionValue(&currentTCV));
		ITrigConditionValue.Release();

		// Get pointer to the IProp interface for the TriggerChannel property.
	    CComPtr<IProp> pProp;
        HRESULT hRes =GetProperty(L"TriggerChannel",&pProp);
        if (!(SUCCEEDED(hRes))) return hRes;

		// Initialize variables.
        variant_t var;
        
		// Get the value of the TriggerChannel property.
        pProp->get_Value(&var);
        
		// Error if a TriggerChannel was not specified.
        if (var.vt==VT_EMPTY){
           return E_INVALID_TRIGGERCHANNEL;
        }

		// pCont is a pointer to the IPropContainer for the channels defined
		// in the TriggerChannel property.
        CComQIPtr<IPropContainer, &__uuidof(IPropContainer)>  pCont;
        pCont=var;
        var.Clear();
        
        // fix this to support multiple trigger channels
		// var - the value of the HwChannel property of the channels in the 
		//       TriggerChannel property.
        hRes = pCont->get_MemberValue(L"hwchannel", &var);
        if (FAILED(hRes)) return hRes;
        _triggerChannel[0]= _validChanList[static_cast<unsigned int>((double)var - 1)]; 
		
		// Get the index of the specified HwChannel.
		variant_t indexTC; 
		pCont->get_MemberValue(L"index", &indexTC);

		// Convert TriggerConditionValues to percentages of the InputRange.
		long IRange = static_cast<long>(_chanRange[1][((long)(indexTC))-1]);
		ViReal64 lowerTC = (((double)(_triggerConditionValue[0]))*100)/IRange;
		ViReal64 upperTC = (((double)(_triggerConditionValue[1]))*100)/IRange;

		if ((lowerTC < -125) || (upperTC > 125)){
			return E_INVALID_TC_RANGE; 
		}

	//	if ((upperTC - lowerTC) < 10){
	//		_engine->WarningMessage(L"It is recommended that the difference between the upper and lower \nTriggerConditionValues be at least 10%% of the full scale InputRange.");
	//	}

		// create a channel group for triggering
        DAQ_CHECK(hpe1432_createChannelGroup(_session, 1, _triggerChannel, &_trigGrpID));
        
        /*
        Level mode

        If the mode is set to "level" and the trigger slope is positive, 
        then  the module triggers when the signal crosses both the upper 
        and lower  trigger levels in the positive direction. If the trigger 
        slope is  negative, the module triggers when the signal crosses both 
        levels in the  negative direction.  Setting two trigger levels prevents 
        the module from  triggering repeatedly when a noisy signal crosses the 
        trigger level.

        Bound mode

        If the mode is set to "bound" and the trigger slope is positive (leaving),   
        then the module triggers when the signal exits the zone between the upper  
        and lower trigger levels in the either direction.  If the trigger slope   
        is negative, the module triggers when the signal enters the zone between   
        the upper and lower trigger levels.
        */

		// rising vs. falling
        if (_triggerCondition==RISING || _triggerCondition==LEAVING)
            _triggerSlope=HPE1432_TRIGGER_SLOPE_POS;
        else
            _triggerSlope=HPE1432_TRIGGER_SLOPE_NEG;

        ViInt32 condition;

		// bound vs. level
        if (_triggerCondition==RISING || _triggerCondition==FALLING)
            condition=HPE1432_TRIGGER_MODE_LEVEL;
        else
            condition=HPE1432_TRIGGER_MODE_BOUND;

        // fix this to work for the specified trigger channel(s)
        DAQ_CHECK(hpe1432_setTrigger(_session, _trigGrpID, HPE1432_CHANNEL_ON, 
            (long)triggerDelay, lowerTC, upperTC, _triggerSlope, condition));

		pProp.Release();
        
    }
    else if (_triggerType==TRIG_TYPE_EXTERNAL){
		// TriggerType = HwDigital.
		DAQ_CHECK(hpe1432_setAutoTrigger(_session, _gid, HPE1432_MANUAL_TRIGGER));
        DAQ_CHECK(hpe1432_setTriggerExt(_session, _gid, _triggerCondition));
    } else  {
		// immediate, software, or engine "manual" triggering
        DAQ_CHECK(hpe1432_setAutoTrigger(_session, _gid, HPE1432_AUTO_TRIGGER));
    }           

   	if (globalGidAO != NULL){
		hpe1432_reenableInterrupt(_session, globalGidAO);
	}

    return S_OK;
}    

// Called by hpvxiAD::Start.
int hpvxiAD::ChannelSetup()
{
	AUTO_LOCK;

	if (globalGidAO != NULL){
		hpe1432_reenableInterrupt(_session, globalGidAO);
	}

    for (int i=0;i<_nChannels; i++)
    {	
        switch (_inputMode[i])
        {
        case HPE1432_INPUT_MODE_VOLT:
        case HPE1432_INPUT_MODE_ICP:	    	    
    	    DAQ_CHECK(hpe1432_setRange(_session, _chanList[i], _chanRange[1][i]));  	        	    
			break;                    
        case HPE1432_INPUT_MODE_CHARGE:
            DAQ_CHECK(hpe1432_setRangeCharge(_session, _chanList[i], _chanRange[1][i]));	    	        	    
            break;
        case HPE1432_INPUT_MODE_MIC:           
        case HPE1432_INPUT_MODE_MIC_200V:
            DAQ_CHECK(hpe1432_setRangeMike(_session, _chanList[i], _chanRange[1][i]));	      	    
            break;
        }
        

		DAQ_CHECK(hpe1432_setInputMode(_session, _chanList[i], _inputMode[i]));
		DAQ_CHECK(hpe1432_setCoupling(_session, _chanList[i], _coupling[i]));

        // high and low input configuration
        DAQ_CHECK(hpe1432_setInputLow(_session, _chanList[i], _groundingMode[i]));
        DAQ_CHECK(hpe1432_setInputHigh(_session, _chanList[i], _inputSource[i]));
    }

#if 0
    // icp must be set in banks of 4
    for (i=0; i<_nChannels; i++)
    {
	if (_inputMode[i]==HPE1432_INPUT_MODE_ICP && nChannels>=4) 
	    inputMode[3]=inputMode[2]=inputMode[1]=inputMode[0];
	
    }   
#endif

	if (globalGidAO != NULL){
		hpe1432_reenableInterrupt(_session, globalGidAO);
	}

    return S_OK;            
}


// This is called by the engine to start the device.
// Keeps track of the state of objects.
STDMETHODIMP hpvxiAD::Start ()
{

    AUTO_LOCK;
    // Initialize variables.
    int status;
    
    // If an object is already running - error.
    if (RunningADPtr!=NULL){
        status = E_RUN_TWO_AI;
    }else{
        // Try to start the object.
        status = InternalStart();
        if (status){
            // Object did not start.
            _running = false;
        }else{
            // Object started successfully.
            RunningADPtr=this;
            globalGidAI = _gid;
        }
    }
    
    
    return status;
}

// perform a software trigger on the device 
STDMETHODIMP hpvxiAD::Trigger ()
{
    AUTO_LOCK;

    DAQ_CHECK(hpe1432_initMeasure(_session,_gid));
    // Reenable the analog output interrupt if the analog output object is running.

    if (globalGidAO != NULL){
        hpe1432_reenableInterrupt(_session, globalGidAO);
    }
    return S_OK;
}

// Start the hardware.
int hpvxiAD::InternalStart(){

    AUTO_LOCK;
    
    // Initialize variables.
    _samplesAcquired=0;
    _callbackCnt=0;
	_triggersOccured = 0;
	_LstBufFlg = false;
    
    // _session   - session handle.
    // _nChannels - number of channels to add.
    // _chanList  - channel ids.
    // _gid       - pointer to channelgroup id.
    DAQ_CHECK(hpe1432_createChannelGroup(_session,_nChannels,_chanList,&_gid));
    
    // set the channel ranges
    DAQ_CHECK(ChannelSetup());
    
    DAQ_CHECK(TriggerSetup());
    
    HRESULT hRes = _engine->GetBufferingConfig(&_blockSize, NULL);
    if (FAILED(hRes)) return hRes;    
    
    _buffer = new short[_blockSize*_nChannels];
    if (_buffer==NULL) return E_MEM_ERROR;
    
    // set the fifo blocksize 
    DAQ_CHECK(hpe1432_setBlocksize(_session,_gid, _blockSize)); 
    DAQ_CHECK(hpe1432_setDataSize(_session, _gid, HPE1432_DATA_SIZE_16));
    DAQ_CHECK(hpe1432_setDataMode(_session,_gid, HPE1432_CONTINUOUS_MODE));	
    DAQ_CHECK(hpe1432_setCalcData(_session, _gid, HPE1432_DATA_TIME));
    
    // _clockSource = 0 when the engine's Internal ClockSource is used.
    if ((_clockSource == 0) || (_clockSource == HPE1432_CLOCK_SOURCE_INTERNAL)){
        hpe1432_setClockSource(_session, _gid, HPE1432_CLOCK_SOURCE_INTERNAL);
    }else {
        hpe1432_setAutoGroupMeas(_session, _gid, HPE1432_AUTO_GROUP_MEAS_OFF);
        hpe1432_setClockSource(_session, _gid, _clockSource);
    }
    
    // Determine if the callback needs to be installed.
    // This seems to depend on the first id only.
    if (_callbackRegistered == false){
        if (installCallback(UserId[0]) == false){
            globalCallbackInstalled = false;
        }else{
            globalCallbackInstalled = true;
        }
        _callbackRegistered = true;
        
        // Add the id to the callback installed list.	
        addDev(UserId[0]);
    }else{
        globalCallbackInstalled = true;
    }
    
    if (!globalCallbackInstalled) {
        // installs a pointer to the callback function  that will be called upon 
        // receiving an interrupt from the HPE1432.
        ViStatus callbackStatus = hpe1432_callbackInstall(_session, _gid, globalCallback, 0);
        if (callbackStatus != 0){
            return E_CANNOT_INSTALL_CALLBACK;
        }
       	globalCallbackInstalled=true;
    }
    
    // Set up the trigger and clock lines.
    DAQ_CHECK(hpe1432_setTtltrgSatrg(_session, _gid, HPE1432_TTLTRG_2));
    
    DAQ_CHECK(hpe1432_setTtltrgClock(_session, _gid, HPE1432_TTLTRG_1));
    
    // Only want to be interrupted when the data is ready or there was a block overflow.
    DAQ_CHECK(hpe1432_setInterrupt(_session,_gid, 7,
        HPE1432_IRQ_MEAS_ERROR | HPE1432_IRQ_BLOCK_READY ));      
    
    // Set the Span.
    DAQ_CHECK(hpe1432_setClockFreq(_session, _gid, _clockFreq));
    DAQ_CHECK(hpe1432_setSpan(_session, _gid, _span));

    if (globalGidAO != NULL){
        hpe1432_reenableInterrupt(_session, globalGidAO);
    }
    
    _running=true;
    
    return S_OK;
}

// utility function the engine may or may not call.
STDMETHODIMP hpvxiAD::GetStatus(hyper *samplesProcessed, BOOL *running)
{
	AUTO_LOCK;
    *samplesProcessed=_samplesAcquired;
	*running = _running;
    return S_OK;
}

void hpvxiAD::addDev(int id){

	AUTO_LOCK;
	if (_numIdSpecified != 1){
		// Need to install the callback on the board that the first channel is contained by.
		 NESTABLEPROP *firstChan;
		 _EngineChannelList->GetChannelStructLocal(0, &firstChan);
		 long idToFind = _validChanList[firstChan->HwChan-1];
		 long foundIds = 0;	
		 for (int i = 0; i< numFound; i++){
			foundIds += globalIdList[i*4+1];
			if (foundIds > idToFind){
				id = globalIdList[i*4];
				break;
			}
		 }
	}

	if (id >= static_cast<int>(_installedCallbackIDs.size())){
		_installedCallbackIDs.resize(id+1);
	}

	_installedCallbackIDs[id] = 1;
}


bool hpvxiAD::installCallback(int id){
	// If the id has a value of zero that the id has not yet been initialized - return false.
	// True indicates that the id has been initialized.
	AUTO_LOCK;	

	if (id >= static_cast<int>(_installedCallbackIDs.size())){
		return false;
	}

	int isId = _installedCallbackIDs[id];
	if (isId != 0){
		// hardware has been initialized.
		return true;
	}else{
		// hardware has not been initialized.
		return false;
	}
}
