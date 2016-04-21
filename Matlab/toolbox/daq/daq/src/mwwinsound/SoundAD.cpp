// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.1.6.2 $  $Date: 2003/12/04 18:40:16 $


// SoundAD.cpp : Implementation of mwwinsound and DLL registration.

#include "stdafx.h"
#include "daqmex.h"
#include "errors.h"

// For DAQ Partners, the following line should be uncommented.
//#include "mwexample.h"

// For DAQ Partners, the following line should be commented out.
#include "mwwinsound.h"

#include "SoundAD.h"
#include <comcat.h>
#include <mmreg.h>
#include <math.h>   // modf
#include <sarrayaccess.h>
#include "util.h"
#include <objbase.h>

#ifdef _DEBUG
#undef THIS_FILE
#undef DEBUG_NEW
static char THIS_FILE[]=__FILE__;
#define DEBUG_NEW new(_NORMAL_BLOCK, THIS_FILE, __LINE__)
#define new DEBUG_NEW
#endif
#define AUTO_LOCK TAtlLock<SoundAD> _lock(*this)


/////////////////////////////////////////////////////////////////////////////

// object constructor:
// initialize data members
SoundAD::SoundAD() : 
_chanSkewMode(CHAN_SKEW_NONE),
_chanSkew(0),
_bitsPerSample(16),
_standardSampleRates(true),
_isStarted(false),
_triggerConditionValue(0),
#pragma warning(disable: 4355) // 'this' used before initialized
_thread(ThreadProc,this),
_isDying(0),
#pragma warning(default: 4355)
_lastBufferGap(false),
_GapTime(0),
_id(0)
{
    ATLTRACE("Sound Driver Open\n");
}

// Register the property with a local variable
// This is so that when SetProperty is called
// the local variables get updated
CComPtr<IProp> SoundAD::RegisterProperty(LPWSTR name, DWORD dwUser)
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


