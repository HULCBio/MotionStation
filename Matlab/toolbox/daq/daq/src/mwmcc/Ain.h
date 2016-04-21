// Copyright 1998-2003 The MathWorks, Inc.
// $Revision: 1.1.6.2 $  $Date: 2003/12/04 18:39:47 $


// Ain.h : Declaration of the CAin

#ifndef __AIN_H_
#define __AIN_H_

#include "resource.h"       // main symbols
//#import "D:\cbi\include\daqmex.tlb" raw_interfaces_only, raw_native_types, no_namespace, named_guids
#include "daqmex.h"
#include "cbw.h"
#include "cirbuf.h"
#include "cbutil.h"
#include <xutility> // for min and max
using namespace std;

TCircBuffer<unsigned short>::~TCircBuffer()
    {
        if (m_Buffer)
	    int result = cbWinBufFree(m_Buffer);
	    //            VirtualFree(m_Buffer,0,MEM_RELEASE);
        m_Buffer=NULL;
    }
HRESULT TCircBuffer<unsigned short>::Initialize(int Size)
    {
        if (Size!=m_Size)
        {
            if (m_Buffer)
            	    int result = cbWinBufFree(m_Buffer);

		//VirtualFree(m_Buffer,0,MEM_RELEASE);
            if(Size)
            {
		m_Buffer = (CBT*)cbWinBufAlloc(Size*sizeof(CBT));
                //m_Buffer=(CBT*)VirtualAlloc(NULL, Size*sizeof(CBT), MEM_COMMIT, PAGE_READWRITE);
                if (m_Buffer==NULL) return E_OUTOFMEMORY;
            }
            else
                m_Buffer=NULL;
            m_Size=Size;
        }
        m_ReadLoc=0;
        m_WriteLoc=0;
        return(S_OK);
    }


