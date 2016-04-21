// Adaptor.cpp : Implementation of CAdaptor
// Copyright 1998-2003 The MathWorks, Inc.
// $Revision: 1.3.4.3 $  $Date: 2003/08/29 04:44:06 $
#if !defined __AdaptorKit_H
#define __AdaptorKit_H

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000
#include <vector>
#include <comdef.h>
#include <daqmex.h>
#include <DaqmexStructs.h>
#include <Mmsystem.h>

extern const CATID CATID_ImwAdaptor; // ={ 0x6fe55f7b, 0xaf1a, 0x11d3, { 0xa5, 0x36, 0x0, 0x90, 0x27, 0x57, 0xea, 0x8d } };


#ifdef _DEBUG
inline HRESULT _CheckHResult(long severity,HRESULT status,char *Message,char *file,int line)
{
    if (!SUCCEEDED(status)) 
    {
         if ((1 == _CrtDbgReport(severity, file, line, NULL,"%s Returned %d\n", Message, status))) 
                _CrtDbgBreak(); 
    }
    return status;
}
// Remember that positive HRESULTs are not errors.
#define CHECK_HRESULT(status) _CheckHResult(_CRT_ERROR,status,#status,__FILE__,__LINE__)
#define RETURN_HRESULT(status) { HRESULT stat=_CheckHResult(_CRT_WARN,status,#status,__FILE__,__LINE__);  if (!SUCCEEDED(stat)) return stat;}
#define DEBUG_HRESULT RETURN_HRESULT
#else
#define CHECK_HRESULT(status) (status)
#define RETURN_HRESULT(status) { HRESULT stat=status;  if (!SUCCEEDED(stat)) return stat;}
#define DEBUG_HRESULT CHECK_HRESULT
#endif
// this header requires CHECK_HRESULT
#include <sarrayaccess.h>

//((int)&((NESTABLEPROP*)0)->x)
//#define USER_VAL(X) ((long)&((CAin*)0)->X)
// this is what I think I should use
#if 0
#define USER_VAL(X) offsetof(CAin,X)
//#define PROP_FROMUSER(X) (CLocalProp*)((BYTE*)this+X)
#else
#define USER_VAL(X) (long)&static_cast<CLocalProp&>(X)
#define PROP_FROMUSER(X) ((CLocalProp*)X)
#endif

// Virtual base class for local property types all values set for user should be based off this
class CLocalProp 
{
public:
    virtual ~CLocalProp() {}
    virtual void SetLocal(_variant_t &Val)=0;

};


class CRemoteProp :public CLocalProp,public CComQIPtr<IProp>
{
public:
    CRemoteProp() {};
    void SetLocal(_variant_t &Val) {};

    CComQIPtr<IProp>& Attach(IPropContainer *pCont,wchar_t *Name,long UserVal=0); // does not attach to user
    CComQIPtr<IProp>& Create(IPropContainer *pCont,wchar_t *Name,const CComVariant& Value);
    HRESULT SetRange(const CComVariant &V1,const CComVariant &V2) 
        // BECAUSE these values are defined as input by idl they are constant in implementation
    {return CHECK_HRESULT(p->SetRange(static_cast<VARIANT*>(const_cast<CComVariant*>(&V1)),
                                            static_cast<VARIANT*>(const_cast<CComVariant*>(&V2)) ));}
    HRESULT SetDefaultValue(const CComVariant &V1) 
    {return CHECK_HRESULT(p->put_DefaultValue(V1)) ;}
};

template <class T,const IID* PropIID=&__uuidof(IProp)> class TProp : public CLocalProp
{
public:
    TProp(T InitialV): Value(InitialV) {}
    TProp() : Value(0) {}
    VARIANT * Get(_variant_t &retVal) { retVal=Value; return &retVal; }
    virtual void SetLocal(_variant_t &Val) { Value=Val; }
    CComPtr<IProp> Create(IPropContainer *pCont,wchar_t *Name,long UserVal=0)
    {
        CComPtr<IProp> prop;
        pCont->CreateProperty(Name,&CComVariant(Value),*PropIID,(void**)&prop);
        CHECK_HRESULT(prop->put_User(USER_VAL(*this)));
        return prop;
    }

    CComPtr<IProp> Attach(IPropContainer *pCont,wchar_t *Name,long UserVal)
    {
        variant_t Val;
        CComPtr<IProp> prop;
        CHECK_HRESULT(pCont->GetMemberInterface(Name,*PropIID,(void**)&prop));
        _ASSERTE(prop!=NULL);    
        if (UserVal) 
            CHECK_HRESULT(prop->put_User(UserVal));
        CHECK_HRESULT(prop->get_Value(&Val));
        Value=Val;
        return prop;
    }
    operator T&() { return Value; }
    void operator=(const T newval) {Value=newval;}
    T Value;
};

