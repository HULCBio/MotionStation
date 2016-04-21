/* $Revision: 1.2 $ */
#include <windows.h>
#if !defined( _OBJBASE_H_ )
#define _OBJBASE_H_
#ifndef LPUNKNOWN_DEFINED
typedef void *LPUNKNOWN;
#define LPUNKNOWN_DEFINED
#endif
#ifndef LPOLESTR
#define LPOLESTR LPCSTR
#endif
#ifndef OLECHAR
#define OLECHAR WCHAR
#endif
#if defined(_WIN32) || defined(_MPPC_)
#define STDMETHODCALLTYPE       _stdcall
#define STDMETHODVCALLTYPE
#define STDAPICALLTYPE          _stdcall
#define STDAPIVCALLTYPE
#define STDAPI                  extern HRESULT STDAPICALLTYPE
#define STDAPI_(type)           extern type STDAPICALLTYPE
#define STDMETHODIMP            HRESULT STDMETHODCALLTYPE
#define STDMETHODIMP_(type)     type STDMETHODCALLTYPE
#define STDAPIV                 extern HRESULT STDAPIVCALLTYPE
#define STDAPIV_(type)          extern type STDAPIVCALLTYPE
#define STDMETHODIMPV           HRESULT STDMETHODVCALLTYPE
#define STDMETHODIMPV_(type)    type STDMETHODVCALLTYPE
#ifdef _OLE32_
#define WINOLEAPI        STDAPI
#define WINOLEAPI_(type) STDAPI_(type)
#else
#define WINOLEAPI        extern HRESULT STDAPICALLTYPE
#define WINOLEAPI_(type) extern type STDAPICALLTYPE
#endif
#define interface               struct
#ifndef STDMETHOD
#define STDMETHOD(method)       HRESULT (STDMETHODCALLTYPE * method)
#define STDMETHOD_(type,method) type (STDMETHODCALLTYPE * method)
#endif
#define BEGIN_INTERFACE
#define END_INTERFACE
#define PURE
#ifndef THIS_
#define THIS_                   INTERFACE * This,
#define THIS                    INTERFACE * This
#endif
#ifdef CONST_VTABLE
#undef CONST_VTBL
#define CONST_VTBL const
#define DECLARE_INTERFACE(iface)    typedef interface iface { \
                                    const struct iface##Vtbl * lpVtbl; \
                                } iface; \
                                typedef const struct iface##Vtbl iface##Vtbl; \
                                const struct iface##Vtbl
#else
#undef CONST_VTBL
#define CONST_VTBL
#define DECLARE_INTERFACE(iface)    typedef interface iface { struct iface##Vtbl * lpVtbl; } iface; \
                                typedef struct iface##Vtbl iface##Vtbl; \
                                struct iface##Vtbl
#endif
#define DECLARE_INTERFACE_(iface, baseiface)    DECLARE_INTERFACE(iface)
#endif

#define FARSTRUCT
#define HUGEP
#include <stdlib.h>
#define LISet32(li, v) ((li).HighPart = (v) < 0 ? -1 : 0, (li).LowPart = (v))
#define ULISet32(li, v) ((li).HighPart = 0, (li).LowPart = (v))
#define CLSCTX_INPROC           (CLSCTX_INPROC_SERVER|CLSCTX_INPROC_HANDLER)
#define CLSCTX_ALL              (CLSCTX_INPROC_SERVER| \
                                 CLSCTX_INPROC_HANDLER| \
                                 CLSCTX_LOCAL_SERVER| \
                                 CLSCTX_REMOTE_SERVER)

#define CLSCTX_SERVER           (CLSCTX_INPROC_SERVER|CLSCTX_LOCAL_SERVER|CLSCTX_REMOTE_SERVER)
typedef enum tagREGCLS { REGCLS_SINGLEUSE = 0, REGCLS_MULTIPLEUSE = 1,     
    REGCLS_MULTI_SEPARATE = 2   } REGCLS;
