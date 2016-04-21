// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.1.6.2 $  $Date: 2003/12/04 18:40:17 $

// SoundDA.cpp : Implementation of CMwdeviceApp and DLL registration.

#include "stdafx.h"

// For DAQ Partners, the following line should be uncommented
//#include "mwexample.h"

// For DAQ Partners, the following line should be commented out
#include "mwwinsound.h"

#include "daqmex.h"
#include "errors.h"
#include "SoundDA.h"
#include <comcat.h>
#include <limits>
#include <sarrayaccess.h>
#include "util.h"
/////////////////////////////////////////////////////////////////////////////
#ifdef _DEBUG
#undef THIS_FILE
#undef DEBUG_NEW
static char THIS_FILE[]=__FILE__;
#define DEBUG_NEW new(_NORMAL_BLOCK, THIS_FILE, __LINE__)
#define new DEBUG_NEW
#endif
#define AUTO_LOCK TAtlLock<SoundDA> _lock(*this)

BOOL SoundDA::IsBufferDone()
{ 
    if (_BufferList.size()==0) 
        return FALSE;
    Buffer* pBuf=_BufferList.NextBuffer();
    return GetBufferHeader(pBuf)->IsDone(); 
}

SoundDA::SoundDA() : 
_bitsPerSample (16),
_standardSampleRates(0),
_running(false),
_samplesOutput(0),
_pointsQueued(0),
#pragma warning(disable: 4355) // 'this' used before initialized
_thread(ThreadProc,this),
_isDying(0),
#pragma warning(default: 4355)
_lastBufferGap(false),
_id(0)
{

}

SoundDA::~SoundDA()
{
    Stop();

    _isDying++;
    int rv;
    while ((rv=_thread.Resume())>1)
    {
        _RPT1(_CRT_WARN,"Resume value is %d",rv);
    }
    _BufferDoneEvent.Set();
    _thread.WaitForDeath();
}


CComPtr<IProp> SoundDA::RegisterProperty(LPWSTR name, DWORD dwUser)
{
    CComPtr<IProp> prop;
    GetProperty(name, &prop);

    if (prop==NULL) {
        char errStr[128];
        sprintf(errStr, "Winsound: Invalid property: '%s'.", name);
        throw errStr;
    }
    
    prop->put_User(dwUser);

    return prop;
}


