/* $Revision: 1.1 $ */
/*********************************************************************/
/*                        R C S  information                         */
/*********************************************************************/
/*
 * $Log: mwsamp2ctl.cpp,v $
 * Revision 1.1  2001/09/04 18:23:09  fpeermoh
 * Initial revision
 *
 */

// Mwsamp2Ctl.cpp : Implementation of the CMwsamp2Ctrl ActiveX Control class.

#include "stdafx.h"
#include "mwsamp2.h"
#include "Mwsamp2Ctl.h"
#include "Mwsamp2Ppg.h"


#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif


IMPLEMENT_DYNCREATE(CMwsamp2Ctrl, COleControl)


/////////////////////////////////////////////////////////////////////////////
// Message map

BEGIN_MESSAGE_MAP(CMwsamp2Ctrl, COleControl)
	//{{AFX_MSG_MAP(CMwsamp2Ctrl)
	// NOTE - ClassWizard will add and remove message map entries
	//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG_MAP
	ON_OLEVERB(AFX_IDS_VERB_PROPERTIES, OnProperties)
END_MESSAGE_MAP()


/////////////////////////////////////////////////////////////////////////////
// Dispatch map

BEGIN_DISPATCH_MAP(CMwsamp2Ctrl, COleControl)
	//{{AFX_DISPATCH_MAP(CMwsamp2Ctrl)
	DISP_PROPERTY(CMwsamp2Ctrl, "Label", m_label, VT_BSTR)
	DISP_PROPERTY(CMwsamp2Ctrl, "Radius", m_radius, VT_I2)
	DISP_FUNCTION(CMwsamp2Ctrl, "Beep", Beep, VT_EMPTY, VTS_NONE)
	DISP_FUNCTION(CMwsamp2Ctrl, "FireClickEvent", FireClickEvent, VT_EMPTY, VTS_NONE)
	DISP_FUNCTION(CMwsamp2Ctrl, "GetBSTR", GetBSTR, VT_BSTR, VTS_NONE)
	DISP_FUNCTION(CMwsamp2Ctrl, "GetBSTRArray", GetBSTRArray, VT_VARIANT, VTS_NONE)
	DISP_FUNCTION(CMwsamp2Ctrl, "GetI4", GetI4, VT_I4, VTS_NONE)
	DISP_FUNCTION(CMwsamp2Ctrl, "GetI4Array", GetI4Array, VT_VARIANT, VTS_NONE)
	DISP_FUNCTION(CMwsamp2Ctrl, "GetI4Vector", GetI4Vector, VT_VARIANT, VTS_NONE)
	DISP_FUNCTION(CMwsamp2Ctrl, "GetIDispatch", GetIDispatch, VT_DISPATCH, VTS_NONE)
	DISP_FUNCTION(CMwsamp2Ctrl, "GetR8", GetR8, VT_R8, VTS_NONE)
	DISP_FUNCTION(CMwsamp2Ctrl, "GetR8Array", GetR8Array, VT_VARIANT, VTS_NONE)
	DISP_FUNCTION(CMwsamp2Ctrl, "GetR8Vector", GetR8Vector, VT_VARIANT, VTS_NONE)
	DISP_FUNCTION(CMwsamp2Ctrl, "GetVariantArray", GetVariantArray, VT_VARIANT, VTS_NONE)
	DISP_FUNCTION(CMwsamp2Ctrl, "GetVariantVector", GetVariantVector, VT_VARIANT, VTS_NONE)
	DISP_FUNCTION(CMwsamp2Ctrl, "Redraw", Redraw, VT_EMPTY, VTS_NONE)
	DISP_FUNCTION(CMwsamp2Ctrl, "SetBSTR", SetBSTR, VT_BSTR, VTS_BSTR)
	DISP_FUNCTION(CMwsamp2Ctrl, "SetBSTRArray", SetBSTRArray, VT_VARIANT, VTS_VARIANT)
	DISP_FUNCTION(CMwsamp2Ctrl, "SetI4", SetI4, VT_I4, VTS_I4)
	DISP_FUNCTION(CMwsamp2Ctrl, "SetI4Array", SetI4Array, VT_VARIANT, VTS_VARIANT)
	DISP_FUNCTION(CMwsamp2Ctrl, "SetI4Vector", SetI4Vector, VT_VARIANT, VTS_VARIANT)
	DISP_FUNCTION(CMwsamp2Ctrl, "SetR8", SetR8, VT_R8, VTS_R8)
	DISP_FUNCTION(CMwsamp2Ctrl, "SetR8Array", SetR8Array, VT_VARIANT, VTS_VARIANT)
	DISP_FUNCTION(CMwsamp2Ctrl, "SetR8Vector", SetR8Vector, VT_VARIANT, VTS_VARIANT)
	//}}AFX_DISPATCH_MAP
	DISP_FUNCTION_ID(CMwsamp2Ctrl, "AboutBox", DISPID_ABOUTBOX, AboutBox, VT_EMPTY, VTS_NONE)
