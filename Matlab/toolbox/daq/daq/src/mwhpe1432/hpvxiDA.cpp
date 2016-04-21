// hpvxiDA.cpp : Implementation of CMwdeviceApp and DLL registration.
// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.1.6.2 $  $Date: 2003/12/04 18:39:26 $



#include "stdafx.h"

#include "mwhpe1432.h"
#include "daqmex.h"
#include "errors.h"
#include "hpvxiDA.h"
#include <comcat.h>
#include <limits>
#include "util.h"
#include <stdio.h>
#include <sarrayaccess.h>

/////////////////////////////////////////////////////////////////////////////
//


#define AUTO_LOCK TAtlLock<hpvxiDA> _lock(*this)

hpvxiDA *hpvxiDA::RunningDAPtr=NULL;

hpvxiDA::hpvxiDA() :
_bufferingconfig(1024),
_chanList(NULL),
_validChanList(NULL),
_chasis(0),
_clockSource(0),
_clockFreq(0),
_cola(NULL),
_numIdSpecified(0),
_callbackRegistered(false),
_rampRate(NULL),
_engineBlkSize(4096),
_gid(0),
_id(""),
_isStarted(false),
_lastBufferGap(false),
_lessThanBuffer(false),
_maxSR(51200),
_maxChannels(0),
_minSpan(0),
_maxSpan(51200),
_nChannels (0),
_pointsQueued(0),
_running(0),
_samplesOutput(0),
_sourceOutput(NULL),
_sourceMode(NULL),
_sampleRate(51200), 
_session(NULL),
_span(20000),
_sum(NULL),
_triggerType(TRIG_TYPE_IMMEDIATE)

{
	AUTO_LOCK;
	_buffer = new long[4096];

    _chanRange[0] = new double[1];
    _chanRange[1] = new double[1];
    
    _chanRange[0][0] = -10.0;
    _chanRange[1][0] =  10.0;   
	

    ATLTRACE("HPVXI Source Driver Open\n");    
	
}

// Destructor.
hpvxiDA::~hpvxiDA()
{
	AUTO_LOCK;

	// Stop the object.
    Stop();

	// Close the session only if no other objects exist.
//         rmDev(UserId[0]);
   
	// Delete the local variables.
    delete [] _chanRange[0]; _chanRange[0]= NULL;
    delete [] _chanRange[1]; _chanRange[1]= NULL;
    delete [] _chanList;     _chanList	  = NULL;

	delete [] _buffer;       _buffer      = NULL;
    
	delete [] _rampRate;     _rampRate    = NULL;
    delete [] _sourceOutput; _sourceOutput= NULL;
    delete [] _sourceMode;   _sourceMode  = NULL;
	delete [] _cola;	     _cola        = NULL;
	delete [] _sum;			 _sum         = NULL;
    
}


// Set the fields needed for daqhwinfo. This is called by Open to 
// define the _maxSR and _maxChannels local variables.
HRESULT hpvxiDA::SetDaqHwInfo()
{  
    HRESULT hRes;
	// prop is a pointer to the IProp interface.
	// pCont is a pointer to the IPropContainer interface.
    CComPtr<IProp> prop;       
    
    // hwinfo property container
    CComQIPtr<IPropContainer, &__uuidof(IPropContainer)>  pCont(GetHwInfo());   
    
	// Return harsware configuration information.
    ViInt32 *configInfo = new ViInt32[27*numFound];        
    memset(configInfo, 0, sizeof(configInfo));
    
	// configInfo (output) - returns 27 numbers for each module, so the total array
	//                       needs to be 27*numFound long.
    ViStatus vierr=hpe1432_getHWConfig(0, numFound, addList, configInfo);    
    
	// Translate the error message and error if hpe1432_getHWConfig did not complete
	// correctly.
	if(vierr) {            
        TCHAR  errStr[401];
       hpe1432_error_message(_session,vierr,errStr);                        
        hpe1432_errorDetails(_session, errStr, 400);
        ATLTRACE("getHWConfig error detail: %s\n", errStr);                        
    }    
    
	// Initialize variables.
    bstr_t DeviceName;

    // based on the id, figure out which device is which in the config info            
    long idx=0;        

    for (int i=0; i<numFound; i++) {
		// Initialize variables.
        char numStr[8]={'\0'};
		char *ptr=strchr(_id,':');
        ptr+=2;
        int j=0;
	
        // Search the id string for the address.  The string is in the form
        // VXI0::address::INSTR
        while (j<8 && *ptr != ':' && *ptr!=',') {
            numStr[j++] = *ptr++;         
        }

		if (atoi(numStr)==addList[i]) {
			idx=i;
			break;
		}	
    }
    
	// configInfo element 6 contains the sca_id, five IDS for the SCAs that are present.
    switch (configInfo[6+(27*idx)]) {
    case HPE1432_SCA_ID_NONE:   
        DeviceName="HP E1434A";
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
        break;
    case HPE1432_SCA_ID_SONATA:
        DeviceName="HP E1433A";
        break;
    case HPE1432_SCA_ID_CLARION:
        DeviceName="HP E1434A";
        break;
	case -842150451:
		// HP E1433A - none of the names given in the getHWConfig help match HP E1433A.
        DeviceName="HP E1433A";
		break;
    default:
        DeviceName="unknown";
        ATLTRACE("Unknown device");
        break;
    }

    delete [] configInfo;

	// Initialize Span, SampleRate and Clock Frequency information.
    _maxSR= 65536;
    _minSpan = 40960/(2.56*5*pow(2,16));
	_maxSpan = 25600;
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
    
    // total channels     
    DAQ_CHECK(pCont->put_MemberValue(CComBSTR(L"totalchannels"),CComVariant(_maxChannels)));        

    // differential input channels
    CComVariant vids;
	short* ids;
    ids = new short[_maxChannels];
    for (int j=0;j<_maxChannels;j++){
        ids[j]=j+1;
	}

    CreateSafeVector(ids,_maxChannels,&vids);

    DAQ_CHECK(pCont->put_MemberValue(CComBSTR(L"channelids"),vids)); 
	
	delete [] ids;

    // Polarity.
    DAQ_CHECK(pCont->put_MemberValue(CComBSTR(L"polarity"), CComVariant(L"Bipolar")));    
	
	// Coupling can only be DC.
    DAQ_CHECK(pCont->put_MemberValue(CComBSTR(L"coupling"), CComVariant(L"DC")));    
	
    // subsystem type
    DAQ_CHECK(pCont->put_MemberValue(CComBSTR(L"subsystemtype"),CComVariant(L"AnalogOutput")));
		
	// SampleType.
    DAQ_CHECK(pCont->put_MemberValue(CComBSTR(L"sampletype"),CComVariant(1L)));    
	
    // number of bits
    DAQ_CHECK(pCont->put_MemberValue(CComBSTR(L"bits"),CComVariant(32L)));    
	
	// AdaptorName.
    DAQ_CHECK(pCont->put_MemberValue(CComBSTR(L"adaptorname"), CComVariant(L"hpe1432")));    
	
    // driver description    (DeviceName is defined in the switch statement above).
    DAQ_CHECK(pCont->put_MemberValue(CComBSTR(L"devicename"),CComVariant((BSTR)DeviceName)));    
	
    DAQ_CHECK(pCont->put_MemberValue(CComBSTR(L"vendordriverdescription"),
		CComVariant(L"VXI Plug & Play Driver")));    
	
    DAQ_CHECK(pCont->put_MemberValue(CComBSTR(L"vendordriverversion"),CComVariant(L"1.0")));    
	
    // native data type    
    DAQ_CHECK(pCont->put_MemberValue(CComBSTR(L"nativedatatype"), CComVariant(VT_I4)));	    
	
    // conversion offset    
    //DAQ_CHECK(pCont->put_MemberValue(CComBSTR(L"conversionoffset"),CComVariant(0L)));    	
	
    // min & max sample rates (_maxSR is defined in the switch statement above). CComVariant(25.6)
    DAQ_CHECK(pCont->put_MemberValue(CComBSTR(L"minsamplerate"), CComVariant(_minSpan*2.56)));	    
    DAQ_CHECK(pCont->put_MemberValue(CComBSTR(L"maxsamplerate"), CComVariant(_maxSR)));	    

    return S_OK;
}


