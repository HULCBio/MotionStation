#ifndef __RPCBASE_H__
#include "rpcbase.h"
#endif 
#ifndef NORPC
#ifndef __RPC_H__
#include "rpc.h"
#endif 
#ifndef __RPCNDR_H__
#include "rpcndr.h"
#endif 
#endif 
#ifndef COM_NO_WINDOWS_H
#include "windows.h"
#ifndef __LCC_OLE2_H_
#include "ole2.h"
#endif 
#endif 
#ifndef __oleidl_h__
#define __oleidl_h__
#ifndef __IOleAdviseHolder_FWD_DEFINED__
#define __IOleAdviseHolder_FWD_DEFINED__
typedef interface IOleAdviseHolder IOleAdviseHolder;
#endif 	
#ifndef __IOleCache_FWD_DEFINED__
#define __IOleCache_FWD_DEFINED__
typedef interface IOleCache IOleCache;
#endif 	
#ifndef __IOleCache2_FWD_DEFINED__
#define __IOleCache2_FWD_DEFINED__
typedef interface IOleCache2 IOleCache2;
#endif 	
#ifndef __IOleCacheControl_FWD_DEFINED__
#define __IOleCacheControl_FWD_DEFINED__
typedef interface IOleCacheControl IOleCacheControl;
#endif 	
#ifndef __IParseDisplayName_FWD_DEFINED__
#define __IParseDisplayName_FWD_DEFINED__
typedef interface IParseDisplayName IParseDisplayName;
#endif 	
#ifndef __IOleContainer_FWD_DEFINED__
#define __IOleContainer_FWD_DEFINED__
typedef interface IOleContainer IOleContainer;
#endif 	
#ifndef __IOleClientSite_FWD_DEFINED__
#define __IOleClientSite_FWD_DEFINED__
typedef interface IOleClientSite IOleClientSite;
#endif 	
#ifndef __IOleObject_FWD_DEFINED__
#define __IOleObject_FWD_DEFINED__
typedef interface IOleObject IOleObject;
#endif 	
#ifndef __IOleWindow_FWD_DEFINED__
#define __IOleWindow_FWD_DEFINED__
typedef interface IOleWindow IOleWindow;
#endif 	
#ifndef __IOleLink_FWD_DEFINED__
#define __IOleLink_FWD_DEFINED__
typedef interface IOleLink IOleLink;
#endif 	
#ifndef __IOleItemContainer_FWD_DEFINED__
#define __IOleItemContainer_FWD_DEFINED__
typedef interface IOleItemContainer IOleItemContainer;
#endif 	
#ifndef __IOleInPlaceUIWindow_FWD_DEFINED__
#define __IOleInPlaceUIWindow_FWD_DEFINED__
typedef interface IOleInPlaceUIWindow IOleInPlaceUIWindow;
#endif 	
#ifndef __IOleInPlaceActiveObject_FWD_DEFINED__
#define __IOleInPlaceActiveObject_FWD_DEFINED__
typedef interface IOleInPlaceActiveObject IOleInPlaceActiveObject;
#endif 	
#ifndef __IOleInPlaceFrame_FWD_DEFINED__
#define __IOleInPlaceFrame_FWD_DEFINED__
typedef interface IOleInPlaceFrame IOleInPlaceFrame;
#endif 	
#ifndef __IOleInPlaceObject_FWD_DEFINED__
#define __IOleInPlaceObject_FWD_DEFINED__
typedef interface IOleInPlaceObject IOleInPlaceObject;
#endif 	
#ifndef __IOleInPlaceSite_FWD_DEFINED__
#define __IOleInPlaceSite_FWD_DEFINED__
typedef interface IOleInPlaceSite IOleInPlaceSite;
#endif 	
#ifndef __IViewObject_FWD_DEFINED__
#define __IViewObject_FWD_DEFINED__
typedef interface IViewObject IViewObject;
#endif 	
#ifndef __IViewObject2_FWD_DEFINED__
#define __IViewObject2_FWD_DEFINED__
typedef interface IViewObject2 IViewObject2;
#endif 	
#ifndef __IDropSource_FWD_DEFINED__
#define __IDropSource_FWD_DEFINED__
typedef interface IDropSource IDropSource;
#endif 	
#ifndef __IDropTarget_FWD_DEFINED__
#define __IDropTarget_FWD_DEFINED__
typedef interface IDropTarget IDropTarget;
#endif 	
#ifndef __IEnumOLEVERB_FWD_DEFINED__
#define __IEnumOLEVERB_FWD_DEFINED__
typedef interface IEnumOLEVERB IEnumOLEVERB;
#endif 	
#ifndef __objidl_h__
#include "objidl.h"
#endif 
#ifndef __MIDL_USER_ALLOCATE_DEFINED
#define __MIDL_USER_ALLOCATE_DEFINED
void * __RPC_USER MIDL_user_allocate(size_t);
void __RPC_USER MIDL_user_free(void *); 
#endif
#ifndef NOPROXYSTUB
extern RPC_IF_HANDLE __MIDL__intf_0000_v0_0_c_ifspec;
extern RPC_IF_HANDLE __MIDL__intf_0000_v0_0_s_ifspec;
#endif
#ifndef __IOleAdviseHolder_INTERFACE_DEFINED__
#define __IOleAdviseHolder_INTERFACE_DEFINED__
typedef IOleAdviseHolder *LPOLEADVISEHOLDER;
const IID IID_IOleAdviseHolder;
typedef struct IOleAdviseHolderVtbl {
	HRESULT (_stdcall *QueryInterface)(IOleAdviseHolder *,REFIID,void * *);
	ULONG (_stdcall *AddRef)(IOleAdviseHolder *);
	ULONG (_stdcall *Release)(IOleAdviseHolder *);
	HRESULT (_stdcall *Advise)(IOleAdviseHolder *,IAdviseSink *,DWORD *);
	HRESULT (_stdcall *Unadvise)(IOleAdviseHolder *,DWORD);
	HRESULT (_stdcall *EnumAdvise)(IOleAdviseHolder *,IEnumSTATDATA * *);
	HRESULT (_stdcall *SendOnRename)(IOleAdviseHolder *,IMoniker *);
	HRESULT (_stdcall *SendOnSave)(IOleAdviseHolder *);
	HRESULT (_stdcall *SendOnClose)(IOleAdviseHolder *);
} IOleAdviseHolderVtbl;
interface IOleAdviseHolder { CONST_VTBL struct IOleAdviseHolderVtbl *lpVtbl; };
#define IOleAdviseHolder_QueryInterface(This,riid,ppvObject)	 (This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IOleAdviseHolder_AddRef(This)	 (This)->lpVtbl->AddRef(This)
#define IOleAdviseHolder_Release(This)	 (This)->lpVtbl->Release(This)
#define IOleAdviseHolder_Advise(This,pAdvise,pdwConnection)	 (This)->lpVtbl->Advise(This,pAdvise,pdwConnection)
#define IOleAdviseHolder_Unadvise(This,dwConnection)	 (This)->lpVtbl->Unadvise(This,dwConnection)
#define IOleAdviseHolder_EnumAdvise(This,ppenumAdvise)	(This)->lpVtbl->EnumAdvise(This,ppenumAdvise)
#define IOleAdviseHolder_SendOnRename(This,pmk)	 (This)->lpVtbl->SendOnRename(This,pmk)
#define IOleAdviseHolder_SendOnSave(This)	 (This)->lpVtbl->SendOnSave(This)
#define IOleAdviseHolder_SendOnClose(This)	 (This)->lpVtbl->SendOnClose(This)
HRESULT _stdcall IOleAdviseHolder_Advise_Proxy(IOleAdviseHolder *,IAdviseSink *,DWORD *);
void __RPC_STUB IOleAdviseHolder_Advise_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleAdviseHolder_Unadvise_Proxy(IOleAdviseHolder * This,DWORD dwConnection);
void __RPC_STUB IOleAdviseHolder_Unadvise_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleAdviseHolder_EnumAdvise_Proxy(IOleAdviseHolder *,IEnumSTATDATA * *);
void __RPC_STUB IOleAdviseHolder_EnumAdvise_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleAdviseHolder_SendOnRename_Proxy(IOleAdviseHolder * This,IMoniker *pmk);
void __RPC_STUB IOleAdviseHolder_SendOnRename_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleAdviseHolder_SendOnSave_Proxy(IOleAdviseHolder *);
void __RPC_STUB IOleAdviseHolder_SendOnSave_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleAdviseHolder_SendOnClose_Proxy(IOleAdviseHolder *);
void __RPC_STUB IOleAdviseHolder_SendOnClose_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
#endif 	
#ifndef __IOleCache_INTERFACE_DEFINED__
#define __IOleCache_INTERFACE_DEFINED__
typedef IOleCache *LPOLECACHE;
const IID IID_IOleCache;
typedef struct IOleCacheVtbl {
	HRESULT (_stdcall *QueryInterface)(IOleCache *,REFIID,void * *);
	ULONG (_stdcall *AddRef)(IOleCache *);
	ULONG (_stdcall *Release)(IOleCache *);
	HRESULT (_stdcall *Cache)(IOleCache *,FORMATETC *,DWORD,DWORD *);
	HRESULT (_stdcall *Uncache)(IOleCache *,DWORD);
	HRESULT (_stdcall *EnumCache)(IOleCache *,IEnumSTATDATA * *);
	HRESULT (_stdcall *InitCache)(IOleCache *,IDataObject *);
	HRESULT (_stdcall *SetData)(IOleCache *,FORMATETC *,STGMEDIUM *,BOOL);
} IOleCacheVtbl;
interface IOleCache { CONST_VTBL struct IOleCacheVtbl *lpVtbl; };
#define IOleCache_QueryInterface(This,riid,ppvObject)	 (This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IOleCache_AddRef(This)	 (This)->lpVtbl->AddRef(This)
#define IOleCache_Release(This)	 (This)->lpVtbl->Release(This)
#define IOleCache_Cache(This,pformatetc,advf,pdwConnection)	 (This)->lpVtbl->Cache(This,pformatetc,advf,pdwConnection)
#define IOleCache_Uncache(This,dwConnection)	(This)->lpVtbl->Uncache(This,dwConnection)
#define IOleCache_EnumCache(This,ppenumSTATDATA) (This)->lpVtbl->EnumCache(This,ppenumSTATDATA)
#define IOleCache_InitCache(This,pDataObject)	 (This)->lpVtbl->InitCache(This,pDataObject)
#define IOleCache_SetData(This,pformatetc,pmedium,fRelease)	 (This)->lpVtbl->SetData(This,pformatetc,pmedium,fRelease)
HRESULT _stdcall IOleCache_Cache_Proxy(IOleCache *,FORMATETC *,DWORD,DWORD *);
void __RPC_STUB IOleCache_Cache_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleCache_Uncache_Proxy(IOleCache *,DWORD);
void __RPC_STUB IOleCache_Uncache_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleCache_EnumCache_Proxy(IOleCache *,IEnumSTATDATA * *);
void __RPC_STUB IOleCache_EnumCache_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleCache_InitCache_Proxy(IOleCache *,IDataObject *);
void __RPC_STUB IOleCache_InitCache_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleCache_SetData_Proxy(IOleCache *,FORMATETC *,STGMEDIUM *,BOOL);
void __RPC_STUB IOleCache_SetData_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
#endif 	
#ifndef __IOleCache2_INTERFACE_DEFINED__
#define __IOleCache2_INTERFACE_DEFINED__
typedef IOleCache2 *LPOLECACHE2;
#define	UPDFCACHE_NODATACACHE	1
#define	UPDFCACHE_ONSAVECACHE	2
#define	UPDFCACHE_ONSTOPCACHE	4
#define	UPDFCACHE_NORMALCACHE	8
#define	UPDFCACHE_IFBLANK	16
#define	UPDFCACHE_ONLYIFBLANK	0x80000000
#define	UPDFCACHE_IFBLANKORONSAVECACHE	(UPDFCACHE_IFBLANK | UPDFCACHE_ONSAVECACHE)
#define	UPDFCACHE_ALL	((DWORD)~UPDFCACHE_ONLYIFBLANK)
#define	UPDFCACHE_ALLBUTNODATACACHE	(UPDFCACHE_ALL & (DWORD)~UPDFCACHE_NODATACACHE)
typedef enum tagDISCARDCACHE
	{	DISCARDCACHE_SAVEIFDIRTY	= 0,
	DISCARDCACHE_NOSAVE	= 1
	}	DISCARDCACHE;

