/* $Revision: 1.1 $ */
/*********************************************************************/
/*                        R C S  information                         */
/*********************************************************************/
/*
 * $Log: mwsamp2.h,v $
 * Revision 1.1  2001/09/04 18:23:18  fpeermoh
 * Initial revision
 *
 */

#if !defined(AFX_MWSAMP2_H__D38B08C7_934C_4001_9D88_D767C2729732__INCLUDED_)
#define AFX_MWSAMP2_H__D38B08C7_934C_4001_9D88_D767C2729732__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

// mwsamp2.h : main header file for MWSAMP2.DLL

#if !defined( __AFXCTL_H__ )
	#error include 'afxctl.h' before including this file
#endif

#include "resource.h"       // main symbols

/////////////////////////////////////////////////////////////////////////////
// CMwsamp2App : See mwsamp2.cpp for implementation.

class CMwsamp2App : public COleControlModule
{
public:
	BOOL InitInstance();
	int ExitInstance();
};

extern const GUID CDECL _tlid;
extern const WORD _wVerMajor;
extern const WORD _wVerMinor;

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_MWSAMP2_H__D38B08C7_934C_4001_9D88_D767C2729732__INCLUDED)
