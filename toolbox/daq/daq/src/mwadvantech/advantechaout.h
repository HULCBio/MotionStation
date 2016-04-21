// advantechAout.h : Declaration of CadvantechOut class
// Copyright 2002-2003 The MathWorks, Inc.
// $Revision: 1.1.6.2 $  $Date: 2003/12/04 18:39:19 $


#ifndef __advantechOUT_H_
#define __advantechOUT_H_

#pragma warning(disable:4996) // no warnings: CComModule::UpdateRegistryClass was declared deprecated

#include "stdafx.h"
#include "resource.h"       // main symbols
#include "mwadvantech.h"
#include "advantechpropdef.h"
#include "advantechadapt.h"
#include "advantechUtil.h"
#include "advantecherr.h"
#include "advantechBuffer.h"	// Advantech circular buffer overload methods.
#include "driver.h"
#include <vector>

class CadvAOBuffer : public CadvBuffer
{
public:
	HRESULT CopyIn(CBT *src,int size, bool initialLoad)
    {
		// DEBUG: ATLTRACE(_T("In CopyIn\n"));
		if (!m_driverHandle)
			return E_BUFDRVHANDLE;
		PT_FAOLoad ptFAOLoad;
        ptFAOLoad.ActiveBuf = 0;   

        int size1,size2;
        CBT *ptr1, *ptr2;
        GetWritePointers(&ptr1, &size1, &ptr2, &size2);

		int points = min(size1, size);
		// Transfer first part?
		if (points > 0)
		{
			//DEBUG: ATLTRACE("\tPart 1: Transferring %d points from loc %d (m_Size is %d)\n", points, (ptr1-GetPtr()), m_Size);
			//DEBUG: ATLTRACE("\t\tm_WriteLoc: %d\tm_ReadLoc: %d\n", m_WriteLoc, m_ReadLoc);

			// Use memcpy if its the initial load as FAOLoad does not work 
			// before the device is started
			if (initialLoad)
			{
				memcpy(ptr1, (CBT *)src, points*sizeof(CBT));
			}
			else
			{
				ptFAOLoad.ActiveBuf  = 0;  // single buffer
				ptFAOLoad.DataBuffer = (CBT *)src;
				ptFAOLoad.start      = (ULONG)(ptr1 - GetPtr());
				ptFAOLoad.count      = points;
				LRESULT loadError = DRV_FAOLoad(m_driverHandle, (LPT_FAOLoad)&ptFAOLoad);				
			}
			
			m_WriteLoc+=points;
			if (m_WriteLoc>m_Size) m_WriteLoc=0;
		}
		// Transfer second part?
        if ((size2 > 0) && (points<size))
        {
			//DEBUG: ATLTRACE("\t\tm_WriteLoc: %d\tm_ReadLoc: %d\n", m_WriteLoc, m_ReadLoc);
            points = min(size2, size-points);
			//DEBUG: ATLTRACE("\tPart 2: Transferring %d points from loc %d\n", points, (ptr2-GetPtr()));
			if (initialLoad)
			{
				memcpy(ptr2, (CBT *)src + size1, points*sizeof(CBT));
				}
			else
			{
				ptFAOLoad.ActiveBuf  = 0;  // single buffer
				ptFAOLoad.DataBuffer = (CBT *)src + size1;
				ptFAOLoad.start      = (ULONG)(ptr2 - GetPtr());
				ptFAOLoad.count      = points;
				LRESULT loadError = DRV_FAOLoad(m_driverHandle, (LPT_FAOLoad)&ptFAOLoad);				
			}
            m_WriteLoc = points;
        }
		////DEBUG: ATLTRACE("Pointer info: writeLoc = %d; read_Loc = %d", m_WriteLoc, m_ReadLoc);
     return S_OK;   
    };
	bool IsWriteUnderrun(int loc) // returns true for an underrun
    {   
		if ((m_ReadLoc < m_WriteLoc))
		{
			if ((loc < m_ReadLoc) || (loc >= m_WriteLoc))
			{
				// Not reading from middel valid portion of circbuf
				return true;
			}
		}
		else if ((loc >= m_WriteLoc) && (loc < m_ReadLoc))
		{
			// Not reading from outer valid portions of the circbuf
			return true;
		}		
		
		return false;		
	};        
};

//This abstract class extends the CswClockedDevice class by a single pure virtual function PutSingleValue()
class ATL_NO_VTABLE CadvantechAoutputBase: public CswClockedDevice
{
public:
    typedef short RawDataType;
    enum BitsEnum {Bits=16}; // bits must fit in rawdatatype
    virtual HRESULT PutSingleValue(int index,RawDataType Value)=0;
};


/////////////////////////////////////////////////////////////////////////////
// CadvantechAout class declaration
//
// CadvantechAout is based on ImwDevice and ImwOutput via chains:..
//.. ImwDevice -> CmwDevice -> CswClockedDevice -> CadvantechAoutputBase ->..
//.. TADDevice -> CadvantechAout  and..
//.. ImwOutput -> TADDevice -> CadvantechAout
class ATL_NO_VTABLE CadvantechAout :
	public TDADevice<CadvantechAoutputBase>, //is based on ImwDevice
	public CComCoClass<CadvantechAout, &CLSID_advantechAout>
