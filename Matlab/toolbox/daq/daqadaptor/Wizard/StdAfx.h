// stdafx.h : include file for standard system include files,
//      or project specific include files that are used frequently,
//      but are changed infrequently

// Copyright 2002-2003 The MathWorks, Inc. 
// $Revision: 1.1.6.3 $  $Date: 2003/08/29 04:44:20 $


#if !defined(AFX_STDAFX_H__CE93231D_3BD9_11D4_A584_00902757EA8D__INCLUDED_)
#define AFX_STDAFX_H__CE93231D_3BD9_11D4_A584_00902757EA8D__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#define STRICT
#ifndef _WIN32_WINNT
#define _WIN32_WINNT 0x0400
#endif
//#define _ATL_APARTMENT_THREADED
#define _ATL_FREE_THREADED

#include <atlbase.h>
//You may derive a class from CComModule and use it if you want to override
//something, but do not change the name of _Module
extern CComModule _Module;
#include <atlcom.h>
#include <comdef.h>

#include "Adaptorkit.h"

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_STDAFX_H__CE93231D_3BD9_11D4_A584_00902757EA8D__INCLUDED)