HRESULT SoundDA::SetDaqHwInfo()
{    
    CComPtr<IProp> prop;     

    // hwinfo property container

    CComQIPtr<IPropContainer> pCont(GetHwInfo());   
        
    // total channels 
    CComVariant var,vids;
    short ids[]={1,2};
    if (WaveCaps.IsStereo())
    {
        var=2L;
        CreateSafeVector(ids,2,&vids);
    }
    else
    {
        var=1L;
        CreateSafeVector(ids,1,&vids);
    }

    HRESULT hRes = pCont->put_MemberValue(L"totalchannels",var);
    if (!(SUCCEEDED(hRes))) return hRes;        

    hRes = pCont->put_MemberValue(L"channelids", vids);
    if (!(SUCCEEDED(hRes))) return hRes;

    
    wchar_t idStr[8];
    swprintf(idStr, L"%d", _id);
    hRes = pCont->put_MemberValue(L"id", CComVariant(idStr));	
    if (!(SUCCEEDED(hRes))) return hRes;
    
    hRes = pCont->put_MemberValue(L"polarity", CComVariant(L"Bipolar"));
    if (!(SUCCEEDED(hRes))) return hRes;

    hRes = pCont->put_MemberValue(L"coupling", CComVariant(L"AC Coupled"));
    if (!(SUCCEEDED(hRes))) return hRes;

    // subsystem type
    hRes = pCont->put_MemberValue(L"subsystemtype",CComVariant(L"AnalogOutput"));
    if (!(SUCCEEDED(hRes))) return hRes;

    // autocal
    //hRes = pCont->put_MemberValue(CComBSTR(L"autocalibrate"),CComVariant(0L));
    //if (!(SUCCEEDED(hRes))) return hRes;
   
    hRes = pCont->put_MemberValue(L"sampletype",CComVariant(1L));
    if (!(SUCCEEDED(hRes))) return hRes;

    // number of bits
    CComVariant val;
    val = WaveCaps.Supports16Bit() ? 16L : 8L;
    hRes = pCont->put_MemberValue(CComBSTR(L"bits"),val);
    if (!(SUCCEEDED(hRes))) return hRes;
      
    hRes = pCont->put_MemberValue(L"adaptorname",
        CComVariant(L"winsound"));
    if (!(SUCCEEDED(hRes))) return hRes;

    // driver description    
    bstr_t name = WaveCaps.GetDeviceName();
    V_VT(&val) = VT_BSTR;
    V_BSTR(&val) = name;
    hRes = pCont->put_MemberValue(L"devicename",val);
    if (!(SUCCEEDED(hRes))) return hRes;    

    hRes = pCont->put_MemberValue(L"vendordriverdescription",
	CComVariant(L"Windows Multimedia Driver"));
    if (!(SUCCEEDED(hRes))) return hRes;
       
    hRes = pCont->put_MemberValue(L"vendordriverversion",CComVariant(WaveCaps.GetDriverVersion()));
    if (!(SUCCEEDED(hRes))) return hRes;

    // native data type
    var = WaveCaps.Supports16Bit() ? VT_I2 : VT_UI1;
    hRes = pCont->put_MemberValue(L"nativedatatype", var);	
    if (!(SUCCEEDED(hRes))) return hRes;


    SetSampleRateRange(8000,static_cast<long>(WaveCaps.GetMaxSampleRate()));

    // input ranges --> move to input group    
    SAFEARRAY *ps = SafeArrayCreateVector(VT_R8, 0, 2);
    if (ps==NULL) 
	throw "Failure to create SafeArray.";

    val.parray=ps;
    val.vt = VT_ARRAY | VT_R8;

    double *pr;
    
    hRes = SafeArrayAccessData(ps, (void **) &pr);
    if (FAILED (hRes)) 
    {
        SafeArrayDestroy (ps);
        throw "Failure to access SafeArray data.";
    }       

    pr[0]=-1;
    pr[1]=1;

    SafeArrayUnaccessData (ps);

    hRes = pCont->put_MemberValue(CComBSTR(L"outputranges"), val);	
    if (!(SUCCEEDED(hRes))) return hRes;    

    return S_OK;
}

