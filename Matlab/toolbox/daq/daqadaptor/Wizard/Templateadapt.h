// #$Demo$#Adapt.h : Declaration of the C#$Demo$#Adapt class
// Copyright 2002-2003 The MathWorks, Inc.
// $Revision: 1.1.6.3 $  $Date: 2003/08/29 04:44:32 $


#ifndef __#$DEMO$#ADAPT_H_
#define __#$DEMO$#ADAPT_H_

#include "resource.h"       // main symbols
#include "#$Demo$#.h"

/////////////////////////////////////////////////////////////////////////////
// C#$Demo$#Adapt class -- implements ImwAdaptor
//
// The C#$Demo$#Adapt class abstracts the general hardware driver. Through 
// this class, all supported hardware is queried and identified for future
// use. Once a particlur piece of hardware is specified, this class is used to 
// create a subsystem object.

class ATL_NO_VTABLE C#$Demo$#Adapt :
    public CComObjectRootEx<CComMultiThreadModel>,
    public CComCoClass<C#$Demo$#Adapt, &CLSID_#$Demo$#Adapt>,
    public ImwAdaptor
{
public:

DECLARE_NOT_AGGREGATABLE(C#$Demo$#Adapt)

DECLARE_PROTECT_FINAL_CONSTRUCT()
DECLARE_CLASSFACTORY_SINGLETON(C#$Demo$#Adapt)

BEGIN_COM_MAP(C#$Demo$#Adapt)
	COM_INTERFACE_ENTRY(ImwAdaptor)
END_COM_MAP()

BEGIN_CATEGORY_MAP(C#$Demo$#Adapt)
	IMPLEMENTED_CATEGORY(CATID_ImwAdaptor)
END_CATEGORY_MAP()

DECLARE_REGISTRY_RESOURCEID(IDR_#$DEMO$#ADAPTOR)
		
public:
	C#$Demo$#Adapt();
	~C#$Demo$#Adapt();
	STDMETHOD(AdaptorInfo)(IPropContainer * Container);
    STDMETHOD(OpenDevice)(REFIID riid, long nParams, VARIANT __RPC_FAR *Param,
		REFIID EngineIID, IUnknown __RPC_FAR *pIEngine,
		void __RPC_FAR *__RPC_FAR *ppIDevice);
    STDMETHOD(TranslateError)(HRESULT eCode, BSTR * retVal);
	
    static OLECHAR ConstructorName[100];
	
private:

	// Convert string to lowercase representation
	LPWSTR StringToLower(LPCWSTR in,LPWSTR out)
	{
		while(*in)
			*out++ = towlower(*in++);
		return out;
	} // end of StringToLower()
	
};

#endif //__#$Demo$#ADAPT_H_
