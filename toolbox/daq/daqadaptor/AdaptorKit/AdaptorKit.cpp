// Adaptor.cpp : Implementation of CAdaptor
// Copyright 1998-2003 The MathWorks, Inc.
// $Revision: 1.3.4.3 $  $Date: 2003/08/29 04:44:05 $
#include <stdafx.h>
#include <math.h>
#include "AdaptorKit.h"

// this file requires the winmm library
#pragma comment( lib, "winmm" )


// {6FE55F7B-AF1A-11d3-A536-00902757EA8D}
extern "C" const CATID __declspec(selectany)CATID_ImwAdaptor=
    { 0x6fe55f7b, 0xaf1a, 0x11d3, { 0xa5, 0x36, 0x0, 0x90, 0x27, 0x57, 0xea, 0x8d } };
// Other GUIDS
extern "C" const GUID __declspec(selectany) LIBID_DAQMEXLib =
    {0x5da5a732,0xd462,0x11d1,{0x90,0xbe,0x00,0x60,0x08,0x41,0xf9,0xff}};
extern "C" const GUID __declspec(selectany) IID_ImwAdaptor =
    {0x69ca3484,0x95f5,0x11d3,{0xa5,0x27,0x00,0x90,0x27,0x57,0xea,0x8d}};
extern "C" const GUID __declspec(selectany) IID_IPropContainer =
    {0xe79d1b45,0xdf5f,0x11d1,{0x90,0xc1,0x00,0x60,0x08,0x41,0xf9,0xff}};
extern "C" const GUID __declspec(selectany) IID_ImwDevice =
    {0x42680178,0x65fa,0x11d3,{0xa5,0x1b,0x00,0x90,0x27,0x57,0xea,0x8d}};
extern "C" const GUID __declspec(selectany) IID_ImwInput =
    {0x42680175,0x65fa,0x11d3,{0xa5,0x1b,0x00,0x90,0x27,0x57,0xea,0x8d}};
extern "C" const GUID __declspec(selectany) IID_ImwOutput =
    {0x42680176,0x65fa,0x11d3,{0xa5,0x1b,0x00,0x90,0x27,0x57,0xea,0x8d}};
extern "C" const GUID __declspec(selectany) IID_ImwDIO =
    {0x42680177,0x65fa,0x11d3,{0xa5,0x1b,0x00,0x90,0x27,0x57,0xea,0x8d}};
extern "C" const GUID __declspec(selectany) IID_IPropRoot =
    {0x8beefabe,0xe54a,0x11d3,{0xa5,0x51,0x00,0x90,0x27,0x57,0xea,0x8d}};
extern "C" const GUID __declspec(selectany) IID_IProp =
    {0x0bfa2913,0xd48e,0x11d1,{0x90,0xbe,0x00,0x60,0x08,0x41,0xf9,0xff}};
extern "C" const GUID __declspec(selectany) IID_IDaqEngine =
    {0x8beefabf,0xe54a,0x11d3,{0xa5,0x51,0x00,0x90,0x27,0x57,0xea,0x8d}};
extern "C" const GUID __declspec(selectany) IID_IChannelList =
    {0x8beefac1,0xe54a,0x11d3,{0xa5,0x51,0x00,0x90,0x27,0x57,0xea,0x8d}};
extern "C" const GUID __declspec(selectany) IID_IDaqEnum =
    {0xf3f93b7f,0x93c7,0x11d3,{0xa5,0x26,0x00,0x90,0x27,0x57,0xea,0x8d}};
extern "C" const GUID __declspec(selectany) IID_IDaqMappedEnum =
    {0xf3f93b80,0x93c7,0x11d3,{0xa5,0x26,0x00,0x90,0x27,0x57,0xea,0x8d}};

CComQIPtr<IProp>& CRemoteProp::Attach(IPropContainer *pCont,wchar_t *Name,long UserVal)
{
    Release();
    CHECK_HRESULT(pCont->GetMemberInterface(Name,__uuidof(IProp),(void**)&p));
    _ASSERTE(p!=NULL);
    if (UserVal) 
       CHECK_HRESULT(p->put_User(UserVal));

    return *this;
}

