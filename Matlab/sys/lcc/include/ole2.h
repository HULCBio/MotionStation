/* $Revision: 1.2 $ */
#ifndef __LCC_OLE2_H
#define __LCC_OLE2_H
#include <windows.h>
#pragma pack(push,8)
#ifndef WIN32
#define WIN32    100  
#endif
#include <objbase.h>
#include <oleauto.h>
#define E_DRAW                  VIEW_E_DRAW
#define DATA_E_FORMATETC        DV_E_FORMATETC
#define OLEIVERB_PRIMARY            0
#define OLEIVERB_SHOW               (-1)
#define OLEIVERB_OPEN               (-2)
#define OLEIVERB_HIDE               (-3)
#define OLEIVERB_UIACTIVATE         (-4)
#define OLEIVERB_INPLACEACTIVATE    (-5)
#define OLEIVERB_DISCARDUNDOSTATE   (-6)
#define EMBDHLP_INPROC_HANDLER   0x0000L
#define EMBDHLP_INPROC_SERVER    0x0001L
#define EMBDHLP_CREATENOW    0x00000000L
#define EMBDHLP_DELAYCREATE  0x00010000L
#include <oleidl.h>
WINOLEAPI CreateDataAdviseHolder(LPDATAADVISEHOLDER * ppDAHolder);
WINOLEAPI_(DWORD) OleBuildVersion( VOID );
WINOLEAPI ReadClassStg(LPSTORAGE pStg, CLSID * pclsid);
WINOLEAPI WriteClassStg(LPSTORAGE pStg, REFCLSID rclsid);
WINOLEAPI ReadClassStm(LPSTREAM pStm, CLSID * pclsid);
WINOLEAPI WriteClassStm(LPSTREAM pStm, REFCLSID rclsid);
WINOLEAPI WriteFmtUserTypeStg (LPSTORAGE pstg, CLIPFORMAT cf, LPOLESTR lpszUserType);
WINOLEAPI ReadFmtUserTypeStg (LPSTORAGE pstg, CLIPFORMAT * pcf, LPOLESTR * lplpszUserType);
WINOLEAPI OleInitialize(LPVOID pvReserved);
WINOLEAPI_(void) OleUninitialize(void);
WINOLEAPI  OleQueryLinkFromData(LPDATAOBJECT pSrcDataObject);
WINOLEAPI  OleQueryCreateFromData(LPDATAOBJECT pSrcDataObject);
WINOLEAPI  OleCreate(REFCLSID rclsid, REFIID riid, DWORD renderopt, LPFORMATETC pFormatEtc, 
		LPOLECLIENTSITE pClientSite, LPSTORAGE pStg, LPVOID * ppvObj);
WINOLEAPI  OleCreateFromData(LPDATAOBJECT pSrcDataObj, REFIID riid,
                DWORD renderopt, LPFORMATETC pFormatEtc, LPOLECLIENTSITE pClientSite, LPSTORAGE pStg, LPVOID * ppvObj);
WINOLEAPI  OleCreateLinkFromData(LPDATAOBJECT pSrcDataObj, REFIID riid,
                DWORD renderopt, LPFORMATETC pFormatEtc,
                LPOLECLIENTSITE pClientSite, LPSTORAGE pStg,
                LPVOID * ppvObj);
WINOLEAPI  OleCreateStaticFromData(LPDATAOBJECT pSrcDataObj, REFIID iid,
                DWORD renderopt, LPFORMATETC pFormatEtc,
                LPOLECLIENTSITE pClientSite, LPSTORAGE pStg,
                LPVOID * ppvObj);
WINOLEAPI  OleCreateLink(LPMONIKER pmkLinkSrc, REFIID riid,
            DWORD renderopt, LPFORMATETC lpFormatEtc,
            LPOLECLIENTSITE pClientSite, LPSTORAGE pStg, LPVOID * ppvObj);