#define DISCARDCACHE_to_xmit(pEnum,ppLong) *(ppLong) = (long *) (pEnum)
#define DISCARDCACHE_from_xmit(pLong,pEnum) *(pEnum) = (DISCARDCACHE) *(pLong)
#define DISCARDCACHE_free_inst(pEnum) 
#define DISCARDCACHE_free_xmit(pLong) 
const IID IID_IOleCache2;
typedef struct IOleCache2Vtbl {
	HRESULT (_stdcall *QueryInterface)(IOleCache2 *,REFIID,void * *);
	ULONG (_stdcall *AddRef)(IOleCache2 *);
	ULONG (_stdcall *Release)(IOleCache2 *);
	HRESULT (_stdcall *Cache)(IOleCache2 *,FORMATETC *,DWORD,DWORD *);
	HRESULT (_stdcall *Uncache)(IOleCache2 *,DWORD);
	HRESULT (_stdcall *EnumCache)(IOleCache2 *,IEnumSTATDATA * *);
	HRESULT (_stdcall *InitCache)(IOleCache2 *,IDataObject *);
	HRESULT (_stdcall *SetData)(IOleCache2 *,FORMATETC *,STGMEDIUM *,BOOL);
	HRESULT (_stdcall *UpdateCache)(IOleCache2 *,LPDATAOBJECT,DWORD,LPVOID);
	HRESULT (_stdcall *DiscardCache)(IOleCache2 *,DWORD);
	} IOleCache2Vtbl;
interface IOleCache2 { CONST_VTBL struct IOleCache2Vtbl *lpVtbl; };
#define IOleCache2_QueryInterface(This,riid,ppvObject)	 (This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IOleCache2_AddRef(This)	 (This)->lpVtbl->AddRef(This)
#define IOleCache2_Release(This) (This)->lpVtbl->Release(This)
#define IOleCache2_Cache(This,pformatetc,advf,pdwConnection) (This)->lpVtbl->Cache(This,pformatetc,advf,pdwConnection)
#define IOleCache2_Uncache(This,dwConnection) (This)->lpVtbl->Uncache(This,dwConnection)
#define IOleCache2_EnumCache(This,ppenumSTATDATA) (This)->lpVtbl->EnumCache(This,ppenumSTATDATA)
#define IOleCache2_InitCache(This,pDataObject)	 (This)->lpVtbl->InitCache(This,pDataObject)
#define IOleCache2_SetData(This,pformatetc,pmedium,fRelease) (This)->lpVtbl->SetData(This,pformatetc,pmedium,fRelease)
#define IOleCache2_UpdateCache(This,pDataObject,grfUpdf,pReserved) (This)->lpVtbl->UpdateCache(This,pDataObject,grfUpdf,pReserved)
#define IOleCache2_DiscardCache(This,dwDiscardOptions)	 (This)->lpVtbl->DiscardCache(This,dwDiscardOptions)
HRESULT _stdcall IOleCache2_UpdateCache_Proxy(IOleCache2 *,LPDATAOBJECT,DWORD,LPVOID);
void __RPC_STUB IOleCache2_UpdateCache_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleCache2_DiscardCache_Proxy(IOleCache2 *,DWORD);
void __RPC_STUB IOleCache2_DiscardCache_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
#endif 	
#ifndef __IOleCacheControl_INTERFACE_DEFINED__
#define __IOleCacheControl_INTERFACE_DEFINED__
typedef IOleCacheControl *LPOLECACHECONTROL;
const IID IID_IOleCacheControl;
typedef struct IOleCacheControlVtbl {
	HRESULT (_stdcall *QueryInterface)(IOleCacheControl *,REFIID,void * *);
	ULONG (_stdcall *AddRef)(IOleCacheControl *); 
	ULONG (_stdcall *Release)(IOleCacheControl *);
	HRESULT (_stdcall *OnRun)(IOleCacheControl * s,LPDATAOBJECT);
	HRESULT (_stdcall *OnStop)(IOleCacheControl *);
} IOleCacheControlVtbl;
interface IOleCacheControl { CONST_VTBL struct IOleCacheControlVtbl *lpVtbl; };
#define IOleCacheControl_QueryInterface(This,riid,ppvObject) (This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IOleCacheControl_AddRef(This) (This)->lpVtbl->AddRef(This)
#define IOleCacheControl_Release(This)	 (This)->lpVtbl->Release(This)
#define IOleCacheControl_OnRun(This,pDataObject) (This)->lpVtbl->OnRun(This,pDataObject)
#define IOleCacheControl_OnStop(This)	 (This)->lpVtbl->OnStop(This)
HRESULT _stdcall IOleCacheControl_OnRun_Proxy(IOleCacheControl *,LPDATAOBJECT);
void __RPC_STUB IOleCacheControl_OnRun_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleCacheControl_OnStop_Proxy(IOleCacheControl *);
void __RPC_STUB IOleCacheControl_OnStop_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
#endif 	
#ifndef __IParseDisplayName_INTERFACE_DEFINED__
#define __IParseDisplayName_INTERFACE_DEFINED__
typedef IParseDisplayName *LPPARSEDISPLAYNAME;
const IID IID_IParseDisplayName;
typedef struct IParseDisplayNameVtbl {
	HRESULT (_stdcall *QueryInterface)(IParseDisplayName *,REFIID,void * *);
	ULONG (_stdcall *AddRef)(
	IParseDisplayName * This);
	ULONG (_stdcall *Release)(IParseDisplayName * This);
	HRESULT (_stdcall *ParseDisplayName)(
	IParseDisplayName * This,
	IBindCtx *pbc,
	LPOLESTR pszDisplayName,
	ULONG *pchEaten,
	IMoniker * *ppmkOut);
} IParseDisplayNameVtbl;
interface IParseDisplayName { CONST_VTBL struct IParseDisplayNameVtbl *lpVtbl; };
#define IParseDisplayName_QueryInterface(This,riid,ppvObject)	 (This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IParseDisplayName_AddRef(This)	 (This)->lpVtbl->AddRef(This)
#define IParseDisplayName_Release(This)	 (This)->lpVtbl->Release(This)
#define IParseDisplayName_ParseDisplayName(This,pbc,pszDisplayName,pchEaten,ppmkOut) (This)->lpVtbl->ParseDisplayName(This,pbc,pszDisplayName,pchEaten,ppmkOut)
HRESULT _stdcall IParseDisplayName_ParseDisplayName_Proxy(IParseDisplayName *,IBindCtx *,LPOLESTR,ULONG *,IMoniker * *);
void __RPC_STUB IParseDisplayName_ParseDisplayName_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
#endif 	
#ifndef __IOleContainer_INTERFACE_DEFINED__
#define __IOleContainer_INTERFACE_DEFINED__
typedef IOleContainer *LPOLECONTAINER;
const IID IID_IOleContainer; 
typedef struct IOleContainerVtbl {
	HRESULT (_stdcall *QueryInterface)(IOleContainer *,REFIID,void * *);
	ULONG (_stdcall *AddRef)(IOleContainer *);
	ULONG (_stdcall *Release)(IOleContainer *);
	HRESULT (_stdcall *ParseDisplayName)(IOleContainer *,IBindCtx *,LPOLESTR,ULONG *,IMoniker * *);
	HRESULT (_stdcall *EnumObjects)(IOleContainer *,DWORD,IEnumUnknown * *);
	HRESULT (_stdcall *LockContainer)(IOleContainer *,BOOL);
} IOleContainerVtbl;
interface IOleContainer { CONST_VTBL struct IOleContainerVtbl *lpVtbl; };
#define IOleContainer_QueryInterface(This,riid,ppvObject) (This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IOleContainer_AddRef(This) (This)->lpVtbl->AddRef(This)
#define IOleContainer_Release(This) (This)->lpVtbl->Release(This)
#define IOleContainer_ParseDisplayName(This,pbc,pszDisplayName,pchEaten,ppmkOut) (This)->lpVtbl->ParseDisplayName(This,pbc,pszDisplayName,pchEaten,ppmkOut)
#define IOleContainer_EnumObjects(This,grfFlags,ppenum)	 (This)->lpVtbl->EnumObjects(This,grfFlags,ppenum)
#define IOleContainer_LockContainer(This,fLock)	 (This)->lpVtbl->LockContainer(This,fLock)
HRESULT _stdcall IOleContainer_EnumObjects_Proxy(IOleContainer *,DWORD,IEnumUnknown * *);
void __RPC_STUB IOleContainer_EnumObjects_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleContainer_LockContainer_Proxy(IOleContainer *,BOOL);
void __RPC_STUB IOleContainer_LockContainer_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
#endif 	
#ifndef __IOleClientSite_INTERFACE_DEFINED__
#define __IOleClientSite_INTERFACE_DEFINED__
typedef IOleClientSite *LPOLECLIENTSITE;
const IID IID_IOleClientSite;
typedef struct IOleClientSiteVtbl {
	HRESULT (_stdcall *QueryInterface)(IOleClientSite *,REFIID,void * *);
	ULONG (_stdcall *AddRef)(IOleClientSite *);
	ULONG (_stdcall *Release)(IOleClientSite *);
	HRESULT (_stdcall *SaveObject)(IOleClientSite *);
	HRESULT (_stdcall *GetMoniker)(IOleClientSite *,DWORD,DWORD,IMoniker * *);
	HRESULT (_stdcall *GetContainer)(IOleClientSite *,IOleContainer * *);
	HRESULT (_stdcall *ShowObject)(IOleClientSite *);
	HRESULT (_stdcall *OnShowWindow)(IOleClientSite *,BOOL);
	HRESULT (_stdcall *RequestNewObjectLayout)(IOleClientSite *);
} IOleClientSiteVtbl;
interface IOleClientSite { CONST_VTBL struct IOleClientSiteVtbl *lpVtbl; };
#define IOleClientSite_QueryInterface(This,riid,ppvObject) (This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IOleClientSite_AddRef(This) (This)->lpVtbl->AddRef(This)
#define IOleClientSite_Release(This)	 (This)->lpVtbl->Release(This)
#define IOleClientSite_SaveObject(This)	 (This)->lpVtbl->SaveObject(This)
#define IOleClientSite_GetMoniker(This,dwAssign,dwWhichMoniker,ppmk) (This)->lpVtbl->GetMoniker(This,dwAssign,dwWhichMoniker,ppmk)
#define IOleClientSite_GetContainer(This,ppContainer)	 (This)->lpVtbl->GetContainer(This,ppContainer)
#define IOleClientSite_ShowObject(This)	 (This)->lpVtbl->ShowObject(This)
#define IOleClientSite_OnShowWindow(This,fShow)	 (This)->lpVtbl->OnShowWindow(This,fShow)
#define IOleClientSite_RequestNewObjectLayout(This) (This)->lpVtbl->RequestNewObjectLayout(This)
HRESULT _stdcall IOleClientSite_SaveObject_Proxy(IOleClientSite *);
void __RPC_STUB IOleClientSite_SaveObject_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleClientSite_GetMoniker_Proxy(IOleClientSite *,DWORD,DWORD,IMoniker * *);
void __RPC_STUB IOleClientSite_GetMoniker_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleClientSite_GetContainer_Proxy(IOleClientSite *,IOleContainer * *);
void __RPC_STUB IOleClientSite_GetContainer_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleClientSite_ShowObject_Proxy(IOleClientSite *);
void __RPC_STUB IOleClientSite_ShowObject_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleClientSite_OnShowWindow_Proxy(IOleClientSite *,BOOL);
void __RPC_STUB IOleClientSite_OnShowWindow_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleClientSite_RequestNewObjectLayout_Proxy(IOleClientSite *);
void __RPC_STUB IOleClientSite_RequestNewObjectLayout_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
#endif 	
#ifndef __IOleObject_INTERFACE_DEFINED__
#define __IOleObject_INTERFACE_DEFINED__
typedef IOleObject *LPOLEOBJECT;
typedef enum tagOLEGETMONIKER
	{	OLEGETMONIKER_ONLYIFTHERE	= 1,
	OLEGETMONIKER_FORCEASSIGN	= 2,
	OLEGETMONIKER_UNASSIGN	= 3,
	OLEGETMONIKER_TEMPFORUSER	= 4
	}	OLEGETMONIKER;
