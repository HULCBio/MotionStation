#ifndef _LCC_OLECTL_H_
#define _LCC_OLECTL_H_
#ifndef __MKTYPLIB__
#ifndef RC_INVOKED
#pragma pack(push,8)
#endif 
#include <olectlid.h>
typedef TEXTMETRICW TEXTMETRICOLE;
typedef TEXTMETRIC TEXTMETRICOLE;
typedef TEXTMETRICOLE * LPTEXTMETRICOLE;
#ifndef interface
#define interface struct
#endif
#ifndef _VARIANT_BOOL_DEFINED
#define _VARIANT_BOOL_DEFINED
typedef short _VARIANT_BOOL;
typedef short VARIANT_BOOL;
#endif
typedef interface IOleControl IOleControl;
typedef interface IOleControlSite IOleControlSite;
typedef interface ISimpleFrameSite ISimpleFrameSite;
typedef interface IErrorLog IErrorLog;
typedef interface IPropertyBag IPropertyBag;
typedef interface IPersistPropertyBag IPersistPropertyBag;
typedef interface IPersistStreamInit IPersistStreamInit;
typedef interface IPersistMemory IPersistMemory;
typedef interface IPropertyNotifySink IPropertyNotifySink;
typedef interface IProvideClassInfo IProvideClassInfo;
typedef interface IProvideClassInfo2 IProvideClassInfo2;
typedef interface IConnectionPointContainer IConnectionPointContainer;
typedef interface IEnumConnectionPoints IEnumConnectionPoints;
typedef interface IConnectionPoint IConnectionPoint;
typedef interface IEnumConnections IEnumConnections;
typedef interface IClassFactory2 IClassFactory2;
typedef interface ISpecifyPropertyPages ISpecifyPropertyPages;
typedef interface IPerPropertyBrowsing IPerPropertyBrowsing;
typedef interface IPropertyPageSite IPropertyPageSite;
typedef interface IPropertyPage IPropertyPage;
typedef interface IPropertyPage2 IPropertyPage2;
typedef interface IFont IFont;
typedef interface IFontDisp IFontDisp;
typedef interface IPicture IPicture;
typedef interface IPictureDisp IPictureDisp;
typedef IOleControl * LPOLECONTROL;
typedef IOleControlSite * LPOLECONTROLSITE;
typedef ISimpleFrameSite * LPSIMPLEFRAMESITE;
typedef IErrorLog * LPERRORLOG;
typedef IPropertyBag * LPPROPERTYBAG;
typedef IPersistPropertyBag * LPPERSISTPROPERTYBAG;
typedef IPersistStreamInit * LPPERSISTSTREAMINIT;
typedef IPersistMemory * LPPERSISTMEMORY;
typedef interface IPropertyNotifySink * LPPROPERTYNOTIFYSINK;
typedef IProvideClassInfo * LPPROVIDECLASSINFO;
typedef IProvideClassInfo2 * LPPROVIDECLASSINFO2;
typedef IConnectionPointContainer * LPCONNECTIONPOINTCONTAINER;
typedef IEnumConnectionPoints * LPENUMCONNECTIONPOINTS;
typedef IConnectionPoint * LPCONNECTIONPOINT;
typedef IEnumConnections * LPENUMCONNECTIONS;
typedef IClassFactory2 * LPCLASSFACTORY2;
typedef ISpecifyPropertyPages * LPSPECIFYPROPERTYPAGES;
typedef IPerPropertyBrowsing * LPPERPROPERTYBROWSING;
typedef IPropertyPageSite * LPPROPERTYPAGESITE;
typedef IPropertyPage * LPPROPERTYPAGE;
typedef IPropertyPage2 * LPPROPERTYPAGE2;
typedef IFont * LPFONT;
typedef IFontDisp * LPFONTDISP;
typedef IPicture * LPPICTURE;
typedef IPictureDisp * LPPICTUREDISP;
typedef struct tagPOINTF * LPPOINTF;
typedef struct tagCONTROLINFO * LPCONTROLINFO;
typedef struct tagCONNECTDATA * LPCONNECTDATA;
typedef struct tagLICINFO * LPLICINFO;
typedef struct tagCAUUID * LPCAUUID;
typedef struct tagCALPOLESTR * LPCALPOLESTR;
typedef struct tagCADWORD * LPCADWORD;
typedef struct tagOCPFIPARAMS * LPOCPFIPARAMS;
typedef struct tagPROPPAGEINFO * LPPROPPAGEINFO;
typedef struct tagFONTDESC * LPFONTDESC;
typedef struct tagPICTDESC * LPPICTDESC;
typedef DWORD OLE_COLOR;
typedef long OLE_XPOS_PIXELS;
typedef long OLE_YPOS_PIXELS;
typedef long OLE_XSIZE_PIXELS;
typedef long OLE_YSIZE_PIXELS;
typedef long OLE_XPOS_HIMETRIC;
typedef long OLE_YPOS_HIMETRIC;
typedef long OLE_XSIZE_HIMETRIC;
typedef long OLE_YSIZE_HIMETRIC;
typedef float OLE_XPOS_CONTAINER;
typedef float OLE_YPOS_CONTAINER;
typedef float OLE_XSIZE_CONTAINER;
typedef float OLE_YSIZE_CONTAINER;
typedef enum { triUnchecked = 0, triChecked = 1, triGray = 2 } OLE_TRISTATE;
typedef VARIANT_BOOL OLE_OPTEXCLUSIVE;
typedef VARIANT_BOOL OLE_CANCELBOOL;
typedef VARIANT_BOOL OLE_ENABLEDEFAULTBOOL;
typedef UINT OLE_HANDLE;
#ifndef FACILITY_CONTROL
#define FACILITY_CONTROL 0xa
#endif
#define STD_CTL_SCODE(n) MAKE_SCODE(SEVERITY_ERROR, FACILITY_CONTROL, n)
#define CTL_E_ILLEGALFUNCTIONCALL STD_CTL_SCODE(5)
#define CTL_E_OVERFLOW STD_CTL_SCODE(6)
#define CTL_E_OUTOFMEMORY STD_CTL_SCODE(7)
#define CTL_E_DIVISIONBYZERO STD_CTL_SCODE(11)
#define CTL_E_OUTOFSTRINGSPACE STD_CTL_SCODE(14)
#define CTL_E_OUTOFSTACKSPACE STD_CTL_SCODE(28)
#define CTL_E_BADFILENAMEORNUMBER STD_CTL_SCODE(52)
#define CTL_E_FILENOTFOUND STD_CTL_SCODE(53)
#define CTL_E_BADFILEMODE STD_CTL_SCODE(54)
#define CTL_E_FILEALREADYOPEN STD_CTL_SCODE(55)
#define CTL_E_DEVICEIOERROR STD_CTL_SCODE(57)
#define CTL_E_FILEALREADYEXISTS STD_CTL_SCODE(58)
#define CTL_E_BADRECORDLENGTH STD_CTL_SCODE(59)
#define CTL_E_DISKFULL STD_CTL_SCODE(61)
#define CTL_E_BADRECORDNUMBER STD_CTL_SCODE(63)
#define CTL_E_BADFILENAME STD_CTL_SCODE(64)
#define CTL_E_TOOMANYFILES STD_CTL_SCODE(67)
#define CTL_E_DEVICEUNAVAILABLE STD_CTL_SCODE(68)
#define CTL_E_PERMISSIONDENIED STD_CTL_SCODE(70)
#define CTL_E_DISKNOTREADY STD_CTL_SCODE(71)
#define CTL_E_PATHFILEACCESSERROR STD_CTL_SCODE(75)
#define CTL_E_PATHNOTFOUND STD_CTL_SCODE(76)
#define CTL_E_INVALIDPATTERNSTRING STD_CTL_SCODE(93)
#define CTL_E_INVALIDUSEOFNULL STD_CTL_SCODE(94)
#define CTL_E_INVALIDFILEFORMAT STD_CTL_SCODE(321)
#define CTL_E_INVALIDPROPERTYVALUE STD_CTL_SCODE(380)
#define CTL_E_INVALIDPROPERTYARRAYINDEX STD_CTL_SCODE(381)
#define CTL_E_SETNOTSUPPORTEDATRUNTIME STD_CTL_SCODE(382)
#define CTL_E_SETNOTSUPPORTED STD_CTL_SCODE(383)
#define CTL_E_NEEDPROPERTYARRAYINDEX STD_CTL_SCODE(385)
#define CTL_E_SETNOTPERMITTED STD_CTL_SCODE(387)
#define CTL_E_GETNOTSUPPORTEDATRUNTIME STD_CTL_SCODE(393)
#define CTL_E_GETNOTSUPPORTED STD_CTL_SCODE(394)
#define CTL_E_PROPERTYNOTFOUND STD_CTL_SCODE(422)
#define CTL_E_INVALIDCLIPBOARDFORMAT STD_CTL_SCODE(460)
#define CTL_E_INVALIDPICTURE STD_CTL_SCODE(481)
#define CTL_E_PRINTERERROR STD_CTL_SCODE(482)
#define CTL_E_CANTSAVEFILETOTEMP STD_CTL_SCODE(735)
#define CTL_E_SEARCHTEXTNOTFOUND STD_CTL_SCODE(744)
#define CTL_E_REPLACEMENTSTOOLONG STD_CTL_SCODE(746)
#define CUSTOM_CTL_SCODE(n) MAKE_SCODE(SEVERITY_ERROR, FACILITY_CONTROL, n)
#define CTL_E_CUSTOM_FIRST CUSTOM_CTL_SCODE(600)
#define CLASS_E_NOTLICENSED (CLASSFACTORY_E_FIRST+2)
#define CONNECT_E_FIRST MAKE_SCODE(SEVERITY_ERROR, FACILITY_ITF, 0x0200)
#define CONNECT_E_LAST MAKE_SCODE(SEVERITY_ERROR, FACILITY_ITF, 0x020F)
#define CONNECT_S_FIRST MAKE_SCODE(SEVERITY_SUCCESS, FACILITY_ITF, 0x0200)
#define CONNECT_S_LAST MAKE_SCODE(SEVERITY_SUCCESS, FACILITY_ITF, 0x020F)
#define CONNECT_E_NOCONNECTION (CONNECT_E_FIRST+0)
#define CONNECT_E_ADVISELIMIT (CONNECT_E_FIRST+1)
#define CONNECT_E_CANNOTCONNECT (CONNECT_E_FIRST+2)
#define CONNECT_E_OVERRIDDEN (CONNECT_E_FIRST+3)
#define SELFREG_E_FIRST MAKE_SCODE(SEVERITY_ERROR, FACILITY_ITF, 0x0200)
#define SELFREG_E_LAST MAKE_SCODE(SEVERITY_ERROR, FACILITY_ITF, 0x020F)
#define SELFREG_S_FIRST MAKE_SCODE(SEVERITY_SUCCESS, FACILITY_ITF, 0x0200)
#define SELFREG_S_LAST MAKE_SCODE(SEVERITY_SUCCESS, FACILITY_ITF, 0x020F)
#define SELFREG_E_TYPELIB (SELFREG_E_FIRST+0)
#define SELFREG_E_CLASS (SELFREG_E_FIRST+1)
#define PERPROP_E_FIRST MAKE_SCODE(SEVERITY_ERROR, FACILITY_ITF, 0x0200)
#define PERPROP_E_LAST MAKE_SCODE(SEVERITY_ERROR, FACILITY_ITF, 0x020F)
#define PERPROP_S_FIRST MAKE_SCODE(SEVERITY_SUCCESS, FACILITY_ITF, 0x0200)
#define PERPROP_S_LAST MAKE_SCODE(SEVERITY_SUCCESS, FACILITY_ITF, 0x020F)
#define PERPROP_E_NOPAGEAVAILABLE (PERPROP_E_FIRST+0)
#define OLEMISC_INVISIBLEATRUNTIME 0x00000400L
#define OLEMISC_ALWAYSRUN 0x00000800L
#define OLEMISC_ACTSLIKEBUTTON 0x00001000L
#define OLEMISC_ACTSLIKELABEL 0x00002000L
#define OLEMISC_NOUIACTIVATE 0x00004000L
#define OLEMISC_ALIGNABLE 0x00008000L
#define OLEMISC_SIMPLEFRAME 0x00010000L
#define OLEMISC_SETCLIENTSITEFIRST 0x00020000L
#define OLEMISC_IMEMODE				0x00040000L
#ifndef OLEIVERB_PROPERTIES
#define OLEIVERB_PROPERTIES (-7L)
#endif
#define VT_STREAMED_PROPSET 73 
#define VT_STORED_PROPSET 74 
#define VT_BLOB_PROPSET 75 
#define VT_VERBOSE_ENUM		76	
#define VT_COLOR VT_I4
#define VT_XPOS_PIXELS VT_I4
#define VT_YPOS_PIXELS VT_I4
#define VT_XSIZE_PIXELS VT_I4
#define VT_YSIZE_PIXELS VT_I4
#define VT_XPOS_HIMETRIC VT_I4
#define VT_YPOS_HIMETRIC VT_I4
#define VT_XSIZE_HIMETRIC VT_I4
#define VT_YSIZE_HIMETRIC VT_I4
#define VT_TRISTATE VT_I2
#define VT_OPTEXCLUSIVE VT_BOOL
#define VT_FONT VT_DISPATCH
#define VT_PICTURE VT_DISPATCH
#define VT_HANDLE VT_I4
#define OCM__BASE (WM_USER+0x1c00)
#define OCM_COMMAND (OCM__BASE + WM_COMMAND)
#define OCM_CTLCOLORBTN (OCM__BASE + WM_CTLCOLORBTN)
#define OCM_CTLCOLOREDIT (OCM__BASE + WM_CTLCOLOREDIT)
#define OCM_CTLCOLORDLG (OCM__BASE + WM_CTLCOLORDLG)
#define OCM_CTLCOLORLISTBOX (OCM__BASE + WM_CTLCOLORLISTBOX)
#define OCM_CTLCOLORMSGBOX (OCM__BASE + WM_CTLCOLORMSGBOX)
#define OCM_CTLCOLORSCROLLBAR (OCM__BASE + WM_CTLCOLORSCROLLBAR)
#define OCM_CTLCOLORSTATIC (OCM__BASE + WM_CTLCOLORSTATIC)
#define OCM_DRAWITEM (OCM__BASE + WM_DRAWITEM)
#define OCM_MEASUREITEM (OCM__BASE + WM_MEASUREITEM)
#define OCM_DELETEITEM (OCM__BASE + WM_DELETEITEM)
#define OCM_VKEYTOITEM (OCM__BASE + WM_VKEYTOITEM)
#define OCM_CHARTOITEM (OCM__BASE + WM_CHARTOITEM)
#define OCM_COMPAREITEM (OCM__BASE + WM_COMPAREITEM)
#define OCM_HSCROLL (OCM__BASE + WM_HSCROLL)
#define OCM_VSCROLL (OCM__BASE + WM_VSCROLL)
#define OCM_PARENTNOTIFY (OCM__BASE + WM_PARENTNOTIFY)
#define OCM_NOTIFY			(OCM__BASE + WM_NOTIFY)
#include <unknwn.h>
STDAPI DllRegisterServer(void);
STDAPI DllUnregisterServer(void);
STDAPI OleCreatePropertyFrame(HWND hwndOwner, UINT x, UINT y,
	LPCOLESTR lpszCaption, ULONG cObjects, LPUNKNOWN * ppUnk, ULONG cPages,
	LPCLSID pPageClsID, LCID lcid, DWORD dwReserved, LPVOID pvReserved);
