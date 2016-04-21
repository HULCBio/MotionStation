//
// LABIO.CPP
// Class to represent the 1200 series cards
// Copyright 1998-2004 The MathWorks, Inc.
// $Revision: 1.2.4.2 $  $Date: 2004/04/08 20:49:44 $
//
#include "stdafx.h"
#include "mwnidaq.h"
#include "nia2d.h"
#include "daqmex.h"
#include "daqtypes.h"
#include "errors.h"

#include "nidaq.h"
#include "nidaqcns.h"
#include "nidaqerr.h"
#include <crtdbg.h>
#include <sarrayaccess.h>
#include <math.h>
#define AUTO_LOCK TAtlLock<Cnia2d> _lock(*this)


HRESULT CLabInput::Open(IDaqEngine *engine,int id,DevCaps* DeviceCaps)
{
    RETURN_HRESULT(Cnia2d::Open(engine, id,DeviceCaps));
    if (GetDevCaps()->Is700())
    {
        _chanSkewMode->ClearEnumValues();    
        _chanSkewMode->AddMappedEnumValue(EQUISAMPLE, L"Equisample");
        _chanSkewMode=EQUISAMPLE;
        _chanSkewMode->put_DefaultValue(CComVariant(EQUISAMPLE)); 
        UpdateTimeing(FORSET);
    }

    return S_OK;
}


STDMETHODIMP CLabInput::SetProperty(long User, VARIANT *newVal)
{
    if (User==(long)&_chanSkew && GetDevCaps()->Is700())
    {
        return Error(L"Channel skew may not be set on LPM type devices because ChannelSkewMode must be Equisample.");
    }
    return Cnia2d::SetProperty(User,newVal);
}

STDMETHODIMP CLabInput::SetChannelProperty(long User,NESTABLEPROP * pChan, VARIANT * NewValue)
{
    HRESULT status=Cnia2d::SetChannelProperty(User,pChan,NewValue);
    if (User==INPUTRANGE && status==S_OK)
    {
        // change the default value
    }

    return status;
}

STDMETHODIMP CLabInput::GetSingleValues(VARIANT* values)
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
    
    if (_nChannels<=2) 
    {        	    
        for (int i=0;i<_nChannels;i++)
        {
            DAQ_CHECK(AI_Read(_id, _chanList[i], _gainList[i], &binarray[i]));
        }
    }
    else 
    {
        // setup the channels to read and scan them
        DAQ_TRACE(Set_DAQ_Device_Info(_id, ND_DATA_XFER_MODE_AI, ND_INTERRUPTS));		
        short *dummy=(short*)_alloca(_nChannels*sizeof(short));
        DAQ_CHECK(Lab_ISCAN_Op(_id,static_cast<i16>(_nChannels),_gainList[0],&binarray[0],
			_nChannels, 1.0/_chanSkew,0,dummy));
    }        
    

    return S_OK;
}


    
STDMETHODIMP CLabInput::ChildChange(DWORD typeofchange, NESTABLEPROP *pChan)
{
    if ((typeofchange & CHILDCHANGE_REASON_MASK)== ADD_CHILD)        
    {
        int MaxChannels=_chanType.Value==DIFFERENTIAL ? GetDevCaps()->nDIInputIDs : GetDevCaps()->nSEInputIDs;
        if (_nChannels>=MaxChannels)
            return Error(L"Lab and LPM boards may not scan more channels then are present on the board.");
    }

   return Cnia2d::ChildChange( typeofchange, pChan);
}

int CLabInput::TriggerSetup()
{  		
    short starttrig=0;
    _ASSERTE(!GetDevCaps()->IsESeries()); // E series not supported by this function
    
    if (_triggerType & TRIG_TRIGGER_IS_HARDWARE)
    {
        switch(_triggerType)
        {
        case HW_DIGITAL:
            starttrig=1;
            break;
        default:
            return E_E_SERIES_ONLY;
        }
    }
    return(DAQ_Config(_id, starttrig, (short)_clockSrc));
}

double  CLabInput::RoundRate(double SourceRate)
{
    double clockfreq=1.0/Timebase2ClockResolution(_scanTB);
    long clockdiv=static_cast<long>(floor(clockfreq/SourceRate+.01)); // spec says one percent tol (of what?)
    return clockfreq/ clockdiv ;
}


