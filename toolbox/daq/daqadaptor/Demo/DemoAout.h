// demoOut.h : Declaration of CdemoOut class
// Copyright 1998-2003 The MathWorks, Inc.
// $Revision: 1.1.4.3 $  $Date: 2003/08/29 04:44:13 $


#ifndef __DEMOAOUT_H_
#define __DEMOAOUT_H_

#include "resource.h"       // main symbols


//This abstract class extends the CswClockedDevice class by a single ..
//..pure virtual function GetSingleValue()
class ATL_NO_VTABLE CDemoAoutputBase: public CswClockedDevice
{
public:
    typedef short RawDataType;
    enum BitsEnum {Bits=16}; // bits must fit in rawdatatype
    virtual HRESULT PutSingleValue(int index,RawDataType Value)=0;
};

/////////////////////////////////////////////////////////////////////////////
// CDemoAout class declaration
//
// CDemoAout is based on ImwDevice and ImwOutput via chains:..
//.. ImwDevice -> CmwDevice -> CswClockedDevice -> CDemoAoutputBase ->..
//.. TADDevice -> CDemoAout  and..
//.. ImwOutput -> TADDevice -> CDemoAout
class ATL_NO_VTABLE CDemoAout :
	public TDADevice<CDemoAoutputBase>, //is based on ImwDevice
	public CComCoClass<CDemoAout, &CLSID_DemoAout>
//	public IDispatchImpl<IDemoOut, &IID_IDemoOut, &LIBID_DEMOLib>
{
    typedef TDADevice<CDemoAoutputBase> TBaseObj;

public:

//TO_DO: In this macro enter (1)name of the adaptor class,..
//..(2)program ID, (3)version independent program ID, (4)index of the name..
//..bearing resource string -- from the resource.h file. Keep flags untouched.
DECLARE_REGISTRY( CDemoAdapt, _T("Demo.DemoAout.1"), _T("Demo.DemoAout"),
				  IDS_PROJNAME, THREADFLAGS_BOTH )
//END TO_DO

//this line is not needed if the program does not support aggregation
DECLARE_PROTECT_FINAL_CONSTRUCT()

//ATL macros internally implementing QueryInterface() for the mapped interfaces
BEGIN_COM_MAP(CDemoAout)
//	COM_INTERFACE_ENTRY(IDemoAout)
	COM_INTERFACE_ENTRY(ImwDevice)
	COM_INTERFACE_ENTRY(ImwOutput)
END_COM_MAP()

public:
	CDemoAout();
    HRESULT Open(IUnknown *Interface,long ID);
    HRESULT PutSingleValue(int chan,RawDataType value);

//DeviceId data member currently is not used in the demo program
    UINT DeviceId;

    typedef std::vector<RawDataType> BufferT;
    BufferT Buffer;
    BufferT::iterator NextPoint;
};


#endif //__DEMOOAOUT_H_
// DemoOut.cpp : Implementation of CDemoAout
