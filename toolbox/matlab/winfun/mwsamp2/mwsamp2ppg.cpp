/* $Revision: 1.1 $ */
/*********************************************************************/
/*                        R C S  information                         */
/*********************************************************************/
/*
 * $Log: mwsamp2ppg.cpp,v $
 * Revision 1.1  2001/09/04 18:23:12  fpeermoh
 * Initial revision
 *
 */

// Mwsamp2Ppg.cpp : Implementation of the CMwsamp2PropPage property page class.

#include "stdafx.h"
#include "mwsamp2.h"
#include "Mwsamp2Ppg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif


IMPLEMENT_DYNCREATE(CMwsamp2PropPage, COlePropertyPage)


/////////////////////////////////////////////////////////////////////////////
// Message map

BEGIN_MESSAGE_MAP(CMwsamp2PropPage, COlePropertyPage)
	//{{AFX_MSG_MAP(CMwsamp2PropPage)
	// NOTE - ClassWizard will add and remove message map entries
	//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()


/////////////////////////////////////////////////////////////////////////////
// Initialize class factory and guid

IMPLEMENT_OLECREATE_EX(CMwsamp2PropPage, "MWSAMP2.Mwsamp2PropPage.1",
	0xb563c08b, 0x5797, 0x4c50, 0x8b, 0x20, 0xc3, 0x61, 0xd0, 0xd0, 0xfc, 0x96)


/////////////////////////////////////////////////////////////////////////////
// CMwsamp2PropPage::CMwsamp2PropPageFactory::UpdateRegistry -
// Adds or removes system registry entries for CMwsamp2PropPage

BOOL CMwsamp2PropPage::CMwsamp2PropPageFactory::UpdateRegistry(BOOL bRegister)
{
	if (bRegister)
		return AfxOleRegisterPropertyPageClass(AfxGetInstanceHandle(),
			m_clsid, IDS_MWSAMP2_PPG);
	else
		return AfxOleUnregisterClass(m_clsid, NULL);
}


/////////////////////////////////////////////////////////////////////////////
// CMwsamp2PropPage::CMwsamp2PropPage - Constructor

CMwsamp2PropPage::CMwsamp2PropPage() :
	COlePropertyPage(IDD, IDS_MWSAMP2_PPG_CAPTION)
{
	//{{AFX_DATA_INIT(CMwsamp2PropPage)
	// NOTE: ClassWizard will add member initialization here
	//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_DATA_INIT
}


/////////////////////////////////////////////////////////////////////////////
// CMwsamp2PropPage::DoDataExchange - Moves data between page and properties

void CMwsamp2PropPage::DoDataExchange(CDataExchange* pDX)
{
	//{{AFX_DATA_MAP(CMwsamp2PropPage)
	// NOTE: ClassWizard will add DDP, DDX, and DDV calls here
	//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_DATA_MAP
	DDP_PostProcessing(pDX);
}


/////////////////////////////////////////////////////////////////////////////
// CMwsamp2PropPage message handlers