CComQIPtr<IProp>& CRemoteProp::Create(IPropContainer *pCont,wchar_t *Name,const CComVariant& Value)
{
    CHECK_HRESULT( pCont->CreateProperty(Name,(VARIANT*)&Value,__uuidof(IProp),(void**)&p));
    return *this;
}

CmwDevice::CmwDevice():
_updateChildren(true),
_updateProps(true)
{

}

HRESULT CmwDevice::InitHwInfo(VARTYPE DataType,int DataBits,int maxchannels,INPUTTYPE inType,LPCWSTR adaptorname,LPCWSTR hwname)
{
    CComPtr<IProp> prop;        

    wchar_t tmpString[512];
    CComVariant vids;    
    // we expect the ini file to be in the same directory as the application,
    // namely, this DLL. It's the only way to find the file if it's not
    // in the windows subdirectory


    // device Id
    DEBUG_HRESULT(_DaqHwInfo->put_MemberValue(L"totalchannels",CComVariant(maxchannels)));

    CreateSafeVector((short*)NULL,maxchannels,&vids);
    TSafeArrayAccess<short> ids(&vids);
    for (int i=0;i<maxchannels;i++)
    {
        ids[i]=i;
    }

    switch (inType)
    {
    case OUTPUT:
        DEBUG_HRESULT( _DaqHwInfo->put_MemberValue(L"channelids", vids));
        break;
    case SE_INPUT:
        DEBUG_HRESULT( _DaqHwInfo->put_MemberValue(L"singleendedids", vids));
        break;
    case DI_INPUT:
        DEBUG_HRESULT( _DaqHwInfo->put_MemberValue(L"differentialids", vids));
        break;
    case 3:
        DEBUG_HRESULT( _DaqHwInfo->put_MemberValue(L"singleendedids", vids));
        {
            TSafeArrayVector<short> ids;
            ids.Allocate(maxchannels/2);
            for (int i=0;i<maxchannels/2;i++)
            {
                ids[i]=i;
            }
            
            DEBUG_HRESULT( _DaqHwInfo->put_MemberValue(L"differentialids", ids));
        }
    }
    
    
    DEBUG_HRESULT(_DaqHwInfo->put_MemberValue(L"adaptorname", CComVariant(adaptorname)));
    DEBUG_HRESULT(_DaqHwInfo->put_MemberValue(L"devicename",CComVariant(hwname)));

    DEBUG_HRESULT( _DaqHwInfo->put_MemberValue(L"polarity", CComVariant(L"Bipolar")));
    DEBUG_HRESULT( _DaqHwInfo->put_MemberValue(L"coupling", CComVariant(L"Unknown")));
    
    DEBUG_HRESULT(_DaqHwInfo->put_MemberValue(L"nativedatatype",CComVariant(DataType)));
    // number of bits    
    DEBUG_HRESULT(_DaqHwInfo->put_MemberValue(L"bits",CComVariant(DataBits)));

    // Get the Revision numbers
    float DllRevNum=0, DriverRevNum=0;
    //cbGetRevision (&DllRevNum, &DriverRevNum);
    swprintf(tmpString, L"DllVer=%8.4f DriverVer=%8.4f",DllRevNum, DriverRevNum);
    DEBUG_HRESULT( _DaqHwInfo->put_MemberValue(L"vendordriverversion",CComVariant(tmpString)));

    
    return S_OK;

}

CswClockedDevice::CswClockedDevice():
_nChannels(0),
pSampleRate(100)
{
}

double CswClockedDevice::RoundRate(const double& NewRate) 
{
#ifdef USE_HiResTimer
    return NewRate < MAX_SW_SAMPLERATE ? NewRate : MAX_SW_SAMPLERATE;
#else
    return NewRate < MAX_SW_SAMPLERATE ? 1000/floor(1000.0/ NewRate ) : MAX_SW_SAMPLERATE;
#endif
}


