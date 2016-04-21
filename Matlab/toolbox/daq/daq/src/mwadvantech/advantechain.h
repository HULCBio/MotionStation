// advantechAin.h : Declaration of CadvantechAin class
// Copyright 2002-2003 The MathWorks, Inc.
// $Revision: 1.1.6.2 $  $Date: 2003/12/04 18:39:17 $


#ifndef __advantechIN_H_
#define __advantechIN_H_

#include "stdafx.h"
#include "resource.h"       // main symbols
#include "mwadvantech.h"
#include "advantechpropdef.h"
#include "advantechUtil.h"
#include "advantechadapt.h"
#include "advantecherr.h"
#include "advantechBuffer.h"	// Buffer handling code
#include "driver.h"
#include <vector>

// Extend CadvBuffer to overload the CopyOut method.
class CadvAIBuffer: public CadvBuffer
{
public:
	HRESULT CopyOut(CBT *dest,int size)
    {
        int size1,size2;
        CBT *ptr1, *ptr2;
		CBT * temp = NULL;
        GetReadPointers(&ptr1, &size1, &ptr2, &size2);
		//DEBUG: ATLTRACE("\nIn CopyOut:\n\tsize is: %d\n\tsize1 is: %d\n\tsize2 is: %d\n",size, size1, size2);
        int points = min(size1, size);
		if (points)
		{
			//DEBUG: ATLTRACE("Copying first part of %d points from start %d..", points, ptr1-GetPtr());
			//DEBUG: ATLTRACE("\n\tm_Buffer=%x, ptr1=%x, size1=%d..",m_Buffer, ptr1, size1);
			m_ptFAITransfer.DataBuffer = dest;			
			m_ptFAITransfer.start    = (ULONG)(ptr1 - GetPtr());
			m_ptFAITransfer.count    = (ULONG)points;
			LRESULT transfererror = DRV_FAITransfer(m_driverHandle, (LPT_FAITransfer)&m_ptFAITransfer);
			if (transfererror != 0)
			{
				return E_TRANSFER_ERROR;
			}
			m_ReadLoc+=points;
		}
        if (m_ReadLoc>m_Size) 
		{
			m_ReadLoc=0;
		}
        if (size2  && points<size) 
        {
            points = min(size2 ,size-points);
			if (points)
			{
				//DEBUG: ATLTRACE("Copying second part of %d points from start %d..", points, ptr2-GetPtr());
				//DEBUG: ATLTRACE("\n\tm_Buffer=%x, ptr2=%x, size2=%d..",m_Buffer, ptr2, size2);
				m_ptFAITransfer.DataBuffer = dest+size1;
				// FAITransfer wants an offset, not a pointer.
				m_ptFAITransfer.start    = (ULONG)(ptr2 - GetPtr());
				m_ptFAITransfer.count    = (ULONG)points;
				LRESULT transfererror = DRV_FAITransfer(m_driverHandle, (LPT_FAITransfer)&m_ptFAITransfer);
				if (transfererror != 0)
				{
					return E_TRANSFER_ERROR;
				}
				m_ReadLoc = points;
			}
        }
     return S_OK;   
    };
};


////////////////////////////////////////////////////////////////////////////
// CadvantechAinputBase class declaration
// This abstract class extends the CswClockedDevice class by a single
// pure virtual function GetSingleValue() 
////////////////////////////////////////////////////////////////////////////
class ATL_NO_VTABLE CadvantechAinputBase: public CswClockedDevice
{
public:
    typedef short RawDataType; 
    enum BitsEnum {Bits=16}; // bits must fit in rawdatatype 
    virtual HRESULT GetSingleValue(int index,RawDataType *Value)=0;
};


