/* $Revision: 1.1 $ */
/*********************************************************************/
/*                        R C S  information                         */
/*********************************************************************/
/*
 * $Log: stdafx.h,v $
 * Revision 1.1  2001/09/04 18:23:29  fpeermoh
 * Initial revision
 *
 */

#if !defined(AFX_STDAFX_H__77EF7F1B_ACFC_48BF_8198_66F5A3035698__INCLUDED_)
#define AFX_STDAFX_H__77EF7F1B_ACFC_48BF_8198_66F5A3035698__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

// stdafx.h : include file for standard system include files,
//      or project specific include files that are used frequently,
//      but are changed infrequently

#define VC_EXTRALEAN		// Exclude rarely-used stuff from Windows headers

#include <afxctl.h>         // MFC support for ActiveX Controls
#include <afxext.h>         // MFC extensions
#include <afxdtctl.h>		// MFC support for Internet Explorer 4 Comon Controls
#ifndef _AFX_NO_AFXCMN_SUPPORT
#include <afxcmn.h>			// MFC support for Windows Common Controls
#endif // _AFX_NO_AFXCMN_SUPPORT

// Delete the two includes below if you do not wish to use the MFC
//  database classes

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_STDAFX_H__77EF7F1B_ACFC_48BF_8198_66F5A3035698__INCLUDED_)
