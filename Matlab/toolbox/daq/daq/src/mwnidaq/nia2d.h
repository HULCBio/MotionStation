// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.5.2.6 $  $Date: 2003/12/04 18:40:06 $


// nia2d.h: Definition of the nia2d class
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_NIA2D_H__D0C329D2_E0FF_11D1_A21F_00A024E7DC56__INCLUDED_)
#define AFX_NIA2D_H__D0C329D2_E0FF_11D1_A21F_00A024E7DC56__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

#pragma warning(disable:4996) // no warnings: CComModule::UpdateRegistryClass was declared deprecated

#include "mwnidaq.h"
#include "resource.h"       // main symbols
#include "daqmex.h"
#include "daqtypes.h"
//#include "evtmsg.h"
#include "AdaptorKit.h"
#include "messagew.h"
#include "cirbuf.h"
#include "nidisp.h"
#include "niutil.h"
/////////////////////////////////////////////////////////////////////////////
// nia2d
class ATL_NO_VTABLE CniAdaptor: 
public ImwAdaptor,
public CComObjectRoot,
public CComCoClass<CniAdaptor,&CLSID_CniAdaptor>
{
public:

    STDMETHOD(OpenDevice)(REFIID riid,   long nParams, VARIANT __RPC_FAR *Param,
        REFIID EngineIID,
        IUnknown __RPC_FAR *pIEngine,
        void __RPC_FAR *__RPC_FAR *ppIDevice);
    STDMETHOD(AdaptorInfo)(IPropContainer*);
    STDMETHODIMP TranslateError(HRESULT code,BSTR *out)
    {
        *out=TranslateErrorCode(code).Detach();
        return *out ? S_OK : E_FAIL;
    }
    BEGIN_COM_MAP(CniAdaptor)
        COM_INTERFACE_ENTRY(ImwAdaptor)
    END_COM_MAP()
    BEGIN_CATEGORY_MAP(CAin)
    IMPLEMENTED_CATEGORY(CATID_ImwAdaptor)
    END_CATEGORY_MAP()
    DECLARE_NOT_AGGREGATABLE(CniAdaptor) 
    DECLARE_CLASSFACTORY_SINGLETON(CniAdaptor)
    // Remove the comment from the line above if you don't want your object to 
    // support aggregation. 
    DECLARE_REGISTRY( CniAdaptor, "mwnidaq.adaptor.1", "mwnidaq.adaptor", IDS_NIADAPT_DESC, THREADFLAGS_BOTH )
    // global adaptor storage
    CniAdaptor();
    ~CniAdaptor();

    DevCaps* GetDevCaps(int id) {return DeviceInfo[id];}
private:
    std::vector<DevCaps*> DeviceInfo;
    std::vector<int> BoardIds;
    void InitDeviceInfo(); // called by constructor
};


/////////////////////////////////////////////////////////////////////////////