HRESULT SoundDA::Open(IDaqEngine *engine, int id)
{
    // assign the engine access pointer
    _engine = engine;
    _ASSERTE(engine!=NULL);
    _id=id; 
    CComPtr<IProp> prop;
    CComVariant minvar,maxvar;

    UINT nDevs=waveOutGetNumDevs();

    if (!nDevs) return E_NO_DEVICE;


    if (_id<0 || _id>nDevs-1) return E_INVALID_DEVICE_ID;
    CmwDevice::Open(engine);

    // common properties 
    WaveCaps.LoadCaps(_id);    
    _cSamplesPerSec.Attach(GetPropRoot(),L"SampleRate");
    CComVariant val(DEFAULT_SAMPLE_RATE, VT_I4);
    _cSamplesPerSec=DEFAULT_SAMPLE_RATE;    
    _cSamplesPerSec->put_DefaultValue(val);
    

    // device specific properties
    HRESULT hRes;
    
    bool supports16Bit=WaveCaps.Supports16Bit();
    
    // sixteen-bit boards also support 8-bit mode
    if (supports16Bit)
    {       
   	hRes = _EnginePropRoot->CreateProperty(L"BitsPerSample", &CComVariant(16L), __uuidof(IProp),(void**) &prop);     
        if (!(SUCCEEDED(hRes))) return hRes;
    
        minvar=4L; maxvar=32L;	    
	prop->SetRange(&minvar, &maxvar);
    }
    else    
    {
        hRes = _EnginePropRoot->CreateProperty(L"BitsPerSample", &CComVariant(8L),__uuidof(IProp),(void**) &prop);     
        if (!(SUCCEEDED(hRes))) return hRes;
       
        minvar=maxvar=8L;
	prop->SetRange(&minvar, &maxvar);
	prop->put_Value(CComVariant(8));
        _bitsPerSample=8;
        {
            CComPtr <IProp> iProp;
            GetChannelProperty(L"conversionoffset",&iProp);
            iProp->put_DefaultValue(CComVariant(128.0));
        }

    }   
    prop->put_User((long)&_bitsPerSample);
    prop.Release();

    // StandardSampleRates - device specific.
    hRes = _EnginePropRoot->CreateProperty(L"StandardSampleRates", &CComVariant(true), __uuidof(IProp),(void**) &prop);
    if (!(SUCCEEDED(hRes))) return hRes; 
    prop->put_User((long)&_standardSampleRates);
    prop->put_IsReadonlyRunning(true);
    prop.Release();
 
    // Channel ranges

    static double Neg1To1[]={-1,1};
    CreateSafeVector(Neg1To1,2,&val);

    hRes = GetChannelProperty(L"outputrange", &prop);
    if (!(SUCCEEDED(hRes))) return hRes;     
    
    prop->put_DefaultValue( val);

    hRes = prop->put_User(OUTPUTRANGE);
    if (!(SUCCEEDED(hRes))) return hRes;    

    minvar=-1.0;
    maxvar=1.0;
    prop->SetRange(&minvar,&maxvar);

    prop.Release();
 
    hRes = GetChannelProperty(L"unitsrange", &prop);
    if (!(SUCCEEDED(hRes))) return hRes;        
    prop->put_DefaultValue( val);
    prop.Release();

    // DaqHwInfo
    hRes = SetDaqHwInfo();
    if (!(SUCCEEDED(hRes))) return hRes;      

    hRes = GetChannelProperty(L"HwChannel", &prop);
    if (!(SUCCEEDED(hRes))) return hRes;
    prop->put_DefaultValue( CComVariant(1L));
    
    prop->put_User((long)HwChan);
    
    if (WaveCaps.IsStereo())
        prop->SetRange(&CComVariant(1L),&CComVariant(2L));
    else
        prop->SetRange(&CComVariant(1L),&CComVariant(1L));
    
    prop.Release();

    _thread.Resume();
    _thread.SetThreadPriority(THREAD_PRIORITY_TIME_CRITICAL);

    return S_OK;

}