/////////////////////////////////////////////////////////////////////////////
// CadvantechAin class declaration
//
// CadvantechAin is based on ImwDevice and ImwInput via chains:..
//.. ImwDevice -> CmwDevice -> CswClockedDevice -> CadvantechAinputBase ->..
//.. TADDevice -> CadvantechAin  and.. 
//.. ImwInput -> TADDevice -> CadvantechAin
////////////////////////////////////////////////////////////////////////////
class ATL_NO_VTABLE CadvantechAin : 
	public TADDevice<CadvantechAinputBase>, //is based on ImwDevice
	public CComCoClass<CadvantechAin, &CLSID_advantechAin>,
	public ISupportErrorInfo,
	public IDispatchImpl<IadvantechAin, &IID_IadvantechAin, &LIBID_ADVANTECHLib>
{
    typedef TADDevice<CadvantechAinputBase> TBaseObj;

public:

DECLARE_REGISTRY( Cadvantechadapt, _T("advantech.advantechAin.1"), _T("advantech.advantechAin"),
				  IDS_PROJNAME, THREADFLAGS_BOTH )

// This line is not needed if the program does not support aggregation
DECLARE_PROTECT_FINAL_CONSTRUCT()

// ATL macros internally implementing QueryInterface() for the mapped interfaces
BEGIN_COM_MAP(CadvantechAin)
	COM_INTERFACE_ENTRY(IadvantechAin)
	COM_INTERFACE_ENTRY(ImwDevice)
	COM_INTERFACE_ENTRY(ImwInput)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

public:
	CadvantechAin();
	~CadvantechAin();

	// Methods
    HRESULT Open(IUnknown *Interface,long ID);
	HRESULT SetDaqHwInfo();
	STDMETHOD(Start)();
	STDMETHOD(Trigger)();
	STDMETHOD(Stop)();
	STDMETHOD(SetProperty)(long User, VARIANT * NewValue);
	STDMETHOD(SetChannelProperty)(long UserVal, tagNESTABLEPROP * pChan, VARIANT * NewValue);
	STDMETHOD(ChildChange)(DWORD typeofchange, NESTABLEPROP *pChan);
    STDMETHOD (InterfaceSupportsErrorInfo)(REFIID riid);
    HRESULT GetSingleValue(int chan,RawDataType *value);

	TTimerCallback<CadvantechAin,HiResTimer> TimerObj;
	bool TimerRoutine() {return (GetScanData()==S_OK);} // Returns 1 for stop status. 
	HRESULT GetScanData();

	Cadvantechadapt * GetParent() {return m_pParent;}
	void SetParent(Cadvantechadapt * parent) {m_pParent = parent;}

private:

	// Methods
	HRESULT LoadINIInfo();
	int GetFreqArea();
	HRESULT LoadRangeInfo(bool *supportsUnipolar);
	ITInputType GetInputTypeConfiguration();
	void GetPolarityConfiguration();
	void MaxInputRange(PolarityType polarity, double *lowRange, double *highRange);
	HRESULT FindRange(float low, float high,  RANGE_INFO *&pRange);
	HRESULT UpdateChans(bool ForStart);
	HRESULT StopDeviceIfRunning();
	double QuantiseValue(double rate);
	void SetAllPolarities(PolarityType polarity);
	void CheckTransferMode(bool showWarnings);
	void ValidateNewRate(double newrate, double maxCurrentRate);
	void UpdateRateandSkew();
	HRESULT SetDefaultTriggerConditionValues(double minVol, double maxVol);
	
	// Variables
	Cadvantechadapt * m_pParent;
    typedef TCircBuffer<unsigned short> CIRCBUFFER;
	ITInputType m_inputType;
	short m_scanStatus;

	DEVFEATURES			m_DevFeatures;			// Structure containing list of features eg. board ID, gainlist...
	DEVCONFIG_AI		m_DevConfigAI;			// Structure containing analog input configuration data
	PT_FAIIntScanStart	m_ptFAIIntScanStart;	// FAIIntScanStart table
	PT_FAIDmaScanStart  m_ptFAIDmaScanStart;	// The structure containing info about an an acquisitions setup
	PT_FAIDmaStart		m_ptFAIDmaStart;
	PT_FAIDmaExStart	m_ptFAIDmaExStart;		// Structure for devices supporting HW triggers
	PT_FAICheck			m_ptFAICheck;			// The structure containing info about an an acquisitions status
	USHORT				m_gwActiveBuf;			// Returned in FAICheck structure
	USHORT				m_gwOverrun;			// Returned in FAICheck structure
    USHORT				m_gwStopped;			// Returned in FAICheck structure   
	USHORT				m_gwHalfReady;			// Returned in FAICheck structure
	ULONG				m_retrieved;			// Returned in FAICheck structure

	CadvAIBuffer        m_circBuff;
	long				m_triggersToGo;
	bool				m_triggerPosted;		// True if a trigger has been posted
	bool				m_singleShot;			// True if we are going to get less than a buffersize of points
	long				m_engBuffSizePoints;	// Size of engine buffer(s), as per CBI adaptor
	long				m_pointsLeftInTrigger;
	double				m_timerPeriod;			
	bool				m_swInputType;			// 1 if software configurable input type, 0 if jumpered
	bool				m_swPolarityConfig;		// 1 if software configurable polarity, 0 if jumpered
	int					m_aiDiffMult;			// Multiplication factor for differential inputs
	__int64				m_pointsThisRun;		// Total samples acquired since start
	int					m_aiInterruptMode;
	CHAR				m_DeviceName[50];
	PolarityType		m_polarity;				// Variable to keep track of the current polarity
	short				m_maxAIDiffChl;			// Maximum number of differential channels for device
	short				m_maxAISiglChl;			// Maximum number of single-ended channels for device
	int					m_aiFifo;				// Anolog in FIFO buffer size
	bool				m_supportsHwTrigger;	// INI file: True if Hw Triggers supported (and hence call DRV_FAIDmaExStart)
	WORD				m_deviceID;		
	long				m_driverHandle;	
	short				m_numGains;				// Total number of gains available for selected device
	double				m_maxSampleRate;		// Maximum sample rate of HARDWARE CLOCK (not max settable in MATLAB object)
	double				m_minSampleRate;		// Minimum sample rate of HARDWARE CLOCK (not min settable in MATLAB object)
	bool				m_supportsScanning;		// TRUE: Device can have multiple channels

	std::vector<USHORT> m_chanGainCode;
	typedef std::vector<RANGE_INFO> RangeList_t;
    RangeList_t		m_validRanges;

	// Engine Properties - Base Properties
    TCachedProp<long>   pChannelSkewMode;
	TRemoteProp<double> pChannelSkew;
	TRemoteProp<long>	pTotalPointsToAcquire;
	TRemoteProp<double>	pSamplesPerTrigger;
	TCachedProp<double> pTriggerRepeat;
	TRemoteProp<long>	pClockSource;
	TRemoteProp<long>	pInputType;
	TRemoteProp<long>   pTriggerType;			// Need this for manual triggers with MTHO = Trigger!
	TRemoteProp<long>	pManualTriggerHwOn;		// Need this for manual triggers with MTHO = Trigger!
	// These will be needed for hardware triggers:
	TCachedProp<long>   pTriggerCondition;
    DoubleArrayProp		pTriggerConditionValue;
	TCachedProp<double>	pTriggerDelay;
	// TRemoteProp<long>	pTriggerDelayPoints;

	// Engine Properties - Device Secific
	CachedEnumProp		pTransferMode;
};

#endif //__advantechIN_H_