//
// Set the fields needed for DaqHwInfo
//
HRESULT SoundAD::SetDaqHwInfo()
{
    
    CComPtr<IProp> prop;       

    // hwinfo property container
    HRESULT hRes = GetProperty(L"daqhwinfo",&prop);
    CComQIPtr<IPropContainer, &__uuidof(IPropContainer)>  pCont(prop);   
        
    // total channels
    CComVariant var,vids;
    short ids[]={1,2};
    if (WaveCaps.IsStereo(_id))
    {
        var=2L;
        CreateSafeVector(ids,2,&vids);
    }
    else
    {
        var=1L;
        CreateSafeVector(ids,1,&vids);
    }
    
    hRes = pCont->put_MemberValue(CComBSTR(L"totalchannels"),var);
    if (!(SUCCEEDED(hRes))) return hRes;

    // device Id
    wchar_t idStr[8];
    swprintf(idStr, L"%d", _id);
    hRes = pCont->put_MemberValue(CComBSTR(L"id"), CComVariant(idStr));		
    if (!(SUCCEEDED(hRes))) return hRes;   

    // single ended channels
    hRes = pCont->put_MemberValue(CComBSTR(L"singleendedids"), vids);
    if (!(SUCCEEDED(hRes))) return hRes;

    // subsystem type
    hRes = pCont->put_MemberValue(CComBSTR(L"subsystemtype"),CComVariant(L"AnalogInput"));
    if (!(SUCCEEDED(hRes))) return hRes;

    // autocal
    //hRes = pCont->put_MemberValue(CComBSTR(L"autocalibrate"),CComVariant(0L));
    //if (!(SUCCEEDED(hRes))) return hRes;
    
    hRes = pCont->put_MemberValue(CComBSTR(L"sampletype"),CComVariant(1L));
    if (!(SUCCEEDED(hRes))) return hRes;

    bool support16bit = WaveCaps.Supports16Bit(_id);
    // number of bits    
    var = support16bit ? 16L : 8L;
    hRes = pCont->put_MemberValue(CComBSTR(L"bits"),var);
    if (!(SUCCEEDED(hRes))) return hRes;
    
    hRes = pCont->put_MemberValue(CComBSTR(L"adaptorname"), CComVariant(L"winsound"));
    if (!(SUCCEEDED(hRes))) return hRes;

    hRes = pCont->put_MemberValue(CComBSTR(L"vendordriverdescription"),
	CComVariant(L"Windows Multimedia Driver"));
    if (!(SUCCEEDED(hRes))) return hRes;
       
    hRes = pCont->put_MemberValue(CComBSTR(L"vendordriverversion"),CComVariant(WaveCaps.GetDriverVersion(_id)));
    if (!(SUCCEEDED(hRes))) return hRes;

    hRes = pCont->put_MemberValue(CComBSTR(L"polarity"), CComVariant(L"Bipolar"));
    if (!(SUCCEEDED(hRes))) return hRes;

    hRes = pCont->put_MemberValue(CComBSTR(L"coupling"), CComVariant(L"AC Coupled"));
    if (!(SUCCEEDED(hRes))) return hRes;

    
    // device name  
    CComVariant val;
    V_VT(&val) = VT_BSTR;
    V_BSTR(&val) = (WaveCaps.GetDeviceName(_id)).copy();
    hRes = pCont->put_MemberValue(CComBSTR(L"devicename"),val);
    if (!(SUCCEEDED(hRes))) return hRes;
    val.Clear();    

    // native data type
    var = support16bit ? VT_I2 : VT_UI1;
    hRes = pCont->put_MemberValue(CComBSTR(L"nativedatatype"), var);	
    if (!(SUCCEEDED(hRes))) return hRes;

    // conversion offset
    //var = support16bit ? 0 : 128;
    //hRes = pCont->put_MemberValue(CComBSTR(L"conversionoffset"),var);
    //if (!(SUCCEEDED(hRes))) return hRes;

    // Set sample rate Range

    RETURN_HRESULT(SetSampleRateRange(8000,static_cast<long>(WaveCaps.GetMaxSampleRate(_id))));

    // input ranges --> move to input group    
    SAFEARRAY *ps = SafeArrayCreateVector(VT_R8, 0, 2);
    if (ps==NULL) 
	throw "Failure to create SafeArray.";

    val.parray=ps;
    val.vt = VT_ARRAY | VT_R8;

    double *pr;
    
    HRESULT hr = SafeArrayAccessData(ps, (void **) &pr);
    if (FAILED (hr)) 
    {
        SafeArrayDestroy (ps);
        throw "Failure to access SafeArray data.";
    }       

    pr[0]=-1;
    pr[1]=1;
   
    SafeArrayUnaccessData (ps);

    hRes = pCont->put_MemberValue(CComBSTR(L"inputranges"), val);	
    if (!(SUCCEEDED(hRes))) return hRes;    

    prop.Release();
    return S_OK;
}

