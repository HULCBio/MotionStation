// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.6.4.7 $  $Date: 2004/01/16 19:58:33 $


// nia2d.cpp : Implementation of CMwdrvApp and DLL registration.

#include "stdafx.h"
#include "mwnidaq.h"
#include "nia2d.h"
#include "daqmex.h"
#include "daqtypes.h"
#include "errors.h"
#include  <math.h>
#include "messagew.h"

#include "nidaq.h"
#include "nidaqcns.h"
#include "nidaqerr.h"
#include "niutil.h"
#include <crtdbg.h>
#include <stdio.h>
//#include <stdlib.h>			// atoi
#include <memory.h>			// memset
#include <sarrayaccess.h>
#include <xutility>
#define AUTO_LOCK TAtlLock<Cnia2d> _lock(*this)



/////////////////////////////////////////////////////////////////////////////
//

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
int Cnia2d::SetXferMode()
{	
    if (!GetDevCaps()->IsDSA())
    {		
        int status = DAQ_NO_ERROR;
        
        bool warning=false;
        
        //int scanrate=_sampleRate*nChannels;
        //if (_xferMode==ND_INTERRUPTS && (scanrate<100 || (scanrate<1000 && samplesPerTrigger<32)))
        //    _xferMode=ND_INTERRUPTS;
        status = Set_DAQ_Device_Info(_id, ND_DATA_XFER_MODE_AI, _xferMode);
        
        
        /*
        * if the desired mode returns an error, use interrupts as a last resort
        */
        if (status) 
        {
            //        const wchar_t *errStr = daqTranslateErrorCode(status);
            
            warning=true;
            _xferMode=ND_INTERRUPTS;
            
            status=Set_DAQ_Device_Info(_id, ND_DATA_XFER_MODE_AI, ND_INTERRUPTS);		
        }
        
        return status ? status : warning;
    }
    else
        return DAQ_NO_ERROR;

}


// NI-DAQ Analog Input constructor
Cnia2d::Cnia2d() : 
_callTrigger(true),
_chanType(DIFFERENTIAL),
_clockSrc(INTERNAL), 
_chanList(NULL), 
_chanSkew(0),
_chanSkewMode(CHAN_SKEW_MIN),
_driveAIS(false),
_hWnd(NULL),
_isConfig(false),
_nMuxBrds(0),
_nSamples(1024), 
_running(false),
_sampleRate(1000),
_TargetSampleRate(1000), 
_startCalled(false),
_doneLatch(false),
_triggerChannelIndex(0),
_triggerCondition(TRIG_NONE),
_triggerConditionValue(&variant_t(0L)),
_triggerSrc(ND_THE_AI_CHANNEL),
_triggerType(TRIG_IMMEDIATE),
_triggerDelay(0),
_UseNSCANSCallback(true),
_xferMode(ND_UP_TO_1_DMA_CHANNEL)
{
}


Cnia2d::~Cnia2d()
{
    AUTO_LOCK;
    if (_running || (_Nia2dWnd && _Nia2dWnd->GetDevFromId(_id)==this))
    {
        Stop();
        _RPT0(_CRT_ERROR,"mwNIDAQ Sleeping because running device was deleted.");
        Sleep(200);
    }
     





}

STDMETHODIMP Cnia2d::Delete()
{
    DAQ_Clear(_id);
    return S_OK;
}

/*
 * Map double precision voltage values to integer values
 * which are used to set trigger limits. Mapping depends on 
 * polarity, gain, channel range, and adc resolution.
 */
long Cnia2d::MapVoltsToInt(double voltage)
{
    
   /* 
    * Gain adjustment
    */	
    double gain=1; 

    // if channels exist, we have a gain list, so use it.
    if ( _triggerSrc!=ND_PFI_0 && _triggerChannelIndex < static_cast<long>(_gainList.size()))
    {
        RANGE_INFO *TriggerRange;
        TriggerRange=FindRangeFromGainInt(_gainList[_triggerChannelIndex], _polarityList[_triggerChannelIndex]);
        if (TriggerRange)
            gain=TriggerRange->Gain;
    }
    
    double tmpVolts = voltage * gain;
    

    double loV,hiV;
    GetTriggerConditionValueRange(&loV,&hiV);
    

    if (_triggerSrc!=ND_PFI_0 && _nChannels>=1)
    {
        // retrieve the channel data struct from daqmex and calculate the units value
        // this should probably be an exported function
        
        /*
        * install channels params into local member variables
        */
#if 1
        AICHANNEL *aichan;
        _EngineChannelList->GetChannelStructLocal(_triggerChannelIndex, (NESTABLEPROP**)&aichan);
        double m=(aichan->SensorRange[1] -aichan->SensorRange[0])/(aichan->UnitRange[1]-aichan->UnitRange[0]);
        tmpVolts=tmpVolts*m + aichan->SensorRange[1]-m*aichan->UnitRange[1];
#else        
        CComPtr<IChannel> pChannel;
        //  _EngineChannelList->GetChannelContainer(_triggerChannelIndex,__uuidof(pChannel),reinterpret_cast<void**>(&pChannel));
        GetChannelContainer(_triggerChannelIndex,&pChannel);  // call the member function of CmwDevice instead of above code 
        CComVariant tempval;
        pChannel->UnitsToBinary(voltage,&tempval);
#endif

    }
   /*
    * Map the post amplified value to the proper range
    *  
    * legal range is 0 - 255 for all devices
    * except the 16 bit cards and DSA cards,
    * which is 0 - 4095. This mapping dependent on the polarity and 
    * trigger source.
    */  
    int MaxCode;
    int vv=0;

    if (GetDevCaps()->IsDSA())
    {
        MaxCode=(1<<(GetDevCaps()->adcResolution-1))-1;  // legal range is  -32768 to 32767 for 16 bit dsa 
        // current nidaq doc implies more then 16 bit dsa to come...
       // legal range is acutaly -32768 to 32767
        vv=static_cast<int>((tmpVolts/10)*(MaxCode+1));
        //geck G94506
        if (vv==0) vv=1;
    }
    else
    {
        bool is16bit = GetDevCaps()->adcResolution==16;
        MaxCode=is16bit ? 4096 : 256; // 16 bit boards have 4096 codes 12 have 256 codes
        vv=static_cast<int>((tmpVolts-loV)/(hiV-loV)*MaxCode);
    }
    /*
    * From the NI function reference manual: 
    * If you apply any of the formulas and get a value equal to 256, 
    * use the value 255 instead; if you get 4,096 with the 16-bit boards, 
    * use 4,095 instead.
    */
    if (vv>=MaxCode) vv=MaxCode-1;

    return vv;
}


/*
 * Trigger setup routines
 */


// AnalogTriggerSetup is called by TriggerSetup when needed
int Cnia2d::AnalogTriggerSetup(ConfigReason reason)  
{
    // Setup the hardware analog trigger to produce a trigger. Here we expect the
    // trigger source to be the analog input signal
    long triggergain=1;
    _ASSERTE(_triggerConditionValue.len);
    if (_triggerConditionValue.len==0) return S_OK;            
    
    if (_triggerType==HW_ANALOG_CHANNEL)
    {
        _triggerChannelIndex=0;
        // need to verify that the channel is index 1 (0 if 0 based) unless board is 611x 
        //trig = ND_THE_AI_CHANNEL;	 
        CComPtr<IProp> pProp;
        HRESULT hRes =GetProperty(L"TriggerChannel",&pProp);
        if (!(SUCCEEDED(hRes))) return hRes;
        variant_t var;
        
        pProp->get_Value(&var);
        if (var.vt==VT_EMPTY)
        {
            _triggerChannelIndex=0;
            if (!GetDevCaps()->scanning)
                _triggerSrc=0;
        }
        else
        {
            CComQIPtr<IPropContainer, &__uuidof(IPropContainer)>  pCont;
            pCont=var;
            var.Clear();
            
            hRes = pCont->get_MemberValue(L"hwchannel", &var);
            if (FAILED(hRes)) return hRes;
            _triggerChannelID=var;
            hRes = pCont->get_MemberValue(L"index", &var);
            if (FAILED(hRes)) return hRes;
            _triggerChannelIndex=var;
            _triggerChannelIndex--;
            if (GetDevCaps()->scanning)
            {
                if (_triggerChannelIndex>=1)
                    return E_INVALID_TRIG_CHANNEL;
            }
            else
            {
                _triggerSrc=_triggerChannelID;
            }
            
        }
        
    }
    
    switch (_triggerCondition)
    {
        // for these cases, one range value is used 
        // low value must be less than high value
    case ND_ABOVE_HIGH_LEVEL:
        {
            long trigHi = MapVoltsToInt(_triggerConditionValue[0]);
			double Lo,Hi;
			GetTriggerConditionValueRange(&Lo, &Hi);
			long trigLo = MapVoltsToInt(Lo);

            int status=Configure_HW_Analog_Trigger(_id, 
                ND_ON, // turn the trigger on
                trigLo,
                trigHi,
                _triggerCondition,
                _triggerSrc);
            
            if (status==-10003)
            {
                return E_TRIG_PARAM_ERR;
            }
            else
                DAQ_CHECK(status);
            
        }
        break;
        
    case ND_BELOW_LOW_LEVEL:	    	    
        {		    
            
            long trigLo = MapVoltsToInt(_triggerConditionValue[0]);   
			double Lo,Hi;
			GetTriggerConditionValueRange(&Lo, &Hi);
			long trigHi = MapVoltsToInt(Hi);
                      
            int status=Configure_HW_Analog_Trigger(_id, 
                ND_ON, // turn the trigger on
                trigLo,
                trigHi,  
                _triggerCondition,
                _triggerSrc);
            
            if (status==-10003)
            {
                return E_TRIG_PARAM_ERR;
            }
            else
                DAQ_CHECK(status);   	    				
        }
        break;	    
        
        
    case ND_INSIDE_REGION:
    case ND_LOW_HYSTERESIS:
    case ND_HIGH_HYSTERESIS:		
        {
            // here we require a 2 element but we need to allow the condition to 
            // be set without requiring the value be set first
            // If start is called and it's still not correct it's an error
            if (_startCalled && _triggerConditionValue.len!=2)
            {
                _startCalled=false;
                return E_INVALID_TRIG_VALUE;
            }
            else if (_triggerConditionValue.len!=2) 
            {
                _engine->WarningMessage(CComBSTR(L"A 2 element vector is expected for TriggerCondtionValue."));
                return S_OK;
            }
            
            int lo = MapVoltsToInt(_triggerConditionValue[0]);
            int hi = MapVoltsToInt(_triggerConditionValue[1]);
            
            if (lo>=hi) return E_INVALID_TRIG_VALUE;
            
            
            int status=Configure_HW_Analog_Trigger(_id, 
                ND_ON, // turn the trigger on
                lo,
                hi,
                _triggerCondition,
                _triggerSrc);
            
            if (status==-10003)
            {
                return E_TRIG_PARAM_ERR;
            }
            else
                DAQ_CHECK(status);
            
        }
        break;
    case TRIG_NONE:
        return S_OK;
    default:
        return E_INVALID_HW_TRIG_CONDITION;
        
    }
    return ::Select_Signal(_id, 
        ND_IN_START_TRIGGER,	// source
        ND_PFI_0,		// signal
        ND_LOW_TO_HIGH)	;	// source spec for this source
    
}

int Cnia2d::TriggerSetup(ConfigReason reason)
{  
    _ASSERTE(!GetDevCaps()->IsLab());
    
    if (_triggerType==HW_ANALOG_CHANNEL)
        _triggerSrc=ND_THE_AI_CHANNEL;
    else
        _triggerSrc=ND_PFI_0;
    
    if ( !(_triggerType & TRIG_TRIGGER_IS_HARDWARE))
    {
        
        // Start immediately, no external trigger, possible external conversion
        DAQ_CHECK(::Select_Signal(_id, 
            ND_IN_START_TRIGGER,	// source
            ND_AUTOMATIC,		// signal
            ND_DONT_CARE));
        
        return(DAQ_Config(_id,0,(short)_clockSrc));		
    }
    else
        switch (_triggerType) 
    {
        
        case HW_ANALOG_CHANNEL:
        case HW_ANALOG_PIN:
            DAQ_CHECK(AnalogTriggerSetup(reason));
            return(DAQ_Config(_id, 
                1,	// true when a trigger source exists 
                (short)_clockSrc)
                );
            
            
        case HW_DIGITAL:
            {	
                // This routine sets up the hardware for 
                // external start triggering and/or conversion	    	    
                DAQ_CHECK(
                    ::Select_Signal(_id, 
                    ND_IN_START_TRIGGER, 
                    pHwDigitalTriggerSource, 
                    ND_HIGH_TO_LOW)
                    );    
                return(DAQ_Config(_id, 
                    1,	// true when a trigger source exists 
                    (short)_clockSrc)
                    );
                
                break;
            } 
        default:
            return E_INVALID_TRIG_SRC;
            
    }

return(DAQ_NO_ERROR);

}