WINOLEAPI  OleCreateLinkToFile(LPCOLESTR lpszFileName, REFIID riid,
            DWORD renderopt, LPFORMATETC lpFormatEtc,
            LPOLECLIENTSITE pClientSite, LPSTORAGE pStg, LPVOID * ppvObj);
WINOLEAPI  OleCreateFromFile(REFCLSID rclsid, LPCOLESTR lpszFileName, REFIID riid,
            DWORD renderopt, LPFORMATETC lpFormatEtc,
            LPOLECLIENTSITE pClientSite, LPSTORAGE pStg, LPVOID * ppvObj);
WINOLEAPI  OleLoad(LPSTORAGE pStg, REFIID riid, LPOLECLIENTSITE pClientSite, LPVOID * ppvObj);
WINOLEAPI  OleSave(LPPERSISTSTORAGE pPS, LPSTORAGE pStg, BOOL fSameAsLoad);
WINOLEAPI  OleLoadFromStream( LPSTREAM pStm, REFIID iidInterface, LPVOID * ppvObj);
WINOLEAPI  OleSaveToStream( LPPERSISTSTREAM pPStm, LPSTREAM pStm );
WINOLEAPI  OleSetContainedObject(LPUNKNOWN pUnknown, BOOL fContained);
WINOLEAPI  OleNoteObjectVisible(LPUNKNOWN pUnknown, BOOL fVisible);
WINOLEAPI  RegisterDragDrop(HWND hwnd, LPDROPTARGET pDropTarget);
WINOLEAPI  RevokeDragDrop(HWND hwnd);
WINOLEAPI  DoDragDrop(LPDATAOBJECT pDataObj, LPDROPSOURCE pDropSource, DWORD dwOKEffects, LPDWORD pdwEffect);
WINOLEAPI  OleSetClipboard(LPDATAOBJECT pDataObj);
WINOLEAPI  OleGetClipboard(LPDATAOBJECT * ppDataObj);
WINOLEAPI  OleFlushClipboard(void);
WINOLEAPI  OleIsCurrentClipboard(LPDATAOBJECT pDataObj);
WINOLEAPI_(HOLEMENU)   OleCreateMenuDescriptor (HMENU hmenuCombined, LPOLEMENUGROUPWIDTHS lpMenuWidths);
WINOLEAPI              OleSetMenuDescriptor (HOLEMENU , HWND hwndFrame, HWND, LPOLEINPLACEFRAME , LPOLEINPLACEACTIVEOBJECT);
WINOLEAPI              OleDestroyMenuDescriptor (HOLEMENU holemenu);
WINOLEAPI              OleTranslateAccelerator (LPOLEINPLACEFRAME lpFrame,
                            LPOLEINPLACEFRAMEINFO lpFrameInfo, LPMSG lpmsg);
WINOLEAPI_(HANDLE) OleDuplicateData (HANDLE hSrc, CLIPFORMAT cfFormat, UINT uiFlags);
WINOLEAPI          OleDraw (LPUNKNOWN pUnknown, DWORD dwAspect, HDC hdcDraw, LPCRECT lprcBounds);
WINOLEAPI          OleRun(LPUNKNOWN pUnknown);
WINOLEAPI_(BOOL)   OleIsRunning(LPOLEOBJECT pObject);
WINOLEAPI          OleLockRunning(LPUNKNOWN pUnknown, BOOL fLock, BOOL fLastUnlockCloses);
WINOLEAPI_(void)   ReleaseStgMedium(LPSTGMEDIUM);
WINOLEAPI          CreateOleAdviseHolder(LPOLEADVISEHOLDER * ppOAHolder);
WINOLEAPI          OleCreateDefaultHandler(REFCLSID clsid, LPUNKNOWN pUnkOuter,
                    REFIID riid, LPVOID * lplpObj);
WINOLEAPI          OleCreateEmbeddingHelper(REFCLSID clsid, LPUNKNOWN pUnkOuter,
                    DWORD flags, LPCLASSFACTORY pCF, REFIID riid, LPVOID * lplpObj);