class CEnumProp: public TProp<long,&__uuidof(IDaqMappedEnum)>
{
public:
    CEnumProp(long InitialV=0): TProp<long,&__uuidof(IDaqMappedEnum)>(InitialV) {}
    CComPtr<IProp> Create(IPropContainer *pCont,wchar_t *Name,long UserVal=0)
    {
        CComPtr<IProp> prop;
        pCont->CreateProperty(Name,NULL,__uuidof(IDaqMappedEnum), (void**)&prop);
        CHECK_HRESULT(prop->put_User(UserVal));
        CComVariant var(Value);
        CHECK_HRESULT(prop->put_DefaultValue(var));
        CHECK_HRESULT(prop->put_Value(var));
        return prop;
    }
    //HRESULT AddEnumValue(long value,LPCWSTR Name)
    //{

    //}
    void operator=(long newval) {Value=newval;}
};

template <class T> class TRemoteProp: public CRemoteProp
{
public:
    TRemoteProp() {};
    CComQIPtr<IProp, &__uuidof(IProp)>& Create(IPropContainer *pCont,wchar_t *Name,T Value)
    {
        return CRemoteProp::Create(pCont,Name,Value) ;
    }
    operator T() {variant_t Val;CHECK_HRESULT(p->get_Value(&Val)); return Val; } // this could be better
    HRESULT Set(T Value) {return CHECK_HRESULT(p->put_Value(CComVariant(Value)));}
    HRESULT SetDefaultValue(const T& V1) 
    {return CHECK_HRESULT(p->put_DefaultValue(CComVariant(V1))) ;}
    void operator=(const T newval) {Set(newval);}
    TRemoteProp<T>* operator&() {return this;}
};

template <class T,const IID* PropIID=&__uuidof(IProp)> class TCachedProp : public CRemoteProp
{
public:
    TCachedProp(T InitialV): Value(InitialV) {}
    TCachedProp() : Value(0) {}
    CComQIPtr<IProp>& Create(IPropContainer *pCont,wchar_t *Name,long UserVal=0)
    {
        Release();

        CHECK_HRESULT(pCont->CreateProperty(Name,&CComVariant(Value),*PropIID,(void**)&p));
		if (UserVal==0) {
			UserVal=USER_VAL(*this);
		}
        CHECK_HRESULT(p->put_User(UserVal));
        return *this;
    }
    CComQIPtr<IProp>& Attach(IPropContainer *pCont,wchar_t *Name,long UserVal=0)
    {
        Release();

        CHECK_HRESULT(pCont->GetMemberInterface(Name,__uuidof(IProp),(void**)&p));
        _ASSERTE(p!=NULL);
        if (UserVal==0)
        {
            UserVal=USER_VAL(*this);
        }
        CHECK_HRESULT(p->put_User(UserVal));
        variant_t Val;
        CHECK_HRESULT(p->get_Value(&Val));
#ifdef _debug
        if (Value!=static_cast<T>(Val) && Value!=0)
            _RPT2(_CRT_WARN,"Default values for property do not match Adaptor val=%f engin val=%f\n",static_cast<double>(Value),static_cast<double>(Val));
#endif
        Value=Val;
        return *this;
    }
    VARIANT * Get(_variant_t &retVal) { retVal=Value; return &retVal; }
    virtual void SetLocal(_variant_t &Val) { Value=Val; }
    void SetLocal(T Val) { Value=Val; }
    HRESULT SetRemote(const CComVariant& NewValue) { return CHECK_HRESULT(p->put_Value(NewValue));}
    operator T() { return Value; }
    TCachedProp<T>* operator&() {return this;}
    void operator=(const T NewValue) {Value=NewValue;SetRemote(NewValue);}
    T Value;
};