HRESULT CESeriesInput::SetClockSource(ConfigReason reason)
{
    if (_clockSrc & 1) // if external clocking
    {
        DAQ_CHECK(::Select_Signal(_id, ND_IN_CONVERT, pExternalSampleClockSource,ND_HIGH_TO_LOW));
    }
    else
    {
        DAQ_CHECK(::Select_Signal(_id, ND_IN_CONVERT, ND_INTERNAL_TIMER,ND_LOW_TO_HIGH));
    }
    if (_clockSrc & 2)
    {
        DAQ_CHECK(::Select_Signal(_id, ND_IN_SCAN_START, pExternalScanClockSource,ND_HIGH_TO_LOW));
    }
    else
    {
        DAQ_CHECK(::Select_Signal(_id, ND_IN_SCAN_START,ND_INTERNAL_TIMER, ND_LOW_TO_HIGH));
    }
    return S_OK;
}


HRESULT CESeriesInput::UpdateTimeing(ConfigReason reason)
{

    HRESULT Status = UpdateChannelSkew();    
	if (_nChannels>1)
    {
        // have had round off problems in the past
        if (_sampleRate*_nChannels>GetDevCaps()->maxAISampleRate*1.00000001 && GetDevCaps()->scanning)
        {
            // if the new rate is too fast restore the old rate
            return E_EXCEEDS_MAX_RATE;
        }
    }
    return Status;
}
// channel skew is dependent on sample rate


//
// Calculate channel skew for the desired SampleRate
// and hardware limits.
//
void CESeriesInput::CalculateInterval()
{
	// If only one channel, do not use scan rate and set channel skew value to 
	//		something (although not really applicable as there is at most 1 channel)
    if (_nChannels<2) 
    {
		// Set the scanInterval to 0
		_scanInterval = 0;

		// Calculate the new SampleInterval based on the requested SampleRate
		GetDevCaps()->FindRate(_sampleRate, &_sampleTB, &_sampleInterval);

    }
	// If more than one channel,
    else if (_nChannels >= 2) 
	{
		double ScanRate = GetTargetSampleRate(); // iNumChans;

		//Check to see if in Equisample mode
		if (_chanSkewMode == EQUISAMPLE)
		{
			// Do not use scan rate
			_scanInterval = 0;

			// Calculate the new SampleInterval even SampleRate across channels
			GetDevCaps()->FindRate(ScanRate * _nChannels, &_sampleTB, &_sampleInterval);
			
			// Update the channelskew value
			_chanSkew = (_sampleInterval * Timebase2ClockResolution(_sampleTB));

		}
		else
		{ // not equisampled, calculate scan/sample TB/Interval

			// Set the scanInterval to the Requested SampleRate
			// Set the SampleInterval to the fastest sample rate allowed
						
			// Calculate the new ScanInterval based on the requested SampleRate
			GetDevCaps()->FindRate(ScanRate, &_scanTB, &_scanInterval);
			
			if (_chanSkewMode == CHAN_SKEW_MIN)
			{
				// Calculate the new SampleInterval based on the fastest SampleRate available
				GetDevCaps()->FindRate(GetDevCaps()->maxAISampleRate, &_sampleTB, &_sampleInterval);
				
				// Update the channelskew value
				_chanSkew = (_sampleInterval * Timebase2ClockResolution(_sampleTB));
			}
			else if (_chanSkewMode == CHAN_SKEW_MANUAL)
			{ // Channel skew mode is manual, we know skew setting
				ScanRate = 1 / _chanSkew;

				// NTOE: Already know that rate/skew settings are valid

				// calculate Timebase/Interval for calculated rate
				GetDevCaps()->FindRate(ScanRate, &_sampleTB, &_sampleInterval);

			}

		}
	}
 
}

STDMETHODIMP Cnia2d::Start()
{
    int status=InternalStart();
    if (status)
    {
        Stop(); // just in case
        _startCalled=false;
    }
    return status;
}

STDMETHODIMP CESeriesInput::Trigger()
{
    //
    // Trigger the acquisition and start collecting data
    // 

    AUTO_LOCK;
    
    if (_nChannels==1) 
    {	

        // Use single channel asynchronous acquisition
        DAQ_CHECK(DAQ_Start(_id, _chanList[0], _gainList[0], _CircBuff.GetPtr(),
            _CircBuff.GetBufferSize(), _sampleTB, _sampleInterval));			
    } 
    else 
    {	        
        // Use multiple channel asynchronous acquisition
            DAQ_CHECK(SCAN_Start(_id, _CircBuff.GetPtr(),  _CircBuff.GetBufferSize(), _sampleTB, _sampleInterval,
                _scanTB, _scanInterval));        
    } 

    _running=true;
    _callTrigger=true;

    return S_OK;
}


STDMETHODIMP CDSAInput::Trigger()
{
    //
    // Trigger the acquisition and start collecting data
    // 

    AUTO_LOCK;
    double newrate;
    DAQ_CHECK(DAQ_Set_Clock(_id,0,_sampleRate,0,&newrate));
    
    if (_nChannels==1) 
    {	
         // Use single channel asynchronous acquisition
        DAQ_CHECK(DAQ_Start(_id, _chanList[0], _gainList[0], (short*)_CircBuff.GetPtr(),
            _CircBuff.GetBufferSize(), _scanTB, _scanInterval));			
    } 
    else 
    {	
        // Use multiple channel asynchronous acquisition
        DAQ_CHECK(SCAN_Start(_id, (short*)_CircBuff.GetPtr(),  _CircBuff.GetBufferSize(), _scanTB, _sampleInterval,
                _scanTB, _scanInterval));        
    } 

    _running=true;
    _callTrigger=true;

    return S_OK;
}

HRESULT Cnia2d::MakeMuxLists(short *ChanList,short *GainList,short &ScanChans)
{
    int MuxMult=_nMuxBrds*4;
    ScanChans=static_cast<short>(_nChannels/MuxMult);
    if (ScanChans*MuxMult!=_nChannels || ScanChans>16)
        return E_INVALIED_MUX_CHAN_SETUP;
    
    for (int i=0;i<ScanChans;i++)
    {
        ChanList[i]=_chanList[i*MuxMult];
        GainList[i]=_gainList[i*MuxMult];
    }
    return S_OK;
}

int Cnia2d::InternalStart()
{       
    AUTO_LOCK;
    long BufferSize;
    if (_Nia2dWnd->AddDev(_id,this))
    {
        return E_BAD_DEVICE;
    }
    
    _startCalled=true;
    if (!GetDevCaps()->IsDSA()) 
        DAQ_CHECK(AI_Clear(_id));
    RETURN_HRESULT(Configure(FORSTART));      
    DAQ_CHECK(SetXferMode());

    _samplesThisRun=0;
    _triggersProcessed=0;
    _doneLatch=false;
    _engine->GetBufferingConfig(&_nSamples,NULL);
   

        
    // allocate 4 times the number of samples requested since we're doing
    // double buffered acquisition
    
    BufferSize = _nChannels * _nSamples*4;
    if (BufferSize<8192)
    {
        BufferSize*=8192/BufferSize+1;
    }
    _samplesPerTrigger=0;

#if 1
    // this code is not yet working correctly for all buffers sizes (NI-DAQ bug?)
    long TotalPoints=_totalPointsToAcquire;
     // now check if we can accquire the whole run into one buffer
    if (TotalPoints>=8 
        || ( (_triggerType & TRIG_PRETRIGGER_DISABLED) && (_triggerType!=TRIG_IMMEDIATE) 
              &&  (_engineSamplesPerTrigger*_nChannels<= BufferSize )) )
    {
        if (_triggerType==TRIG_IMMEDIATE) // do repeates
        {
            _samplesPerTrigger=TotalPoints/_nChannels;
        }
        else
        {
            // total points is known however hw stops after trigger use spt
            _samplesPerTrigger=static_cast<long>(_engineSamplesPerTrigger+(_triggerDelayPoints/_nChannels));
        }

    
        if (_samplesPerTrigger*_nChannels >= (1<<16) && GetDevCaps()->IsLab())
        {   // lab cards have a burst size limit of 64K samples
            _samplesPerTrigger=0;
            _UseNSCANSCallback=true;
        }
        else
        {
            BufferSize=_samplesPerTrigger*_nChannels;
            if (_samplesPerTrigger >= _nSamples*2)
            {
                _UseNSCANSCallback=true;
                if (_samplesPerTrigger % _nSamples !=0)
                {
                    BufferSize=(_samplesPerTrigger/_nSamples+1)*_nSamples*_nChannels; // round up to next multiple
                }
            }
            else
            {
                _UseNSCANSCallback=false;
                //            if (_nSamples<BufferSize
            }
            
            // now do some checks to see if one buffer will work
            if ((BufferSize & 1) && (GetDevCaps()->HasMite))
                BufferSize+=1;
        }
        
    }
    else
        _UseNSCANSCallback=true;
#else
#pragma message("burst is disabled")
#endif
    if (_samplesPerTrigger==0)
    {
        //Enable double buffered mode
        DAQ_CHECK(DAQ_DB_Config(_id, 1));    
    }
    else
        DAQ_CHECK(DAQ_DB_Config(_id, 0));    

    _CrtCheckMemory( );
    InitBuffering(BufferSize);
    
    if (_xferMode==ND_INTERRUPTS && _nSamples)
    {
        int status;
        if (_nSamples*_nChannels <= static_cast<long>(GetDevCaps()->AIFifoSize/2) && _sampleRate*_nChannels< 2500 )
        {
            unsigned long value;
            status=Get_DAQ_Device_Info(_id,ND_AI_FIFO_INTERRUPTS,&value);
            if (status==0 && (value==ND_AUTOMATIC || value==ND_INTERRUPT_HALF_FIFO) )
            {
                status=Set_DAQ_Device_Info(_id,ND_AI_FIFO_INTERRUPTS,ND_INTERRUPT_EVERY_SAMPLE);
                if (status!=0)
                    _engine->WarningMessage(CComBSTR(L"NI-DAQ:Device could not be set to interrupt per sample."
                    L"Use BufferingConfig to manualy set buffer size."));
            }
            //DATA_XFER_MODE_AI,
        }
        else
            status=Set_DAQ_Device_Info(_id,ND_AI_FIFO_INTERRUPTS,ND_INTERRUPT_HALF_FIFO);

    }   

    /* 
     * Setup callbacks
     */ 
    char chanStr[8192];

    ChanList2Str( &_chanList[0], _nChannels, AI, chanStr);

    DAQ_CHECK(Config_DAQ_Event_Message(_id, ADD_MSG, 
        chanStr,
        NOTIFY_WHEN_DONE_OR_ERR,
        0L,0L,0L,0L,0L,0,WM_NOTIFY_WHEN_DONE_OR_ERR,(long)Callback));

    if (_UseNSCANSCallback)
    {
    DAQ_CHECK(Config_DAQ_Event_Message(_id, ADD_MSG, 
        chanStr,
        NOTIFY_AFTER_EACH_NSCANS,
        _nSamples,
        0,
        0L,
        0L,
        0L,
        0,
        WM_NOTIFY_AFTER_EACH_NSAMPS,
        (long)Callback));
    }
     // final setup of scan channels
    if (_nChannels!=1) 
    {	
        
        // Convert the scan rate to a timebase and scan interval
        // By convention, what NI calls scan rate we call sample rate,
        // The time elapsing between channels in a scan NI calls 
        // sample rate, we call it channel skew. 
        //        
        if (!GetDevCaps()->IsLab())
        {
            if (_nMuxBrds>0)
            {
                short ChanList[16],GainList[16];

                short chans;
                DAQ_CHECK(MakeMuxLists(ChanList,GainList,chans));
                DAQ_CHECK(SCAN_Setup(_id, chans, ChanList, GainList));	
            }
            else
                DAQ_CHECK(SCAN_Setup(_id, (short)_nChannels, &_chanList[0], &_gainList[0]));	
            
            // 1 is 1 uSec
        }
    } 


    return S_OK;
}