// This is called by the engine when the constructor is called.
// An engine interface is passed in and stored in a member variable.
// Optional parameters such as ID are passed in as s1, s2, s3.
HRESULT hpvxiDA::Open(IDaqEngine *engine, wchar_t *devName )
{

    AUTO_LOCK;
	// assign the engine access pointer
    CmwDevice::Open(engine);
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
	// id specified by user in the form: VXIO::8,32::INSTR
    _id = _wcsupr(devName);     
    
    // Determine the chasis number and the hardware ids specified.
    
    // Initialize variables.
    wchar_t  *tmpValue;
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
    while(*tmpValue != 0 && tmpValue < (wchar_t *)_id+_id.length()) {    
        
		if (iswdigit(*tmpValue)) {
			UserId[count] = wcstol(tmpValue, &tmpValue, 10);
			count++;
		}else{
			tmpValue++;
		}
	}

	// Store the number of ids specified.
	_numIdSpecified = count;

	// Initialize the hardware if it has not be initialized yet.
        DAQ_CHECK(GetGlobalSession(_session));

	// Determine which channels are valid for the specified id.
	bool foundId = false;
	int totalSource = 0;

	// k-loop contains the number of ids that the user specified.
	// Ex. analogoutput('hpe1432', [8 32])  k-loop loops twice for the 8 and 32.
	for (int k=0; k<count;k++){
		totalSource = 0;

		// Loop through the possible ids found - up to 256 can be found.
		for (i=0; i < static_cast<unsigned int>(numFound); i++){

			if (UserId[k] == globalIdList[i*4]){
				foundId = true;

				// Error if the id does not have any of the specified channel type.
				// Ex. error if analoginput is called on a 1434 which has no analoginput channels.
				if (globalIdList[i*4+2] == 0){
					return E_INVALID_DEVICE_ID;
				}

				// Increment the total number of channels by the number of analogoutput
				// channels supported by this hardware.
				_maxChannels += globalIdList[i*4+2];

				// Create the list of ids for the total channel array.
				for (int j = 0; j<_maxChannels; j++){
					_validChanList.push_back( totalSource+j+1);
					_validScaleFactor.push_back(globalIdList[i*4+3]);
				}

				break;
			}
			// Increment total source so that the validChanList contains the correct values.
			totalSource+=globalIdList[i*4+2];
		}
		if (foundId == false){
			// Error if the device id was not found in the list of available ids.
			return E_INVALID_DEVICE_ID;
		}else{
			// Reset and continue on to the next id specified by the user.
			foundId = false;
		}
	}

	// common properties 
	// prop is a pointer to the IProp interface.
    CComPtr<IProp> prop;       
    
    
    // device specific properties
       
    
	_span = 20000;

    // maxSR, _minSpan and _maxSpan gets set here so it must be called before  
    // setting the range values for the sample rate property    
    DAQ_CHECK(SetDaqHwInfo());      
	
	// pRoot is a pointer to the IPropContainer interface.  Create the device 
	// specific property Span.  Returns prop which is a pointer to the IProp
	// interface for the Span property.
    GetPropRoot()->CreateProperty(L"Span", &CComVariant(_span),__uuidof(IProp),(void**) &prop);
    CComVariant val(_span);
    prop->put_User((long)&_span);
    prop->put_Value(val);
    prop->put_DefaultValue(val);
    
	// Define the range of the Span property.
    CComVariant minvar(_minSpan);
    CComVariant maxvar(_maxSpan);    
    prop->SetRange(&minvar, &maxvar);
    prop.Release();

    // sample rate
    prop = RegisterProperty(L"SampleRate", (DWORD)&_sampleRate);
    val=_span*2.56;
    prop->put_Value(val);
    prop->put_DefaultValue(val);
    
	// Define the range of the SampleRate property.
    minvar=_minSpan*2.56;
    maxvar=_maxSR;   
    prop->SetRange(&minvar, &maxvar);
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

	// TriggerType has the hp specific values of HwDigitalPos and HwDigitalNeg plus
	// the values common to all hardware (immediate, manual)
    prop = RegisterProperty(L"TriggerType", (DWORD)&_triggerType);    
    prop->AddMappedEnumValue(HPE1432_TRIGGER_EXT_POS, L"HwDigitalPos");
	prop->AddMappedEnumValue(HPE1432_TRIGGER_EXT_NEG, L"HwDigitalNeg");
    prop.Release();

	// Create the channel properties.

    // OutputRange should default to [-10 10]
    CComVariant out;
    short outRange[]={-10,10};
    CreateSafeVector(outRange,2,&out);

	GetChannelProperty(L"OutputRange", &prop);
        prop->put_DefaultValue(out);
	prop->put_User(OUTPUT_RANGE);
    prop->put_DefaultValue(out);
    prop->SetRange(&CComVariant(-10L),&CComVariant(10L));
    prop.Release();

	// HwChannel.
    DAQ_CHECK(GetChannelProperty(L"HwChannel", &prop));    
        prop->put_DefaultValue(CComVariant(1L));
    prop->put_User((long)HWCHAN);    
    prop->SetRange(&CComVariant(1L),&CComVariant(_maxChannels));    
    prop.Release();

    // SourceMode is an enumerated property.
    DAQ_CHECK(CreateChannelProperty(L"SourceMode", NULL, &prop));        
    prop->AddMappedEnumValue(HPE1432_SOURCE_MODE_ARB,	L"Arbitrary");	
    prop->put_DefaultValue(CComVariant(HPE1432_SOURCE_MODE_ARB));
    prop->put_User((long)SOURCE_MODE);
    prop.Release();        
	
	// SourceOutput is an enumerated property.
    DAQ_CHECK(CreateChannelProperty(L"SourceOutput", NULL, &prop));    
    prop->AddMappedEnumValue(HPE1432_SOURCE_OUTPUT_NORMAL,	L"Normal");	
    prop->AddMappedEnumValue(HPE1432_SOURCE_OUTPUT_GROUNDED,  L"Grounded");
    prop->AddMappedEnumValue(HPE1432_SOURCE_OUTPUT_OPEN,	L"Open");
    prop->AddMappedEnumValue(HPE1432_SOURCE_OUTPUT_CAL,	L"CALOUT");
    prop->AddMappedEnumValue(HPE1432_SOURCE_OUTPUT_MULTI,	L"SRC&CALOUT");    
    prop->put_DefaultValue(CComVariant(HPE1432_SOURCE_OUTPUT_NORMAL));
    prop->put_User((long)SOURCE_OUTPUT);
    prop.Release();

	// RampRate can range from 0 to 100 with a default value of 0.
    DAQ_CHECK(CreateChannelProperty(L"RampRate", &CComVariant(0L), &prop));    
    prop->put_User((long)RAMP_RATE);    
    prop->SetRange(&CComVariant(0L),&CComVariant(100L));    
    prop.Release();

	// COLA.
    DAQ_CHECK(CreateChannelProperty(L"COLA", NULL, &prop));
    prop->AddMappedEnumValue(HPE1432_SOURCE_COLA_OFF, L"Off");
	prop->AddMappedEnumValue(HPE1432_SOURCE_COLA_ON, L"On");
	prop->put_DefaultValue(CComVariant(HPE1432_SOURCE_COLA_OFF));
    prop->put_User((long)COLA);
    prop.Release();  

	// Sum.
    DAQ_CHECK(CreateChannelProperty(L"Sum", NULL, &prop));    
    prop->AddMappedEnumValue(HPE1432_SOURCE_SUM_OFF, L"Off");
	prop->AddMappedEnumValue(HPE1432_SOURCE_SUM_ON, L"On");
	prop->put_DefaultValue(CComVariant(HPE1432_SOURCE_SUM_OFF));
    prop->put_User((long)SUM);
    prop.Release();

	// Set the range for the BufferingConfig's first value.  This can be done through the 
	// EngineBlockSize property.
    DAQ_CHECK(GetProperty(L"EngineBlockSize", &prop));
    CComVariant minblock(1);
    CComVariant maxblock(4096);    
	prop->SetRange(&minblock, &maxblock);
	prop.Release();

	// Define the BufferingConfig property.
	// pBC is a pointer to the BufferingConfig IProp interface.
    CComPtr<IProp> pBC;
            
    HRESULT hRes =GetProperty(L"BufferingConfig", &pBC);
    if (FAILED(hRes)) return hRes;

	// Register the BufferingConfig property with the engine.
	pBC->put_User((long)&_bufferingconfig);
	pBC.Release();

	// Create a hidden ClockFreqency property.
    DAQ_CHECK(GetPropRoot()->CreateProperty(L"ClockFrequency", &CComVariant(_clockFreq),__uuidof(IProp),(void**) &prop));    
	prop->put_IsHidden(true);
	prop->put_IsReadOnly(true);
	prop.Release();

	if (globalGidAI != NULL){
		hpe1432_reenableInterrupt(_session, globalGidAI);
	}

	if (globalGidAO != NULL){
		hpe1432_reenableInterrupt(_session, globalGidAO);
	}



    return S_OK;
	
}


