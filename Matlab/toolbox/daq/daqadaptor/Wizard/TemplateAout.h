// #$Demo$#Out.h : Declaration of C#$demo$#Out class
// Copyright 2002-2003 The MathWorks, Inc.
// $Revision: 1.1.6.3 $  $Date: 2003/08/29 04:44:27 $


#ifndef __#$DEMO$#AOUT_H_
#define __#$DEMO$#AOUT_H_

#include "resource.h"       // main symbols
#include "#$Demo$#.h"

//////////////////////////////////////////////////////////////////////////////
//This abstract class extends the CswClockedDevice class by a single ..
//..pure virtual function GetSingleValue(). Base analog output class
//provides support for software clocking (in lieu of hardware clocking)
class ATL_NO_VTABLE C#$Demo$#AoutputBase: public CswClockedDevice
{
public:
// TODO:
// 	Need to define the native data type that your hardware acquisition 
//	function returns. Data that comes from the hardware will be of this type.
// 	RawDataType will be used to defined the adaptor's data buffer for 
//	data that will be returned to the DAQ Engine for processing.

    typedef short RawDataType;     // Defined here as short (16 bits)
    
// END TO_DO    

    enum BitsEnum {Bits=16}; // bits must fit in rawdatatype
    virtual HRESULT PutSingleValue(int index,RawDataType Value)=0;
};

/////////////////////////////////////////////////////////////////////////////
// C#$Demo$#Aout class declaration
//
// C#$Demo$#Aout is based on ImwDevice and ImwOutput via chains:..
//.. ImwDevice -> CmwDevice -> CswClockedDevice -> C#$Demo$#AoutputBase ->..
//.. TADDevice -> C#$Demo$#Aout  and..
//.. ImwOutput -> TADDevice -> C#$Demo$#Aout
/////////////////////////////////////////////////////////////////////////////
class ATL_NO_VTABLE C#$Demo$#Aout :
	public TDADevice<C#$Demo$#AoutputBase>, //is based on ImwDevice
	public CComCoClass<C#$Demo$#Aout, &CLSID_#$Demo$#Aout>
{

public:

	typedef TDADevice<C#$Demo$#AoutputBase> TBaseObj;

	DECLARE_REGISTRY_RESOURCEID(IDR_#$DEMO$#AOUT)
	
	DECLARE_PROTECT_FINAL_CONSTRUCT()

	//ATL macros internally implementing QueryInterface() for the mapped interfaces
	BEGIN_COM_MAP(C#$Demo$#Aout)
		COM_INTERFACE_ENTRY(ImwDevice)
		COM_INTERFACE_ENTRY(ImwOutput)
	END_COM_MAP()

public:
	C#$Demo$#Aout();

	/////////////////////////
	// ImwDevice methods
	/////////////////////////
    STDMETHOD(SetProperty)(long User, VARIANT * NewValue);
	STDMETHOD(SetChannelProperty)(long UserVal, tagNESTABLEPROP * pChan, VARIANT * NewValue);
	// STDMETHOD(Start)();  // Using base class 
	// STDMETHOD(Stop)();	// Using base class
	STDMETHOD(ChildChange)(DWORD typeofchange, NESTABLEPROP *pChan);
	// STDMETHOD(GetStatus)(__int64* samplesProcessed, int* running);	// Using base class
	// STDMETHOD(AllocBufferData(BUFFER_ST* Buffer);
	// STDMETHOD(FreeBufferData)(BUFFER_ST* Buffer);	

	/////////////////////////
	// ImwOutput methods
	/////////////////////////
	// STDMETHOD(PutSingleValues)(VARIANT* Values);	// Using base class
	// STDMETHOD(Trigger)();	// Using base class

	/////////////////////////
	// Local methods
	/////////////////////////
    HRESULT Open(IUnknown *Interface,long ID);
    HRESULT PutSingleValue(int chan,RawDataType value);
    HRESULT SetDaqHwInfo();

	// Define additional member functions here

   	// Add additional data members here
    typedef std::vector<RawDataType> BufferT;
    BufferT Buffer;
    BufferT::iterator NextPoint;

   	long 	_boardID;

private:

	// Define additional member functions here

   	// Add additional data members here
	CachedEnumProp 	 	pClockSource;
	TRemoteProp<long>	pSampleRate;
	CachedEnumProp		pOutputType;
	#$AddCode$#
	#$AddDevSpecificCode#$

protected:

	// Define additional member functions here

   	// Add additional data members here
	
};


#endif //__#$DEMO$#AOUT_H_