#define MARSHALINTERFACE_MIN 500 
#define CWCSTORAGENAME 32
#define STGM_DIRECT             0
#define STGM_TRANSACTED         0x10000L
#define STGM_SIMPLE             0x8000000L
#define STGM_READ               0
#define STGM_WRITE              1
#define STGM_READWRITE          2
#define STGM_SHARE_DENY_NONE    0x40L
#define STGM_SHARE_DENY_READ    0x30L
#define STGM_SHARE_DENY_WRITE   0x20L
#define STGM_SHARE_EXCLUSIVE    0x10L
#define STGM_PRIORITY           0x40000L
#define STGM_DELETEONRELEASE    0x4000000L
#define STGM_NOSCRATCH          0x100000L
#define STGM_CREATE             0x1000L
#define STGM_CONVERT            0x20000L
#define STGM_FAILIFTHERE        0
#define STGM_NOSNAPSHOT         0x200000L
#define ASYNC_MODE_COMPATIBILITY    1
#define ASYNC_MODE_DEFAULT          0
#define STGTY_REPEAT                0x100L
#define STG_TOEND                   0xFFFFFFFFL
#define STG_LAYOUT_SEQUENTIAL       0
#define STG_LAYOUT_INTERLEAVED      1
typedef interface    IRpcStubBuffer     IRpcStubBuffer;
typedef interface    IRpcChannelBuffer  IRpcChannelBuffer;
#include <wtypes.h>
#include <objidl.h>
#ifndef DEFINE_GUID
#ifndef INITGUID
#define DEFINE_GUID(name, l, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8) \
    extern const GUID  name
#else

#define DEFINE_GUID(name, l, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8) \
        extern const GUID name \
                = { l, w1, w2, { b1, b2,  b3,  b4,  b5,  b6,  b7,  b8 } }
#endif 
#endif
#define DEFINE_OLEGUID(name,l,w1,w2)  DEFINE_GUID(name,l,w1,w2,0xC0,0,0,0,0,0,0,0x46)
#define IsEqualIID(riid1, riid2) IsEqualGUID(riid1, riid2)
BOOL wIsEqualGUID(REFGUID,REFGUID);
#define IsEqualGUID(r1,r2) wIsEqualGUID(r1,r2)
#define IsEqualCLSID(rclsid1, rclsid2) IsEqualGUID(rclsid1, rclsid2)
typedef enum tagCOINIT {COINIT_MULTITHREADED = 0, COINIT_APARTMENTTHREADED  = 2,      
	COINIT_DISABLE_OLE1DDE = 4, COINIT_SPEED_OVER_MEMORY  = 8 } COINIT;