STDAPI OleCreatePropertyFrameIndirect(LPOCPFIPARAMS lpParams);
STDAPI OleTranslateColor(OLE_COLOR clr, HPALETTE hpal, COLORREF* lpcolorref);
STDAPI OleCreateFontIndirect(LPFONTDESC lpFontDesc, REFIID riid,
	LPVOID * lplpvObj);
STDAPI OleCreatePictureIndirect(LPPICTDESC lpPictDesc, REFIID riid, BOOL fOwn,
	LPVOID * lplpvObj);
STDAPI OleLoadPicture(LPSTREAM lpstream, LONG lSize, BOOL fRunmode,
	REFIID riid, LPVOID * lplpvObj);
STDAPI_(HCURSOR) OleIconToCursor(HINSTANCE hinstExe, HICON hIcon);
typedef struct tagPOINTF {
	float x;
	float y;
} POINTF;
typedef struct tagCONTROLINFO {
	ULONG cb; 
	HACCEL hAccel; 
	USHORT cAccel; 
	DWORD dwFlags; 
} CONTROLINFO;
#define CTRLINFO_EATS_RETURN 1 
#define CTRLINFO_EATS_ESCAPE 2 
#undef INTERFACE
#define INTERFACE IOleControl
DECLARE_INTERFACE_(IOleControl, IUnknown) {
	STDMETHOD(QueryInterface)(THIS_ REFIID riid, LPVOID * ppvObj) ;
	STDMETHOD_(ULONG,AddRef)(THIS) ;
	STDMETHOD_(ULONG,Release)(THIS) ;
	STDMETHOD(GetControlInfo)(THIS_ LPCONTROLINFO pCI) ;
	STDMETHOD(OnMnemonic)(THIS_ LPMSG pMsg) ;
	STDMETHOD(OnAmbientPropertyChange)(THIS_ DISPID dispid) ;
	STDMETHOD(FreezeEvents)(THIS_ BOOL bFreeze) ;
};
#undef INTERFACE
#define INTERFACE IOleControlSite
DECLARE_INTERFACE_(IOleControlSite, IUnknown) {
	STDMETHOD(QueryInterface)(THIS_ REFIID riid, LPVOID * ppvObj) ;
	STDMETHOD_(ULONG,AddRef)(THIS) ;
	STDMETHOD_(ULONG,Release)(THIS) ;
	STDMETHOD(OnControlInfoChanged)(THIS) ;
	STDMETHOD(LockInPlaceActive)(THIS_ BOOL fLock);
	STDMETHOD(GetExtendedControl)(THIS_ LPDISPATCH * ppDisp) ;
	STDMETHOD(TransformCoords)(THIS_ POINTL * lpptlHimetric,
		POINTF * lpptfContainer, DWORD flags) ;
	STDMETHOD(TranslateAccelerator)(THIS_ LPMSG lpMsg, DWORD grfModifiers);
	STDMETHOD(OnFocus)(THIS_ BOOL fGotFocus);
	STDMETHOD(ShowPropertyFrame)(THIS);
};
#define XFORMCOORDS_POSITION 0x1
#define XFORMCOORDS_SIZE 0x2
#define XFORMCOORDS_HIMETRICTOCONTAINER 0x4
#define XFORMCOORDS_CONTAINERTOHIMETRIC 0x8
#undef INTERFACE
#define INTERFACE ISimpleFrameSite
DECLARE_INTERFACE_(ISimpleFrameSite, IUnknown) {
	STDMETHOD(QueryInterface)(THIS_ REFIID riid, LPVOID * ppvObj) ;
	STDMETHOD_(ULONG,AddRef)(THIS) ;
	STDMETHOD_(ULONG,Release)(THIS) ;
	STDMETHOD(PreMessageFilter)(THIS_ HWND hwnd, UINT msg, WPARAM wp,
		LPARAM lp, LRESULT * lplResult, DWORD FAR * lpdwCookie) ;
	STDMETHOD(PostMessageFilter)(THIS_ HWND hwnd, UINT msg, WPARAM wp,
		LPARAM lp, LRESULT * lplResult, DWORD dwCookie) ;
};
#undef INTERFACE
#define INTERFACE IErrorLog
DECLARE_INTERFACE_(IErrorLog, IUnknown) {
	STDMETHOD(QueryInterface)(THIS_ REFIID riid, LPVOID * ppvObj) ;
	STDMETHOD_(ULONG,AddRef)(THIS) ;
	STDMETHOD_(ULONG,Release)(THIS) ;
	STDMETHOD(AddError)(THIS_ LPCOLESTR pszPropName, LPEXCEPINFO pExcepInfo) ;
};
#undef INTERFACE
#define INTERFACE IPropertyBag
DECLARE_INTERFACE_(IPropertyBag, IUnknown) {
	STDMETHOD(QueryInterface)(THIS_ REFIID riid, LPVOID * ppvObj) ;
	STDMETHOD_(ULONG,AddRef)(THIS) ;
	STDMETHOD_(ULONG,Release)(THIS) ;
	STDMETHOD(Read)(THIS_ LPCOLESTR pszPropName, LPVARIANT pVar,
		LPERRORLOG pErrorLog) ;
	STDMETHOD(Write)(THIS_ LPCOLESTR pszPropName, LPVARIANT pVar) ;
};
#undef INTERFACE
#define INTERFACE IPersistPropertyBag
DECLARE_INTERFACE_(IPersistPropertyBag, IPersist) {
	STDMETHOD(QueryInterface)(THIS_ REFIID riid, LPVOID * ppvObj) ;
	STDMETHOD_(ULONG,AddRef)(THIS) ;
	STDMETHOD_(ULONG,Release)(THIS) ;
	STDMETHOD(GetClassID)(THIS_ LPCLSID lpClassID) ;
	STDMETHOD(InitNew)(THIS) ;
	STDMETHOD(Load)(THIS_ LPPROPERTYBAG pPropBag, LPERRORLOG pErrorLog) ;
	STDMETHOD(Save)(THIS_ LPPROPERTYBAG pPropBag, BOOL fClearDirty,
		BOOL fSaveAllProperties) ;
};
#undef INTERFACE
#define INTERFACE IPersistStreamInit
DECLARE_INTERFACE_(IPersistStreamInit, IPersist) {
	STDMETHOD(QueryInterface)(THIS_ REFIID riid, LPVOID * ppvObj) ;
	STDMETHOD_(ULONG,AddRef)(THIS) ;
	STDMETHOD_(ULONG,Release)(THIS) ;
	STDMETHOD(GetClassID)(THIS_ LPCLSID lpClassID) ;
	STDMETHOD(IsDirty)(THIS) ;
	STDMETHOD(Load)(THIS_ LPSTREAM pStm) ;
	STDMETHOD(Save)(THIS_ LPSTREAM pStm, BOOL fClearDirty) ;
	STDMETHOD(GetSizeMax)(THIS_ ULARGE_INTEGER * pcbSize) ;
	STDMETHOD(InitNew)(THIS) ;
};
#undef INTERFACE
#define INTERFACE IPersistMemory
DECLARE_INTERFACE_(IPersistMemory, IPersist) {
	STDMETHOD(QueryInterface)(THIS_ REFIID riid, LPVOID * ppvObj) ;
	STDMETHOD_(ULONG,AddRef)(THIS) ;
	STDMETHOD_(ULONG,Release)(THIS) ;
	STDMETHOD(GetClassID)(THIS_ LPCLSID lpClassID) ;
	STDMETHOD(IsDirty)(THIS) ;
	STDMETHOD(Load)(THIS_ LPVOID lpStream, ULONG cbSize) ;
	STDMETHOD(Save)(THIS_ LPVOID lpStream, BOOL fClearDirty, ULONG cbSize) ;
	STDMETHOD(GetSizeMax)(THIS_ ULONG* pcbSize) ;
	STDMETHOD(InitNew)(THIS) ;
};
#undef INTERFACE
#define INTERFACE IPropertyNotifySink
DECLARE_INTERFACE_(IPropertyNotifySink, IUnknown) {
	STDMETHOD(QueryInterface)(THIS_ REFIID riid, LPVOID * ppvObj) ;
	STDMETHOD_(ULONG,AddRef)(THIS) ;
	STDMETHOD_(ULONG,Release)(THIS) ;
	STDMETHOD(OnChanged)(THIS_ DISPID dispid) ;
	STDMETHOD(OnRequestEdit)(THIS_ DISPID dispid) ;
};
#undef INTERFACE
#define INTERFACE IProvideClassInfo
DECLARE_INTERFACE_(IProvideClassInfo, IUnknown) {
	STDMETHOD(QueryInterface)(THIS_ REFIID riid, LPVOID * ppvObj) ;
	STDMETHOD_(ULONG,AddRef)(THIS) ;
	STDMETHOD_(ULONG,Release)(THIS) ;
	STDMETHOD(GetClassInfo)(THIS_ LPTYPEINFO * ppTI) ;
};
#undef INTERFACE
#define INTERFACE IProvideClassInfo2
DECLARE_INTERFACE_(IProvideClassInfo2, IProvideClassInfo) {
	STDMETHOD(QueryInterface)(THIS_ REFIID riid, LPVOID * ppvObj) ;
	STDMETHOD_(ULONG,AddRef)(THIS) ;
	STDMETHOD_(ULONG,Release)(THIS) ;
	STDMETHOD(GetClassInfo)(THIS_ LPTYPEINFO * ppTI) ;
	STDMETHOD(GetGUID)(THIS_ DWORD dwGuidKind, GUID * pGUID) ;
};
#define GUIDKIND_DEFAULT_SOURCE_DISP_IID	1
#undef INTERFACE
#define INTERFACE IConnectionPointContainer
DECLARE_INTERFACE_(IConnectionPointContainer, IUnknown) {
	STDMETHOD(QueryInterface)(THIS_ REFIID riid, LPVOID * ppvObj) ;
	STDMETHOD_(ULONG,AddRef)(THIS) ;
	STDMETHOD_(ULONG,Release)(THIS) ;
	STDMETHOD(EnumConnectionPoints)(THIS_ LPENUMCONNECTIONPOINTS * ppEnum)
		;
	STDMETHOD(FindConnectionPoint)(THIS_ REFIID iid,
		LPCONNECTIONPOINT * ppCP) ;
};
#undef INTERFACE
#define INTERFACE IEnumConnectionPoints
DECLARE_INTERFACE_(IEnumConnectionPoints, IUnknown) {
	STDMETHOD(QueryInterface)(THIS_ REFIID riid, LPVOID * ppvObj) ;
	STDMETHOD_(ULONG,AddRef)(THIS) ;
	STDMETHOD_(ULONG,Release)(THIS) ;
	STDMETHOD(Next)(THIS_ ULONG cConnections, LPCONNECTIONPOINT * rgpcn,
		ULONG * lpcFetched) ;
	STDMETHOD(Skip)(THIS_ ULONG cConnections) ;
	STDMETHOD(Reset)(THIS) ;
	STDMETHOD(Clone)(THIS_ LPENUMCONNECTIONPOINTS * ppEnum) ;
};
#undef INTERFACE
#define INTERFACE IConnectionPoint
DECLARE_INTERFACE_(IConnectionPoint, IUnknown) {
	STDMETHOD(QueryInterface)(THIS_ REFIID riid, LPVOID * ppvObj) ;
	STDMETHOD_(ULONG,AddRef)(THIS) ;
	STDMETHOD_(ULONG,Release)(THIS) ;
	STDMETHOD(GetConnectionInterface)(THIS_ IID * pIID) ;
	STDMETHOD(GetConnectionPointContainer)(THIS_
		IConnectionPointContainer * * ppCPC) ;
	STDMETHOD(Advise)(THIS_ LPUNKNOWN pUnkSink, DWORD * pdwCookie) ;
	STDMETHOD(Unadvise)(THIS_ DWORD dwCookie) ;
	STDMETHOD(EnumConnections)(THIS_ LPENUMCONNECTIONS * ppEnum) ;
};
typedef struct tagCONNECTDATA {
	LPUNKNOWN pUnk;
	DWORD dwCookie;
} CONNECTDATA;
#undef INTERFACE
#define INTERFACE IEnumConnections
DECLARE_INTERFACE_(IEnumConnections, IUnknown) {
	STDMETHOD(QueryInterface)(THIS_ REFIID riid, LPVOID * ppvObj) ;
	STDMETHOD_(ULONG,AddRef)(THIS) ;
	STDMETHOD_(ULONG,Release)(THIS) ;
	STDMETHOD(Next)(THIS_ ULONG cConnections, LPCONNECTDATA rgcd,
		ULONG * lpcFetched) ;
	STDMETHOD(Skip)(THIS_ ULONG cConnections) ;
	STDMETHOD(Reset)(THIS) ;
	STDMETHOD(Clone)(THIS_ LPENUMCONNECTIONS * ppecn) ;
};
typedef struct tagLICINFO {
	long cbLicInfo;
	BOOL fRuntimeKeyAvail;
	BOOL fLicVerified;
} LICINFO;
#undef INTERFACE
#define INTERFACE IClassFactory2
DECLARE_INTERFACE_(IClassFactory2, IClassFactory) {
	STDMETHOD(QueryInterface)(THIS_ REFIID riid, LPVOID * ppvObj) ;
	STDMETHOD_(ULONG,AddRef)(THIS) ;
	STDMETHOD_(ULONG,Release)(THIS) ;
	STDMETHOD(CreateInstance)(THIS_ LPUNKNOWN pUnkOuter, REFIID riid,
		LPVOID * ppvObject) ;
	STDMETHOD(LockServer)(THIS_ BOOL fLock) ;
	STDMETHOD(GetLicInfo)(THIS_ LPLICINFO pLicInfo) ;
	STDMETHOD(RequestLicKey)(THIS_ DWORD dwResrved, BSTR * pbstrKey) ;
	STDMETHOD(CreateInstanceLic)(THIS_ LPUNKNOWN pUnkOuter,
		LPUNKNOWN pUnkReserved, REFIID riid, BSTR bstrKey,
		LPVOID * ppvObject) ;
};
#ifndef _tagCAUUID_DEFINED
#define _tagCAUUID_DEFINED
#define _CAUUID_DEFINED
typedef struct tagCAUUID {
	ULONG cElems;
	GUID * pElems;
} CAUUID;
#endif
#ifndef _tagCALPOLESTR_DEFINED
#define _tagCALPOLESTR_DEFINED
#define _CALPOLESTR_DEFINED
typedef struct tagCALPOLESTR {
	ULONG cElems;
	LPOLESTR * pElems;
} CALPOLESTR;
#endif
#ifndef _tagCADWORD_DEFINED
#define _tagCADWORD_DEFINED
#define _CADWORD_DEFINED
typedef struct tagCADWORD {
	ULONG cElems;
	DWORD * pElems;
} CADWORD;
#endif
typedef struct tagOCPFIPARAMS {
	ULONG cbStructSize;
	HWND hWndOwner;
	int x;
	int y;
	LPCOLESTR lpszCaption;
	ULONG cObjects;
	LPUNKNOWN * lplpUnk;
	ULONG cPages;
	CLSID * lpPages;
	LCID lcid;
	DISPID dispidInitialProperty;
} OCPFIPARAMS;
typedef struct tagPROPPAGEINFO {
	size_t cb;
	LPOLESTR pszTitle;
	SIZE size;
	LPOLESTR pszDocString;
	LPOLESTR pszHelpFile;
	DWORD dwHelpContext;
} PROPPAGEINFO;
#undef INTERFACE
#define INTERFACE ISpecifyPropertyPages
DECLARE_INTERFACE_(ISpecifyPropertyPages, IUnknown) {
	STDMETHOD(QueryInterface)(THIS_ REFIID riid, LPVOID * ppvObj) ;
	STDMETHOD_(ULONG,AddRef)(THIS) ;
	STDMETHOD_(ULONG,Release)(THIS) ;
	STDMETHOD(GetPages)(THIS_ CAUUID * pPages) ;
};
#undef INTERFACE
#define INTERFACE IPerPropertyBrowsing
DECLARE_INTERFACE_(IPerPropertyBrowsing, IUnknown) {
	STDMETHOD(QueryInterface)(THIS_ REFIID riid, LPVOID * ppvObj) ;
	STDMETHOD_(ULONG,AddRef)(THIS) ;
	STDMETHOD_(ULONG,Release)(THIS) ;
	STDMETHOD(GetDisplayString)(THIS_ DISPID dispid, BSTR * lpbstr) ;
	STDMETHOD(MapPropertyToPage)(THIS_ DISPID dispid, LPCLSID lpclsid) ;
	STDMETHOD(GetPredefinedStrings)(THIS_ DISPID dispid,
		CALPOLESTR * lpcaStringsOut, CADWORD * lpcaCookiesOut) ;
	STDMETHOD(GetPredefinedValue)(THIS_ DISPID dispid, DWORD dwCookie,
		VARIANT * lpvarOut) ;
};
#undef INTERFACE
#define INTERFACE IPropertyPageSite
DECLARE_INTERFACE_(IPropertyPageSite, IUnknown) {
	STDMETHOD(QueryInterface)(THIS_ REFIID riid, LPVOID * ppvObj) ;
	STDMETHOD_(ULONG,AddRef)(THIS) ;
	STDMETHOD_(ULONG,Release)(THIS) ;
	STDMETHOD(OnStatusChange)(THIS_ DWORD flags) ;
	STDMETHOD(GetLocaleID)(THIS_ LCID * pLocaleID) ;
	STDMETHOD(GetPageContainer)(THIS_ LPUNKNOWN * ppUnk) ;
	STDMETHOD(TranslateAccelerator)(THIS_ LPMSG lpMsg) ;
};
#define PROPPAGESTATUS_DIRTY 0x1 
#define PROPPAGESTATUS_VALIDATE 0x2 
#undef INTERFACE
#define INTERFACE IPropertyPage
DECLARE_INTERFACE_(IPropertyPage, IUnknown) {
	STDMETHOD(QueryInterface)(THIS_ REFIID riid, LPVOID * ppvObj) ;
	STDMETHOD_(ULONG,AddRef)(THIS) ;
	STDMETHOD_(ULONG,Release)(THIS) ;
	STDMETHOD(SetPageSite)(THIS_ LPPROPERTYPAGESITE pPageSite) ;
	STDMETHOD(Activate)(THIS_ HWND hwndParent, LPCRECT lprc, BOOL bModal) ;
	STDMETHOD(Deactivate)(THIS) ;
	STDMETHOD(GetPageInfo)(THIS_ LPPROPPAGEINFO pPageInfo) ;
	STDMETHOD(SetObjects)(THIS_ ULONG cObjects, LPUNKNOWN * ppunk) ;
	STDMETHOD(Show)(THIS_ UINT nCmdShow) ;
	STDMETHOD(Move)(THIS_ LPCRECT prect) ;
	STDMETHOD(IsPageDirty)(THIS) ;
	STDMETHOD(Apply)(THIS) ;
	STDMETHOD(Help)(THIS_ LPCOLESTR lpszHelpDir) ;
	STDMETHOD(TranslateAccelerator)(THIS_ LPMSG lpMsg) ;
};
#undef INTERFACE
#define INTERFACE IPropertyPage2
DECLARE_INTERFACE_(IPropertyPage2, IPropertyPage) {
	STDMETHOD(QueryInterface)(THIS_ REFIID riid, LPVOID * ppvObj) ;
	STDMETHOD_(ULONG,AddRef)(THIS) ;
	STDMETHOD_(ULONG,Release)(THIS) ;
	STDMETHOD(SetPageSite)(THIS_ LPPROPERTYPAGESITE pPageSite) ;
	STDMETHOD(Activate)(THIS_ HWND hwndParent, LPCRECT lprc, BOOL bModal) ;
	STDMETHOD(Deactivate)(THIS) ;
	STDMETHOD(GetPageInfo)(THIS_ LPPROPPAGEINFO pPageInfo) ;
	STDMETHOD(SetObjects)(THIS_ ULONG cObjects, LPUNKNOWN * ppunk) ;
	STDMETHOD(Show)(THIS_ UINT nCmdShow) ;
	STDMETHOD(Move)(THIS_ LPCRECT prect) ;
	STDMETHOD(IsPageDirty)(THIS) ;
	STDMETHOD(Apply)(THIS) ;
	STDMETHOD(Help)(THIS_ LPCOLESTR lpszHelpDir) ;
	STDMETHOD(TranslateAccelerator)(THIS_ LPMSG lpMsg) ;
	STDMETHOD(EditProperty)(THIS_ DISPID dispid) ;
};
#undef INTERFACE
#define INTERFACE IFont
DECLARE_INTERFACE_(IFont, IUnknown) {
	STDMETHOD(QueryInterface)(THIS_ REFIID riid, LPVOID * ppvObj) ;
	STDMETHOD_(ULONG, AddRef)(THIS) ;
	STDMETHOD_(ULONG, Release)(THIS) ;
	STDMETHOD(get_Name)(THIS_ BSTR * pname) ;
	STDMETHOD(put_Name)(THIS_ BSTR name) ;
	STDMETHOD(get_Size)(THIS_ CY * psize) ;
	STDMETHOD(put_Size)(THIS_ CY size) ;
	STDMETHOD(get_Bold)(THIS_ BOOL * pbold) ;
	STDMETHOD(put_Bold)(THIS_ BOOL bold) ;
	STDMETHOD(get_Italic)(THIS_ BOOL * pitalic) ;
	STDMETHOD(put_Italic)(THIS_ BOOL italic) ;
	STDMETHOD(get_Underline)(THIS_ BOOL * punderline) ;
	STDMETHOD(put_Underline)(THIS_ BOOL underline) ;
	STDMETHOD(get_Strikethrough)(THIS_ BOOL * pstrikethrough) ;
	STDMETHOD(put_Strikethrough)(THIS_ BOOL strikethrough) ;
	STDMETHOD(get_Weight)(THIS_ short * pweight) ;
	STDMETHOD(put_Weight)(THIS_ short weight) ;
	STDMETHOD(get_Charset)(THIS_ short * pcharset) ;
	STDMETHOD(put_Charset)(THIS_ short charset) ;
	STDMETHOD(get_hFont)(THIS_ HFONT * phfont) ;
	STDMETHOD(Clone)(THIS_ IFont * * lplpfont) ;
	STDMETHOD(IsEqual)(THIS_ IFont FAR * lpFontOther) ;
	STDMETHOD(SetRatio)(THIS_ long cyLogical, long cyHimetric) ;
	STDMETHOD(QueryTextMetrics)(THIS_ LPTEXTMETRICOLE lptm) ;
	STDMETHOD(AddRefHfont)(THIS_ HFONT hfont) ;
	STDMETHOD(ReleaseHfont)(THIS_ HFONT hfont) ;
	STDMETHOD(SetHdc)(THIS_ HDC hdc) ;
};
#undef INTERFACE
#define INTERFACE IFontDisp
DECLARE_INTERFACE_(IFontDisp, IDispatch) {
	STDMETHOD(QueryInterface)(THIS_ REFIID riid, LPVOID * ppvObj) ;
	STDMETHOD_(ULONG, AddRef)(THIS) ;
	STDMETHOD_(ULONG, Release)(THIS) ;
	STDMETHOD(GetTypeInfoCount)(THIS_ UINT * pctinfo) ;
	STDMETHOD(GetTypeInfo)(THIS_ UINT itinfo, LCID lcid,
		ITypeInfo * * pptinfo) ;
	STDMETHOD(GetIDsOfNames)(THIS_ REFIID riid, LPOLESTR * rgszNames,
		UINT cNames, LCID lcid, DISPID * rgdispid) ;
	STDMETHOD(Invoke)(THIS_ DISPID dispidMember, REFIID riid, LCID lcid,
		WORD wFlags, DISPPARAMS * pdispparams, VARIANT * pvarResult,
		EXCEPINFO * pexcepinfo, UINT * puArgErr) ;
};
#define FONTSIZE(n) { n##0000, 0 }
typedef struct tagFONTDESC {
	UINT cbSizeofstruct;
	LPOLESTR lpstrName;
	CY cySize;
	SHORT sWeight;
	SHORT sCharset;
	BOOL fItalic;
	BOOL fUnderline;
	BOOL fStrikethrough;
} FONTDESC;
#define PICTURE_SCALABLE 0x1l
#define PICTURE_TRANSPARENT 0x2l
#undef INTERFACE
#define INTERFACE IPicture
DECLARE_INTERFACE_(IPicture, IUnknown) {
	STDMETHOD(QueryInterface)(THIS_ REFIID riid, LPVOID * ppvObj) ;
	STDMETHOD_(ULONG, AddRef)(THIS) ;
	STDMETHOD_(ULONG, Release)(THIS) ;
	STDMETHOD(get_Handle)(THIS_ OLE_HANDLE * phandle) ;
	STDMETHOD(get_hPal)(THIS_ OLE_HANDLE * phpal) ;
	STDMETHOD(get_Type)(THIS_ short * ptype) ;
	STDMETHOD(get_Width)(THIS_ OLE_XSIZE_HIMETRIC * pwidth) ;
	STDMETHOD(get_Height)(THIS_ OLE_YSIZE_HIMETRIC * pheight) ;
	STDMETHOD(Render)(THIS_ HDC hdc, long x, long y, long cx, long cy,
		OLE_XPOS_HIMETRIC xSrc, OLE_YPOS_HIMETRIC ySrc,
		OLE_XSIZE_HIMETRIC cxSrc, OLE_YSIZE_HIMETRIC cySrc,
		LPCRECT lprcWBounds) ;
	STDMETHOD(set_hPal)(THIS_ OLE_HANDLE hpal) ;
	STDMETHOD(get_CurDC)(THIS_ HDC FAR * phdcOut) ;
	STDMETHOD(SelectPicture)(THIS_
		HDC hdcIn, HDC FAR * phdcOut, OLE_HANDLE FAR * phbmpOut) ;
	STDMETHOD(get_KeepOriginalFormat)(THIS_ BOOL * pfkeep) ;
	STDMETHOD(put_KeepOriginalFormat)(THIS_ BOOL fkeep) ;
	STDMETHOD(PictureChanged)(THIS) ;
	STDMETHOD(SaveAsFile)(THIS_ LPSTREAM lpstream, BOOL fSaveMemCopy,
		LONG FAR * lpcbSize) ;
	STDMETHOD(get_Attributes)(THIS_ DWORD FAR * lpdwAttr) ;
};
#undef INTERFACE
#define INTERFACE IPictureDisp
DECLARE_INTERFACE_(IPictureDisp, IDispatch) {
	STDMETHOD(QueryInterface)(THIS_ REFIID riid, LPVOID * ppvObj) ;
	STDMETHOD_(ULONG, AddRef)(THIS) ;
	STDMETHOD_(ULONG, Release)(THIS) ;
	STDMETHOD(GetTypeInfoCount)(THIS_ UINT * pctinfo) ;
	STDMETHOD(GetTypeInfo)(THIS_ UINT itinfo, LCID lcid,
		ITypeInfo * * pptinfo) ;
	STDMETHOD(GetIDsOfNames)(THIS_ REFIID riid, LPOLESTR * rgszNames,
		UINT cNames, LCID lcid, DISPID * rgdispid) ;
	STDMETHOD(Invoke)(THIS_ DISPID dispidMember, REFIID riid, LCID lcid,
		WORD wFlags, DISPPARAMS * pdispparams, VARIANT * pvarResult,
		EXCEPINFO * pexcepinfo, UINT * puArgErr) ;
};
#define PICTYPE_UNINITIALIZED (-1)
#define PICTYPE_NONE		0
#define PICTYPE_BITMAP		1
#define PICTYPE_METAFILE	2
#define PICTYPE_ICON		3
#define PICTYPE_ENHMETAFILE	4
typedef struct tagPICTDESC {
	UINT cbSizeofstruct;
	UINT picType;
	union
	{
		struct
		{
			HBITMAP hbitmap; 
			HPALETTE hpal; 
		} bmp;

		struct
		{
			HMETAFILE hmeta; 
			int xExt;
			int yExt; 
		} wmf;

		struct
		{
			HICON hicon; 
		} icon;

		struct
		{
			HENHMETAFILE hemf; 
		} emf;
	};

} PICTDESC;
#ifndef RC_INVOKED
#pragma pack(pop)
#endif 
#endif 
#define DISPID_AUTOSIZE (-500)
#define DISPID_BACKCOLOR (-501)
#define DISPID_BACKSTYLE (-502)
#define DISPID_BORDERCOLOR (-503)
#define DISPID_BORDERSTYLE (-504)
#define DISPID_BORDERWIDTH (-505)
#define DISPID_DRAWMODE (-507)
#define DISPID_DRAWSTYLE (-508)
#define DISPID_DRAWWIDTH (-509)
#define DISPID_FILLCOLOR (-510)
#define DISPID_FILLSTYLE (-511)
#define DISPID_FONT (-512)
#define DISPID_FORECOLOR (-513)
#define DISPID_ENABLED (-514)
#define DISPID_HWND (-515)
#define DISPID_TABSTOP (-516)
#define DISPID_TEXT (-517)
#define DISPID_CAPTION (-518)
#define DISPID_BORDERVISIBLE (-519)
#define DISPID_APPEARANCE				(-520)
#define DISPID_REFRESH (-550)
#define DISPID_DOCLICK (-551)
#define DISPID_ABOUTBOX (-552)
#define DISPID_CLICK (-600)
#define DISPID_DBLCLICK (-601)
#define DISPID_KEYDOWN (-602)
#define DISPID_KEYPRESS (-603)
#define DISPID_KEYUP (-604)
#define DISPID_MOUSEDOWN (-605)
#define DISPID_MOUSEMOVE (-606)
#define DISPID_MOUSEUP (-607)
#define DISPID_ERROREVENT (-608)
#define DISPID_AMBIENT_BACKCOLOR (-701)
#define DISPID_AMBIENT_DISPLAYNAME (-702)
#define DISPID_AMBIENT_FONT (-703)
#define DISPID_AMBIENT_FORECOLOR (-704)
#define DISPID_AMBIENT_LOCALEID (-705)
#define DISPID_AMBIENT_MESSAGEREFLECT (-706)
#define DISPID_AMBIENT_SCALEUNITS (-707)
#define DISPID_AMBIENT_TEXTALIGN (-708)
#define DISPID_AMBIENT_USERMODE (-709)
#define DISPID_AMBIENT_UIDEAD (-710)
#define DISPID_AMBIENT_SHOWGRABHANDLES (-711)
#define DISPID_AMBIENT_SHOWHATCHING (-712)
#define DISPID_AMBIENT_DISPLAYASDEFAULT (-713)
#define DISPID_AMBIENT_SUPPORTSMNEMONICS (-714)
#define DISPID_AMBIENT_AUTOCLIP (-715)
#define DISPID_AMBIENT_APPEARANCE		(-716)
#define DISPID_FONT_NAME 0
#define DISPID_FONT_SIZE 2
#define DISPID_FONT_BOLD 3
#define DISPID_FONT_ITALIC 4
#define DISPID_FONT_UNDER 5
#define DISPID_FONT_STRIKE 6
#define DISPID_FONT_WEIGHT 7
#define DISPID_FONT_CHARSET 8
#define DISPID_PICT_HANDLE 0
#define DISPID_PICT_HPAL 2
#define DISPID_PICT_TYPE 3
#define DISPID_PICT_WIDTH 4
#define DISPID_PICT_HEIGHT 5
#define DISPID_PICT_RENDER 6
#ifdef __MKTYPLIB__
#define STDOLE_TLB "stdole32.tlb"
#define STDTYPE_TLB "olepro32.dll"
#endif 
#endif 
