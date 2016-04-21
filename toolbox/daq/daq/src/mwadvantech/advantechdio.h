// advantechdio.h - Declaration of the advantech DigitalIO device
// $Revision: 1.1.6.2 $
// $Date: 2004/04/08 20:49:29 $
// Copyright 2002-2004 The MathWorks, Inc. 
// Coded by OPTI-NUM solutions

#ifndef __advantechDIO_H_
#define __advantechDIO_H_

#include "resource.h"       // main symbols
#include "daqmex.h"
#include "mwadvantech.h"
#include "advantechpropdef.h"
#include "advantechUtil.h"
#include "driver.h"
#include <vector>

class Cadvantechadapt;
/////////////////////////////////////////////////////////////////////////////
// Cadvantechdio
class ATL_NO_VTABLE CadvantechDio : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CadvantechDio, &CLSID_advantechDio>,
	public ISupportErrorInfo,
	public TDIODevice<CmwDevice>,
	public IadvantechDio
{
public:

DECLARE_REGISTRY( Cadvantechadapt, _T("advantech.advantechDio.1"), _T("advantech.advantechDio"),
				  IDS_PROJNAME, THREADFLAGS_BOTH )

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CadvantechDio)
	COM_INTERFACE_ENTRY(IadvantechDio)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY(ImwDevice)
	COM_INTERFACE_ENTRY(ImwDIO)
END_COM_MAP()


// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IadvantechDIO
public:
	CadvantechDio(); // Constructor
	~CadvantechDio(); // Destructor
	HRESULT LoadINIInfo();
    HRESULT SetDaqHwInfo(); // Function to set the daqhwinfo for the device
	HRESULT Open(IUnknown *Interface,long ID); // This Function Opens the device

     // ImwDIO methods
	STDMETHOD(ReadValues)(LONG NumberOfPorts, LONG * PortList, ULONG * Data);
	STDMETHOD(WriteValues)(LONG NumberOfPorts, LONG * PortList, ULONG * Data, ULONG * Mask);
	STDMETHOD(SetPortDirection)(LONG Port, ULONG DirectionValues);
   
private:
	int			m_numInPorts;
	WORD		m_deviceID;	
	long		m_driverHandle;
	CHAR		m_deviceName[50]; 
	DEVFEATURES	m_devFeatures;	// Structure containing list of features eg. board ID, gainlist...
	int			m_configLines;	// Number of configurable lines
	int			m_inputLines;	// Number of non-configurable input lines
	int			m_outputLines;	// Number of non-configurable output lines
	int			m_ports;	// Total number of DIO ports
};

#endif //__advantechDIO_H_