STDMETHODIMP Cnia2d::Stop()
{
    
    // Wait for running to clear
    if (!_startCalled)
        return S_OK;
#if 0   
    SHORT Stopped;
    u32 Retrieved;
    int loopcount=0;
    int status;
    if (_samplesPerTrigger>0 && _samplesThisRun>=_samplesPerTrigger)
    {
        // if the device stopped on its own and should tell us so
        do
        {
            Sleep(1);
            status=DAQ_Check(_id,&Stopped,&Retrieved);
            if (status!=0) Stopped=1;
        } while ((!Stopped || _running) && loopcount++<100);
        if (loopcount>=100)
        {
            DAQ_Clear(_id);
            _RPT1(_CRT_ERROR,"Looped too many times waiting for stoped callback loopcount is:%d \n",loopcount);
        }
    }
    else
    {
        status=DAQ_Check(_id,&Stopped,&Retrieved);
        DAQ_Clear(_id);
        status=DAQ_Check(_id,&Stopped,&Retrieved);
        while (status==0 && !Stopped && loopcount++<100)
        {
            ATLTRACE("Waiting for device to stop\n");
            Sleep(10);
            status=DAQ_Check(_id,&Stopped,&Retrieved);
        }
#ifdef _DEBUG
        if (status!=0 && status!=noTransferInProgError)
            _RPT1(_CRT_ERROR,"Unexpected error from NIDAQ %d\n",status); 
        if (loopcount>=100)
            _RPT1(_CRT_ERROR,"Looped too many times waiting for stop loopcount is:%d \n",loopcount);
#endif
    }
#endif
    AUTO_LOCK;
    
    DAQ_Clear(_id);  // on pci1200 this call is needed even though documented otherwise. DAC_Check should do this
    
    DAQ_DB_Config(_id, 0);
    // now restore the transfer mode
    Set_DAQ_Device_Info(_id, ND_DATA_XFER_MODE_AI, GetDevCaps()->transferModeAI);
    
    char chanStr[8192];
    
    ChanList2Str( &_chanList[0], _nChannels, AI, chanStr);
    
    DAQ_TRACE(Config_DAQ_Event_Message(_id, DEL_MSG, 
        chanStr,
        NOTIFY_WHEN_DONE_OR_ERR,
        0L,0L,0L,0L,0L,0,WM_NOTIFY_WHEN_DONE_OR_ERR,(long)Callback));
    if (_UseNSCANSCallback)
    {
        DAQ_TRACE(Config_DAQ_Event_Message(_id, DEL_MSG, 
            chanStr,
            NOTIFY_AFTER_EACH_NSCANS,
            _nSamples,
            0,
            0L,
            0L,
            0L,
            0,
            WM_NOTIFY_AFTER_EACH_NSAMPS,
            (long)Callback));
    }
    //ClearEventMessages(_id);
    
    // Set triggering mode back to initial state.
    DAQ_Config(_id, 0, 0);
    
    // Set PFI line back to initial state. 
    ::Select_Signal(_id, ND_IN_START_TRIGGER, ND_AUTOMATIC, ND_DONT_CARE);
    // clean up pending messages
    
    
#if 0
    MSG msg;
    while ( PeekMessage(&msg, _Nia2dWnd->GetHandle(), NULL, NULL,PM_REMOVE))
    {
        
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }
#endif
    
    _Nia2dWnd->DeleteDev(_id);
    
    _isConfig = false;
    _startCalled=false;
    _running=false;
    
    return S_OK;
}

void Cnia2d::ProcessSamples(int samples,bool Stopped)
{
    if (samples==0) 
        return;
    long points=samples*_nChannels;
    long status = 0;
//    if (_CircBuff.GetPtr()==NULL)
//    {
//        _RPT0(_CRT_ERROR,"NIDAQ Callback called when device buffer is NULL\n");
//        return;
//    }
    unsigned long newindex;
    short stopped;
    bool StopAcq=false; 
    //                status=DAQ_Check(DeviceId,&stopped,&retrieved);
    //_RPT3(_CRT_ERROR,"DaqCheck returned running=%d samples=%d status=%d\n",stopped,retrieved,status);
    //char errStr[80];
    //sprintf(errStr, "Data NOT ready count: %d\n", cnt);
    //OutputDebugString(errStr);
    BUFFER_ST *buf;
    status=GetEngine()->GetBuffer(0, &buf); // timeout should be empty
    if (buf==NULL) 
    {
        if (status==DE_NOT_RUNNING)
        {
            DAQ_Clear(_id);
            _running=false;
            Stop();
            GetEngine()->DaqEvent(EVENT_STOP, -1, _samplesThisRun, NULL);
        }
        else
        {
            ATLTRACE("Buffer from engine is NULL\n");	                                             
            GetEngine()->DaqEvent(EVENT_DATAMISSED, -1, _samplesThisRun,NULL);
        }
        return;
    }
    if (buf->ValidPoints<points)
    {
        // less then the availible points are needed
        // Note that in the event of trigger repeat this code will not be used because
        // the engine will not reduce validpoints.
        points=buf->ValidPoints;
        samples=points/_nChannels;

    }

    if (GetDevCaps()->Is1200() && GetDevCaps()->HasMite && _xferMode!=ND_INTERRUPTS)
    {
        // this is a bug fix for the pci 1200 and may be removed in the future if fixed by NI
        //pause 2 sample times...
        double t0,t1;
        GetEngine()->GetTime(&t0);
        do
        {
            if (_sampleRate<1000)
                Sleep(1);
            GetEngine()->GetTime(&t1);
        } while (t1-t0< 2.0/_sampleRate);
    }

    if (Stopped && !_UseNSCANSCallback)
    {
        buf->ValidPoints=points;
        
        CopyToBuffer(buf);
    }
    else
    {
        status = DAQ_Monitor (_id, -1, CONSECUTIVE_BUFFER, points, 
            (short*)buf->ptr, &newindex, &stopped);
        
        if (status==dataNotAvailError)
        {
            ATLTRACE("Nidaq dataNotAvailError sleeping\n");	                                             
            Sleep(100);
            status = DAQ_Monitor (_id, -1, CONSECUTIVE_BUFFER, points, 
                (short*)buf->ptr, &newindex, &stopped);
        }
        if (status)
        {
            
            samples=0;
            points=0;
            GetEngine()->DaqEvent(EVENT_ERR, 0, _samplesThisRun, TranslateErrorCode(status));
        }
    }
    //if (stopped)
    //{
    //ptsTfr=_samplesPerTrigger-SamplesThisRun();
    //if (newindex< _samplesPerTrigger )
    //      GetEngine()->DaqEvent(ERR, 0, SamplesThisRun(), L"Acquisiton stopped prematurely.");
    
    //Stop();
    
    //}
    //_CircBuff.CopyOut((short*)buf->ptr, ptsTfr);
    
    // ValidPoints must be setup here for the engine to 
    // correctly allocate the output array 
    buf->StartPoint=_samplesThisRun*_nChannels;
    _samplesThisRun+=samples;
    buf->ValidPoints=points;

    if (buf->Flags & BUFFER_IS_LAST)
    {
        StopAcq=true;
    }
    
    GetEngine()->PutBuffer(buf);
    // post a trigger event the first time we get the callback
    if (_callTrigger && (_triggerType==HW_ANALOG_CHANNEL || _triggerType==HW_ANALOG_PIN 
        || _triggerType==HW_DIGITAL))        
    {
        double time;             
        _callTrigger=false;
        GetEngine()->GetTime(&time);
        // is sampleRate the correct value here when multiple chans are sampled?
        double triggerTime = time - samples/_sampleRate;
        GetEngine()->DaqEvent(EVENT_TRIGGER, triggerTime,_samplesPerTrigger*_triggersProcessed , NULL);
    }
    if (StopAcq)
    {
        DAQ_Clear(_id);
        _running=false;
        Stop();
        _engine->DaqEvent(EVENT_STOP, -1, _samplesThisRun, NULL);
    }
}