// Register the property with a local variable (called by Open).
// This is for when SetProperty is called, the local variables get updated.
// Returns the IProp interface to the specified property, name.
CComPtr<IProp> hpvxiDA::RegisterProperty(LPWSTR name, DWORD dwUser)
{
	// prop is the pointer to the IProp interface for the property, name.
    CComPtr<IProp> prop;
   GetProperty(name, &prop);
	
	// Error if name is an invalid name.
    if (prop==NULL) {
        char errStr[128];
        sprintf(errStr, "HPVXI: Invalid property: '%s'.", name);
        throw errStr;
    }
    
	// Register the property with the engine so that the local variable can
	// be updated when the user modifies the property.
    prop->put_User(dwUser);

    return prop;
}

// This is called by the engine when a property is set.
// An interface to the property along with the new property value is passed in.
// prop     - IProp interface.
// NewValue - new property value. 
// The error code is returned if the property set fails.
// prop contains the old value for the property being set while NewValue is the new value that
// the property is being set to.  If SetProperty succeeds prop will be updated to the NewValue
// otherwise it will stay at the old value.
STDMETHODIMP hpvxiDA::SetProperty(long User, VARIANT *NewValue)  
{
    // User contains the address of the local data member of the property 
    // being set.
    variant_t *newVal = (variant_t*)NewValue;        
    
    // When either span or sample rate is set, the other needs
    // to be updated. The driver cares only about span.
    if (User==(long)&_sampleRate || User==(long)&_span) {   
        
        bool isSpan;
        
        // Get the IProp interface to the Span and SampleRate properties.
        CComPtr<IProp> ISpan, ISampleRate, IClockFreq;
        
        HRESULT hRes =GetProperty(L"Span", &ISpan);
        if (FAILED(hRes)) return hRes;
        
        hRes =GetProperty(L"SampleRate", &ISampleRate);
        if (FAILED(hRes)) return hRes;
        
        hRes =GetProperty(L"ClockFrequency", &IClockFreq);
        if (FAILED(hRes)) return hRes;
        
        // If the SampleRate property is being modified, set span to sampleRate/2.56
        // otherwise set span to the value passed in.
        if (User==(long)&_sampleRate){
            isSpan = false;
            _span=((double)*newVal)/2.56;
        }else{
            isSpan = true;
            _span=*newVal;
        }
        
        // Source channels begin at 4097.
        ViInt32 group, chanList[1]={4097};
        
        // create a temporary channel group to set/get the span value
        DAQ_CHECK(hpe1432_createChannelGroup(_session,1,chanList,&group));            
        
        // Determine the corresponding Clock Frequency so that the span can be set
        // to the closest value possible.
        _clockFreq = FindClockFreq(NewValue, isSpan);
        DAQ_CHECK(hpe1432_setClockFreq(_session, group, _clockFreq));       
        DAQ_CHECK(hpe1432_setSourceSpan(_session, group, _span));
        IClockFreq->put_Value(CComVariant(_clockFreq));
        
        // get back the actual span and update the _span local variable value.              
        DAQ_CHECK(hpe1432_getSourceSpan(_session, group, &(double)_span));
        
        // done with the temp channel group.
        DAQ_CHECK(hpe1432_deleteChannelGroup(_session, group));
        
        // update the data member with the actual value.
        _sampleRate=_span*2.56; 
        
        // Don't set the value of a property that has just been set (could cause recursion)
        if (isSpan == false){
            // update the property value in the engine for span.
            ISpan->put_Value(CComVariant(_span));	    	    
            *newVal=_sampleRate;
        }else {
            // update the engine's value for sampleRate
            ISampleRate->put_Value(CComVariant(_sampleRate));
            *newVal=_span;
        }
        
        ISpan.Release();
        ISampleRate.Release();
        IClockFreq.Release();
        
        return S_OK;
    } // Close SampleRate/Span If statement.
    else if (User == (long)&_bufferingconfig){
        
        if (V_VT(NewValue) == (VT_ARRAY | VT_R8)){
            
            long        uBound, lBound;	
            SAFEARRAY * psa = V_ARRAY(newVal);
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
            
            // Error if the EngineBlockSize is greater than 4096.
            if (pr[0] > 4096) {
                SafeArrayUnaccessData (psa);
                return E_INVALID_ENG_BLKSIZE_GREAT;
            }                                                
            
            // Error if the EngineBlockSize is less than 1.
            if (pr[0] < 1) {
                SafeArrayUnaccessData (psa);
                return E_INVALID_ENG_BLKSIZE_LESS;
            }                                                
            
            _bufferingconfig = static_cast<long>(pr[0]);
            SafeArrayUnaccessData (psa);
            return S_OK;
        }
    } // Close the bufferingconfig If statement.
    
    // Update the local variable for the property being set.
    ((CLocalProp*)User)->SetLocal(*newVal);        
    
    return S_OK;
}