typedef enum tagOLEWHICHMK
	{	OLEWHICHMK_CONTAINER	= 1,
	OLEWHICHMK_OBJREL	= 2,
	OLEWHICHMK_OBJFULL	= 3
	}	OLEWHICHMK;
typedef enum tagUSERCLASSTYPE {
	USERCLASSTYPE_FULL	= 1,
	USERCLASSTYPE_SHORT	= 2,
	USERCLASSTYPE_APPNAME	= 3
	}	USERCLASSTYPE;
typedef enum tagOLEMISC {
	OLEMISC_RECOMPOSEONRESIZE	= 1,
	OLEMISC_ONLYICONIC	= 2,
	OLEMISC_INSERTNOTREPLACE	= 4,
	OLEMISC_STATIC	= 8,
	OLEMISC_CANTLINKINSIDE	= 16,
	OLEMISC_CANLINKBYOLE1	= 32,
	OLEMISC_ISLINKOBJECT	= 64,
	OLEMISC_INSIDEOUT	= 128,
	OLEMISC_ACTIVATEWHENVISIBLE	= 256,
	OLEMISC_RENDERINGISDEVICEINDEPENDENT	= 512
	}	OLEMISC;
typedef enum tagOLECLOSE
	{	OLECLOSE_SAVEIFDIRTY	= 0,
	OLECLOSE_NOSAVE	= 1,
	OLECLOSE_PROMPTSAVE	= 2
	}	OLECLOSE;
const IID IID_IOleObject;
typedef struct IOleObjectVtbl {
	HRESULT (_stdcall *QueryInterface)(IOleObject *,REFIID,void * *);
	ULONG (_stdcall *AddRef)(IOleObject *);
	ULONG (_stdcall *Release)(IOleObject *);
	HRESULT (_stdcall *SetClientSite)(IOleObject *,IOleClientSite *);
	HRESULT (_stdcall *GetClientSite)(IOleObject *,IOleClientSite * *);
	HRESULT (_stdcall *SetHostNames)(IOleObject *,LPCOLESTR,LPCOLESTR);
	HRESULT (_stdcall *Close)(IOleObject *,DWORD);
	HRESULT (_stdcall *SetMoniker)(IOleObject *,DWORD,IMoniker *);
	HRESULT (_stdcall *GetMoniker)(IOleObject *,DWORD,DWORD,IMoniker * *);
	HRESULT (_stdcall *InitFromData)(IOleObject *,IDataObject *,BOOL,DWORD);
	HRESULT (_stdcall *GetClipboardData)(IOleObject *,DWORD,IDataObject * *);
	HRESULT (_stdcall *DoVerb)(IOleObject *,LONG,LPMSG,IOleClientSite *,LONG,HWND,LPCRECT);
	HRESULT (_stdcall *EnumVerbs)(IOleObject *,IEnumOLEVERB * *);
	HRESULT (_stdcall *Update)(IOleObject *);
	HRESULT (_stdcall *IsUpToDate)(IOleObject *);
	HRESULT (_stdcall *GetUserClassID)(IOleObject *,CLSID *);
	HRESULT (_stdcall *GetUserType)(IOleObject *,DWORD,LPOLESTR *);
	HRESULT (_stdcall *SetExtent)(IOleObject *,DWORD,SIZEL *); 
	HRESULT (_stdcall *GetExtent)(IOleObject *,DWORD,SIZEL *);
	HRESULT (_stdcall *Advise)(IOleObject *,IAdviseSink *,DWORD *);
	HRESULT (_stdcall *Unadvise)(IOleObject *,DWORD);
	HRESULT (_stdcall *EnumAdvise)(IOleObject *,IEnumSTATDATA * *);
	HRESULT (_stdcall *GetMiscStatus)(IOleObject *,DWORD,DWORD *);
	HRESULT (_stdcall *SetColorScheme)(IOleObject *,LOGPALETTE *);
} IOleObjectVtbl;
interface IOleObject { CONST_VTBL struct IOleObjectVtbl *lpVtbl; };
#define IOleObject_QueryInterface(This,riid,ppvObject)	 (This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IOleObject_AddRef(This)	 (This)->lpVtbl->AddRef(This)
#define IOleObject_Release(T) (T)->lpVtbl->Release(T)
#define IOleObject_SetClientSite(This,pClientSite) (This)->lpVtbl->SetClientSite(This,pClientSite)
#define IOleObject_GetClientSite(This,ppClientSite) (This)->lpVtbl->GetClientSite(This,ppClientSite)
#define IOleObject_SetHostNames(This,szContainerApp,szContainerObj) (This)->lpVtbl->SetHostNames(This,szContainerApp,szContainerObj)
#define IOleObject_Close(This,dwSaveOption) (This)->lpVtbl->Close(This,dwSaveOption)
#define IOleObject_SetMoniker(This,dwWhichMoniker,pmk)	 (This)->lpVtbl->SetMoniker(This,dwWhichMoniker,pmk)
#define IOleObject_GetMoniker(This,dwAssign,dwWhichMoniker,ppmk) (This)->lpVtbl->GetMoniker(This,dwAssign,dwWhichMoniker,ppmk)
#define IOleObject_InitFromData(This,pDataObject,fCreation,dwReserved)	 (This)->lpVtbl->InitFromData(This,pDataObject,fCreation,dwReserved)
#define IOleObject_GetClipboardData(This,dwReserved,ppDataObject) (This)->lpVtbl->GetClipboardData(This,dwReserved,ppDataObject)
#define IOleObject_DoVerb(This,iVerb,lpmsg,pActiveSite,lindex,hwndParent,lprcPosRect) (This)->lpVtbl->DoVerb(This,iVerb,lpmsg,pActiveSite,lindex,hwndParent,lprcPosRect)
#define IOleObject_EnumVerbs(This,ppEnumOleVerb) (This)->lpVtbl->EnumVerbs(This,ppEnumOleVerb)
#define IOleObject_Update(This)	 (This)->lpVtbl->Update(This)
#define IOleObject_IsUpToDate(This) (This)->lpVtbl->IsUpToDate(This)
#define IOleObject_GetUserClassID(This,pClsid)	 (This)->lpVtbl->GetUserClassID(This,pClsid)
#define IOleObject_GetUserType(This,dwFormOfType,pszUserType) (This)->lpVtbl->GetUserType(This,dwFormOfType,pszUserType)
#define IOleObject_SetExtent(This,dwDrawAspect,psizel)	 (This)->lpVtbl->SetExtent(This,dwDrawAspect,psizel)
#define IOleObject_GetExtent(This,dwDrawAspect,psizel)	 (This)->lpVtbl->GetExtent(This,dwDrawAspect,psizel)
#define IOleObject_Advise(This,pAdvSink,pdwConnection)	 (This)->lpVtbl->Advise(This,pAdvSink,pdwConnection)
#define IOleObject_Unadvise(This,dwConnection)	 (This)->lpVtbl->Unadvise(This,dwConnection)
#define IOleObject_EnumAdvise(This,ppenumAdvise) (This)->lpVtbl->EnumAdvise(This,ppenumAdvise)
#define IOleObject_GetMiscStatus(This,dwAspect,pdwStatus) (This)->lpVtbl->GetMiscStatus(This,dwAspect,pdwStatus)
#define IOleObject_SetColorScheme(This,pLogpal)	 (This)->lpVtbl->SetColorScheme(This,pLogpal)
HRESULT _stdcall IOleObject_SetClientSite_Proxy(IOleObject *,IOleClientSite *);
void __RPC_STUB IOleObject_SetClientSite_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleObject_GetClientSite_Proxy(IOleObject *,IOleClientSite * *);
void __RPC_STUB IOleObject_GetClientSite_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleObject_SetHostNames_Proxy(IOleObject *,LPCOLESTR,LPCOLESTR);
void __RPC_STUB IOleObject_SetHostNames_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleObject_Close_Proxy(IOleObject *,DWORD);
void __RPC_STUB IOleObject_Close_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleObject_SetMoniker_Proxy(IOleObject *,DWORD,IMoniker *);
void __RPC_STUB IOleObject_SetMoniker_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleObject_GetMoniker_Proxy(IOleObject *,DWORD,DWORD,IMoniker * *);
void __RPC_STUB IOleObject_GetMoniker_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleObject_InitFromData_Proxy(IOleObject *,IDataObject *,BOOL,DWORD);
void __RPC_STUB IOleObject_InitFromData_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleObject_GetClipboardData_Proxy(IOleObject *,DWORD,IDataObject * *);
void __RPC_STUB IOleObject_GetClipboardData_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleObject_DoVerb_Proxy(IOleObject *,LONG,LPMSG,IOleClientSite *,LONG,HWND,LPCRECT);
void __RPC_STUB IOleObject_DoVerb_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleObject_EnumVerbs_Proxy(IOleObject *,IEnumOLEVERB * *);
void __RPC_STUB IOleObject_EnumVerbs_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleObject_Update_Proxy(IOleObject *);
void __RPC_STUB IOleObject_Update_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleObject_IsUpToDate_Proxy(IOleObject *);
void __RPC_STUB IOleObject_IsUpToDate_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleObject_GetUserClassID_Proxy(IOleObject *,CLSID *);
void __RPC_STUB IOleObject_GetUserClassID_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleObject_GetUserType_Proxy(IOleObject *,DWORD,LPOLESTR *);
void __RPC_STUB IOleObject_GetUserType_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleObject_SetExtent_Proxy(IOleObject *,DWORD,SIZEL *);
void __RPC_STUB IOleObject_SetExtent_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleObject_GetExtent_Proxy(IOleObject *,DWORD,SIZEL *);
void __RPC_STUB IOleObject_GetExtent_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *); 
HRESULT _stdcall IOleObject_Advise_Proxy(IOleObject *,IAdviseSink *,DWORD *);
void __RPC_STUB IOleObject_Advise_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleObject_Unadvise_Proxy(IOleObject *,DWORD);
void __RPC_STUB IOleObject_Unadvise_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleObject_EnumAdvise_Proxy(IOleObject *,IEnumSTATDATA * *);
void __RPC_STUB IOleObject_EnumAdvise_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleObject_GetMiscStatus_Proxy(IOleObject *,DWORD,DWORD *);
void __RPC_STUB IOleObject_GetMiscStatus_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleObject_SetColorScheme_Proxy(IOleObject *,LOGPALETTE *);
void __RPC_STUB IOleObject_SetColorScheme_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
#endif 	
#ifndef __IOLETypes_INTERFACE_DEFINED__
#define __IOLETypes_INTERFACE_DEFINED__
typedef enum tagOLERENDER
	{	OLERENDER_NONE	= 0,
	OLERENDER_DRAW	= 1,
	OLERENDER_FORMAT	= 2,
	OLERENDER_ASIS	= 3
	}	OLERENDER;