CComQIPtr<IProp>& TCachedProp<long,&__uuidof(IDaqMappedEnum)>::Create(IPropContainer *pCont,wchar_t *Name,long UserVal)
{
    // default value must be null for nowmust be null 
    CComPtr<IDaqMappedEnum> ienum;
    CHECK_HRESULT(pCont->CreateProperty(Name,NULL,*PropIID,(void**)&ienum));
    ienum.QueryInterface(&p); // qi for 
    CHECK_HRESULT(p->put_User(UserVal));
    CComVariant var(Value);
    CHECK_HRESULT(p->put_DefaultValue(var));
    CHECK_HRESULT(p->put_Value(var));
    return *this;
}


typedef TProp<long> IntProp;
typedef TProp<short> ShortProp;
typedef TProp<double> DoubleProp;
typedef TProp<bool> BoolProp;
//typedef TProp<__int64> Int64Prop;
typedef TProp<double> Int64Prop;
typedef TCachedProp<long,&__uuidof(IDaqMappedEnum)> CachedEnumProp;

//  
// Array class template 
// This is used to handle array properties to and from the engine.
//
template <class T, long Type> class TArrayProp : public CRemoteProp
{
public:
    TArrayProp(VARIANT *values): _Values(NULL) {  SetLocal(variant_t(values)); }
    TArrayProp(): _Values(NULL) {}
    ~TArrayProp() { delete [] _Values; }
/* I do not know why to use this  might need virtual 
    VARIANT * Get(_variant_t &retVal) 
    {
        
        T *pr;
        
        ps = SafeArrayCreateVector(Type, 0, len);
        if (ps==NULL)
            throw "Failure to create SafeArray.";
        
        retVal->parray=ps;
        retVal->vt=VT_ARRAY | Type;
        
        HRESULT hr = SafeArrayAccessData (ps, (void **) &pr);
        if (FAILED (hr)) 
        {
            SafeArrayDestroy (ps);
            throw "Failure to access SafeArray.";
        }
        
        memcpy (pr, _Values, len*Size());     
        
        SafeArrayUnaccessData (ps);
        
        return retVal;
    }
*/ 
    CComQIPtr<IProp>& Attach(IPropContainer *pCont,wchar_t *Name,long UserVal=0)
    {
        CRemoteProp::Attach(pCont,Name);
        variant_t Val;
        if (!UserVal)
        {
            UserVal=USER_VAL(*this);
        }
        CHECK_HRESULT(p->put_User(UserVal));
        CHECK_HRESULT(p->get_Value(&Val));
        SetLocal(Val);
        return *this;
    }
    void SetLocal(variant_t &Val)
    {            
        
        // first, see if its an array
        if (V_ISARRAY (&Val) || V_ISVECTOR (&Val))
        {
            SAFEARRAY *ps;
            ps = V_ARRAY(&Val);
            if (ps==NULL) 
            {
                _RPT0(_CRT_ERROR,"Invalid SafeArray.");
                return;
            }

            // get the number of dimensions in the source safearray
            int nDims = SafeArrayGetDim(ps);
            if (nDims>2) 
            {
                _RPT0(_CRT_ERROR,"Arrays of dimension greater than two are not supported by TArrayProp.");
                return;
            }
            T *pr;
            long uBound, lBound;	
            SafeArrayGetLBound (ps, 1, &lBound);
            SafeArrayGetUBound (ps, 1, &uBound);
            len = uBound - lBound + 1;	    
            
            
            if (FAILED (CHECK_HRESULT(SafeArrayAccessData (ps, (void **) &pr)))) 
            {
                return;
            }
            
            delete [] _Values;
            _Values = new T[len];
            memcpy(_Values, pr, len * Size());
            
            SafeArrayUnaccessData(ps);
            
        } 
        else 
        {   
            len=1;
            delete [] _Values;
            _Values=NULL;
            _Values=new T[1];
            *_Values = Val;
        }	    
     
    }

    long ArrayLen()             { return len; }        
    operator T&()       { return *_Values; }
    T operator [] (int index) { return _Values[index];} 
    long len;
private:
    T *_Values;    
    int Size()  { return sizeof(T);}   
};

typedef TArrayProp < double, VT_R8 > DoubleArrayProp;
typedef TArrayProp < long, VT_I4> IntArrayProp;

/* now here are the helper classes for creating adaptors */
#ifdef _ATL_APARTMENT_THREADED
#pragma message("No Locks in apartment threading") 
#endif

