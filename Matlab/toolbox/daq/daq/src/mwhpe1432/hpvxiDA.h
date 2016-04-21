// hpvxiDA.h: Definition of the hpvxiDA class
//
//////////////////////////////////////////////////////////////////////
// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.1.6.2 $  $Date: 2003/12/04 18:39:27 $


#if !defined(AFX_hpvxiDA_H__602F2105_DF66_11D1_A21D_00A024E7DC56__INCLUDED_)
#define AFX_hpvxiDA_H__602F2105_DF66_11D1_A21D_00A024E7DC56__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

#pragma warning(disable:4996) // no warnings: CComModule::UpdateRegistryClass was declared deprecated

#include "resource.h"       // main symbols
#include "AdaptorKit.h"
#pragma warning(disable: 4229) 
#define INSTR_CALLBACKS     // needed to support interrupt callbacks
#include "hpe1432.h"
#pragma warning(default: 4229)
//#include "thread.h"
#include <vector>
#include "util.h"

#define SRC_CHAN_OFFSET (4096)	// source channels start at 4097

//#define USETHREAD

/////////////////////////////////////////////////////////////////////////////
// hpvxiDA

class hpvxiDA : 
public CmwDevice,
public ImwOutput,
public GlobalInfo,
public CComObjectRoot,
public CComCoClass<hpvxiDA,&CLSID_hpvxiDA>
{
    
public:
    static hpvxiDA *RunningDAPtr;
    
    long*           _buffer;
    ViInt32	        _blockSize;
    ViSession	    _session;		// session handle    
    ViInt32	        *_chanList;
    int             UserId[255];
    int             _numIdSpecified;
    bool            _callbackRegistered;
    int		    _chasis;
    
    IntProp         _clockSource;
    
    ViInt32	        _gid;		// group id   
    ViReal64        _minSpan;
    ViReal64        _maxSpan;
    bool            _isStarted;
    bool            _running;
    int             _nChannels;
    long            _bufferingconfig;
    double          _clockFreq;
    DoubleProp      _engineBlkSize;
    bool            _lessThanBuffer;
    DoubleProp      _sampleRate;
    DoubleProp	    _span;   
    DoubleProp      _triggerType;   
    DoubleProp      _triggerCondition;
    
    __int64         _pointsQueued;
    bstr_t	        _id;
    bool	        _lastBufferGap;
    double	        _maxSR;
    long	        _maxChannels;
    std::vector<ViInt32>  _validChanList;
    std::vector<ViInt32>  _validScaleFactor;
    
    // per channel
    ViInt32         *_rampRate;
    ViInt32         *_sourceOutput;
    ViInt32         *_sourceMode;    
    long	        *_cola;
    long	        *_sum;
    
    ViReal64	    *_chanRange[2];
    
    __int64         _samplesOutput;
    
    enum { HWCHAN=1, COLA, OUTPUT_RANGE, SOURCE_OUTPUT,	SOURCE_MODE, SUM, RAMP_RATE };
    
    
    
    
public:
    hpvxiDA();
    ~hpvxiDA();
    
    CComPtr<IProp> RegisterProperty(LPWSTR, DWORD);
    HRESULT SetDefaultRange(LPWSTR);
    HRESULT SetDaqHwInfo();    
    int ReallocCGLists();
    int InitChannels();
    int SetOutputRange(VARIANT *, int);
    int ChannelSetup();
    void SamplesOutput(long s) { _samplesOutput=s; }
    void srcCallback(int channel);
    bool VerifyBufferSize();
    double FindClockFreq(VARIANT*, bool);
    int InternalStart();
    void addDev(int);
    bool installCallback(int);
    
    BEGIN_COM_MAP(hpvxiDA)
        COM_INTERFACE_ENTRY(ImwDevice)
        COM_INTERFACE_ENTRY(ImwOutput)
        END_COM_MAP()
        //DECLARE_NOT_AGGREGATABLE(hpvxiDA) 
        // Remove the comment from the line above if you don't want your object to 
        // support aggregation. 
        
        //DECLARE_REGISTRY_RESOURCEID(IDR_hpvxiDA)
        DECLARE_REGISTRY( hpvxiDA, "mwhpe1432.output.1", "mwhpe1432.output", IDS_AdaptorDescription, THREADFLAGS_BOTH )
        
        
        // IOutput
        HRESULT Open(IDaqEngine*, wchar_t *devName);
public:
    STDMETHOD(GetStatus)(hyper *samplesProcessed, BOOL *running);
    STDMETHOD(PutSingleValues)(VARIANT*) { return E_NOTIMPL;}
    STDMETHOD(SetChannelProperty)(long, NESTABLEPROP*, VARIANT*);         
    STDMETHOD(SetProperty)(long, VARIANT*);     
    STDMETHOD(Start)();
    STDMETHOD(Stop)();    
    STDMETHOD(Trigger)();
    //    STDMETHOD(TranslateError)(HRESULT, BSTR*);
    STDMETHOD(ChildChange)(DWORD, NESTABLEPROP*);
};

#endif // !defined(AFX_hpvxiDA_H__602F2105_DF66_11D1_A21D_00A024E7DC56__INCLUDED_)
