// SoundAD.h: Definition of the SoundAD class
//
//////////////////////////////////////////////////////////////////////
// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.1.6.1 $  $Date: 2003/10/15 18:33:41 $

#if !defined(AFX_SOUNDAD_H__602F2102_DF66_11D1_A21D_00A024E7DC56__INCLUDED_)
#define AFX_SOUNDAD_H__602F2102_DF66_11D1_A21D_00A024E7DC56__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

#include "resource.h"       // main symbols
#include "DaqmexStructs.h"
#include "buflist.h"
//#include "prop.h"
#include "adaptorKit.h"
#include "wavein.h"
#include "daqmex.h"
#include "thread.h"
#include <vector>
#include "util.h"
/////////////////////////////////////////////////////////////////////////////
// CAdaptor
class ATL_NO_VTABLE CAdaptor : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CAdaptor, &CLSID_Adaptor>,
	public ISupportErrorInfo,
	public ImwAdaptor
{
public:
	CAdaptor()
	{
//            ATLTRACE("+Created Winsound Adaptor Class.\n");
	}
	~CAdaptor()
	{
//            ATLTRACE("-Deleted Winsound Adaptor Class.\n");
	}

DECLARE_REGISTRY_RESOURCEID(IDR_ADAPTOR)
DECLARE_NOT_AGGREGATABLE(CAdaptor)
DECLARE_CLASSFACTORY_SINGLETON(CAdaptor)
DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CAdaptor)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY(ImwAdaptor)
END_COM_MAP()
    BEGIN_CATEGORY_MAP(CAin)
    IMPLEMENTED_CATEGORY(CATID_ImwAdaptor)
    END_CATEGORY_MAP()

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

public:
// ImwAdaptor
	STDMETHOD(AdaptorInfo)(IPropContainer * Container);
//	STDMETHOD(OpenDevice)(GUID * DevIID, LONG nParams, VARIANT * Param, GUID * EngineIID, IUnknown * pEngine, VOID * * ppIDevice);
	STDMETHOD(TranslateError)(HRESULT eCode, BSTR * retVal);
    STDMETHOD(OpenDevice)(REFIID riid,   long nParams, VARIANT __RPC_FAR *Param,
        REFIID EngineIID,
        IUnknown __RPC_FAR *pIEngine,
        void __RPC_FAR *__RPC_FAR *ppIDevice);
};


/////////////////////////////////////////////////////////////////////////////
// SoundAD


class SoundAD : 
public ImwInput, 
public CSoundDevice,       
public CComObjectRoot,
public CComCoClass<SoundAD,&CLSID_SoundAD>
{
    WaveInDevice    _waveInDevice;
    BufferList	    _BufferList;
    
    CWaveInCaps	    WaveCaps;
    
    bool            _isStarted;
    bool	    _lastBufferGap;
    double          _GapTime;
   // bool            _stoping
    IntProp         _bitsPerSample;     // user settable  
    BoolProp        _standardSampleRates;
    IntProp         _chanSkewMode;      // fixed to none
    DoubleProp      _chanSkew;
    __int64	    _PointsThisRun;  

    DoubleProp      _triggerConditionValue;
    UINT	        _id;
    
    enum { HWCHAN=1, INPUTRANGE };
    
    enum { CHAN_SKEW_NONE=1 };
    
//    typedef enum { TRIG_NONE, TRIG_SOFTWARE } TrigType;
    
    Thread _thread;
    int _isDying;
    CEvent _BufferDoneEvent;
    static unsigned WINAPI ThreadProc(void* pArg);
    void CheckBuffersDone();
    static HRESULT WaveInError(MMRESULT err);

public:
    SoundAD();
    ~SoundAD();
    bool IsBufferDone ();
    CComPtr<IProp>  RegisterProperty(LPWSTR, DWORD);
    //    HRESULT SetDefaultRange(LPWSTR);    
    HRESULT SetDaqHwInfo();    
    BEGIN_COM_MAP(SoundAD)
        COM_INTERFACE_ENTRY(ImwDevice)
        COM_INTERFACE_ENTRY(ImwInput)
    END_COM_MAP()

        //DECLARE_NOT_AGGREGATABLE(SoundAD) 
        // Remove the comment from the line above if you don't want your object to 
        // support aggregation. 
        
    //DECLARE_REGISTRY_RESOURCEID(IDR_SoundAD)
        
        // IInput
    HRESULT BufferReadyForDevice();
    bool PutBuffer();
    void ProcessBuffers();

private:
    void ProcessDoneBuffer();


public:
    STDMETHOD(GetStatus)(hyper *samplesProcessed, BOOL *running);
    STDMETHOD(FreeBufferData)(BUFFER_ST*);    
    STDMETHOD(GetSingleValues)(VARIANT*){ return E_NOTIMPL;}    
    STDMETHOD(Open)(IDaqEngine *, int unit);
    STDMETHOD(PeekData)(BUFFER_ST*){ return E_NOTIMPL;}    
    STDMETHOD(SetProperty)(long user, VARIANT * NewValue);
    STDMETHOD(SetChannelProperty)(long User, tagNESTABLEPROP * pChan, VARIANT * NewValue);
    STDMETHOD(Start)();
    STDMETHOD(Stop)();  
    STDMETHOD(Trigger)();
    //STDMETHOD(TranslateError)(HRESULT, BSTR*);
};

#endif // !defined(AFX_SOUNDAD_H__602F2102_DF66_11D1_A21D_00A024E7DC56__INCLUDED_)