//
// This is called by the engine when the constructor is called
// An engine interface is passed in and stored in a member variable
// Optional parameters such as ID are passed in as s1, s2, s3.
//
STDMETHODIMP SoundAD::Open(IDaqEngine *engine, int id)
{
    // assign the engine access pointer
    CComVariant val,minvar,maxvar;
    _engine = engine;
    _ASSERTE(engine!=NULL);
    _id=id; 
    UINT nDevs=waveInGetNumDevs();

    // make sure there is at least one sound card installed
    if (nDevs<1) 
	return E_NO_DEVICE;       
      

    if (_id<0 || _id>nDevs-1) return E_INVALID_DEVICE_ID;
    CmwDevice::Open(engine);
    // common properties 
    _cSamplesPerSec.Attach(GetPropRoot(),L"SampleRate");
    _cSamplesPerSec.SetDefaultValue(CComVariant((int)WaveFormat.nSamplesPerSec));
    _cSamplesPerSec=WaveFormat.nSamplesPerSec;

    CComPtr<IProp> prop;       

    prop = RegisterProperty(L"ChannelSkew", (DWORD)&_chanSkew);       
    minvar=maxvar=0;
    prop->SetRange(&minvar, &maxvar);
    prop.Release();

    bool supports16Bit=WaveCaps.Supports16Bit(_id);
    HRESULT hRes;
    // sixteen-bit boards also support 8-bit mode
    if (supports16Bit)
    {
        hRes = _EnginePropRoot->CreateProperty(L"BitsPerSample", &CComVariant(16L),__uuidof(IProp),(void**) &prop);     
        if (!(SUCCEEDED(hRes))) return hRes;

	minvar=8L; maxvar=32L;
	prop->SetRange(&minvar, &maxvar);
    }
    else    
    {
        hRes = _EnginePropRoot->CreateProperty(L"BitsPerSample", &CComVariant(8L), __uuidof(IProp),(void**) &prop);     
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
    prop=_standardSampleRates.Create(_EnginePropRoot,L"StandardSampleRates");
   // hRes = _EnginePropRoot->CreateProperty(L"StandardSampleRates", &CComVariant(true),  __uuidof(IProp),(void**) &prop);
    //prop->put_User((long)&_standardSampleRates);
    prop->put_IsReadonlyRunning(true);
    prop.Release();
    
    // ChannelSkewMode is read-only and defaults to NONE
    hRes=GetProperty(L"ChannelSkewMode", &prop);
    if (!(SUCCEEDED(hRes))) return hRes;        
    prop->put_User((long)&_chanSkewMode);
    prop->ClearEnumValues();
    prop->AddMappedEnumValue(CHAN_SKEW_NONE,L"None");
    prop->put_DefaultValue(CComVariant(CHAN_SKEW_NONE));
    prop->put_Value(CComVariant(CHAN_SKEW_NONE));
    prop.Release();   

    // Channel ranges
    
    // set input range to default to [-1 1]
    static double Neg1To1[]={-1,1};
    CreateSafeVector(Neg1To1,2,&val);

    hRes = GetChannelProperty(L"inputrange", &prop);
    if (!(SUCCEEDED(hRes))) return hRes;        

    prop->put_DefaultValue(val);
    hRes = prop->put_User(INPUTRANGE);
    if (!(SUCCEEDED(hRes))) return hRes;    

    minvar=-1.0;
    maxvar=1.0;
    prop->SetRange(&minvar,&maxvar);

    prop.Release();

    hRes = GetChannelProperty(L"unitsrange", &prop);
    if (!(SUCCEEDED(hRes))) return hRes;        
    prop->put_DefaultValue(val);
    prop.Release();

    hRes = GetChannelProperty(L"sensorrange", &prop);
    if (!(SUCCEEDED(hRes))) return hRes;        
    prop->put_DefaultValue(val);
    prop.Release();

    
    hRes = SetDaqHwInfo();
    if (!(SUCCEEDED(hRes))) return hRes;      

    // inputType (channel type)
    _EnginePropRoot->CreateProperty(L"InputType", NULL,__uuidof(IProp),(void**) &prop);    
    prop->AddMappedEnumValue(0L, L"AC-Coupled");
    prop.Release();
    
    // create L and R channels and set the range (index) values
    hRes = GetChannelProperty(L"HwChannel", &prop);
    if (!(SUCCEEDED(hRes))) return hRes;
    prop->put_User((long)HWCHAN);
    prop->put_DefaultValue(CComVariant(1L));
    
    if (WaveCaps.IsStereo(_id))
        prop->SetRange(&CComVariant(1L),&CComVariant(2L));
    else
        prop->SetRange(&CComVariant(1L),&CComVariant(1L));
    
    prop.Release();
    
    _thread.Resume();
    _thread.SetThreadPriority(THREAD_PRIORITY_TIME_CRITICAL);
    
    return S_OK;
}

//
// This is called by the engine when a property is set
// An interface to the property along with the new value is passed in
//
STDMETHODIMP SoundAD::SetProperty(long User, VARIANT * NewValue)  // return false for fail
{
    
    if (User)
    {	
	
        // variant_t is a more friendly data type to work with
	variant_t *var = (variant_t*)NewValue;       
       
	// special case: if bitsPerSample is being changed, we
	// need to update the daqHwInfo to reflect this
	//
	if (User==(long)&_bitsPerSample)
	{        
	    
       	    // set the daqHwInfo value which depends on the BitsPerSample property
            double offset;
	    // set the data type to match the bits, default is Int16
                long datatype;
                long bits=*var;
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
                HRESULT hRes = GetHwInfo()->put_MemberValue(L"nativedatatype",CComVariant(datatype));
                if (!(SUCCEEDED(hRes))) return hRes;
                hRes = GetHwInfo()->put_MemberValue(L"bits",*NewValue);
                if (!(SUCCEEDED(hRes))) return hRes;
                
                WaveFormat.SetBits(static_cast<WORD>(bits));
            // now set the offset value that the engin uses to calculate naiveoffset
            for (int i=0;i<_nChannels;i++)
            {
                AICHANNEL *chan;
                _EngineChannelList->GetChannelStructLocal(i,(NESTABLEPROP**)&chan);
                chan->ConversionOffset=offset;
            }

            // set the default offset
            CComPtr<IPropRoot> iProp;
            GetChannelProperty(L"conversionoffset",&iProp);
            iProp->put_DefaultValue(CComVariant(offset));

	}        
        else if (User==(long)&_triggerConditionValue)
        {
            CComPtr<IPropValue> iProp;
            HRESULT hRes = GetProperty(L"TriggerCondition", &iProp);
            if (FAILED(hRes)) return hRes;	   
            
            // if the trigger condition is set to none,
            // issue a warning that triggercondition value 
            // will be ignored.
            variant_t triggerCond;
            iProp->get_Value(&triggerCond);
            if ((long)triggerCond==TRIG_IMMEDIATE)
            {
                hRes = _engine->WarningMessage(L"TriggerConditionValue will be ignored while TriggerCondition is NONE.");
                if (FAILED(hRes)) return hRes;
            }  
            

        }
        // must be able to set these to their default value
        else if (User==(long)&_chanSkewMode)
        {
            if ((long)*var!=CHAN_SKEW_NONE)
                return E_INV_SKEW_MODE;
        }
        else if (User==(long)&_chanSkew)
        {
            if ((double)*var!=0.0)
                return E_INV_SKEW_VALUE;
        }
	else if (User==(long)&_standardSampleRates)
	{
                
            if ((bool)(*var) == true){
	        // Need to snap current SampleRate to one of the standard samplerates.
                // A one percent tolerance is given.  
                // Ex. 8080 snaps to 8000 not 11025.
                _cSamplesPerSec=SnapSampleRates(_cSamplesPerSec);
                WaveFormat.SetRate(_cSamplesPerSec);
                RETURN_HRESULT(SetSampleRateRange(8000,static_cast<long>(WaveCaps.GetMaxSampleRate(_id))));
            }else{
                // SampleRate can be set to a maximum of 96000Hz.
                RETURN_HRESULT(SetSampleRateRange(5000,96000));
            }

	}
	else if (User==(long)&_cSamplesPerSec)
	{
		// SampleRate has been chosen.  Depending on standardSampleRates value
		// may need to snap specified SampleRate to 8000, 11025, 22050, 44100,
		// 48000.  A one percent tolerance is given.
		double newrate=*var;		
		if (_standardSampleRates)
                {
                   // StandardSampleRates is on.  Need to snap the value that is being set to
                   // either 8000, 11025, 22050, 44100, .
		   newrate=SnapSampleRates(newrate);
                }
		else 
                {   // StandardSampleRates is off.  Don't need to snap but do need to 
		    // round up to the next integer value.
				
		    // Get the fraction portion of the SampleRate (8050.50)
           	    double n;   
		    double fraction=modf(newrate, &n);
				
		    // If not a fraction round up.
                    if (fraction!=0.0){
			newrate=(long)++n;
                    }
                }		    
                *var=newrate;
                WaveFormat.SetRate(static_cast<DWORD>(newrate));
	}
	
	// set the local value
	((CLocalProp*)User)->SetLocal(*var);
    
    }    
    
    return S_OK;
}



//
// This is called by the engine to set channel properties
// Inputs:
//      channel property interface
//      property container interface
//      channel pointer
//      new property value

STDMETHODIMP SoundAD::SetChannelProperty(long User, tagNESTABLEPROP * pChan, VARIANT * NewValue)

{

    int chan=pChan->Index;   
   
    long numChans;
    
    HRESULT hRes = _EngineChannelList->GetNumberOfChannels(&numChans);
    if (FAILED(hRes)) return hRes;
        

        if (User==HWCHAN) 
        {
            variant_t val = (variant_t*)NewValue;
            if (V_VT(NewValue)==VT_R8 && (double)val!=chan)
                return E_INVALID_CHANNEL;
        }    
        // Winsound supports only an input range of [-1 1]
        else if (User==INPUTRANGE)
        {
            if (V_ISARRAY (NewValue) || V_ISVECTOR (NewValue))
            {                            
                SAFEARRAY *ps = NewValue->parray;
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
                    return E_INV_INPUT_RANGE;
                }
                
                SafeArrayUnaccessData (ps);
            }

        }
/*       
    else    // constructor for the channel
*/
    if (numChans!=_nChannels)
        _nChannels = numChans;       
    
    return S_OK;
}

