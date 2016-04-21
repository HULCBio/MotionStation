/* $Revision: 1.1 $ */
/*********************************************************************/
/*                        R C S  information                         */
/*********************************************************************/
/*
 * $Log: mwsamp2ctl.h,v $
 * Revision 1.1  2001/09/04 18:23:21  fpeermoh
 * Initial revision
 *
 */

#if !defined(AFX_MWSAMP2CTL_H__31AE77B1_CD9F_41B0_9ED9_0DD2E1B329F5__INCLUDED_)
#define AFX_MWSAMP2CTL_H__31AE77B1_CD9F_41B0_9ED9_0DD2E1B329F5__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000

// Mwsamp2Ctl.h : Declaration of the CMwsamp2Ctrl ActiveX Control class.

/////////////////////////////////////////////////////////////////////////////
// CMwsamp2Ctrl : See Mwsamp2Ctl.cpp for implementation.

class CMwsamp2Ctrl : public COleControl
{
	DECLARE_DYNCREATE(CMwsamp2Ctrl)

// Constructor
public:
	CMwsamp2Ctrl();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CMwsamp2Ctrl)
	public:
	virtual void OnDraw(CDC* pdc, const CRect& rcBounds, const CRect& rcInvalid);
	virtual void DoPropExchange(CPropExchange* pPX);
	virtual void OnResetState();
	//}}AFX_VIRTUAL

// Implementation
protected:
	~CMwsamp2Ctrl();

	DECLARE_OLECREATE_EX(CMwsamp2Ctrl)    // Class factory and guid
	DECLARE_OLETYPELIB(CMwsamp2Ctrl)      // GetTypeInfo
	DECLARE_PROPPAGEIDS(CMwsamp2Ctrl)     // Property page IDs
	DECLARE_OLECTLTYPE(CMwsamp2Ctrl)		// Type name and misc status

// Message maps
	//{{AFX_MSG(CMwsamp2Ctrl)
		// NOTE - ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()

// Dispatch maps
	//{{AFX_DISPATCH(CMwsamp2Ctrl)
	CString m_label;
	short m_radius;
	afx_msg void Beep();
	afx_msg void FireClickEvent();
	afx_msg BSTR GetBSTR();
	afx_msg VARIANT GetBSTRArray();
	afx_msg long GetI4();
	afx_msg VARIANT GetI4Array();
	afx_msg VARIANT GetI4Vector();
	afx_msg LPDISPATCH GetIDispatch();
	afx_msg double GetR8();
	afx_msg VARIANT GetR8Array();
	afx_msg VARIANT GetR8Vector();
	afx_msg VARIANT GetVariantArray();
	afx_msg VARIANT GetVariantVector();
	afx_msg void Redraw();
	afx_msg BSTR SetBSTR(LPCTSTR b);
	afx_msg VARIANT SetBSTRArray(const VARIANT FAR& v);
	afx_msg long SetI4(long l);
	afx_msg VARIANT SetI4Array(const VARIANT FAR& v);
	afx_msg VARIANT SetI4Vector(const VARIANT FAR& v);
	afx_msg double SetR8(double d);
	afx_msg VARIANT SetR8Array(const VARIANT FAR& v);
	afx_msg VARIANT SetR8Vector(const VARIANT FAR& v);
	//}}AFX_DISPATCH
	DECLARE_DISPATCH_MAP()

	afx_msg void AboutBox();

// Event maps
	//{{AFX_EVENT(CMwsamp2Ctrl)
	//}}AFX_EVENT
	DECLARE_EVENT_MAP()

// Dispatch and event IDs
public:
	enum {
	//{{AFX_DISP_ID(CMwsamp2Ctrl)
	dispidLabel = 1L,
	dispidRadius = 2L,
	dispidBeep = 3L,
	dispidFireClickEvent = 4L,
	dispidGetBSTR = 5L,
	dispidGetBSTRArray = 6L,
	dispidGetI4 = 7L,
	dispidGetI4Array = 8L,
	dispidGetI4Vector = 9L,
	dispidGetIDispatch = 10L,
	dispidGetR8 = 11L,
	dispidGetR8Array = 12L,
	dispidGetR8Vector = 13L,
	dispidGetVariantArray = 14L,
	dispidGetVariantVector = 15L,
	dispidRedraw = 16L,
	dispidSetBSTR = 17L,
	dispidSetBSTRArray = 18L,
	dispidSetI4 = 19L,
	dispidSetI4Array = 20L,
	dispidSetI4Vector = 21L,
	dispidSetR8 = 22L,
	dispidSetR8Array = 23L,
	dispidSetR8Vector = 24L,
	//}}AFX_DISP_ID
	};
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_MWSAMP2CTL_H__31AE77B1_CD9F_41B0_9ED9_0DD2E1B329F5__INCLUDED)