WINOLEAPI_(BOOL)   IsAccelerator(HACCEL hAccel, int cAccelEntries, LPMSG lpMsg, WORD * lpwCmd);
WINOLEAPI_(HGLOBAL) OleGetIconOfFile(LPOLESTR lpszPath, BOOL fUseFileAsLabel);
WINOLEAPI_(HGLOBAL) OleGetIconOfClass(REFCLSID rclsid,     LPOLESTR lpszLabel, BOOL fUseTypeAsLabel);
WINOLEAPI_(HGLOBAL) OleMetafilePictFromIconAndLabel(HICON hIcon, LPOLESTR lpszLabel,
                                        LPOLESTR lpszSourceFile, UINT iIconIndex);
WINOLEAPI                  OleRegGetUserType (REFCLSID clsid, DWORD dwFormOfType,
                                        LPOLESTR * pszUserType);
WINOLEAPI                  OleRegGetMiscStatus     (REFCLSID clsid, DWORD dwAspect, DWORD * pdwStatus);
WINOLEAPI                  OleRegEnumFormatEtc     (REFCLSID clsid, DWORD dwDirection, LPENUMFORMATETC * ppenum);
WINOLEAPI                  OleRegEnumVerbs (REFCLSID clsid, LPENUMOLEVERB * ppenum);
typedef struct _OLESTREAM *  LPOLESTREAM;
typedef struct _OLESTREAMVTBL {
    DWORD (CALLBACK* Get)(LPOLESTREAM, void *, DWORD);
    DWORD (CALLBACK* Put)(LPOLESTREAM, const void *, DWORD);
} OLESTREAMVTBL;
typedef  OLESTREAMVTBL *  LPOLESTREAMVTBL;
typedef struct _OLESTREAM {
    LPOLESTREAMVTBL lpstbl;
} OLESTREAM;
WINOLEAPI OleConvertOLESTREAMToIStorage
    (LPOLESTREAM                lpolestream,
    LPSTORAGE                   pstg,
    const DVTARGETDEVICE *   ptd);
WINOLEAPI OleConvertIStorageToOLESTREAM (LPSTORAGE     pstg, LPOLESTREAM     lpolestream);
WINOLEAPI GetHGlobalFromILockBytes (LPLOCKBYTES plkbyt, HGLOBAL * phglobal);
WINOLEAPI CreateILockBytesOnHGlobal (HGLOBAL hGlobal, BOOL fDeleteOnRelease,
                                    LPLOCKBYTES * pplkbyt);
WINOLEAPI GetHGlobalFromStream (LPSTREAM pstm, HGLOBAL * phglobal);
WINOLEAPI CreateStreamOnHGlobal (HGLOBAL hGlobal, BOOL fDeleteOnRelease,
                                LPSTREAM * ppstm);
WINOLEAPI OleDoAutoConvert(LPSTORAGE pStg, LPCLSID pClsidNew);
WINOLEAPI OleGetAutoConvert(REFCLSID clsidOld, LPCLSID pClsidNew);
WINOLEAPI OleSetAutoConvert(REFCLSID clsidOld, REFCLSID clsidNew);
WINOLEAPI GetConvertStg(LPSTORAGE pStg);
WINOLEAPI SetConvertStg(LPSTORAGE pStg, BOOL fConvert);
WINOLEAPI OleConvertIStorageToOLESTREAMEx
    (LPSTORAGE          pstg,
     CLIPFORMAT         cfFormat,   
     LONG               lWidth,     
     LONG               lHeight,    
     DWORD              dwSize,     
     LPSTGMEDIUM        pmedium,    
     LPOLESTREAM        polestm);

WINOLEAPI OleConvertOLESTREAMToIStorageEx
    (LPOLESTREAM        polestm,
     LPSTORAGE          pstg,
     CLIPFORMAT *    pcfFormat,  
     LONG *          plwWidth,   
     LONG *          plHeight,   
     DWORD *         pdwSize,    
     LPSTGMEDIUM        pmedium);   
#ifndef RC_INVOKED
#pragma pack(pop)
#endif 
#endif