//	public IDispatchImpl<IadvantechOut, &IID_IadvantechOut, &LIBID_advantechLib>
{
    typedef TDADevice<CadvantechAoutputBase> TBaseObj;

public:

DECLARE_REGISTRY( CadvantechAdapt, _T("advantech.advantechAout.1"), _T("advantech.advantechAout"),
				  IDS_PROJNAME, THREADFLAGS_BOTH )

// This line is not needed if the program does not support aggregation
DECLARE_PROTECT_FINAL_CONSTRUCT()

// ATL macros internally implementing QueryInterface() for the mapped interfaces
BEGIN_COM_MAP(CadvantechAout)
//	COM_INTERFACE_ENTRY(IadvantechAout)
	COM_INTERFACE_ENTRY(ImwDevice)
	COM_INTERFACE_ENTRY(ImwOutput)
END_COM_MAP()

public:
	CadvantechAout();
	~CadvantechAout();
	STDMETHOD(Start)();
	STDMETHOD(Trigger)();
	STDMETHOD(Stop)();
	STDMETHODIMP ChildChange(DWORD typeofchange, NESTABLEPROP *pChan);
	STDMETHODIMP SetChannelProperty(long UserVal, tagNESTABLEPROP *pChan, VARIANT *NewValue);
	STDMETHODIMP SetProperty(long User, VARIANT *NewValue);
	HRESULT FindRange(float low, float high, RANGE_INFO *&pRange);
	HRESULT SetDaqHwInfo();
	HRESULT LoadINIInfo();
    HRESULT Open(IUnknown *Interface,long ID);
    HRESULT PutSingleValue(int chan,RawDataType value);
	void GetMaxOutputRange(double *lowRange, double *highRange);
	HRESULT LoadOutputRanges();

	Cadvantechadapt * GetParent() {return m_pParent;}
	void SetParent(Cadvantechadapt * parent) {m_pParent = parent;}

	TTimerCallback<CadvantechAout,HiResTimer> TimerObj;
    bool TimerRoutine() 
    {     
        return(SyncAndLoadData()==S_OK);
    }
	HRESULT SyncAndLoadData();
	HRESULT StopDeviceIfRunning();
	HRESULT LoadData();


private:
	// Methods
	double QuantiseValue(double rate);
	void RangeAndDefaultSR(bool UpdateVal);

	// Properties
    typedef TCircBuffer<unsigned short> CIRCBUFFER;
	CIRCBUFFER::CBT		m_defaultChannelValue;  // There is only one channel so we can use a single value!
	PolarityType		m_polarity;				// Variable to keep track of the current polarity
	bool				m_swOutputRange;		// 1 if software configurable, 0 if jumpered
	bool				m_aoBipolar;			// support for bipolar ranges
	Cadvantechadapt *	m_pParent;
	long				m_driverHandle;
	DEVFEATURES			m_devFeatures;			// Structure containing list of features eg. board ID, gainlist...
	WORD				m_deviceID;
	CHAR				m_deviceName[50]; 
	short				m_maxAOChl;				// The number of analog output channels 
	double				m_maxSampleRate;		// Maximum sampling rate for HW clocking
	double				m_minSampleRate;		// Minimum sample rate of HARDWARE CLOCK (not min settable in MATLAB object)
	int					m_numUniqueJumperedOutputRanges; // Number of unique output ranges
	bool				m_supportedRanges[3];

	PT_FAOIntStart		m_ptFAOIntStart;		// FAOIntScanStart table
	PT_FAODmaStart		m_ptFAODmaStart;		// FAODmaScanStart table
	PT_FAOCheck			m_ptFAOCheck;			// The structure containing task status info
	USHORT				m_gwActiveBuf;			// Returned in FAOCheck structure
	USHORT				m_gwOverrun;			// Returned in FAOCheck structure
    USHORT				m_gwStopped;			// Returned in FAOCheck structure   
	USHORT				m_gwHalfReady;			// Returned in FAOCheck structure
	ULONG				m_posted;				// Returned in FAOCheck structure
	ULONG				m_prevPosted;			// Previous count of points posted (from Adv)	
	bool				m_initialLoad;			// TRUE: We are loading data before the output starts, FALSE: We are loading data during output

	CadvAOBuffer        m_circBuff;
	__int64				m_pointsToAdvBuffer;	// Total points sent to Advantech buffers
	__int64				m_pointsToHardware;		// Total points sent to the hardware
	long				m_engBuffSizePoints;	// Size of engine buffer(s), as per CBI adaptor
	double				m_timerPeriod;			
	bool				m_lastBufferLoaded;		// True if we have posted the last Engine buffer to Advantech.
	short				m_putStatus;			// Status of a scan start.
	LONG				m_DMABuffer;
	
	typedef std::vector<RANGE_INFO> RangeList_t;
	RangeList_t			m_channelRanges;

	TRemoteProp<long>	pClockSource;
	CachedEnumProp		pTransferMode;
    CEnumProp           pOutOfDataMode;

};


#endif //__advantechOAOUT_H_
// advantechOut.cpp : Implementation of CadvantechAout
