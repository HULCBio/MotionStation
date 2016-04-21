// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.3.4.6 $  $Date: 2003/12/22 00:48:13 $


// nid2a.cpp : Implementation of CMwdrvApp and DLL registration.

#include "stdafx.h"
#include <stdio.h>

#include "daqmex.h"
#include "daqtypes.h"

#include "errors.h"
#include <math.h>
#include <sarrayaccess.h>
#include "messagew.h"
#include "mwnidaq.h"
#include "DaqmexStructs.h"
#include "nidaq.h"
#include "nidaqcns.h"
#include "nidaqerr.h"
#include "niutil.h"
#include "nid2a.h"
#include "resource.h"

#pragma warning(disable:4660) // if these declerations are not here
template class Tnid2a<short>;
template class Tnid2a<long>;


#define WFM_CLEAR   (0)
#define WFM_START   (1)

// we need a window handle for the NI-DAQ callbacks 
#define AUTO_LOCK TAtlLock<Cnid2a> _lock(*this)

typedef enum {
    INTERRUPTS=ND_INTERRUPTS,
    SINGLE_DMA=ND_UP_TO_1_DMA_CHANNEL,
    DUAL_DMA=ND_UP_TO_2_DMA_CHANNELS,
    OTHER // programmed I/O
} XferMode;

/////////////////////////////////////////////////////////////////////////////
//
// NI-DAQ Analog Input constructor
Cnid2a::Cnid2a() : 
_buffersDone(0),
_triggersPosted(0),
_clockSrc(0),
_chanList(NULL), 
_hWnd(NULL),
_isConfig(false),
_nChannels(0), 
_outOfDataMode(0),
_polarityList(NULL), 
_running(false),
_samplesOutput(0),
_samplesPut(0),
_triggerType(TRIG_IMMEDIATE),
_underrun(false),
_updateMode(INTERNAL),
_refVoltage(0.0),
_sampleRate(1000), 
_waveformGroup(1),
_LastBufferLoaded(false),
_fifoSize(2048+32),
_xferMode(SINGLE_DMA)
{
    _chanRange[0] = new double[1];
    _chanRange[1] = new double[1];

    _chanRange[0][0] = -10;
    _chanRange[1][0] = 10;
}

Cnid2a::~Cnid2a()
{   
    if (_running)
    {
        Stop();
        if (_Nid2aWnd  && _id!=0)
        {
            if (_engine) _engine->WarningMessage(CComBSTR(L"Sleeping"));
            Sleep(200);
            MSG msg;
            while ( PeekMessage(&msg, _Nid2aWnd->GetHandle(), NULL, NULL,PM_REMOVE))
            {
                
                TranslateMessage(&msg);
                DispatchMessage(&msg);
            }
            
            _Nid2aWnd->DeleteDev(_id);
        }
    }
    delete [] _chanRange[0]; _chanRange[0] = NULL;
    delete [] _chanRange[1]; _chanRange[1] = NULL;

    delete [] _polarityList; _polarityList = NULL;
    delete [] _chanList;     _chanList     = NULL;



    _defaultChannelValueIProp.Release();

}


int Cnid2a::SetOutputRangeDefault(short polarity)
{
    
    int hRes;
    CComVariant val;    
    double range[2];
    double MaxVolts=GetDevCaps()->dacBipolarRange;
	CComVariant minVal(-MaxVolts);

	if (MaxVolts<GetDevCaps()->dacUnipolarRange)
	{
		MaxVolts=GetDevCaps()->dacUnipolarRange;
	}

    CComVariant maxVal(MaxVolts);

    
    // default hardware setting is +/- 10 volts, bipolar
    if (polarity==BIPOLAR)
    {
        range[0]=-GetDevCaps()->dacBipolarRange;
        range[1]= GetDevCaps()->dacBipolarRange;
    }
    else
    {
        range[0]=0;
        range[1]= GetDevCaps()->dacUnipolarRange;
    }
    CreateSafeVector(range,2,&val);
    
    // Output range
    CComPtr<IProp> prop;    

    hRes = GetChannelProperty(L"OutputRange", &prop);
    if (FAILED(hRes)) return hRes;


    hRes = prop->put_User((long)OUTPUTRANGE);
    if (!SUCCEEDED(hRes)) return hRes;
    
    hRes = prop->put_DefaultValue(val);  
    if (!SUCCEEDED(hRes)) return hRes;
    
    prop->SetRange(&minVal,&maxVal);

    prop.Release();

    return S_OK;
}

