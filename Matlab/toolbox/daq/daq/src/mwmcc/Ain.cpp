// Copyright 1998-2004 The MathWorks, Inc. 
// $Revision: 1.1.6.7 $  $Date: 2004/04/08 20:49:39 $


// Ain.cpp : Implementation of CAin

#include "stdafx.h"
#include <string>
#include <sstream>
#include "Mwmcc.h"
#include "Ain.h"
#include "sarrayaccess.h"
#include "DaqmexStructs.h"
#include "cbutil.h"
#include "math.h"
#define AUTO_LOCK TAtlLock<CAin> _lock(*this)


enum InputTypes {
    DIFFERENTIAL=MAKE_ENUM_VALUE(INPUT_TYPE_DIFFERENTIAL,0),
    SINGLE_ENDED=MAKE_ENUM_VALUE(INPUT_TYPE_SINGLEENDED,0)
};
//enum TriggerTypes {
//    HW_DIGITAL_TRIG=ADAPTOR_ENUM_MIN,
//        HW_ANALOG_TRIG
//};

#define  HW_DIGITAL_TRIG MAKE_USER_TRIGGER(TRIG_PRETRIGGER_DISABLED | TRIG_TRIGGER_IS_HARDWARE,1L)
#define  HW_ANALOG_TRIG MAKE_USER_TRIGGER(TRIG_PRETRIGGER_DISABLED | TRIG_TRIGGER_IS_HARDWARE,2L)
#ifdef _DEBUG
#undef THIS_FILE
#undef DEBUG_NEW
static char THIS_FILE[]=__FILE__;
#define DEBUG_NEW new(_NORMAL_BLOCK, THIS_FILE, __LINE__)
#define new DEBUG_NEW
#endif

CAin::CAin():
TimerObj(this),
_differential(true),         // inputs are differentail
_selectableInputType(false),  // board can be changed from singleendied to di
_convertData(false),
_Options(0),
pChannelSkewMode(BURSTMODE)
{
}

CAin::~CAin()
{
    if (_BoardNum>=0)
    {
        cbStopBackground(_BoardNum, AIFUNCTION);
    }

}

STDMETHODIMP CAin::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IAin
	};
	for (int i=0; i < sizeof(arr) / sizeof(arr[0]); i++)
	{
		if (InlineIsEqualGUID(*arr[i],riid))
			return S_OK;
	}
	return S_FALSE;
}

/////////////////////////////////////////////////////////////////////////////
// CAin

//
// Open
//
// Description:
//  Called when MatLab creates in analoginput, analogoutput,
//  or digitalio. Performs some preliminary setup and system
//  configuration. 
//
// UL Routines:
//
enum CHANUSER {INPUTRANGE=1,HWCHANNEL}; // do not use user of 0