// A Templated LOCK for CLASS T
template <class T> class TAtlLock 
{
public:
    typedef T LOCKABLE;
	// Acquire the state of the semaphore
	TAtlLock ( LOCKABLE& crit ) 
		: _LockedObj(crit) 
	{
		_LockedObj.Lock();
	}
	// Release the state of the semaphore
	~TAtlLock ()
	{
		_LockedObj.Unlock();
	}
private:
	LOCKABLE& _LockedObj;
};

// timer class note that only one of onshot and timer may be used at a time.
#include <mmsystem.h>

typedef bool (CALLBACK SIMPLECALLBACK)(void *);

// all times are in seconds
class LowResTimer
{
public:
    typedef LowResTimer Ty;
    LowResTimer(int resolution=1);
    ~LowResTimer();
    bool CallIn(double time);
    bool CallPeriod(double delta); // returns true for success
    double  GetResolution() {return wTimerRes/1000.0;}
    void Stop(); // do not call this function from the timer callback

protected:
    static void CALLBACK localTimerFunc(UINT wTimerID, UINT msg, 
        DWORD dwUser, DWORD dw1, DWORD dw2);
    static void CALLBACK localOneshotFunc(UINT wTimerID, UINT msg, 
        DWORD dwUser, DWORD dw1, DWORD dw2);

    HANDLE hTimerPending; 
    UINT     wTimerRes;
    int LastTime;
    MMRESULT wTimerID;
    SIMPLECALLBACK *CallbackFunction;
    void *CallbackParam;
};

class HiResTimer :public LowResTimer
{
public:
    HiResTimer();
    typedef HiResTimer Ty;

    bool CallIn(double time);
    bool CallPeriod(double delta); // returns true for success
    double     GetResolution() {return 1e-6;} // fixme?
    static void CALLBACK localTimerFunc(UINT wTimerID, UINT msg, 
        DWORD dwUser, DWORD dw1, DWORD dw2) ;
    static void CALLBACK localOneshotFunc(UINT wTimerID, UINT msg, 
        DWORD dwUser, DWORD dw1, DWORD dw2) ;
   double Period;                 /* Frame period                 */
   double FrameStart;             /* Start of frame time          */
   double Time;                   /* Frame time                   */
   double OldTime;                /* Old frame time               */
   double Error;                  /* Frame time error             */
   UINT Delay;                    /* Integer ms frame periods     */
    bool Shutdown;              // set this to true to force a shutdown of Timer func on next call
   // routines for use of performance timer
   static LARGE_INTEGER TimerFrequency;  /* Performance timer frequency  */
   static double Frequency;              /* Frequence converted to double*/
    static void FastTimerInit(void);
    static double FastTimer(void);
    void Stop() {Shutdown=true;  LowResTimer::Stop();}
};

template <class T, class TimerType> 
class TTimerCallback :public TimerType
{
public:
    typedef TTimerCallback < T,TimerType > Ty;
    TTimerCallback(T* newOwner,int resolution=1):Owner(newOwner)
        
    {
        CallbackFunction=Callback; 
        CallbackParam=this;
    }
    static  bool __stdcall Callback(void *ptr)
    {
        Ty* This=(Ty*)ptr;
        return This->Owner->TimerRoutine();
    }
    T *Owner;
};

// This macro will set up a propery based off of CLocalProp of the format pPropName
// where _prop is PropName
//template <class T>
#define ATTACH_PROP(_prop) p##_prop.Attach(_EnginePropRoot,L#_prop,USER_VAL(p##_prop))
#define CREATE_PROP(_prop) p##_prop.Create(_EnginePropRoot,L#_prop,USER_VAL(p##_prop))

class ATL_NO_VTABLE CmwDevice :public ImwDevice
{
public:
    CmwDevice();
    
    template <class T>
    HRESULT GetChannelContainer(int index,T**Cont)
    { RETURN_HRESULT(_EngineChannelList->GetChannelContainer(index,__uuidof(T),(void**)Cont)); return S_OK;}
    static HRESULT TranslateError(HRESULT code,BSTR *out);