int Cnid2a::SetDaqHwInfo()
{
    SAFEARRAY *ps;   
    // hwinfo property container
    HRESULT hRes = _DaqHwInfo->put_MemberValue(L"totalchannels",CComVariant(GetDevCaps()->nOutputs));
    if (!(SUCCEEDED(hRes))) return hRes;

    std::vector <short> ids;
    ids.resize(GetDevCaps()->nOutputs);
    for (unsigned int i=0;i<ids.size();i++)
        ids[i]=i;

    CComVariant vids;
    CreateSafeVector(&ids[0],ids.size(),&vids);

    hRes = _DaqHwInfo->put_MemberValue(CComBSTR(L"channelids"), vids);
    if (!(SUCCEEDED(hRes))) return hRes;

    // number of bits
    hRes = _DaqHwInfo->put_MemberValue(CComBSTR(L"bits"),
        CComVariant(GetDevCaps()->dacResolution));
    if (!(SUCCEEDED(hRes))) return hRes;
   
    // device name
    CComVariant val(GetDevCaps()->deviceName);
    hRes = _DaqHwInfo->put_MemberValue(L"devicename", val);	
    if (!(SUCCEEDED(hRes))) return hRes;
    val.Clear();
    
    // subsystem type
    hRes = _DaqHwInfo->put_MemberValue(L"subsystemtype",CComVariant(L"AnalogOutput"));
    if (!(SUCCEEDED(hRes))) return hRes;

    // driver name
    hRes = _DaqHwInfo->put_MemberValue(L"adaptorname",CComVariant(L"nidaq"));
    if (!(SUCCEEDED(hRes))) return hRes;
      
    // native data type
    if (GetDevCaps()->IsDSA())
	val = VT_I4;
    else
    {
	if (GetDevCaps()->IsAODC())
	    val = VT_UI2;
	else
	    val = VT_I2;
    }
    hRes = _DaqHwInfo->put_MemberValue(L"nativedatatype", val);
    if (!(SUCCEEDED(hRes))) return hRes;

    // device Id
    wchar_t idStr[8];
    swprintf(idStr, L"%d", _id);
    hRes = _DaqHwInfo->put_MemberValue(L"id", CComVariant(idStr));		
    if (!(SUCCEEDED(hRes))) return hRes;

    // all ni hardware is dc coupled
    hRes = _DaqHwInfo->put_MemberValue(CComBSTR(L"coupling"), CComVariant(L"DC"));
    if (!(SUCCEEDED(hRes))) return hRes;

    // minsamplerate
    hRes = _DaqHwInfo->put_MemberValue(CComBSTR(L"minsamplerate"), CComVariant(GetDevCaps()->minSampleRate));
    if (!(SUCCEEDED(hRes))) return hRes;
    
    // maxsamplerate
    hRes = _DaqHwInfo->put_MemberValue(CComBSTR(L"maxsamplerate"), CComVariant(GetDevCaps()->maxAOSampleRate));
    if (!(SUCCEEDED(hRes))) return hRes;

    // sampling type is simultaneous for output
    hRes = _DaqHwInfo->put_MemberValue(CComBSTR(L"sampletype"), CComVariant(1L));
    if (!(SUCCEEDED(hRes))) return hRes;
   
   
    // polarity
    if (GetDevCaps()->dacUnipolarRange!=0)
    {
        
        LPCOLESTR polarities[]={L"Bipolar",L"Unipolar"};
        CreateSafeVector(polarities,2,&val);
        hRes = _DaqHwInfo->put_MemberValue(CComBSTR(L"polarity"), val);
        if (!(SUCCEEDED(hRes))) return hRes;
        val.Clear();

        
    }
    else
    {
        hRes = _DaqHwInfo->put_MemberValue(CComBSTR(L"polarity"), CComVariant(L"Bipolar"));
        if (!(SUCCEEDED(hRes))) return hRes;
    }

    // autocal
//    hRes = _DaqHwInfo->put_MemberValue(CComBSTR(L"autocalibrate"),CComVariant(0L));
//    if (!(SUCCEEDED(hRes))) return hRes;

    hRes = _DaqHwInfo->put_MemberValue(CComBSTR(L"vendordriverdescription"),
        CComVariant(L"National Instruments Data Acquisition Driver"));
    if (!(SUCCEEDED(hRes))) return hRes;    

    char version[16];
    GetDriverVersion(version);    
    hRes = _DaqHwInfo->put_MemberValue(CComBSTR(L"vendordriverversion"),CComVariant(version));
    if (!(SUCCEEDED(hRes))) return hRes;

    // output ranges  
    // this is a 2-d array of range values
    // there are unipolar and bipolar ranges 
    val.Clear();
    int len=0;
    if (GetDevCaps()->dacBipolarRange!=0)
        len++;
    if (GetDevCaps()->dacUnipolarRange!=0)
        len++;

    SAFEARRAYBOUND rgsabound[2];  
    rgsabound[0].lLbound = 0;
    rgsabound[0].cElements = len; // bipolar and unipolar 
    rgsabound[1].lLbound = 0;
    rgsabound[1].cElements = 2;     // upper and lower range values
    
    ps = SafeArrayCreate(VT_R8, 2, rgsabound);
    if (ps == NULL) return E_SAFEARRAY_ERR;       
    double *ranges,*pl,*ph;
   
    hRes = SafeArrayAccessData (ps, (void **) &ranges);
    if (FAILED (hRes)) 
    {
        SafeArrayDestroy (ps);
        return E_SAFEARRAY_ERR;
    }
   
    pl=ranges;
    ph=ranges+len;
    if (GetDevCaps()->dacUnipolarRange!=0)
    {
        *pl++=0;
        *ph++=GetDevCaps()->dacUnipolarRange;
    }
    if ( GetDevCaps()->dacBipolarRange!=0)
    {
        *ph=GetDevCaps()->dacBipolarRange;
        *pl++=-*ph++;
    }

    V_VT(&val)=(VT_ARRAY | VT_R8);    
    V_ARRAY(&val)=ps;
    
    SafeArrayUnaccessData (ps);

    hRes = _DaqHwInfo->put_MemberValue(CComBSTR(L"outputranges"), val);	
    return hRes;    

}

/*
 * Open a device, initialize it, and register
 */ 
MessageWindow* Cnid2a::_Nid2aWnd=NULL;

