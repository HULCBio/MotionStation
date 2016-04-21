// ParallelAdapt.h : Declaration of the CParallelAdapt
//
// Copyright 1998-2003 The MathWorks, Inc.
// $Author: batserve $
// $Revision: 1.1.6.1 $  $Date: 2003/10/15 18:32:31 $

#ifndef __PARALLELADAPT_H_
#define __PARALLELADAPT_H_

#include "resource.h"       // main symbols
#include "adaptorkit.h"
#include "ParallelDriver.h"

//#define ERR_XLATE(x) (-(x+1000))

/////////////////////////////////////////////////////////////////////////////
// CParallelAdapt
class ATL_NO_VTABLE CParallelAdapt : 
	public CComObjectRootEx<CComMultiThreadModel>,
	public CComCoClass<CParallelAdapt, &CLSID_ParallelAdapt>,
	public ImwAdaptor
{
public:

DECLARE_REGISTRY_RESOURCEID(IDR_PARALLELADAPT)

DECLARE_NOT_AGGREGATABLE(CParallelAdapt)

DECLARE_CLASSFACTORY_SINGLETON(CParallelAdapt)

DECLARE_PROTECT_FINAL_CONSTRUCT()

BEGIN_COM_MAP(CParallelAdapt)
	COM_INTERFACE_ENTRY(ImwAdaptor)
END_COM_MAP()

BEGIN_CATEGORY_MAP(CParallelAdapt)
    IMPLEMENTED_CATEGORY(CATID_ImwAdaptor)
END_CATEGORY_MAP()

public:
	CParallelAdapt();
	~CParallelAdapt();
// ImwAdaptor
	STDMETHOD(AdaptorInfo)(IPropContainer * Container);
	STDMETHOD(OpenDevice)(REFIID riid, long nParams, VARIANT __RPC_FAR *Param,
	    REFIID EngineIID, IUnknown __RPC_FAR *pIEngine,
	    void __RPC_FAR *__RPC_FAR *ppIDevice);
	STDMETHOD(TranslateError)(HRESULT eCode, BSTR * retVal);

// Data
	static OLECHAR ConstructorName[100];
	static CComVariant DeviceName;

	CParallelDriver ParallelPort; // ParallelPort Driver


private:
	CComBSTR BoardIDs;
	long PortAddrs[3];	
	

private:
    LPWSTR StringToLower(LPCWSTR in,LPWSTR out) 
    {
	while(*in)
	    *out++ = towlower(*in++);
	return out;
    } // end of StringToLower()
    
};

#endif //__PARALLELADAPT_H_