END_DISPATCH_MAP()


/////////////////////////////////////////////////////////////////////////////
// Event map

BEGIN_EVENT_MAP(CMwsamp2Ctrl, COleControl)
	//{{AFX_EVENT_MAP(CMwsamp2Ctrl)
	EVENT_STOCK_CLICK()
	EVENT_STOCK_DBLCLICK()
	EVENT_STOCK_MOUSEDOWN()
	//}}AFX_EVENT_MAP
END_EVENT_MAP()


/////////////////////////////////////////////////////////////////////////////
// Property pages

// TODO: Add more property pages as needed.  Remember to increase the count!
BEGIN_PROPPAGEIDS(CMwsamp2Ctrl, 1)
	PROPPAGEID(CMwsamp2PropPage::guid)
END_PROPPAGEIDS(CMwsamp2Ctrl)


/////////////////////////////////////////////////////////////////////////////
// Initialize class factory and guid

IMPLEMENT_OLECREATE_EX(CMwsamp2Ctrl, "MWSAMP2.Mwsamp2Ctrl.1",
	0x5771a80a, 0x2294, 0x4cac, 0xa7, 0x5b, 0x15, 0x7d, 0xcd, 0xdd, 0x36, 0x53)


/////////////////////////////////////////////////////////////////////////////
// Type library ID and version

IMPLEMENT_OLETYPELIB(CMwsamp2Ctrl, _tlid, _wVerMajor, _wVerMinor)


/////////////////////////////////////////////////////////////////////////////
// Interface IDs

const IID BASED_CODE IID_DMwsamp2 =
		{ 0x13e74b28, 0x5deb, 0x464c, { 0xad, 0x59, 0x1d, 0x4c, 0xad, 0x15, 0x68, 0x69 } };
const IID BASED_CODE IID_DMwsamp2Events =
		{ 0x8c74663f, 0xccf6, 0x4292, { 0x8a, 0x7c, 0xdd, 0xc8, 0xa7, 0x54, 0xa8, 0x66 } };


/////////////////////////////////////////////////////////////////////////////
// Control type information

static const DWORD BASED_CODE _dwMwsamp2OleMisc =
	OLEMISC_ACTIVATEWHENVISIBLE |
	OLEMISC_SETCLIENTSITEFIRST |
	OLEMISC_INSIDEOUT |
	OLEMISC_CANTLINKINSIDE |
	OLEMISC_RECOMPOSEONRESIZE;

IMPLEMENT_OLECTLTYPE(CMwsamp2Ctrl, IDS_MWSAMP2, _dwMwsamp2OleMisc)


/////////////////////////////////////////////////////////////////////////////
// CMwsamp2Ctrl::CMwsamp2CtrlFactory::UpdateRegistry -
// Adds or removes system registry entries for CMwsamp2Ctrl

BOOL CMwsamp2Ctrl::CMwsamp2CtrlFactory::UpdateRegistry(BOOL bRegister)
{
	// TODO: Verify that your control follows apartment-model threading rules.
	// Refer to MFC TechNote 64 for more information.
	// If your control does not conform to the apartment-model rules, then
	// you must modify the code below, changing the 6th parameter from
	// afxRegApartmentThreading to 0.

	if (bRegister)
		return AfxOleRegisterControlClass(
			AfxGetInstanceHandle(),
			m_clsid,
			//m_lpszProgID,
			"MWSAMP.MwsampCtrl.2",
			IDS_MWSAMP2,
			IDB_MWSAMP2,
			afxRegApartmentThreading,
			_dwMwsamp2OleMisc,
			_tlid,
			_wVerMajor,
			_wVerMinor);
	else
		return AfxOleUnregisterClass(m_clsid, m_lpszProgID);
}


/////////////////////////////////////////////////////////////////////////////
// CMwsamp2Ctrl::CMwsamp2Ctrl - Constructor

CMwsamp2Ctrl::CMwsamp2Ctrl()
{
	InitializeIIDs(&IID_DMwsamp2, &IID_DMwsamp2Events);
	m_label = "Label";
	m_radius = 20;
	// TODO: Initialize your control's instance data here.
}