// 
// Clean up when object is deleted
//
SoundAD::~SoundAD()
{
    Stop();
    _isDying++;
    _thread.Resume();
    _BufferDoneEvent.Set();
    _thread.WaitForDeath();
    _waveInDevice.Close ();
    ATLTRACE("Sound Driver Close\n");
}




//CHECKBUFFERSDONE: Called during stop to see if any remaining buffers need to 
//		    be processed before completely stoping
void SoundAD::CheckBuffersDone()
{
    // Check to see if any remaining buffers need to be processed
    while (IsBufferDone ())
    {
        ProcessDoneBuffer();
    }
}




// THREADPROC: 
// This is the thread procedure which processes
// buffers as they are marked done.
//
unsigned WINAPI SoundAD::ThreadProc(void* pArg)
{
    CoInitialize(NULL);
    try {
        SoundAD* thisptr=(SoundAD*) pArg;

	// Loop until the thread in the reference object is marked as dying
        while(!thisptr->_isDying)
        {
	    // If not dying, wait forever for event to be signaled
            thisptr->_BufferDoneEvent.Wait();
	    // A Buffer is done, now process
            thisptr->ProcessBuffers();
       }
    }
    catch (...)
    {
	//Something bad happened and we are going to stop this thread
        _RPT0(_CRT_ERROR,"***** Exception in Sound Thread Terminating Thread\n");
    }
    return 0;
}