HRESULT CAin::Open(IUnknown *Interface,long ID)
{
    CComPtr<IProp> prop;
    CRemoteProp rp;
    CComVariant var;
    RETURN_HRESULT(CbDevice::Open(Interface));
    // Get the board number and verify.
    _BoardNum=ID;
    
    if (_BoardNum < 0 || _BoardNum > GINUMBOARDS)
        return ERR_XLATE(ERR_INVALID_ID);
    int chans=0;
    CBI_CHECK(cbGetConfig (BOARDINFO, _BoardNum, 0, BINUMADCHANS, &chans));
    if (chans==0)
        return ERR_XLATE(ERR_INVALID_ID);
    
    RETURN_HRESULT(SetDaqHwInfo());

    ATTACH_PROP(SampleRate);
    if (_maxSampleRate<pSampleRate.Value)
    {
        pSampleRate.SetDefaultValue(_maxSampleRate);
        pSampleRate=_maxSampleRate;
    }
    if (_minSampleRate>pSampleRate.Value)
    {
        pSampleRate.SetDefaultValue(_minSampleRate);
        pSampleRate=_minSampleRate;
    }

    _RequestedRate=pSampleRate;
    pSampleRate.SetRange(_minSampleRate,_maxSampleRate);
    prop=CREATE_PROP(TransferMode);
    pTransferMode->AddMappedEnumValue(DEFAULTIO, L"Default");
    prop->AddMappedEnumValue(SINGLEIO , L"InterruptPerPoint");

    ATTACH_PROP(ChannelSkew);
    ATTACH_PROP(ChannelSkewMode);
    pChannelSkewMode->ClearEnumValues();
    double skewval=0;
    if (_scanning)
    {
        pChannelSkewMode->AddMappedEnumValue(0, L"Equisample");
        if (_SupportsBurst)
        {
			pChannelSkewMode->AddMappedEnumValue(BURSTMODE, L"Minimum");       
			pChannelSkewMode=BURSTMODE;
			pChannelSkewMode->put_DefaultValue(CComVariant(BURSTMODE));
        }
        skewval=_settleTime*1e-6;
    }
    else
    {
		// SSH cards have no skew, so pChannelSkewMode should be 0.
		// Instacal versions before 5.44 did not care if this was not
		// set correctly.  Geck 202173.
        pChannelSkewMode->AddMappedEnumValue(BURSTMODE, L"None");    
        pChannelSkewMode->put_DefaultValue(CComVariant(0));  
        pChannelSkewMode=0;
    }
    pChannelSkew=skewval;
    var=skewval;
    pChannelSkew->put_DefaultValue(var);
    pChannelSkew->SetRange(&var,&var);
    // clockSource: this exists, but we need to modify the enum list
    prop=ATTACH_PROP(ClockSource);
    pClockSource->AddMappedEnumValue(CLOCKSOURCE_SOFTWARE, L"Software");
    if (_UseSoftwareClock)
    {
		pClockSource->RemoveEnumValue(CComVariant(L"internal"));
		pClockSource.SetDefaultValue(CLOCKSOURCE_SOFTWARE);
		pClockSource=CLOCKSOURCE_SOFTWARE;
    }
    else
    {
        pClockSource->AddMappedEnumValue(MAKE_ENUM_VALUE(0,EXTCLOCK), L"External");
        pTransferMode->AddMappedEnumValue(DMAIO   , L"DMA");
        pTransferMode->AddMappedEnumValue(BLOCKIO , L"InterruptPerBlock");
		pTransferMode->AddMappedEnumValue(BURSTIO , L"InterruptPerScan");
    }

    // inputType (channel type)
    prop=ATTACH_PROP(InputType);
    
    if (_selectableInputType)
    {
        prop->AddMappedEnumValue(DIFFERENTIAL, L"Differential");
        prop->AddMappedEnumValue(SINGLE_ENDED, L"SingleEnded");
    }
    else if (_differential)  
    {
        prop->AddMappedEnumValue(DIFFERENTIAL, L"Differential");
    }
    else
        prop->AddMappedEnumValue(SINGLE_ENDED, L"SingleEnded");

    var=_differential?  DIFFERENTIAL : SINGLE_ENDED;

    prop->put_DefaultValue(var);
    prop->put_Value(var);

    ATTACH_PROP(SamplesPerTrigger);

   // trigger condition
//    ATTACH_PROP(TriggerCondition);
//    ATTACH_PROP(TriggerDelay);
    ATTACH_PROP(TriggerDelayPoints);
    ATTACH_PROP(TotalPointsToAcquire);
    ATTACH_PROP(TriggerRepeat);

    // trigger type
    prop=ATTACH_PROP(TriggerType);
    prop->AddMappedEnumValue(HW_DIGITAL_TRIG,  L"HwDigital");

    if (_analogTrig)
    {
        prop->AddMappedEnumValue(HW_ANALOG_TRIG, L"HwAnalog");        
    }
    prop.Release();

    ATTACH_PROP(TriggerCondition);
    ATTACH_PROP(TriggerConditionValue);

    _EnginePropRoot->put_MemberValue(L"UseDeadReckoning",CComVariant(true));

    // channel props    
    rp.Attach(_EngineChannelList,L"HwChannel",HWCHANNEL);
    rp.SetRange(0L,_MaxChannels-1);
    rp.Release();

    double InputRange[2];
    RANGE_INFO *rInfo=*_validRanges.begin();

    InputRange[0]=rInfo->minVal;
    InputRange[1]=rInfo->maxVal;
    CreateSafeVector(InputRange,2,&var);
    
    rp.Attach(_EngineChannelList,L"inputrange",INPUTRANGE);
    rp->put_DefaultValue(var);
    rp.SetRange(InputRange[0],InputRange[1]);
    rp.Release();

    rp.Attach(_EngineChannelList,L"unitsrange");
    rp->put_DefaultValue(var);
  

    rp.Attach(_EngineChannelList,L"sensorrange");
    rp->put_DefaultValue(var);

    rp.Attach(_EngineChannelList,L"conversionoffset");
    rp->put_DefaultValue(CComVariant(1<<(_Resolution-1)));
    rp.Release();

    return S_OK;
    
}

int CAin::LoadDeviceInfo()
{  
    RETURN_HRESULT(CbDevice::LoadDeviceInfo(_T("AI")));

    _maxSampleRate = GetFromIni("AIMaxSR", 100000.0);
    if (_maxSampleRate==0)
    {
        _maxSampleRate=MAX_SW_SAMPLERATE;
        _SampleRate=100;
        _UseSoftwareClock=true;
        _minSampleRate=MIN_SW_SAMPLERATE;
    }
    else
    {
        _minSampleRate = GetFromIni("AIMinSR", 1.0);
        _SupportsBurst = GetFromIni("AIBurstMode",false);
                
        _scanning = GetFromIni("Scanning", true);
    }

	_maxContinuousSampleRate = GetFromIni("AIMaxContSR", 0 );

    _settleTime= GetFromIni("SettleTime",10);
    _Resolution = GetFromIni("AIResolution", 12);

    // This needs to be implemented in the cbGetConfig function. Placed in .ini
    // file for the time being.

//    _swRangeConfig = GetFromIni("swRangeConfig", false);

    _chanGainQueue = GetFromIni("ChanGainQueue", false);
    _digitalTrig=GetFromIni("DigitalTrig", false);
    _analogTrig=GetFromIni("AnalogTrig", false);
    _ClockingType=GetFromIni("AIClockingType", NORMAL);

    // now try to determine convertdata
    if (_Resolution==12 && wcsncmp(_boardName,L"CIO",3)==0)
    {
        _convertData=true;
    }
    _convertData=GetFromIni("ConvertAIData",_convertData);
        
    // now fix up max sample rate must do near end because of need for most settings
    FixupSampleRates();    
    return S_OK;
}

