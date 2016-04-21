// Copyright 1998-2003 The MathWorks, Inc. 
// $Revision: 1.1.6.1 $  $Date: 2003/10/15 18:32:08 $


// stdafx.h : include file for standard system include files,
//      or project specific include files that are used frequently,
//      but are changed infrequently

#if !defined(AFX_STDAFX_H__4DE0B7C4_2292_11D3_A2F1_00A024E7DC56__INCLUDED_)
#define AFX_STDAFX_H__4DE0B7C4_2292_11D3_A2F1_00A024E7DC56__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#define STRICT
#ifndef _WIN32_WINNT
#define _WIN32_WINNT 0x0400
#endif
//#define _ATL_APARTMENT_THREADED
#define ATL_TRACE_CATEGORY (~atlTraceRegistrar)
#include <atlbase.h>
//You may derive a class from CComModule and use it if you want to override
//something, but do not change the name of _Module
extern CComModule _Module;
#include <atlcom.h>

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_STDAFX_H__4DE0B7C4_2292_11D3_A2F1_00A024E7DC56__INCLUDED)