//PROCESSBUFFERS: Called by the thread to process a done buffer
void SoundAD::ProcessBuffers()
{
    bool PutFlag;
    AUTO_LOCK;
    
    do
    {
	PutFlag=false;
	// Check to see if there the next buffer is marked done
        if (IsBufferDone())
        {
	    // Process buffers ready to be returned to the engine
            ProcessDoneBuffer();	    
	    
	    
	    // Reclaim a buffer if less than 20 are being used
	    if (_BufferList.size()<20)
	    {
		// Call PUTBUFFER to get a new buffer
		PutFlag=PutBuffer();
	    }
	    else
	    {
		// Did not get a new buffer
		PutFlag=false;
	    }	
	}
	// Recheck if there are no done buffers and he object is not dying
    } while ( (IsBufferDone() || PutFlag) && !_isDying);
}




// ISBUFFERDONE: Returns TRUE if Buffers are ready to be processed.
bool SoundAD::IsBufferDone()
{
    // _BufferList holds buffers full of newly acquired data

    // Check to see that there are buffers in the list
    if (_BufferList.size()==0) 
        return false;

    // Get a pointer to the next buffer from the front of list
    Buffer* pBuf=_BufferList.NextBuffer();
    
    // Check to see if the WAVEHEADER is marked done for this buffer
    return GetBufferHeader(pBuf)->IsDone(); 
}