    //    static HRESULT WINAPI Error(LPCSTR lpszDesc,const IID& iid = GUID_NULL, HRESULT hRes = 0)
//    {
//        return CComCoClass<ImwDevice>::Error(lpszDesc, iid, hRes);
//    }
    template <class T>
    HRESULT GetProperty(LPCWSTR name, T** prop)
    { RETURN_HRESULT(_EnginePropRoot->GetMemberInterface(name,__uuidof(T),(void**)prop)); return S_OK;}
    template <class T>
    HRESULT GetChannelProperty(LPCWSTR name, T** prop)
    { RETURN_HRESULT(_EngineChannelList->GetMemberInterface(name,__uuidof(T),(void**)prop)); return S_OK;}
    template <class T>
    HRESULT CreateProperty(LPCWSTR name,  VARIANT *value, T** prop)
    { RETURN_HRESULT(_EnginePropRoot->CreateProperty(name,value,__uuidof(T),(void**)prop)); return S_OK;}
    template <class T>
    HRESULT CreateChannelProperty(LPCWSTR name,  VARIANT *value, T** prop)
    { RETURN_HRESULT(_EngineChannelList->CreateProperty(name,value,__uuidof(T),(void**)prop)); return S_OK;}


    HRESULT Open(IUnknown *Interface);
    enum INPUTTYPE {SE_INPUT=1,DI_INPUT=2,BOTH_INPUT=3,OUTPUT=4}; // If bot SE and DI are supported or them together and DI channs=maxchannels/2
    HRESULT InitHwInfo(VARTYPE DataType,int DataBits,int maxchannels,INPUTTYPE inType,LPCWSTR adaptorname,LPCWSTR hwname);
    // Local variable access routines
    const CComQIPtr<IDaqEngine>& GetEngine() {return _engine;}
    const CComQIPtr<IChannelList>& GetChannelList() {return _EngineChannelList;}
    const CComQIPtr<IPropContainer>& GetHwInfo() {return _DaqHwInfo;}
    const CComQIPtr<IPropContainer>& GetPropRoot() {return _EnginePropRoot;}


protected:
    //  these functions should only be called when implementeing the same function in a dirived class
    // use calling the base function is optional when overriding but in most cases all base functionality will need
    // to be duplicated
    STDMETHOD(AllocBufferData)(struct tagBUFFER *);
    STDMETHOD(FreeBufferData)(struct tagBUFFER *);
    STDMETHOD(SetProperty)(long User, VARIANT * NewValue);

    STDMETHOD(SetChannelProperty)(long User, tagNESTABLEPROP * pChan, VARIANT * NewValue);
    STDMETHOD(ChildChange)(ULONG typeofchange,  tagNESTABLEPROP * pChan) {return S_OK; }

    // local variables
protected:  // make private in future
    CComQIPtr<IDaqEngine>	_engine;
    CComQIPtr<IPropContainer> _EnginePropRoot;
    CComQIPtr<IPropContainer> _DaqHwInfo;
    CComQIPtr<IChannelList> _EngineChannelList;
    bool _running;
    bool _updateChildren;
    bool _updateProps;
    
};

 
#define USE_HiResTimer
#ifdef USE_HiResTimer
#define MAX_SW_SAMPLERATE 500
#else
#define MAX_SW_SAMPLERATE 1000
#endif

#define MIN_SW_SAMPLERATE 0.0002
// this class can be replaced or modified 

class ATL_NO_VTABLE CswClockedDevice: public CmwDevice
{
public:
    CswClockedDevice();
    virtual HRESULT UpdateChans(bool ForStart);  // If for start is false chans are being updated because of childchange
    virtual HRESULT UpdateProps() {return S_OK;}
    virtual HRESULT TranslateError(HRESULT code,BSTR *out) {return CmwDevice::TranslateError(code,out);}

    STDMETHOD(SetProperty)(long User, VARIANT * NewValue);
    STDMETHOD(ChildChange)(ULONG typeofchange,  tagNESTABLEPROP * pChan);
    HRESULT Open(IUnknown *Interface);
    static double RoundRate(const double& NewRate);
    HRESULT EnableSwClocking(bool SetAsDefault=false);
    TCachedProp<double> pSampleRate;
    std::vector<int> _chanList;
    long    _nChannels;
};


