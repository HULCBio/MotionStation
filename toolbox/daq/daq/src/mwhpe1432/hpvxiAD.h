// hpvxiAD.h: Definition of the hpvxiAD class
//
//////////////////////////////////////////////////////////////////////
// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.1.6.2 $  $Date: 2003/12/04 18:39:25 $


#if !defined(AFX_HPVXIAD_H__602F2102_DF66_11D1_A21D_00A024E7DC56__INCLUDED_)
#define AFX_HPVXIAD_H__602F2102_DF66_11D1_A21D_00A024E7DC56__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

#pragma warning(disable:4996) // no warnings: CComModule::UpdateRegistryClass was declared deprecated

#include "resource.h"       // main symbols
#include "AdaptorKit.h"
//#include "thread.h"
#define INSTR_CALLBACKS     // needed to support interrupt callbacks
#pragma warning(disable: 4229) // anachronism used : modifiers on data are ignored
#include "hpe1432.h"
#pragma warning(default: 4229)

#include <vector>
#include "util.h"
/////////////////////////////////////////////////////////////////////////////
// hpvxiAD

#define DAQ_NO_ERROR (0)

//#define USETHREAD

class hpvxiAD : 
public CmwDevice,
public ImwInput,
public ImwAdaptor,        
public GlobalInfo,
public CComObjectRoot,
public CComCoClass<hpvxiAD,&CLSID_hpvxiAD>
{   
public:	
	static hpvxiAD *RunningADPtr;
    
    short*	        _buffer;
    ViSession	    _session;		// session handle    
    ViInt32 *	    _chanList;
    ViReal64	    *_chanRange[2];
	int             UserId[255];
	int             _numIdSpecified;
	int             _chasis;
	bool            _callbackRegistered;
	std::vector<ViInt32>  _validChanList;
	std::vector<ViInt32>  _validScaleFactor;

    ViInt32	        *_coupling;
    ViInt32         *_groundingMode;
    ViInt32         *_inputSource;
    ViInt32         *_inputMode;
    ViInt32	         _gid;		// group id
    ViInt32         _trigGrpID;    // TriggerChannel group id.

    
    DoubleProp	    _span;
    ViInt32	        _blockSize;
    __int64	        _samplesAcquired;    
	ViReal64        _minSpan;
	ViReal64        _maxSpan;
    
    bool            _isStarted;
    long            _nChannels;	
    long            _maxChannels;
	double            _clockFreq;
    DoubleProp      _sampleRate;
    double          _maxSR;
    IntProp         _chanSkewMode;      // fixed to none
    DoubleProp      _chanSkew;
    IntProp         _clockSource;
    ViInt32	       *_triggerChannel;
    IntProp         _triggerCondition;
    DoubleArrayProp _triggerConditionValue;    
    DoubleProp      _triggerDelay;
    IntProp         _triggerDelayUnits;
	DoubleProp      _triggerRepeat;
    IntProp         _triggerSlope;
    IntProp	        _triggerType;   
    bstr_t	        _id;
    bool	        _lastBufferGap;
    bool	        _running;
    int             _callbackCnt;
	//[SK] added
	DWORD			_triggersOccured;			
	DoubleProp		_samplesPerTrigger;
    bool			_LstBufFlg;

    enum { HWCHAN=1, INPUTRANGE, COUPLING, SOURCE, GROUND, MODE, TRIGGERCHANNEL };
    
    enum { CHAN_SKEW_NONE=1 };
    
    enum { RISING=1, FALLING, ENTERING, LEAVING };
    
    //typedef enum { TRIG_NONE, TRIG_SOFTWARE } TrigType;
    
    
    
    hpvxiAD();
    ~hpvxiAD();    
    CComPtr<IProp>  RegisterProperty(LPWSTR, DWORD);
    HRESULT SetDefaultRange(LPWSTR);    
    HRESULT SetDaqHwInfo();    
    int InitChannels();
    int ReallocCGLists();
    int SetDefaultTriggerConditionValues();
    int TriggerSetup();
    int ChannelSetup();   
    int SetInputRange(VARIANT*, int);    
    int VerifyTriggerConditionValue(VARIANT*);
    double FindClockFreq(VARIANT*, bool);
    int InternalStart();
    void addDev(int);
    bool installCallback(int);
    
    
    void Callback(ViInt32 b);
    ViInt32 GroupID() {return _gid;}
    ViSession Session() { return _session; }
    
    
    BEGIN_COM_MAP(hpvxiAD)
        COM_INTERFACE_ENTRY(ImwDevice)
        COM_INTERFACE_ENTRY(ImwInput)
        COM_INTERFACE_ENTRY(ImwAdaptor)
    END_COM_MAP()
    //DECLARE_NOT_AGGREGATABLE(hpvxiAD) 
    // Remove the comment from the line above if you don't want your object to 
    // support aggregation. 
        BEGIN_CATEGORY_MAP(CAin)
        IMPLEMENTED_CATEGORY(CATID_ImwAdaptor)
        END_CATEGORY_MAP()
    DECLARE_REGISTRY( hpvxiAD, "mwhpe1432.input.1", "mwhpe1432.input", IDS_AdaptorDescription, THREADFLAGS_BOTH )
    
    //DECLARE_REGISTRY_RESOURCEID(IDR_hpvxiAD) // this is out of date due to guids

    HRESULT Open(IDaqEngine *engine, wchar_t *devName);
        
        // IInput
public:
    STDMETHOD(GetName)( /* [out] */ BSTR __RPC_FAR *Name) 
    {*Name=SysAllocString(L"hpe1432");return S_OK;}
    STDMETHOD(AdaptorInfo)(IPropContainer*);
    STDMETHOD(OpenDevice)(REFIID riid,   long nParams, VARIANT __RPC_FAR *Param,
        REFIID EngineIID,
        IUnknown __RPC_FAR *pIEngine,
        void __RPC_FAR *__RPC_FAR *ppIDevice);
    STDMETHOD(GetStatus)(hyper *samplesProcessed, BOOL *running);
    STDMETHOD(BufferReadyForDevice)();    
    STDMETHOD(GetSingleValues)(VARIANT*){ return E_NOTIMPL;}    
    STDMETHOD(PeekData)(BUFFER_ST*){ return E_NOTIMPL;}    
    STDMETHOD(SetChannelProperty)(long,  NESTABLEPROP *, VARIANT *);         
    STDMETHOD(SetProperty)(long, VARIANT*);     
    STDMETHOD(Start)();
    STDMETHOD(Stop)();    
    STDMETHOD(Trigger)();
    STDMETHOD(TranslateError)(HRESULT, BSTR*);
    STDMETHOD(ChildChange)(DWORD,  NESTABLEPROP *);
};

#endif // !defined(AFX_HPVXIAD_H__602F2102_DF66_11D1_A21D_00A024E7DC56__INCLUDED_)