// Called by SetProperty to determine the valid ClockFrequency for the specified span.
double hpvxiDA::FindClockFreq(VARIANT *newSpan, bool isSpan){

    // variant_t is a more friendly data type to work with
    variant_t *var = (variant_t*)newSpan;       

	// define the valid Clock Frequencies.
	double validClock[] = {40960, ((double)(24576000))/((double)(586)), ((double)(24576000))/((double)(557)),
		48000, 49152, 50000, 51200,	((double)(24576000))/((double)(469)), 61400, 62500, 64000, 65536};

	// If more than one source channel is used the maximum clock frequency is 51200.
	int numClocks = 12;
	if (_nChannels > 1){
		numClocks = 7;
	}

	// Define how many times ClockFrequency can be divided by 2.
	int div2;
	if (_maxSR == 51200){
		div2 = 8;	
	}else{
		div2 = 16;
	}

	// Define the closest clock frequency.
	// double clockFreq = validClock[(sizeof(validClock)/sizeof(double)) - 1];
	double clockFreq = validClock[numClocks-1];
	double freqdif = validClock[0];

	double span = (double)(*var);
	if (isSpan == false){
		span = span/2.56;
	}
	
	double nextClock;
	double powerClock;

	// Loop through and find the closest clock frequency.
	//for (int i=0; i<(sizeof(validClock)/sizeof(double)); i++){
	for (int i=0; i<numClocks; i++){
		// Define the next valid clock frequency to check - must divide by 2.56.
		nextClock = validClock[i]/2.56;

		// Incrementally divide by a power of 2 (from 8/16 back to 0) and determine
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
		//for (int i=0; i<(sizeof(validClock)/sizeof(double)); i++){
		for (int i=0; i<numClocks; i++){
			// Define the next valid clock frequency to check - must divide by 2.56.
			nextClock = validClock[i]/(2.56*5);

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
//   prop     - IProp interface.
//   cont     - IPropContainer interface.
//   pChan    - channel pointer.
//   newValue - new property value.
STDMETHODIMP hpvxiDA::SetChannelProperty(long User, NESTABLEPROP *pChan, VARIANT *newValue)
{
   
	// Initialize variables.
    int chan=pChan->Index-1;      
    long numChans;
	int hwchan = pChan->HwChan;
	variant_t val;
    
	// Get the number of channels currently in use.
    DAQ_CHECK(_EngineChannelList->GetNumberOfChannels(&numChans));    
    
	// If the property exists get the address of the local member variable.
        
		variant_t newVal = (variant_t*)newValue;

		// Based on the User update the local member variable values.
        switch (User){
		case COLA:
			// The Sum and COLA properties cannot both be enabled at the same time.
			// Return an error if the Sum property is 'On' and trying to set the COLA property to 'On'.
			if ((_sum[chan] == HPE1432_SOURCE_SUM_ON) && ((long)newVal == HPE1432_SOURCE_COLA_ON)){
				return E_INVALID_COLA;
			}else{
				_cola[chan]=(long)newVal;
			}
			break;
		case SOURCE_OUTPUT:	    
			_sourceOutput[chan]=(long)newVal;
			break;
        case SOURCE_MODE:
            _sourceMode[chan]=(long)newVal;
            break;
		case RAMP_RATE:
			// Update the local variable for the channel being modified.
			_rampRate[chan] = (long)newVal;
			break;
		case OUTPUT_RANGE:
			DAQ_CHECK(SetOutputRange(newValue, pChan->Index));
			break;
		case SUM:
			// The Sum and COLA properties cannot both be enabled at the same time.
			// Return an error if the COLA property is 'On' and trying to set the Sum property to 'On'.
			if ((_cola[chan] == HPE1432_SOURCE_COLA_ON)  && ((long)newVal == HPE1432_SOURCE_SUM_ON)){
				return E_INVALID_SUM;
			}else{
				_sum[chan]=(long)newVal;
			}
			break;
        default:
			break;
		}
 
    if (numChans!=_nChannels)
        _nChannels = numChans;    

    return S_OK;
}

// Called by SetChannelProperty.
int hpvxiDA::SetOutputRange(VARIANT *newValue, int chan)
{
    
    if (V_VT(newValue) == (VT_ARRAY | VT_R8)){
        
        long        uBound, lBound;	
        SAFEARRAY * psa = V_ARRAY(newValue);
        double *pr;
        
		// Verify that a two element vector is given.
        SafeArrayGetLBound (psa, 1, &lBound);
        SafeArrayGetUBound (psa, 1, &uBound);
        int size = uBound - lBound + 1;
        _ASSERT(size==2);		
        
		// pr points to the safe array data.
        HRESULT hr = SafeArrayAccessData (psa, (void **) &pr);
        if (FAILED (hr)) {
            SafeArrayDestroy (psa);
            return E_SAFEARRAY_FAILURE;
        }	                                                                    
        
		// Error if [10 -10]
        if (pr[1] <= pr[0]) {
            SafeArrayUnaccessData (psa);
            return E_INVALID_CHAN_RANGE;
        }                                                
        
        SafeArrayUnaccessData (psa);
	
		double range = max( fabs(pr[0]), fabs(pr[1]) );      
		double originalRange = range;
		double tempRange = range;
                
		long index = chan-1;        
        
		// SRC_CHAN_OFFSET is defined as 4096 since source channels begin at 4097.
        chan = _chanList[chan-1];

		// set the range to the specified value.
		DAQ_CHECK(hpe1432_setRange(_session, chan, range));	    	    	    	    
	
		// get back the actual range.
		DAQ_CHECK(hpe1432_getRange(_session, chan, &range));	 
		
		while (range < originalRange){
			tempRange = tempRange + 0.1;
			DAQ_CHECK(hpe1432_setRange(_session, chan, tempRange));	    	    	    	    
			DAQ_CHECK(hpe1432_getRange(_session, chan, &range));	 
		}
	
		// Update the local variables with the actual value set.
		_chanRange[1][index]=range; 
		_chanRange[0][index]=-range; 
        
		// Update the safe array data.
        pr[1]=range;
        pr[0]=-range;
                
    }else {
        return E_INVALID_CHAN_RANGE;
    }    
 
    return S_OK;
}

// called when a channel is reordered or deleted
STDMETHODIMP hpvxiDA::ChildChange(DWORD typeofchange,NESTABLEPROP *pChan)
{
    DWORD reason=typeofchange & CHILDCHANGE_REASON_MASK;

    // Are the other types needed?
    if ( (reason==DELETE_CHILD) && pChan) 
    {		// set deleted channels inactive
        _nChannels--;
        DAQ_CHECK(hpe1432_setActive(_session, pChan->HwChan + SRC_CHAN_OFFSET, HPE1432_CHANNEL_OFF));	
    }
    if (reason==ADD_CHILD && pChan)
    {
        // Channel constructor.
        // Channels must be in ascending order and contain no repeats.
        long numChans;
        // Get the number of channels currently in use.
        DAQ_CHECK(_EngineChannelList->GetNumberOfChannels(&numChans));    
       
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
            if (_validChanList[pChan->HwChan - 1] < _validChanList[lastChan->HwChan -1]){
                return E_INVALID_CHANNEL_ORDER;
            }
        }
        _nChannels++;
        _ASSERTE(_nChannels==numChans);
    }
    if(typeofchange & END_CHANGE)
    {
        DAQ_CHECK(InitChannels());
    }
    return S_OK;	   
}

// Called by hpvxiDA::ChildChange.
// Updates the HWChannel field based on the channel added.
int hpvxiDA::InitChannels()
{
 
	// Reset the channel property local variables to their default values.
    DAQ_CHECK(ReallocCGLists());    

    // Initialize variables.
    NESTABLEPROP *chan;   
	CComQIPtr<IChannel> Container;
	variant_t val;
	long uBound, lBound;	

	// install channels params into local member variables
    for (int i=0; i<_nChannels; i++) {    
        _EngineChannelList->GetChannelStructLocal(i, &chan);	
        if (chan==NULL) break;

		// Initialize chanList to the channel specified (plus 4096).
        //_chanList[i] = chan->HwChan+SRC_CHAN_OFFSET;
		_chanList[i] = _validChanList[chan->HwChan-1] + SRC_CHAN_OFFSET;

		GetChannelContainer(i, &Container);
		if (Container == NULL) break;

		// Restore _sourceOutput
		Container->get_MemberValue(CComBSTR(L"sourceoutput"), &val);
		_sourceOutput[i] = (long)val;

		// Restore _sourceMode
		Container->get_MemberValue(CComBSTR(L"sourcemode"), &val);
		_sourceMode[i] = (long)val;

		// Restore _rampRate
		Container->get_MemberValue(CComBSTR(L"ramprate"), &val);
		_rampRate[i] = (long)val;

		// Restore _cola
		Container->get_MemberValue(CComBSTR(L"cola"), &val);
		_cola[i] = (long)val;

		// Restore _sum
		Container->get_MemberValue(CComBSTR(L"sum"), &val);
		_sum[i] = (long)val;

		// Restore _chanrange
		Container->get_MemberValue(CComBSTR(L"outputrange"), &val);

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

// Called by hpvxiDA::InitChannels.
// Initializes or sets to NULL the child property member variables.
int hpvxiDA::ReallocCGLists()
{
 
	// Delete the local variables.
    delete [] _chanList;
    delete [] _chanRange[0];
    delete [] _chanRange[1];
    delete [] _sourceOutput;
    delete [] _sourceMode;
	delete [] _rampRate;
	delete [] _cola;
	delete [] _sum;
    
	// Determine the number of channels that now exist.
    long numChans;                    
    
    _EngineChannelList->GetNumberOfChannels(&numChans);
    _nChannels=numChans;
    
	// If no channels exist set member variables to NULL.
    if (_nChannels==0) {
        _chanList=NULL;
        _chanRange[0]=NULL;
        _chanRange[1]=NULL;
        _sourceOutput=NULL;        
        _sourceMode=NULL;
		_rampRate=NULL;
		_cola = NULL;
		_sum = NULL;
        return S_OK;
    }

    // Otherwise, if channels do exist initialize the member variables.
    _chanList = new long[_nChannels];
    if (_chanList==NULL) return E_MEM_ERROR;
    
    // setup the channel range for each channel
    _chanRange[0] = new double[_nChannels];
    if (_chanRange[0]==NULL) return E_MEM_ERROR;
    
    _chanRange[1] = new double[_nChannels];
    if (_chanRange[1]==NULL) return E_MEM_ERROR;
    
	// Channel properties.
    _rampRate = new long [_nChannels];
    if (_rampRate==NULL) return E_MEM_ERROR;

    _sourceOutput = new long [_nChannels];
    if (_sourceOutput==NULL) return E_MEM_ERROR;
    
    _sourceMode = new long [_nChannels];
    if (_sourceMode==NULL) return E_MEM_ERROR;

    _sum = new long [_nChannels];
    if (_sum==NULL) return E_MEM_ERROR;

    _cola = new long [_nChannels];
    if (_cola==NULL) return E_MEM_ERROR;

    // set the channel defaults
    for (int i=0; i<_nChannels; i++) {
    
		_chanRange[0][i] = -10;
        _chanRange[1][i] =  10;        
        _chanList[i]     =  0;        

		_rampRate[i]     =  0;
		_sourceOutput[i] =  HPE1432_SOURCE_OUTPUT_NORMAL;
        _sourceMode[i]   =  HPE1432_SOURCE_MODE_ARB;
		_sum[i]          =  HPE1432_SOURCE_SUM_OFF;
		_cola[i]         =  HPE1432_SOURCE_COLA_OFF;

    }
    return S_OK;
}

// Source callback if not using threads.
// This outputs the data.
void hpvxiDA::srcCallback(int channel)
{
    AUTO_LOCK;

	// Initialize variables.
    ViStatus	vierr;	
    ViInt32	    reason;
    TCHAR       errStr[401];
	bool        LastBufferLoaded(false);
    
    ATLTRACE("Got interrupt\n");

	if (globalGidAI != NULL){
		hpe1432_reenableInterrupt(_session, globalGidAI);
	}

    // find cause of interrupt
    vierr=hpe1432_getInterruptReason(_session,_chanList[0],&reason);  //4097
	if(vierr) {            
        hpe1432_error_message(_session,vierr,errStr);        
        hpe1432_errorDetails(_session, errStr, 400);
        ATLTRACE("error detail: %s\n", errStr);      
        return;
    } 

	// HPE1432_IRQ_SRC_STATUS - Source channel interrupt.
    if (HPE1432_IRQ_SRC_STATUS & reason) {  

        long ready=0;     
		  
		// Get the buffer structure which contains a pointer to the data being output.
        BUFFER_ST *engBuf;
        _engine->GetBuffer(0, &engBuf); 

		if (!engBuf){
			ATLTRACE("Nullengine buffer");
			LastBufferLoaded = true;
		}else{
			for (int chan=0; chan<_nChannels; chan++) {                

				// Extract chan's data from the engine buffer.
				long* pbuf = (long*)(engBuf->ptr)+chan;
				for (int n = 0; n<engBuf->ValidPoints/_nChannels; n++){
					_buffer[n] = *pbuf;
					pbuf+=_nChannels;
				}

				// Keep checking until more data can be transferred to the source.
				do {
					ready = 0;
					vierr=hpe1432_checkSrcArbRdy(_session, _chanList[chan],
						     HPE1432_SRC_DATA_MODE_WAITAB, &ready); 
                    
					// If an error occurred, translate it and post an event.
					if (vierr) {
						hpe1432_error_message(_session,vierr,errStr);                        
		                hpe1432_errorDetails(_session, errStr, 400);
			            ATLTRACE("checkSrcArbRdy error detail: %s\n", errStr);   
				        return;
					}

				} while (ready == 0);
         
				// Write out the data to available buffer.
				vierr=hpe1432_writeSrcBufferData(_session, _chanList[chan], _buffer,
					(engBuf->ValidPoints/_nChannels), HPE1432_SRC_DATA_MODE_WAITAB); 

				// If an error occurred, translate it and post an event.
				if (vierr) {
					hpe1432_error_message(_session,vierr,errStr);                    
					hpe1432_errorDetails(_session, errStr, 400);
					ATLTRACE("writeSrcBufferData error detail: %s\n", errStr);        
					_engine->DaqEvent(EVENT_ERR, 0, _samplesOutput, (bstr_t)errStr);                    
				}
			}
		} //close for

		if (engBuf){
			// Update the SampleOutput value.
			SamplesOutput(static_cast<long>(_samplesOutput+=engBuf->ValidPoints/_nChannels));

			// Send a buffer back to the engine after the data has been sent out.
			_engine->PutBuffer(engBuf);   
		}

	}else if (HPE1432_IRQ_MEAS_ERROR & reason){
		// An error occurred.  Translate and post an event.
        hpe1432_error_message(_session,vierr,errStr);            
        hpe1432_errorDetails(_session, errStr, 400);
        ATLTRACE("error detail: %s\n", errStr);        
        _engine->DaqEvent(EVENT_ERR, 0, _samplesOutput, (bstr_t)errStr);
        return;
    }

	// If the last buffer has been loaded, stop the object and post a Stop event.
	if (LastBufferLoaded){
		Stop();
		_engine->DaqEvent(EVENT_STOP, 0, _samplesOutput, CComBSTR(L"STOP"));
		return;
	}else{
		// Need to reenable the interrupt so that the next interrupt can be processed.
	    vierr=hpe1432_reenableInterrupt(_session, _gid);
	
	    if (vierr) {
		    hpe1432_error_message(_session,vierr,errStr);            
			hpe1432_errorDetails(_session, errStr, 400);
			ATLTRACE("error detail: %s\n", errStr);         
			_engine->DaqEvent(EVENT_ERR, 0, _samplesOutput, (bstr_t)errStr);
			return;
		}
    }
	if (reason == 0){
		hpe1432_reenableInterrupt(_session, _gid);
	}
}


// Stop the device.
STDMETHODIMP hpvxiDA::Stop()
{

	AUTO_LOCK;
	RunningDAPtr=NULL;
	globalGidAO = NULL;

	// No longer running.
    _running = false;    
    
	if (_callbackRegistered == true && globalGidAI == NULL){
		// Cleans up after a measurement is no longer needed. FinishMeasure stops all 
		// input and sources.  Should only be done if AI is not running.
		ViStatus vierr = hpe1432_finishMeasure(_session,_gid);
	}

    // channels need to be manually deactivated before deleting.
	// _session  - Instrument handle.
	// _gid      - Group handle
	if (_callbackRegistered == true){
		hpe1432_setActive(_session, _gid, HPE1432_CHANNEL_OFF);
		hpe1432_deleteChannelGroup(_session, _gid);
    }

    return S_OK;
}

// Method called by the engine to start the device.
// Keeps track of the state of the object.
STDMETHODIMP hpvxiDA::Trigger ()
{
    
    AUTO_LOCK;
    // Initialize variables.
    int status;
    
    // If an object is already running - error.
    if (RunningDAPtr!=NULL){
        status = E_RUN_TWO_AO;
        if (globalGidAO != NULL){
            hpe1432_reenableInterrupt(_session, globalGidAO);
        }
        
    }else{
        // Try to start the object.
        status = InternalStart();
        if (status){
            // Object did not start.
            _running = false;
        }else{
            // Object started successfully.
            RunningDAPtr=this;
            globalGidAO = _gid;
        }
    }
    
    // Reenable the analog input interrupt if the analog input object is running.
    if (globalGidAI != NULL){
        hpe1432_reenableInterrupt(_session, globalGidAI);
    }
    
    return status;
}

// Start the hardware.
int hpvxiDA::InternalStart(){

    AUTO_LOCK;
    
    // At least two buffers of data need to be output.  If the second buffer from the engine is NULL, 
    // then the first buffer needs to be halfed so that two buffers can be written out.
    bool alterSize = false;
    
    BUFFER_ST *engBuf;                                
    _engine->GetBuffer(0, &engBuf); 
    if (engBuf==NULL){
        ATLTRACE("Engine buffer is null");
        return -1;
    }
    
    BUFFER_ST *engBuf2;                                
    _engine->GetBuffer(0, &engBuf2);
    if (engBuf2==NULL){
        alterSize = true;
    }
    
    // Get the engine's blocksize and use that for hardware blocksize.
    _engine->GetBufferingConfig(&_bufferingconfig, NULL);
    
    // Initialize variables.
    _samplesOutput=0;
    
    // Create the channel group based on the channel ids in _chanList.
    DAQ_CHECK(hpe1432_createChannelGroup(_session,_nChannels,_chanList,&_gid));
    
    // Activate those channels that were added.
    DAQ_CHECK(hpe1432_setActive(_session, _gid, HPE1432_CHANNEL_ON));
    
    // set the channel ranges
    DAQ_CHECK(ChannelSetup());          
    
    if (_triggerType==HPE1432_TRIGGER_EXT_POS){
        // TriggerType = HwDigitalPos.
        DAQ_CHECK(hpe1432_setAutoTrigger(_session, _gid, HPE1432_MANUAL_TRIGGER));
        DAQ_CHECK(hpe1432_setTriggerExt(_session, _gid, HPE1432_TRIGGER_EXT_POS));
    }else if (_triggerType==HPE1432_TRIGGER_EXT_NEG){
        // TriggerType = HwDigitalNeg.
        DAQ_CHECK(hpe1432_setAutoTrigger(_session, _gid, HPE1432_MANUAL_TRIGGER));
        DAQ_CHECK(hpe1432_setTriggerExt(_session, _gid, HPE1432_TRIGGER_EXT_NEG));
    }else{
        // HPE1432_AUTO_TRIGGER sets the module to perform the transition as soon as it enters 
        // the TRIGGER state.
        DAQ_CHECK(hpe1432_setAutoTrigger(_session, _gid, HPE1432_AUTO_TRIGGER));
    }
    
    // _clockSource = 0 when the engine's Internal ClockSource is used.
    if ((_clockSource == 0) || (_clockSource == HPE1432_CLOCK_SOURCE_INTERNAL)){
        hpe1432_setClockSource(_session, _gid, HPE1432_CLOCK_SOURCE_INTERNAL);
    }else{
        hpe1432_setAutoGroupMeas(_session, _gid, HPE1432_AUTO_GROUP_MEAS_OFF);
        hpe1432_setClockSource(_session, _gid, _clockSource);
    }
    
    if (_sourceMode[0]==HPE1432_SOURCE_MODE_ARB || _sourceMode[0]==HPE1432_SOURCE_MODE_BARB){
        // set the fifo blocksize 
        DAQ_CHECK(hpe1432_setSrcBufferMode(_session,_gid, HPE1432_SRC_BUFFER_CONTINUOUS));
        
        // Use the BufferingConfig size or hapf of the buffer block size if only one buffer of
        // data is available.
        if (!alterSize){
            DAQ_CHECK(hpe1432_setSrcBufferSize(_session, _gid, _bufferingconfig));  
            DAQ_CHECK(hpe1432_setSourceBlocksize(_session,_gid, _bufferingconfig));   
        }else{
            DAQ_CHECK(hpe1432_setSrcBufferSize(_session, _gid, (engBuf->ValidPoints)/2));  
            DAQ_CHECK(hpe1432_setSourceBlocksize(_session,_gid, (engBuf->ValidPoints)/2));   
        }
        
        DAQ_CHECK(hpe1432_setSrcBufferInit(_session,_gid, HPE1432_SRC_BUFFER_INIT_EMPTY));	
        
        if (_sourceMode[0]==HPE1432_SOURCE_MODE_ARB) {
            
            for (int chan=0; chan<_nChannels; chan++){     
                
                // Extract chan's data from the engine buffer.
                long* pbuf = (long*)(engBuf->ptr)+chan;
                for (int n = 0; n<engBuf->ValidPoints/_nChannels; n++){
                    _buffer[n] = *pbuf;
                    pbuf+=_nChannels;
                }
                
                // Initialize variables.
                TCHAR  errStr[401];
                ViStatus vierr;               
                long ready=0;
                
                // Loop until data can be transferred to the source.
                do 	{	
                    ready = 0;
                    
                    // Used to determine when more source data may be transferred.
                    // ready can be one of the following values:
                    //    HPE1432_SRCBUF_RDY   - the buffer is ready to continue to accept data.
                    //    HPE1432_SRCBUF_AVAIL - the buffer is ready to be started to accept data.
                    //    HPE1432_SRCBUF_FULL  - the buffer is full and not ready to accept data.
                    vierr=hpe1432_checkSrcArbRdy(_session, _chanList[chan],
                        HPE1432_SRC_DATA_MODE_WAITAB, &ready);                
                    
                    // If an error occurs, translate it and post to the engine as an event.
                    if(vierr){            
                        hpe1432_error_message(_session,vierr,errStr);                        
                        hpe1432_errorDetails(_session, errStr, 400);
                        ATLTRACE("checkSrcArbRdy error detail: %s\n", errStr);        
                        return vierr;
                    }    
                    
                } while (ready == 0);
                
                
                // Write to buffer A - Transfers ARB data from the host to the source.
                if (!alterSize){
                    // Write the entire first engine buffer.
                    DAQ_CHECK(hpe1432_writeSrcBufferData(_session, _chanList[chan], _buffer,
                        (engBuf->ValidPoints/_nChannels), HPE1432_SRC_DATA_MODE_WAITAB));       //(long*)engBuf->ptr
                }else{
                    // Write the first half of the first engine buffer.
                    DAQ_CHECK(hpe1432_writeSrcBufferData(_session, _chanList[chan], _buffer,
                        (engBuf->ValidPoints)/(2*_nChannels), HPE1432_SRC_DATA_MODE_WAITAB));                      
                }
            }
            
            if (!alterSize){
                // Update the SamplesOutput value based on the number of data points sent.
                _samplesOutput+=engBuf->ValidPoints/_nChannels;
                
                // Send a buffer back to the engine after the data has been sent out.
                _engine->PutBuffer(engBuf);
            }
            
            for (chan=0; chan<_nChannels; chan++){      
                
                // Initialize variables.
                TCHAR  errStr[401];
                ViStatus vierr;               
                long ready=0;
                
                // Extract chan's data from the engine buffer.
                // Extract chan's data from the engine buffer.
                
                if (!alterSize){
                    long* pbuf = (long*)(engBuf2->ptr)+chan;
                    for (int n = 0; n<engBuf2->ValidPoints/_nChannels; n++){
                        _buffer[n] = *pbuf;
                        pbuf+=_nChannels;
                    }
                }
                
                // Loop until data can be transferred to the source.
                do 	{	
                    ready = 0;
                    
                    // Used to determine when more source data may be transferred.
                    vierr=hpe1432_checkSrcArbRdy(_session, _chanList[chan],
                        HPE1432_SRC_DATA_MODE_WAITAB, &ready);                
                    
                    // If an error occurs, translate it and post to the engine as an event.
                    if(vierr){            
                        hpe1432_error_message(_session,vierr,errStr);                        
                        hpe1432_errorDetails(_session, errStr, 400);
                        ATLTRACE("checkSrcArbRdy error detail: %s\n", errStr);        
                        return vierr;
                    }    
                    
                } while (ready == 0);
                
                // Write to buffer B - Transfers ARB data from the host to the source.
                if (!alterSize){
                    // Write the entire second engine buffer.
                    DAQ_CHECK(hpe1432_writeSrcBufferData(_session, _chanList[chan], _buffer,
                        (engBuf2->ValidPoints/_nChannels), HPE1432_SRC_DATA_MODE_WAITAB));     
                }else{
                    // Write the second half of the first engine buffer.
                    long pad = ((engBuf->ValidPoints)/2)*4;
                    DAQ_CHECK(hpe1432_writeSrcBufferData(_session, _chanList[chan], _buffer+pad,
                        (engBuf->ValidPoints)/(2*_nChannels), HPE1432_SRC_DATA_MODE_WAITAB));      
                }
            }
            
            if (!alterSize){									
                // Update the SamplesOutput value based on the number of data points sent.
                _samplesOutput+=engBuf2->ValidPoints/_nChannels;
                
                // Send a buffer back to the engine after the data has been sent out.
                _engine->PutBuffer(engBuf2);
            }else{
                
                // Update the SamplesOutput value based on the number of data points sent.
                _samplesOutput+=engBuf->ValidPoints/_nChannels;
                
                // Send buffer back to the engine after the data has been sent out.
                _engine->PutBuffer(engBuf);
            }
        }     
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
         
         // Install the callback if it is not already installed - there can only be one callback per device.
         if (!globalCallbackInstalled ) {
             ViStatus callbackStatus = hpe1432_callbackInstall(_session, _gid, globalCallback, 0);
             if (callbackStatus != 0){
                 return E_CANNOT_INSTALL_CALLBACK;
             }
             globalCallbackInstalled=true;
         }

	// An interrupt will occur if there is an overflow or a source channel interrupt.
	DAQ_CHECK(hpe1432_setInterrupt(_session,_gid, 7,
            HPE1432_IRQ_MEAS_ERROR | HPE1432_IRQ_SRC_STATUS ));     

	// Set up the trigger and clock lines.
	DAQ_CHECK(hpe1432_setTtltrgSatrg(_session, _gid, HPE1432_TTLTRG_0));
	DAQ_CHECK(hpe1432_setTtltrgClock(_session, _gid, HPE1432_TTLTRG_1));
    
	// clock frequency may be updated depending on the number of channels active.
	bool updateSpan = false;
	if ((_nChannels > 1) && (_clockFreq > 51200)){
		_clockFreq = 51200;
		updateSpan = true;
	}

        DAQ_CHECK(hpe1432_setClockFreq(_session, _gid, _clockFreq ));  
        DAQ_CHECK(hpe1432_setSourceSpan(_session, _gid, _span));
        
        // The Span and SampleRate values may need to be updated if Clock Frequency was updated due
        // to the number of channels.
        if (updateSpan){
            // Initialize variables.
            CComPtr<IProp> ISpan, ISampleRate;
            
            // Get the new span value and update the span and samplerate local variables.
            DAQ_CHECK(hpe1432_getSourceSpan(_session, _gid, &(double)_span));
            _sampleRate=_span*2.56;
            
            // Get the IProp interface to the Span and SampleRate properties.
           GetProperty(L"Span", &ISpan);
           GetProperty(L"SampleRate", &ISampleRate);
            
            // Update the Span and SampleRate values.
            ISpan->put_Value(CComVariant(_span));
            ISampleRate->put_Value(CComVariant(_sampleRate));
            
            _engine->WarningMessage(L"The SampleRate and Span properties have been updated due to the number of channels.");
        }
        
        // Start source output on source channels. 
        DAQ_CHECK(hpe1432_initMeasure(_session,_gid));
        
        if (alterSize == true){
            // Stopping.
            Stop();
            _engine->DaqEvent(EVENT_STOP, 0, _samplesOutput, CComBSTR(L"STOP"));
        }else{
            _running=true;
            // Need to reenable the interrupt so that the next interrupt can be processed.
            DAQ_CHECK(hpe1432_reenableInterrupt(_session, _gid));
        }
        
        if (globalGidAI != NULL){
            hpe1432_reenableInterrupt(_session, globalGidAI);
        }
        
        return S_OK;
}

// Called by start.
int hpvxiDA::ChannelSetup()
{
    
    if (globalGidAI != NULL){
        hpe1432_reenableInterrupt(_session, globalGidAI);
    }
    
    for (int i=0;i<_nChannels; i++) {	
        
        // The channel id is the index+1+4096 (since in MATLAB hp channels are 1 based
        // and since hp source channels begine at 4097.
        
        // Set the RampRate of the channels.  (RampRate Channel Property).
        DAQ_CHECK(hpe1432_setRampRate(_session, _chanList[i], _rampRate[i]));
        
        // Set the Source mode. (OutputMode Channel property).
        DAQ_CHECK(hpe1432_setSourceMode(_session, _chanList[i],_sourceMode[i]));  
        
        // Set the OutputRange of the channels.  (OutputRange Channel property).
        DAQ_CHECK(hpe1432_setRange(_session, _chanList[i], _chanRange[1][i]));
        
        // Set the COLA of the channels.  (COLA Channel property).
        DAQ_CHECK(hpe1432_setSourceCola(_session,  _chanList[i], _cola[i]));
        
        // Set the Sum of the channels.  (Sum Channel property).
        DAQ_CHECK(hpe1432_setSourceSum(_session, _chanList[i], _sum[i]));
        
        // Set the SourceOutput of the channels.  (SourceOutput Channel Property).
        DAQ_CHECK(hpe1432_setSourceOutput(_session, _chanList[i], _sourceOutput[i]));  //i+1+SRC_CHAN_OFFSET
        
    }
    
    if (globalGidAI != NULL){
        hpe1432_reenableInterrupt(_session, globalGidAI);
    }
    
    return S_OK;
}

STDMETHODIMP hpvxiDA::Start ()
{
    AUTO_LOCK;
    return S_OK;
}



// utility function for the engine.to determine the status of an ongoing process.
STDMETHODIMP hpvxiDA::GetStatus(hyper * samplesProcessed, BOOL * running)
{
    AUTO_LOCK; 
	*running = _running;
    *samplesProcessed = _samplesOutput;
    return S_OK;
}

void hpvxiDA::addDev(int id){

	AUTO_LOCK;

	if (_numIdSpecified != 1){
		// Need to install the callback on the board that the first channel is contained by.
		 NESTABLEPROP *firstChan;
		 _EngineChannelList->GetChannelStructLocal(0, &firstChan);
		 long idToFind = _validChanList[firstChan->HwChan-1];
		 long foundIds = 0;	
		 for (int i = 0; i<numFound; i++){
			foundIds += globalIdList[i*4+1];
			if (foundIds > idToFind){
				id = globalIdList[i*4];
				break;
			}
		 }
	}

	if (id >= static_cast<int>(_installedCallbackIDs.size())) {
		_installedCallbackIDs.resize(id+1);
	}

	_installedCallbackIDs[id] = 1;
}


bool hpvxiDA::installCallback(int id){
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