//
// SetDaqHwInfo
//
// Description:
//  Set the fields needed for DaqHwInfo
//
HRESULT CAin::SetDaqHwInfo()
{
    
    CComPtr<IProp> prop;       
    int len,temp;
    CHECK_HRESULT(SetBaseHwInfo());
    LoadDeviceInfo();
       
    CComVariant var,vids;
    
    // Get number of channels from driver 
    CBI_CHECK(cbGetConfig(BOARDINFO, _BoardNum, 0, BINUMADCHANS, &_MaxChannels));
    long hRes = _DaqHwInfo->put_MemberValue(L"totalchannels",CComVariant(_MaxChannels));
    if (!(SUCCEEDED(hRes))) return hRes;

    // Get Input type from driver (single-ended or differential)
    CBI_CHECK(cbGetConfig(BOARDINFO, _BoardNum, 0, BIADCFG, &temp));
	// Fix to Geck 210467: MCC PCI-DAS6052 and 6000 series support additional
	// codes to represent single ended ground referenced, single-ended nonreferenced,
	// and differential input types.  Other cards still use the traditional differential
	// equals 0, singleended equals 1.  Also, the MCC DEMO card returns -1, and is mapped
	// to differential (old behavior)
	if(temp == 0x0001 || temp == RSE || temp == NRSE)
	{
		_differential = 0;
	}
	else if(temp == 0x0000 || temp == DIFF || temp == -1)
	{
		_differential = 1;
	}
	else
	{
		// If it isn't a known value, throw a warning, and assume differential (old behavior).
		_engine->WarningMessage(CComBSTR("Measurement Computing board reported unknown input type.  Defaulting to differential."));
		_differential = 1;
	}

    // Load input ranges from INI file 
    // This populates the _validRanges vector and the _rangemap map.
    LoadRangeInfo("InputRanges",(_differential?  DIFFERENTIAL : SINGLE_ENDED));

    // device Id
    wchar_t idStr[8];
    swprintf(idStr, L"%d", _BoardNum);
    hRes = _DaqHwInfo->put_MemberValue(L"id", CComVariant(idStr));		
    if (!(SUCCEEDED(hRes))) return hRes;   

    // single ended channels
    CreateSafeVector((short*)NULL,_MaxChannels,&vids);
    TSafeArrayAccess<short> ids(&vids);
    for (int i=0;i<_MaxChannels;i++)
    {
        ids[i]=i;
    }

    hRes = _DaqHwInfo->put_MemberValue(L"singleendedids", vids);
    if (!(SUCCEEDED(hRes))) return hRes;

    // differential channels
    hRes = _DaqHwInfo->put_MemberValue(L"differentialids",vids);
    if (!(SUCCEEDED(hRes))) return hRes;

    // subsystem type
    hRes = _DaqHwInfo->put_MemberValue(L"subsystemtype",CComVariant(L"AnalogInput"));
    if (!(SUCCEEDED(hRes))) return hRes;
    
    hRes = _DaqHwInfo->put_MemberValue(L"sampletype",CComVariant(_scanning ? SAMPLE_TYPE_SCANNING : SAMPLE_TYPE_SIMULTANEOUS_SAMPLE));
    if (!(SUCCEEDED(hRes))) return hRes;

    // number of bits    
    DEBUG_HRESULT(_DaqHwInfo->put_MemberValue(L"bits",CComVariant(_Resolution)));
    
    hRes = _DaqHwInfo->put_MemberValue(L"adaptorname", CComVariant(L"mcc"));
    if (!(SUCCEEDED(hRes))) return hRes;

	hRes = _DaqHwInfo->put_MemberValue(L"polarity", CComVariant(L"Bipolar"));
    if (!(SUCCEEDED(hRes))) return hRes;

    hRes = _DaqHwInfo->put_MemberValue(L"coupling", CComVariant(L"DC Coupled"));
    if (!(SUCCEEDED(hRes))) return hRes;

    
    // device name  
    char BoardName[BOARDNAMELEN];

    cbGetBoardName(_BoardNum,BoardName);
    hRes = _DaqHwInfo->put_MemberValue(L"devicename",CComVariant(BoardName));
    if (!(SUCCEEDED(hRes))) return hRes;

    // native data type
//    var = support16bit ? VT_UI2 : VT_UI1;
    DEBUG_HRESULT(_DaqHwInfo->put_MemberValue(L"nativedatatype", CComVariant(VT_UI2)));	

    DEBUG_HRESULT(_DaqHwInfo->put_MemberValue(L"minsamplerate", CComVariant(_minSampleRate)));	


    hRes = _DaqHwInfo->put_MemberValue(CComBSTR(L"maxsamplerate"), CComVariant(_maxSampleRate));	
    if (!(SUCCEEDED(hRes))) return hRes;    

    // input ranges  
    // this is a 2-d array of range values
    // there are unipolar and bipolar ranges 
    // both are len x 2, where len is the 
    // number of gains supported
    //
    // we want something like this:
    //  Bipolar
    //  [-10.0  10.0]
    //  [-5.0   5.0 ]
    //  [-2.5   2.5 ]
    //  [-1.25  1.25]
    //   .
    //  Unipolar
    //  [0  10.0]
    //  [0  5.0 ]
    //  [0  2.5 ]
    //  [0  1.25]
    // need to fix up valid ranges
    int range;
        int status=cbGetConfig(BOARDINFO,_BoardNum,0,BIRANGE,&range);
        if (!status && range>0)
        {
            if (range==UNIPOLAR)  // 100's only
            {
                RangeList_t newlist;
                for(unsigned int i=0;i<_validRanges.size();i++)
                {
                    if (_validRanges[i]->rangeInt>=100)
                        newlist.push_back(_validRanges[i]);
                }
                _validRanges=newlist;

            }
            else if (range==BIPOLAR) // <100 only
            {
                RangeList_t newlist;
                for(unsigned int i=0;i<_validRanges.size();i++)
                {
                    if (_validRanges[i]->rangeInt<100)
                        newlist.push_back(_validRanges[i]);
                }
                _validRanges=newlist;
            }
            else
            {
                
            RangeMap_t::iterator i=_rangemap.find(range);
            _validRanges.resize(1);
            if (i!=_rangemap.end())
                _validRanges[0]=i->second;
            }
        }

    
    len = _validRanges.size();           

    SAFEARRAYBOUND rgsabound[2];  
    rgsabound[0].lLbound = 0;
    rgsabound[0].cElements = len; // bipolar and unipolar 
    rgsabound[1].lLbound = 0;
    rgsabound[1].cElements = 2;     // upper and lower range values
    
    SAFEARRAY *ps = SafeArrayCreate(VT_R8, 2, rgsabound);
    if (ps == NULL) return E_OUTOFMEMORY;       
    double *ranges,*pl,*ph;
   
    hRes = SafeArrayAccessData (ps, (void **) &ranges);
    if (FAILED (hRes)) 
    {
        SafeArrayDestroy (ps);
        return E_OUTOFMEMORY;
    }
   
    pl=ranges;
    ph=ranges+len;
    RangeList_t::reverse_iterator it;
    for (it=_validRanges.rbegin();it!=_validRanges.rend();it++)
    {
        *pl++=(*it)->minVal;
        *ph++=(*it)->maxVal;
    }

    var.Clear();
    V_VT(&var)=(VT_ARRAY | VT_R8);    
    V_ARRAY(&var)=ps;
    
    SafeArrayUnaccessData (ps);

    hRes = _DaqHwInfo->put_MemberValue(CComBSTR(L"inputranges"), var);
    if (!(SUCCEEDED(hRes))) return hRes;   
    var.Clear();    

    prop.Release();
    return S_OK;
}