class ATL_NO_VTABLE Cnia2d : 
public CmwDevice, //<ImwDevice>,
public ImwInput,
//public ISupportErrorInfo,
public CComCoClass<Cnia2d,&CLSID_Cnia2d>,
public CniDisp
{
public:
    struct RANGE_INFO {
        int GainInt;
        int polarity;
        double Gain;
        double minVal;
        double maxVal;
        //    char  name[16];
    };
    typedef std::vector<short> shortvect;
    shortvect  _chanList;
    shortvect 		_polarityList;
    shortvect		_gainList;
    TCachedProp<double> _chanSkew;
    TCachedProp<long>   _chanSkewMode;
    IntProp		_chanType;
    IntProp		_clockSrc;	
    BoolProp		_driveAIS;        
    HWND		_hWnd;
    IntProp		_nMuxBrds;
    long		_nSamples;  // samples per engine buffer (and callback if _UseNSCANSCallback)
    TCachedProp<double> _sampleRate;	
    __int64             _samplesThisRun;

    Int64Prop           _engineSamplesPerTrigger;
    long                _samplesPerTrigger;         // this will be 0 for continuous
    TRemoteProp<long>   _totalPointsToAcquire;
    unsigned long       _triggersProcessed;
    unsigned long       _triggerSrc;	
    long		_triggerChannelIndex;
    long                _triggerChannelID;
    TCachedProp<long>	_triggerCondition;
    DoubleArrayProp	_triggerConditionValue;
    
    DoubleProp          _triggerDelay;
    TRemoteProp<long>   _triggerDelayPoints;
    IntProp		_triggerType;
    DoubleProp          _triggerRepeat;
    
    IntProp		_xferMode;	       
//    CComPtr<IDaqEngine>	_engine;
    
    unsigned short     _sampleInterval;
    unsigned short     _scanInterval;
    short     _scanTB;
    double              _TargetSampleRate;  // sample rate set by user
    typedef std::vector<RANGE_INFO> RangeList_t;
    RangeList_t _validRanges;
    RANGE_INFO* FindRangeFromGainInt(short gain,int polarity);
    //typedef std::map<short,RANGE_INFO*> RangeMap_t;
    //RangeMap_t _rangemap; // not needed yet
    
    enum CHANPROPS {
        HWCHAN=1,
            GAIN,
            INPUTRANGE,
            COUPLING
    };
    double GetActualSampleRate() {return _sampleRate;}
    double GetTargetSampleRate() {return _TargetSampleRate;}
    
    static MessageWindow       *_Nia2dWnd;   // is static so that ao can use it 

    // flags used 
    bool		_isConfig;   
    bool                _UseNSCANSCallback;  // engine default buffer size usualy nSamples
    bool		_running;
    bool                _callTrigger;
    bool                _startCalled;
    bool                _doneLatch;  // used for a workaround to prevent bufferprocessing after done message
    

	CachedEnumProp  pExternalScanClockSource;	//ExternalScanClockSource property 
	CachedEnumProp  pExternalSampleClockSource;	//ExternalSampleClockSource property 
	CachedEnumProp  pHwDigitalTriggerSource;	//ExternalScanClockSource property 


public:
    Cnia2d();	
    ~Cnia2d();	
    HRESULT SetNIDAQError(short status,const IID& iid = IID_ImwInput)
    { return status!=0 ? Error(status,iid) : S_OK;};

    int SetXferMode();
    int   Samples()			{ return _nSamples;}    
    template <class PT>
    CComPtr<IProp> RegisterProperty(LPWSTR name,  PT &prop)
    {
        return prop.Attach(GetPropRoot(),name,USER_VAL(prop));
    }
    
    int ReallocCGLists();
    void SetupChannels();
    HRESULT MakeMuxLists(short *ChanList,short *GainList,short &ScanChans);
    
    bool IsValidChanId(short id);
    
    long MapVoltsToInt(double);
    void SetAllPolarities(short polarity);
    int SetGainForRange(short, double, double, double*, double*);
    void FindGainForRange(double inRangeLo, double inRangeHi, 
        double *outRangeLo, double *outRangeHi,short *outGain,short *outPolarity);
    HRESULT FindRange(double low,double high,RANGE_INFO* &pRange);

    int GetTriggerConditionValueRange(double*, double*);
    int SetInputRangeDefault();
    int SetDefaultTriggerConditionValues();
    int SetDaqHwInfo();
    static void Callback(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam);
    void ProcessSamples(int samples,bool Stopped=false);
// Buffer access funcions needed because DSA devices have 32 bit data
    virtual void InitBuffering(int Points)=0;
    long GetBufferSizePoints()
    {
        return GetCircBuffer()->GetBufferSize();
    }
    virtual CCircBufferBase* GetCircBuffer()=0;
    virtual void CopyToBuffer(BUFFER_ST  *BuffPtr)=0;  // copy validpoints points to the buffer

    int InternalStart();
    BEGIN_COM_MAP(Cnia2d)
        COM_INTERFACE_ENTRY(ImwInput)
        COM_INTERFACE_ENTRY(ImwDevice)
        COM_INTERFACE_ENTRY_CHAIN(CniDisp)
    END_COM_MAP()
    DECLARE_NOT_AGGREGATABLE(Cnia2d) 
    // Remove the comment from the line above if you don't want your object to 
    // support aggregation. 
    DECLARE_REGISTRY( Cnia2d, "mwnidaq.input.1", "mwnidaq.input", IDS_NIA2D_DESC, THREADFLAGS_BOTH )
    
    //DECLARE_REGISTRY_RESOURCEID(IDR_nia2d)

    // The following functions vertual and are overrided as needed by other nidaq adaptor classes 
    virtual HRESULT Open(IDaqEngine * Interface,int _ID,DevCaps *DeviceCaps);
    typedef enum ConfigReasonEnum {FORSET,FORSINGLEVALUE,FORSTART} ConfigReason;
    int TriggerSetup(ConfigReason reason);   
    int AnalogTriggerSetup(ConfigReason reason);
    virtual HRESULT Configure(ConfigReason reason)=0;
    virtual HRESULT UpdateTimeing(ConfigReason reason)=0;
        
    HRESULT Initialize();	      
        // IDevice
public:	
    STDMETHOD(GetStatus)(hyper*, BOOL*) {return S_OK;}
    STDMETHOD(Delete)();
    STDMETHOD(GetSingleValues)(VARIANT*);
    STDMETHOD(PeekData)(BUFFER_ST*);	    
    STDMETHOD(SetChannelProperty)(long User,NESTABLEPROP * pChan, VARIANT * NewValue);
    STDMETHOD(SetProperty)(long User, VARIANT *newVal);
    STDMETHOD(ChildChange)(DWORD typeofchange, NESTABLEPROP *pChan);
    STDMETHOD(Stop)();
    STDMETHOD(Start)();	
    
    STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);
};


