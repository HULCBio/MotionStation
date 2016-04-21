/* $Revision: 1.1 $ */
/*********************************************************************/
/*                        R C S  information                         */
/*********************************************************************/
/*
 * $Log: mwsamp2ppg.h,v $
 * Revision 1.1  2001/09/04 18:23:24  fpeermoh
 * Initial revision
 *
 */

#if !defined(AFX_MWSAMP2PPG_H__E4C31407_CDC9_4040_B565_15CEA564F997__INCLUDED_)
#define AFX_MWSAMP2PPG_H__E4C31407_CDC9_4040_B565_15CEA564F997__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

// Mwsamp2Ppg.h : Declaration of the CMwsamp2PropPage property page class.

////////////////////////////////////////////////////////////////////////////
// CMwsamp2PropPage : See Mwsamp2Ppg.cpp.cpp for implementation.

class CMwsamp2PropPage : public COlePropertyPage
{
	DECLARE_DYNCREATE(CMwsamp2PropPage)
	DECLARE_OLECREATE_EX(CMwsamp2PropPage)

// Constructor
public:
	CMwsamp2PropPage();

// Dialog Data
	//{{AFX_DATA(CMwsamp2PropPage)
	enum { IDD = IDD_PROPPAGE_MWSAMP2 };
		// NOTE - ClassWizard will add data members here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_DATA

// Implementation
protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support

// Message maps
protected:
	//{{AFX_MSG(CMwsamp2PropPage)
		// NOTE - ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()

};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_MWSAMP2PPG_H__E4C31407_CDC9_4040_B565_15CEA564F997__INCLUDED)