HRESULT CswClockedDevice::EnableSwClocking(bool SetAsDefault/*=false*/)
{
    if (SetAsDefault)
    {
        pSampleRate.SetDefaultValue(100);
        pSampleRate=100;
    }

    RETURN_HRESULT(pSampleRate.SetRange(MIN_SW_SAMPLERATE,MAX_SW_SAMPLERATE));
    if (pSampleRate>MAX_SW_SAMPLERATE) 
        pSampleRate=MAX_SW_SAMPLERATE;
    pSampleRate=RoundRate(pSampleRate);
    RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"minsamplerate", CComVariant(MIN_SW_SAMPLERATE)));	
    RETURN_HRESULT(_DaqHwInfo->put_MemberValue(L"maxsamplerate", CComVariant(MAX_SW_SAMPLERATE)));	
    return S_OK;
}

HRESULT CswClockedDevice::Open(IUnknown *Interface)
{
    RETURN_HRESULT(CmwDevice::Open(Interface));
    ATTACH_PROP(SampleRate);
    return S_OK;
    //EnableSwClocking();
}

STDMETHODIMP CswClockedDevice::SetProperty(long User, VARIANT * NewValue)
{
    
    if (User) 
    
    {
        variant_t *val=(variant_t*)NewValue;
        if (User==USER_VAL(pSampleRate))
        {
            // Round to a rate devisible into miliseconds
            *val= RoundRate(*val);
        }

        // Now set the actual value

        ((CLocalProp*)User)->SetLocal(*val);

        _updateProps=true;
    }
    return S_OK;
}

HRESULT CmwDevice::Open(IUnknown *Interface)
{
//    HRESULT hRes;
    // assign the engine access pointer
    _engine = Interface;
    _ASSERT(_engine);
    RETURN_HRESULT(_engine->QueryInterface(&_EngineChannelList));
    //_EngineChannelList=_engine;

    // Both of these methods now work QueryInterface is prefered. 
    //_EnginePropRoot=_engine;
    RETURN_HRESULT(_engine->QueryInterface(&_EnginePropRoot));
    if (_EnginePropRoot==NULL) // R12.0 matlab will need run the next line
    {
        RETURN_HRESULT(_EngineChannelList->GetMemberInterface(NULL,__uuidof(_EnginePropRoot),(void**)&_EnginePropRoot));
    }
    RETURN_HRESULT(GetProperty(L"daqhwinfo",&_DaqHwInfo));
//    ATTACH_PROP(SampleRate); do not put sample rate here it will break dio
    return S_OK;
}


STDMETHODIMP CmwDevice::AllocBufferData(struct tagBUFFER *Buf)
{
    //Buf->ptr = new BYTE[Buf->Size];
    Buf->ptr=(BYTE*)CoTaskMemAlloc(Buf->Size);
    if (Buf->ptr==NULL) return E_OUTOFMEMORY;
    
    return S_OK;
}

//
// FreeBufferData
//
STDMETHODIMP CmwDevice::FreeBufferData(struct tagBUFFER *Buf)
{
    CoTaskMemFree(Buf->ptr);
    Buf->ptr=NULL;  // cleanup not needed but a good idea
    Buf->Size=0; 
    return S_OK;
}

STDMETHODIMP CswClockedDevice::ChildChange(ULONG typeofchange,  tagNESTABLEPROP * pChan)
{
    HRESULT retval=S_OK;
    int progress=typeofchange & 0xff00;
    int type=typeofchange & 0xff;
    if (pChan) // if we have a channel
    {
        switch (type)
        {
        case ADD_CHILD  : //could be begin call or end
            ++_nChannels;
            break;
        case DELETE_CHILD  :
            --_nChannels;
            break;
        }
    }
    if (typeofchange & END_CHANGE)
    {
        retval=UpdateChans(false); 
        _updateChildren=true;
    }
    return retval;
}


