// ParallelDio.h : Declaration of the CParallelDio
//
// Copyright 1998-2003 The MathWorks, Inc.
// $Author: batserve $
// $Revision: 1.1.6.1 $  $Date: 2003/10/15 18:32:34 $

#ifndef __PARALLELDIO_H_
#define __PARALLELDIO_H_

#include "resource.h"       // main symbols
#include "AdaptorKit.h"
#include "ParallelDriver.h"

/////////////////////////////////////////////////////////////////////////////
// CParallelDio
class ATL_NO_VTABLE CParallelDio : 
    public TDIODevice<CmwDevice>,
    public CComObjectRootEx<CComMultiThreadModel>,
    public CComCoClass<CParallelDio, &CLSID_ParallelDio>
{
typedef TDIODevice<CmwDevice> TBaseObj;

public:
    
DECLARE_REGISTRY_RESOURCEID(IDR_PARALLELDIO)
	
DECLARE_NOT_AGGREGATABLE(CParallelDio)
	
DECLARE_PROTECT_FINAL_CONSTRUCT()
	
BEGIN_COM_MAP(CParallelDio)
    COM_INTERFACE_ENTRY(ImwDevice)
    COM_INTERFACE_ENTRY(ImwDIO)
END_COM_MAP()
	
	// IParallelDio
public:
    CParallelDio();
    ~CParallelDio();
    STDMETHOD(Open)(IUnknown *Interface, CComBSTR port, long PortAddress);
    STDMETHOD(SetPortDirection)(long Port,unsigned long DirectionValues);
    STDMETHOD(WriteValues)(long NumberOfPorts,long __RPC_FAR *PortList,unsigned long __RPC_FAR *Data,unsigned long __RPC_FAR *Mask);
    STDMETHOD(ReadValues)(long NumberOfPorts,long __RPC_FAR *PortList,unsigned long __RPC_FAR *Data);
    STDMETHOD(ChildChange)(ULONG typeofchange,  tagNESTABLEPROP * pChan);
    
private:
    CParallelDriver PPortDriver;
    long PortAddress;

    ShortProp BiDirectionalBitProp; // Bi-directional Bit Property Pointer
    CEnumProp PortAddressProp; //
    
};

#endif //__PARALLELDIO_H_
