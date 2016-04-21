// demoin.h : Declaration of CDemoAin class
// Copyright 1998-2003 The MathWorks, Inc.
// $Revision: 1.1.4.3 $  $Date: 2003/08/29 04:44:11 $


#ifndef __DEMOAIN_H_
#define __DEMOAIN_H_

#include "resource.h"       // main symbols


//This abstract class extends the CswClockedDevice class by a single ..
//..pure virtual function GetSingleValue()
class ATL_NO_VTABLE CDemoInputBase: public CswClockedDevice
{
public:
    typedef short RawDataType;
    enum BitsEnum {Bits=16}; // bits must fit in rawdatatype
    virtual HRESULT GetSingleValue(int index,RawDataType *Value)=0;
};

/////////////////////////////////////////////////////////////////////////////
// CDemoAin class declaration
//
// CDemoAin is based on ImwDevice and ImwInput via chains:..
//.. ImwDevice -> CmwDevice -> CswClockedDevice -> CDemoInputBase ->..
//.. TADDevice -> CDemoAin  and..
//.. ImwInput -> TADDevice -> CDemoAin
class ATL_NO_VTABLE CDemoAin :
	public TADDevice<CDemoInputBase>, //is based on ImwDevice
	public CComCoClass<CDemoAin, &CLSID_DemoAin>,
	public ISupportErrorInfo,
	public IDispatchImpl<IDemoAin, &IID_IDemoAin, &LIBID_DEMOLib>
{
    typedef TADDevice<CDemoInputBase> TBaseObj;

public:

//TO_DO: In this macro enter (1)name of the adaptor class,..
//..(2)program ID, (3)version independent program ID, (4)index of the name..
//..bearing resource string -- from the resource.h file. Keep flags untouched.
DECLARE_REGISTRY( CDemoAdapt, _T("Demo.DemoAin.1"), _T("Demo.DemoAin"),
				  IDS_PROJNAME, THREADFLAGS_BOTH )
//END TO_DO

//this line is not needed if the program does not support aggregation
DECLARE_PROTECT_FINAL_CONSTRUCT()

//ATL macros internally implementing QueryInterface() for the mapped interfaces
BEGIN_COM_MAP(CDemoAin)
	COM_INTERFACE_ENTRY(IDemoAin)
	COM_INTERFACE_ENTRY(ImwDevice)
	COM_INTERFACE_ENTRY(ImwInput)
	COM_INTERFACE_ENTRY(IDispatch)
	COM_INTERFACE_ENTRY(ISupportErrorInfo)
END_COM_MAP()

public:
	CDemoAin();
    HRESULT Open(IUnknown *Interface,long ID);
    STDMETHOD(InterfaceSupportsErrorInfo)(REFIID riid);
    HRESULT GetSingleValue(int chan,RawDataType *value);

//DeviceId data member currently is not used in the demo program
    UINT DeviceId;

    typedef std::vector<RawDataType> BufferT;
    BufferT Buffer;
    BufferT::iterator NextPoint;
};

#endif //__DEMOAIN_H_
