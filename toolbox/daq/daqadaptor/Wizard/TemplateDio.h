// #$Demo$#DIO.h : Declaration of the C#$Demo$#DIO
// Copyright 2002-2003 The MathWorks, Inc.
// $Revision: 1.1.6.3 $  $Date: 2003/08/29 04:44:29 $


#ifndef __#$DEMO$#DIO_H_
#define __#$DEMO$#DIO_H_

#include "resource.h"       // main symbols
#include "#$Demo$#.h"

typedef TDIODevice<CmwDevice> TBaseObj;

/////////////////////////////////////////////////////////////////////////////
// C#$Demo$#DIO class declaration
//
// C#$Demo$#DIO is based on ImwDevice and ImwDIO via chains: 
//  ImwDevice -> CmwDevice -> TDIODevice( aka TBaseObj) -> C#$Demo$#DIO 
//  	and 
//  ImwInput -> TDIODevice -> C#$Demo$#DIO
/////////////////////////////////////////////////////////////////////////////
class ATL_NO_VTABLE C#$Demo$#DIO : 
    public TDIODevice<CmwDevice>,
    public CComObjectRootEx<CComMultiThreadModel>,
    public CComCoClass<C#$Demo$#DIO, &CLSID_#$Demo$#DIO>
{

public:

   	typedef TDIODevice<CmwDevice> TBaseObj;

	DECLARE_REGISTRY_RESOURCEID(IDR_#$DEMO$#DIO)
	
	DECLARE_NOT_AGGREGATABLE(C#$Demo$#DIO)
	
	DECLARE_PROTECT_FINAL_CONSTRUCT()
	
	// ATL macros internally implementing QueryInterface() for the mapped interfaces
	BEGIN_COM_MAP(C#$Demo$#DIO)
    	COM_INTERFACE_ENTRY(ImwDevice)
    	COM_INTERFACE_ENTRY(ImwDIO)
	END_COM_MAP()
	

public:

    C#$Demo$#DIO();
    ~C#$Demo$#DIO();

	/////////////////////////
	// ImwDevice methods
	/////////////////////////
	// STDMETHOD(SetProperty)(long User, VARIANT * NewValue);
	// STDMETHOD(SetChannelProperty)(long UserVal, tagNESTABLEPROP * pChan, VARIANT * NewValue);
	// STDMETHOD(Start)();  // Using base class 
	// STDMETHOD(Stop)();	// Using base class
	STDMETHOD(ChildChange)(ULONG typeofchange,  tagNESTABLEPROP * pChan);
	// STDMETHOD(GetStatus)(__int64* samplesProcessed, int* running);	// Using base class
	// STDMETHOD(AllocBufferData(BUFFER_ST* Buffer);
	// STDMETHOD(FreeBufferData)(BUFFER_ST* Buffer);	

	/////////////////////////
	// ImwDIO methods
	/////////////////////////
    STDMETHOD(SetPortDirection)(long Port,unsigned long DirectionValues);
    STDMETHOD(WriteValues)(long NumberOfPorts,long __RPC_FAR *PortList,unsigned long __RPC_FAR *Data,unsigned long __RPC_FAR *Mask);
    STDMETHOD(ReadValues)(long NumberOfPorts,long __RPC_FAR *PortList,unsigned long __RPC_FAR *Data);

	/////////////////////////
	// Local methods
	/////////////////////////
    STDMETHOD(Open)(IUnknown *Interface, long ID);
    HRESULT SetDaqHwInfo();

	// Define additional member functions here

   	// Add additional data members here
   	long 	_boardID;

 
private:

	// Define additional member functions here

   	// Add additional data members here
	#$AddDevSpecificCode#$

protected:

	// Define additional member functions here

   	// Add additional data members here
    
};

#endif //__#$DEMO$#DIO_H_
