// Copyright 1998-2003 The MathWorks, Inc.
// $Revision: 1.1.6.2 $  $Date: 2003/12/04 18:39:49 $


// Aout.h : Declaration of the CAout

#ifndef __AOUT_H_
#define __AOUT_H_

#include "resource.h"       // main symbols
//#import "D:\cbi\include\daqmex.tlb" raw_interfaces_only, raw_native_types, no_namespace, named_guids
#include "daqmex.h"
#include "cirbuf.h"
#include "cbutil.h"
#include <algorithm>

/////////////////////////////////////////////////////////////////////////////
// CAout
#define  TRIG_DIGITAL MAKE_USER_TRIGGER(TRIG_PRETRIGGER_DISABLED | TRIG_TRIGGER_IS_HARDWARE,1L)

class ATL_NO_VTABLE CAout :
//	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CAout, &CLSID_Aout>,
	public ISupportErrorInfo,
	public IAout,
        public TDADevice<CbDevice>
{
private:
    
    double dAOStartTime; // Holds the DAQENGINE time at start of output
    int iSamplesToOutput; // Holds the total number of samples for a run

public:
    CAout();
    ~CAout();

DECLARE_REGISTRY_RESOURCEID(IDR_AOUT)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CAout)
	COM_INTERFACE_ENTRY(IAout)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY(ImwDevice)
	COM_INTERFACE_ENTRY(ImwOutput)
END_COM_MAP()
    HRESULT Open(IDaqEngine * Interface,long ID);

    typedef TCircBuffer<RawDataType> CIRCBUFFER;
    std::vector<RawDataType> _defaultChannelValues; // used only for ao but needed for UpdateChans
    CIRCBUFFER          _CircBuff;

    int     _Options;           // Scan options for cbAInScan
    long    _SampleRate;        // Current sample rate for scan.
    long    _PreIndex;          // Used in  for previous scan index.
    __int64 _samplesPut;        // total samples put to the device
    //__int64 _samplesOutput;    // Total samples output sense start
    long    _EngBuffSize;       // Size of engine buffer(s)
    long    _buffersDone;
    long    _triggersPosted;
    bool    _LastBufferLoaded;
    bool    _UseHardwareRange;  // true if the device is jumper configured
    TCachedProp<double> pChanSkew;
    TCachedProp<long>   pChanSkewMode;
    CachedEnumProp	pClockSource;
    CEnumProp           pOutOfDataMode;
//    IntProp         pTriggerType;

    //  Device Specific Properties

    // Local functions
    TTimerCallback<CAout,LowResTimer> TimerObj;
    bool TimerRoutine()
    {
        SyncAndLoadData();
        return _running;
    }
    long UpdateChans(bool ForStart=true);         // check the dirty bit and update if needed (clear dirty)
    HRESULT UpdateDefaultChannelValue(int channel,double value);

    HRESULT SetDaqHwInfo();
    void SyncAndLoadData();
    void LoadData();
    void UpdateSamplesOutput(unsigned long ItersDone,unsigned long PointsDone)
    {
        _samplesOutput=min(_samplesPut,((__int64)ItersDone*_CircBuff.GetBufferSize()+PointsDone /*-_fifoSize*/)/_nChannels);
    }
    int LoadDeviceInfo();

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);


// IAout
public:
    // IDevice
    STDMETHOD(Start)();
    STDMETHOD(Stop)();
    STDMETHOD(Trigger)();
    STDMETHOD(SetChannelProperty)(long user, tagNESTABLEPROP * pChan, VARIANT * NewValue);
    STDMETHOD(SetProperty)(long user, VARIANT * NewValue);
    STDMETHOD(ChildChange)(ULONG typeofchange,  tagNESTABLEPROP * pChan);

    // IOutput
        };

#endif //__AOUT_H_
