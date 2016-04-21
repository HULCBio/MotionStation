// stdafx.h : include file for standard system include files,
//      or project specific include files that are used frequently,
//      but are changed infrequently

// $Revision: 1.1.6.1 $
// $Date: 2003/10/15 18:31:27 $

// Copyright 2002-2003 The MathWorks, Inc. 
// Coded by OPTI-NUM solutions


#if !defined(AFX_STDAFX_H__EA453B48_90DA_4E30_8FFB_3F8EA7AA81F7__INCLUDED_)
#define AFX_STDAFX_H__EA453B48_90DA_4E30_8FFB_3F8EA7AA81F7__INCLUDED_

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

#include "drvlinx.h"
#include "dlcodes.h"
#include "oemcodes.h"
#include "ONSDrvLINX.h"

/*
#ifdef _DEBUG
#include "tracehelp.h"

inline void * __cdecl operator new(unsigned int size, const char *file, int line)
{
	void *ptr = (void *)malloc(size);
	AddTrack((DWORD)ptr, size, file, line);
	return (ptr);
};

inline void __cdecl operator delete(void *p)
{
	RemoveTrack((DWORD)p);
	free(p);
};

#define DEBUG_NEW new(__FILE__, __LINE__)
#else
#define DEBUG_NEW new
#endif
#define new DEBUG_NEW
*/

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_STDAFX_H__EA453B48_90DA_4E30_8FFB_3F8EA7AA81F7__INCLUDED)