// this function should be thought of as an example of how to write your
// own UpdateChans function it is reccommended that your function replace this
// one and not call down to it.
HRESULT CswClockedDevice::UpdateChans(bool ForStart)
{
    _chanList.resize(_nChannels);
     NESTABLEPROP *pNP=NULL;
    if (_updateChildren && ForStart)
    {
#ifdef _DEBUG
        long chancheck=0;
        _EngineChannelList->GetNumberOfChannels(&chancheck);
        _ASSERTE(chancheck==_nChannels);
#endif
        for (int i=0; i<_nChannels; i++) 
        {    
            RETURN_HRESULT(_EngineChannelList->GetChannelStruct(i, &pNP));
            _ASSERTE(pNP);
            _chanList[i]=pNP->HwChan;
            CoTaskMemFree(pNP);
        }
        
        _updateChildren=false;
    }
    else
    {
        // we still need working chanlist and rangelist if no gainlist
    }
    return S_OK;
}


STDMETHODIMP CmwDevice::SetProperty(long User, VARIANT * NewValue)
{    
    if (User) 
    {
        variant_t *val=(variant_t*)NewValue;
        // Now set the actual value

        ((CLocalProp*)User)->SetLocal(*val);

        _updateProps=true;
    }
    return S_OK;
}


STDMETHODIMP CmwDevice::SetChannelProperty(long User, tagNESTABLEPROP * pChan, VARIANT * NewValue)
{
    _updateChildren=true;
    return S_OK;
}


HRESULT CmwDevice::TranslateError(HRESULT code,BSTR *out)
{
    CComBSTR Msg;

    Msg.LoadString(code);
    HRESULT RetVal=S_OK;
    if (Msg.Length()==0)         
    {
        LPTSTR lpBuffer=NULL;
        RetVal=FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_HMODULE |FORMAT_MESSAGE_FROM_SYSTEM,
			_Module.GetModuleInstance(), code,
			MAKELANGID(LANG_NEUTRAL, SUBLANG_SYS_DEFAULT),
			(LPTSTR) &lpBuffer, 0, NULL) ;
        Msg=lpBuffer;
        LocalFree(lpBuffer);
    }
    *out = Msg.Detach();
    return RetVal;
}

// ******************* TIMER FUNCTIONS ************************

// Low resolution timer used for acquisition callbacks
LowResTimer::LowResTimer(int resolution):
wTimerID(0)
{
    TIMECAPS tc;
    timeGetDevCaps(&tc, sizeof(TIMECAPS));
    // Create manual reset event in the signaled state
    hTimerPending = CreateEvent (NULL, TRUE, TRUE, NULL);
    
    // Get the resolution closest to the requested resolution while being in range
    wTimerRes = min(max(tc.wPeriodMin, resolution), tc.wPeriodMax);
    
    // Set the timer to the resolution
    timeBeginPeriod(wTimerRes); 
}


LowResTimer::~LowResTimer() 
{
    // Verify that the timer event has occurred
    Stop();
    // Clears the timer resolution
    timeEndPeriod(wTimerRes);
    // Close the timer handle
    CloseHandle(hTimerPending);
}

// CALLIN: Starts a one-shot timer with the specified delay (in milliseconds).
// Returns TRUE if timer was created.
bool LowResTimer::CallIn(double times)
{
    // Determine the integer portion of the delay in milliseconds
    UINT time = static_cast<UINT>(floor(times*1000));
    _ASSERTE(time>=1);

    // Reset the associated event
    ResetEvent(hTimerPending);
    
    
    _ASSERTE(wTimerID==NULL); // Verify not using a different Timer ID
	
    // Start the timer to run once for the specified delay and store the 
    // timer ID.    
    wTimerID = timeSetEvent(
        time,                    // delay
        wTimerRes,               // resolution (global variable)
        localOneshotFunc,        // callback function
        (DWORD)this,             // Specify this timer object
        TIME_ONESHOT );          // single timer event
    
    // Return TRUE of a valid TIMER ID was created
    return wTimerID!=0;
}