template <class TDevice> class ATL_NO_VTABLE TADDevice: public TDevice, 
public ImwInput,
public CComObjectRootEx<CComMultiThreadModel>
{
public:
    typedef TADDevice<TDevice> InputType;
    typename TDevice::RawDataType;
    //typedef TDataType RawDataType;
    TADDevice() :TimerObj(this),_CurrentSample(NULL),_CurrentPoint(0),_CurrentBuffer(NULL)
    {
        _samplesAcquired=0;
    }
    STDMETHOD(PeekData)(tagBUFFER * pBuffer) {return E_NOTIMPL;} // Adaptors are not required to reimplement this
    STDMETHOD(GetSingleValues)(VARIANT * Values)
    {
        // will call GetSingleValue on TDevice
        UpdateChans(true);
        
        TSafeArrayVector <RawDataType > binarray;    
        binarray.Allocate(_nChannels);
        for (int i=0; i<_nChannels; i++) 
        {    
            RETURN_HRESULT(GetSingleValue(i,&binarray[i]));
        }
        return binarray.Detach(Values);
    }
    STDMETHOD(Start)()
    {
        _samplesAcquired=0;
        TAtlLock<InputType> _lock(*this);
        HRESULT res=InternalStart();
        if (!SUCCEEDED(res))
        {
            _running=false;
        }
        return res;
    }
    
    STDMETHOD(Stop)()
    {
        TimerObj.Stop();
        TAtlLock<InputType> _lock(*this);
        PutBuffer();
        _running=false;
        return S_OK;
    }
    
    // code to allow software timeing
    HRESULT InternalStart()
    {
        //TimerObj.CallEveryXms(1000/pSampleRate);
        RETURN_HRESULT(UpdateChans(true));
        _running=true;

        GetBuffer();
        return S_OK;
    }
    virtual void GetBuffer()
    {
        _engine->GetBuffer(0,&_CurrentBuffer);
        if (_CurrentBuffer)
        {
            _CurrentSample=reinterpret_cast<RawDataType*>(_CurrentBuffer->ptr);
            _CurrentBuffer->StartPoint=_samplesAcquired*_nChannels;
            _CurrentPoint=0;
        }
        else
            _CurrentSample=NULL;
    }
    virtual void PutBuffer()
    {
        if (_CurrentBuffer)
        {
            _CurrentBuffer->ValidPoints=_CurrentPoint;
            _engine->PutBuffer(_CurrentBuffer);
            _CurrentBuffer=NULL;
            _CurrentSample=NULL;
        }
    }
    STDMETHOD(Trigger)()
    {
        TAtlLock<InputType> _lock(*this);
        TimerObj.CallPeriod(1/pSampleRate);
        return S_OK;  // THIS FUNCTION MUST BE REWRITTEN IF NEEDED
    }
    bool TimerRoutine() 
    {
        TAtlLock<InputType> _lock(*this);

        if (_CurrentSample)
        {
            for (int i=0; i<_nChannels; i++) 
            {        	       
                HRESULT status = GetSingleValue( i, _CurrentSample++);                    
                if (status)
                {
                    // post an error
                    _engine->DaqEvent(EVENT_ERR, -1, _samplesAcquired, L"Error from GetSingleValue." );
                    return false;
                }
                
            }
            _CurrentPoint+=_nChannels;
            _samplesAcquired++;
            if (_CurrentPoint>=_CurrentBuffer->ValidPoints)
            {
                PutBuffer();
                GetBuffer();
                if (!_CurrentSample)
                {
                    _engine->DaqEvent(EVENT_STOP, -1, _samplesAcquired, NULL);
                    return false;
                }
                
            }
        }
        else
        {
            // overrun or stop...
            return false;
        }
        return true;
    }
    STDMETHOD(GetStatus)(__int64 * samplesProcessed, BOOL * running)
    {
        *running=_running;
        *samplesProcessed=_samplesAcquired;
        return S_OK;
    }
#ifdef USE_HiResTimer
    TTimerCallback< InputType ,HiResTimer> TimerObj;
#else
    TTimerCallback< InputType ,LowResTimer> TimerObj;
#endif
    __int64 _samplesAcquired;    // Total samples acquired sense start
    int _CurrentPoint;
    RawDataType *_CurrentSample;  // pointer into current buffer
    BUFFER_ST* _CurrentBuffer;
};