HRESULT Cnid2a::Open(IDaqEngine *engine, int id,DevCaps* DeviceCaps)
{
    static MessageWindow static_Nid2aWnd("mwnid2a");
    _Nid2aWnd=&static_Nid2aWnd;

    // assign the engine access pointer
    _engine = engine;
    _ASSERT(engine!=NULL);
    
    if (id<1) return E_INVALID_DEVICE_ID;
    // if we can't initialize here, go no further
    DAQ_CHECK(CniDisp::Open(id,DeviceCaps));
    CmwDevice::Open(engine);
    DAQ_CHECK(Initialize());

    if (!GetDevCaps()->IsValid()) 
    {
		//return E_E_SERIES_ONLY;
        _engine->WarningMessage(CComBSTR(L"Hardware information not found in MWNIDAQ.INI. This device is not supported and has not been tested."));
    }

    // We need a window handle for the callback	
    _hWnd = _Nid2aWnd->GetHandle();
    if (!_hWnd) return E_HWND_FAIL;
    
    // Common properties  

	// Range check initial sample rate
    RegisterProperty(L"SampleRate", _sampleRate);  // Attach to cached remote property
	_sampleRate.SetRange(GetDevCaps()->minSampleRate, GetDevCaps()->maxAOSampleRate);
	if ( _sampleRate > GetDevCaps()->maxAOSampleRate )
	{
		_sampleRate.SetDefaultValue(GetDevCaps()->maxAOSampleRate); 
		_sampleRate = GetDevCaps()->maxAOSampleRate;
	}

    CComPtr<IProp> prop;
    prop = RegisterProperty(L"TimeOut", _timeOut);
    prop.Release();

    prop = RegisterProperty(L"OutOfDataMode", _outOfDataMode);
    prop->put_IsHidden(false);
    prop.Release();

    prop = RegisterProperty(L"TriggerType", _triggerType);
    prop->AddMappedEnumValue(HW_DIGITAL,  L"HwDigital");
    prop.Release();
 

    // device specific properties
    _EnginePropRoot->CreateProperty(CComBSTR(L"ClockSource"), NULL,  __uuidof(IProp),(void**) &prop);        
    prop->put_User((long)&_clockSrc);

    if (GetDevCaps()->IsAODC())
    {
		CComVariant NoClock(CLOCKSOURCE_NONE);

		prop->RemoveEnumValue(CComVariant(CLOCKSOURCE_INTERNAL));
		prop->AddMappedEnumValue(CLOCKSOURCE_NONE ,CComBSTR( L"None"));
		prop->put_DefaultValue(NoClock);
		prop->put_Value(NoClock);
		_clockSrc = CLOCKSOURCE_NONE;
    }
    else
    {
        prop->AddMappedEnumValue(0,CComBSTR( L"Internal"));
        prop->AddMappedEnumValue(1,CComBSTR( L"External"));
    }
    prop.Release();

    _interval.Create(_EnginePropRoot,L"Interval",0);
    _interval->put_IsHidden(true);


    /*
    pCont->CreateProperty(L"WhichClock", NULL, &prop);        
    prop->put_User((long)&_clockSrc);
    prop->AddMappedEnumValue(UPDATE_CLOCK, L"Internal");
    prop->AddMappedEnumValue(DELAY_CLOCK, L"Delay");
    prop->AddMappedEnumValue(DELAY_CLOCK_PRESCALAR_1, L"DelayPrescalar1");
    prop->AddMappedEnumValue(DELAY_CLOCK_PRESCALAR_2, L"DelayPrescalar2");
    prop.Release();
*/
    // transfer mode
    bool dual_dma_sup=true;
    bool single_dma_sup=true;

    _EnginePropRoot->CreateProperty(L"TransferMode", NULL,  __uuidof(IProp),(void**) &prop);    
    prop->put_User((long)&_xferMode);
    int status=Set_DAQ_Device_Info(_id, ND_DATA_XFER_MODE_AO_GR1, ND_UP_TO_2_DMA_CHANNELS);
    if (status) 
        dual_dma_sup=false;
    
    if (Set_DAQ_Device_Info(_id, ND_DATA_XFER_MODE_AO_GR1, ND_UP_TO_1_DMA_CHANNEL))
        single_dma_sup=false;
        
    if (GetDevCaps()->transferModeAO==ND_INTERRUPTS)
	prop->AddMappedEnumValue(ND_INTERRUPTS, L"Interrupts");
    else
	prop->AddMappedEnumValue(0, L"None");

    if (single_dma_sup) 
    {
        prop->AddMappedEnumValue(ND_UP_TO_1_DMA_CHANNEL, L"SingleDMA");
        if (GetDevCaps()->transferModeAO==ND_INTERRUPTS)
            GetDevCaps()->transferModeAO=ND_UP_TO_1_DMA_CHANNEL;
    }

    if (dual_dma_sup)
    {
        prop->AddMappedEnumValue(ND_UP_TO_2_DMA_CHANNELS, L"DualDMA");
        if (GetDevCaps()->AOFifoSize==0 && !GetDevCaps()->HasMite)
            GetDevCaps()->transferModeAO=ND_UP_TO_2_DMA_CHANNELS;
    }

    // now restore the transfer mode
    Set_DAQ_Device_Info(_id, ND_DATA_XFER_MODE_AO_GR1, GetDevCaps()->transferModeAO);

    prop->put_DefaultValue(CComVariant((long)GetDevCaps()->transferModeAO));
    prop->put_Value(CComVariant((long)GetDevCaps()->transferModeAO));
    _xferMode=(int)GetDevCaps()->transferModeAO;
    prop.Release();   
    
    GetChannelProperty(L"HwChannel", &prop);
    prop->put_User((long)HWCHAN);
    prop->SetRange(&CComVariant(0L),&CComVariant(GetDevCaps()->nOutputs-1));
    prop.Release();
       
    GetChannelProperty(L"DefaultChannelValue", &prop);    
    prop->SetRange(&CComVariant(-10L),&CComVariant(10L));
    _defaultChannelValueIProp=prop;
    prop.Release();   

    // output range
    HRESULT hRes = SetOutputRangeDefault(BIPOLAR);
    if (!(SUCCEEDED(hRes))) return hRes;       
    
    hRes=SetDaqHwInfo();
    if (!(SUCCEEDED(hRes))) return hRes;       

    hRes=DeviceSpecificSetup();
    if (!(SUCCEEDED(hRes))) return hRes;       
    
        
    return S_OK;
}

HRESULT Cnid2a::Initialize()
{
		    

//    DAQ_CHECK(Init_DA_Brds(_id, &deviceCode));
    
    // call an AO function to validate AO support for this device
    if (!GetDevCaps()->HasAO()) 
        return E_AO_UNSUPPORTED;

    return S_OK;	
}
/*
 * Set the analog input data transfer mode for Analog Input 
 *
 * The logic is as follows:
 *  Try the user settings first.
 *  Use single channel DMA by default if available
 *  Interrupts must be used if triggering is enabled, or
 *  if DMA is not available.
 * 
 *  Issue a warning if the desired setting is not available
 */
int Cnid2a::SetXferMode()
{	
		
    int status = DAQ_NO_ERROR;
    //long tmpMode;        

    /*
     * Get the desired transfer mode
     */
/* this case no longer needed
    switch (_xferMode) 
    {
      case INTERRUPTS:
	  tmpMode = ND_INTERRUPTS;
	  break;
      case SINGLE_DMA:
	  tmpMode = ND_UP_TO_1_DMA_CHANNEL;
	  break;      
      default:
	  // we should never get here
	  return E_INVALID_TRANSFER_MODE;					  

    }
    */

    status = Set_DAQ_Device_Info(_id, ND_DATA_XFER_MODE_AO_GR1, _xferMode);

   /*
    * if the desired mode returns an error, use interrupts as a last resort
    */
    if (status) 
    {
        if (status==-10609 && GetDevCaps()->IsLab())
        {
            //just eat it
            return 0;
        }
//        const wchar_t *errStr = daqTranslateErrorCode(status);
        // issue a warning here to indicate the desired mode could not be set
        if (_xferMode!=ND_INTERRUPTS)
            _engine->WarningMessage(CComBSTR(L"Single_DMA transfer mode not available on this device. \nDefaulting to Interrupt mode."));
        _xferMode=ND_INTERRUPTS;
        return(Set_DAQ_Device_Info(_id, ND_DATA_XFER_MODE_AO_GR1, ND_INTERRUPTS));
    }
    
    return(status);
}