// LOCALONESHOTFUNC: Callback function for use with a one-shot timer
void CALLBACK LowResTimer::localOneshotFunc(UINT wTimerID, UINT msg, 
                                            DWORD dwUser, DWORD dw1, DWORD dw2) 
{ 
    // Get a pointer to timer object passed in
    Ty* thisptr=(Ty*)dwUser;      
    
    // Verify that this the correct timer (??)
    if (thisptr->wTimerID==NULL) 
    {
        ATLTRACE("Bogus Call to timer \n");
    }
    else
    {	
	// Set the associated timer event
	SetEvent(thisptr->hTimerPending);
	
	// Call the actual callback function specified for this timer by user
	if (!thisptr->CallbackFunction(thisptr->CallbackParam))
	{
	    _RPT0(_CRT_WARN,"User Callback did not return TRUE");
	}
    }

    // Stop and clear the timer ID (no longer in use)
    thisptr->Stop();
	
} 


// CALLPERIOD: Starts a periodic timer with the secified delay (in milliseconds).
// Returns TRUE if timer was created.
bool LowResTimer::CallPeriod(double deltas) // returns true for success
{
    // Reset the associated event
    ResetEvent(hTimerPending);

    // Determine the integer portion of the delay in milliseconds
    UINT delta=static_cast<UINT>(floor(deltas*1000));
    _ASSERTE(delta>=1);

    _ASSERTE(wTimerID==NULL); // Verify not losing a different Timer ID
	
    // Start the timer to run once for the specified delay and store the 
    // timer ID.    
    wTimerID = timeSetEvent(
        delta,                    // delay
        wTimerRes,                // resolution (global variable)
        localTimerFunc,           // callback function
        (DWORD)this,              // specify this timer object
        TIME_PERIODIC | TIME_CALLBACK_FUNCTION);          // single timer event

    _RPT2(_CRT_WARN,"Created TimerID = %d, with a delay of %d\n", wTimerID, delta);
    // Return TRUE of a valid TIMER ID was created
    return wTimerID!=0;
}


// LOCALTIMERFUNC: Timer callback function for use with continuous timer events
void CALLBACK LowResTimer::localTimerFunc(UINT wTimerID, UINT msg, 
                                          DWORD dwUser, DWORD dw1, DWORD dw2) 
{ 
    bool error = false;
    // Get a pointer to timer object passed in
    Ty* thisptr=(Ty*)dwUser; 
    
    // Set the associated timer event
    SetEvent(thisptr->hTimerPending);
    
    // Call the actual callback function specified for this timer by user
    if (!thisptr->CallbackFunction(thisptr->CallbackParam))
    {
	_RPT0(_CRT_WARN,"User Callback did not return TRUE\n");
	error = true;
    }

    // Check to see if we should stop callbacks due to error
    if (error)
    {
	// Set event so that we stop without further error
	SetEvent(thisptr->hTimerPending);
	// Stop timer
	thisptr->Stop();
    }
} 


// STOP: Used to clear the associated timer event and ID.
// Do not call this function from the timer callback
void LowResTimer::Stop() 
{
    // Check to see if waiting for timer event
    int status=WaitForSingleObject(hTimerPending, 1000);

    // If waiting for our timer
    if (status==WAIT_TIMEOUT && wTimerID)
    {                
	// Report DEBUG error that we are caught waiting for event
        _RPT0(_CRT_ERROR,"Timeout waiting for timer to stop\n");        
    }

    _RPT1(_CRT_WARN,"Killing TimerID = %d, \n", wTimerID);

    // Stop the timer
    timeKillEvent(wTimerID);  // cancel the event
    
    // Clear the timer ID
    wTimerID = NULL; 
}





HiResTimer::HiResTimer()
{
    FastTimerInit();
}


bool HiResTimer::CallPeriod(double deltas) // returns true for success
{
    ResetEvent(hTimerPending);
    Error=0;
    Shutdown=false;
    Period=deltas;
    Time = FastTimer();
    Delay=floor(deltas*1000)-1;
    _ASSERTE(Delay>=1);
    //if (delta<=0) delta=1;
    wTimerID = timeSetEvent(
        Delay,                    // delay
        wTimerRes,                     // resolution (global variable)
        localTimerFunc,               // callback function
        (DWORD)this,                  // user data
        TIME_ONESHOT );                // single timer event
    return wTimerID!=0;
}