typedef OLERENDER *LPOLERENDER;
typedef struct tagOBJECTDESCRIPTOR {
	ULONG cbSize;
	CLSID clsid;
	DWORD dwDrawAspect;
	SIZEL sizel;
	POINTL pointl;
	DWORD dwStatus;
	DWORD dwFullUserTypeName;
	DWORD dwSrcOfCopy;
	}	OBJECTDESCRIPTOR;
typedef struct tagOBJECTDESCRIPTOR *POBJECTDESCRIPTOR;
typedef struct tagOBJECTDESCRIPTOR *LPOBJECTDESCRIPTOR;
typedef struct tagOBJECTDESCRIPTOR LINKSRCDESCRIPTOR;
typedef struct tagOBJECTDESCRIPTOR *PLINKSRCDESCRIPTOR;
typedef struct tagOBJECTDESCRIPTOR *LPLINKSRCDESCRIPTOR;
extern RPC_IF_HANDLE IOLETypes_v0_0_c_ifspec;
extern RPC_IF_HANDLE IOLETypes_v0_0_s_ifspec;
#endif 

#ifndef __IOleWindow_INTERFACE_DEFINED__
#define __IOleWindow_INTERFACE_DEFINED__
typedef IOleWindow *LPOLEWINDOW;
const IID IID_IOleWindow;
typedef struct IOleWindowVtbl {
	HRESULT (_stdcall *QueryInterface)(IOleWindow *,REFIID,void * *);
	ULONG (_stdcall *AddRef)(IOleWindow *);
	ULONG (_stdcall *Release)(IOleWindow *);
	HRESULT (_stdcall *GetWindow)(IOleWindow *,HWND *);
	HRESULT (_stdcall *ContextSensitiveHelp)(IOleWindow *,BOOL);
} IOleWindowVtbl;
interface IOleWindow { CONST_VTBL struct IOleWindowVtbl *lpVtbl; };
#define IOleWindow_QueryInterface(This,riid,ppvObject)	 (This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IOleWindow_AddRef(This)	 (This)->lpVtbl->AddRef(This)
#define IOleWindow_Release(This)	 (This)->lpVtbl->Release(This)
#define IOleWindow_GetWindow(This,phwnd) (This)->lpVtbl->GetWindow(This,phwnd)
#define IOleWindow_ContextSensitiveHelp(This,fEnterMode) (This)->lpVtbl->ContextSensitiveHelp(This,fEnterMode)
HRESULT _stdcall IOleWindow_GetWindow_Proxy(IOleWindow *,HWND *);
void __RPC_STUB IOleWindow_GetWindow_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleWindow_ContextSensitiveHelp_Proxy(IOleWindow *,BOOL);
void __RPC_STUB IOleWindow_ContextSensitiveHelp_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
#endif 	
#ifndef __IOleLink_INTERFACE_DEFINED__
#define __IOleLink_INTERFACE_DEFINED__
typedef IOleLink *LPOLELINK;
typedef enum tagOLEUPDATE
	{	OLEUPDATE_ALWAYS	= 1,
	OLEUPDATE_ONCALL	= 3
	}	OLEUPDATE;
typedef OLEUPDATE *LPOLEUPDATE;
typedef OLEUPDATE *POLEUPDATE;
typedef enum tagOLELINKBIND
	{	OLELINKBIND_EVENIFCLASSDIFF	= 1
	}	OLELINKBIND;
const IID IID_IOleLink;
typedef struct IOleLinkVtbl {
	HRESULT (_stdcall *QueryInterface)(IOleLink *,REFIID,void * *);
	ULONG (_stdcall *AddRef)(IOleLink *);
	ULONG (_stdcall *Release)(IOleLink *);
	HRESULT (_stdcall *SetUpdateOptions)(IOleLink *,DWORD);
	HRESULT (_stdcall *GetUpdateOptions)(IOleLink *,DWORD *);
	HRESULT (_stdcall *SetSourceMoniker)(IOleLink *,IMoniker *,REFCLSID);
	HRESULT (_stdcall *GetSourceMoniker)(IOleLink *,IMoniker * *);
	HRESULT (_stdcall *SetSourceDisplayName)(IOleLink *,LPCOLESTR);
	HRESULT (_stdcall *GetSourceDisplayName)(IOleLink *,LPOLESTR *);
	HRESULT (_stdcall *BindToSource)(IOleLink *,DWORD,IBindCtx *);
	HRESULT (_stdcall *BindIfRunning)(IOleLink *);
	HRESULT (_stdcall *GetBoundSource)(IOleLink *,IUnknown * *);
	HRESULT (_stdcall *UnbindSource)(IOleLink *);
	HRESULT (_stdcall *Update)(IOleLink *,IBindCtx *);
} IOleLinkVtbl;
interface IOleLink { CONST_VTBL struct IOleLinkVtbl *lpVtbl; };
#define IOleLink_QueryInterface(This,riid,ppvObject)(This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IOleLink_AddRef(This)	 (This)->lpVtbl->AddRef(This)
#define IOleLink_Release(This)	 (This)->lpVtbl->Release(This)
#define IOleLink_SetUpdateOptions(This,dwUpdateOpt) (This)->lpVtbl->SetUpdateOptions(This,dwUpdateOpt)
#define IOleLink_GetUpdateOptions(This,pdwUpdateOpt)	 (This)->lpVtbl->GetUpdateOptions(This,pdwUpdateOpt)
#define IOleLink_SetSourceMoniker(This,pmk,rclsid)	 (This)->lpVtbl->SetSourceMoniker(This,pmk,rclsid)
#define IOleLink_GetSourceMoniker(This,ppmk)	 (This)->lpVtbl->GetSourceMoniker(This,ppmk)
#define IOleLink_SetSourceDisplayName(This,pszStatusText) (This)->lpVtbl->SetSourceDisplayName(This,pszStatusText)
#define IOleLink_GetSourceDisplayName(This,ppszDisplayName) (This)->lpVtbl->GetSourceDisplayName(This,ppszDisplayName)
#define IOleLink_BindToSource(This,bindflags,pbc) (This)->lpVtbl->BindToSource(This,bindflags,pbc)
#define IOleLink_BindIfRunning(This) (This)->lpVtbl->BindIfRunning(This)
#define IOleLink_GetBoundSource(This,ppunk) (This)->lpVtbl->GetBoundSource(This,ppunk)
#define IOleLink_UnbindSource(This)	 (This)->lpVtbl->UnbindSource(This)
#define IOleLink_Update(This,pbc) (This)->lpVtbl->Update(This,pbc)
HRESULT _stdcall IOleLink_SetUpdateOptions_Proxy(IOleLink *,DWORD);
void __RPC_STUB IOleLink_SetUpdateOptions_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleLink_GetUpdateOptions_Proxy(IOleLink *,DWORD *);
void __RPC_STUB IOleLink_GetUpdateOptions_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleLink_SetSourceMoniker_Proxy(IOleLink *,IMoniker *,REFCLSID);
void __RPC_STUB IOleLink_SetSourceMoniker_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleLink_GetSourceMoniker_Proxy(IOleLink *,IMoniker * *);
void __RPC_STUB IOleLink_GetSourceMoniker_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleLink_SetSourceDisplayName_Proxy(IOleLink *,LPCOLESTR);
void __RPC_STUB IOleLink_SetSourceDisplayName_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleLink_GetSourceDisplayName_Proxy(IOleLink *,LPOLESTR *);
void __RPC_STUB IOleLink_GetSourceDisplayName_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleLink_BindToSource_Proxy(IOleLink *,DWORD,IBindCtx *);
void __RPC_STUB IOleLink_BindToSource_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleLink_BindIfRunning_Proxy(IOleLink *);
void __RPC_STUB IOleLink_BindIfRunning_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleLink_GetBoundSource_Proxy(IOleLink *,IUnknown * *);
void __RPC_STUB IOleLink_GetBoundSource_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleLink_UnbindSource_Proxy(IOleLink *);
void __RPC_STUB IOleLink_UnbindSource_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleLink_Update_Proxy(IOleLink *,IBindCtx *);
void __RPC_STUB IOleLink_Update_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
#endif 	
#ifndef __IOleItemContainer_INTERFACE_DEFINED__
#define __IOleItemContainer_INTERFACE_DEFINED__
typedef IOleItemContainer *LPOLEITEMCONTAINER;
typedef enum tagBINDSPEED {
	BINDSPEED_INDEFINITE	= 1,
	BINDSPEED_MODERATE	= 2,
	BINDSPEED_IMMEDIATE	= 3
	}	BINDSPEED;
typedef enum tagOLECONTF {
	OLECONTF_EMBEDDINGS	= 1,
	OLECONTF_LINKS	= 2,
	OLECONTF_OTHERS	= 4,
	OLECONTF_ONLYUSER	= 8,
	OLECONTF_ONLYIFRUNNING	= 16
	}	OLECONTF;