/////////////////////////////////////////////////////////////////////////////
// CMwsamp2Ctrl::~CMwsamp2Ctrl - Destructor

CMwsamp2Ctrl::~CMwsamp2Ctrl()
{
	// TODO: Cleanup your control's instance data here.
}


/////////////////////////////////////////////////////////////////////////////
// CMwsamp2Ctrl::OnDraw - Drawing function

void CMwsamp2Ctrl::OnDraw(
			CDC* pdc, const CRect& rcBounds, const CRect& rcInvalid)
{
	int	x1, y1, x2, y2;	
  
	x1 = rcBounds.left + ((rcBounds.right - rcBounds.left) / 2) - m_radius;
	y1 = rcBounds.top + ((rcBounds.bottom - rcBounds.top) / 2) - m_radius;
	x2 = rcBounds.left + ((rcBounds.right - rcBounds.left) / 2) + m_radius;
	y2 = rcBounds.top + ((rcBounds.bottom - rcBounds.top) / 2) + m_radius;
	pdc->FillRect(rcBounds, CBrush::FromHandle((HBRUSH)GetStockObject(WHITE_BRUSH)));
	pdc->Ellipse(x1, y1, x2, y2);
	pdc->TextOut (rcBounds.left, rcBounds.top, m_label );
}


/////////////////////////////////////////////////////////////////////////////
// CMwsamp2Ctrl::DoPropExchange - Persistence support

void CMwsamp2Ctrl::DoPropExchange(CPropExchange* pPX)
{
	ExchangeVersion(pPX, MAKELONG(_wVerMinor, _wVerMajor));
	COleControl::DoPropExchange(pPX);

	PX_String (pPX, "Label", m_label, "Label");
    PX_Short (pPX, "Radius", m_radius, 20);

}


/////////////////////////////////////////////////////////////////////////////
// CMwsamp2Ctrl::OnResetState - Reset control to default state

void CMwsamp2Ctrl::OnResetState()
{
	COleControl::OnResetState();  // Resets defaults found in DoPropExchange

	// TODO: Reset any other control state here.
}


/////////////////////////////////////////////////////////////////////////////
// CMwsamp2Ctrl::AboutBox - Display an "About" box to the user

void CMwsamp2Ctrl::AboutBox()
{
	CDialog dlgAbout(IDD_ABOUTBOX_MWSAMP2);
	dlgAbout.DoModal();
}


/////////////////////////////////////////////////////////////////////////////
// CMwsamp2Ctrl message handlers

void CMwsamp2Ctrl::Beep() 
{

	MessageBeep (0xFFFFFFFF);
}

/////////////////////////////////////////////////////////////////////////////
// Force a click event to be fired.
void CMwsamp2Ctrl::FireClickEvent() 
{
	COleControl::FireClick ();
}

BSTR CMwsamp2Ctrl::GetBSTR() 
{
	CString strResult("sample string");
	return strResult.AllocSysString();
}

VARIANT CMwsamp2Ctrl::GetBSTRArray() 
{
    VARIANT		vaResult;
    SAFEARRAYBOUND	sab[3];
    SAFEARRAY		*pSA;
    BSTR		*pData;

    VariantInit(&vaResult);
    
    sab[0].cElements    = 2;
    sab[0].lLbound      = 0;
    sab[1].cElements    = 2;
    sab[1].lLbound      = 0;
    sab[2].cElements    = 2;
    sab[2].lLbound      = 0;

    pSA = SafeArrayCreate (VT_BSTR, 3, sab);
    SafeArrayAccessData (pSA, (void **) &pData);

    for (int i = 0; i < 2; i++)
    {
	for (int j = 0; j < 2; j++)
	{
	    for (int k = 0; k < 2; k++)
	    {
		BSTR    *pV;
		long    subs[3];
		CString strResult;
		char	p[100];
	    
		subs[0] = i;
		subs[1] = j;
		subs[2] = k;
		SafeArrayPtrOfIndex (pSA, subs, (void **) &pV);

		sprintf (p, "%d %d %d", i + 1, j + 1, k + 1);
		strResult = p;
		*pV = strResult.AllocSysString();
	    }
	}
    }
    SafeArrayUnaccessData (pSA);
    V_VT (&vaResult) = VT_BSTR | VT_ARRAY;
    V_ARRAY (&vaResult) = pSA;
    return vaResult;
}

long CMwsamp2Ctrl::GetI4() 
{
   return 27;
}

