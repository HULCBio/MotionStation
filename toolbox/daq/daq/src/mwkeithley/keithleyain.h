// keithleyain.h : Declaration of AnalogInput device
// $Revision: 1.1.6.2 $
// $Date: 2003/12/04 18:39:38 $

// Copyright 2002-2003 The MathWorks, Inc. 
// Coded by OPTI-NUM solutions

#ifndef __KEITHLEYAIN_H_
#define __KEITHLEYAIN_H_

#pragma warning(disable:4996) // no warnings: CComModule::UpdateRegistryClass was declared deprecated

#include "resource.h"       // main symbols
#include "mwkeithley.h"
#include "keithleypropdef.h"
#include "messagew.h"

class Ckeithleyadapt;

//This abstract class extends the CswClockedDevice class by a single ..
//..pure virtual function GetSingleValue() 
class ATL_NO_VTABLE CKeithleyInputBase: public CswClockedDevice
{
public:
    typedef short RawDataType; 
    enum BitsEnum {Bits=16}; // bits must fit in rawdatatype 
    virtual HRESULT GetSingleValue(int index,RawDataType *Value)=0;
};

/////////////////////////////////////////////////////////////////////////////
// Ckeithleyain class declaration
//
// Ckeithleyain is based on ImwDevice and ImwInput via chains:..
//.. ImwDevice -> CmwDevice -> CswClockedDevice -> CKeithleyInputBase ->..
//.. TADDevice -> Ckeithleyain  and.. 
//.. ImwInput -> TADDevice -> Ckeithleyain
class ATL_NO_VTABLE Ckeithleyain : 
	public TADDevice<CKeithleyInputBase>, //is based on ImwDevice
	public CComCoClass<Ckeithleyain, &CLSID_keithleyain>,
	public ISupportErrorInfo,
	public IDispatchImpl<IKeithleyAIn, &IID_IKeithleyAIn, &LIBID_KEITHLEYLib>
{
    typedef TADDevice<CKeithleyInputBase> TBaseObj;

public:

DECLARE_REGISTRY( Ckeithleyadapt, _T("Keithley.keithleyain.1"), _T("Keithley.keithleyain"),
				  IDS_PROJNAME, THREADFLAGS_BOTH )

//this line is not needed if the program does not support aggregation
DECLARE_PROTECT_FINAL_CONSTRUCT()

//ATL macros internally implementing QueryInterface() for the mapped interfaces
BEGIN_COM_MAP(Ckeithleyain)
	COM_INTERFACE_ENTRY(IKeithleyAIn)
	COM_INTERFACE_ENTRY(ImwDevice)
	COM_INTERFACE_ENTRY(ImwInput)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

public:
	Ckeithleyain();
	virtual ~Ckeithleyain();
	HRESULT Open(IUnknown *Interface,long ID);
	HRESULT SetDaqHwInfo();
    STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);
	STDMETHOD(SetProperty)(long User, VARIANT * NewValue);  	
	STDMETHOD(SetChannelProperty)(long UserVal, tagNESTABLEPROP * pChan, VARIANT * NewValue);
	STDMETHOD(ChildChange)(DWORD typeofchange, NESTABLEPROP *pChan);
	HRESULT GetSingleValue(int chan,RawDataType *value);
	STDMETHOD(GetSingleValues)(VARIANT * Values);	

	STDMETHOD(Start)();
	STDMETHOD(Trigger)();
	STDMETHOD(Stop)();
	STDMETHOD(PeekData)(BUFFER_ST *buffer);

	HRESULT SetupSR( bool forStart = false);
	void ReceivedMessage( UINT wParam, long lParam);
	CComBSTR TranslateResultCode( UINT resultCode );

	HRESULT LoadINIInfo();
	HRESULT LoadRangeInfo();
	HRESULT FindNumberOfChannels();
	UINT FindFIFOSize();
	int SetDefaultTriggerConditionValues();
	HRESULT FindRange(double low,double high,RANGE_INFO* &pRange);
	void GetInputRange( double* mindiff, double* maxdiff, double* minsing, double* maxsing );

	MessageWindow* GetParent();

	HRESULT UpdateChans(bool forStart);

	UINT Sec2Tics(double secs);
	bool Tics2Sec(double Tics, double* Sec);
	double QuantiseValue( double valSecs , bool performcheck = true);
	double CalcEquiSmplMinSR( UINT countersize );
	double CalculateMinSampleRate( UINT countersize );
	double CalculateMaxSampleRate( bool noChans = false );
	double CalculateMicroSec();
	void   CalculateRateAndSkew(double newrate, long newskewmode);
	double RoundRange(double inputvalue);

	void SetAllPolarities(short polarity);

