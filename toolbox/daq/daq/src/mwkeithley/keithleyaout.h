// keithleyaout.h : Declaration of the Keithley AnalogOutput device
// $Revision: 1.1.6.2 $
// $Date: 2003/12/04 18:39:40 $

// Copyright 2002-2003 The MathWorks, Inc. 
// Coded by OPTI-NUM solutions

#ifndef __KEITHLEYAOUT_H_
#define __KEITHLEYAOUT_H_

#pragma warning(disable:4996) // no warnings: CComModule::UpdateRegistryClass was declared deprecated

#include "resource.h"       // main symbols
#include "keithleyadapt.h"
#include "MessageW.h"
#include "keithleypropdef.h"

//This abstract class extends the CswClockedDevice class by a single ..
//..pure virtual function PutSingleValue() 
class ATL_NO_VTABLE CKeithleyOutputBase: public CswClockedDevice
{
public:
    typedef short RawDataType; 
    enum BitsEnum {Bits=16}; // bits must fit in rawdatatype 
    virtual HRESULT PutSingleValue(int index,RawDataType Value)=0;
	virtual	HRESULT UpdateChans(bool ForStart);

};

/////////////////////////////////////////////////////////////////////////////
// Ckeithleyaout class declaration
//
// Ckeithleyaout is based on ImwDevice and ImwInput via chains:..
//.. ImwDevice -> CmwDevice -> CswClockedDevice -> CKeithleyInputBase ->..
//.. TADDevice -> Ckeithleyaout  and.. 
//.. ImwInput -> TADDevice -> Ckeithleyaout
class ATL_NO_VTABLE Ckeithleyaout : 
	public TDADevice<CKeithleyOutputBase>, //is based on ImwDevice
	public CComCoClass<Ckeithleyaout, &CLSID_keithleyaout>,
	public ISupportErrorInfo,
	public IDispatchImpl<IKeithleyAOut, &IID_IKeithleyAOut, &LIBID_KEITHLEYLib>
{
    typedef TDADevice<CKeithleyOutputBase> TBaseObj;

public:

DECLARE_REGISTRY( Ckeithleyadapt, _T("Keithley.keithleyaout.1"), _T("Keithley.keithleyaout"),
				  IDS_PROJNAME, THREADFLAGS_BOTH )

//this line is not needed if the program does not support aggregation
DECLARE_PROTECT_FINAL_CONSTRUCT()

//ATL macros internally implementing QueryInterface() for the mapped interfaces
BEGIN_COM_MAP(Ckeithleyaout)
	COM_INTERFACE_ENTRY(ImwDevice)
	COM_INTERFACE_ENTRY(IKeithleyAOut)
	COM_INTERFACE_ENTRY(ImwOutput)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

public:
	Ckeithleyaout();
	virtual ~Ckeithleyaout();
	// Standard methods implemented by all adaptors:
    HRESULT Open(IUnknown *Interface,long ID);
	HRESULT SetDaqHwInfo();
    STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);
	STDMETHODIMP SetProperty(long User, VARIANT * NewValue);
	STDMETHODIMP SetChannelProperty(long UserVal, tagNESTABLEPROP * pChan, VARIANT * NewValue);
	STDMETHODIMP ChildChange(DWORD typeofchange, NESTABLEPROP *pChan);

    HRESULT PutSingleValue(int chan,RawDataType value);
	STDMETHOD (PutSingleValues)(VARIANT* values);

	STDMETHOD(Start)();
	STDMETHOD(Trigger)();
	STDMETHOD(Stop)();

	// Methods which implement messaging:
	MessageWindow* GetParent();
	void SetParent(MessageWindow* pParent);
	void ReceivedMessage(UINT wParam, long lParam);
	void LoadData(UINT bufIndex );

	// Methods which help with channels
	HRESULT UpdateChans(bool ForStart);
	HRESULT UpdateDefaultChannelValue(int channel,double value);

	// DriverLINX Helper functions
	HRESULT SetupSR(bool forStart = false);
	UINT Sec2Tics(double secs);
	bool Tics2Sec(double Tics, double* Sec);
	
	// Other methods used throughout the adaptor
	HRESULT LoadINIInfo();
	double QuantiseValue(double valSecs, bool performcheck = true);
	double CalculateMinSampleRate(UINT countersize);
	double CalculateMaxSampleRate(BOOL FirstTime = false);
	double CalculateMicroSec();
	void   CalculateNewRate(double newrate);
	HRESULT FindRange(float low, float high, RANGE_INFO *&pRange);
	HRESULT LoadRangeInfo();
	double RoundRange(double inputvalue);
	void GetOutputRange(double *mindiff, double *maxdiff, double *minsing, double *maxsing);

	void UpdateSamplesOutput();
	CComBSTR TranslateResultCode(UINT resultCode);
	void SetAllPolarities(short polarity);

private:
	bool m_supportsDMA;
	bool m_supportsPolledClockOnly;
	BOOL m_supportsBurstMode;
	double m_chanSkew;
	HINSTANCE m_driverHandle;
	__int64 m_validPointsToDL;
	__int64 m_actualPointsToFIFO;
	long m_dlBufferPoints;
	UINT m_clockDividerWidth;
	long m_channelGainQueueSize;
	bool m_usingDMA;
	float m_aoTicPeriod;
	double m_maxBoardSampleRate;
	double m_minBoardSampleRate;
	float m_burstModeClockFreq;
	bool m_triggerPosted;
	bool m_triggering;
	UINT m_fifoSize;
	long m_engineBufferSamples;
    
	StatusTypes m_daqStatus;		// Status of the curent task

    std::vector<RawDataType> m_defaultChannelValues; // Stores default value or last value for each channel

	BOOL m_isInitialized;
	SubSystems m_subSystem;
	DL_ServiceRequest* m_pSR;

	WORD m_deviceID;
	HANDLE m_ldd;
	MessageWindow * m_pParent;

	BOOL m_supportsBipolar;
	BOOL m_supportsUnipolar;
	WORD m_numgains;
	short m_polarity;	// Current polarity.

    std::vector<float> m_chanGain;
    typedef std::vector<RANGE_INFO> RangeList_t;
    RangeList_t m_validRanges;

	// Engine Properties - Base Properties
	//TCashedProp<double> pSampleRate;  
    CEnumProp           pOutOfDataMode;
	CachedEnumProp		pTriggerCondition;
    DoubleArrayProp		pTriggerConditionValue;
	TCachedProp<double>	pTriggerDelay;
	CachedEnumProp		pTriggerType;
	TCachedProp<double> pRepeatOutput;
	CachedEnumProp		pTransferMode;
	CachedEnumProp		pClockSource;

	// We need to define the following non-zero values in order to attach to 
	// channel properties. Although we only use OUTPUTRANGE, we still
	// define all of them as we set some defaults for the other properties, 
	// and still want out SetChannelProperty called when any of this changes.
	enum CHANUSER {DEFAULTCHANVAL=1,HWCHANNEL,NATIVEOFFSET,NATIVESCALING, OUTPUTRANGE};

};

#endif //__KEITHLEYAOUT_H_