//
// ChildChange
//
// Description:
//  Called any time there is a change to a channel or line 
//  configuration. The function will first be called with a
//  start message. Then for each channel being added, deleted,
//  or reconfigured, this function will be called. The point 
//  here is to prepair a channel list and check for any settings
//  that might conflict. i.e. on most CBI boards the channel 
//  list must be contiguous and one range must be applied to 
//  all channels. If a user attempts to mess this up then an
//  error should be returned.
//  
// UL Routines:
//
/*
HRESULT CAin::ChildChange(ULONG typeofchange, 
                          IPropContainer * Container, 
                          tagNESTABLEPROP * pChan)
{
    _chanDirty=true;
    return S_OK;
}
*/

//
// GetSingleValues
//
// Description:
//  Returns a single value for each configured channel.
//
// UL Routines:
//  cbAIn()
//
#if 0
HRESULT     CAin::GetSingleValue(int chan,unsigned short *loc)
{
    
    CBI_CHECK(cbAIn(_BoardNum,
        _chanList[chan],
        _chanRange[chan],
        loc));
    return S_OK;
}
#endif
HRESULT CAin::GetSingleValues(VARIANT * Values)
{
    UpdateChans(true);

    TSafeArrayVector <unsigned short > binarray;    
    binarray.Allocate(_nChannels);
    for (int i=0; i<_nChannels; i++) 
    {    

        CBI_CHECK(cbAIn(_BoardNum,
             _chanList[i],
             _chanRange[i],
             &binarray[i]));
//        if (_convertData)
//            binarray[i]>>=4;
    }
    return binarray.Detach(Values);
}

HRESULT CAin::UpdateRateAndSkew(long newskewmode,double newrate)
{
    double newskew;
    if (_UseSoftwareClock || _nChannels<=1 || newskewmode==BURSTMODE)
    {
          newskew=_settleTime*1e-6;
          newrate=RoundRate(newrate);
    }
    else
    {
          newrate=RoundRate(newrate*_nChannels); // find rate for scanning
          newskew=1.0/newrate;
          newrate/=_nChannels;  // actual rate
    }

	// To avoid divide by zero, make sure nChannel is at least 1
	long nChannels = max( _nChannels, 1 );

	// If not using a software clock, and a SampleType of scanning, 
	// verify that we have not exceeded the maximum aggregate sample rate.
    if ( !_UseSoftwareClock && _scanning )
	{
		// If we have exceeded the max aggregate sample rate, recalculate the new max and current sample rate
		if ( newrate*nChannels>_maxSampleRate )
		{
			// Calculate a new max based on the number of channels and
			// adjust the sample rate down to the new max.
			double maxSR = RoundRate(_maxSampleRate/nChannels);
			pSampleRate.SetRange(_minSampleRate, maxSR);
			if (newrate > maxSR)
			{	
				_engine->WarningMessage(CComBSTR("SampleRate reduced based on new limits."));
				newrate = maxSR;
			}
		}
	}

    pSampleRate=newrate;
    pChannelSkew=newskew;
    pChannelSkewMode=newskewmode;
    return S_OK;
}