const IID IID_IOleItemContainer;
typedef struct IOleItemContainerVtbl {
	HRESULT (_stdcall *QueryInterface)(IOleItemContainer *,REFIID,void * *);
	ULONG (_stdcall *AddRef)(IOleItemContainer *);
	ULONG (_stdcall *Release)(IOleItemContainer *);
	HRESULT (_stdcall *ParseDisplayName)(IOleItemContainer *,IBindCtx *,LPOLESTR,ULONG *,IMoniker * *);
	HRESULT (_stdcall *EnumObjects)(IOleItemContainer *,DWORD,IEnumUnknown * *);
	HRESULT (_stdcall *LockContainer)(IOleItemContainer *,BOOL);
	HRESULT (_stdcall *GetObject)(IOleItemContainer *,LPOLESTR,DWORD,IBindCtx *,REFIID,void * *);
	HRESULT (_stdcall *GetObjectStorage)(IOleItemContainer *,LPOLESTR,IBindCtx *,REFIID,void * *);
	HRESULT (_stdcall *IsRunning)(IOleItemContainer *,LPOLESTR);
} IOleItemContainerVtbl;
interface IOleItemContainer { CONST_VTBL struct IOleItemContainerVtbl *lpVtbl; };
#define IOleItemContainer_QueryInterface(This,riid,ppvObject)	 (This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IOleItemContainer_AddRef(This)	 (This)->lpVtbl->AddRef(This)
#define IOleItemContainer_Release(This)	 (This)->lpVtbl->Release(This)
#define IOleItemContainer_ParseDisplayName(This,pbc,pszDisplayName,pchEaten,ppmkOut)	 (This)->lpVtbl->ParseDisplayName(This,pbc,pszDisplayName,pchEaten,ppmkOut)
#define IOleItemContainer_EnumObjects(This,grfFlags,ppenum) (This)->lpVtbl->EnumObjects(This,grfFlags,ppenum)
#define IOleItemContainer_LockContainer(This,fLock)	 (This)->lpVtbl->LockContainer(This,fLock)
#define IOleItemContainer_GetObject(This,pszItem,dwSpeedNeeded,pbc,riid,ppvObject) (This)->lpVtbl->GetObject(This,pszItem,dwSpeedNeeded,pbc,riid,ppvObject)
#define IOleItemContainer_GetObjectStorage(This,pszItem,pbc,riid,ppvStorage)	 (This)->lpVtbl->GetObjectStorage(This,pszItem,pbc,riid,ppvStorage)
#define IOleItemContainer_IsRunning(This,pszItem)	 (This)->lpVtbl->IsRunning(This,pszItem)
HRESULT _stdcall IOleItemContainer_RemoteGetObject_Proxy(IOleItemContainer *,LPOLESTR,DWORD,IBindCtx *,REFIID,IUnknown * *);
void __RPC_STUB IOleItemContainer_RemoteGetObject_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleItemContainer_RemoteGetObjectStorage_Proxy(IOleItemContainer *,LPOLESTR,IBindCtx *,REFIID,IUnknown * *);
void __RPC_STUB IOleItemContainer_RemoteGetObjectStorage_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleItemContainer_IsRunning_Proxy(IOleItemContainer *,LPOLESTR);
void __RPC_STUB IOleItemContainer_IsRunning_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
#endif 	
#ifndef __IOleInPlaceUIWindow_INTERFACE_DEFINED__
#define __IOleInPlaceUIWindow_INTERFACE_DEFINED__
typedef IOleInPlaceUIWindow *LPOLEINPLACEUIWINDOW;
typedef RECT BORDERWIDTHS;
typedef LPRECT LPBORDERWIDTHS;
typedef LPCRECT LPCBORDERWIDTHS;
const IID IID_IOleInPlaceUIWindow;
typedef struct IOleInPlaceUIWindowVtbl {
	HRESULT (_stdcall *QueryInterface)(IOleInPlaceUIWindow *,REFIID,void * *);
	ULONG (_stdcall *AddRef)(IOleInPlaceUIWindow *);
	ULONG (_stdcall *Release)(IOleInPlaceUIWindow *);
	HRESULT (_stdcall *GetWindow)(IOleInPlaceUIWindow *,HWND *);
	HRESULT (_stdcall *ContextSensitiveHelp)(IOleInPlaceUIWindow *,BOOL);
	HRESULT (_stdcall *GetBorder)(IOleInPlaceUIWindow *,LPRECT);
	HRESULT (_stdcall *RequestBorderSpace)(IOleInPlaceUIWindow *,LPCBORDERWIDTHS);
	HRESULT (_stdcall *SetBorderSpace)(IOleInPlaceUIWindow *,LPCBORDERWIDTHS);
	HRESULT (_stdcall *SetActiveObject)(IOleInPlaceUIWindow *,IOleInPlaceActiveObject *,LPCOLESTR);
} IOleInPlaceUIWindowVtbl;
interface IOleInPlaceUIWindow { CONST_VTBL struct IOleInPlaceUIWindowVtbl *lpVtbl; };
#define IOleInPlaceUIWindow_QueryInterface(This,riid,pp) (This)->lpVtbl->QueryInterface(This,riid,pp)
#define IOleInPlaceUIWindow_AddRef(This) (This)->lpVtbl->AddRef(This)
#define IOleInPlaceUIWindow_Release(This) (This)->lpVtbl->Release(This)
#define IOleInPlaceUIWindow_GetWindow(This,phwnd) (This)->lpVtbl->GetWindow(This,phwnd)
#define IOleInPlaceUIWindow_ContextSensitiveHelp(This,f) (This)->lpVtbl->ContextSensitiveHelp(This,f)
#define IOleInPlaceUIWindow_GetBorder(This,l) (This)->lpVtbl->GetBorder(This,l)
#define IOleInPlaceUIWindow_RequestBorderSpace(This,p) (This)->lpVtbl->RequestBorderSpace(This,p)
#define IOleInPlaceUIWindow_SetBorderSpace(This,p) (This)->lpVtbl->SetBorderSpace(This,p)
#define IOleInPlaceUIWindow_SetActiveObject(This,pActiveObject,pszObjName) (This)->lpVtbl->SetActiveObject(This,pActiveObject,pszObjName)
HRESULT _stdcall IOleInPlaceUIWindow_GetBorder_Proxy(IOleInPlaceUIWindow *,LPRECT); 
void __RPC_STUB IOleInPlaceUIWindow_GetBorder_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleInPlaceUIWindow_RequestBorderSpace_Proxy(IOleInPlaceUIWindow *,LPCBORDERWIDTHS);
void __RPC_STUB IOleInPlaceUIWindow_RequestBorderSpace_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleInPlaceUIWindow_SetBorderSpace_Proxy(IOleInPlaceUIWindow *,LPCBORDERWIDTHS);
void __RPC_STUB IOleInPlaceUIWindow_SetBorderSpace_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleInPlaceUIWindow_SetActiveObject_Proxy(IOleInPlaceUIWindow *,IOleInPlaceActiveObject *,LPCOLESTR);
void __RPC_STUB IOleInPlaceUIWindow_SetActiveObject_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
#endif 	
#ifndef __IOleInPlaceActiveObject_INTERFACE_DEFINED__
#define __IOleInPlaceActiveObject_INTERFACE_DEFINED__
typedef IOleInPlaceActiveObject *LPOLEINPLACEACTIVEOBJECT;
const IID IID_IOleInPlaceActiveObject;
typedef struct IOleInPlaceActiveObjectVtbl {
	HRESULT (_stdcall *QueryInterface)(IOleInPlaceActiveObject *,REFIID,void * *);
	ULONG (_stdcall *AddRef)(IOleInPlaceActiveObject *); 
	ULONG (_stdcall *Release)(IOleInPlaceActiveObject *); 
	HRESULT (_stdcall *GetWindow)(IOleInPlaceActiveObject *,HWND *);
	HRESULT (_stdcall *ContextSensitiveHelp)(IOleInPlaceActiveObject *,BOOL);
	HRESULT (_stdcall *TranslateAccelerator)(IOleInPlaceActiveObject *,LPMSG);
	HRESULT (_stdcall *OnFrameWindowActivate)(IOleInPlaceActiveObject *,BOOL);
	HRESULT (_stdcall *OnDocWindowActivate)(IOleInPlaceActiveObject *,BOOL); 
	HRESULT (_stdcall *ResizeBorder)(IOleInPlaceActiveObject *,LPCRECT,IOleInPlaceUIWindow *,BOOL);
	HRESULT (_stdcall *EnableModeless)(IOleInPlaceActiveObject *,BOOL);
} IOleInPlaceActiveObjectVtbl;
interface IOleInPlaceActiveObject { CONST_VTBL struct IOleInPlaceActiveObjectVtbl *lpVtbl; };
#define IOleInPlaceActiveObject_QueryInterface(This,riid,ppvObject) (This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IOleInPlaceActiveObject_AddRef(This) (This)->lpVtbl->AddRef(This)
#define IOleInPlaceActiveObject_Release(This) (This)->lpVtbl->Release(This)
#define IOleInPlaceActiveObject_GetWindow(This,phwnd) (This)->lpVtbl->GetWindow(This,phwnd)
#define IOleInPlaceActiveObject_ContextSensitiveHelp(This,fEnterMode) (This)->lpVtbl->ContextSensitiveHelp(This,fEnterMode)
#define IOleInPlaceActiveObject_TranslateAccelerator(This,lpmsg) (This)->lpVtbl->TranslateAccelerator(This,lpmsg)
#define IOleInPlaceActiveObject_OnFrameWindowActivate(This,fActivate) (This)->lpVtbl->OnFrameWindowActivate(This,fActivate)
#define IOleInPlaceActiveObject_OnDocWindowActivate(This,fActivate) (This)->lpVtbl->OnDocWindowActivate(This,fActivate)
#define IOleInPlaceActiveObject_ResizeBorder(This,prcBorder,pUIWindow,fFrameWindow) (This)->lpVtbl->ResizeBorder(This,prcBorder,pUIWindow,fFrameWindow)
#define IOleInPlaceActiveObject_EnableModeless(This,fEnable) (This)->lpVtbl->EnableModeless(This,fEnable)
HRESULT _stdcall IOleInPlaceActiveObject_RemoteTranslateAccelerator_Proxy(IOleInPlaceActiveObject * This);
void __RPC_STUB IOleInPlaceActiveObject_RemoteTranslateAccelerator_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleInPlaceActiveObject_OnFrameWindowActivate_Proxy(IOleInPlaceActiveObject *,BOOL);
void __RPC_STUB IOleInPlaceActiveObject_OnFrameWindowActivate_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleInPlaceActiveObject_OnDocWindowActivate_Proxy(IOleInPlaceActiveObject *,BOOL);
void __RPC_STUB IOleInPlaceActiveObject_OnDocWindowActivate_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleInPlaceActiveObject_RemoteResizeBorder_Proxy(IOleInPlaceActiveObject *,LPCRECT,REFIID,IOleInPlaceUIWindow *,BOOL);
void __RPC_STUB IOleInPlaceActiveObject_RemoteResizeBorder_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleInPlaceActiveObject_EnableModeless_Proxy(IOleInPlaceActiveObject *,BOOL);
void __RPC_STUB IOleInPlaceActiveObject_EnableModeless_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
#endif 	
#ifndef __IOleInPlaceFrame_INTERFACE_DEFINED__
#define __IOleInPlaceFrame_INTERFACE_DEFINED__
typedef IOleInPlaceFrame *LPOLEINPLACEFRAME;
typedef struct tagOIFI {
	UINT cb;
	BOOL fMDIApp;
	HWND hwndFrame;
	HACCEL haccel;
	UINT cAccelEntries;
	}	OLEINPLACEFRAMEINFO;
typedef struct tagOIFI *LPOLEINPLACEFRAMEINFO;
typedef struct tagOleMenuGroupWidths {
	LONG width[6];
	}	OLEMENUGROUPWIDTHS;