HRESULT CLabInput::UpdateTimeing(ConfigReason reason)
{
    double newChanSkew=_chanSkew;
    double newRate=GetTargetSampleRate();
    
    newRate=GetDevCaps()->FindRate(newRate,&_scanTB,&_scanInterval); // base from samplerate
    if (_nChannels<2) 
    {
        newChanSkew=(GetDevCaps()->settleTime+10)*1e-6;
    }
    else
    {
        switch (_chanSkewMode)
        {	
        case CHAN_SKEW_MIN:              
            {
                // settleTime is in uSec
                // we use a 10 uSec slop factor at the advice of NI
                double settleTime = GetDevCaps()->settleTime + 10;
                if (settleTime/1e6*(_nChannels+2) > 1.0/GetTargetSampleRate())
                {
                    // switch to equalsample
                    newChanSkew=1.0/RoundRate(_sampleRate*_nChannels);
                    if (newChanSkew* (_nChannels+2) >= 1.0/GetTargetSampleRate())
                        // if no time to scan then use equal sample
                    {
                        _scanInterval=0;
                        newChanSkew=1/(GetDevCaps()->FindRate(GetTargetSampleRate()*_nChannels,&_scanTB,&_sampleInterval));
                        // now fix up sample rate
                        newRate=1.0/ (newChanSkew *_nChannels);
                    }
                }
                else
                {  // using min
                    // DAQ_ Rate(settleTime/1e6, 1, &_sampleTB, &_sampleInterval);        
                    // *chanSkew=_sampleInterval*Timebase2ClockResolution(_sampleTB);
                    double clockfreq=1.0/Timebase2ClockResolution(_scanTB);
                    _sampleInterval=static_cast<unsigned short>(floor(clockfreq*settleTime/1e6+.01)); // spec says one percent tol (of what?)
                    
                    newChanSkew=_sampleInterval/clockfreq;
                    }
            }
            break;
        case EQUISAMPLE:
            {            
                newChanSkew=1/(GetDevCaps()->FindRate(GetTargetSampleRate()*_nChannels,&_scanTB,&_sampleInterval));
                _scanInterval=0;
                // now fix up sample rate
                newRate=1.0/ (newChanSkew *_nChannels);
            }
            break;
        case  CHAN_SKEW_MANUAL:
            {
                double clockfreq=1.0/Timebase2ClockResolution(_scanTB);
                _sampleInterval=static_cast<unsigned short>(floor(clockfreq*newChanSkew+.01)); // spec says one percent tol (of what?)            
                newChanSkew=_sampleInterval/clockfreq;        }
            break;  
        default:
            break;
        }
    }
    // put the new value back to the engine. 
    if (_chanSkew!=newChanSkew)
    {      
        _chanSkew=newChanSkew;
    }
    if (newRate!=_sampleRate)
    {
        _sampleRate=newRate;
    }
    return S_OK;
}


HRESULT CLabInput::Configure(ConfigReason reason)
{
    // all channels must have the same range need to find the range
    // 1200 and lab boards have gains 700 boards do not
    if (reason>FORSET)
    {
        _ASSERTE(_nChannels!=0); 
        CurrentRange=FindRangeFromGainInt(_gainList[0], _polarityList[0]);
        _ASSERTE(CurrentRange!=NULL);
        short inputRange=0;                
        // Check all channels for correct input range;

        for (int i=0; i<_nChannels; i++) 
        {
            // 700 and lpm boards do not have gains but do have multiple ranges
            // 1200 boards have gains
            if (_gainList[i]!=CurrentRange->GainInt || _polarityList[i] !=CurrentRange->polarity)
            {
                return Error(L"Your hardware does not support different input ranges on two or more channels.");
            }

        } 
        DAQ_CHECK(AI_Configure( _id,-1, GET_ADAPTOR_ENUM_VALUE(_chanType),
                                static_cast<i16>(CurrentRange->maxVal-CurrentRange->minVal), 
								CurrentRange->polarity, _driveAIS));
        
        // done with input range
        UpdateTimeing(reason);
    }    
    DAQ_CHECK(TriggerSetup());
        
    // Clear any previously configured messages
    //    ClearEventMessages(_id);
    
    _isConfig = true;
    return S_OK;

}

STDMETHODIMP CLabInput::Trigger()
{
        /*
     * Start the acquisition
     */
    AUTO_LOCK;
    
    if (_nChannels==1) 
    {	
        // Convert the sample rate to a timebase and sample interval
//        DAQ_CHECK(DAQ_ Rate(_sampleRate, 0, &_scanTB, &_scanInterval));    	
        
        DAQ_CHECK(DAQ_Start(_id, _chanList[0], _gainList[0], _CircBuff.GetPtr(),
            _CircBuff.GetBufferSize(), _scanTB, _scanInterval));			
    } 
    else 
    {	        //        
        DAQ_CHECK(Lab_ISCAN_Start(_id, static_cast<i16>(_nChannels), _gainList[0],
			_CircBuff.GetPtr(), _CircBuff.GetBufferSize(), _scanTB, _sampleInterval, 
			_scanInterval));
    } 

    _running=true;
    _callTrigger=true;

    return S_OK;
}
