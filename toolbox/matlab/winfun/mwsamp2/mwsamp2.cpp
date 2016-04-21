/* $Revision: 1.1 $ */
/*********************************************************************/
/*                        R C S  information                         */
/*********************************************************************/
/*
 * $Log: mwsamp2.cpp,v $
 * Revision 1.1  2001/09/04 18:23:04  fpeermoh
 * Initial revision
 *
 */

// mwsamp2.cpp : Implementation of CMwsamp2App and DLL registration.

#include "stdafx.h"
#include "mwsamp2.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif


CMwsamp2App NEAR theApp;

const GUID CDECL BASED_CODE _tlid =
		{ 0x4d02e050, 0x24d8, 0x4d35, { 0xa1, 0xc6, 0xfb, 0x93, 0x4, 0x56, 0x81, 0x35 } };
const WORD _wVerMajor = 1;
const WORD _wVerMinor = 0;


////////////////////////////////////////////////////////////////////////////
// CMwsamp2App::InitInstance - DLL initialization

BOOL CMwsamp2App::InitInstance()
{
	BOOL bInit = COleControlModule::InitInstance();

	if (bInit)
	{
		// TODO: Add your own module initialization code here.
	}

	return bInit;
}


////////////////////////////////////////////////////////////////////////////
// CMwsamp2App::ExitInstance - DLL termination

int CMwsamp2App::ExitInstance()
{
	// TODO: Add your own module termination code here.

	return COleControlModule::ExitInstance();
}


/////////////////////////////////////////////////////////////////////////////
// DllRegisterServer - Adds entries to the system registry

STDAPI DllRegisterServer(void)
{
	AFX_MANAGE_STATE(_afxModuleAddrThis);

	if (!AfxOleRegisterTypeLib(AfxGetInstanceHandle(), _tlid))
		return ResultFromScode(SELFREG_E_TYPELIB);

	if (!COleObjectFactoryEx::UpdateRegistryAll(TRUE))
		return ResultFromScode(SELFREG_E_CLASS);

	return NOERROR;
}


/////////////////////////////////////////////////////////////////////////////
// DllUnregisterServer - Removes entries from the system registry

STDAPI DllUnregisterServer(void)
{
	AFX_MANAGE_STATE(_afxModuleAddrThis);

	if (!AfxOleUnregisterTypeLib(_tlid, _wVerMajor, _wVerMinor))
		return ResultFromScode(SELFREG_E_TYPELIB);

	if (!COleObjectFactoryEx::UpdateRegistryAll(FALSE))
		return ResultFromScode(SELFREG_E_CLASS);

	return NOERROR;
}