class CcbiBuffer : public  TCircBuffer<unsigned short>
{
public:
    void ShiftCopyOut(CBT *dest,int size)
    {
        int size1,size2;
        CBT *ptr1, *ptr2;
        GetReadPointers(&ptr1, &size1, &ptr2, &size2);
		int points = min(size1,size);
        //memcpy(dest ,ptr1,points*sizeof(CBT));
        for (int i=0;i<points;i++)
            *dest++=*ptr1++>>4;
        m_ReadLoc+=points;
        if (m_ReadLoc>m_Size) m_ReadLoc=0;
        //ASSERT(bytes == OutSize);
        if (size2  && points<size)
        {
			points = min(size2 ,size-points);
            for (int i=0;i<points;i++)
               *dest++=*ptr2++>>4;
            m_ReadLoc = points;
        }

    }
    void CopyOut(CBT *dest,int size)
    {
	// DEST: Engine Buffer
	// SIZE: Points to copy
	// PTR1: Adaptor Buffer (full of data) (SRC)
	// SIZE1: Samples left to copy
        int size1,size2;
        CBT *ptr1, *ptr2;
        GetReadPointers(&ptr1, &size1, &ptr2, &size2);
		int points = min(size1 ,(int)size);
        
	//memcpy(dest ,ptr1,points*sizeof(CBT));
	int results = cbWinBufToArray(ptr1, dest, 0, points);

        m_ReadLoc+=points;
        if (m_ReadLoc>m_Size) m_ReadLoc=0;
        //ASSERT(bytes == OutSize);
        if (size2  && points<size) 
        {
			points = min(size2 ,size-points);
            CopyMemory(dest+size1 ,ptr2,points*sizeof(CBT));
            m_ReadLoc = points;
        }
        
    }
};
/////////////////////////////////////////////////////////////////////////////
// CAin
class ATL_NO_VTABLE CAin :
//public CComObjectRootEx<CComMultiThreadModel>,
public CComCoClass<CAin, &CLSID_Ain>,
public IDispatchImpl<IAin, &IID_IAin, &LIBID_MWMCCLib>,
public ISupportErrorInfo,
public TADDevice<CbDevice> //is based in ImwDevice
{
public:
    CAin();
    ~CAin();
    DECLARE_REGISTRY_RESOURCEID(IDR_AIN)

    DECLARE_PROTECT_FINAL_CONSTRUCT()

    BEGIN_COM_MAP(CAin)
    COM_INTERFACE_ENTRY(IAin)
    COM_INTERFACE_ENTRY(IDispatch)
    COM_INTERFACE_ENTRY(ISupportErrorInfo)
    COM_INTERFACE_ENTRY(ImwAdaptor)
    COM_INTERFACE_ENTRY(ImwDevice)
    COM_INTERFACE_ENTRY(ImwInput)
    END_COM_MAP()

    BEGIN_CATEGORY_MAP(CAin)
    IMPLEMENTED_CATEGORY(CATID_ImwAdaptor)
    END_CATEGORY_MAP()

    //    CComPtr<IDaqEngine>	_engine;
    bool TriggerPosted;
    long TriggersToGo;
    long PointsLeftInTrigger;  // when repeating (actualy any hw) this is used to count down

    //    int     _BoardNum;          // Currently selected board target
    typedef TCircBuffer<unsigned short> CIRCBUFFER;
    CcbiBuffer          _CircBuff;
    double  _settleTime;        // settleing time used for channelskew=minimum (BURSTMODE)
    double  _timerPeriod;       // Time (ms) between calls to GetScanData()
    bool	_Bursting;          // Are we getting all data in one circular buffer (BURSTIO)
    int     _Options;           // Scan options for cbAInScan
    long    _SampleRate;        // Current sample rate for scan.
    double  _RequestedRate;     // samplerate requested by MATLAB user
    long    _CurIndex;          // Used in GetScanData for current scan index.
    bool    _SupportsBurst;     // Does the device support BURSTMODE
    //    long    _PreIndex;          // Used in GetScanData for previous scan index.
    __int64 _pointsThisRun;    // Total samples acqired sense start
    bool _analogTrig;
    bool _digitalTrig;          // board has digital trigger
    bool _differential;         // inputs are differentail
    bool _selectableInputType;  // board can be changed from singleendied to di
    bool _convertData;      // true for 12 bit cards that must drop low 4 bits
    //    long    _HWBuffSize;        // Size of buffer passed to cbAInScan
    //    long    _nChannels;
    //    std::vector<int> _chanIds;  //hardware ids of channels
    //    std::vector<int> _chanRange; //gain/range enum value for channel
    long    _EngBuffSizePoints;       // Size of engine buffer(s)
    //    HGLOBAL _HWMemHandle;       // Returned from cbWinBuffAlloc for HW buffer
    //    unsigned short * _HWMemHandle;       // Returned from cbWinBuffAlloc for HW buffer
    //  Engine properties
    TRemoteProp<double> pChannelSkew;
    TCachedProp<long>   pChannelSkewMode;
    IntProp		pChanType;
    CachedEnumProp	pClockSource;
    IntProp             pInputType;

    IntProp         pTriggerDelayPoints;
    Int64Prop       pTriggerRepeat;
    CEnumProp       pTriggerType;
    TCachedProp<long>       pTriggerCondition;
    DoubleArrayProp pTriggerConditionValue;

    Int64Prop           pSamplesPerTrigger;
    TRemoteProp<long>   pTotalPointsToAcquire;

    //  Device Specific Properties

    long UpdateChans(bool ForStart=true)         // check the dirty bit and update if needed (clear dirty)
    {
        RETURN_HRESULT(InputType::UpdateChans(ForStart));
        return UpdateRateAndSkew();
    }
    int LoadDeviceInfo();
    HRESULT     UpdateRateAndSkew(long newskewmode,double newrate);
    HRESULT     UpdateRateAndSkew()
    {
        return UpdateRateAndSkew(pChannelSkewMode,_RequestedRate);
    }

    HRESULT     SetDaqHwInfo();
    HRESULT     GetScanData();
    HRESULT     SetAllInputRanges(RANGE_INFO *NewInfo);

    TTimerCallback<CAin,LowResTimer> TimerObj;
    bool TimerRoutine() {return (GetScanData()==S_OK);} // Returns 1 for stop status
    // IAin
    HRESULT Open(IUnknown *Interface, long ID);

public:
	STDMETHOD(CLoad)(VARIANT RegName, unsigned long LoadValue);
	STDMETHOD(C8254Config)(long CounterNum, long Config);
	STDMETHOD(AIn)(long Channel, long  Range,/*[out,retval]*/ unsigned short *DataValue);
	STDMETHOD(GetConfig)(long InfoType,long DevNum,long ConfigItem,long *ConfigVal);
	STDMETHOD(SetConfig)(long InfoType,long DevNum,long ConfigItem,long ConfigVal);
    // IDevice
    // Currently Implemented.
    STDMETHOD(GetSingleValues)(VARIANT * Values);
    STDMETHOD(Start)();
    STDMETHOD(Stop)();
    STDMETHOD(Trigger)();

    STDMETHOD(GetStatus)(__int64 * samplesProcessed, int * running);
    //STDMETHOD(ChildChange)(ULONG typeofchange, IPropContainer * Container, tagNESTABLEPROP * pChan);
    STDMETHOD(SetProperty)(long user, VARIANT * NewValue);
    STDMETHOD(SetChannelProperty)(long User, tagNESTABLEPROP * pChan, VARIANT * NewValue);

    // ISupportsErrorInfo
    STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

    //STDMETHOD(SetProperty)(IProp * Prop, VARIANT * NewValue)
    // IInput
    STDMETHOD(PeekData)(tagBUFFER * pBuffer);
};

#endif //__AIN_H_