VARIANT CMwsamp2Ctrl::GetI4Array() 
{
    VARIANT		vaResult;
    SAFEARRAYBOUND	sab[2];
    SAFEARRAY		*pSA;
    int		*pData;
    // MATLAB and VB use the same array organization, but C uses a different
    // one, so initialize the C data to look the way VB would do it (row major)
    // so we can just memcpy it in below....
    int		pSource[2][3] = {{1, 4, 2}, {5, 3, 6}};

    
    VariantInit(&vaResult);
    
    sab[0].cElements    = 2;
    sab[0].lLbound      = 0;
    sab[1].cElements    = 3;
    sab[1].lLbound      = 0;

    pSA = SafeArrayCreate (VT_I4, 2, sab);
    SafeArrayAccessData (pSA, (void **) &pData);

    memcpy (pData, pSource, sizeof (pSource));
    SafeArrayUnaccessData (pSA);
    V_VT (&vaResult) = VT_I4 | VT_ARRAY;
    V_ARRAY (&vaResult) = pSA;
    return vaResult;
}

VARIANT CMwsamp2Ctrl::GetI4Vector() 
{
	VARIANT		vaResult;
    SAFEARRAYBOUND	sab[1];
    SAFEARRAY		*pSA;
    int		*pData;
    // MATLAB and VB use the same array organization, but C uses a different
    // one, so initialize the C data to look the way VB would do it (row major)
    // so we can just memcpy it in below....
    int		pSource[3] = {1, 2, 3};

    
    VariantInit(&vaResult);
    
    sab[0].cElements    = 3;
    sab[0].lLbound      = 0;

    pSA = SafeArrayCreate (VT_I4, 1, sab);
    SafeArrayAccessData (pSA, (void **) &pData);

    memcpy (pData, pSource, sizeof (pSource));
    SafeArrayUnaccessData (pSA);
    V_VT (&vaResult) = VT_I4 | VT_ARRAY;
    V_ARRAY (&vaResult) = pSA;

    return vaResult;
}

LPDISPATCH CMwsamp2Ctrl::GetIDispatch() 
{
   return (COleControl::GetIDispatch (TRUE));
}

/////////////////////////////////////////////////////////////////////////////
// return a VT_R8
double CMwsamp2Ctrl::GetR8() 
{
   return 27.3;
}

/////////////////////////////////////////////////////////////////////////////
// return a VT_R8 array
VARIANT CMwsamp2Ctrl::GetR8Array() 
{
    VARIANT		vaResult;
    SAFEARRAYBOUND	sab[2];
    SAFEARRAY		*pSA;
    double		*pData;
    // MATLAB and VB use the same array organization, but C uses a different
    // one, so initialize the C data to look the way VB would do it (row major)
    // so we can just memcpy it in below....
    double		pSource[2][3] = {{1.0, 4.0, 2.0}, {5.0, 3.0, 6.0}};

    VariantInit(&vaResult);
    
    sab[0].cElements    = 2;
    sab[0].lLbound      = 0;
    sab[1].cElements    = 3;
    sab[1].lLbound      = 0;

    pSA = SafeArrayCreate (VT_R8, 2, sab);
    SafeArrayAccessData (pSA, (void **) &pData);

    memcpy (pData, pSource, sizeof (pSource));
    SafeArrayUnaccessData (pSA);
    V_VT (&vaResult) = VT_R8 | VT_ARRAY;
    V_ARRAY (&vaResult) = pSA;
    return vaResult;

}

/////////////////////////////////////////////////////////////////////////////
// return a vector of doubles
VARIANT CMwsamp2Ctrl::GetR8Vector() 
{
    VARIANT		vaResult;
    SAFEARRAYBOUND	sab[1];
    SAFEARRAY		*pSA;
    double		*pData;
    // MATLAB and VB use the same array organization, but C uses a different
    // one, so initialize the C data to look the way VB would do it (row major)
    // so we can just memcpy it in below....
    double		pSource[3] = {1.0, 2.0, 3.0};

    VariantInit(&vaResult);
    
    sab[0].cElements    = 3;
    sab[0].lLbound      = 0;

    pSA = SafeArrayCreate (VT_R8, 1, sab);
    SafeArrayAccessData (pSA, (void **) &pData);

    memcpy (pData, pSource, sizeof (pSource));
    SafeArrayUnaccessData (pSA);
    V_VT (&vaResult) = VT_R8 | VT_ARRAY;
    V_ARRAY (&vaResult) = pSA;
    return vaResult;
}