void CALLBACK HiResTimer::localTimerFunc(UINT wTimerID, UINT msg, 
                                          DWORD dwUser, DWORD dw1, DWORD dw2) 
{ 
    Ty* thisptr=(Ty*)dwUser;             // pointer to data 
// spin loop
    if (thisptr->wTimerID!=wTimerID || thisptr->Shutdown)
    {
        // this is the flag to stop the timers
        SetEvent(thisptr->hTimerPending);
        return ;
    }

   /* Wait until period is over */
   thisptr->OldTime = thisptr->Time;
   do
     {
      thisptr->Time = FastTimer();
     }
   while (thisptr->Time-thisptr->OldTime < 
          thisptr->Period - thisptr->Error);

   thisptr->OldTime = thisptr->Time;



    if ( !thisptr->CallbackFunction(thisptr->CallbackParam))
    {
        // stop the timer
        thisptr->wTimerID = 0;
        SetEvent(thisptr->hTimerPending);
    }// handle tasks
    else
    {
        thisptr->wTimerID = timeSetEvent(
        thisptr->Delay,                    // delay
        thisptr->wTimerRes,                     // resolution (global variable)
        localTimerFunc,               // callback function
        (DWORD)thisptr,                  // user data
        TIME_ONESHOT );                // single timer event
    }

   /* Capture Frame Time */
   thisptr->Time = FastTimer();

   /* Capture Frame Error */
   thisptr->Error = (thisptr->Time - thisptr->OldTime);
} 


/*******************************************************************
*****************************  realtime.c  *************************
********************************************************************
*
*  Better Windows NT real time frame generator
*
*  Developed by:  Lionell K. Griffith - March 31, 1998
*  From Windows Developers Journal July 1998
*  Modified by the MathWorks
*
*  email:  lgriffith@hughes.net
*
*     Procedure      Description  
*  1. Li2Double      Converts LONG_INTEGER value to double value
*  2. FastTimerInit  Initializes the Performance Timer
*  3. FastTimer      Returns performance timer time in seconds
*  4. FrameProc      Callback for frame timer
*  5. FrameSet       Sets and starts Frame timer
*  6. FrameKill      Terminates Frame timer
*  7. FrameTime      Returns Frame Start Time
*
*  NOTE:  winmm.lib must be in the linker library list
*
*******************************************************************/

#define BetterTimer TRUE


/*******************************************************************
************************  1. Li2Double  ****************************
********************************************************************
*
*  Converts LONG_INTEGER value to double value
*
*  DoubleValue = Li2Double(LongInteger);
*
*  DoubleValue is the double value of the long integer
*  LongInteger is the LONG_INTEGER value to be converted
*
*******************************************************************/

#define C 4.294967296E9
#define Li2Double(x) (double)((x).HighPart)*C+(double)((x).LowPart)
double HiResTimer::Frequency=0;
LARGE_INTEGER HiResTimer::TimerFrequency;  /* Performance timer frequency  */


/*******************************************************************
**************************  2. FastTimerInit  **********************
********************************************************************
*
*  Initializes the Performance Timer
*
*  FastTimerInit();
*
*******************************************************************/

void HiResTimer::FastTimerInit(void)
  {
   QueryPerformanceFrequency(&TimerFrequency);
   Frequency = Li2Double(TimerFrequency);
  }

/*******************************************************************
*****************************  3. FastTimer   **********************
********************************************************************
*
*  Returns performance timer time in seconds
*
*  Time = FastTimer();
*
*  Time is time in seconds
*
*  Timer resolution is 0.838 usec
*
*  The performance timer is a 64 bit counter.  It can count for
*  almost 700,000 years.  Hence, rollover is not a problem.
*
*******************************************************************/
 
double HiResTimer::FastTimer(void)
  {
   LARGE_INTEGER CurrentTime;
   double Ticks;
   double Seconds;

   QueryPerformanceCounter(&CurrentTime);
   Ticks = Li2Double(CurrentTime);
   Seconds = Ticks/Frequency;
   return Seconds;
  }