typedef struct tagOleMenuGroupWidths *LPOLEMENUGROUPWIDTHS;
typedef HGLOBAL HOLEMENU;
const IID IID_IOleInPlaceFrame;
typedef struct IOleInPlaceFrameVtbl {
	HRESULT (_stdcall *QueryInterface)(IOleInPlaceFrame *,REFIID,void * *);
	ULONG (_stdcall *AddRef)(IOleInPlaceFrame *);
	ULONG (_stdcall *Release)(IOleInPlaceFrame *);
	HRESULT (_stdcall *GetWindow)(IOleInPlaceFrame *,HWND *);
	HRESULT (_stdcall *ContextSensitiveHelp)(IOleInPlaceFrame *,BOOL);
	HRESULT (_stdcall *GetBorder)(IOleInPlaceFrame *,LPRECT);
	HRESULT (_stdcall *RequestBorderSpace)(IOleInPlaceFrame *,LPCBORDERWIDTHS);
	HRESULT (_stdcall *SetBorderSpace)(IOleInPlaceFrame *,LPCBORDERWIDTHS);
	HRESULT (_stdcall *SetActiveObject)(IOleInPlaceFrame *,IOleInPlaceActiveObject *,LPCOLESTR);
	HRESULT (_stdcall *InsertMenus)(IOleInPlaceFrame *,HMENU,LPOLEMENUGROUPWIDTHS);
	HRESULT (_stdcall *SetMenu)(IOleInPlaceFrame *,HMENU,HOLEMENU,HWND);
	HRESULT (_stdcall *RemoveMenus)(IOleInPlaceFrame *,HMENU);
	HRESULT (_stdcall *SetStatusText)(IOleInPlaceFrame *,LPCOLESTR);
	HRESULT (_stdcall *EnableModeless)(IOleInPlaceFrame *,BOOL);
	HRESULT (_stdcall *TranslateAccelerator)(IOleInPlaceFrame *,LPMSG,WORD);
} IOleInPlaceFrameVtbl;
interface IOleInPlaceFrame { CONST_VTBL struct IOleInPlaceFrameVtbl *lpVtbl; };
#define IOleInPlaceFrame_QueryInterface(This,riid,ppvObject) (This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IOleInPlaceFrame_AddRef(This) (This)->lpVtbl->AddRef(This)
#define IOleInPlaceFrame_Release(This)	 (This)->lpVtbl->Release(This)
#define IOleInPlaceFrame_GetWindow(This,phwnd)	 (This)->lpVtbl->GetWindow(This,phwnd)
#define IOleInPlaceFrame_ContextSensitiveHelp(This,fEnterMode)	 (This)->lpVtbl->ContextSensitiveHelp(This,fEnterMode)
#define IOleInPlaceFrame_GetBorder(This,lprectBorder) (This)->lpVtbl->GetBorder(This,lprectBorder)
#define IOleInPlaceFrame_RequestBorderSpace(This,pborderwidths)	 (This)->lpVtbl->RequestBorderSpace(This,pborderwidths)
#define IOleInPlaceFrame_SetBorderSpace(This,pborderwidths)	 (This)->lpVtbl->SetBorderSpace(This,pborderwidths)
#define IOleInPlaceFrame_SetActiveObject(This,pActiveObject,pszObjName)	 (This)->lpVtbl->SetActiveObject(This,pActiveObject,pszObjName)
#define IOleInPlaceFrame_InsertMenus(This,hmenuShared,lpMenuWidths) (This)->lpVtbl->InsertMenus(This,hmenuShared,lpMenuWidths)
#define IOleInPlaceFrame_SetMenu(This,hmenuShared,holemenu,hwndActiveObject) (This)->lpVtbl->SetMenu(This,hmenuShared,holemenu,hwndActiveObject)
#define IOleInPlaceFrame_RemoveMenus(This,hmenuShared)	 (This)->lpVtbl->RemoveMenus(This,hmenuShared)
#define IOleInPlaceFrame_SetStatusText(This,pszStatusText) (This)->lpVtbl->SetStatusText(This,pszStatusText)
#define IOleInPlaceFrame_EnableModeless(This,fEnable)	 (This)->lpVtbl->EnableModeless(This,fEnable)
#define IOleInPlaceFrame_TranslateAccelerator(This,lpmsg,wID)	 (This)->lpVtbl->TranslateAccelerator(This,lpmsg,wID)
HRESULT _stdcall IOleInPlaceFrame_InsertMenus_Proxy(IOleInPlaceFrame *,HMENU,LPOLEMENUGROUPWIDTHS);
void __RPC_STUB IOleInPlaceFrame_InsertMenus_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleInPlaceFrame_SetMenu_Proxy(IOleInPlaceFrame *,HMENU,HOLEMENU,HWND);
void __RPC_STUB IOleInPlaceFrame_SetMenu_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleInPlaceFrame_RemoveMenus_Proxy(IOleInPlaceFrame *,HMENU);
void __RPC_STUB IOleInPlaceFrame_RemoveMenus_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleInPlaceFrame_SetStatusText_Proxy(IOleInPlaceFrame *,LPCOLESTR);
void __RPC_STUB IOleInPlaceFrame_SetStatusText_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleInPlaceFrame_EnableModeless_Proxy(IOleInPlaceFrame *,BOOL);
void __RPC_STUB IOleInPlaceFrame_EnableModeless_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleInPlaceFrame_TranslateAccelerator_Proxy(IOleInPlaceFrame *,LPMSG,WORD);
void __RPC_STUB IOleInPlaceFrame_TranslateAccelerator_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
#endif 	
#ifndef __IOleInPlaceObject_INTERFACE_DEFINED__
#define __IOleInPlaceObject_INTERFACE_DEFINED__
typedef IOleInPlaceObject *LPOLEINPLACEOBJECT;
const IID IID_IOleInPlaceObject;
typedef struct IOleInPlaceObjectVtbl {
	HRESULT (_stdcall *QueryInterface)(IOleInPlaceObject *,REFIID,void * *);
	ULONG (_stdcall *AddRef)(IOleInPlaceObject *);
	ULONG (_stdcall *Release)(IOleInPlaceObject *); 
	HRESULT (_stdcall *GetWindow)(IOleInPlaceObject *,HWND *);
	HRESULT (_stdcall *ContextSensitiveHelp)(IOleInPlaceObject *,BOOL);
	HRESULT (_stdcall *InPlaceDeactivate)(IOleInPlaceObject *);
	HRESULT (_stdcall *UIDeactivate)(IOleInPlaceObject *);
	HRESULT (_stdcall *SetObjectRects)(IOleInPlaceObject *,LPCRECT,LPCRECT);
	HRESULT (_stdcall *ReactivateAndUndo)(IOleInPlaceObject *);
} IOleInPlaceObjectVtbl;
interface IOleInPlaceObject { CONST_VTBL struct IOleInPlaceObjectVtbl *lpVtbl; };
#define IOleInPlaceObject_QueryInterface(This,riid,ppvObject)	 (This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IOleInPlaceObject_AddRef(This)	 (This)->lpVtbl->AddRef(This)
#define IOleInPlaceObject_Release(This)	 (This)->lpVtbl->Release(This)
#define IOleInPlaceObject_GetWindow(This,phwnd)	 (This)->lpVtbl->GetWindow(This,phwnd)
#define IOleInPlaceObject_ContextSensitiveHelp(This,fEnterMode)	 (This)->lpVtbl->ContextSensitiveHelp(This,fEnterMode)
#define IOleInPlaceObject_InPlaceDeactivate(This) (This)->lpVtbl->InPlaceDeactivate(This)
#define IOleInPlaceObject_UIDeactivate(This)	 (This)->lpVtbl->UIDeactivate(This)
#define IOleInPlaceObject_SetObjectRects(This,lprcPosRect,lprcClipRect)	 (This)->lpVtbl->SetObjectRects(This,lprcPosRect,lprcClipRect)
#define IOleInPlaceObject_ReactivateAndUndo(This) (This)->lpVtbl->ReactivateAndUndo(This)
HRESULT _stdcall IOleInPlaceObject_InPlaceDeactivate_Proxy(IOleInPlaceObject * This);
void __RPC_STUB IOleInPlaceObject_InPlaceDeactivate_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleInPlaceObject_UIDeactivate_Proxy(IOleInPlaceObject *);
void __RPC_STUB IOleInPlaceObject_UIDeactivate_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleInPlaceObject_SetObjectRects_Proxy(IOleInPlaceObject *,LPCRECT,LPCRECT);
void __RPC_STUB IOleInPlaceObject_SetObjectRects_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleInPlaceObject_ReactivateAndUndo_Proxy(IOleInPlaceObject *);
void __RPC_STUB IOleInPlaceObject_ReactivateAndUndo_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
#endif 	
#ifndef __IOleInPlaceSite_INTERFACE_DEFINED__
#define __IOleInPlaceSite_INTERFACE_DEFINED__
typedef IOleInPlaceSite *LPOLEINPLACESITE;
const IID IID_IOleInPlaceSite;
typedef struct IOleInPlaceSiteVtbl {
	HRESULT (_stdcall *QueryInterface)(IOleInPlaceSite *,REFIID,void * *);
	ULONG (_stdcall *AddRef)(IOleInPlaceSite *); 
	ULONG (_stdcall *Release)(IOleInPlaceSite *); 
	HRESULT (_stdcall *GetWindow)(IOleInPlaceSite *,HWND *);
	HRESULT (_stdcall *ContextSensitiveHelp)(IOleInPlaceSite *,BOOL);
	HRESULT (_stdcall *CanInPlaceActivate)(IOleInPlaceSite *);
	HRESULT (_stdcall *OnInPlaceActivate)(IOleInPlaceSite *); 
	HRESULT (_stdcall *OnUIActivate)(IOleInPlaceSite *); 
	HRESULT (_stdcall *GetWindowContext)(IOleInPlaceSite *,IOleInPlaceFrame * *,IOleInPlaceUIWindow * *,LPRECT,LPRECT,LPOLEINPLACEFRAMEINFO);
	HRESULT (_stdcall *Scroll)(IOleInPlaceSite *,SIZE);
	HRESULT (_stdcall *OnUIDeactivate)(IOleInPlaceSite *,BOOL);
	HRESULT (_stdcall *OnInPlaceDeactivate)(IOleInPlaceSite *);
	HRESULT (_stdcall *DiscardUndoState)(IOleInPlaceSite *);
	HRESULT (_stdcall *DeactivateAndUndo)(IOleInPlaceSite *);
	HRESULT (_stdcall *OnPosRectChange)(IOleInPlaceSite *,LPCRECT);
} IOleInPlaceSiteVtbl;
interface IOleInPlaceSite { CONST_VTBL struct IOleInPlaceSiteVtbl *lpVtbl; };
#define IOleInPlaceSite_QueryInterface(This,riid,ppvObject)	 (This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IOleInPlaceSite_AddRef(This)	 (This)->lpVtbl->AddRef(This)
#define IOleInPlaceSite_Release(This)	 (This)->lpVtbl->Release(This)
#define IOleInPlaceSite_GetWindow(This,phwnd)	 (This)->lpVtbl->GetWindow(This,phwnd)
#define IOleInPlaceSite_ContextSensitiveHelp(This,fEnterMode)	 (This)->lpVtbl->ContextSensitiveHelp(This,fEnterMode)
#define IOleInPlaceSite_CanInPlaceActivate(This)	 (This)->lpVtbl->CanInPlaceActivate(This)
#define IOleInPlaceSite_OnInPlaceActivate(This)	 (This)->lpVtbl->OnInPlaceActivate(This)
#define IOleInPlaceSite_OnUIActivate(This)	 (This)->lpVtbl->OnUIActivate(This)
#define IOleInPlaceSite_GetWindowContext(This,ppFrame,ppDoc,lprcPosRect,lprcClipRect,lpFrameInfo) (This)->lpVtbl->GetWindowContext(This,ppFrame,ppDoc,lprcPosRect,lprcClipRect,lpFrameInfo)
#define IOleInPlaceSite_Scroll(This,scrollExtant)(This)->lpVtbl->Scroll(This,scrollExtant)
#define IOleInPlaceSite_OnUIDeactivate(This,fUndoable)	 (This)->lpVtbl->OnUIDeactivate(This,fUndoable)
#define IOleInPlaceSite_OnInPlaceDeactivate(This) (This)->lpVtbl->OnInPlaceDeactivate(This)
#define IOleInPlaceSite_DiscardUndoState(This)(This)->lpVtbl->DiscardUndoState(This)
#define IOleInPlaceSite_DeactivateAndUndo(This)	 (This)->lpVtbl->DeactivateAndUndo(This)
#define IOleInPlaceSite_OnPosRectChange(This,lprcPosRect) (This)->lpVtbl->OnPosRectChange(This,lprcPosRect)
HRESULT _stdcall IOleInPlaceSite_CanInPlaceActivate_Proxy(IOleInPlaceSite *);
void __RPC_STUB IOleInPlaceSite_CanInPlaceActivate_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *); 
HRESULT _stdcall IOleInPlaceSite_OnInPlaceActivate_Proxy(IOleInPlaceSite *); 
void __RPC_STUB IOleInPlaceSite_OnInPlaceActivate_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleInPlaceSite_OnUIActivate_Proxy(IOleInPlaceSite *); 
void __RPC_STUB IOleInPlaceSite_OnUIActivate_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleInPlaceSite_GetWindowContext_Proxy(IOleInPlaceSite *,IOleInPlaceFrame * *,IOleInPlaceUIWindow * *,LPRECT,LPRECT,LPOLEINPLACEFRAMEINFO);
void __RPC_STUB IOleInPlaceSite_GetWindowContext_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleInPlaceSite_Scroll_Proxy(IOleInPlaceSite *,SIZE);
void __RPC_STUB IOleInPlaceSite_Scroll_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleInPlaceSite_OnUIDeactivate_Proxy(IOleInPlaceSite *,BOOL);
void __RPC_STUB IOleInPlaceSite_OnUIDeactivate_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleInPlaceSite_OnInPlaceDeactivate_Proxy(IOleInPlaceSite *);
void __RPC_STUB IOleInPlaceSite_OnInPlaceDeactivate_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleInPlaceSite_DiscardUndoState_Proxy(IOleInPlaceSite *);
void __RPC_STUB IOleInPlaceSite_DiscardUndoState_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleInPlaceSite_DeactivateAndUndo_Proxy(IOleInPlaceSite *);
void __RPC_STUB IOleInPlaceSite_DeactivateAndUndo_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IOleInPlaceSite_OnPosRectChange_Proxy(IOleInPlaceSite *,LPCRECT);
void __RPC_STUB IOleInPlaceSite_OnPosRectChange_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
#endif 	
#ifndef __IViewObject_INTERFACE_DEFINED__
#define __IViewObject_INTERFACE_DEFINED__
typedef IViewObject *LPVIEWOBJECT;
const IID IID_IViewObject;
typedef struct IViewObjectVtbl {
	HRESULT (_stdcall *QueryInterface)(IViewObject *,REFIID,void * *);
	ULONG (_stdcall *AddRef)(IViewObject *);
	ULONG (_stdcall *Release)(IViewObject *);
	HRESULT (_stdcall *Draw)(IViewObject *,DWORD,LONG,void *,DVTARGETDEVICE *,HDC,HDC,LPCRECTL,LPCRECTL,BOOL (_stdcall __stdcall *pfnContinue)( DWORD),DWORD );
	HRESULT (_stdcall *GetColorSet)(IViewObject *,DWORD,LONG,void *,DVTARGETDEVICE *,HDC,LOGPALETTE * *);
	HRESULT (_stdcall *Freeze)(IViewObject *,DWORD,LONG,void *,DWORD *);
	HRESULT (_stdcall *Unfreeze)(IViewObject *,DWORD);
	HRESULT (_stdcall *SetAdvise)(IViewObject *,DWORD,DWORD,IAdviseSink *);
	HRESULT (_stdcall *GetAdvise)(IViewObject *,DWORD *,DWORD *,IAdviseSink * *);
} IViewObjectVtbl;
interface IViewObject { CONST_VTBL struct IViewObjectVtbl *lpVtbl; };
#define IViewObject_QueryInterface(This,riid,ppvObject)	 (This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IViewObject_AddRef(This) (This)->lpVtbl->AddRef(This)
#define IViewObject_Release(This) (This)->lpVtbl->Release(This)
#define IViewObject_Draw(This,dwDrawAspect,lindex,pvAspect,ptd,hdcTargetDev,hdcDraw,lprcBounds,lprcWBounds,pfnContinue,dwContinue) (This)->lpVtbl->Draw(This,dwDrawAspect,lindex,pvAspect,ptd,hdcTargetDev,hdcDraw,lprcBounds,lprcWBounds,pfnContinue,dwContinue)
#define IViewObject_GetColorSet(This,dwDrawAspect,lindex,pvAspect,ptd,hicTargetDev,ppColorSet)	 (This)->lpVtbl->GetColorSet(This,dwDrawAspect,lindex,pvAspect,ptd,hicTargetDev,ppColorSet)
#define IViewObject_Freeze(This,dwDrawAspect,lindex,pvAspect,pdwFreeze)	 (This)->lpVtbl->Freeze(This,dwDrawAspect,lindex,pvAspect,pdwFreeze)
#define IViewObject_Unfreeze(This,dwFreeze) (This)->lpVtbl->Unfreeze(This,dwFreeze)
#define IViewObject_SetAdvise(This,aspects,advf,pAdvSink) (This)->lpVtbl->SetAdvise(This,aspects,advf,pAdvSink)
#define IViewObject_GetAdvise(This,pAspects,pAdvf,ppAdvSink) (This)->lpVtbl->GetAdvise(This,pAspects,pAdvf,ppAdvSink)
HRESULT _stdcall IViewObject_Draw_Proxy(IViewObject *,DWORD,LONG,void *,DVTARGETDEVICE *,HDC,HDC,LPCRECTL,LPCRECTL,BOOL (_stdcall *pfnContinue)( DWORD),DWORD );
void __RPC_STUB IViewObject_Draw_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IViewObject_GetColorSet_Proxy(IViewObject *,DWORD,LONG,void *,DVTARGETDEVICE *,HDC,LOGPALETTE * *);
void __RPC_STUB IViewObject_GetColorSet_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IViewObject_Freeze_Proxy(IViewObject *,DWORD,LONG,void *,DWORD *);
void __RPC_STUB IViewObject_Freeze_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IViewObject_Unfreeze_Proxy(IViewObject *,DWORD);
void __RPC_STUB IViewObject_Unfreeze_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IViewObject_SetAdvise_Proxy(IViewObject *,DWORD,DWORD,IAdviseSink *);
void __RPC_STUB IViewObject_SetAdvise_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IViewObject_GetAdvise_Proxy(IViewObject *,DWORD *,DWORD *,IAdviseSink * *);
void __RPC_STUB IViewObject_GetAdvise_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
#endif 	
#ifndef __IViewObject2_INTERFACE_DEFINED__
#define __IViewObject2_INTERFACE_DEFINED__
typedef IViewObject2 *LPVIEWOBJECT2;
const IID IID_IViewObject2;
typedef struct IViewObject2Vtbl {
	HRESULT (_stdcall *QueryInterface)(IViewObject2 *,REFIID,void * *);
	ULONG (_stdcall *AddRef)(IViewObject2 *);
	ULONG (_stdcall *Release)(IViewObject2 *);
	HRESULT (_stdcall *Draw)(IViewObject2 *,DWORD,LONG,void *,DVTARGETDEVICE *,HDC,HDC,LPCRECTL,LPCRECTL,BOOL ( __stdcall *pfnContinue)( DWORD),DWORD);
	HRESULT (_stdcall *GetColorSet)(IViewObject2 *,DWORD,LONG,void *,DVTARGETDEVICE *,HDC,LOGPALETTE * *);
	HRESULT (_stdcall *Freeze)(IViewObject2 *,DWORD,LONG,void *,DWORD *);
	HRESULT (_stdcall *Unfreeze)(IViewObject2 *,DWORD);
	HRESULT (_stdcall *SetAdvise)(IViewObject2 *,DWORD,DWORD,IAdviseSink *);
	HRESULT (_stdcall *GetAdvise)(IViewObject2 *,DWORD *,DWORD *,IAdviseSink * *);
	HRESULT (_stdcall *GetExtent)(IViewObject2 *,DWORD,LONG,DVTARGETDEVICE *,LPSIZEL);
} IViewObject2Vtbl;
interface IViewObject2 { CONST_VTBL struct IViewObject2Vtbl *lpVtbl; };
#define IViewObject2_QueryInterface(This,riid,ppvObject) (This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IViewObject2_AddRef(This) (This)->lpVtbl->AddRef(This)
#define IViewObject2_Release(This) (This)->lpVtbl->Release(This)
#define IViewObject2_Draw(T,A,l,vA,ptd,v,h,s,B,fn,C) (T)->lpVtbl->Draw(T,A,l,vA,ptd,v,h,s,B,fn,C)
#define IViewObject2_GetColorSet(This,dwDrawAspect,lindex,pvAspect,ptd,hicTargetDev,ppColorSet)	 (This)->lpVtbl->GetColorSet(This,dwDrawAspect,lindex,pvAspect,ptd,hicTargetDev,ppColorSet)
#define IViewObject2_Freeze(This,dwDrawAspect,lindex,pvAspect,pdwFreeze) (This)->lpVtbl->Freeze(This,dwDrawAspect,lindex,pvAspect,pdwFreeze)
#define IViewObject2_Unfreeze(This,dwFreeze) (This)->lpVtbl->Unfreeze(This,dwFreeze)
#define IViewObject2_SetAdvise(This,aspects,advf,pAdvSink)	 (This)->lpVtbl->SetAdvise(This,aspects,advf,pAdvSink)
#define IViewObject2_GetAdvise(This,pAspects,pAdvf,ppAdvSink)	 (This)->lpVtbl->GetAdvise(This,pAspects,pAdvf,ppAdvSink)
#define IViewObject2_GetExtent(This,dwDrawAspect,lindex,ptd,lpsizel)	 (This)->lpVtbl->GetExtent(This,dwDrawAspect,lindex,ptd,lpsizel)
HRESULT _stdcall IViewObject2_GetExtent_Proxy(IViewObject2 *,DWORD,LONG,DVTARGETDEVICE *,LPSIZEL);
void __RPC_STUB IViewObject2_GetExtent_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
#endif 	

