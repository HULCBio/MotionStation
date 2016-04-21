// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.1.6.1 $  $Date: 2003/10/15 18:30:55 $


// Dio.h : Declaration of the CDio

#ifndef __DIO_H_
#define __DIO_H_

#include "resource.h"       // main symbols
//#import "D:\cbi\include\daqmex.tlb" raw_interfaces_only, raw_native_types, no_namespace, named_guids 
#include "daqmex.h"
#include "cbutil.h"

/////////////////////////////////////////////////////////////////////////////
// CDio
class ATL_NO_VTABLE CDio : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CDio, &CLSID_Dio>,
	public ISupportErrorInfo,
	public IDio,
	public TDIODevice<CbRoot>
{
public:
	CDio()
	{
	}

DECLARE_REGISTRY_RESOURCEID(IDR_DIO)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CDio)
	COM_INTERFACE_ENTRY(IDio)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY(ImwDevice)
	COM_INTERFACE_ENTRY(ImwDIO)
END_COM_MAP()
    HRESULT Open(IUnknown *Interface,long ID);

// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IDio
public:
// IDevice
        // ImwDIO
	STDMETHOD(ReadValues)(LONG NumberOfPorts, LONG * PortList, ULONG * Data);
	STDMETHOD(WriteValues)(LONG NumberOfPorts, LONG * PortList, ULONG * Data, ULONG * Mask);
	STDMETHOD(SetPortDirection)(LONG Port, ULONG DirectionValues);

        // Member variable declarations.
        HRESULT SetDaqHwInfo();
        bool _DirConfigurable;
        std::vector<int> PortNum;
        std::vector<int> Dir;

private:

	std::vector<int> vPortLineCount;

	// DIO Helper functions
	int getPortCount(void);
	int getPortLines(int port);
	int getDeviceConfigurability(int port, long *portConfig, long *lineConfig);
	int getPortType(int port);
	HRESULT Legacy_SetDaqHwInfo();
			
	};

#endif //__DIO_H_