STDMETHODIMP SoundDA::SetProperty(long User, VARIANT *NewValue)  // return false for fail
{
    if (User)
    {
        variant_t *var = (variant_t*)NewValue;        
        
        // 
	// special case: if bitsPerSample is being changed, we
	// need to update the daqHwInfo to reflect this
	//
	if (User==(long)&_bitsPerSample)
	{      
           
       	    // set the daqHwInfo value which depends on the BitsPerSample property
            double offset;
	    // set the data type to match the bits, default is Int16
                long datatype;
                long bits=(long)*var;
		switch (bits)
                {
                case 8:
                    datatype=VT_UI1;
                    offset=128;
	        break;
                case 16:
                    datatype=VT_I2;
                    offset=0;
                    break;
                case 24:
                    datatype=VT_I4;
                    offset=0;
                    break;
                case 32:
                    datatype=VT_I4;
                    offset=0;
		    break;
                default:
                    if (bits<16 || bits > 32)
		        return E_INV_BPS;
                    _engine->WarningMessage(L"The bits value that has been set has no standard implementation"
                        L" by sound cards.  Acquisition may be unreliable.  To remove this warning rebuild the winsound adaptor");
                    datatype=VT_I4;
                    offset=0;
	        }
                WaveFormat.SetBits(static_cast<WORD>(bits));
                HRESULT hRes = GetHwInfo()->put_MemberValue(L"nativedatatype",CComVariant(datatype));
                if (!(SUCCEEDED(hRes))) return hRes;
                hRes = GetHwInfo()->put_MemberValue(L"bits",*NewValue);
                if (!(SUCCEEDED(hRes))) return hRes;
                
            // now set the offset value that the engin uses to calculate naiveoffset
            for (int i=0;i<_nChannels;i++)
            {
                AOCHANNEL *chan;
                _EngineChannelList->GetChannelStructLocal(i,(NESTABLEPROP**)&chan);
                chan->ConversionOffset=offset;
            }

            // set the default offset
            CComPtr<IPropRoot> iProp;
            GetChannelProperty(L"conversionoffset",&iProp);
            iProp->put_DefaultValue(CComVariant(offset));
        

        }
	else if (User==(long)&_standardSampleRates)
	{
            // Get a pointer to the IProp interface for theSampleRate property.
            if ((bool)(*var) == true){
	        // Need to snap current SampleRate to one of the standard samplerates.
                // A one percent tolerance is given.  
                // Ex. 8080 snaps to 8000 not 11025.
                _cSamplesPerSec=SnapSampleRates(_cSamplesPerSec);
                WaveFormat.SetRate(_cSamplesPerSec);
                RETURN_HRESULT(SetSampleRateRange(8000,static_cast<long>(WaveCaps.GetMaxSampleRate())));
            }else{
                // SampleRate can be set to a maximum of 96000Hz.
                RETURN_HRESULT(SetSampleRateRange(5000,96000));
            }
	}
	else if (User==(long)&_cSamplesPerSec)
	{
	    // SampleRate has been chosen.  Depending on standardSampleRates value
	    // may need to snap to specified SampleRate to 8000, 11025, 22050, 44100, 
            //  A one percent tolerance is given.

	    // Get a pointer to the IProp interface for the StandardSampleRates 
	    // property.
	    IProp* iProp;
            HRESULT hRes = GetProperty(L"StandardSampleRates", &iProp);
            if (FAILED(hRes)) return hRes;	   
   
	    // Get the value of the StandardSampleRates property.
            variant_t standardSR;
            iProp->get_Value(&standardSR);

            switch ((bool)standardSR)
            {
            case false:
                {	// StandardSampleRates is off.  Don't need to snap but do need to 
                    // round up to the next integer value.
                    
                    // Get the fraction portion of the SampleRate (8050.50)
                    double n;
                    double fraction=modf(*var, &n);
                    
                    // If not a fraction round up.
                    if (fraction!=0.0){
                        *var=(long)++n;
                    }
                    break;
                }
            case true:
                {	// StandardSampleRates is on.  Need to snap the specified SampleRate to
                    // either 8000, 11025, 22050, 44100
                    *var = SnapSampleRates(*var);
                    break;
                } 
            } // close switch
            
            iProp->Release();
	} //close else

       	// set the local value
	((CLocalProp*)User)->SetLocal(*var);

    }
    return S_OK;
}


STDMETHODIMP SoundDA::SetChannelProperty(long User, NESTABLEPROP *pChan, VARIANT *newValue)
{
    int chan=pChan->Index;   

    if (chan>2) return E_EXCEEDS_MAX_CHANNELS;
   
    long numChans;
    
    HRESULT hRes = _EngineChannelList->GetNumberOfChannels(&numChans);
    if (FAILED(hRes)) return hRes;
        

        if (User==HwChan) 
        {
            variant_t val = (variant_t*)newValue;
            if (V_VT(newValue)==VT_R8 && (double)val!=chan)
                return E_INVALID_CHANNEL;
        }
        // Winsound supports only an input range of [-1 1]
        else if (User==OUTPUTRANGE)
        {
            if (V_ISARRAY (newValue) || V_ISVECTOR (newValue))
            {                            
                SAFEARRAY *ps = newValue->parray;
                if (ps==NULL)
                    throw "Failure to access SafeArray.";
                                
                double *pr;
                
                HRESULT hr = SafeArrayAccessData (ps, (void **) &pr);
                if (FAILED (hr)) 
                {
                    SafeArrayDestroy (ps);
                    throw "Failure to access SafeArray.";
                }
                
                if (pr[0]!=-1 || pr[1]!=1)
                {
                    SafeArrayUnaccessData (ps);
                    return E_INV_OUTPUT_RANGE;
                }
                
                SafeArrayUnaccessData (ps);
            }

        }


    if (numChans!=_nChannels)
        _nChannels = numChans;       
    
    return S_OK;
}



