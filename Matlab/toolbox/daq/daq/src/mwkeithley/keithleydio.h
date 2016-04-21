// keithleydio.h - Declaration of the Keithley DigitalIO device
// $Revision: 1.1.6.1 $
// $Date: 2003/10/15 18:31:38 $

// Copyright 2002-2003 The MathWorks, Inc. 
// Coded by OPTI-NUM solutions

#ifndef __KEITHLEYDIO_H_
#define __KEITHLEYDIO_H_

#include "resource.h"       // main symbols
#include "daqmex.h"
#include "mwkeithley.h"

class Ckeithleyadapt;
/////////////////////////////////////////////////////////////////////////////
// Ckeithleydio
class ATL_NO_VTABLE Ckeithleydio : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<Ckeithleydio, &CLSID_keithleydio>,
	public ISupportErrorInfo,
	public TDIODevice<CmwDevice>,
	public IKeithleyDIO
{
public:
	

DECLARE_REGISTRY( Ckeithleyadapt, _T("Keithley.keithleydio.1"), _T("Keithley.keithleydio"),
				  IDS_PROJNAME, THREADFLAGS_BOTH )

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(Ckeithleydio)
	COM_INTERFACE_ENTRY(IKeithleyDIO)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
	COM_INTERFACE_ENTRY(ImwDevice)
	COM_INTERFACE_ENTRY(ImwDIO)
END_COM_MAP()


// ISupportsErrorInfo
	STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);

// IKeithleyDIO
public:
	bool IsChanClockOrTrig( int InOrOut, int chan);
	MessageWindow * GetParent(); // Function to return a pointer to the parent class of this class
	void SetParent(MessageWindow * pParent); // Function to set the parent class of this class
    HRESULT SetDaqHwInfo(); // Function to set the daqhwinfo for the device
	HRESULT Open(IUnknown *Interface,long ID); // This Function Opens the device
	Ckeithleydio(); // Constructor
	~Ckeithleydio(); // Destructor


     // ImwDIO methods
	STDMETHOD(ReadValues)(LONG NumberOfPorts, LONG * PortList, ULONG * Data);
	STDMETHOD(WriteValues)(LONG NumberOfPorts, LONG * PortList, ULONG * Data, ULONG * Mask);
	STDMETHOD(SetPortDirection)(LONG Port, ULONG DirectionValues);


   
private:
	HINSTANCE m_driverHandle;

	DL_ServiceRequest* m_pSR;	// Local service request.

	bool			 _DirConfigurable; // Is the direction configureable?
	std::vector<int> m_portNum2Channel; // The number of ports

	LPCSTR			 m_driverName; // The driver name
	WORD			 m_deviceID; // The device ID
	HANDLE			 m_ldd; // Handle to the LDD
	MessageWindow *  m_pParent; // Pointer to the class's parent class
	bool			 m_isInitializedDI; // Is DigitalInput device initialized?
	bool			 m_isInitializedDO; // Is DigitalOutput device initialized?

long PortLineWidth( DWORD chanMask ); // Function to calculate the width of a port, given the port mask
	
};

#endif //__KEITHLEYDIO_H_
