// DemoAdapt.h : Declaration of the CDemoAdapt class
// Copyright 1998-2003 The MathWorks, Inc.
// $Revision: 1.3.4.3 $  $Date: 2003/08/29 04:44:17 $


#ifndef __DEMOADAPT_H_
#define __DEMOADAPT_H_

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CDemoAdapt class -- implements ImwAdaptor
//
class ATL_NO_VTABLE CDemoAdapt :
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CDemoAdapt, &CLSID_DemoAdapt>,
	public ImwAdaptor
{
public:
DECLARE_NOT_AGGREGATABLE(CDemoAdapt)

DECLARE_PROTECT_FINAL_CONSTRUCT()
DECLARE_CLASSFACTORY_SINGLETON(CDemoAdapt)
BEGIN_COM_MAP(CDemoAdapt)
	COM_INTERFACE_ENTRY(ImwAdaptor)
END_COM_MAP()

BEGIN_CATEGORY_MAP(CDemoAdapt)
    IMPLEMENTED_CATEGORY(CATID_ImwAdaptor)
END_CATEGORY_MAP()

//TO_DO: In this macro enter (1)name of the adaptor class,..
//..(2)program ID, (3)version independent program ID, (4)index of the name..
//..bearing resource string -- from the resource.h file. Keep flags untouched.
DECLARE_REGISTRY( CDemoAdapt, _T("Demo.DemoAdapt.1"), _T("Demo.DemoAdapt"),
				  IDS_PROJNAME, THREADFLAGS_BOTH )
//END TO_DO

public:
	CDemoAdapt();
	~CDemoAdapt();
	STDMETHOD(AdaptorInfo)(IPropContainer * Container);
    STDMETHOD(OpenDevice)(REFIID riid, long nParams, VARIANT __RPC_FAR *Param,
              REFIID EngineIID, IUnknown __RPC_FAR *pIEngine,
              void __RPC_FAR *__RPC_FAR *ppIDevice);
    STDMETHOD(TranslateError)(HRESULT eCode, BSTR * retVal);

    static OLECHAR ConstructorName[100];

private:
LPWSTR StringToLower(LPCWSTR in,LPWSTR out)
{
    while(*in)
		*out++ = towlower(*in++);
    return out;
} // end of StringToLower()

};

#endif //__DEMOADAPT_H_