/////////////////////////////////////////////////////////////////////////////
// sample routine which returns a variant which contains an array of
// variants, each of which is a double or a string
VARIANT CMwsamp2Ctrl::GetVariantArray() 
{
   VARIANT		vaResult;
    SAFEARRAYBOUND	sab[2];
    SAFEARRAY		*pSA;
    double		*pData;
    double		pSource[2][3] = {{1.0, 2.0, 3.0}, {4.0, 5.0, 6.0}};

    VariantInit(&vaResult);
    
    sab[0].cElements    = 2;
    sab[0].lLbound      = 0;
    sab[1].cElements    = 3;
    sab[1].lLbound      = 0;

    pSA = SafeArrayCreate (VT_VARIANT, 2, sab);
    SafeArrayAccessData (pSA, (void **) &pData);

    for (int i = 0; i < 2; i++)
    {
	for (int j = 0; j < 3; j++)
	{
	    VARIANT *pV;
	    long    subs[2];
	    
	    subs[0] = i;
	    subs[1] = j;
	    SafeArrayPtrOfIndex (pSA, subs, (void **) &pV);
	    VariantInit (pV);
	  
	  // mix it up with some BSTR variants and some double variants
	    if (i!=j)
	    {
		V_VT (pV) = VT_R8;
		V_R8 (pV) = pSource[i][j];
	    }
	    else
	    {
		CString strResult;
		char	p[100];

		sprintf (p, "%f", pSource[i][j]);
		strResult = p;
		V_VT (pV) = VT_BSTR;
		V_BSTR (pV) = strResult.AllocSysString();
	    }
	}
    }
    SafeArrayUnaccessData (pSA);
    V_VT (&vaResult) = VT_VARIANT | VT_ARRAY;
    V_ARRAY (&vaResult) = pSA;
    return vaResult;
}

/////////////////////////////////////////////////////////////////////////////
// return a vector of variants
VARIANT CMwsamp2Ctrl::GetVariantVector() 
{
    VARIANT		vaResult;
    SAFEARRAYBOUND	sab[1];
    SAFEARRAY		*pSA;
    double		*pData;
    double		pSource[3] = {1.0, 2.0, 3.0};

    VariantInit(&vaResult);
    
    sab[0].cElements    = 3;
    sab[0].lLbound      = 0;

    pSA = SafeArrayCreate (VT_VARIANT, 1, sab);
    SafeArrayAccessData (pSA, (void **) &pData);

    for (int i = 0; i < 3; i++)
    {
        VARIANT *pV;
        long    subs[1];
	    
        subs[0] = i;
        SafeArrayPtrOfIndex (pSA, subs, (void **) &pV);
        VariantInit (pV);
	  
      // mix it up with some BSTR variants and some double variants
    	V_VT (pV) = VT_R8;
    	V_R8 (pV) = pSource[i];
    }

    SafeArrayUnaccessData (pSA);
    V_VT (&vaResult) = VT_VARIANT | VT_ARRAY;
    V_ARRAY (&vaResult) = pSA;
    return vaResult;
}

void CMwsamp2Ctrl::Redraw() 
{
    RedrawWindow();
}

BSTR CMwsamp2Ctrl::SetBSTR(LPCTSTR b) 
{
    CString strResult(b);
    return strResult.AllocSysString();
}

VARIANT CMwsamp2Ctrl::SetBSTRArray(const VARIANT FAR& v) 
{
    VARIANT vaResult;
    VariantInit(&vaResult);
    VariantCopy (&vaResult, (VARIANT *) &v);
    return vaResult;
}

long CMwsamp2Ctrl::SetI4(long l) 
{
	return l;
}

VARIANT CMwsamp2Ctrl::SetI4Array(const VARIANT FAR& v) 
{
    VARIANT vaResult;
    VariantInit(&vaResult);
    VariantCopy (&vaResult, (VARIANT *) &v);
    return vaResult;
}

VARIANT CMwsamp2Ctrl::SetI4Vector(const VARIANT FAR& v) 
{
    VARIANT vaResult;
    VariantInit(&vaResult);
    VariantCopy (&vaResult, (VARIANT *) &v);
    return vaResult;
}

double CMwsamp2Ctrl::SetR8(double d) 
{
	return d;
}

VARIANT CMwsamp2Ctrl::SetR8Array(const VARIANT FAR& v) 
{
    VARIANT vaResult;
    VariantInit(&vaResult);
    VariantCopy (&vaResult, (VARIANT *) &v);
    return vaResult;
}

VARIANT CMwsamp2Ctrl::SetR8Vector(const VARIANT FAR& v) 
{
    VARIANT vaResult;
    VariantInit(&vaResult);
    VariantCopy (&vaResult, (VARIANT *) &v);
    return vaResult;
}