// PROCESSDONEBUFFER: This function is only called from ProcessBuffers when 
//			a buffer is detected as being marked DONE.		      
void SoundAD::ProcessDoneBuffer()
{
	// Get a pointer to a DONE Buffer from the front of the list. Buffer is removed from list
        Buffer *pBuf=_BufferList.GetBuffer();

	// Get a pointer to the header information
        WaveHeader *hdr=GetBufferHeader(pBuf);

	// Unprepares a buffer to be freed
        _waveInDevice.UnPrepare (hdr);
        hdr->dwFlags &= ~WHDR_PREPARED;

	//Convert the number of bytes recorded to samples
        pBuf->ValidPoints=WaveFormat.Bytes2Points(hdr->dwBytesRecorded);
	
	// ????????????
        if (_lastBufferGap)
        {
            pBuf->Flags |= BUFFER_GAP_BEFORE;

	    // Get the time from the engine
            double time;
            _engine->GetTime(&time);
            
            _PointsThisRun+=static_cast<__int64>(floor((time-_GapTime)*_cSamplesPerSec)*_nChannels);
            _lastBufferGap=false;
        }


	// Set the STARTING point for samples acquired this run
        pBuf->StartPoint=_PointsThisRun;

	// Set the ENDING point for samples acquired this run
        _PointsThisRun+=pBuf->ValidPoints;


	// Used to modify the data if not 16 bitspersample
        if (WaveFormat.Points2Bytes(1)==3) 
        {
            unsigned char *ptr=pBuf->ptr+(pBuf->ValidPoints-1)*3;
            int *iptr=(int*)pBuf->ptr+(pBuf->ValidPoints-1);
            for (int i=pBuf->ValidPoints-1;i>0;i--) // copy from tail to head to avoid coruption
            {
                *iptr--=((int)*(char*)ptr<<16) || (ptr[1] << 8) || ptr[2];
                ptr-=3;
            }
        }

	// Check to see if there are no Buffers in the filled list and object is started
        if ( (_BufferList.size()==0) && _isStarted)
        {
	    // ??????????????????
            _lastBufferGap=true; 
	    
	    // Get the  time from the engine
            _engine->GetTime(&_GapTime);

	    // If the buffer is marked as the last buffer
            if (pBuf->Flags & BUFFER_IS_LAST)
            {
                // we are done ...
		// Call to the engine to transfer the buffer
		_engine->PutBuffer(pBuf);

		// Clear the buffer pointer
		pBuf=NULL;
                
		// Stop the Sound Card 
		Stop();

		// Post a STOP event in the event log
                _engine->DaqEvent(EVENT_STOP, 0, _PointsThisRun/_nChannels, NULL);
                
            }
            else
            {
                ATLTRACE("Winsound datamissed\n");
                _engine->DaqEvent(EVENT_DATAMISSED, 0, -1, CComBSTR(L"Data Missed"));
            }
        }
	
	// Process buffer and continue
	if (pBuf!=NULL) _engine->PutBuffer(pBuf);            
}


//
//
// This is called by the engine to clean up 
// the allocated memory.
//
STDMETHODIMP SoundAD::FreeBufferData(BUFFER_ST* Buf) 
{   
    WaveHeader *hdr=GetBufferHeader(Buf);
    if (hdr->dwFlags & WHDR_PREPARED)
        _waveInDevice.UnPrepare (hdr);
    delete hdr;
    CmwDevice::FreeBufferData(Buf);; 
    return S_OK;
}