private:
	bool m_supportsDMA;
	bool m_supportsPolledClockOnly;
	BOOL m_supportsBurstMode;
	HINSTANCE m_driverHandle;
	HRESULT ConfigureStopTrigger();
	float m_chanSkewSafetyRange;
	ChannelSkewSafetyUnitTypes m_chanSkewSafetyUnits;
	long m_terminationMode;
	UINT m_clockDividerWidth;
	WORD m_numSEOnBoard;
	WORD m_numDIOnBoard;
	WORD m_maxValidSEChan;
	WORD m_maxValidDIChan;
	long m_channelGainQueueSize;
	bool m_usingDMA;
	float m_aiTicPeriod;
	BOOL m_triggerPosted;
	BOOL m_triggering;
	double m_maxManChanSkew;
	double m_minManChanSkew;
	double m_maxBoardSampleRate;
	double m_minBoardSampleRate;
	StatusTypes m_daqStatus;
	unsigned long m_triggersProcessed;
	_int64 m_samplesThisRun;
	long m_engineBufferSamples;
	BOOL m_isInitialized;
	SubSystems m_subSystem;
	DL_ServiceRequest* m_pSR;
	WORD m_deviceID;
	HANDLE m_ldd;
	MessageWindow* m_pParent;
	std::vector<float> m_chanGain;
    typedef std::vector<RANGE_INFO> RangeList_t;
    RangeList_t m_validRanges;
	BOOL m_supportsBipolar;  // Do we support Bipolar?
	BOOL m_supportsUnipolar; // Do we support Unipolar?
	WORD m_numgains;// this is the holder for the number of gains that we support.
	short m_polarity;	// Store the polarity of the subsystem.
	float m_termination;	// Termination type code (same datatype as m_chanGain)

// Engine Properties - Base Properties
    TRemoteProp<double> pChannelSkew;
    CachedEnumProp		pChannelSkewMode;
	CachedEnumProp		pInputType;
	// pSampleRate is defined in the CswClockedDevice class, which we inherit.
//	TCashedProp<double> pSampleRate;  
  	CachedEnumProp		pTriggerCondition;
    DoubleArrayProp		pTriggerConditionValue;
	// Not sure why this was a cached prop, so set it to remote.
	// TCashedProp<double>	pTriggerDelay;
	TRemoteProp<double>	pTriggerDelay;
	CachedEnumProp		pTriggerType;
	TRemoteProp<long>	pTotalPointsToAcquire;
	TRemoteProp<double>	pSamplesPerTrigger;
	// Not sure why this was a cached prop, so set it to remote.
	// TCashedProp<double>	pTriggerRepeat;
	TRemoteProp<double> pTriggerRepeat;
	CachedEnumProp		pClockSource;
	
// Engine Properties - Device Secific
	CachedEnumProp		pStopTriggerType;
	TRemoteProp<double>	pStopTriggerChannel;
    CachedEnumProp		pStopTriggerCondition;
	TRemoteProp<double>	pStopTriggerConditionValue;
	TRemoteProp<double>	pStopTriggerDelay;
    CachedEnumProp		pStopTriggerDelayUnits;
	CachedEnumProp		pTransferMode;

	enum CHANUSER {INPUTRANGE=1,HWCHANNEL,NATIVEOFFSET,NATIVESCALING}; // do not use user of 0
};

#endif //__KEITHLEYAIN_H_