STDMETHODIMP CAin::SetProperty(long User, VARIANT * NewValue)
{
    
    if (User) 
    
    {
        CLocalProp* pProp=PROP_FROMUSER(User);
        variant_t *val=(variant_t*)NewValue;
        // I would like to have used a case statement here but can not find a way to code it
        if (User==USER_VAL(pChannelSkew))
        {
            return(Error(_T("ChannelSkew may not be set with mcc devices.")));
        }
        else if (User==USER_VAL(pChannelSkewMode))
        {
            RETURN_HRESULT(UpdateRateAndSkew(*val,_RequestedRate));
        }
        else if (User==USER_VAL(pSampleRate))
        {
            RETURN_HRESULT(UpdateRateAndSkew(pChannelSkewMode,*val));
            _RequestedRate=*val;
            *val=pSampleRate;
        }
        else if (User==USER_VAL(pClockSource))
        {
            bool save=_UseSoftwareClock;
            _UseSoftwareClock=static_cast<long>(*val)==CLOCKSOURCE_SOFTWARE;
            HRESULT status=SetClockSource();
            if (status)
            {
                _UseSoftwareClock=save;
                return status;
            }
        }
        else if (User==USER_VAL(pTriggerType))
        {
            if (static_cast<long>(*val)==HW_DIGITAL_TRIG)
            {
                pTriggerCondition->ClearEnumValues();
                pTriggerCondition->AddMappedEnumValue(GATE_HIGH,L"GateHigh");
                pTriggerCondition->AddMappedEnumValue(GATE_LOW,L"GateLow");
                pTriggerCondition->AddMappedEnumValue(TRIG_HIGH,L"TrigHigh");
                pTriggerCondition->AddMappedEnumValue(TRIG_LOW,L"TrigLow");
                pTriggerCondition->AddMappedEnumValue(TRIG_POS_EDGE,L"TrigPosEdge");
                pTriggerCondition->AddMappedEnumValue(TRIG_NEG_EDGE,L"TrigNegEdge");
                pTriggerCondition=TRIG_NEG_EDGE;
                pTriggerCondition.SetDefaultValue(TRIG_NEG_EDGE);
            }
            else if (static_cast<long>(*val)==HW_ANALOG_TRIG)
            {
                pTriggerCondition->ClearEnumValues();
                pTriggerCondition->AddMappedEnumValue(GATE_NEG_HYS,L"GateNegHys");
                pTriggerCondition->AddMappedEnumValue(GATE_POS_HYS,L"GatePosHys");
                pTriggerCondition->AddMappedEnumValue(GATE_ABOVE,L"GateAbove");
                pTriggerCondition->AddMappedEnumValue(GATE_BELOW,L"GateBelow");
                pTriggerCondition->AddMappedEnumValue(TRIGABOVE,L"TrigAbove");
                pTriggerCondition->AddMappedEnumValue(TRIGBELOW,L"TrigBelow");
                pTriggerCondition->AddMappedEnumValue(GATE_IN_WINDOW,L"GateInWindow");
                pTriggerCondition->AddMappedEnumValue(GATE_OUT_WINDOW,L"GateOutWindow");
                pTriggerCondition=TRIGABOVE;
                pTriggerCondition.SetDefaultValue(TRIGABOVE);
                RANGE_INFO *rInfo=*_validRanges.begin();
                pTriggerConditionValue.SetRange(rInfo->minVal,rInfo->maxVal);
            }
        }
        
        // Now set the actual value
        pProp->SetLocal(*val);

        _updateProps=true;
    }
    return S_OK;
}

HRESULT CAin::SetAllInputRanges(RANGE_INFO *NewInfo)
{
    double VoltRange[2];
    CComVariant val;
    VoltRange[0]=NewInfo->minVal;
    VoltRange[1]=NewInfo->maxVal;
    CreateSafeVector(VoltRange,2,&val);
    CComPtr<IPropRoot> prop;
    CComPtr<IChannel> pcont;

    // Input range
    RETURN_HRESULT(GetChannelProperty(L"InputRange", &prop));

    for (int i=0; i<_nChannels; i++) 
    {	    
	RETURN_HRESULT(GetChannelContainer(i, &pcont));
        RETURN_HRESULT(pcont->put_PropValue(__uuidof(prop),prop,val));
        _chanRange[i]=NewInfo->rangeInt;
        pcont=NULL;
    }       

#if 0
    if (polarity==UNIPOLAR)
    {
            // native data type    
        _DaqHwInfo->put_MemberValue(CComBSTR(L"nativedatatype"), CComVariant(VT_UI2));	

    }
    else
        _DaqHwInfo->put_MemberValue(CComBSTR(L"nativedatatype"), CComVariant(VT_I2));
#endif
    return prop->put_DefaultValue(val);
}

