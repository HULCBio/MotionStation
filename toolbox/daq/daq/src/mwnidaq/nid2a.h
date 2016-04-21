// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.3.4.6 $  $Date: 2003/12/22 00:48:14 $


// nid2a.h: Definition of the nid2a class
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_NID2A_H__D0C329D5_E0FF_11D1_A21F_00A024E7DC56__INCLUDED_)
#define AFX_NID2A_H__D0C329D5_E0FF_11D1_A21F_00A024E7DC56__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

#pragma warning(disable:4996) // no warnings: CComModule::UpdateRegistryClass was declared deprecated

#include "mwnidaq.h"
#include "resource.h"       // main symbols
#include "daqtypes.h"
#include "daqmex.h"
//#include "evtmsg.h"
#include "AdaptorKit.h"
#include "nidisp.h"

#include "cirbuf.h"
#include "messagew.h"
/////////////////////////////////////////////////////////////////////////////
// nid2a

class ATL_NO_VTABLE Cnid2a : 
    public CmwDevice,
	public ImwOutput,
	public CComCoClass<Cnid2a,&CLSID_Cnid2a>,
    public CniDisp
{
public:
   
    unsigned long           _buffersDone;
    short *		    _chanList;
    double 		   *_chanRange[2];	    
    ShortProp		    _clockSrc;
    //ShortProp               _whichClock;
    TRemoteProp<long>       _timeBase;
    TRemoteProp<long>       _interval;
    //ShortProp               _delayMode;

    std::vector<double>	    _defaultValues;
    HWND		    _hWnd;
    long			_nChannels;
    CEnumProp		_outOfDataMode;
    IntProp		    _refSource;
    DoubleProp	    _refVoltage;
    bool		    _isConfig;
    bool		    _running;    
    bool		    _underrun;
    TCachedProp<double> _sampleRate;
    __int64         _samplesOutput;
    __int64         _samplesPut;
    IntProp		    _timeOut;
    IntProp		    _triggerType;   
    short		    _updateMode;
    DoubleProp	    _updateRate;
    ShortProp	    _waveformGroup;
    short * 	    _polarityList;
    //short *	    _buffer;    
    long            _EngineBufferSamples;
    IntProp		    _xferMode;
	    

    bool            _LastBufferLoaded;
    long		    _ptsTfr;
    long            _fifoSize;
    enum CHANPROPS 
	{
		HWCHAN=1,
		OUTPUTRANGE,
        DEFAULT_VALUE
    };    


    CComPtr<IPropRoot>	    _defaultChannelValueIProp; 

    static MessageWindow   *_Nid2aWnd;
    long                    _triggersPosted;

public:
    HRESULT SetNIDAQError(short status,const IID& iid = IID_ImwOutput)
    { return status!=0 ? Error(status,iid) : S_OK;};

    Cnid2a();
    ~Cnid2a();
    int ReallocCGLists();
    template <class PT>
    CComPtr<IProp> RegisterProperty(LPWSTR name,  PT &prop)
    {
        return prop.Attach(_EnginePropRoot,name,USER_VAL(prop));
    }
    void SetupChannels();
    int SetWaveformGenMsgParams(int mode);
    short GetID()			{ return _id;               }
    long Channels()                     { return _nChannels;        }
    short *ChanList()                   { return _chanList;         }
    void setRunning(bool running)	{ _running = running;       }
    bool Running()                      { return _running;          }
    long GetFifoSizePoints()         {return _fifoSize;}
    
    __int64 SamplesOutput()             { return _samplesOutput;    }
    void UpdateSamplesOutput(unsigned long ItersDone,unsigned long PointsDone) 
    { 
        _samplesOutput=((__int64)((unsigned __int64)ItersDone*GetBufferSizePoints())+PointsDone-GetFifoSizePoints())/_nChannels;
    }
    void SamplesOutput(__int64 s)       { _samplesOutput=s;         }
    bool Underrun()                     { return _underrun; }
    long PointsPerSecond()              { return (long)(_sampleRate*_nChannels);}
    void CleanUp();
    HRESULT Initialize();
    virtual HRESULT Configure();
    int SetOutputRangeDefault(short polarity);
    int SetOutputRange( VARIANT*, short);
    int LoadOutputRanges();
    void SetAllPolarities(short polarity);
    int SetXferMode();
    int TriggerSetup();
    long PtsTfr() { return _ptsTfr; }
    int SetDaqHwInfo();
    virtual void LoadData()=0;    // load/update data in the device buffer
    virtual void SyncAndLoadData()=0;  // take care of all dynamic stuff
    HRESULT Open(IDaqEngine * Interface,int _ID,DevCaps* DeviceCaps);
    int SetConversionOffset(short polarity);

BEGIN_COM_MAP(Cnid2a)
	COM_INTERFACE_ENTRY(ImwOutput)
        COM_INTERFACE_ENTRY(ImwDevice)
        COM_INTERFACE_ENTRY_CHAIN(CniDisp)
END_COM_MAP()
//DECLARE_NOT_AGGREGATABLE(nid2a) 
// Remove the comment from the line above if you don't want your object to 
// support aggregation. 

//DECLARE_REGISTRY_RESOURCEID(IDR_nid2a)
    DECLARE_REGISTRY( Cnid2a, "mwnidaq.output.1", "mwnidaq.output", IDS_NID2A_DESC, THREADFLAGS_BOTH )
    HRESULT InternalStart();

// IOutput
public:
    STDMETHOD(GetStatus)(hyper*, BOOL*);
    STDMETHOD(PutSingleValues)(VARIANT*);
    STDMETHOD(Start)();
    STDMETHOD(Stop)();    
    STDMETHOD(Trigger)();
    STDMETHOD(TranslateError)(VARIANT * eCode, VARIANT *retVal);
    
    STDMETHOD(SetChannelProperty)(long User,NESTABLEPROP * pChan, VARIANT * NewValue);
    STDMETHOD(SetProperty)(long User, VARIANT *newVal);
    STDMETHOD(ChildChange)(DWORD typeofchange, NESTABLEPROP *pChan);

    // functions that depend on the data type
    virtual void InitBuffering(int Points)=0;
    virtual long GetBufferSizePoints()=0;
    virtual void *GetBufferPtr()=0;
    virtual HRESULT DeviceSpecificSetup() { return S_OK; }
private:
};

