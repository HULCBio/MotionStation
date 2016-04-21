// advantechadapt.h : Declaration of the Cadvantechadapt class
// Copyright 2002-2003 The MathWorks, Inc.
// Coded by OPTI-NUM solutions (Pty) Ltd.
// $Revision: 1.1.6.2 $  $Date: 2003/12/04 18:39:15 $

#ifndef __advantechADAPT_H_
#define __advantechADAPT_H_

#pragma warning(disable:4996) // no warnings: CComModule::UpdateRegistryClass was declared deprecated

#include "driver.h"
#include "resource.h"       // main symbols

// Used for Running Devices list.
typedef struct RUNNINGDEVICE
{
	DWORD deviceID;
	void* ptr;
} DEV;

/////////////////////////////////////////////////////////////////////////////
// Cadvantechadapt class -- implements ImwAdaptor
/////////////////////////////////////////////////////////////////////////////
class ATL_NO_VTABLE Cadvantechadapt : 
public CComObjectRootEx<CComMultiThreadModel>,
public CComCoClass<Cadvantechadapt, &CLSID_advantechadapt>,
public ImwAdaptor
{
public:
	DECLARE_NOT_AGGREGATABLE(Cadvantechadapt)
	DECLARE_PROTECT_FINAL_CONSTRUCT()
	DECLARE_CLASSFACTORY_SINGLETON(Cadvantechadapt)
	BEGIN_COM_MAP(Cadvantechadapt)
		COM_INTERFACE_ENTRY(ImwAdaptor)
	END_COM_MAP()
	
	BEGIN_CATEGORY_MAP(Cadvantechadapt)
		IMPLEMENTED_CATEGORY(CATID_ImwAdaptor)
	END_CATEGORY_MAP()
	
	DECLARE_REGISTRY( Cadvantechadapt, _T("advantech.advantechadapt.1"), _T("advantech.advantechadapt"),
	IDS_PROJNAME, THREADFLAGS_BOTH )
		
public:
	Cadvantechadapt();
	~Cadvantechadapt();
	STDMETHOD(AdaptorInfo)(IPropContainer * Container);
	STDMETHOD(OpenDevice)(REFIID riid, long nParams, VARIANT __RPC_FAR *Param,
		REFIID EngineIID, IUnknown __RPC_FAR *pIEngine,
		void __RPC_FAR *__RPC_FAR *ppIDevice);
	STDMETHOD(TranslateError)(HRESULT eCode, BSTR * retVal);
	
	static OLECHAR ConstructorName[100];
    HRESULT AddDev(DWORD id,void *dev);
    HRESULT DeleteDev(DWORD id);
	std::vector<DEV>::iterator GetIteratorFromID( DWORD id )
	{
		for(OPENDEVLIST::iterator dit = OpenDevs.begin(); dit != OpenDevs.end(); dit++)
		{
			if ((*dit).deviceID == id)
				return dit;
		}
		return NULL;
	}
	
private:
	LPWSTR StringToLower(LPCWSTR in,LPWSTR out) 
	{
		while(*in)
			*out++ = towlower(*in++);
		return out;
	} // end of StringToLower()
	
	// For the running devices:
	typedef std::vector<DEV> OPENDEVLIST;
    OPENDEVLIST OpenDevs;
	
};

#endif //__advantechADAPT_H_
