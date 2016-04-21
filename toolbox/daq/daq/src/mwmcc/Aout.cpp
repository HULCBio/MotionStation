// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.1.6.2 $  $Date: 2003/12/04 18:39:48 $


// Aout.cpp : Implementation of CAout
#include "stdafx.h"
#include "Mwmcc.h"
#include "Aout.h"
#include "sarrayaccess.h"
#include "math.h"
#include <algorithm>
#define AUTO_LOCK TAtlLock<CAout> _lock(*this)
#ifdef _DEBUG
#undef THIS_FILE
#undef DEBUG_NEW
static char THIS_FILE[]=__FILE__;
#define DEBUG_NEW new(_NORMAL_BLOCK, THIS_FILE, __LINE__)
#define new DEBUG_NEW
#endif

/////////////////////////////////////////////////////////////////////////////
// CAout
CAout::CAout() :
TimerObj(this),
_UseHardwareRange(false),
_SampleRate(1000)
{
}

CAout::~CAout() 
{
}

STDMETHODIMP CAout::InterfaceSupportsErrorInfo(REFIID riid)
{
	static const IID* arr[] = 
	{
		&IID_IAout
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
enum CHANUSER {OUTPUTRANGE=1,HWCHANNEL,DEFAULT_VALUE}; // do not use user of 0


HRESULT CAout::Open(IDaqEngine * Interface,long ID)
{
    CComPtr<IProp> prop;
    CComVariant var;

    // assign the engine access pointer
    OutputType::Open(Interface);
   
    // Get the board number and verify.
    _BoardNum=ID;
    
    if (_BoardNum < 0 || _BoardNum > GINUMBOARDS)
        return ERR_XLATE(ERR_INVALID_ID);
    int chans=0;
    CBI_CHECK(cbGetConfig (BOARDINFO, _BoardNum, 0, BINUMDACHANS, &chans));
    if (chans==0)
        return ERR_XLATE(ERR_INVALID_ID);
    
    RETURN_HRESULT(SetDaqHwInfo());


    if (_maxSampleRate<pSampleRate || pSampleRate> _SampleRate)
    {
        _SampleRate=static_cast<long>(min(_SampleRate,_maxSampleRate));
        pSampleRate->put_DefaultValue(CComVariant(_SampleRate));
        pSampleRate=_SampleRate;
    }
    pSampleRate.SetRange(_minSampleRate,_maxSampleRate);
    CREATE_PROP(TransferMode);
    pTransferMode->AddMappedEnumValue(DEFAULTIO, L"Default");
    pTransferMode->AddMappedEnumValue(SINGLEIO , L"InterruptPerPoint");

    prop=ATTACH_PROP(OutOfDataMode);
    prop->put_IsHidden(false);


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
        prop->AddMappedEnumValue(MAKE_ENUM_VALUE(1,EXTCLOCK), L"External");
        pTransferMode->AddMappedEnumValue(DMAIO   , L"DMA");
        pTransferMode->AddMappedEnumValue(BLOCKIO , L"InterruptPerBlock");
    }

    double Range[2];
    RangeList_t::iterator ri=_validRanges.begin();
    
    
    Range[0]=(*ri)->minVal;
    Range[1]=(*ri)->maxVal;

    while(++ri!=_validRanges.end())
    {
        if (Range[0]>(*ri)->minVal)
            Range[0]=(*ri)->minVal;
        if (Range[1]<(*ri)->maxVal)
            Range[1]=(*ri)->maxVal;
    }

    CreateSafeVector(Range,2,&var);



    CRemoteProp rp;
    RETURN_HRESULT(GetChannelProperty(L"outputrange", &rp));
    rp->put_DefaultValue(var);

    //rp.Attach(engine,L"inputrange");

    RETURN_HRESULT( rp->put_User(OUTPUTRANGE));

    RETURN_HRESULT(rp.SetRange(Range[0],Range[1]));
    rp.Release();

    rp.Attach(_EngineChannelList,L"unitsrange");
    rp->put_DefaultValue(var);
    rp.Release();

    RETURN_HRESULT( GetChannelProperty(L"HwChannel", &rp));
    rp->put_User(HWCHANNEL);
    
    rp.SetRange(0,_MaxChannels-1);
    rp.Release();

    RETURN_HRESULT(GetChannelProperty(L"conversionoffset", &rp));
    rp->put_DefaultValue(CComVariant(1<<(_Resolution-1)));
    rp.Release();

    return S_OK;
    
}

int CAout::LoadDeviceInfo()
{  
    RETURN_HRESULT(CbDevice::LoadDeviceInfo(_T("AO")));

    _maxSampleRate = GetFromIni("AOMaxSR", 0);
    if (_maxSampleRate==0)
    {
        _maxSampleRate=MAX_SW_SAMPLERATE;
        _SampleRate=100;
        _UseSoftwareClock=true;
        _minSampleRate=MIN_SW_SAMPLERATE;
    }
    else
    {
        _minSampleRate = GetFromIni("AOMinSR", 1);
        if (_maxSampleRate<_minSampleRate)
            _minSampleRate=_maxSampleRate;
    }
    _scanning = GetFromIni("AOScanning", false);
    _Resolution = GetFromIni("AOResolution", 12);
    _ClockingType=GetFromIni("AOClockingType", NORMAL);

    // If this HW only supports SW Clocking (from INI File) then set the appropriate flag
    if(_ClockingType == SOFTWARE)
	_UseSoftwareClock=true;

    FixupSampleRates();    
    SetClockSource();

    return S_OK;
}

//
// SetDaqHwInfo
//
// Description:
//  Set the fields needed for DaqHwInfo
//
HRESULT CAout::SetDaqHwInfo()
{
    
    int len;
    DEBUG_HRESULT(SetBaseHwInfo());
    LoadDeviceInfo();
    LoadRangeInfo("OutputRanges");

        
    // total channels
    CBI_CHECK(cbGetConfig(BOARDINFO, _BoardNum, 0, BINUMDACHANS, &_MaxChannels));
    CComVariant var,vids;
 
    CreateSafeVector((short*)NULL,_MaxChannels,&vids);
    TSafeArrayAccess<short> ids(&vids);
    for (int i=0;i<_MaxChannels;i++)
    {
        ids[i]=i;
    }

    // Channel IDS
    DEBUG_HRESULT( _DaqHwInfo->put_MemberValue(L"channelids", vids));

    long hRes = _DaqHwInfo->put_MemberValue(L"totalchannels",CComVariant(_MaxChannels));
    if (!(SUCCEEDED(hRes))) return hRes;

    // device Id
    wchar_t idStr[8];
    swprintf(idStr, L"%d", _BoardNum);
    hRes = _DaqHwInfo->put_MemberValue(L"id", CComVariant(idStr));		
    if (!(SUCCEEDED(hRes))) return hRes;   


    // subsystem type
    //hRes = _DaqHwInfo->put_MemberValue(CComBSTR(L"subsystemtype"),CComVariant(L"AnalogInput"));
    //if (!(SUCCEEDED(hRes))) return hRes;

    // autocal
    
    DEBUG_HRESULT(_DaqHwInfo->put_MemberValue(L"sampletype",CComVariant(0L)));

    // number of bits    
    DEBUG_HRESULT(_DaqHwInfo->put_MemberValue(L"bits",CComVariant(_Resolution)));
    
    DEBUG_HRESULT(_DaqHwInfo->put_MemberValue(L"adaptorname", CComVariant(L"mcc")));

    DEBUG_HRESULT( _DaqHwInfo->put_MemberValue(L"polarity", CComVariant(L"Bipolar")));

    DEBUG_HRESULT( _DaqHwInfo->put_MemberValue(L"coupling", CComVariant(L"DC Coupled")));

    
    // device name  
    char BoardName[BOARDNAMELEN];

    CBI_CHECK(cbGetBoardName(_BoardNum,BoardName));
    DEBUG_HRESULT(_DaqHwInfo->put_MemberValue(L"devicename",CComVariant(BoardName)));

    // native data type
//    var = support16bit ? VT_UI2 : VT_UI1;
    DEBUG_HRESULT( _DaqHwInfo->put_MemberValue(L"nativedatatype", CComVariant(VT_UI2)));	

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
    int status;
    _chanRange.clear();
    _chanRange.reserve(_MaxChannels); 
    int range=-1;
    for (i=0;i<_MaxChannels;i++)
    {
        status=cbGetConfig(BOARDINFO,_BoardNum,i,BIDACRANGE,&range);
        if (status==0 && (range>=0) && (range!=UNIPOLAR) && (range!=BIPOLAR))
        {
            _chanRange.push_back(range);
        }
        if (status || range < 0 ) break;
    }
    if (status==0 && range>=0)
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
            // build list from channels
            _UseHardwareRange=true;
            _validRanges.clear();
            for (std::vector<short>::iterator i=_chanRange.begin();i!=_chanRange.end();++i)
            {
                RangeMap_t::iterator ri=_rangemap.find(*i);
                if (ri!=_rangemap.end())
                    _validRanges.push_back(ri->second);
            }
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

    DEBUG_HRESULT(_DaqHwInfo->put_MemberValue(CComBSTR(L"outputranges"), var));
    var.Clear();    
    return S_OK;
}


STDMETHODIMP CAout::SetChannelProperty(long UserVal, tagNESTABLEPROP * pChan, VARIANT * NewValue)
{
    int Index=pChan->Index-1;  // we use 0 based index 
    _ASSERTE(Index<_nChannels);
    variant_t& vtNewValue=reinterpret_cast<variant_t&>(*NewValue);
    switch (UserVal)
    {
    case OUTPUTRANGE:
        {
            TSafeArrayAccess<double> NewRange(NewValue);
            RANGE_INFO *NewInfo;
            RETURN_HRESULT(FindRange(static_cast<float>(NewRange[0]),
			                         static_cast<float>(NewRange[1]),NewInfo));
            if (_UseHardwareRange)
            {
                if (_chanRange[pChan->HwChan]!=NewInfo->rangeInt)
                    return Error("This Hardware uses jumpers for output range check with instacal.");
            }
            else
            {
                _chanRange[Index]=NewInfo->rangeInt;
                int status=cbSetConfig(BOARDINFO,_BoardNum,pChan->HwChan,BIDACRANGE,NewInfo->rangeInt); // ignore error
            }
            NewRange[0]=NewInfo->minVal;
            NewRange[1]=NewInfo->maxVal;
        }
        break;
    case HWCHANNEL:
        {
            _chanList[Index]=vtNewValue;
        }
    case DEFAULT_VALUE:
        {
            return UpdateDefaultChannelValue(Index,vtNewValue);
        }
            
    default:
        _updateChildren=true;
    }
    return S_OK;
}

STDMETHODIMP CAout::ChildChange(ULONG typeofchange,  tagNESTABLEPROP * pChan)
{
    HRESULT retval=S_OK;
    //int progress=typeofchange & ~CHILDCHANGE_REASON_MASK;
    int type=typeofchange & CHILDCHANGE_REASON_MASK;
    AOCHANNEL* pAOChan=reinterpret_cast<AOCHANNEL*>(pChan);
    if (pChan) // if we have a channel
    {
        switch (type)
        {
        case ADD_CHILD  : 
            ++_nChannels;
            retval=UpdateChans(false); // must exist in base class // resizes channel arrrays
            _updateChildren=true;
            // now set the new range 
            RANGE_INFO *NewInfo;
            if (!retval)
            {
                if (_UseHardwareRange)
                {
                    RangeMap_t::iterator i=_rangemap.find(_chanRange[pChan->HwChan]);
                    if (i!=_rangemap.end())
                    {
                        NewInfo=i->second;
                        pAOChan->VoltRange[0]=_rangemap[_chanRange[pChan->HwChan]]->minVal;
                        pAOChan->VoltRange[1]=_rangemap[_chanRange[pChan->HwChan]]->maxVal;
                        memcpy(pAOChan->UnitRange,pAOChan->VoltRange,sizeof(pAOChan->VoltRange));
                    }
                }
                else
                {
                    retval=FindRange(static_cast<float>(pAOChan->VoltRange[0]),
						             static_cast<float>(pAOChan->VoltRange[1]),NewInfo);
                    if (!retval) _chanRange[_nChannels-1]=NewInfo->rangeInt;
                }
            }
            if (retval)
               --_nChannels;
            return retval;
        case DELETE_CHILD  :
            --_nChannels;
            break;
        case REINDEX_CHILD :

            break;
        }
    }
    if (typeofchange & END_CHANGE)
    {
        retval=UpdateChans(false); // must exist in base class
        _updateChildren=true;
    }
    return retval;
}

HRESULT CAout::UpdateChans(bool ForStart)
{
    _defaultChannelValues.resize(_nChannels);
    _chanList.resize(_nChannels);
    if (!_UseHardwareRange)
        _chanRange.resize(_nChannels);
     AOCHANNEL *aochan=NULL;
    if (_updateChildren && ForStart)
    {
#ifdef _DEBUG
        long chancheck=0;
        _EngineChannelList->GetNumberOfChannels(&chancheck);
        _ASSERTE(chancheck==_nChannels);
#endif
        for (int i=0; i<_nChannels; i++) 
        {    
            RETURN_HRESULT(_EngineChannelList->GetChannelStructLocal(i, (NESTABLEPROP**)&aochan));
            _ASSERTE(aochan);
            _chanList[i]=static_cast<short>(aochan->Nestable.HwChan);
            if (!_UseHardwareRange)
            {
                RANGE_INFO *NewInfo;
                RETURN_HRESULT(FindRange(static_cast<float>(aochan->VoltRange[0]),
					                     static_cast<float>(aochan->VoltRange[1]),NewInfo));
                _chanRange[i]=NewInfo->rangeInt;
            }
            RETURN_HRESULT(UpdateDefaultChannelValue(i,aochan->DefaultValue));
            
        }
        
        _updateChildren=false;
    }
    else
    {
        // we still need working chanlist and rangelist if no gainlist
    }
    return S_OK;
}

HRESULT CAout::UpdateDefaultChannelValue(int channel,double value)
{
    CComPtr<IChannel> pcont;
    
    RETURN_HRESULT(GetChannelContainer(channel, &pcont));
    CComVariant var;
    RETURN_HRESULT(pcont->UnitsToBinary(value,&var));
    _defaultChannelValues[channel]=var.iVal;
    return S_OK;
}

STDMETHODIMP CAout::Start()
{
    _buffersDone=0;
    _triggersPosted=0;
    _samplesOutput=0;
    _samplesPut=0;
    _PreIndex=0;

    // Initialize Counters for tracking if elapsed time  >= the time needed for an output
    dAOStartTime = 0.0;
    iSamplesToOutput = 0;

    if (_updateChildren) 
    {
        // need error check
        RETURN_HRESULT(UpdateChans());
    }
    if (_UseSoftwareClock)
        return OutputType::Start();
    RETURN_HRESULT(CheckChansForBackround());

    // Initialize the block size for the engine, used in GetScanData
    _engine->GetBufferingConfig(&_EngBuffSize,NULL);
   
    
    // allocate 16 times the number of samples per buffer
    // double buffered acquisition
    //delete [] _buffer; _buffer=NULL;
    long BufferSize = _nChannels * _EngBuffSize*16;
    if (BufferSize<64*1024)
    {
        BufferSize*=64*1024/BufferSize;
    }
    RETURN_HRESULT(_CircBuff.Initialize(BufferSize));
    LoadData();

    return S_OK;
}

STDMETHODIMP CAout::Stop()
{
    if (_UseSoftwareClock)
        return OutputType::Stop();
    TimerObj.Stop();
    AUTO_LOCK;

    CBI_CHECK(cbStopBackground(_BoardNum, AOFUNCTION));
    _running=false;
    return S_OK;
}

//
// The analog output trigger method.
// This funciton is called when a trigger event occurrs, or when 'Start' is called and the 
// triggerType is set to 'immediate'
//
STDMETHODIMP CAout::Trigger()
{
    // Create a MUTEX Lock
    AUTO_LOCK;
    
    // Check for software clocking
    if (_UseSoftwareClock)
        return OutputType::Trigger(); // Call the base trigger method and return
    
    // Create the MCC options flag
    _Options = BACKGROUND  |CONTINUOUS | pTransferMode |GET_ADAPTOR_ENUM_VALUE(pClockSource);
    //  _Options = BACKGROUND  |CONTINUOUS | BURSTIO |GET_ADAPTOR_ENUM_VALUE(pClockSource);
    
    // Round the requested sample rate down to the next level
    long sr1 =_SampleRate = static_cast<long>(floor(pSampleRate));
    
    // Call the universal library function to start the output for this device
    CBI_CHECK( cbAOutScan( 
	_BoardNum,_chanList[0],_chanList[_nChannels-1], _CircBuff.GetBufferSize() , &_SampleRate,  _chanRange[0], _CircBuff.GetPtr(), _Options));
    
    // Get the DAQ Engine start time;
    _engine->GetTime(&dAOStartTime);
    
    // Confirm that the universal library did not adjust the sample rate
    if ( !(_SampleRate==sr1 || _SampleRate== floor(pSampleRate+0.5)))
    {
	// Warn if the rate changed
	_engine->WarningMessage(L"SampleRate changed at start.");
	_RPT3(_CRT_WARN,"SampleRate changed at start NewRate=%d TestRate=%f chans=%d\n",_SampleRate,(DOUBLE)pSampleRate,_nChannels);
	// Update the class' settings
	pSampleRate=_SampleRate;
    }
    
    // Set the timer object period
    double triggerTime = (double)_EngBuffSize/pSampleRate-0.01;
    triggerTime /= 2;
    
    TimerObj.CallPeriod(triggerTime);
    
    // The output is now running
    _running=true;
    return S_OK;
}

STDMETHODIMP CAout::SetProperty(long User, VARIANT * NewValue)
{
    
    if (User) 
    
    {
        CLocalProp* pProp=PROP_FROMUSER(User);
        variant_t *val=(variant_t*)NewValue;
        // I would like to have used a case statement here but can not find a way to code it
        if (User==USER_VAL(pSampleRate))
        {
            if (_UseSoftwareClock)
                return OutputType::SetProperty(User,NewValue);

            *val=RoundRate(*val);
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
        // Now set the actual value
        pProp->SetLocal(*val);

        _updateProps=true;
    }
    return S_OK;
}


void CAout::LoadData()
{
    BUFFER_ST* pBuf=NULL;
    while ( _CircBuff.FreeSpace() >(long)(_EngBuffSize*_nChannels))
    {
    
        HRESULT hRes = _engine->GetBuffer(0, &pBuf);
        if (FAILED(hRes) || pBuf==NULL)
        {
            // need to fill the buffer here
            short *vals=(short*)_alloca(_nChannels*sizeof(short));
                    int size1,size2;
            CIRCBUFFER::CBT *ptr1, *ptr2,*plast;
            _CircBuff.GetReadPointers(&ptr1, &size1, &ptr2, &size2);
            if (size2)
            {
                _ASSERTE(size2>=_nChannels);
#ifdef _DEBUG
                if (size2<_nChannels) // prevent crash 
                    return;
#endif
                    plast=ptr2+(size2-_nChannels);
            }
            else
            {
                _ASSERTE(size1>=_nChannels);
                plast=ptr1+(size1-_nChannels);
            }

            for (int i=0;i<_nChannels;i++)
            {
                switch (pOutOfDataMode)
                {
                case ODM_HOLD:	// default is to hold last value indefinitely
                    vals[i]=plast[i];	
                    break;
                case ODM_DEFAULTVALUE:
                    {
                        // use the default value
                        vals[i]=_defaultChannelValues[i]; // Units need to be implmented
                    }
                    break;
                default:
                    vals[i]=plast[i];	
                    break;
                }
            }
            _CircBuff.GetWritePointers(&ptr1, &size1, &ptr2, &size2);
            for (i=0;i<size1;i++) *ptr1++=vals[i % _nChannels];
            if (ptr2)  // the next line assums that all buffer sizes are a clean multiple of channels
                for (int i=0;i<size2;i++) *ptr2++=vals[i % _nChannels];

            return;
        }       
        _samplesPut+=pBuf->ValidPoints/_nChannels;
        _CircBuff.CopyIn((CIRCBUFFER::CBT*)pBuf->ptr,pBuf->ValidPoints);
  
	// Increase the counter that tracks how many samples this session should output
	iSamplesToOutput += pBuf->ValidPoints;
	
	if (pBuf->Flags & BUFFER_IS_LAST)
        {
            _LastBufferLoaded=true;
            
        }
        else 
            _LastBufferLoaded=false;

        _engine->PutBuffer(pBuf);
    }
}

void CAout::SyncAndLoadData()
{
    short Stopped;
    bool UnderRun=false;
    long CurrentCount,CurrentIndex;
    
    // Create a mutex lock
    AUTO_LOCK;    

    // Obtain the current driver status
    short stat=cbGetStatus(_BoardNum,&Stopped,&CurrentCount,&CurrentIndex, AOFUNCTION);
    if (stat)
    {
        _engine->DaqEvent(EVENT_ERR, 0, _samplesOutput, GetErrMsg(stat));
        return;
    }
    //_RPT3(_CRT_WARN,"WFM_Check returned %d Iters %d points for a total of %d points\n",ItersDone, CurrentIndex,ItersDone*_CircBuff.GetBufferSize()+CurrentIndex);
    //CurrentIndex>>=1;

    // If at this time the driver reports no samples have been sent return to the timer callback
    if (CurrentIndex==-1)
        return;

    // Check to see if the buffer was over run
    if (CurrentIndex>=_CircBuff.GetBufferSize())
    {
        ATLTRACE("Points done is greater then buffer size");
        CurrentIndex=_CircBuff.GetBufferSize()-1;
    }
    
    //
    // Check for UNDERRUNS in this context UNDERRUN means that more data was accessed by the driver
    // than was actually requested by the user (I think this is BAD terminology - IMB )
    //
    // We need to also pay attention to whether the buffer wrapped or not
    //
    
    // IF the current index is at a location prior to the last sent block, then the buffer access wrapped around
    // The buffer looks like  <-------CURRENTINDEX---------PREVOUSINDEX---------->
    if (CurrentIndex<_PreIndex)
    {
	// The buffer looks like    <------WRITE------CURRENTINDEX--------->
	// or the buffer looks like <----------READ----------WRITE------------->	
        if ((int)CurrentIndex >=_CircBuff.GetWriteLoc() || _CircBuff.GetReadLoc() <=_CircBuff.GetWriteLoc())
        {
            // underrun detected
            UnderRun=true;
        }
        ++_buffersDone;
    }
    else // There was no wrap around
    {
 	// The buffer looks like  <----READ---------WRITE--------------CURRENTINDEX-------->
	if ((int)CurrentIndex>=_CircBuff.GetWriteLoc() && _CircBuff.GetWriteLoc() >= _CircBuff.GetReadLoc())
        {
            // underrun detected
            UnderRun=true;
        }
    }

    //Update the samples output variables to reflect the 
    UpdateSamplesOutput(_buffersDone,CurrentIndex);

    //This buffer has been processed, store the index of the last completed scan
    _PreIndex=CurrentIndex;

#if 0
    double time;
    _engine->GetTime(&time);
    _RPT2(_CRT_WARN,"Samples output is %d time is %f\n",(int)_samplesOutput,time);
#endif

    // If for some reason the _samplesOutput variable became negative, force it to zero
    if (_samplesOutput<0)
    {
	//	_RPT1(_CRT_WARN,"SamplesOutput is %d fixing to 0\n",(int)_samplesOutput);
	_samplesOutput=0;
    }

    // IF there was a previously detected UNDERRUN;
    if (UnderRun)
    {
	// If > 0 buffers have been loaded, then proceed
        if (_LastBufferLoaded)
        {
   
	    //
	    // Semi busy wait until all the data points have been sent, or we bump over the maximum iterations
	    //
	    for( int LoopCount = 0; (_samplesPut>_samplesOutput) && !Stopped && (stat==0) && LoopCount < 10 ; LoopCount++)
            {
		// Get the current status of the process
                stat=cbGetStatus(_BoardNum,&Stopped,&CurrentCount,&CurrentIndex, AOFUNCTION);
		
		// If there are no errors then update the samples outputted variable
                if (stat==0) 
                    UpdateSamplesOutput(_buffersDone,CurrentIndex);
		// Sleep for a very little bit
                Sleep(1);
            }
 
	    // If after the loop there are still samples to be send then sleep for the time required to output the rest of the data
	    if (_samplesPut>_samplesOutput)
                Sleep(static_cast<DWORD>((_samplesPut-_samplesOutput)*1000/_SampleRate+1)); // 1000ms*time per point
   
	    // Perform a sanity check on the time_SampleRate
	    double time;
	    // Get the DAQ Engine time
	    _engine->GetTime(&time); 
	    time -=  dAOStartTime;
	    // The samplesToOutput must be divided by the total number of channels when the time to ouput is estimated
	    time = (static_cast<double>(iSamplesToOutput)/static_cast<double>(_SampleRate)) / _chanList.size() - time;
	    if( (time) > 0 )
		Sleep(static_cast<DWORD>(time * 1000)); // S * 1000 = MS

	    // After the longer wait, recheck the status and update the the samples output variable
	    stat=cbGetStatus(_BoardNum,&Stopped,&CurrentCount,&CurrentIndex, AOFUNCTION);
            
	    if (stat==0)  
                UpdateSamplesOutput(_buffersDone,CurrentIndex);
 
	    // Can not call this.stop because it will call the timers stop
	    // Stop the background output process and mark the running flag appropriatly 
            cbStopBackground(_BoardNum, AOFUNCTION);
            _running=false;
	    
	    // Update the sampls outputted variable and tell DAQMEX we have stopped	    
            _samplesOutput=min(_samplesPut,_samplesOutput);
            _engine->DaqEvent(EVENT_STOP, 0, _samplesOutput, NULL);
            return;
        }
        else // no buffers have been sent
        {
            // error condition
	    _engine->DaqEvent(EVENT_ERR, 0, _samplesOutput, NULL);
            // Reset the circular buffer
            _CircBuff.SetWriteLocation(CurrentIndex);
        }
    }
    _CircBuff.SetReadLocation(CurrentIndex);
    LoadData();
/* No hardware triggering?
    if (pTriggerType==TRIG_DIGITAL && _triggersPosted==0 && _samplesOutput>0 )       
    {
        double time;                
        _engine->GetTime(&time);
        double triggerTime = time - _samplesOutput/_SampleRate;
        _engine->DaqEvent(EVENT_TRIGGER, triggerTime, 0, NULL);
        _triggersPosted++;
    }
    */
}