void Cnia2d::Callback(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{

    // DeviceId is the device which is responsible for the callback
    short DeviceId = (wParam & 0x00FF);
    short doneFlag = (wParam & 0xFF00) >> 8;
    long scansDone = lParam;

//    MessageWindow* Window=(MessageWindow*)GetWindowLong(hWnd, GWL_USERDATA);
    //CLock lock(Window->_mutex);

    Cnia2d *ai = (Cnia2d*)_Nia2dWnd->GetDevFromId(DeviceId);	
    if (ai==NULL) 
    {
#ifdef _DEBUG
        switch (msg) 
        {
        case WM_NOTIFY_AFTER_NSAMPS:	
        case WM_NOTIFY_AFTER_EACH_NSAMPS:
            ATLTRACE("NIDAQ NOTIFY_AFTER_EACH_NSAMPS callback on device id %d after stopping\n",DeviceId); 
            break;
        case WM_NOTIFY_WHEN_DONE_OR_ERR:
            ATLTRACE("NIDAQ NOTIFY_WHEN_DONE_OR_ERR on device id %d after stopping\n",DeviceId); 
            break;
        default:
            ATLTRACE("NIDAQ callback on device id %d after stopping\n",DeviceId); 
        }
#endif        
        return;

    }
    ai->Lock();
    doneFlag=ai->_doneLatch ? true : doneFlag ; 
    switch (msg) {
        
    case WM_NOTIFY_AFTER_NSAMPS:	
    case WM_NOTIFY_AFTER_EACH_NSAMPS:
        if (!doneFlag || scansDone*ai->_nChannels<ai->GetBufferSizePoints())
        {
            ai->ProcessSamples(ai->_nSamples);
            break;
        }
        // fall through but we need to detect multiple calls for same run
    case WM_NOTIFY_WHEN_DONE_OR_ERR:
        if (doneFlag)
        {
            // _samples
            long totalsamples=static_cast<long>(ai->_samplesPerTrigger*(ai->_triggersProcessed+1)-ai->_samplesThisRun);
            if (totalsamples>0 && ai->_UseNSCANSCallback && !ai->_doneLatch)
            {
                ai->_doneLatch=true;
                break;
            }
            ai->_doneLatch=false;
            while (totalsamples>ai->_nSamples)
            {
                ai->ProcessSamples(ai->_nSamples,true);
                totalsamples-=ai->_nSamples;
            }
            if (totalsamples>0) ai->ProcessSamples(totalsamples,true);
            if (((TRIG_TRIGGER_IS_HARDWARE & ai->_triggerType)!=0) && ai->_triggersProcessed++<ai->_triggerRepeat)
            {
                DAQ_Clear(DeviceId);
                ai->Trigger();
            }
            else
            {
                ai->GetEngine()->DaqEvent(EVENT_STOP, -1, ai->_samplesThisRun, NULL);
                ai->Stop();
            }
            _RPT2(_CRT_WARN,"%d scans and %d triggers done\n", (long)ai->_samplesThisRun,ai->_triggersProcessed);
        }
        else
        {
            ai->GetEngine()->DaqEvent(EVENT_ERR, 0,ai->_samplesThisRun, L"Unexpected error from NI-DAQ. Device is still running");
            _RPT0(_CRT_ERROR,"Unknown error message posted\n");
        }
        ai->_running=false;
        break;
        
    default:
	break;

    }
    ai->Unlock();
}

HRESULT Cnia2d::Initialize()
{

    RANGE_INFO ri;
    if (!GetDevCaps()->HasAI()) 
        return E_AI_UNSUPPORTED;

    // build the range info
    ri.polarity=UNIPOLAR;
    ri.minVal=0;
    for ( int i=0;i<GetDevCaps()->numUnipolarGains;++i)
    {
        double gain=GetDevCaps()->unipolarGains[i];
        ri.maxVal=GetDevCaps()->unipolarRange/gain;
        ri.Gain=gain;
        ri.GainInt=GetDevCaps()->unipolarGainSettings[i];
        _validRanges.push_back(ri);
    }
        ri.polarity=BIPOLAR;

    for ( i=GetDevCaps()->numBipolarGains-1;i>=0;i--)
    {
        double gain=GetDevCaps()->bipolarGains[i];
        ri.maxVal=GetDevCaps()->bipolarRange/gain;
        ri.minVal=-ri.maxVal;
        ri.Gain=gain;
        ri.GainInt=GetDevCaps()->bipolarGainSettings[i];
        _validRanges.push_back(ri);
    }
    return S_OK;
	
}



HRESULT CDSAInput::Configure(ConfigReason reason)
{
    DAQ_CHECK(TriggerSetup(reason));
    _isConfig = true;

    return S_OK;

}


HRESULT CESeriesInput::Configure(ConfigReason reason)
{
/*
* Configure any AMUX-64T boards that are connected
    */
    if (_nChannels!=0) 
    {
        for (int i=0; i<_nChannels; i++) 
        {
            DAQ_CHECK(AI_Configure(_id, _chanList[i], GET_ADAPTOR_ENUM_VALUE(_chanType),
                0, _polarityList[i], _driveAIS));	
        }        
        
        // done with input range
    }    
    if (_nMuxBrds) 
    {
        DAQ_CHECK(AI_Mux_Config((short)_id, (short)_nMuxBrds));
        
        //If this is an AT-MIO-64E-3, call an additional configuration routine	 
        if (GetDevCaps()->nInputs==64) 
            DAQ_CHECK(MIO_Config(_id, 0, 1)) // no dither, useAMUX
    }

	// Double check the Scan/Sample Timebase/Interval
	CalculateInterval();

    if (_clockSrc & 1) // if external clocking
    {
        _sampleTB=0;
    }
    if (_clockSrc & 2)
    {
        _scanTB=0;
    }
    DAQ_CHECK(SetClockSource(reason));
    DAQ_CHECK(TriggerSetup(reason));
    
        
    
    // Clear any previously configured messages
    //    ClearEventMessages(_id);
    
    _isConfig = true;
    return S_OK;
    
}

int Cnia2d::SetInputRangeDefault()
{    
    int hRes;
    CComVariant val;    
    double range[2];
    double MaxVolts=GetDevCaps()->bipolarRange/GetDevCaps()->bipolarGains[0];
	CComVariant minVal(-MaxVolts);

	if (GetDevCaps()->unipolarGains) // this is primarily for 1200 series boards
	{
		MaxVolts=max(MaxVolts,GetDevCaps()->unipolarRange/GetDevCaps()->unipolarGains[0]);
	}
    CComVariant maxVal(MaxVolts);

    
    range[0]=-GetDevCaps()->bipolarRange;
    range[1]=GetDevCaps()->bipolarRange;

    
    CreateSafeVector(range,2,&val);
    CComPtr<IProp> prop;

    // Input range
    hRes =GetChannelProperty(L"InputRange", &prop);
    prop->put_User((long)INPUTRANGE);

    hRes = prop->put_DefaultValue(val);
    if (!SUCCEEDED(hRes)) return hRes;            


    prop->SetRange(&minVal,&maxVal);
    
    prop.Release();

    return S_OK;
}




// Trigger condition values are read-only until
// the trigger condition is set. The default
// value is an empty array
int Cnia2d::SetDefaultTriggerConditionValues()
{
    HRESULT hRes;
    // trigger condition value

    _triggerConditionValue.Attach(_EnginePropRoot,L"TriggerConditionValue");
    
    SAFEARRAY *ps = SafeArrayCreateVector(VT_R8, 0, 1);
    if (ps==NULL) E_SAFEARRAY_ERR;
    
    CComVariant val;

    // set the data type and values
    V_VT(&val)=VT_ARRAY | VT_R8;
    V_ARRAY(&val)=ps;
    
    double *range = NULL;
    
    hRes = SafeArrayAccessData (ps, (void **) &range);
    if (FAILED (hRes)) 
    {
        SafeArrayDestroy (ps);
        return E_SAFEARRAY_ERR;
    }

    range=0;
    
    hRes = _triggerConditionValue->put_Value(val);
    if (!SUCCEEDED(hRes)) 
    {
        SafeArrayUnaccessData (ps);
	return hRes;        
    }
    hRes = _triggerConditionValue->put_DefaultValue(val);
    if (!SUCCEEDED(hRes)) 
    {
        SafeArrayUnaccessData (ps);
	return hRes;        
    }
    hRes = _triggerConditionValue->SetRange(&CComVariant(0L),&CComVariant(0L));
    if (!SUCCEEDED(hRes)) 
    {
        SafeArrayUnaccessData (ps);
	return hRes;        
    }
    
    SafeArrayUnaccessData (ps);

    return S_OK;

}


int Cnia2d::SetDaqHwInfo()
{

    HRESULT hRes = _DaqHwInfo->put_MemberValue(CComBSTR(L"totalchannels"),CComVariant(GetDevCaps()->nInputs));
    if (!(SUCCEEDED(hRes))) return hRes;
    
    // subsystem type
    hRes = _DaqHwInfo->put_MemberValue(CComBSTR(L"subsystemtype"),CComVariant(L"AnalogInput"));
    if (!(SUCCEEDED(hRes))) return hRes;

    // autocal
//    hRes = _DaqHwInfo->put_MemberValue(CComBSTR(L"autocalibrate"),CComVariant(0L));
//    if (!(SUCCEEDED(hRes))) return hRes;
   
    // sampling type
    hRes = _DaqHwInfo->put_MemberValue(CComBSTR(L"sampletype"), GetDevCaps()->scanning ? CComVariant(0L) : CComVariant(1L));
    if (!(SUCCEEDED(hRes))) return hRes;

    // polarity
    if (GetDevCaps()->supportsUnipolar)
    {
        SAFEARRAY *ps = SafeArrayCreateVector(VT_BSTR, 0, 2);
        if (ps==NULL) E_SAFEARRAY_ERR;
        CComVariant val;
        
        // set the data type and values
        V_VT(&val)=VT_ARRAY | VT_BSTR;
        V_ARRAY(&val)=ps;
        CComBSTR *polarities;
        
        hRes = SafeArrayAccessData (ps, (void **) &polarities);
        if (FAILED (hRes)) 
        {
            SafeArrayDestroy (ps);
            return E_SAFEARRAY_ERR;
        }
        
        polarities[0]=L"Bipolar";
        polarities[1]=L"Unipolar";
        
        hRes = _DaqHwInfo->put_MemberValue(CComBSTR(L"polarity"), val);
        if (!(SUCCEEDED(hRes))) return hRes;
        
        SafeArrayUnaccessData (ps);
        val.Clear();    
    }
    else
    {
        hRes = _DaqHwInfo->put_MemberValue(L"polarity", CComVariant(L"Bipolar"));
        if (!(SUCCEEDED(hRes))) return hRes;
    }

    // minsamplerate
    hRes = _DaqHwInfo->put_MemberValue(L"minsamplerate", CComVariant(GetDevCaps()->minSampleRate));
    if (!(SUCCEEDED(hRes))) return hRes;
    
    // maxsamplerate
    hRes = _DaqHwInfo->put_MemberValue(L"maxsamplerate", CComVariant(GetDevCaps()->maxAISampleRate));
    if (!(SUCCEEDED(hRes))) return hRes;


    // number of bits        
    hRes = _DaqHwInfo->put_MemberValue(L"bits",CComVariant(GetDevCaps()->adcResolution));
    if (!(SUCCEEDED(hRes))) return hRes;       
    
    // native data type    
    if (GetDevCaps()->IsDSA())
    {
        hRes = _DaqHwInfo->put_MemberValue(L"nativedatatype", CComVariant(VT_I4));	
        if (!(SUCCEEDED(hRes))) return hRes;
    }
    else
    {
        hRes = _DaqHwInfo->put_MemberValue(L"nativedatatype", CComVariant(VT_I2));	
        if (!(SUCCEEDED(hRes))) return hRes;
    }
    // device Id
    wchar_t idStr[8];
    swprintf(idStr, L"%d", _id);
    hRes = _DaqHwInfo->put_MemberValue(L"id", CComVariant(idStr));	
    if (!(SUCCEEDED(hRes))) return hRes;

    // driver name
    hRes = _DaqHwInfo->put_MemberValue(L"adaptorname",CComVariant(L"nidaq"));
    if (!(SUCCEEDED(hRes))) return hRes;

    hRes = _DaqHwInfo->put_MemberValue(L"coupling", CComVariant(GetDevCaps()->GetCoupling()));
    if (!(SUCCEEDED(hRes))) return hRes;


    // supported gain values
    CComVariant val;

    short len=GetDevCaps()->numBipolarGains;    
 
    SAFEARRAY *ps = SafeArrayCreateVector(VT_R8, 0, len);
    if (ps==NULL) return E_SAFEARRAY_ERR;       

    // set the data type and values
    V_VT(&val)=VT_ARRAY | VT_R8;
    V_ARRAY(&val)=ps;
    
    double *gains;
    
    hRes = SafeArrayAccessData (ps, (void **) &gains);
    if (FAILED (hRes)) 
    {
        SafeArrayDestroy (ps);
        return E_SAFEARRAY_ERR;
    }

    for (int i=0;i<len;i++)
        gains[i]=GetDevCaps()->bipolarGains[i];      
    
    hRes = _DaqHwInfo->put_MemberValue(CComBSTR(L"gains"), val);
    if (!(SUCCEEDED(hRes))) return hRes;

    SafeArrayUnaccessData (ps);
    val.Clear();    
    

    CreateSafeVector(GetDevCaps()->SEInputIDs,GetDevCaps()->nSEInputIDs,&val);
    hRes = _DaqHwInfo->put_MemberValue(CComBSTR(L"singleendedids"), val);
    if (!(SUCCEEDED(hRes))) return hRes;

    CreateSafeVector(GetDevCaps()->DIInputIDs,GetDevCaps()->nDIInputIDs,&val);
    hRes = _DaqHwInfo->put_MemberValue(CComBSTR(L"differentialids"), val);
    if (!(SUCCEEDED(hRes))) return hRes;

    // input ranges  
    // this is a 2-d array of range values
    // there are unipolar and bipolar ranges 
    // both are len x 2, where len is the 
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

    
    len = GetDevCaps()->numUnipolarGains+GetDevCaps()->numBipolarGains;           

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
    for ( i=GetDevCaps()->numUnipolarGains-1;i>=0;i--)
    {
        *pl++=0;
        *ph++=GetDevCaps()->unipolarRange/GetDevCaps()->unipolarGains[i];
    }
    for ( i=GetDevCaps()->numBipolarGains-1;i>=0;i--)
    {
        *ph=GetDevCaps()->bipolarRange/GetDevCaps()->bipolarGains[i];
        *pl++=-*ph++;
    }

    V_VT(&val)=(VT_ARRAY | VT_R8);    
    V_ARRAY(&val)=ps;
    
    SafeArrayUnaccessData (ps);

    hRes = _DaqHwInfo->put_MemberValue(CComBSTR(L"inputranges"), val);
    if (!(SUCCEEDED(hRes))) return hRes;   
    val.Clear();    
        
    hRes = _DaqHwInfo->put_MemberValue(CComBSTR(L"vendordriverdescription"),
        CComVariant(L"National Instruments Data Acquisition Driver"));
    if (!(SUCCEEDED(hRes))) return hRes;    

    char version[16];
    GetDriverVersion(version);    
    hRes = _DaqHwInfo->put_MemberValue(CComBSTR(L"vendordriverversion"),CComVariant(version));
    if (!(SUCCEEDED(hRes))) return hRes;

    // device name   
    V_VT(&val) = VT_BSTR;
    val.bstrVal = CComBSTR(GetDevCaps()->deviceName).Detach();
    
    hRes = _DaqHwInfo->put_MemberValue(CComBSTR(L"devicename"), val);	    
    return hRes;
}


//
//	Open a device and initialize it
// 
MessageWindow* Cnia2d::_Nia2dWnd=NULL;

HRESULT Cnia2d::Open(IDaqEngine *engine,int id,DevCaps *DeviceCaps)
{
    
    static MessageWindow static_Nia2dWnd("mwnia2d");
    variant_t val;
    _Nia2dWnd=&static_Nia2dWnd;

   // _engine = engine;

    if (id<1) return E_INVALID_DEVICE_ID;
    // if we can't initialize here, go no further
    DAQ_CHECK(CniDisp::Open(id,DeviceCaps));

    // assign the engine access pointer
    CmwDevice::Open(engine);

    DAQ_CHECK(Initialize());


     // We need a window handle for the callback	
    _hWnd = _Nia2dWnd->GetHandle();
    if (!_hWnd) return E_HWND_FAIL;

    if (!GetDevCaps()->IsValid()) 
    {
	//return E_E_SERIES_ONLY;
        _engine->WarningMessage(CComBSTR(L"Hardware information not found in MWNIDAQ.INI. This device is not supported and has not been tested."));
    }
    HRESULT hRes = SetDaqHwInfo();
    if (FAILED(hRes)) return hRes;

    CComPtr<IProp> prop;    

    
    _ASSERT(_EnginePropRoot);

	// Configure SampleRate property
    _sampleRate.Attach(_EnginePropRoot,L"SampleRate");  
    _sampleRate->SetRange(&CComVariant(GetDevCaps()->minSampleRate), &CComVariant((long)GetDevCaps()->maxAISampleRate));
	GetDevCaps()->FindRate(GetTargetSampleRate(), &_scanTB, &_scanInterval);
	_sampleRate = 1 / (_scanInterval * Timebase2ClockResolution(_scanTB));

	// Configure ChannelSkew property
    _chanSkew.Attach(_EnginePropRoot,L"ChannelSkew");
    if (GetDevCaps()->scanning)
    {
		// determine minimum channel skew
		double minSkew = GetDevCaps()->settleTime*1.0e-6;

		// determine maximum channel skew
		double maxSkew = minSkew;
		
		// Get timebase for card at minimum sample rate
		GetDevCaps()->FindRate(GetDevCaps()->minSampleRate, &_scanTB, &_scanInterval);
		if ((GetDevCaps()->IsESeries()) && (_scanTB > 2)) 
		{
			// E-Series card can only have maximum skew of 10u sec * 2^16
			maxSkew = Timebase2ClockResolution(2) * 65535; // 2^16 bit 
		}
		else
		{
			// non E-Series card or  E-Series with a small Timebase
			maxSkew = Timebase2ClockResolution(_scanTB) * 65535; // 2^16 bit 
		}


		// Set channel skew range
        _chanSkew->SetRange(&CComVariant(minSkew),&CComVariant(maxSkew));

		// Set channel skew default (Minimum)
        _chanSkew.SetRemote(CComVariant(minSkew)); 
        _chanSkew->put_DefaultValue(CComVariant(minSkew));
		_chanSkew = minSkew;
    }


    // device specific properties
    
    _driveAIS.Create(_EnginePropRoot,L"DriveAISenseToGround");     
    
    _EnginePropRoot->CreateProperty(L"NumMuxBoards", &CComVariant(0L),  __uuidof(IProp),(void**) &prop);
    prop->put_User((long)&_nMuxBrds);
    if (GetDevCaps()->IsESeries())
        prop->SetRange(&CComVariant(0L), &CComVariant(4L));
    else
        prop->SetRange(&CComVariant(0L), &CComVariant(0L));
 
    prop.Release();  
        
    /*
     * enums
     */  
    _chanSkewMode.Attach(_EnginePropRoot,L"ChannelSkewMode");
    _chanSkewMode->ClearEnumValues();    
    if (GetDevCaps()->scanning)
    {
        _chanSkewMode->AddMappedEnumValue(EQUISAMPLE, L"Equisample");
        _chanSkewMode->AddMappedEnumValue(CHAN_SKEW_MANUAL, L"Manual");    
        _chanSkewMode->AddMappedEnumValue(CHAN_SKEW_MIN, L"Minimum");       
        _chanSkewMode=CHAN_SKEW_MIN;
        _chanSkewMode->put_DefaultValue(CComVariant(CHAN_SKEW_MIN));    
    }
    else
    {
        _chanSkewMode->AddMappedEnumValue(CHAN_SKEW_NONE, L"None");    
        _chanSkewMode->put_DefaultValue(CComVariant(CHAN_SKEW_NONE));  
        _chanSkewMode=CHAN_SKEW_NONE;
    }



    // clockSource: this exists, but we need to modify the enum list
    hRes=GetProperty(L"ClockSource",&prop);
    if (FAILED(hRes)) return hRes;
    prop->put_User((DWORD)&_clockSrc);
    if (!(GetDevCaps()->IsDSA() || GetDevCaps()->Is700()) ) 
    {
		// Add ExternalScanCtrl option to clock source
        prop->AddMappedEnumValue(EXT_SCAN_CTRL, L"ExternalScanCtrl");

		// Define ExternalScanClockSource property
		CREATE_PROP(ExternalScanClockSource);
		ATTACH_PROP(ExternalScanClockSource);
		pExternalScanClockSource->AddMappedEnumValue(ND_PFI_0, CComBSTR(L"PFI0")); // Add enumarated values
		pExternalScanClockSource->AddMappedEnumValue(ND_PFI_1, CComBSTR(L"PFI1")); // Add enumarated values
		pExternalScanClockSource->AddMappedEnumValue(ND_PFI_2, CComBSTR(L"PFI2")); // Add enumarated values
		pExternalScanClockSource->AddMappedEnumValue(ND_PFI_3, CComBSTR(L"PFI3")); // Add enumarated values
		pExternalScanClockSource->AddMappedEnumValue(ND_PFI_4, CComBSTR(L"PFI4")); // Add enumarated values
		pExternalScanClockSource->AddMappedEnumValue(ND_PFI_5, CComBSTR(L"PFI5")); // Add enumarated values
		pExternalScanClockSource->AddMappedEnumValue(ND_PFI_6, CComBSTR(L"PFI6")); // Add enumarated values
		pExternalScanClockSource->AddMappedEnumValue(ND_PFI_7, CComBSTR(L"PFI7")); // Add enumarated values
		pExternalScanClockSource->AddMappedEnumValue(ND_PFI_8, CComBSTR(L"PFI8")); // Add enumarated values
		pExternalScanClockSource->AddMappedEnumValue(ND_PFI_9, CComBSTR(L"PFI9")); // Add enumarated values
		pExternalScanClockSource->AddMappedEnumValue(ND_RTSI_0, CComBSTR(L"RTSI0")); // Add enumarated values
		pExternalScanClockSource->AddMappedEnumValue(ND_RTSI_1, CComBSTR(L"RTSI1")); // Add enumarated values
		pExternalScanClockSource->AddMappedEnumValue(ND_RTSI_2, CComBSTR(L"RTSI2")); // Add enumarated values
		pExternalScanClockSource->AddMappedEnumValue(ND_RTSI_3, CComBSTR(L"RTSI3")); // Add enumarated values
		pExternalScanClockSource->AddMappedEnumValue(ND_RTSI_4, CComBSTR(L"RTSI4")); // Add enumarated values
		pExternalScanClockSource->AddMappedEnumValue(ND_RTSI_5, CComBSTR(L"RTSI5")); // Add enumarated values
		pExternalScanClockSource->AddMappedEnumValue(ND_RTSI_6, CComBSTR(L"RTSI6")); // Add enumarated values
		pExternalScanClockSource.SetDefaultValue(CComVariant(ND_PFI_7)); // Set default value
		pExternalScanClockSource = ND_PFI_7; // Set current value
//		pExternalScanClockSource.SetDefaultValue(CComVariant(ND_INTERNAL_TIMER)); // Set default value
//		pExternalScanClockSource = ND_INTERNAL_TIMER; // Set current value
		pExternalScanClockSource->put_IsReadonlyRunning(true);
		pExternalScanClockSource->put_IsReadOnly(false);
    }
    if (GetDevCaps()->scanning)
    {
        prop->AddMappedEnumValue(EXT_SAMPLE_CTRL, L"ExternalSampleCtrl");
        if (! GetDevCaps()->Is700()) 
            prop->AddMappedEnumValue(EXT_SAMPLE_AND_SCAN_CTRL, L"ExternalSampleAndScanCtrl");

		// Define ExternalSampleClockSource property
		CREATE_PROP(ExternalSampleClockSource);
		ATTACH_PROP(ExternalSampleClockSource);
		pExternalSampleClockSource->AddMappedEnumValue(ND_PFI_0, CComBSTR(L"PFI0")); // Add enumarated values
		pExternalSampleClockSource->AddMappedEnumValue(ND_PFI_1, CComBSTR(L"PFI1")); // Add enumarated values
		pExternalSampleClockSource->AddMappedEnumValue(ND_PFI_2, CComBSTR(L"PFI2")); // Add enumarated values
		pExternalSampleClockSource->AddMappedEnumValue(ND_PFI_3, CComBSTR(L"PFI3")); // Add enumarated values
		pExternalSampleClockSource->AddMappedEnumValue(ND_PFI_4, CComBSTR(L"PFI4")); // Add enumarated values
		pExternalSampleClockSource->AddMappedEnumValue(ND_PFI_5, CComBSTR(L"PFI5")); // Add enumarated values
		pExternalSampleClockSource->AddMappedEnumValue(ND_PFI_6, CComBSTR(L"PFI6")); // Add enumarated values
		pExternalSampleClockSource->AddMappedEnumValue(ND_PFI_7, CComBSTR(L"PFI7")); // Add enumarated values
		pExternalSampleClockSource->AddMappedEnumValue(ND_PFI_8, CComBSTR(L"PFI8")); // Add enumarated values
		pExternalSampleClockSource->AddMappedEnumValue(ND_PFI_9, CComBSTR(L"PFI9")); // Add enumarated values
		pExternalSampleClockSource->AddMappedEnumValue(ND_RTSI_0, CComBSTR(L"RTSI0")); // Add enumarated values
		pExternalSampleClockSource->AddMappedEnumValue(ND_RTSI_1, CComBSTR(L"RTSI1")); // Add enumarated values
		pExternalSampleClockSource->AddMappedEnumValue(ND_RTSI_2, CComBSTR(L"RTSI2")); // Add enumarated values
		pExternalSampleClockSource->AddMappedEnumValue(ND_RTSI_3, CComBSTR(L"RTSI3")); // Add enumarated values
		pExternalSampleClockSource->AddMappedEnumValue(ND_RTSI_4, CComBSTR(L"RTSI4")); // Add enumarated values
		pExternalSampleClockSource->AddMappedEnumValue(ND_RTSI_5, CComBSTR(L"RTSI5")); // Add enumarated values
		pExternalSampleClockSource->AddMappedEnumValue(ND_RTSI_6, CComBSTR(L"RTSI6")); // Add enumarated values
		pExternalSampleClockSource.SetDefaultValue(CComVariant(ND_PFI_2)); // Set default value
		pExternalSampleClockSource = ND_PFI_2; // Set current value
		pExternalSampleClockSource->put_IsReadonlyRunning(true);
		pExternalSampleClockSource->put_IsReadOnly(false);
	}
    prop.Release();

    // inputType (channel type)
    _EnginePropRoot->CreateProperty(L"InputType", NULL, __uuidof(IProp),(void**) &prop);    
    prop->AddMappedEnumValue(DIFFERENTIAL, L"Differential");
    // simultaneous sampling hardware has only DI mode
    if (GetDevCaps()->scanning)  
    {
        prop->AddMappedEnumValue(REF_SINGLE_ENDED, L"SingleEnded");
        prop->AddMappedEnumValue(NON_REF_SINGLE_ENDED, L"NonReferencedSingleEnded");
    }
    prop->put_DefaultValue(CComVariant(DIFFERENTIAL));
    prop->put_Value(CComVariant(DIFFERENTIAL));
    prop->put_User((long)&_chanType);
    prop.Release();
    
    bool single_dma_sup=true;
    bool dual_dma_sup=true;

    // transfer mode    
        _EnginePropRoot->CreateProperty(L"TransferMode", NULL, __uuidof(IProp),(void**) &prop);
        prop->put_User((long)&_xferMode);
    if (GetDevCaps()->IsDSA())
    {
            prop->AddMappedEnumValue(ND_UP_TO_1_DMA_CHANNEL, L"SingleDMA");
    }
    else
    {
        int status=Set_DAQ_Device_Info(_id, ND_DATA_XFER_MODE_AI, ND_UP_TO_2_DMA_CHANNELS);
        if (status) 
            dual_dma_sup=false;
        
        if (Set_DAQ_Device_Info(_id, ND_DATA_XFER_MODE_AI, ND_UP_TO_1_DMA_CHANNEL))
            single_dma_sup=false;
       // only the at-mio-16e-1 supports dual dma.
        
        // now restore the transfer mode
        Set_DAQ_Device_Info(_id, ND_DATA_XFER_MODE_AI, GetDevCaps()->transferModeAI);
        
        prop->AddMappedEnumValue(ND_INTERRUPTS, L"Interrupts");
        if (single_dma_sup) 
        {
            prop->AddMappedEnumValue(ND_UP_TO_1_DMA_CHANNEL, L"SingleDMA");
        }
        
        if (dual_dma_sup)
            prop->AddMappedEnumValue(ND_UP_TO_2_DMA_CHANNELS, L"DualDMA");
    }
    prop->put_DefaultValue(CComVariant((long)GetDevCaps()->transferModeAI));
    prop->put_Value(CComVariant((long)GetDevCaps()->transferModeAI));
    _xferMode=(int)GetDevCaps()->transferModeAI;
    prop.Release();
     
    // trigger channel
//    RegisterProperty(L"TriggerChannel", (DWORD)&_triggerChannel);
    _engineSamplesPerTrigger.Attach(_EnginePropRoot,L"SamplesPerTrigger",USER_VAL(_engineSamplesPerTrigger));

    // trigger condition
    _triggerCondition.Attach(_EnginePropRoot,L"TriggerCondition");
    _triggerDelay.Attach(_EnginePropRoot,L"TriggerDelay",USER_VAL(_triggerDelay));
    _triggerDelayPoints.Attach(_EnginePropRoot,L"TriggerDelayPoints");
    _totalPointsToAcquire.Attach(_EnginePropRoot,L"TotalPointsToAcquire");
    RegisterProperty(L"TriggerRepeat",_triggerRepeat);

    prop=_triggerType.Attach(_EnginePropRoot,L"TriggerType",USER_VAL(_triggerType));
    // trigger type
    if (GetDevCaps()->digitalTrig)
    {
        prop->AddMappedEnumValue(HW_DIGITAL,  L"HwDigital");

		// Define DigitalTriggerSource property
		CREATE_PROP(HwDigitalTriggerSource);
		ATTACH_PROP(HwDigitalTriggerSource);
		pHwDigitalTriggerSource->AddMappedEnumValue(ND_PFI_0, CComBSTR(L"PFI0")); // Add enumarated values
		pHwDigitalTriggerSource->AddMappedEnumValue(ND_PFI_1, CComBSTR(L"PFI1")); // Add enumarated values
		pHwDigitalTriggerSource->AddMappedEnumValue(ND_PFI_2, CComBSTR(L"PFI2")); // Add enumarated values
		pHwDigitalTriggerSource->AddMappedEnumValue(ND_PFI_3, CComBSTR(L"PFI3")); // Add enumarated values
		pHwDigitalTriggerSource->AddMappedEnumValue(ND_PFI_4, CComBSTR(L"PFI4")); // Add enumarated values
		pHwDigitalTriggerSource->AddMappedEnumValue(ND_PFI_5, CComBSTR(L"PFI5")); // Add enumarated values
		pHwDigitalTriggerSource->AddMappedEnumValue(ND_PFI_6, CComBSTR(L"PFI6")); // Add enumarated values
		pHwDigitalTriggerSource->AddMappedEnumValue(ND_PFI_7, CComBSTR(L"PFI7")); // Add enumarated values
		pHwDigitalTriggerSource->AddMappedEnumValue(ND_PFI_8, CComBSTR(L"PFI8")); // Add enumarated values
		pHwDigitalTriggerSource->AddMappedEnumValue(ND_PFI_9, CComBSTR(L"PFI9")); // Add enumarated values
		pHwDigitalTriggerSource->AddMappedEnumValue(ND_RTSI_0, CComBSTR(L"RTSI0")); // Add enumarated values
		pHwDigitalTriggerSource->AddMappedEnumValue(ND_RTSI_1, CComBSTR(L"RTSI1")); // Add enumarated values
		pHwDigitalTriggerSource->AddMappedEnumValue(ND_RTSI_2, CComBSTR(L"RTSI2")); // Add enumarated values
		pHwDigitalTriggerSource->AddMappedEnumValue(ND_RTSI_3, CComBSTR(L"RTSI3")); // Add enumarated values
		pHwDigitalTriggerSource->AddMappedEnumValue(ND_RTSI_4, CComBSTR(L"RTSI4")); // Add enumarated values
		pHwDigitalTriggerSource->AddMappedEnumValue(ND_RTSI_5, CComBSTR(L"RTSI5")); // Add enumarated values
		pHwDigitalTriggerSource->AddMappedEnumValue(ND_RTSI_6, CComBSTR(L"RTSI6")); // Add enumarated values
		pHwDigitalTriggerSource.SetDefaultValue(CComVariant(ND_PFI_0)); // Set default value
		pHwDigitalTriggerSource = ND_PFI_0; // Set current value
		pHwDigitalTriggerSource->put_IsReadonlyRunning(true);
		pHwDigitalTriggerSource->put_IsReadOnly(false);

    }

    if (GetDevCaps()->analogTrig)
    {
        prop->AddMappedEnumValue(HW_ANALOG_CHANNEL, L"HwAnalogChannel");
        if (!GetDevCaps()->IsDSA())
            prop->AddMappedEnumValue(HW_ANALOG_PIN, L"HwAnalogPin");        
    }
    prop.Release();
   
    // trigger condition value
    hRes = SetDefaultTriggerConditionValues();
    if (FAILED(hRes)) return hRes;

    // channel props    
    
    if (GetDevCaps()->SupportsCoupling())
    {
        CComPtr<IDaqMappedEnum> prop;
        CComVariant var;
        CreateChannelProperty(L"Coupling",NULL,&prop);
        prop->put_User(COUPLING);
        prop->AddMappedEnumValue(ND_AC,L"AC");
        prop->AddMappedEnumValue(ND_DC,L"DC");
        if (GetDevCaps()->IsDSA())
            prop->put_DefaultValue(CComVariant(ND_AC));
        else
            prop->put_DefaultValue(CComVariant(ND_DC));
        
    }

    hRes=GetChannelProperty(L"HwChannel", &prop);
    if (FAILED(hRes)) return hRes;
    prop->put_User((long)HWCHAN);
    

    //
    // If the board is 16 channels, only the first 8 are usable
    // in DI mode. Larger channel count boards have the channels
    // interleaved in banks of 8, so a 64 channel board supports
    // 0:7, 16:23, 32:39, 48:55 since the other channels are returns.

    long idMax;
    if (GetDevCaps()->nInputs==16)           // DI mode is default
        idMax=GetDevCaps()->nInputs/2-1;    
    else
        idMax=GetDevCaps()->nInputs-1;

    prop->SetRange(&CComVariant(0L),&CComVariant(idMax));
    prop.Release();
    
    
    hRes = SetInputRangeDefault();
    if (!(SUCCEEDED(hRes))) return hRes;   
    
    ATLTRACE("Initialization complete\n");    
        
    return S_OK;
}

HRESULT CDSAInput::Open(IDaqEngine *engine,int id,DevCaps* DeviceCaps)
{
    RETURN_HRESULT(Cnia2d::Open(engine, id,DeviceCaps));
    CComPtr<IPropRoot> prop;
    RETURN_HRESULT(GetChannelProperty(L"ConversionExtraScaling", &prop));
    prop->put_DefaultValue(CComVariant(1.0/pow(2,32-GetDevCaps()->adcResolution)));
    return S_OK;
}

#define ALL_CHANNELS (-1)
//#pragma message ("Peekdata is disabled")
STDMETHODIMP Cnia2d::PeekData(BUFFER_ST *buffer)
{

    unsigned long newestPtIndex;
    short isStopped;	
    int status;
    if (buffer==NULL)
        return S_OK; // return E_NOTIMPL or S_OK tells the engine that PeekData is supported
    AUTO_LOCK;
    
    /* 
     * NOTE: To change MOST_RECENT_BUFFER to CONSECUTIVE_BUFFER to return consecutive
     * data instead of the most recently available.
     */
    
    status = DAQ_Monitor (_id, ALL_CHANNELS, MOST_RECENT_BUFFER, buffer->ValidPoints, 
	    (short*)buffer->ptr, &newestPtIndex, &isStopped);										

    
    if (status!=DAQ_NO_ERROR) 
    {					
	buffer->ValidPoints=0;
	return(status);
    }						

    // Since we didn't error out, we have the data asked for
    //buffer->ValidPoints = buffer->Size/2;

    return S_OK;
}

int Cnia2d::ReallocCGLists()
{

    long numChans;                    

    _EngineChannelList->GetNumberOfChannels(&numChans);

    _nChannels=numChans;


    if (_nChannels==0) 
    {
        return DAQ_NO_ERROR;
    }

    _chanList.resize(_nChannels,-1); // make illigal to force initialization in setup channels
    
    _gainList.resize(_nChannels,0);

    _polarityList.resize(_nChannels,BIPOLAR);

    return DAQ_NO_ERROR;
}

int Cnia2d::GetTriggerConditionValueRange(double *lowVal, double *hiVal)
{

    // if no channels have been added yet, polarity list
    // is null, so default to BIPOLAR operation
    switch (_triggerSrc)
    {
    case ND_PFI_0:
	*lowVal = -10;
	*hiVal = 10;	
	break;
    case ND_THE_AI_CHANNEL:
        _ASSERTE(_triggerChannelIndex==0);
        _triggerChannelIndex=0;
    default:    
        // assume bipolar triggering if no channel for triggerchannelindex
        if ( static_cast<long>(_polarityList.size()) <= _triggerChannelIndex || _polarityList[_triggerChannelIndex]==BIPOLAR)
	{
                *lowVal = -GetDevCaps()->bipolarRange;
	        *hiVal  = GetDevCaps()->bipolarRange;
	} 
	else
	{
                *lowVal = 0;
	        *hiVal  = GetDevCaps()->unipolarRange;

	}
	
	break;
    }

    return 0;
}

// The channel skew mode determines how to choose channel skew.
// There a 4 modes: min, equisamples, none, and manual. For min 
// calculate the minimum delay between samples using the
// device specific settling times. For equisample, setting
// the scan interval to zero causes the time that elapses
// between scan sequences and the time between A/D conversions
// are both equal to the sample interval, which becomes the 
// calculated scan interval required to achieve the desired 
// sample rate.
//
// Channel skew of none means we support simultaneous sampling
// so do nothing???
int CESeriesInput::UpdateChannelSkew()
{    
        
        switch (_chanSkewMode)
        {	
        case CHAN_SKEW_MIN:              
        case EQUISAMPLE:
            {
                CalculateInterval();
            }
            break;

        case CHAN_SKEW_MANUAL:
			// need to determine if ChannelSkew is a valid setting
			{
				// Check to see what SampleRate is selected
				double  tAdjustedSampleRate;
				short tempTB;
				unsigned short tempInterval;

				double tSampleRate = 1/_chanSkew;

				// Check to see if requested ChannelSkew 'fits' into sample rate given number of channels
				if ((_nChannels * _chanSkew) > (1/_sampleRate))
					return E_INVALID_CHANSKEW;

				GetDevCaps()->FindRate(tSampleRate, &tempTB, &tempInterval);
				
				tAdjustedSampleRate = 1/(tempInterval * Timebase2ClockResolution(tempTB));

				// Check to see if calculated sample rate is as requested
				if (tSampleRate != tAdjustedSampleRate)
				{
					// ChannelSkew needs to be adjusted to fall on valid sample rate									
					// Calculate the new SampleInterval based on the closest SampleRate available
					GetDevCaps()->FindRate(tAdjustedSampleRate, &_sampleTB, &_sampleInterval);
					
					// Update the channelskew value
					_chanSkew = (_sampleInterval * Timebase2ClockResolution(_sampleTB));

				}
			}
            
            break;
        
		case CHAN_SKEW_NONE:
			// SSH
			break;
			
        default:
            break;
        }
    
    return S_OK;
}



STDMETHODIMP Cnia2d::SetProperty(long User, VARIANT *newVal)
{

    HRESULT hr;

    // prevent mulitple objects pointing to the same device to change
    // param values while the device is open    
    if (_Nia2dWnd->IsOpen(_id) && _Nia2dWnd->GetDevFromId(_id) !=this)
        return E_BAD_DEVICE;

        variant_t *var = (variant_t*)newVal;
       
        // calculate the actual value used by the hardware        
        if (User==(long)&_sampleRate)
        {
			double requestedSampleRate = *var;
			double calculatedSampleRate;
			short tempTB;
			unsigned short tempInterval;

			// Calculate new timebase/interval from requested samplerate
			GetDevCaps()->FindRate(requestedSampleRate, &tempTB, &tempInterval);

			// verify that the sample rate is valid
			calculatedSampleRate = 1 / (tempInterval * Timebase2ClockResolution(tempTB));

			_sampleRate.SetLocal(requestedSampleRate);

			// Check to see if SampleRate needs to be modified based on timebase/interval information
			if (calculatedSampleRate != requestedSampleRate)
			{
				// Update Sample Rate to valid value
				_sampleRate.SetLocal(calculatedSampleRate);
	
			}

			// Updated target samplerate
            _TargetSampleRate=calculatedSampleRate;

            RETURN_HRESULT(UpdateTimeing(FORSET));
            *var=_sampleRate;

            return S_OK;
        }
/*
        else if (User==(long)&_triggerChannel)
        {
            // can not do here because trigger channel is not set and var contains an mxArray
            return S_OK;

            CComPtr<IProp> pProp;
            HRESULT hRes =GetChannelProperty(L"TriggerChannel",&pProp);
            if (!(SUCCEEDED(hRes))) return hRes;
            variant_t var;
            
            pProp->get_Value(&var);
            
            CComQIPtr<IPropContainer, &__uuidof(IPropContainer)>  pCont;
            pCont=var;
            var.Clear();
            
            hRes = pCont->get_MemberValue(L"HwChannel", &var);
            if (FAILED(hRes)) return hRes;
            _triggerChannel=var;
            
        }     
*/
        // the triggercondition sets the valid triggerconditonvalues

        else if (User==(long)&_triggerCondition)
        {
            double lo, hi;
            
            if ((long)*var==TRIG_NONE)
                return S_OK;            
            
            CComPtr<IProp> pProp;
			hr =GetProperty(L"TriggerConditionValue", &pProp);
            if (FAILED(hr)) return hr;	                           
            
            if (GetTriggerConditionValueRange(&lo, &hi))
                return E_INVALID_TRIG_SRC;
            
            pProp->SetRange(&CComVariant(lo), &CComVariant(hi));	    
            
        }	
        else if (User==(long)&_chanSkew)
        {
            if (_chanSkewMode!=CHAN_SKEW_MANUAL)
            {
                //return E_CHANSKEW_CALCULATED;
                
                if (!GetDevCaps()->scanning)
                    return E_NO_CHANSKEW;
                _chanSkewMode=CHAN_SKEW_MANUAL;
            }

			// Capture the current channel skew value
			double OldChannelSkew = _chanSkew;
            
			// Assign new requested value
			_chanSkew=*var; 
            
			// Update timing
            hr = UpdateTimeing(FORSET);

			// If there was an error, reset the original channelskew value
			if (hr != S_OK)
				_chanSkew = OldChannelSkew;

			// Update the value in the engine
            *var=_chanSkew;


            return hr;
        }
        // Channel skew can only bet set if Channel Skew Mode is manual
        else if (User==(long)&_chanSkewMode)
        {
	    // simultaneous sampling required for skew mode NONE
	    if ((long)*var==CHAN_SKEW_NONE && GetDevCaps()->scanning)
		return E_INV_CHANSKEW;

            if (!GetDevCaps()->scanning && (long)*var!=CHAN_SKEW_NONE)
                return E_NO_CHANSKEW;
                    
            // set the mode then update the chan skew value
            _chanSkewMode = *var;
            // this does not require reconfigure, so we're done here.
            return UpdateTimeing(FORSET);

        }
        // channel type effects the total number of channels available
        else if (User==(long)&_chanType)
        {

            CComPtr<IProp> pProp;
            HRESULT hr =GetChannelProperty(L"HwChannel", &pProp);
            if (FAILED(hr)) return hr;	   
            
            if ((long)*var==DIFFERENTIAL)
            {
                long idMax;
                
                // delete all channels
                if (_nChannels>0)
                {
                    _engine->WarningMessage(CComBSTR(L"NI-DAQ Deleting existing channels because of input type change."));
                    _EngineChannelList->DeleteAllChannels();
                }
                // boards with more than 16 inputs
                // use interleaved banks of 8 channels
                // in DI mode
                if (GetDevCaps()->nInputs==16)           
                    idMax=GetDevCaps()->nInputs/2-1;
                else
                    idMax=GetDevCaps()->nInputs-1;

                hr=pProp->SetRange(&CComVariant(0L),&CComVariant(idMax));
                if (FAILED(hr)) return hr;	   
            }
            else
            {
                hr=pProp->SetRange(&CComVariant(0L),&CComVariant(GetDevCaps()->nInputs-1));
                if (FAILED(hr)) return hr;
                if (_nChannels>0 && _nMuxBrds>0)
                {
                    // delete all the channels
                    _engine->WarningMessage(CComBSTR(L"NI-DAQ Deleting existing channels because of input type change and NumMuxBoards."));
                    _EngineChannelList->DeleteAllChannels();
                }
                
            }
            
        }               
        else if (User==(long)&_driveAIS)
        {
            bstr_t str=StringToLower(bstr_t(*var));

            if (str==bstr_t("on"))
                *var=1L;
            else if (str==bstr_t("off"))
                *var=0L;            
        }
        else if (User==(long)&_triggerDelay)
        {
            if ((double)*var<0 && (_triggerType==HW_DIGITAL 
                                   || _triggerType==HW_ANALOG_CHANNEL
                                   || _triggerType==HW_ANALOG_PIN))
                 return(E_PRETRIGGER_NOT_SUPPORTED);

        }
        else if (User==(long)&_triggerType)
	{
            long newTrigger=(long)*var;
            
            if (newTrigger==HW_DIGITAL 
                || newTrigger==HW_ANALOG_CHANNEL
                || newTrigger==HW_ANALOG_PIN)
            {
                if (_triggerDelay<0)
                    return(E_PRETRIGGER_NOT_SUPPORTED);
            }
	    if (newTrigger==HW_DIGITAL)
	    {
		_triggerCondition->ClearEnumValues();                
                _triggerCondition->AddMappedEnumValue(TRIG_NONE, L"None");    
                _triggerCondition->put_Value(CComVariant(TRIG_NONE));
                
                _triggerConditionValue->SetRange(&CComVariant(0L), &CComVariant(0L));
	    }
	    else if (newTrigger==HW_ANALOG_CHANNEL || (long)*var==HW_ANALOG_PIN)
	    {
                // hardware analog trigger settings
                _triggerCondition->ClearEnumValues();                
		_triggerCondition->AddMappedEnumValue(ND_ABOVE_HIGH_LEVEL, L"AboveHighLevel");                
		_triggerCondition->AddMappedEnumValue(ND_BELOW_LOW_LEVEL,  L"BelowLowLevel");               
		_triggerCondition->AddMappedEnumValue(ND_INSIDE_REGION,    L"InsideRegion");                
		_triggerCondition->AddMappedEnumValue(ND_LOW_HYSTERESIS,   L"LowHysteresis");                
		_triggerCondition->AddMappedEnumValue(ND_HIGH_HYSTERESIS,  L"HighHysteresis");  
                
                _triggerCondition->put_Value(CComVariant(ND_ABOVE_HIGH_LEVEL));
                _triggerCondition->put_DefaultValue(CComVariant(ND_ABOVE_HIGH_LEVEL));
                _triggerCondition=ND_ABOVE_HIGH_LEVEL;                
                _triggerConditionValue->put_Value(CComVariant(0.0));
                _triggerConditionValue->put_DefaultValue(CComVariant(0.0));

                _triggerType=newTrigger;
                double min,max;
                GetTriggerConditionValueRange(&min,&max);
                _triggerConditionValue.SetRange(CComVariant(min),max);
	    }
	}
        else if (User==(long)&_nMuxBrds)
        {
            if ((long)*var<0 || (long)*var==3 || (long)*var>4)
                return E_INV_NUM_MUX;
            if (_nChannels>0)
            {
                // delete all the channels
                _engine->WarningMessage(CComBSTR(L"NI-DAQ Deleting existing channels because of change in NumMuxBoards."));
                _EngineChannelList->DeleteAllChannels();
            }
            DAQ_CHECK(AI_Mux_Config(_id, (short)*var));
        }

        // Now set the actual value
        ((CLocalProp*)User)->SetLocal(*var);
        
        // dirty flag - something changed, so reconfigure
        _isConfig=false;	
        DAQ_CHECK(Configure(FORSET));
        
    
    return S_OK;
}


void Cnia2d::SetupChannels()
{
      
    NESTABLEPROP *chan;        
    ReallocCGLists();    

    /*
     * install channels params into local member variables
     */
    for (int i=0; i<_nChannels; i++) 
    {    
	_EngineChannelList->GetChannelStructLocal(i, &chan);
        AICHANNEL *aichan=(AICHANNEL*)chan;
        if (chan==NULL ) continue;
        if (GetDevCaps()->IsLab() && _nChannels>1) // if a lab device fix up channel id's
        {
            if (_chanType==DIFFERENTIAL)
                chan->HwChan=GetDevCaps()->DIInputIDs[_nChannels-i-1];
            else
                chan->HwChan=GetDevCaps()->SEInputIDs[_nChannels-i-1];
        }
        if (chan->HwChan==_chanList[i]) continue;
       _chanList[i] = (short)chan->HwChan;
        double outRangeLo,outRangeHi;  // check to see if values come back correctly
        FindGainForRange(aichan->VoltRange[0], aichan->VoltRange[1], &outRangeLo, &outRangeHi,&_gainList[i],&_polarityList[i]);
        aichan->ConversionOffset=_polarityList[i]==BIPOLAR ? 0 : 1<<(GetDevCaps()->adcResolution-1);

    }
    _isConfig=false;
}

void Cnia2d::SetAllPolarities(short polarity)
{
    NESTABLEPROP *chan;
    AICHANNEL *pchan;
    double VoltRange[2];
    VoltRange[0]=polarity==UNIPOLAR ? 0 : -GetDevCaps()->bipolarRange;;
    VoltRange[1]=polarity==UNIPOLAR ? GetDevCaps()->unipolarRange : GetDevCaps()->bipolarRange;;
    for (int i=0; i<_nChannels; i++) 
    {	    
        _polarityList[i]=polarity;
	_EngineChannelList->GetChannelStructLocal(i, &chan);
	if (chan==NULL) break;
	pchan=(AICHANNEL*)chan;
        if (polarity==BIPOLAR)
        {
            FindGainForRange(-pchan->VoltRange[1],pchan->VoltRange[1],&pchan->VoltRange[0],&pchan->VoltRange[1],
                &_gainList[i],&_polarityList[i]);
        }
        else
        {
            FindGainForRange(0,pchan->VoltRange[1],&pchan->VoltRange[0],&pchan->VoltRange[1],
                &_gainList[i],&_polarityList[i]);
        }
        pchan->ConversionOffset=polarity==BIPOLAR ? 0 : 1<<(GetDevCaps()->adcResolution-1);
    }       


    if (polarity==UNIPOLAR)
    {
            // native data type    
        _DaqHwInfo->put_MemberValue(CComBSTR(L"nativedatatype"), CComVariant(VT_UI2));	

    }
    else
        _DaqHwInfo->put_MemberValue(CComBSTR(L"nativedatatype"), CComVariant(VT_I2));

    CComVariant val;
    CreateSafeVector(VoltRange,2,&val);

    CComPtr<IProp> prop;

    // Input range
    HRESULT hRes =GetChannelProperty(L"InputRange", &prop);

    hRes = prop->put_DefaultValue(val);

    
    prop.Release();


}

#ifdef stloverkill

#include <functional>
#include <algorithm>

template<class Pred>
class RangeFinder: public  std::unary_function<Pred, bool>
{
public:
    RangeFinder(short gain,int polarity): gainint(gain),polarity(polarity) {}
    bool operator()(const argument_type& x) const
    {
        return (gainInt==x.GainInt) && (polarity==x.polarity);
    }
    int polarity;
    short gainInt;
};

Cnia2d::RANGE_INFO* Cnia2d::FindRangeFromGainInt(short gain,int polarity)
{
    RangeList_t::iterator i;
    RangeFinder<RANGE_INFO> rf(gain,polarity);
    i=std::find_if(_validRanges.begin(),_validRanges.end(),rf);
    return i!=_validRanges.end() ? i: NULL;
}
#else

Cnia2d::RANGE_INFO* Cnia2d::FindRangeFromGainInt(short gain,int polarity)
{
    RangeList_t::iterator i;
    for (i=_validRanges.begin();i!=_validRanges.end();++i)
    {
        if ((gain==i->GainInt) && (polarity==i->polarity))
            return &(*i);
    }
    return NULL;
}

#endif

/*
 * Here we have 3 parameters which determine the possible gain values.
 *
 * 12-bit boards support an actual range of [-5 5], while 16 bit
 * boards support [-10 10]. 
 *
 * Some 16-bit E Series boards support limited gains values: [1,2,10,100]
 * while most support [1,2,5,10,20,50,100]
 * 
 * Simultaneous Sampling hardware supports [0.2,0.5,1,2,5,10,20,50]
 * 
 * Scanning 12-bit cards support [-1 (0.5),1,2,5,10,20,50,100]
 *  
 *  The 12 bit 6023E, 6024E and 6025E families of boards support 4 gains: .5, 

    1, 10, 100.  This will cause problems internally because we already have 

    the 16 bit boards supporting 4 gains which are a different set of gains.  


 * Bipolar input range must be uniform wrt to 0, and unipolar must 
 * use 0 as the lower range value.
 *
 * Here we take the user input range and set the gain to best fit the 
 * requested range. The range corresponding to the gain used is returned.
 */

HRESULT Cnia2d::FindRange(double low,double high,RANGE_INFO* &pRange)
{

    if (low>high)
        return DE_INVALID_CHAN_RANGE;
    if (low==high)
    {
        return Error(_T("Low value must not be the same as high value."));
    }
    pRange=NULL;
    double range=HUGE_VAL;
    low*=0.9999; // round values down a bit to prevent round off errors
    high*=0.9999;
    // search all reanges (saves having a sort (sort by what? range.)
    for (RangeList_t::iterator i=_validRanges.begin();i!=_validRanges.end();i++)
    {
        if (i->minVal<=low && i->maxVal >=high && range>i->maxVal-i->minVal)
        {
            // range is valid and better 
            pRange=&(*i);
            range=i->maxVal-i->minVal;
        }
    }
    if (!pRange)
        return DE_INVALID_CHAN_RANGE;
    return S_OK;

}

void Cnia2d::FindGainForRange(double inRangeLo, double inRangeHi, 
			    double *outRangeLo, double *outRangeHi,short *outGain,short *outPolarity)
{
    RANGE_INFO *ri;
    if (!SUCCEEDED(FindRange(inRangeLo,inRangeHi,ri)))
        ri=&_validRanges[0];
    *outRangeHi=ri->maxVal;
    *outRangeLo=ri->minVal;
    *outGain=ri->GainInt;
    *outPolarity=ri->polarity;
}

int Cnia2d::SetGainForRange(short chan, double inRangeLo, double inRangeHi, 
			    double *outRangeLo, double *outRangeHi)
{

    short polarity,gain;
    RANGE_INFO *ri;
    RETURN_HRESULT(FindRange(inRangeLo,inRangeHi,ri));
    *outRangeHi=ri->maxVal;
    *outRangeLo=ri->minVal;
    gain=ri->GainInt;
    polarity=ri->polarity;

    if (inRangeLo< *outRangeLo || inRangeHi> *outRangeHi)
        return E_INVALID_CHAN_RANGE;

    if (polarity!=_polarityList[chan])
    {

        if (_nChannels>1) _engine->WarningMessage(CComBSTR(L"All channels configured to have the same polarity."));
        SetAllPolarities(polarity);
    }
    _polarityList[chan]=polarity;
    _gainList[chan]=gain;

    // tell the engine about the actual gain and set Conversion offset for display 
    // this code is not realy needed until we support multiple polarities

    CComPtr<IChannel> pCont;
    HRESULT hRes = _EngineChannelList->GetChannelContainer(chan, __uuidof(IChannel),(void**)&pCont);
    if (FAILED (hRes)) return hRes;
    pCont->put_MemberValue(L"conversionoffset",CComVariant(polarity==BIPOLAR ? 0.0 : (double)(1<<(GetDevCaps()->adcResolution-1)) ) );
    return DAQ_NO_ERROR;
}


// chan is the index
STDMETHODIMP Cnia2d::SetChannelProperty(long dwUser, NESTABLEPROP * pChan, VARIANT * NewValue)
{

    // prevent mulitple objects pointing to the same device to change
    // param values while the device is running    

    if (_Nia2dWnd->IsOpen(_id) && _Nia2dWnd->GetDevFromId(_id) !=this )
        return E_BAD_DEVICE;
    
    short chan = static_cast<short>(((AICHANNEL*)pChan)->Nestable.Index-1); // index is one-based
    
    variant_t *var = (variant_t*)NewValue;
    
    switch (dwUser)
    {
    case HWCHAN:
        {
            short id=*var;
            if (!IsValidChanId(id))
                return E_INVALID_INPUT_CHANNEL;
            if (GetDevCaps()->IsLab() && _nChannels>1 && id!=pChan->HwChan)
                return E_HWCHANNEL_MAY_NOT_BE_SET_FOR_LAB;
            
            _chanList[chan]=id;
        }
        break;
        
        
    case INPUTRANGE:	    	    	
        
        if (V_VT(NewValue) == (VT_ARRAY | VT_R8))
        {
            TSafeArrayAccess<double> inRange(NewValue);
            _ASSERT(inRange.Size()==2);	// The engine will error before we get here	
            
            double inRangeLo = inRange[0];
            double inRangeHi = inRange[1];
            
            double outRangeLo, outRangeHi;
            
            if (inRangeHi <= inRangeLo)
            {
                return E_INVALID_CHAN_RANGE;
            }
            
            // set the gain accordingly
            RETURN_HRESULT(SetGainForRange(chan, inRangeLo, inRangeHi, &outRangeLo, &outRangeHi));
            
            
            // tell the engine about the actual range used
            inRange[0] = outRangeLo;
            inRange[1] = outRangeHi;
            
        }
        else 
        {
            return E_INVALID_CHAN_RANGE;
        }
        
        break;
    case COUPLING:
        DAQ_CHECK(::AI_Change_Parameter (_id, chan, ND_AI_COUPLING, static_cast<long>(*var) ));
         break;
    default:
        break;
    }
    // do if we have a user field connection
    // dirty flag - something changed, so reconfigure
    _isConfig=false;
    
    DAQ_CHECK(Configure(FORSET));
    return S_OK;
}


STDMETHODIMP Cnia2d::GetSingleValues(VARIANT* values)
{    
        
    AUTO_LOCK; // Should not be needed inserted on a whim
    if (!_isConfig) 
        DAQ_CHECK(Configure(FORSINGLEVALUE));
    // 3 SCANS IS THE MIN with scan_op
    SAFEARRAY *ps = SafeArrayCreateVector(VT_I2, 0, _nChannels*2);
    if (ps==NULL) return E_SAFEARRAY_ERR;
    
    // set the data type and values
    V_ARRAY(values)=ps;
    V_VT(values)=VT_ARRAY | VT_I2;
    TSafeArrayAccess <short > binarray(values);    
    
    if (_nChannels==1) 
    {        	    
   
	DAQ_CHECK(AI_Read(_id, _chanList[0], _gainList[0], &binarray[0]));
    }
    else 
    {
	// setup the channels to read and scan them
        DAQ_TRACE(Set_DAQ_Device_Info(_id, ND_DATA_XFER_MODE_AI, ND_INTERRUPTS));		
        if (GetDevCaps()->IsLab())
        {
            if (_nChannels==2)
            {
                DAQ_CHECK(AI_Read(_id, _chanList[0], _gainList[0], &binarray[0]));
                DAQ_CHECK(AI_Read(_id, _chanList[1], _gainList[1], &binarray[1]));
            }
            else
            {
                short *dummy=(short*)_alloca(_nChannels*sizeof(short));
                DAQ_CHECK(Lab_ISCAN_Op(_id,static_cast<i16>(_nChannels),_gainList[0],&binarray[0],
					_nChannels,1.0/_chanSkew,0,dummy));
            }
        }
        else
        {
            if (_nMuxBrds>0)
            {
                short ChanList[16],GainList[16];
                
                short chans;
                DAQ_CHECK(MakeMuxLists(ChanList,GainList,chans));
                DAQ_CHECK( SCAN_Op(_id,chans,ChanList,GainList,&binarray[0],_nChannels*2, 
                    1.0/_chanSkew,_sampleRate));
            }
            else
                
                DAQ_CHECK( SCAN_Op(_id,static_cast<i16>(_nChannels),&_chanList[0],&_gainList[0],&binarray[0],
					_nChannels*2,1.0/_chanSkew,_sampleRate));
        }
    }        


    return S_OK;
}


/////////////////////////////////////////////////////////////////////////////
// CError


STDMETHODIMP Cnia2d::InterfaceSupportsErrorInfo(REFIID riid)
{
    static const IID* arr[] = 
    {
	&__uuidof(ImwDevice) , //&IID_IDevice,
    };
    for (int i=0;i<sizeof(arr)/sizeof(arr[0]);i++)
    {
	if (InlineIsEqualGUID(*arr[i],riid))
	    return S_OK;
    }
    return S_FALSE;
}


/*
STDMETHODIMP Cnia2d::TranslateError(VARIANT *eCode, VARIANT *retVal)
{      
    V_BSTR(retVal) = TranslateErrorCode(eCode->lVal).Detach();
    return S_OK;
}
*/
bool Cnia2d::IsValidChanId(short id)
{
        if (_chanType.Value==DIFFERENTIAL)
        {
            // make sure id is valid
            for (int i=0;i<GetDevCaps()->nDIInputIDs;i++)
            {
                if (GetDevCaps()->DIInputIDs[i]==id)
                {
                    return true;
                }
            }
            return false;
        }
        else
            return true; // for now all se ids that get by engine are legal (setrange for hwchannelid) 
}

STDMETHODIMP Cnia2d::ChildChange(DWORD typeofchange, NESTABLEPROP *pChan)
{
    
    // prevent mulitple objects pointing to the same device to change
    // param values while the device is open    
    if (_Nia2dWnd->IsOpen(_id) && _Nia2dWnd->GetDevFromId(_id) !=this)
        return E_BAD_DEVICE;

    // Verify that the index is legal for the current board
    // All channels are legal for SE.
    // For DI, 0-7 is valid for 16 channel boards
    // 0-7, 16-23, 32-39, and 48-55 are legal for 64 channel boards
    if ((typeofchange & CHILDCHANGE_REASON_MASK)== ADD_CHILD)
    {
        if (GetDevCaps()->scanning && (_nChannels+1)*_sampleRate>GetDevCaps()->maxAISampleRate*1.001)
            return DE_RATE_TOO_HIGH_GIVEN_CHANNELS;
        
        if (pChan)        
        {
            short chan = static_cast<short>(((AICHANNEL*)pChan)->Nestable.Index-1); // index is one-based
            
            if (_chanType.Value==DIFFERENTIAL)
            {
                // make sure id is valid
                if (!IsValidChanId(static_cast<short>(pChan->HwChan)))
                    return E_INVALID_INPUT_CHANNEL;
            }
        }
    }
    if (typeofchange & END_CHANGE)
    {
        SetupChannels();
        UpdateTimeing(FORSET);
    }
    
    return S_OK;
}

HRESULT CDSAInput::UpdateTimeing(ConfigReason reason)
    {
        double newrate;
        DAQ_CHECK(DAQ_Set_Clock(_id,0,_sampleRate,0,&newrate));
        _sampleRate=newrate;
        return S_OK;
    }
