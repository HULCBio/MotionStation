// #$Demo$#Ain.h : Declaration of C#$Demo$#Ain class
// Copyright 2002-2003 The MathWorks, Inc.
// $Revision: 1.1.6.3 $  $Date: 2003/08/29 04:44:25 $


#ifndef __#$DEMO$#AIN_H_
#define __#$DEMO$#AIN_H_

#include "resource.h"       // main symbols
#include "#$Demo$#.h"

/////////////////////////////////////////////////////////////////////////////
// C#$Demo$#InputBase class declaration
// Base analoginput class providing support for software clocking 
// (in lieu of hardware clocking).
class ATL_NO_VTABLE C#$Demo$#InputBase: public CswClockedDevice
{
public:

// TODO: Define the native data type
// 	Need to define the native data type that your hardware acquisition 
//	function returns. Data that comes from the hardware will be of this type.
// 	RawDataType will be used to defined the adaptor's data buffer for 
//	data that will be returned to the DAQ Engine for processing.

    typedef short RawDataType;     // Defined here as short (16 bits)
    
// END TO_DO    

    enum BitsEnum {Bits=8*sizeof(RawDataType)}; // Bits in RawDataType
    virtual HRESULT GetSingleValue(int index,RawDataType *Value)=0;
};

/////////////////////////////////////////////////////////////////////////////
// C#$Demo$#Ain class declaration
//
// C#$Demo$#Ain is based on ImwDevice and ImwInput via chains: 
//  ImwDevice -> CmwDevice -> CswClockedDevice -> C#$Demo$#InputBase ->
//  TADDevice( aka TBaseObj) -> C#$Demo$#Ain  
//  	and 
//  ImwInput -> TADDevice -> C#$Demo$#Ain
/////////////////////////////////////////////////////////////////////////////
class ATL_NO_VTABLE C#$Demo$#Ain :
	public TADDevice<C#$Demo$#InputBase>, 
	public CComCoClass<C#$Demo$#Ain, &CLSID_#$Demo$#Ain> // ATL Class factory support
{
public:
	typedef TADDevice<C#$Demo$#InputBase> TBaseObj;

	DECLARE_REGISTRY_RESOURCEID(IDR_#$DEMO$#AIN)

	DECLARE_PROTECT_FINAL_CONSTRUCT()

	// ATL macros internally implementing QueryInterface() for the mapped interfaces
	BEGIN_COM_MAP(C#$Demo$#Ain)
		COM_INTERFACE_ENTRY(ImwDevice)
		COM_INTERFACE_ENTRY(ImwInput)
	END_COM_MAP()

public:
	C#$Demo$#Ain();
	
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
	// ImwInput methods
	/////////////////////////
	// STDMETHOD(GetSingleValues)(VARIANT* Values);	// Using base class
	STDMETHOD(PeekData)(BUFFER_ST* pBuffer);
	// STDMETHOD(Trigger)();	// Using base class

	/////////////////////////
	// Local methods
	/////////////////////////
	HRESULT Open(IUnknown *Interface,long ID);
	HRESULT GetSingleValue(int chan,RawDataType *value);
	HRESULT SetDaqHwInfo();
	
	// Define additional member functions here

   	// Add additional data members here
	typedef std::vector<RawDataType> 	BufferT; 	// Define a buffer vector (STL) data type
	BufferT 					Buffer;		// Define a buffer
	BufferT::iterator 			NextPoint;	// Define an iterator

    long 	_boardID;	// Board identifier
    	
private:

	// Define additional member functions here

   	// Add additional data members here
	CachedEnumProp 	 	pClockSource;
	TRemoteProp<long>	pSampleRate;
	CachedEnumProp		pInputType;
	#$AddCode$#
	#$AddDevSpecificCode#$

protected:
	
	// Define additional member functions here
	
	// Define additional data members here
	
};

#endif //__#$DEMO$#AIN_H_