#ifndef __IDropSource_INTERFACE_DEFINED__
#define __IDropSource_INTERFACE_DEFINED__
typedef IDropSource *LPDROPSOURCE;
const IID IID_IDropSource;
typedef struct IDropSourceVtbl {
	HRESULT (_stdcall *QueryInterface)(IDropSource *,REFIID,void * *);
	ULONG (_stdcall *AddRef)(IDropSource *);
	ULONG (_stdcall *Release)(IDropSource *);
	HRESULT (_stdcall *QueryContinueDrag)(IDropSource *,BOOL,DWORD);
	HRESULT (_stdcall *GiveFeedback)(IDropSource *,DWORD);
	} IDropSourceVtbl;
interface IDropSource { CONST_VTBL struct IDropSourceVtbl *lpVtbl; };
#define IDropSource_QueryInterface(This,riid,ppvObject)	 (This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IDropSource_AddRef(This) (This)->lpVtbl->AddRef(This)
#define IDropSource_Release(This) (This)->lpVtbl->Release(This)
#define IDropSource_QueryContinueDrag(This,fEscapePressed,grfKeyState) (This)->lpVtbl->QueryContinueDrag(This,fEscapePressed,grfKeyState)
#define IDropSource_GiveFeedback(This,dwEffect)	 (This)->lpVtbl->GiveFeedback(This,dwEffect)
HRESULT _stdcall IDropSource_QueryContinueDrag_Proxy(IDropSource *,BOOL,DWORD);
void __RPC_STUB IDropSource_QueryContinueDrag_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IDropSource_GiveFeedback_Proxy(IDropSource *,DWORD);
void __RPC_STUB IDropSource_GiveFeedback_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
#endif 	
#ifndef __IDropTarget_INTERFACE_DEFINED__
#define __IDropTarget_INTERFACE_DEFINED__
typedef IDropTarget *LPDROPTARGET;
#define	MK_ALT 32
#define	DROPEFFECT_NONE	0
#define	DROPEFFECT_COPY	1
#define	DROPEFFECT_MOVE	2
#define	DROPEFFECT_LINK	4
#define	DROPEFFECT_SCROLL	0x80000000
#define	DD_DEFSCROLLINSET	11
#define	DD_DEFSCROLLDELAY	50
#define	DD_DEFSCROLLINTERVAL	50
#define	DD_DEFDRAGDELAY	(200)
#define	DD_DEFDRAGMINDIST	(2)
const IID IID_IDropTarget;
typedef struct IDropTargetVtbl {
	HRESULT (_stdcall *QueryInterface)(IDropTarget *,REFIID,void * *);
	ULONG (_stdcall *AddRef)(IDropTarget *);
	ULONG (_stdcall *Release)(IDropTarget *);
	HRESULT (_stdcall *DragEnter)(IDropTarget *,IDataObject *,DWORD,POINTL,DWORD *);
	HRESULT (_stdcall *DragOver)(IDropTarget *,DWORD,POINTL,DWORD *); 
	HRESULT (_stdcall *DragLeave)(IDropTarget *); 
	HRESULT (_stdcall *Drop)(IDropTarget *,IDataObject *,DWORD,POINTL,DWORD *);
} IDropTargetVtbl;
interface IDropTarget { CONST_VTBL struct IDropTargetVtbl *lpVtbl; };
#define IDropTarget_QueryInterface(This,riid,ppvObject)	 (This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IDropTarget_AddRef(This) (This)->lpVtbl->AddRef(This)
#define IDropTarget_Release(This) (This)->lpVtbl->Release(This)
#define IDropTarget_DragEnter(This,pDataObj,grfKeyState,pt,pdwEffect) (This)->lpVtbl->DragEnter(This,pDataObj,grfKeyState,pt,pdwEffect)
#define IDropTarget_DragOver(This,grfKeyState,pt,pdwEffect) (This)->lpVtbl->DragOver(This,grfKeyState,pt,pdwEffect)
#define IDropTarget_DragLeave(This)	 (This)->lpVtbl->DragLeave(This)
#define IDropTarget_Drop(This,pDataObj,grfKeyState,pt,pdwEffect) (This)->lpVtbl->Drop(This,pDataObj,grfKeyState,pt,pdwEffect)
HRESULT _stdcall IDropTarget_DragEnter_Proxy(IDropTarget *,IDataObject *,DWORD,POINTL,DWORD *);
void __RPC_STUB IDropTarget_DragEnter_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IDropTarget_DragOver_Proxy(IDropTarget *,DWORD,POINTL,DWORD *);
void __RPC_STUB IDropTarget_DragOver_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IDropTarget_DragLeave_Proxy(IDropTarget *);
void __RPC_STUB IDropTarget_DragLeave_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IDropTarget_Drop_Proxy(IDropTarget *,IDataObject *,DWORD,POINTL,DWORD *);
void __RPC_STUB IDropTarget_Drop_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
#endif 	
#ifndef __IEnumOLEVERB_INTERFACE_DEFINED__
#define __IEnumOLEVERB_INTERFACE_DEFINED__
typedef IEnumOLEVERB *LPENUMOLEVERB;
typedef struct tagOLEVERB {
	LONG lVerb;
	LPOLESTR lpszVerbName;
	DWORD fuFlags;
	DWORD grfAttribs;
	}	OLEVERB;