WINOLEAPI_(DWORD) CoBuildVersion(VOID);
WINOLEAPI  CoInitialize(LPVOID);
WINOLEAPI  CoInitializeEx(LPVOID,DWORD);
WINOLEAPI_(void)  CoUninitialize(void);
WINOLEAPI  CoGetMalloc(DWORD,LPMALLOC *);
WINOLEAPI_(DWORD) CoGetCurrentProcess(void);
WINOLEAPI  CoRegisterMallocSpy(LPMALLOCSPY);
WINOLEAPI  CoRevokeMallocSpy(void);
WINOLEAPI  CoCreateStandardMalloc(DWORD,IMalloc * *);
#if DBG == 1
WINOLEAPI_(ULONG) DebugCoGetRpcFault( void );
WINOLEAPI_(void) DebugCoSetRpcFault( ULONG );
#endif
WINOLEAPI  CoGetClassObject(REFCLSID,DWORD,LPVOID,REFIID,LPVOID *);
WINOLEAPI  CoRegisterClassObject(REFCLSID,LPUNKNOWN,DWORD,DWORD,LPDWORD);
WINOLEAPI  CoRevokeClassObject(DWORD);
WINOLEAPI CoGetMarshalSizeMax(ULONG *,REFIID,LPUNKNOWN,DWORD,LPVOID,DWORD);
WINOLEAPI CoMarshalInterface(LPSTREAM,REFIID,LPUNKNOWN,DWORD,LPVOID,DWORD);
WINOLEAPI CoUnmarshalInterface(LPSTREAM, REFIID,LPVOID * );
WINOLEAPI CoMarshalHresult(LPSTREAM,HRESULT);
WINOLEAPI CoUnmarshalHresult(LPSTREAM,HRESULT  *);
WINOLEAPI CoReleaseMarshalData(LPSTREAM);
WINOLEAPI CoDisconnectObject(LPUNKNOWN,DWORD);
WINOLEAPI CoLockObjectExternal(LPUNKNOWN,BOOL,BOOL);
WINOLEAPI CoGetStandardMarshal(REFIID,LPUNKNOWN,DWORD,LPVOID,DWORD,LPMARSHAL *);
WINOLEAPI_(BOOL) CoIsHandlerConnected(LPUNKNOWN);
WINOLEAPI_(BOOL) CoHasStrongExternalConnections(LPUNKNOWN);
WINOLEAPI CoMarshalInterThreadInterfaceInStream(REFIID,LPUNKNOWN,LPSTREAM *);
WINOLEAPI CoGetInterfaceAndReleaseStream(LPSTREAM,REFIID,LPVOID *);
WINOLEAPI CoCreateFreeThreadedMarshaler(LPUNKNOWN,LPUNKNOWN *);
WINOLEAPI_(HINSTANCE) CoLoadLibrary(LPOLESTR,BOOL);
WINOLEAPI_(void) CoFreeLibrary(HINSTANCE);
WINOLEAPI_(void) CoFreeAllLibraries(void);
WINOLEAPI_(void) CoFreeUnusedLibraries(void);
WINOLEAPI CoGetCallContext(REFIID,void **);
WINOLEAPI CoSwitchCallContext( IUnknown *,IUnknown **);
WINOLEAPI CoQueryProxyBlanket(IUnknown *,DWORD *,DWORD *,OLECHAR **,DWORD *,DWORD *, void *, DWORD *);
WINOLEAPI CoSetProxyBlanket(IUnknown *,DWORD,DWORD,OLECHAR *,DWORD,DWORD,void *,DWORD);
WINOLEAPI CoCopyProxy(IUnknown *, IUnknown   **);
WINOLEAPI CoQueryClientBlanket(DWORD *,DWORD *,OLECHAR **,DWORD *,DWORD  *,void  *,DWORD *);
WINOLEAPI CoImpersonateClient(void);
WINOLEAPI CoRevertToSelf();
#define COM_RIGHTS_EXECUTE 1
WINOLEAPI CoCreateInstance(REFCLSID,LPUNKNOWN,DWORD,REFIID,LPVOID *);
WINOLEAPI CoGetPersistentInstance(REFIID,DWORD,DWORD,OLECHAR *,struct IStorage *,REFCLSID,BOOL *,void **);
typedef struct _COSERVERINFO { DWORD dwSize; OLECHAR *pszName; } COSERVERINFO;
WINOLEAPI StringFromCLSID(REFCLSID,LPOLESTR * );
WINOLEAPI CLSIDFromString(LPOLESTR,LPCLSID);
WINOLEAPI StringFromIID(REFIID,LPOLESTR *);
WINOLEAPI IIDFromString(LPOLESTR lpsz, LPIID lpiid);
WINOLEAPI_(BOOL) CoIsOle1Class(REFCLSID rclsid);
WINOLEAPI ProgIDFromCLSID (REFCLSID clsid, LPOLESTR * lplpszProgID);
WINOLEAPI CLSIDFromProgID (LPCOLESTR lpszProgID, LPCLSID lpclsid);
WINOLEAPI_(int) StringFromGUID2(REFGUID rguid, LPOLESTR lpsz, int cbMax);
WINOLEAPI CoCreateGuid(GUID  *pguid);
WINOLEAPI_(BOOL) CoFileTimeToDosDateTime(FILETIME *,LPWORD,LPWORD);
WINOLEAPI_(BOOL) CoDosDateTimeToFileTime(WORD,WORD,FILETIME *);
WINOLEAPI  CoFileTimeNow(FILETIME *);
WINOLEAPI CoRegisterMessageFilter(LPMESSAGEFILTER,LPMESSAGEFILTER *);
WINOLEAPI CoGetTreatAsClass(REFCLSID clsidOld, LPCLSID pClsidNew);
WINOLEAPI CoTreatAsClass(REFCLSID clsidOld, REFCLSID clsidNew);
typedef HRESULT (STDAPICALLTYPE * LPFNGETCLASSOBJECT) (REFCLSID, REFIID, LPVOID *);
typedef HRESULT (STDAPICALLTYPE * LPFNCANUNLOADNOW)(void);
STDAPI  DllGetClassObject(REFCLSID rclsid, REFIID riid, LPVOID * ppv);
STDAPI  DllCanUnloadNow(void);
WINOLEAPI_(LPVOID) CoTaskMemAlloc(ULONG cb);
WINOLEAPI_(LPVOID) CoTaskMemRealloc(LPVOID,ULONG);
WINOLEAPI_(void)   CoTaskMemFree(LPVOID);
WINOLEAPI CreateDataAdviseHolder(LPDATAADVISEHOLDER *);
WINOLEAPI CreateDataCache(LPUNKNOWN * ,REFCLSID,REFIID,LPVOID *);
WINOLEAPI StgCreateDocfile(OLECHAR *, DWORD,DWORD,struct IStorage * *);
WINOLEAPI StgCreateDocfileOnILockBytes(ILockBytes  *,DWORD,DWORD,struct IStorage * *);
WINOLEAPI StgOpenStorage(OLECHAR *,IStorage  *,DWORD,SNB,DWORD,struct IStorage * *);
WINOLEAPI StgOpenStorageOnILockBytes(ILockBytes  *,IStorage  *,DWORD,SNB,DWORD,struct IStorage * *);
WINOLEAPI StgIsStorageFile(OLECHAR *);
WINOLEAPI StgIsStorageILockBytes(ILockBytes * plkbyt);
WINOLEAPI StgSetTimes(OLECHAR *,FILETIME *,FILETIME *,FILETIME *);
WINOLEAPI  BindMoniker(LPMONIKER,DWORD,REFIID,LPVOID *);
WINOLEAPI  CoGetObject(LPCWSTR,BIND_OPTS *,REFIID,void **);
WINOLEAPI  MkParseDisplayName(LPBC,LPCOLESTR,ULONG  *,LPMONIKER  *);
WINOLEAPI  MonikerRelativePathTo(LPMONIKER,LPMONIKER,LPMONIKER *,BOOL);
WINOLEAPI  MonikerCommonPrefixWith(LPMONIKER,LPMONIKER,LPMONIKER *);
WINOLEAPI  CreateBindCtx(DWORD,LPBC *);
WINOLEAPI  CreateGenericComposite(LPMONIKER,LPMONIKER,LPMONIKER *);
WINOLEAPI  GetClassFile (LPCOLESTR,CLSID *);
WINOLEAPI  CreateClassMoniker(REFCLSID,LPMONIKER *);
WINOLEAPI  CreateFileMoniker(LPCOLESTR,LPMONIKER *);
WINOLEAPI  CreateItemMoniker(LPCOLESTR,LPCOLESTR,LPMONIKER *);
WINOLEAPI  CreateAntiMoniker(LPMONIKER *);
WINOLEAPI  CreatePointerMoniker(LPUNKNOWN,LPMONIKER *);
WINOLEAPI  GetRunningObjectTable(DWORD,LPRUNNINGOBJECTTABLE *);
#endif 