//
// called by the engine to stop the device
//
STDMETHODIMP SoundAD::Stop()
{
    if (_isStarted)
    {
        ATLTRACE("Stopping sound card\n");
        
        _isStarted = false;
        _waveInDevice.Reset ();
        AUTO_LOCK;
        int l=0;
        // now unprepare all buffers
        _waveInDevice.Close();
        CheckBuffersDone();
    }
    return S_OK;
}

// This is called by the engine when a buffer is ready to be
// fed to the hardware
HRESULT SoundAD::BufferReadyForDevice()
{
    AUTO_LOCK;
    long size=_BufferList.size();
    if (_isStarted && size<20)
    {   
        long status=S_OK;
        while (size++<20 && PutBuffer()) ;  // while there are buffers put them
    }
    return S_OK;
}

// PUTBUFFER: Get a buffer from the engine and configure the header information
//	      Return TRUE if buffer was obtained.
bool SoundAD::PutBuffer()
{
    BUFFER_ST *pBuffer;
    AUTO_LOCK;
    long status=S_OK;
    bool retval=true;

    // Call into the engine to get a buffer
    status=_engine->GetBuffer(0, &pBuffer);

    // If a buffer was returned from the engine
    if (status==S_OK )  
    {    
	// Get a pointer to the header data
        WaveHeader *header=GetBufferHeader(pBuffer);
        
	// format header data
        header->dwFlags &=~WHDR_DONE; //clear done flag
        header->dwBytesRecorded=0;


        if ( !(header->dwFlags & WHDR_PREPARED))  // will alwase be true
        {
            header->dwUser=(DWORD)pBuffer;
            header->lpData = (char *) pBuffer->ptr;
            header->dwBufferLength = WaveFormat.Points2Bytes(pBuffer->ValidPoints);
            

            _waveInDevice.Prepare (header);
        }
        if (pBuffer->Flags & BUFFER_IS_LAST)
        {
            retval=false; // do not call again
        }
        pBuffer->ValidPoints=0;
        _BufferList.PutBuffer((Buffer*)pBuffer);
        _waveInDevice.SendBuffer (header);
    }
    else
    {
        if (status==DE_NOT_RUNNING)
        {
            Stop();
            _engine->DaqEvent(EVENT_STOP, 0, _PointsThisRun/_nChannels, NULL);
        }
        retval=false;
    }
    return retval; 
}

//
// This is called by the engine to start the device
//

HRESULT SoundAD::WaveInError(MMRESULT err)
{
    TCHAR str[MAXERRORLENGTH+1];
    waveInGetErrorText(err,str,MAXERRORLENGTH);
    return Error(str);
}

STDMETHODIMP SoundAD::Start ()
{
    AUTO_LOCK;
    _lastBufferGap=false;
    _PointsThisRun=0;
    WaveFormat.SetChannels(_nChannels);

    MMRESULT result = waveInOpen(0, _id, &WaveFormat, 0, 0, WAVE_FORMAT_QUERY  );
    if (result!=MMSYSERR_NOERROR )
    {
        if (result==WAVERR_BADFORMAT)
            return E_INVALID_FORMAT;
        else
            return WaveInError(result);
    }
    
    _waveInDevice.Open (_id, WaveFormat,(DWORD)(HANDLE)_BufferDoneEvent ,NULL ,CALLBACK_EVENT);
    if (!_waveInDevice.Ok())
    {
        if (_waveInDevice.isInUse())
            return E_DEVICE_IN_USE;            
        else
            return WaveInError(result);
       // return FALSE;
    }
    _isStarted = true;
    // read back the actual sample rate
    // _cSamplePerSec=format.nSamplesPerSec;
    // there seems to be a max of 90 buffers in the soundblaster driver on NT
    BufferReadyForDevice();
    return S_OK;
}

STDMETHODIMP SoundAD::Trigger ()
{
    _waveInDevice.Start();
    return S_OK;
}


// utility function the engine may or may not call.
STDMETHODIMP SoundAD::GetStatus(hyper *samplesProcessed, BOOL *running)
{
	// TODO: Add your implementation code here

	return S_OK;
}