typedef struct tagOLEVERB *LPOLEVERB;
typedef enum tagOLEVERBATTRIB
	{	OLEVERBATTRIB_NEVERDIRTIES	= 1,
	OLEVERBATTRIB_ONCONTAINERMENU	= 2
	}	OLEVERBATTRIB;
const IID IID_IEnumOLEVERB;
typedef struct IEnumOLEVERBVtbl {
	HRESULT (_stdcall *QueryInterface)(IEnumOLEVERB *,REFIID,void * *);
	ULONG (_stdcall *AddRef)(IEnumOLEVERB *);
	ULONG (_stdcall *Release)(IEnumOLEVERB *);
	HRESULT (_stdcall *Next)(IEnumOLEVERB *,ULONG,LPOLEVERB,ULONG *);
	HRESULT (_stdcall *Skip)(IEnumOLEVERB *,ULONG); 
	HRESULT (_stdcall *Reset)(IEnumOLEVERB *); 
	HRESULT (_stdcall *Clone)(IEnumOLEVERB *,IEnumOLEVERB * *);
} IEnumOLEVERBVtbl;
interface IEnumOLEVERB { CONST_VTBL struct IEnumOLEVERBVtbl *lpVtbl; };
#define IEnumOLEVERB_QueryInterface(This,riid,ppvObject) (This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IEnumOLEVERB_AddRef(This) (This)->lpVtbl->AddRef(This)
#define IEnumOLEVERB_Release(This) (This)->lpVtbl->Release(This)
#define IEnumOLEVERB_Next(This,celt,rgelt,pceltFetched)	 (This)->lpVtbl->Next(This,celt,rgelt,pceltFetched)
#define IEnumOLEVERB_Skip(This,celt)	 (This)->lpVtbl->Skip(This,celt)
#define IEnumOLEVERB_Reset(This) (This)->lpVtbl->Reset(This)
#define IEnumOLEVERB_Clone(This,ppenum)	 (This)->lpVtbl->Clone(This,ppenum)
#ifndef NOPROXYSTUB
HRESULT _stdcall IEnumOLEVERB_RemoteNext_Proxy(IEnumOLEVERB *,ULONG,LPOLEVERB,ULONG *);
void __RPC_STUB IEnumOLEVERB_RemoteNext_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IEnumOLEVERB_Skip_Proxy(IEnumOLEVERB *,ULONG);
void __RPC_STUB IEnumOLEVERB_Skip_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IEnumOLEVERB_Reset_Proxy(IEnumOLEVERB *);
void __RPC_STUB IEnumOLEVERB_Reset_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IEnumOLEVERB_Clone_Proxy(IEnumOLEVERB *,IEnumOLEVERB * *);
void __RPC_STUB IEnumOLEVERB_Clone_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
#endif 
#endif 	
void __RPC_USER UINT_to_xmit(UINT *,unsigned long * *);
void __RPC_USER UINT_from_xmit(unsigned long *,UINT *);
void __RPC_USER UINT_free_inst(UINT *);
void __RPC_USER UINT_free_xmit(unsigned long *);
void __RPC_USER WPARAM_to_xmit(WPARAM *,unsigned long * *);
void __RPC_USER WPARAM_from_xmit(unsigned long *,WPARAM *);
void __RPC_USER WPARAM_free_inst(WPARAM *);
void __RPC_USER WPARAM_free_xmit(unsigned long *);
void __RPC_USER HWND_to_xmit(HWND *,long * *);
void __RPC_USER HWND_from_xmit(long *,HWND *);
void __RPC_USER HWND_free_inst(HWND *);
void __RPC_USER HWND_free_xmit(long *);
void __RPC_USER HMENU_to_xmit(HMENU *,long * *);
void __RPC_USER HMENU_from_xmit(long *,HMENU *);
void __RPC_USER HMENU_free_inst(HMENU *);
void __RPC_USER HMENU_free_xmit(long *);
void __RPC_USER HACCEL_to_xmit(HACCEL *,long * *);
void __RPC_USER HACCEL_from_xmit(long *,HACCEL *);
void __RPC_USER HACCEL_free_inst(HACCEL *);
void __RPC_USER HACCEL_free_xmit(long *);
void __RPC_USER HOLEMENU_to_xmit(HOLEMENU *,RemHGLOBAL * *);
void __RPC_USER HOLEMENU_from_xmit(RemHGLOBAL *,HOLEMENU *);
void __RPC_USER HOLEMENU_free_inst(HOLEMENU *);
void __RPC_USER HOLEMENU_free_xmit(RemHGLOBAL *);
HRESULT _stdcall IOleItemContainer_GetObject_Proxy(IOleItemContainer *,LPOLESTR,DWORD,IBindCtx *,REFIID riid,void * *);
HRESULT _stdcall IOleItemContainer_GetObject_Stub(IOleItemContainer *,LPOLESTR,DWORD,IBindCtx *,REFIID,IUnknown * *);
HRESULT _stdcall IOleItemContainer_GetObjectStorage_Proxy(IOleItemContainer *,LPOLESTR,IBindCtx *,REFIID,void * *);
HRESULT _stdcall IOleItemContainer_GetObjectStorage_Stub(IOleItemContainer *,LPOLESTR,IBindCtx *,REFIID,IUnknown * *);
HRESULT _stdcall IOleInPlaceActiveObject_TranslateAccelerator_Proxy(IOleInPlaceActiveObject *,LPMSG);
HRESULT _stdcall IOleInPlaceActiveObject_TranslateAccelerator_Stub(IOleInPlaceActiveObject *);
HRESULT _stdcall IOleInPlaceActiveObject_ResizeBorder_Proxy(IOleInPlaceActiveObject *,LPCRECT,IOleInPlaceUIWindow *,BOOL);
HRESULT _stdcall IOleInPlaceActiveObject_ResizeBorder_Stub(IOleInPlaceActiveObject *,LPCRECT,REFIID,IOleInPlaceUIWindow *,BOOL);
HRESULT _stdcall IEnumOLEVERB_Next_Proxy(IEnumOLEVERB * This,ULONG celt,LPOLEVERB rgelt,ULONG *pceltFetched);
HRESULT _stdcall IEnumOLEVERB_Next_Stub(IEnumOLEVERB * This,ULONG celt,LPOLEVERB rgelt,ULONG *pceltFetched);
#endif