STDMETHODIMP CAin::SetChannelProperty(long UserVal, tagNESTABLEPROP * pChan, VARIANT * NewValue)
{
    int Index=pChan->Index-1;  // we use 0 based index 
    _ASSERTE(Index<_nChannels);
    variant_t& vtNewValue=reinterpret_cast<variant_t&>(*NewValue);
    switch (UserVal)
    {
    case INPUTRANGE:
        {
        TSafeArrayAccess<double> NewRange(NewValue);
        RANGE_INFO *NewInfo;
        RETURN_HRESULT(FindRange(static_cast<float>(NewRange[0]),
			                     static_cast<float>(NewRange[1]),NewInfo));
        if (_chanRange[Index]!=NewInfo->rangeInt)
        {
            if (_validRanges.size()<=1)
            {
                return(Error(_T("Device is not software range configurable.  Please set your range with Instacal.")));
            }
            _chanRange[Index]=NewInfo->rangeInt;
        }
        NewRange[0]=NewInfo->minVal;
        NewRange[1]=NewInfo->maxVal;
        }
        break;
    case HWCHANNEL:
        {
            _chanList[Index]=vtNewValue;
            break;
        }
    default:
        _updateChildren=true;
    }
    return S_OK;
}

template <class T> T MakeNative(double value,T& output,int bits,int offset,double range)
{
    output=static_cast<T>((value+offset)*(1<<bits)/range);
    return output;
}
// 
// Start
//
HRESULT CAin::Start()
{
    if (_updateChildren) 
    {
        // need error check
        RETURN_HRESULT(UpdateChans(true));
    }
    if (_UseSoftwareClock)
        return InputType::Start();

    RETURN_HRESULT(CheckChansForBackround());

    TriggerPosted=false;
    _pointsThisRun=0;
    _Options = BACKGROUND | pTransferMode | pChannelSkewMode | GET_ADAPTOR_ENUM_VALUE(pClockSource);
 
    if (pTriggerType &  TRIG_TRIGGER_IS_HARDWARE)
    {
        TriggersToGo=static_cast<long>(pTriggerRepeat);
        PointsLeftInTrigger=static_cast<long>(pSamplesPerTrigger*_nChannels);
        _Options |= EXTTRIGGER;
        unsigned short lowt=0,hit=0;
        RANGE_INFO *rInfo=*_validRanges.begin();

        double offset=rInfo->minVal;
        double range=rInfo->maxVal-offset;

        if (pTriggerConditionValue.ArrayLen()>=1)
            MakeNative(pTriggerConditionValue[0],lowt,_Resolution,static_cast<int>(offset),range); 
        if (pTriggerConditionValue.ArrayLen()>=2)
            MakeNative(pTriggerConditionValue[1],hit,_Resolution,static_cast<int>(offset),range); 
        else
            hit=lowt; // when one value is used it may be the high one
        int status=cbSetTrigger(_BoardNum,pTriggerCondition,lowt,hit);
        if (status==BADBOARDTYPE)  // if a bad board type just ignore
        {
            if (pTriggerType==HW_ANALOG_TRIG)
                return Error(L"Analog triggering is not supported by your hardware.");
            else if (pTriggerCondition!=TRIG_NEG_EDGE)
                _engine->WarningMessage(CComBSTR("The hardware in use does not appear to support setable trigger conditions."));
        }
        else
            CBI_CHECK(status);
    }
    else
    {
        TriggersToGo=0;
        PointsLeftInTrigger=MAXLONG;
    }

    // Initialize the block size of the engine, in points (used in GetScanData()).
    _engine->GetBufferingConfig(&_EngBuffSizePoints,NULL);
	_EngBuffSizePoints*=_nChannels; 
    
	// Determine the circular buffer size (and the number of points to request per scan)
	// 16 buffer's worth. I don't know where this came from except that in the default
	// setup, it gets the buffer size back to about one second's worth of data.
    long BufferSize = _EngBuffSizePoints*16;  
    long TotalPoints = (PointsLeftInTrigger==MAXLONG) ? pTotalPointsToAcquire : PointsLeftInTrigger;

	// If we know how many points we are acquiring and 
	// all of them can fit in the circular buffer or the FIFO
    if (TotalPoints>0 && (TotalPoints<=BufferSize || TotalPoints <= _FifoSize) )
    {
		_Bursting=true;
		// _Options |= BURSTIO; // will default to this anyways if available
        BufferSize=TotalPoints; // Make circular buffer the same size as points being acquired
        PointsLeftInTrigger=TotalPoints;
    }
    else
    {
		_Bursting=false;
        _Options |= CONTINUOUS;
        if (BufferSize<8*1024)
        {
            BufferSize*=8*1024/BufferSize;
        }
    }

	// If there is a CONTINUOUS max sample rate, and we have exceeded it, 
	// check the number of points being acquired.
	if ( _maxContinuousSampleRate > 0 && (pSampleRate*_nChannels>_maxContinuousSampleRate) )
	{
		// If the total points exceed the fifo size
		if ( TotalPoints > _FifoSize )
		{
			// Give a more descriptive error since the Universal Library error is "Invalid Sample Rate".
			return ERR_XLATE(ERR_INVALID_NUMBER_OF_POINTS_FOR_BURSTIO);
		}
	}

	// Time period is 2x faster than the time it should take to acquire one engine buffer worth of data.
	_timerPeriod=(double)min(BufferSize,_EngBuffSizePoints)/_nChannels/pSampleRate/2;

    RETURN_HRESULT(_CircBuff.Initialize(BufferSize));
    if (_chanGainQueue)
        CBI_CHECK(cbALoadQueue(_BoardNum,&_chanList[0],&_chanRange[0],_nChannels));
    return S_OK;
}
// Description:
//  Start the analog input scan. Requires beginning and ending 
//  channel numbers, range, rate, and scanning options. 
//  Channel info will come from information built up via 
//  ChildChange calls. 
//
// UL Routines:
//  cbAInScan()
//
// Notes:
//  Initialize the _PreIndex to 0 before starting the scan. 
//
HRESULT CAin::Trigger()
{
    AUTO_LOCK;
    HRESULT RetStatus;
    if (_UseSoftwareClock)
        return InputType::Trigger();

    // Allocate buffer for the scan.(in Samples NOT bytes)
    // Get configuration options.
    long sr1 =_SampleRate = static_cast<long>(floor(pSampleRate));

    // Start scan
    RetStatus = (HRESULT) cbAInScan(_BoardNum,_chanList[0],_chanList[_nChannels-1],  _CircBuff.GetBufferSize() ,&_SampleRate,
                                    _chanRange[0], _CircBuff.GetPtr(), _Options);
    _running=true;  // so that stop will stop...
    if (RetStatus)
    {
        Stop();
        return CBI_XLATE(RetStatus);
    }
    if ( !(_SampleRate==sr1 || _SampleRate== floor(pSampleRate+0.5)))
    {
        _engine->WarningMessage(CComBSTR("SampleRate changed at start."));
        _RPT3(_CRT_WARN,"SampleRate changed at start NewRate=%d TestRate=%f chans=%d\n",_SampleRate,(DOUBLE)pSampleRate,_nChannels);
        pSampleRate=_SampleRate;
    }
    TimerObj.CallPeriod(_timerPeriod);
#ifdef _DEBUG
    short Status;
    long CurCount,CurIndex;
    cbGetStatus(_BoardNum, &Status, &CurCount, &CurIndex, AIFUNCTION);
#endif
    return S_OK;
}