HRESULT Cnid2a::Configure()
{  

    if (!_nChannels)
        return S_OK;

     // setup the transfer mode (DMA or interrupts)    

//    ClearEventMessages(_id);

    DAQ_CHECK(TriggerSetup());
    

    return S_OK;
}


int Cnid2a::SetWaveformGenMsgParams(int mode)
{
    
    char chanStr[80];    
    ChanList2Str(_chanList, _nChannels, AO, chanStr);

    DAQ_CHECK(Config_DAQ_Event_Message(_id,
	mode,
	ChanList2Str(_chanList, _nChannels, AO, chanStr),
	NOTIFY_WHEN_DONE_OR_ERR,
	0L,
	0L,
	0L,
	0L,
	0L,
	_hWnd,
	WM_NOTIFY_WHEN_DONE_OR_ERR,
	(long)WfmCallback));

    /*
    For DAQEvent = 1, DAQTrigVal0 must be greater than zero. 
    If you are using DMA with double buffers or a pretrigger 
    data acquisition, DAQTrigVal0 must be an even divisor of 
    the size of the buffer in scans.

    For DAQEvent = 1, DAQTrigVal0 must always be an even divisor of 
    the buffer or a multiple of it.
    */
    // according to the doc, the channel number in the channel string is ignored.

    return(Config_DAQ_Event_Message(
        _id, 
        mode,                                            // add message
        ChanList2Str(_chanList, _nChannels, AO, chanStr),   // channel string, e.g. "AO1"
        NOTIFY_AFTER_EACH_NSCANS,                          // event criteria
        _EngineBufferSamples,                               // number of scans
        0L,                                                 // ignored
        0L,                                                 // triggers to skip
        0L,                                                 // pretrigger scans
        0L,                                                 // post trigger scans
        _hWnd,                                              // window to post msg to
        WM_NOTIFY_AO_READY,                                 // msg to post
        (long)WfmCallback));                                // callback
}

void Cnid2a::CleanUp()
{
    BUFFER_ST *pBuf;

    // Move all the buffers back to the FromDev list
    while (_engine->GetBuffer(0, &pBuf)==S_OK)
    {
        _engine->PutBuffer(pBuf);
    }
    
    _samplesOutput=0;
    _samplesPut=0;

        
}

STDMETHODIMP Cnid2a::Start()
{
    int status=InternalStart();
    if (status)
    {
        _Nid2aWnd->DeleteDev(_id);
        _running=false;
    }
    return status;
}


STDMETHODIMP Cnid2a::Trigger()
{
    AUTO_LOCK; 

    int status = WFM_Group_Control(_id, _waveformGroup, WFM_START);
    if (status)
    {
        CleanUp();
	return status;
    }    
    //SyncAndLoadData();
    return S_OK;
    ATLTRACE("Triggered Nidaq D2A\n");
    
}

HRESULT Cnid2a::InternalStart()
{
    _ptsTfr=0;
    _samplesOutput=0;
    _samplesPut=0;
    _underrun=false;
    _buffersDone=0;
    _triggersPosted=0;
    AUTO_LOCK; 
    if (_Nid2aWnd->AddDev(_id,this))
    {
        return E_BAD_DEVICE;
    }
    
    // Error if no clock source
    if (_clockSrc == CLOCKSOURCE_NONE)
	{
		return deviceSupportError;
	}

    DAQ_CHECK(Configure());    
    // set up the transfer mode;
    DAQ_CHECK(SetXferMode());
    if (!_isConfig)
	{
		DAQ_CHECK(LoadOutputRanges());
	}
    /* This sets a timeout limit (#Sec * 18ticks/Sec) so that if there
     is something wrong, the program won't hang on the WFM_DB_Transfer
     call. */
//    DAQ_CHECK(Timeout_Config(_id, 180));

    DAQ_CHECK(WFM_Group_Setup(_id, (short)_nChannels, _chanList, _waveformGroup));

    if (GetDevCaps()->IsDSA())
    {
        double newrate;
        DAQ_CHECK(WFM_Set_Clock(_id,_waveformGroup,0,_sampleRate,0,&newrate));
    }
    else
    {
        short timebase;
        unsigned short updateInterval;
        if (_clockSrc==0)
        {
			/*
			* Convert the rate into timebase and update 
			* interval. Units default to pts/s
			*/
			GetDevCaps()->FindRate(_sampleRate, &timebase, &updateInterval);    
			_interval.Set(updateInterval);    
        }
        else
        {
            updateInterval=static_cast<short>(_interval);
            timebase=0;
        }
        // use the default clock source for now
        DAQ_CHECK(WFM_ClockRate(_id, _waveformGroup, 0, 
            timebase, updateInterval, _updateMode));
    }

    // Initialize the number of samples per buffer
    _engine->GetBufferingConfig(&_EngineBufferSamples,NULL);

	// Initialize the FIFO size
    _fifoSize = GetDevCaps()->AOFifoSize; // NIDAQ FIFO size is in 'points'

	// Get the number of points per buffer
    long engineBufferPoints = _EngineBufferSamples * _nChannels;

	// Compute the size of the circular buffer

    // We want a minimum of 4 engine buffers and 4096 points, but the number of points MUST  
    // be evenly divisible by number of channels AND the number of samples per buffer.
    long points = 4 * engineBufferPoints;
    while(points < 4096) 
        points += (engineBufferPoints);

    // Attempt to configure nidaq card for resonable response
    if (GetDevCaps()->HasMite)
    {
        _fifoSize+=32;

        if (engineBufferPoints < _fifoSize)
        {
            long status=0;
            if (engineBufferPoints < _fifoSize/2) // if size is less then 1/2 fifoing
            {
                status=AO_Change_Parameter(_id,_chanList[0],ND_DATA_TRANSFER_CONDITION,ND_FIFO_EMPTY);
                if (status==0)
                    _fifoSize=2;
            }
            else
            {
                status=AO_Change_Parameter(_id,_chanList[0],ND_DATA_TRANSFER_CONDITION,ND_FIFO_HALF_FULL_OR_LESS);
                if (status==0)
                    _fifoSize=(_fifoSize-32)/2+32;
            }
        }
        else
        {
            long status=AO_Change_Parameter(_id,_chanList[0],ND_DATA_TRANSFER_CONDITION,ND_FIFO_NOT_FULL);
        }
    }
    else
    {
        // Try disabling anyway
        if (engineBufferPoints < _fifoSize)
        {
            long status=0;
            status=AO_Change_Parameter(_id,_chanList[0],ND_DATA_TRANSFER_CONDITION,ND_FIFO_HALF_FULL_OR_LESS);
            if (status==0)
                _fifoSize=_fifoSize/2;
            if (engineBufferPoints < _fifoSize) // if size is still less then 1/2 fifo
            {
                status=AO_Change_Parameter(_id,_chanList[0],ND_DATA_TRANSFER_CONDITION,ND_FIFO_EMPTY);
                if (status==0)
                    _fifoSize=0;
            }
        }
        else
        {
            long status=AO_Change_Parameter(_id,_chanList[0],ND_DATA_TRANSFER_CONDITION,ND_FIFO_HALF_FULL_OR_LESS);
        }
    }

	// Make sure we get at least 1/2 second of points
    if ( points < PointsPerSecond()/2 ) 
    {
        int buffersperhalfsec = ((PointsPerSecond()/2) / engineBufferPoints) + 1;
        points = buffersperhalfsec * engineBufferPoints;
    }

	// Make sure we get at least 2X FIFO size
    if ( points < _fifoSize*2 )
    {
        points *= ((_fifoSize*2)/points)+1;
    }

	// Initialize the circular buffer and load the data into it
    InitBuffering(points);
    LoadData();
    if ( _samplesPut * _nChannels <= _fifoSize )
    {
		_engine->WarningMessage(CComBSTR(L"NI-DAQ: Samples put to device are less then fifo size.\nContinuous operation may be impossible."));
    }
    
    DAQ_CHECK(WFM_Group_Setup(_id, (short)_nChannels, _chanList, _waveformGroup));
    
    // setup message posting for NI-DAQ
    DAQ_CHECK(SetWaveformGenMsgParams(ADD_MSG));

    // Load the waveform into the desired channel(s)    
    int status = WFM_Load(_id, (short)_nChannels, _chanList, (short *)GetBufferPtr(),
				    points, 0/*_iterations*/, FALSE /*Fifo Mode*/);
    if (status)
    {	        
		CleanUp();
		return status;
    }
    
    _running = TRUE;

    return S_OK;
}