template <typename NativeDataType>
class ATL_NO_VTABLE Tnid2a :public Cnid2a
{
    public:
    typedef TCircBuffer<NativeDataType> CIRCBUFFER;
    CIRCBUFFER              _CircBuff;
    std::vector<NativeDataType> StoppedValue;
    void InitBuffering(int Points)
    {
        _CircBuff.Initialize(Points);
        StoppedValue.resize(_nChannels);
    }
    long GetBufferSizePoints()
    {
        return _CircBuff.GetBufferSize();
    }
    void *GetBufferPtr()
    {
        return _CircBuff.GetPtr();
    }
    virtual void LoadData();    // load/update data in the device buffer
    virtual void SyncAndLoadData();  // take care of all dynamic stuff
};
//extern template class Tnid2a<short>;
//extern template class Tnid2a<long>;


class  ATL_NO_VTABLE CESeriesOutput :public Tnid2a<short>
{
public:
 //   STDMETHOD(Trigger)();
//    virtual void ProcessSamples(int samples);
};

class ATL_NO_VTABLE CDSAOutput :public Tnid2a<long>
{
public:
  //  STDMETHOD(Trigger)();
//    virtual void ProcessSamples(int samples);
    HRESULT DeviceSpecificSetup();
    STDMETHOD(PutSingleValues)(VARIANT*) { return E_NOTIMPL;}    
    STDMETHOD(SetProperty)(long User, VARIANT *newVal);

};

#endif // !defined(AFX_NID2A_H__D0C329D5_E0FF_11D1_A21F_00A024E7DC56__INCLUDED_)
