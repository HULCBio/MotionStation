// stdafx.h : include file for standard system include files,
//      or project specific include files that are used frequently,
//      but are changed infrequently
// $Revision: 1.1.6.2 $
// $Date: 2004/04/08 20:49:27 $
// Copyright 2002-2004 The MathWorks, Inc. 
// Coded by OPTI-NUM solutions

#if !defined(AFX_STDAFX_H__54449F46_5943_4397_ADD0_79A75EDEA074__INCLUDED_)
#define AFX_STDAFX_H__54449F46_5943_4397_ADD0_79A75EDEA074__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

#define STRICT
#ifndef _WIN32_WINNT
#define _WIN32_WINNT 0x0400
#endif
#define _ATL_APARTMENT_THREADED

#include <atlbase.h>
//You may derive a class from CComModule and use it if you want to override
//something, but do not change the name of _Module
extern CComModule _Module;
#include <atlcom.h>
#include "AdaptorKit.h"

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_STDAFX_H__54449F46_5943_4397_ADD0_79A75EDEA074__INCLUDED)