unsigned WINAPI SoundDA::ThreadProc(void* pArg)
{
    try {
        SoundDA* thisptr=(SoundDA*) pArg;
        while(!thisptr->_isDying)
        {
            thisptr->_BufferDoneEvent.Wait(200); // wake up every 200ms just in case
            thisptr->CheckBuffersDone();
            thisptr->BufferReadyForDevice();
        }
    }
    catch (...)
    {
        _RPT0(_CRT_ERROR,"***** Exception in Sound Thread Terminateing Thread\n");
    }
    return 0;
}

void SoundDA::CheckBuffersDone()
{
    AUTO_LOCK;
    while (IsBufferDone ())
    {
        Buffer* pBuf=_BufferList.GetBuffer(); 
        WaveHeader *hdr=GetBufferHeader(pBuf);
        _waveOutDevice.UnPrepare (hdr);
        if (_running) 
            _samplesOutput+=pBuf->ValidPoints/_nChannels;
        else
            pBuf->ValidPoints=0;
        _engine->PutBuffer(pBuf);       
    }  
    if (_BufferList.size()==0 && _running && _waveOutDevice.GetPosSample()>=_samplesOutput)
    {
        //while (_waveOutDevice.GetPosSample()<_samplesOutput)
        //Sleep(70);
        _engine->DaqEvent(EVENT_STOP,0,_samplesOutput,NULL);
        // go ahead and stop things now
        _running=false;
        _waveOutDevice.Close();
        _lastBufferGap=false;
    }
#ifdef _DEBUG    
    if (_pointsQueued<=_samplesOutput*_nChannels)
        ATLTRACE("Total samples output: %d\n", _samplesOutput);
#endif
}


STDMETHODIMP SoundDA::FreeBufferData(BUFFER_ST* Buf) 
{   
    WaveHeader *hdr=GetBufferHeader(Buf);
    if (hdr->dwFlags & WHDR_PREPARED)
        _waveOutDevice.UnPrepare (hdr);
    delete hdr;
    CmwDevice::FreeBufferData(Buf);; 
    return S_OK;
}

STDMETHODIMP SoundDA::Stop()
{
   
    AUTO_LOCK;
    if (_running)
    {
    _running = false;
    _samplesOutput=_waveOutDevice.GetPosSample();
    _waveOutDevice.Reset();

    // Move all the buffers back to the FromDev list
#if 1
    CheckBuffersDone();
    int l=0;
    
    // now unprepare all buffers
    while (_BufferList.size()>0 && l++<20)
    {
        Sleep(1); // wait for buffers to clear
        CheckBuffersDone();
    }
#else
    
    int l=0;
    
    // now unprepare all buffers
    while (_BufferList.size()>0 && l++<20)
    {
        Lock.UnLock();
        Sleep(10); // wait for buffers to clear
        Lock.Lock();
    }
#endif
    _waveOutDevice.Close();
    _lastBufferGap=false;
    }
    return S_OK;
}

HRESULT SoundDA::BufferReadyForDevice()
{
    BUFFER_ST *pBuffer;
    AUTO_LOCK;
    while (_running && _BufferList.size()<45 && _engine->GetBuffer(0, &pBuffer)==S_OK)  // while there are buffers
    {   
        // assume buffers are prepared
        WaveHeader *hdr=GetBufferHeader(pBuffer);        
        hdr->dwFlags &= ~WHDR_DONE; //clear done flag
        hdr->lpData = (char *) pBuffer->ptr;        
        hdr->dwBufferLength = WaveFormat.Points2Bytes(pBuffer->ValidPoints);   
        if (WaveFormat.Points2Bytes(1)==3) // fix up the data
        {
            unsigned char *ptr24=pBuffer->ptr;
            unsigned char *ptr32=pBuffer->ptr;
            for (int i=0;i<pBuffer->ValidPoints;i++) 
            {
                *ptr24++=*++ptr32;
                *ptr24++=*++ptr32;
                *ptr24++=*++ptr32;
                ptr32++;
            }
        }
        
        _BufferList.PutBuffer((Buffer*)pBuffer);
        
        _waveOutDevice.Prepare (hdr);        
        _waveOutDevice.SendBuffer (hdr);
        _pointsQueued+=pBuffer->ValidPoints;
    }
    // if we ran and get another buffer before stop, it's underrun condition
 //   else if (_running)   
 //   {
 //       _engine->DaqEvent(ERR, 0, _samplesOutput/_nChannels,L"Underrun");
 //   }

    
    return S_OK;
}

