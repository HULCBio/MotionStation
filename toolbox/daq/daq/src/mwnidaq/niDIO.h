// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.3.4.5 $  $Date: 2003/12/04 18:40:04 $


// niDIO.h: Definition of the CniDIO class
//
//////////////////////////////////////////////////////////////////////

#if !defined(AFX_NIDIO_H__A408E4AC_C5B2_11D2_B241_00A0C9F223E0__INCLUDED_)
#define AFX_NIDIO_H__A408E4AC_C5B2_11D2_B241_00A0C9F223E0__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#pragma warning(disable:4996) // no warnings: CComModule::UpdateRegistryClass was declared deprecated

#include "resource.h"       // main symbols
#include <daqmex.h>
#include "daqtypes.h"
#include <AdaptorKit.h>
#include "nidisp.h"
#include "niutil.h"
/////////////////////////////////////////////////////////////////////////////
// CniDIO

class ATL_NO_VTABLE CniDIO : 
public CniDisp,
public CComCoClass<CniDIO,&CLSID_niDIO>,
public TDIODevice<CmwDevice>
//public NiDevice<ImwDevice>,
//public ImwDIO
{
public:
    CniDIO() {};
    BEGIN_COM_MAP(CniDIO)
        COM_INTERFACE_ENTRY(ImwDevice)
        COM_INTERFACE_ENTRY(ImwDIO)
        COM_INTERFACE_ENTRY_CHAIN(CniDisp)
        END_COM_MAP()
        //DECLARE_NOT_AGGREGATABLE(CniDIO) 
        // Remove the comment from the line above if you don't want your object to 
        // support aggregation. 
        DECLARE_REGISTRY( CniDIO, "mwnidaq.digitalIO.1", "mwnidaq.digitalIO", IDS_NIDIO_DESC, THREADFLAGS_BOTH )

        //DECLARE_REGISTRY_RESOURCEID(IDR_niDIO)
        
        // IniDIO
public:
    HRESULT SetNIDAQError(short status,const IID& iid = IID_ImwDIO)
    { return status!=0 ? Error(status,iid) : S_OK;};
    HRESULT Open(IDaqEngine * Interface,int _ID,DevCaps* DeviceCaps);

    int Initialize();
    HRESULT SetDaqHwInfo();
    // IDevice
    // IDevice
    // ImwDIO
    STDMETHOD(ReadValues)(LONG NumberOfPorts, LONG * PortList, ULONG * Data);
    STDMETHOD(WriteValues)(LONG NumberOfPorts, LONG * PortList, ULONG * Data, ULONG * Mask);
    STDMETHOD(SetPortDirection)(LONG Port, ULONG  DirectionValues);
};

#endif // !defined(AFX_NIDIO_H__A408E4AC_C5B2_11D2_B241_00A0C9F223E0__INCLUDED_)