/////////////////////////////////////////////////////////////////////////////

class ATL_NO_VTABLE CESeriesInput : public Cnia2d
{
public:
    typedef TCircBuffer<short> CIRCBUFFER;
    CIRCBUFFER          _CircBuff;
    STDMETHOD(Trigger)();
//    virtual void ProcessSamples(int samples);
    void InitBuffering(int Points)
    {
        _CircBuff.Initialize(Points);
    }
    void CopyToBuffer(BUFFER_ST  *BuffPtr) { _CircBuff.CopyOut(reinterpret_cast<CIRCBUFFER::CBT*>(BuffPtr->ptr),BuffPtr->ValidPoints);}  // copy validpoints points to the buffer
    CCircBufferBase* GetCircBuffer() {return &_CircBuff;}

    virtual HRESULT Configure(ConfigReason reason);
    HRESULT UpdateTimeing(ConfigReason reason);
    HRESULT SetClockSource(ConfigReason reason);
    void CalculateInterval();
    int UpdateChannelSkew();
    short     _sampleTB; // time base used per point when scaning 
};


/////////////////////////////////////////////////////////////////////////////

class ATL_NO_VTABLE CLabInput : public Cnia2d
{
public:
    typedef TCircBuffer<short> CIRCBUFFER;
    CIRCBUFFER          _CircBuff;
    double RoundRate(double SourceRate); 
//    virtual void ProcessSamples(int samples);
    void InitBuffering(int Points)
    {
        _CircBuff.Initialize(Points);
    }
    void CopyToBuffer(BUFFER_ST  *BuffPtr) { _CircBuff.CopyOut(reinterpret_cast<CIRCBUFFER::CBT*>(BuffPtr->ptr),BuffPtr->ValidPoints);}  // copy validpoints points to the buffer
    CCircBufferBase* GetCircBuffer() {return &_CircBuff;}
    int TriggerSetup();   

    HRESULT Open(IDaqEngine * Interface,int _ID,DevCaps* DeviceCaps);
    STDMETHOD(SetChannelProperty)(long User,NESTABLEPROP * pChan, VARIANT * NewValue);
    STDMETHOD(SetProperty)(long User, VARIANT *newVal);
    STDMETHOD(ChildChange)(DWORD typeofchange, NESTABLEPROP *pChan);
    STDMETHOD(GetSingleValues)(VARIANT*);

    STDMETHOD(Trigger)();
//    virtual void ProcessSamples(int samples);
    HRESULT Configure(ConfigReason reason);
    HRESULT UpdateTimeing(ConfigReason reason);

    RANGE_INFO *CurrentRange;
};

/////////////////////////////////////////////////////////////////////////////

class ATL_NO_VTABLE CDSAInput :public Cnia2d 
{
public:
    typedef TCircBuffer<long> CIRCBUFFER;
    CIRCBUFFER          _CircBuff;
    STDMETHOD(Trigger)();
//    virtual void ProcessSamples(int samples);
    HRESULT Open(IDaqEngine * Interface,int _ID,DevCaps* DeviceCaps);
    void InitBuffering(int Points)
    {
        _CircBuff.Initialize(Points);
    }
    void CopyToBuffer(BUFFER_ST  *BuffPtr) { _CircBuff.CopyOut(reinterpret_cast<CIRCBUFFER::CBT*>(BuffPtr->ptr),BuffPtr->ValidPoints);}  // copy validpoints points to the buffer
    CCircBufferBase* GetCircBuffer() {return &_CircBuff;}
    HRESULT UpdateTimeing(ConfigReason reason); 

    STDMETHOD(GetSingleValues)(VARIANT*) {return E_NOTIMPL;}
    HRESULT Configure(ConfigReason reason);

};


#endif // !defined(AFX_NIA2D_H__D0C329D2_E0FF_11D1_A21F_00A024E7DC56__INCLUDED_)