template<typename NativeDataType>
void Tnid2a<NativeDataType>::LoadData()
{
    BUFFER_ST* pBuf=NULL;
    while ( _CircBuff.FreeSpace() >_EngineBufferSamples*_nChannels)
    {
    
        HRESULT hRes = _engine->GetBuffer(0, &pBuf);
        if (FAILED(hRes) || pBuf==NULL)
        {
            // need to fill the buffer here
            CIRCBUFFER::CBT *vals=(CIRCBUFFER::CBT*)_alloca(_nChannels*sizeof(CIRCBUFFER::CBT));
                    int size1,size2;
            CIRCBUFFER::CBT *ptr1, *ptr2,*plast;
            _CircBuff.GetReadPointers(&ptr1, &size1, &ptr2, &size2);
            if (size2)
            {
                _ASSERTE(size2>=_nChannels);
                plast=ptr2+(size2-_nChannels);
            }
            else
            {
                _ASSERTE(size1>=_nChannels);
                plast=ptr1+(size1-_nChannels);
            }

            for (int i=0;i<_nChannels;i++)
            {
                switch (_outOfDataMode)
                {
                case ODM_HOLD:	// default is to hold last value indefinitely
                    vals[i]=plast[i];	
                    break;
                case ODM_DEFAULTVALUE:
                    {
#pragma message ("ODM_DEFAULTVALUE not yet implemented")
                        // use the default value
                        vals[i]=0; // this needs to be fixed
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
        if (pBuf->Flags & BUFFER_IS_LAST)
        {
            _LastBufferLoaded=true;
            
        }
        else 
            _LastBufferLoaded=false;

        _engine->PutBuffer(pBuf);
    }
}

template<typename NativeDataType>
void Tnid2a<NativeDataType>::SyncAndLoadData()
{
    short Stopped;
    unsigned long ItersDone,PointsDone;
    AUTO_LOCK;    
    if (!_Nid2aWnd->IsOpen(_id))
    { // this is to catch a possible race condition in the callback procedure
        ATLTRACE("SyncAndLoadData called on device that is not running");
        return;
    }
    short stat=WFM_Check(_id,_chanList[0],&Stopped,&ItersDone,&PointsDone);
    PointsDone*=_nChannels;
    if (stat)
    {
        // nidaq error post it
        if (stat!=-10608) //No transfer is in progress for the specified resource.
        {
            GetEngine()->DaqEvent(EVENT_ERR, 0, SamplesOutput(), TranslateErrorCode(stat));
        }
        return;
    }
    //_RPT3(_CRT_WARN,"WFM_Check returned %d Iters %d points for a total of %d points\n",ItersDone, PointsDone,ItersDone*_CircBuff.GetBufferSize()+PointsDone);
    //PointsDone>>=1;
    if (static_cast<int>(PointsDone)>=_CircBuff.GetBufferSize())
    {
        ATLTRACE("Points done is greater then buffer size");
        PointsDone=_CircBuff.GetBufferSize()-1;
    }
    // need to check for wraps
    if (_buffersDone<ItersDone)
    {
        if (_buffersDone<ItersDone-1 || (int)PointsDone >=_CircBuff.GetWriteLoc() || _CircBuff.GetReadLoc() <=_CircBuff.GetWriteLoc())
        {
            // underrun detected
            _underrun=true;
        }
        _buffersDone=ItersDone;
    }
    else
    {
        if ((int)PointsDone>=_CircBuff.GetWriteLoc() && _CircBuff.GetWriteLoc() >= _CircBuff.GetReadLoc())
        {
            // underrun detected
            _underrun=true;
        }
    }
    UpdateSamplesOutput(ItersDone,PointsDone);
#if 0
    double time;
    _engine->GetTime(&time);
    _RPT2(_CRT_WARN,"Samples output is %d time is %f\n",(int)_samplesOutput,time);
#endif
    if (_samplesOutput<0) // more debuging code
    {

        _RPT1(_CRT_WARN,"SamplesOutput is %d fixing to 0\n",(int)SamplesOutput());
        SamplesOutput(0);
    }

    if (_underrun)
    {
        if (_LastBufferLoaded)
        {
            // clean stop here
            // spin untill done
            int LoopCount=0;
            while((_samplesPut>_samplesOutput) && !Stopped && (stat==0) && LoopCount++<10)
            {
                stat=WFM_Check(_id,_chanList[0],&Stopped,&ItersDone,&PointsDone);
                PointsDone*=_nChannels;
                if (stat==0) 
                    UpdateSamplesOutput(ItersDone,PointsDone);
                Sleep(1);
            }
            if (_samplesPut>_samplesOutput)
                Sleep(static_cast<DWORD>((_samplesPut-_samplesOutput)*1000/_sampleRate+1)); // 1000ms*time per point
            stat=WFM_Check(_id,_chanList[0],&Stopped,&ItersDone,&PointsDone);
            PointsDone*=_nChannels;
            if (stat==0)  
                UpdateSamplesOutput(ItersDone,PointsDone);
            Stop();
            SamplesOutput(min(_samplesPut,_samplesOutput));
            GetEngine()->DaqEvent(EVENT_STOP, 0, _samplesOutput, NULL);
            return;
        }
        else
        {
            // error condition
           GetEngine()->DaqEvent(EVENT_ERR, 0, SamplesOutput(), NULL);
            _CircBuff.SetWriteLocation(PointsDone);
        }
    }
    _CircBuff.SetReadLocation(PointsDone);
    LoadData();

    if (_triggerType==HW_DIGITAL && _triggersPosted==0 && _samplesOutput>0 )       
    {
        double time;                
        _engine->GetTime(&time);
        double triggerTime = time - _samplesOutput/_sampleRate;
        _engine->DaqEvent(EVENT_TRIGGER, triggerTime, 0, NULL);
        _triggersPosted++;
    }
}

// if the device is running and putdata is called
// transfer the data to the device

STDMETHODIMP Cnid2a::Stop()
{    
    
    // Set WFM group back to default state. 
    WFM_Group_Control(_id, _waveformGroup, WFM_CLEAR);
    AUTO_LOCK;    
    // Set DB mode back to default state. 
    WFM_DB_Config(_id, (short)_nChannels, _chanList, 0, 0, 0);
    DAQ_CHECK(SetWaveformGenMsgParams(DEL_MSG));
   
    // restore trigger line to default state
    ::Select_Signal(_id, ND_OUT_START_TRIGGER, ND_AUTOMATIC, ND_LOW_TO_HIGH);
    
    // restore the transfer mode
    Set_DAQ_Device_Info(_id, ND_DATA_XFER_MODE_AO_GR1, GetDevCaps()->transferModeAO);

    switch (_outOfDataMode)
    {
    case ODM_HOLD:	// default is to hold last value indefinitely
        break;	
    case ODM_DEFAULTVALUE:
        {
            // use the default value
            for (int i=0; i<_nChannels; i++) 	
                AO_VWrite(_id, _chanList[i], _defaultValues[i]);
        }
        break;
    default:
        break;
    }
    
    Timeout_Config(_id, -1);
    //_Nid2aWnd->DeleteDev(_id);
    
    
    _isConfig=false;
    _running=false;
    
    _Nid2aWnd->DeleteDev(_id);
    
    return S_OK;
}



// The number of channels has changed, so reallocate
// the arrays. Channel lists get cleaned up by deleting
// all channels, e.g. _nChannels==0
int Cnid2a::ReallocCGLists()
{
    delete [] _chanList; _chanList=NULL;    
    delete [] _chanRange[0]; _chanRange[0] = NULL;
    delete [] _chanRange[1]; _chanRange[1] = NULL;    
    delete [] _polarityList; _polarityList = NULL;
    
    if (_nChannels == NULL) return S_OK;

    _chanList = new short[_nChannels];
    if (_chanList==NULL) return E_MEM_ERR;
   
    // setup the channel range for each channel
    _chanRange[0] = new double[_nChannels];
    if (_chanRange[0]==NULL) return E_MEM_ERR;

    _chanRange[1] = new double[_nChannels];
    if (_chanRange[1]==NULL) return E_MEM_ERR;

    _polarityList = new short[_nChannels];
    if (_polarityList==NULL) return E_MEM_ERR;

    _defaultValues.resize(_nChannels);

    // set the chanrange defaults
    for (int i=0; i<_nChannels; i++) 
    {
        _chanRange[0][i] = -GetDevCaps()->dacBipolarRange;
        _chanRange[1][i] = GetDevCaps()->dacBipolarRange;
	_polarityList[i] = BIPOLAR;
    }

    return S_OK;
}

STDMETHODIMP Cnid2a::SetProperty(long User, VARIANT *newVal)
{
   	
	variant_t *var = (variant_t*)newVal;	        
        
    // prevent mulitple objects pointing to the same device to change
    // param values while the device is open
    if (_Nid2aWnd->IsOpen(_id) && _Nid2aWnd->GetDevFromId(_id) !=this)
		return E_BAD_DEVICE;
	
    if (User==(long)&_sampleRate)
    {
		short timeBase;
        unsigned short interval;	                        
        double rateRequested = GetDevCaps()->FindRate((double)*var,&timeBase,&interval);
        if (rateRequested> GetDevCaps()->maxAOSampleRate)
        {
			// Geck 167706: If the FindRate function can return a value greater than
			// the maximum allowed by the card.  That shouldn't happen, see geck #
			// 194165 about that.  So, for R14, check to make sure that FindRate didn't
			// give an out of range value.  Error if it does.
			return E_EXCEEDS_MAX_RATE;
        }
        *var=rateRequested;
    }
	
	// Now set the actual value if there is a User
    ((CLocalProp*)User)->SetLocal(*var);
        
	// dirty flag - something changed, so reconfigure
	_isConfig=false;	
	DAQ_CHECK(Configure());

    return S_OK;
}


void Cnid2a::SetupChannels()
{
    _EngineChannelList->GetNumberOfChannels(&_nChannels);       
   
    ReallocCGLists();
    
    NESTABLEPROP *chan;
    AOCHANNEL *pchan;

    /*
     * install channels params into local member variables
     */
    for (int i=0; i<_nChannels; i++) 
    {	    
	_EngineChannelList->GetChannelStructLocal(i, &chan);
	if (chan==NULL) break;
	pchan=(AOCHANNEL*)chan;
	_chanList[i] = (short)chan->HwChan;
	_polarityList[i] =pchan->VoltRange[0] <0 ? BIPOLAR :UNIPOLAR;

	pchan->ConversionOffset=SetConversionOffset(_polarityList[i]);

        _defaultValues[i]=(pchan)->DefaultValue;
    }       
}

// SETCONVERSIONOFFSET: Use this function to set the data scaling (offset value)
int Cnid2a::SetConversionOffset(short polarity)
{
	if (GetDevCaps()->IsAODC())
	    return (1<<(GetDevCaps()->dacResolution-1));
	else
	    return (polarity==BIPOLAR? 0 : 1<<(GetDevCaps()->dacResolution-1));
}

void Cnid2a::SetAllPolarities(short polarity)
{
    NESTABLEPROP *chan;
    AOCHANNEL *pchan;
    for (int i=0; i<_nChannels; i++) 
    {	    
        _polarityList[i]=polarity;
	_EngineChannelList->GetChannelStructLocal(i, &chan);
	if (chan==NULL) break;
	pchan=(AOCHANNEL*)chan;
    }       
    if (polarity==UNIPOLAR)
    {
        pchan->VoltRange[0]= 0;
        pchan->VoltRange[1]= GetDevCaps()->dacUnipolarRange;
        pchan->ConversionOffset= SetConversionOffset(polarity);
            
	// native data type    
        _DaqHwInfo->put_MemberValue(CComBSTR(L"nativedatatype"), CComVariant(VT_UI2));	
    }
    else // BIPOLAR
    {
        pchan->VoltRange[0]= -GetDevCaps()->dacBipolarRange;
        pchan->VoltRange[1]= GetDevCaps()->dacBipolarRange;
        pchan->ConversionOffset=  SetConversionOffset(polarity);
       
	// native data type 
	if (GetDevCaps()->IsAODC())
		_DaqHwInfo->put_MemberValue(CComBSTR(L"nativedatatype"), CComVariant(VT_UI2));
	else
	    _DaqHwInfo->put_MemberValue(CComBSTR(L"nativedatatype"), CComVariant(VT_I2));	
    }

}

//
// Two possibilities for output range exist for NI hardware: 
// unipolar and bipolar. 
//

int Cnid2a::LoadOutputRanges()
{
    for (int i=0;i<_nChannels;i++)
    {
        DAQ_CHECK(AO_Configure(_id,_chanList[i],_polarityList[i],0,10,0));
    }
    _isConfig=true;
    return S_OK;
}

int Cnid2a::SetOutputRange( VARIANT *NewValue, short chan)
{
    if (V_VT(NewValue) == (VT_ARRAY | VT_R8))
    {	long uBound, lBound;	
	SAFEARRAY * psa = V_ARRAY(NewValue);
	double *pr;
	
	SafeArrayGetLBound (psa, 1, &lBound);
	SafeArrayGetUBound (psa, 1, &uBound);
	int size = uBound - lBound + 1;
	_ASSERT(size==2);
	if (size!=2) 
            return Error("Array must contain two elements.");
	
	HRESULT hr = SafeArrayAccessData (psa, (void **) &pr);
	if (FAILED (hr)) 
	{
	    SafeArrayDestroy (psa);
	    return E_SAFEARRAY_ERR;
	}	                    
	
	double inRangeLo = pr[0];
	double inRangeHi = pr[1];	
	
	if (inRangeHi <= inRangeLo)
	{
	    SafeArrayUnaccessData (psa);
	    return E_INVALID_CHAN_RANGE;
	}

	variant_t defaultVal;

	if (inRangeLo>=0 && (inRangeHi>0) && (GetDevCaps()->dacUnipolarRange!=0) )
	{	
	    pr[0] = _chanRange[0][chan]= 0;
	    pr[1] = _chanRange[1][chan]= GetDevCaps()->dacUnipolarRange;
            if (_polarityList[chan]!=UNIPOLAR && _nChannels>1)
            {
               _engine->WarningMessage(CComBSTR(L"All channels configured for UNIPOLAR output."));
               SetAllPolarities(UNIPOLAR);
            }
            SetOutputRangeDefault(UNIPOLAR);
	    _polarityList[chan]=UNIPOLAR;
	    // update the default value range
	    _defaultChannelValueIProp->SetRange(&CComVariant(0L),&CComVariant(GetDevCaps()->dacUnipolarRange));	    
	    // determine if the current value is out of range and warn if so.
	    // Since it will never be greater than the upper value, only
	    // the lower value needs checking.
	    CComQIPtr<IChannel, &__uuidof(IChannel)> pCont;
	    _EngineChannelList->GetChannelContainer(chan, __uuidof(IChannel),(void**)&pCont);
	    pCont->get_PropValue(__uuidof(_defaultChannelValueIProp),_defaultChannelValueIProp, &defaultVal);    
	    if ((long)defaultVal<0)
	    {
		HRESULT hr = _engine->WarningMessage(CComBSTR(L"DefaultValue for this channel is now out of range."));
		if (FAILED(hr)) return hr;
	    }
	}  
	else
	{
	    pr[0] = _chanRange[0][chan]= -GetDevCaps()->dacBipolarRange;
	    pr[1] = _chanRange[1][chan]= GetDevCaps()->dacBipolarRange;

            if (_polarityList[chan]!=BIPOLAR && _nChannels>1)
            {
               _engine->WarningMessage(CComBSTR(L"All channels configured for BIPOLAR output."));
               SetAllPolarities(BIPOLAR);
            }
	    _polarityList[chan]=BIPOLAR;
            SetOutputRangeDefault(BIPOLAR);
	    
	    // update the default value range
	    _defaultChannelValueIProp->SetRange(&CComVariant(-GetDevCaps()->dacBipolarRange),&CComVariant(GetDevCaps()->dacBipolarRange));

	    // determine if the current value is out of range and warn if so
	    // Since it will never be greater than the upper value, only
	    // the lower value needs checking.
	    CComQIPtr<IChannel, &__uuidof(IChannel)> pCont;
	    _EngineChannelList->GetChannelContainer(chan,__uuidof(pCont), (void**)&pCont);
	    pCont->get_PropValue(__uuidof(_defaultChannelValueIProp),_defaultChannelValueIProp, &defaultVal);    
	    if (fabs((double)defaultVal)>GetDevCaps()->dacBipolarRange)
	    {
		HRESULT hr = _engine->WarningMessage(CComBSTR(L"DefaultValue for this channel is now out of range."));
		if (FAILED(hr)) return hr;
	    }
	}       
	SafeArrayUnaccessData (psa);		
    }
    else 
    {
	return E_INVALID_CHAN_RANGE;
    }
    return DAQ_NO_ERROR;
}

/*
 * SetChannelProperty: This gets called by the engine whenever a channel property is set. 
 */
STDMETHODIMP Cnid2a::SetChannelProperty(long dwUser, NESTABLEPROP * pChan, VARIANT * NewValue)
{
    // prevent mulitple objects pointing to the same device to change
    // param values while the device is open        
    if (_Nid2aWnd->IsOpen(_id) && _Nid2aWnd->GetDevFromId(_id) !=this)
        return E_BAD_DEVICE;
  
    long numChans;
    short chan = static_cast<short>(((AICHANNEL*)pChan)->Nestable.Index-1);   // index is one-based
        
    _EngineChannelList->GetNumberOfChannels(&numChans);       

    if (numChans!=_nChannels)
    {
        _nChannels = numChans;        	
	SetupChannels();
    }
    
    _ASSERT(chan<_nChannels);
    _ASSERT(pChan!=NULL);
    _ASSERT(_chanList!=NULL);    



    if ( dwUser!=NULL) 
    {				
	switch (dwUser)
	{
	case HWCHAN:		    
	    _chanList[chan]=*(variant_t*)NewValue;
	    break;	      

        case OUTPUTRANGE:	    	    	
            {
                HRESULT hr = SetOutputRange( NewValue, chan);           
                if (FAILED(hr)) return hr;
                ((AOCHANNEL*)pChan)->ConversionOffset = SetConversionOffset(_polarityList[chan]);
            }
            break;
        case DEFAULT_VALUE:
            _defaultValues[chan] = *(variant_t*)NewValue;
            break;
        default:
	    return Error("Attempt to set invalid AO channel parameter.");            
	}
    }	  

    // dirty flag - something changed, so reconfigure
    _isConfig=false;
    RETURN_HRESULT(Configure());
    return S_OK;
}


// Single point method for DACs

STDMETHODIMP Cnid2a::PutSingleValues(VARIANT* values)
{              
        if (!_isConfig)
            DAQ_CHECK(LoadOutputRanges());
    
    if ( V_ISARRAY (values) || V_ISVECTOR (values))
    {
        SAFEARRAY *ps = V_ARRAY(values);
        if (ps==NULL) return E_SAFEARRAY_ERR;

        int status;
        short *voltArray;
    
        HRESULT hr = SafeArrayAccessData (ps, (void **) &voltArray);
        if (FAILED (hr)) 
        {
            return E_SAFEARRAY_ERR;
        }
    
        for (int i=0; i<_nChannels; i++) 
        {        	       
            status = AO_Write(_id, _chanList[i], voltArray[i]);                    
            if (status)
            {
                 SafeArrayUnaccessData (ps);
                 return status;
            }
        }       
    
        SafeArrayUnaccessData (ps);

    }
    else
        return E_SAFEARRAY_ERR;

    return S_OK;
}


STDMETHODIMP Cnid2a::TranslateError(VARIANT *eCode, VARIANT *retVal)
{    
   
    V_BSTR(retVal) = TranslateErrorCode(eCode->lVal).Detach();
    return S_OK;
}

STDMETHODIMP Cnid2a::GetStatus(hyper * samplesProcessed, BOOL * running)
{
    AUTO_LOCK;
    *running = _running;
    *samplesProcessed=_samplesOutput;

    return S_OK;
}

/*
 * Trigger setup
 */
int Cnid2a::TriggerSetup()
{  		
    if (GetDevCaps()->IsESeries()) 
    {    
        if ( !(_triggerType & TRIG_TRIGGER_IS_HARDWARE))
        {
            // Start immediately, no external trigger, possible external conversion
            //	
            return (
                ::Select_Signal(_id, 
                ND_OUT_START_TRIGGER, 
                ND_AUTOMATIC, 
                ND_LOW_TO_HIGH)
                );                                
        }
        else
        {
            if (_triggerType!=HW_DIGITAL)
                return E_INVALID_TRIG_SRC;
            
            return (
                ::Select_Signal(_id, 
                ND_OUT_START_TRIGGER, 
                ND_PFI_6, 
                ND_HIGH_TO_LOW)
                );                                
        }
    }
    else 
    {
        if (_triggerType==HW_DIGITAL)
            _engine->WarningMessage(CComBSTR(L"Hardware triggers not implemented for 1200 series devices."));
    }
    
    return(DAQ_NO_ERROR);
    
}


STDMETHODIMP Cnid2a::ChildChange(DWORD typeofchange, NESTABLEPROP *pChan)
{


    // prevent mulitple objects pointing to the same device to change
    // param values while the device is open        
    if (_Nid2aWnd->IsOpen(_id) && _Nid2aWnd->GetDevFromId(_id) !=this)
        return E_BAD_DEVICE;

    if (typeofchange & END_CHANGE)
       SetupChannels();     
    
    if (pChan && (typeofchange & CHILDCHANGE_REASON_MASK)== ADD_CHILD) 
    {
        int chan=pChan->Index-1;
	/*
	 * Infer default polarity from channel range
	 */
	if (_chanRange[0][chan]>=0 && _chanRange[1][chan]>=0)
	    _polarityList[chan]=UNIPOLAR;
	else
	    _polarityList[chan]=BIPOLAR;

        _isConfig = false;
        
        return S_OK;
    } 

    return S_OK;
}

HRESULT CDSAOutput::DeviceSpecificSetup()
{
    Cnid2a::DeviceSpecificSetup();
    CComPtr<IPropRoot> prop;
    RETURN_HRESULT(GetChannelProperty(L"ConversionExtraScaling", &prop));
    prop->put_DefaultValue(CComVariant(1.0/pow(2,32-GetDevCaps()->dacResolution)));
    return S_OK;
}

STDMETHODIMP CDSAOutput::SetProperty(long User, VARIANT *newVal)
{
   	
        variant_t *var = (variant_t*)newVal;	        
        
        // prevent mulitple objects pointing to the same device to change
        // param values while the device is open
        if (_Nid2aWnd->IsOpen(_id) && _Nid2aWnd->GetDevFromId(_id) !=this)
            return E_BAD_DEVICE;
	
        if (User==(long)&_sampleRate)
        {
            double newrate;
            DAQ_CHECK(WFM_Set_Clock(_id,_waveformGroup,0,*var,0,&newrate));
            *var=newrate;
        }
	
	// Now set the actual value if there is a User
        ((CLocalProp*)User)->SetLocal(*var);
        
	
	// dirty flag - something changed, so reconfigure
	_isConfig=false;	
	DAQ_CHECK(Configure());

    return S_OK;

}