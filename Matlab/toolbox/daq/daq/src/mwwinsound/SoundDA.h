// SoundDA.h: Definition of the SoundDA class
//
//////////////////////////////////////////////////////////////////////
// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.1.6.2 $  $Date: 2003/12/04 18:40:18 $

#if !defined(AFX_SOUNDDA_H__602F2105_DF66_11D1_A21D_00A024E7DC56__INCLUDED_)
#define AFX_SOUNDDA_H__602F2105_DF66_11D1_A21D_00A024E7DC56__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

#pragma warning(disable:4996) // no warnings: CComModule::UpdateRegistryClass was declared deprecated

#include "resource.h"       // main symbols
#include "buflist.h"
#include "adaptorkit.h"
#include "wavein.h"
#include "waveout.h"
#include "daqmex.h"
#include "util.h"
#include "thread.h"
/////////////////////////////////////////////////////////////////////////////
// SoundDA

class SoundDA : 
        public CSoundDevice,
	public ImwOutput,
	public CComObjectRoot,
	public CComCoClass<SoundDA,&CLSID_SoundDA>
{
    CWaveOutDevice  _waveOutDevice;
    BufferList	    _BufferList;    
    
    bool            _running;
    IntProp         _bitsPerSample;     // user settable    
	IntProp         _standardSampleRates;
    __int64         _samplesOutput;
    __int64         _pointsQueued;
    CWaveOutCaps    WaveCaps;
    UINT	    _id;
    bool	    _lastBufferGap;

    enum { HwChan=1, OUTPUTRANGE };


//    static void    CALLBACK waveOutProc(HWAVEOUT, UINT, SoundDA*, DWORD, DWORD);
    Thread _thread;
    int _isDying;
    CEvent _BufferDoneEvent;
    void CheckBuffersDone();
    static unsigned WINAPI ThreadProc(void* pArg);

public:
    SoundDA();
    ~SoundDA();
    BOOL IsBufferDone ();
    CComPtr<IProp> RegisterProperty(LPWSTR, DWORD);
    //HRESULT SetDefaultRange(LPWSTR);
    HRESULT SetDaqHwInfo();    
    static HRESULT  WaveOutError(MMRESULT err);

BEGIN_COM_MAP(SoundDA)
        COM_INTERFACE_ENTRY(ImwDevice)
	COM_INTERFACE_ENTRY(ImwOutput)
END_COM_MAP()
//DECLARE_NOT_AGGREGATABLE(SoundDA) 
// Remove the comment from the line above if you don't want your object to 
// support aggregation. 
    DECLARE_REGISTRY(SoundDA,_T("mwwinsound.output.1"),_T("mwwinsound.output"),IDS_SOUNDDA_DESC,THREADFLAGS_BOTH);

// IOutput
public:
    STDMETHOD(GetStatus)(hyper *samplesProcessed, BOOL *running);
    HRESULT BufferReadyForDevice();    
    STDMETHOD(FreeBufferData)(BUFFER_ST*);    
    HRESULT Open(IDaqEngine*, int _id);
    STDMETHOD(PutSingleValues)(VARIANT*) { return E_NOTIMPL;}
    STDMETHOD(SetProperty)(long user, VARIANT * NewValue);
    STDMETHOD(SetChannelProperty)(long User, tagNESTABLEPROP * pChan, VARIANT * NewValue);
    STDMETHOD(Start)();
    STDMETHOD(Stop)();    
    STDMETHOD(Trigger)();    

};

#endif // !defined(AFX_SOUNDDA_H__602F2105_DF66_11D1_A21D_00A024E7DC56__INCLUDED_)