HRESULT SoundDA::WaveOutError(MMRESULT err)
{
    TCHAR str[MAXERRORLENGTH+1];
    waveOutGetErrorText(err,str,MAXERRORLENGTH);
    return Error(str);
}

STDMETHODIMP SoundDA::Start ()
{
    AUTO_LOCK;
    WaveFormat.SetBits(static_cast<WORD>(_bitsPerSample));
    WaveFormat.SetRate(_cSamplesPerSec);
    WaveFormat.SetChannels(_nChannels);
    
    MMRESULT result = waveOutOpen(0, _id, &WaveFormat, 0, 0, WAVE_FORMAT_QUERY  );
    if (result!=MMSYSERR_NOERROR )
    {
        if (result==WAVERR_BADFORMAT)
            return E_INVALID_FORMAT;
        else
            return WaveOutError(result);
    }
//    _waveOutDevice.Open (_id, format,(HANDLE)waveOutProc ,(DWORD)this);
    _waveOutDevice.Open (_id, WaveFormat,(DWORD)(HANDLE)_BufferDoneEvent ,NULL ,CALLBACK_EVENT);
    if (!_waveOutDevice.Ok())
    {
        TCHAR buf[64];
        if (_waveOutDevice.isInUse())
            return E_DEVICE_IN_USE;
        else
            _waveOutDevice.GetErrorText (buf, sizeof (buf));
        throw buf;
        // return FALSE;
    }
    _running = true;
    
    _samplesOutput=0;
    _pointsQueued=0;

    // read back the actual sample rate
    // _cSamplePerSec=format.nSamplesPerSec;
    _waveOutDevice.Pause();
    _thread.Suspend();

    BUFFER_ST * pBuffer;
    while (_BufferList.size()<45 && _engine->GetBuffer(0, &pBuffer)==S_OK)  // while there are buffers
    {
        WaveHeader *header=GetBufferHeader(pBuffer);
        // setup header
        header->lpData = (char *) pBuffer->ptr;
        header->dwBufferLength = pBuffer->ValidPoints*(_bitsPerSample/8);
        header->dwFlags = 0;    // must be set to zero
        header->dwLoops = 0;        
        // just for now try filling extra space in buffer
        if (header->dwBufferLength < static_cast<DWORD>(pBuffer->Size))
            memset(pBuffer->ptr+header->dwBufferLength,0,pBuffer->Size-header->dwBufferLength);
        _BufferList.PutBuffer((Buffer*)pBuffer);
        _waveOutDevice.Prepare (header);        
        _waveOutDevice.SendBuffer (header);
        _pointsQueued+=pBuffer->ValidPoints;
    }

    ATLTRACE("Total samples queued at start: %d\n", _pointsQueued);
    return S_OK;
}

STDMETHODIMP SoundDA::Trigger ()
{
    AUTO_LOCK;
    while (_thread.Resume()>1); // incase multiple suspends

    _waveOutDevice.Restart();
    return S_OK;
}


STDMETHODIMP SoundDA::GetStatus(hyper * samplesProcessed, BOOL * running)
{
    AUTO_LOCK;
    *running = _running;
    if (_running)
    {
        *samplesProcessed=_waveOutDevice.GetPosSample();
    }
    else
        *samplesProcessed=_samplesOutput;
    return S_OK;
}