//
// BufferReadyForDevice
//
// Description:
//  For now this routine is being used to check if data from cbAinScan
//  can be returned to MatLab. May not be needed for final implementation.
//
// UL Routines:
//

//
// GetStatus
//  
// Description:
//
// UL Routines:
//  cbGetStatus()
//
HRESULT CAin::GetStatus(__int64 * samplesProcessed, int * running)
{
    return S_OK;
}

//
// PeekData
//
// Description:
//
// UL Routines:
//
// Notes:
//  For testing call GetScanData to see if we can get some data back.
//  The initial check for NULL is required since this routine will 
//  be called once during analoginput to determine if the interface
//  supports this function.

HRESULT CAin::PeekData(BUFFER_ST * pBuffer)
{
    //if (pBuffer==NULL)  // this is a test to see if the funcion is implemented
     //   return S_OK;  
    
    
    //GetScanData (pBuffer);
    
    return E_NOTIMPL;
}

//
// Stop
//
// Description:
//  Stop the analog input scan. At least we should clean up the
//  buffer that was allocated in Start.
//
// UL Routines:
//  cbStopBackground()
//  cbWinBufFree()
//
HRESULT CAin::Stop()
{
    if (_UseSoftwareClock)
        return InputType::Stop();
    if (_running)
    {
		TimerObj.Stop(); // protects it's self
		AUTO_LOCK;
		// Stop any background tasks that are running.
		CBI_CHECK(cbStopBackground(_BoardNum, AIFUNCTION));
		GetScanData();
		// Free the HW data acquisition buffer 
		//cbWinBufFree(_HWMemHandle);
		_running=false;
    }
    return S_OK;
}



