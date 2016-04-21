// keithleyadapt.h : Declaration of the Main Adaptor class
// $Revision: 1.1.6.2 $
// $Date: 2003/12/04 18:39:36 $

// Copyright 2002-2003 The MathWorks, Inc. 
// Coded by OPTI-NUM solutions

#ifndef __KEITHLEYADAPT_H_
#define __KEITHLEYADAPT_H_

#pragma warning(disable:4996) // no warnings: CComModule::UpdateRegistryClass was declared deprecated

#include "resource.h"       // main symbols
#include "keithleypropdef.h"
#include "messagew.h"

/////////////////////////////////////////////////////////////////////////////
// Ckeithleyadapt class -- implements ImwAdaptor
//
/////////////////////////////////////////////////////////////////////////////
class ATL_NO_VTABLE Ckeithleyadapt : 
public CComObjectRootEx<CComMultiThreadModel>,
public CComCoClass<Ckeithleyadapt, &CLSID_keithleyadapt>,
public ImwAdaptor
{
public:
	DECLARE_NOT_AGGREGATABLE(Ckeithleyadapt)
		
	DECLARE_PROTECT_FINAL_CONSTRUCT()
	// Do not use this in the adaptor implementation. See Adaptor Kit User's Guide
	// DECLARE_CLASSFACTORY_SINGLETON(Ckeithleyadapt)
	BEGIN_COM_MAP(Ckeithleyadapt)
		COM_INTERFACE_ENTRY(ImwAdaptor)
	END_COM_MAP()
		
	BEGIN_CATEGORY_MAP(Ckeithleyadapt)
		IMPLEMENTED_CATEGORY(CATID_ImwAdaptor)
	END_CATEGORY_MAP()
		
	DECLARE_REGISTRY( Ckeithleyadapt, _T("Keithley.keithleyadapt.1"), _T("Keithley.keithleyadapt"),
		IDS_PROJNAME, THREADFLAGS_BOTH)
public:
	Ckeithleyadapt();
	~Ckeithleyadapt();
	STDMETHOD(AdaptorInfo)(IPropContainer * Container);
	STDMETHOD(OpenDevice)(REFIID riid, long nParams, VARIANT __RPC_FAR *Param,
		REFIID EngineIID, IUnknown __RPC_FAR *pIEngine,
		void __RPC_FAR *__RPC_FAR *ppIDevice);
	STDMETHOD(TranslateError)(HRESULT eCode, BSTR * retVal);
	static OLECHAR ConstructorName[100];
	MessageWindow *m_KeithleyWnd;
	
private:
	LPWSTR StringToLower(LPCWSTR in,LPWSTR out) 
	{
		while(*in)
			*out++ = towlower(*in++);
		return out;
	} // end of StringToLower()
	
};

double GetPrivateProfileDouble(LPCTSTR lpAppName,LPCTSTR lpKeyName,double Default, LPCTSTR lpFileName);

#endif //__KEITHLEYADAPT_H_