template <class TDevice=CmwDevice>
class ATL_NO_VTABLE TDADevice: 
public TDevice, 
public ImwOutput,	
public CComObjectRootEx<CComMultiThreadModel>
{
    // Single point method for DACs
public:
    typename TDevice::RawDataType;
//    typename RawDataType;
    typedef TDADevice<TDevice> OutputType;
  //  typedef TDataType RawDataType;
    TDADevice() :TimerObj(this),_CurrentSample(NULL),_CurrentPoint(0),_CurrentBuffer(NULL)
    {
        _samplesOutput=0;
    }
    STDMETHOD(PutSingleValues)(VARIANT * values)
    {              
        if (_updateChildren)
        {
            UpdateChans(true);
        }
        if (_updateProps)
        {}
        
        if ( V_ISARRAY (values) || V_ISVECTOR (values))
        {
            SAFEARRAY *ps = V_ARRAY(values);
            if (ps==NULL) return E_INVALIDARG;
            
            int status;
            RawDataType *voltArray;
            
            HRESULT hr = SafeArrayAccessData (ps, (void **) &voltArray);
            if (FAILED (hr)) 
            {
                return hr;
            }
            
            for (int i=0; i<_nChannels; i++) 
            {        	       
                status = PutSingleValue( i, voltArray[i]);                    
                if (status)
                {
                    SafeArrayUnaccessData (ps);
                    return status;
                }
            }       
            
            SafeArrayUnaccessData (ps);
            
        }
        else
            return E_INVALIDARG;
        
        return S_OK;
    }
    STDMETHOD(GetStatus)(__int64 *samplesProcessed, int * running)
    {
        *samplesProcessed=_samplesOutput;
        *running=_running;
        return S_OK;
    }
    
    STDMETHOD(Start)()
    {
        _samplesOutput=0;
        TAtlLock<OutputType> _lock(*this);
        HRESULT res=InternalStart();
        if (!SUCCEEDED(res))
        {
            _running=false;
        }
        return res;
    }
    
    STDMETHOD(Stop)()
    {
        TimerObj.Stop();
        TAtlLock<OutputType> _lock(*this);
        PutBuffer();
        _running=false;
        return S_OK;
    }
    
    // code to allow software timeing
    HRESULT InternalStart()
    {
        //TimerObj.CallEveryXms(1000/pSampleRate);
        GetBuffer();
        _running=true;
        return S_OK;
    }
    void GetBuffer()
    {
        _engine->GetBuffer(0,&_CurrentBuffer);
        if (_CurrentBuffer)
        {
            _CurrentSample=reinterpret_cast<RawDataType*>(_CurrentBuffer->ptr);
            _CurrentPoint=0;
        }
        else
            _CurrentSample=NULL;
    }
    void PutBuffer()
    {
        if (_CurrentBuffer)
        {
            _CurrentBuffer->ValidPoints=_CurrentPoint;
            _engine->PutBuffer(_CurrentBuffer);
            _CurrentSample=NULL;
            _CurrentBuffer=NULL;
        }
    }
    STDMETHOD(Trigger)()
    {
        TAtlLock<OutputType> _lock(*this);
        TimerObj.CallPeriod(1/pSampleRate);
        return S_OK;  // THIS FUNCTION MUST BE REWRITTEN IF NEEDED
    }
    bool TimerRoutine() 
    {
        TAtlLock<OutputType> _lock(*this);

        if (_CurrentSample)
        {
            for (int i=0; i<_nChannels; i++) 
            {        	       
                HRESULT status = PutSingleValue( i, *_CurrentSample++);                    
                if (status)
                {
                    BSTR str=NULL;
                    TranslateError(status,&str);
                    _engine->DaqEvent(EVENT_ERR, 0, _samplesOutput, str);
                    SysFreeString(str);
                    return false;
                }
                
            }
            _CurrentPoint+=_nChannels;
            _samplesOutput++;
            if (_CurrentPoint>=_CurrentBuffer->ValidPoints)
            {
                PutBuffer();
                GetBuffer();
                if (!_CurrentSample)
                {
                    _engine->DaqEvent(EVENT_STOP, 0, _samplesOutput, NULL);
                    return false;
                }
                
            }
        }
        else
        {
            // overrun or stop...
            return false;
        }
        return true;
    }
#ifdef USE_HiResTimer
    TTimerCallback< OutputType ,HiResTimer> TimerObj;
#else
    TTimerCallback< OutputType ,LowResTimer> TimerObj;
#endif
    int _CurrentPoint;
    RawDataType *_CurrentSample;  // pointer into current buffer
    BUFFER_ST* _CurrentBuffer;
    __int64 _samplesOutput;    // Total samples output sense start
};

template <class TDevice>
class ATL_NO_VTABLE TDIODevice: public TDevice, public ImwDIO
{
	STDMETHOD(Start)()
	{
		return E_NOTIMPL;
	}
	STDMETHOD(Stop)()
	{
		return E_NOTIMPL;
	}
	STDMETHOD(GetStatus)(__int64 * samplesProcessed, int * running)
	{
		return E_NOTIMPL;
	}
};

#endif // #ifdef __AdaptorKit_H