//
// GetScanData
//
// Description:
//  Routine to check the status of a background scan. If 
//  the acquired data meets the update quantity then 
//  GetBuffer and PutBuffer. _BoardNum is a member 
//  variable assigned in Open.
//
// UL Routines:
//  cbGetStatus()
//
// Notes:
//  The bahavior of cbGetStatus varies from board to board. 
//  On some hardware the CurCount will increment until the 
//  requested data is reached or the scan is stopped. On 
//  others the CurCount will loop based on the buffer size
//  passed to cbAInScan. For this reason the interface will 
//  only track CurIndex. _PreIndex initialized in Start() to 0.
//  _HWBuffSize assigned in Start() as well. 
//  
HRESULT CAin::GetScanData()
{
    short Status;         // IDLE, or RUNNING
    long  CurCount=0;     // Not used here
    AUTO_LOCK;
    if (!_running)
        return E_FAIL;
    BUFFER_ST  *BuffPtr;  // Storage for GetBuffer and PutBuffer
     _CurIndex=0;   

    // Call cbGetStatus to check where current scan is at.
    short result=cbGetStatus(_BoardNum, &Status, &CurCount, &_CurIndex, AIFUNCTION);
//ATLTRACE("cbGetStatus Status=%d CurCount=%d CurIndex=%d\n",Status, CurCount, _CurIndex );

    if (_CurIndex<0)
    {
        return S_OK;
    }

    if ( result )
    {
        ATLTRACE("cbGetStatus FAILED ");
        return E_FAIL;
    }

    // post a trigger if needed
    bool ForceCopy=false;

	// If the entire buffer has been acquired in one transfer...
	// This was added for devices like the PMD-1208 that acquire data and transfer it
	// to the PC in one block. This happens for small amounts of samples (e.g. 10) 
	// or a high sample rate with an amount of samples that fits in the FIFO 
	// (e.g. 8000Hz and < 4K samples). The device automatically uses BURSTIO mode 
	// and keeps the CurCount and _CurIndex at 0 until the entire scan finishes. 
	// When the scan is complete, CurCount will be updated to the buffer size,
	// _CurIndex will be set to 0, and Status will be IDLE.
	if ( _Bursting && Status == IDLE && CurCount == _CircBuff.GetBufferSize() && _CurIndex == 0 )
	{
		//_CurIndex = 0; // it already is
		// the buffer is full, force a copy 
        ForceCopy = true;
	}
	// Leave the original code untouched
	else
	{
	    _CurIndex+=_nChannels;

	    if (_CurIndex>=_CircBuff.GetBufferSize())
		{
			// the buffer is full, force a copy 
			_CurIndex-=_CircBuff.GetBufferSize();
			ForceCopy=(_CurIndex==0) && _Bursting;
		}
	}

    if (pTriggerType & TRIG_TRIGGER_IS_HARDWARE && !TriggerPosted)
    {
        TriggerPosted=true;
        double time;             
        _engine->GetTime(&time);
        // is sampleRate the correct value here when multiple chans are sampled?
        double triggerTime = time - _CurIndex/_nChannels/pSampleRate;
        _engine->DaqEvent(EVENT_TRIGGER, triggerTime, _pointsThisRun/_nChannels, NULL);
    }
    // check for data missed
    if (!_Bursting && _CircBuff.IsWriteOverrun(_CurIndex)) // this considres a force copy to be buffer empty if not an overrun
    {
        _engine->DaqEvent(EVENT_DATAMISSED, 0, _pointsThisRun/_nChannels,NULL);
        return E_FAIL;
    }

    _CircBuff.SetWriteLocation(_CurIndex);
    // Check to see if enough data has been collected to fill a buffer.

    // If we have enough data then get a buffer to return.
    // If there is more than one buffers worth of data then
    // send multiple buffes back.
    long flags=0;
	while ( _CircBuff.ValidData() >= min(_EngBuffSizePoints,PointsLeftInTrigger) || ForceCopy )// deal with less data needed (from buffer?)
    {
        // Get buffer from engine
        long bufferstatus=_engine->GetBuffer(0, &BuffPtr);
        if (bufferstatus==S_OK)
        {
			long pointstocopy=min(BuffPtr->ValidPoints,PointsLeftInTrigger);
            flags=BuffPtr->Flags;
            if (_convertData)
                _CircBuff.ShiftCopyOut((CIRCBUFFER::CBT*)BuffPtr->ptr,pointstocopy);
            else    
                _CircBuff.CopyOut((CIRCBUFFER::CBT*)BuffPtr->ptr,pointstocopy);
            BuffPtr->ValidPoints = pointstocopy;
            BuffPtr->StartPoint=_pointsThisRun;
            _pointsThisRun+=pointstocopy;
            if (PointsLeftInTrigger!=MAXLONG) 
                PointsLeftInTrigger-=pointstocopy;
            // Put the buffer back to the engine
            _engine->PutBuffer(BuffPtr);
        }
        if ((flags & BUFFER_IS_LAST ) || PointsLeftInTrigger==0 || bufferstatus==DE_NOT_RUNNING)
        {
            cbStopBackground(_BoardNum, AIFUNCTION);
            Status=IDLE;
            if (!TriggersToGo) 
				_engine->DaqEvent(EVENT_STOP, -1, _pointsThisRun/_nChannels, NULL);

            break;
        }
        if (bufferstatus) 
			break;
        ForceCopy=false;
    }

    if (Status==IDLE && TriggersToGo)
    {
        --TriggersToGo;
        _CircBuff.Reset();
        PointsLeftInTrigger = static_cast<long>(pSamplesPerTrigger*_nChannels);
        
        cbAInScan(_BoardNum,_chanList[0],_chanList[_nChannels-1],  _CircBuff.GetBufferSize() ,&_SampleRate,
            _chanRange[0], _CircBuff.GetPtr(), _Options);
        Status=RUNNING; //1
        TriggerPosted=false;
    }
    
    return (Status==IDLE ? 1 : S_OK);
}

STDMETHODIMP CAin::SetConfig(long InfoType, long DevNum, long ConfigItem, long ConfigVal)
{
	// TODO: Add your implementation code here
        CBI_CHECK(cbSetConfig(InfoType,_BoardNum,DevNum,ConfigItem,ConfigVal));
	return S_OK;
}

STDMETHODIMP CAin::GetConfig(long InfoType, long DevNum, long ConfigItem, long *ConfigVal)
{
	// TODO: Add your implementation code here

        CBI_CHECK(cbGetConfig(InfoType,_BoardNum,DevNum,ConfigItem,(int*)ConfigVal));
	return S_OK;
}


STDMETHODIMP CAin::AIn(long Channel, long Range, unsigned short *DataValue)
{
	// TODO: Add your implementation code here
        CBI_CHECK(cbAIn(_BoardNum,Channel,Range,DataValue));

	return S_OK;
}

STDMETHODIMP CAin::C8254Config(long CounterNum, long Config)
{
	// TODO: Add your implementation code here

        CBI_CHECK(cbC8254Config(_BoardNum,CounterNum,Config));
	return S_OK;
}

STDMETHODIMP CAin::CLoad(VARIANT RegName, unsigned long LoadValue)
{
	// TODO: Add your implementation code here
        variant_t vt(RegName);
        long regvalue=vt;

        CBI_CHECK(cbCLoad(_BoardNum,regvalue,LoadValue));
	return S_OK;
}
