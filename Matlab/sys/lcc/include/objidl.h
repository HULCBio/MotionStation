/* $Revision: 1.2 $ */
#ifndef _LCC_OBJIDL_H
#define _LCC_OBJIDL_H
#include <windows.h>
#include <rpcdcep.h>
#ifndef OLECHAR
#ifdef UNICODE
#define OLECHAR WCHAR
#else
#define OLECHAR char
#endif
#endif
#define LPCOLESTR LPCSTR
#ifndef __objidl_h__
#define __objidl_h__
#ifndef interface
#define interface struct
#endif
typedef interface IMarshal IMarshal;
typedef interface IMalloc IMalloc;
typedef interface IMallocSpy IMallocSpy;
typedef interface IStdMarshalInfo IStdMarshalInfo;
typedef interface IExternalConnection IExternalConnection;
typedef interface IEnumUnknown IEnumUnknown;
typedef interface IBindCtx IBindCtx;
typedef interface IEnumMoniker IEnumMoniker;
typedef interface IRunnableObject IRunnableObject;
typedef interface IRunningObjectTable IRunningObjectTable;
typedef interface IPersist IPersist;
typedef interface IPersistStream IPersistStream;
typedef interface IMoniker IMoniker;
typedef interface IROTData IROTData;
typedef interface IEnumString IEnumString;
typedef interface IStream IStream;
typedef interface IEnumSTATSTG IEnumSTATSTG;
typedef interface IStorage IStorage;
typedef interface IPersistFile IPersistFile;
typedef interface IPersistStorage IPersistStorage;
typedef interface ILockBytes ILockBytes;
typedef interface IEnumFORMATETC IEnumFORMATETC;
typedef interface IEnumSTATDATA IEnumSTATDATA;
typedef interface IRootStorage IRootStorage;
typedef interface IAdviseSink IAdviseSink;
typedef interface IAdviseSink2 IAdviseSink2;
typedef interface IDataObject IDataObject;
typedef interface IDataAdviseHolder IDataAdviseHolder;
typedef interface IMessageFilter IMessageFilter;
typedef interface IRpcChannelBuffer IRpcChannelBuffer;
typedef interface IRpcProxyBuffer IRpcProxyBuffer;
typedef interface IRpcStubBuffer IRpcStubBuffer;
typedef interface IPSFactoryBuffer IPSFactoryBuffer;
typedef interface IChannelHook IChannelHook;
typedef interface IPropertyStorage IPropertyStorage;
typedef interface IPropertySetStorage IPropertySetStorage;
typedef interface IEnumSTATPROPSTG IEnumSTATPROPSTG;
typedef interface IEnumSTATPROPSETSTG IEnumSTATPROPSETSTG;
typedef interface IClientSecurity IClientSecurity;
typedef interface IServerSecurity IServerSecurity;
typedef interface IClassActivator IClassActivator;
typedef interface IFillLockBytes IFillLockBytes;
typedef interface IProgressNotify IProgressNotify;
typedef interface ILayoutStorage ILayoutStorage;
/* header files for imported files */
#include "unknwn.h"
#ifdef IUnknown
#undef IUnknown
#endif
//typedef interface _IUnknown { struct iUnknownVtbl *lpVtbl; } IUnknown;
#ifndef __MIDL_USER_ALLOCATE_DEFINED
#define __MIDL_USER_ALLOCATE_DEFINED
void* _stdcall MIDL_user_allocate(int);
void _stdcall MIDL_user_free(void* ); 
#endif
extern void * __MIDL__intf_0000_v0_0_c_ifspec;
extern void * __MIDL__intf_0000_v0_0_s_ifspec;

typedef IMarshal*LPMARSHAL;
extern IID IID_IMarshal;

typedef struct IMarshalVtbl {
	HRESULT (_stdcall*QueryInterface)(IMarshal*,REFIID,void * *);
	ULONG (_stdcall*AddRef )(IMarshal*);
	ULONG (_stdcall*Release )(IMarshal* This);
	HRESULT (_stdcall*GetUnmarshalClass)(IMarshal*,REFIID,void*,DWORD,void*,DWORD,CLSID*);
	HRESULT (_stdcall*GetMarshalSizeMax)(IMarshal*,REFIID,void*,DWORD,void*,DWORD,DWORD*);
	HRESULT (_stdcall*MarshalInterface)(IMarshal*,IStream*,REFIID,void*,DWORD,void*,DWORD);
	HRESULT (_stdcall*UnmarshalInterface)(IMarshal*,IStream*,REFIID,void **);
	HRESULT (_stdcall*ReleaseMarshalData)(IMarshal*,IStream *);
	HRESULT (_stdcall* DisconnectObject)(IMarshal*,DWORD);
	} IMarshalVtbl;

interface IMarshal { struct IMarshalVtbl*lpVtbl; };

#define IMarshal_QueryInterface(T,r,p) (T)->lpVtbl->QueryInterface(T,r,p)
#define IMarshal_AddRef(This) (This)->lpVtbl->AddRef(This)
#define IMarshal_Release(This) (This)->lpVtbl->Release(This)
#define IMarshal_GetUnmarshalClass(T,r,pv,dw,pvD,m,pC) (T)->lpVtbl->GetUnmarshalClass(T,r,pv,dw,pvD,m,pC)
#define IMarshal_GetMarshalSizeMax(T,r,pv,dw,pD,m,p) (T)->lpVtbl->GetMarshalSizeMax(T,r,pv,dw,pD,m,p)
#define IMarshal_MarshalInterface(T,p,r,pv,dw,pvD,m) (T)->lpVtbl->MarshalInterface(T,p,r,pv,dw,pv,m)
#define IMarshal_UnmarshalInterface(T,p,r,pp) (T)->lpVtbl->UnmarshalInterface(T,p,r,pp)
#define IMarshal_ReleaseMarshalData(T,p) (T)->lpVtbl->ReleaseMarshalData(T,p)
#define IMarshal_DisconnectObject(T,d) (T)->lpVtbl->DisconnectObject(T,d)

HRESULT _stdcall IMarshal_GetUnmarshalClass_Proxy(IMarshal*, REFIID,void*,DWORD,void*,DWORD,CLSID*);
void _stdcall IMarshal_GetUnmarshalClass_Stub(IRpcStubBuffer *, IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IMarshal_GetMarshalSizeMax_Proxy(IMarshal*,REFIID ,void*,DWORD,void*,DWORD,DWORD*);
void _stdcall IMarshal_GetMarshalSizeMax_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IMarshal_MarshalInterface_Proxy(IMarshal*,IStream*,REFIID,void*,DWORD,void*,DWORD);
void _stdcall IMarshal_MarshalInterface_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IMarshal_UnmarshalInterface_Proxy(IMarshal*,IStream*,REFIID ,void * *);
void _stdcall IMarshal_UnmarshalInterface_Stub(IRpcStubBuffer *, IRpcChannelBuffer *,PRPC_MESSAGE, DWORD *);
HRESULT _stdcall IMarshal_ReleaseMarshalData_Proxy(IMarshal*, IStream*);
void _stdcall IMarshal_ReleaseMarshalData_Stub(IRpcStubBuffer *, IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IMarshal_DisconnectObject_Proxy(IMarshal*,DWORD);
void _stdcall IMarshal_DisconnectObject_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE, DWORD *);

typedef IMalloc*LPMALLOC;
extern const IID IID_IMalloc;
typedef struct IMallocVtbl {
	HRESULT (_stdcall*QueryInterface )(IMalloc* This,
	REFIID riid,void * * ppvObject);
	ULONG (_stdcall*AddRef )(IMalloc*);
	ULONG (_stdcall*Release )(IMalloc*);
	void*(* _stdcall Alloc )(IMalloc*, ULONG);
	void*(_stdcall*Realloc )(IMalloc*,void*,ULONG);
	void (_stdcall*Free )(IMalloc*,void*);
	ULONG (_stdcall*GetSize )(IMalloc*,void*);
	int (_stdcall*DidAlloc )(IMalloc*,void *);
	void (_stdcall*HeapMinimize )(IMalloc*);
} IMallocVtbl;
interface IMalloc { struct IMallocVtbl*lpVtbl; };
#define IMalloc_QueryInterface(This,riid,ppvObject) (This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IMalloc_AddRef(This) (This)->lpVtbl->AddRef(This)
#define IMalloc_Release(This)	(This)->lpVtbl->Release(This)
#define IMalloc_Alloc(This,cb)	(This)->lpVtbl->Alloc(This,cb)
#define IMalloc_Realloc(This,pv,cb)	(This)->lpVtbl->Realloc(This,pv,cb)
#define IMalloc_Free(This,pv)	(This)->lpVtbl->Free(This,pv)
#define IMalloc_GetSize(This,pv) (This)->lpVtbl->GetSize(This,pv)
#define IMalloc_DidAlloc(This,pv) (This)->lpVtbl->DidAlloc(This,pv)
#define IMalloc_HeapMinimize(This) (This)->lpVtbl->HeapMinimize(This)
void*_stdcall IMalloc_Alloc_Proxy(IMalloc*,ULONG);
void _stdcall IMalloc_Alloc_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
void*_stdcall IMalloc_Realloc_Proxy(IMalloc*,void*,ULONG);
void _stdcall IMalloc_Realloc_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
void _stdcall IMalloc_Free_Proxy(IMalloc*,void *);
void _stdcall IMalloc_Free_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
ULONG _stdcall IMalloc_GetSize_Proxy(IMalloc*,void*);
void _stdcall IMalloc_GetSize_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
int _stdcall IMalloc_DidAlloc_Proxy(IMalloc*,void*);
void _stdcall IMalloc_DidAlloc_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
void _stdcall IMalloc_HeapMinimize_Proxy(IMalloc*);
void _stdcall IMalloc_HeapMinimize_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
typedef IMallocSpy*LPMALLOCSPY;
extern const IID IID_IMallocSpy;
typedef struct IMallocSpyVtbl {
	HRESULT (_stdcall*QueryInterface )(IMallocSpy*,REFIID,void * *);
	ULONG (_stdcall*AddRef )(IMallocSpy* );
	ULONG (_stdcall*Release )(IMallocSpy* );
	ULONG (_stdcall*PreAlloc )(IMallocSpy* ,ULONG);
	void*(_stdcall*PostAlloc )(IMallocSpy* ,void*);
	void*(_stdcall*PreFree )(IMallocSpy*,void*,BOOL);
	void (_stdcall*PostFree)(IMallocSpy*,BOOL);
	ULONG (_stdcall*PreRealloc)(IMallocSpy*,void*,ULONG,void * *,BOOL);
	void*(_stdcall*PostRealloc)(IMallocSpy*,void*,BOOL);
	void*(_stdcall*PreGetSize)(IMallocSpy*,void*,BOOL);
	ULONG (_stdcall*PostGetSize )(IMallocSpy*,ULONG,BOOL);
	void*(_stdcall*PreDidAlloc )(IMallocSpy*,void*,BOOL);
	int (_stdcall*PostDidAlloc )(IMallocSpy*,void*,BOOL,int);
	void (_stdcall*PreHeapMinimize )(IMallocSpy*);
	void (_stdcall*PostHeapMinimize )(IMallocSpy*);
} IMallocSpyVtbl;
interface IMallocSpy { struct IMallocSpyVtbl*lpVtbl; };
#define IMallocSpy_QueryInterface(T,r,p) (T)->lpVtbl->QueryInterface(T,r,p)
#define IMallocSpy_AddRef(This)	 (This)->lpVtbl->AddRef(This)
#define IMallocSpy_Release(This) (This)->lpVtbl->Release(This)
#define IMallocSpy_PreAlloc(T,c)	 (T)->lpVtbl->PreAlloc(T,c)
#define IMallocSpy_PostAlloc(This,p)	(This)->lpVtbl->PostAlloc(This,p)
#define IMallocSpy_PreFree(This,p,f) (This)->lpVtbl->PreFree(This,p,f)
#define IMallocSpy_PostFree(This,fSpyed) (This)->lpVtbl->PostFree(This,fSpyed)
#define IMallocSpy_PreRealloc(T,p,c,pp,f) (T)->lpVtbl->PreRealloc(T,p,c,pp,f)
#define IMallocSpy_PostRealloc(T,p,f) (T)->lpVtbl->PostRealloc(T,p,f)
#define IMallocSpy_PreGetSize(This,p,f)	(This)->lpVtbl->PreGetSize(This,p,f)
#define IMallocSpy_PostGetSize(This,cbActual,fSpyed)	\
	(This)->lpVtbl->PostGetSize(This,cbActual,fSpyed)
#define IMallocSpy_PreDidAlloc(This,pRequest,fSpyed)	\
	(This)->lpVtbl->PreDidAlloc(This,pRequest,fSpyed)
#define IMallocSpy_PostDidAlloc(This,pRequest,fSpyed,fActual)	\
	(This)->lpVtbl->PostDidAlloc(This,pRequest,fSpyed,fActual)
#define IMallocSpy_PreHeapMinimize(T) (T)->lpVtbl->PreHeapMinimize(T)
#define IMallocSpy_PostHeapMinimize(T) (T)->lpVtbl->PostHeapMinimize(T)

ULONG _stdcall IMallocSpy_PreAlloc_Proxy(IMallocSpy* This,ULONG cbRequest);
void _stdcall IMallocSpy_PreAlloc_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
void*_stdcall IMallocSpy_PostAlloc_Proxy(IMallocSpy*,void*);
void _stdcall IMallocSpy_PostAlloc_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
void*_stdcall IMallocSpy_PreFree_Proxy(IMallocSpy*,void*,BOOL);
void _stdcall IMallocSpy_PreFree_Stub(IRpcStubBuffer *, IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
void _stdcall IMallocSpy_PostFree_Proxy(IMallocSpy* ,BOOL);
void _stdcall IMallocSpy_PostFree_Stub(IRpcStubBuffer *, IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
ULONG _stdcall IMallocSpy_PreRealloc_Proxy(IMallocSpy*, void*,ULONG,void * * ,BOOL);
void _stdcall IMallocSpy_PreRealloc_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
void*_stdcall IMallocSpy_PostRealloc_Proxy(IMallocSpy*,void*,BOOL);
void _stdcall IMallocSpy_PostRealloc_Stub(IRpcStubBuffer *, IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
void*_stdcall IMallocSpy_PreGetSize_Proxy(IMallocSpy*,void*,BOOL);
void _stdcall IMallocSpy_PreGetSize_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
ULONG _stdcall IMallocSpy_PostGetSize_Proxy(IMallocSpy*,ULONG,BOOL);
void _stdcall IMallocSpy_PostGetSize_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
void*_stdcall IMallocSpy_PreDidAlloc_Proxy(IMallocSpy*,void*,BOOL);
void _stdcall IMallocSpy_PreDidAlloc_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE ,DWORD *);
int _stdcall IMallocSpy_PostDidAlloc_Proxy(IMallocSpy*,void*,BOOL,int);
void _stdcall IMallocSpy_PostDidAlloc_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
void _stdcall IMallocSpy_PreHeapMinimize_Proxy(IMallocSpy* );
void _stdcall IMallocSpy_PreHeapMinimize_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
void _stdcall IMallocSpy_PostHeapMinimize_Proxy(IMallocSpy*);
void _stdcall IMallocSpy_PostHeapMinimize_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);

typedef IStdMarshalInfo*LPSTDMARSHALINFO;
extern const IID IID_IStdMarshalInfo;
typedef struct IStdMarshalInfoVtbl {
	HRESULT (_stdcall*QueryInterface )(IStdMarshalInfo*,REFIID,void * *);
	ULONG (_stdcall*AddRef)(IStdMarshalInfo*);
	ULONG (_stdcall*Release)(IStdMarshalInfo*);
	HRESULT (_stdcall*GetClassForHandler )(IStdMarshalInfo*,DWORD,void*,CLSID*);
} IStdMarshalInfoVtbl;

interface IStdMarshalInfo { struct IStdMarshalInfoVtbl*lpVtbl; };
#define IStdMarshalInfo_QueryInterface(T,r,p) (This)->lpVtbl->QueryInterface(T,r,p)
#define IStdMarshalInfo_AddRef(This) (This)->lpVtbl->AddRef(This)
#define IStdMarshalInfo_Release(This) (This)->lpVtbl->Release(This)
#define IStdMarshalInfo_GetClassForHandler(This,D,p,C) (This)->lpVtbl->GetClassForHandler(This,D,p,C)
HRESULT _stdcall IStdMarshalInfo_GetClassForHandler_Proxy(IStdMarshalInfo*,DWORD,void*,CLSID*);
void _stdcall IStdMarshalInfo_GetClassForHandler_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);

typedef IExternalConnection*LPEXTERNALCONNECTION;
typedef enum tagEXTCONN {	EXTCONN_STRONG	= 0x1,
	EXTCONN_WEAK	= 0x2,
	EXTCONN_CALLABLE	= 0x4
	}	EXTCONN;
extern const IID IID_IExternalConnection;
typedef struct IExternalConnectionVtbl {
	HRESULT (_stdcall*QueryInterface )(IExternalConnection*,REFIID,void* *);
	ULONG (_stdcall*AddRef )(IExternalConnection* );
	ULONG (_stdcall*Release )(IExternalConnection* );
	DWORD (_stdcall*AddConnection )(IExternalConnection*,DWORD,DWORD);
	DWORD (_stdcall*ReleaseConnection )(IExternalConnection*,DWORD,DWORD,BOOL);
} IExternalConnectionVtbl;

interface IExternalConnection { struct IExternalConnectionVtbl*lpVtbl; };
#define IExternalConnection_QueryInterface(This,riid,ppvObject)	(This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IExternalConnection_AddRef(This) (This)->lpVtbl->AddRef(This)
#define IExternalConnection_Release(This) (This)->lpVtbl->Release(This)
#define IExternalConnection_AddConnection(T,e,r) (T)->lpVtbl->AddConnection(T,e,r)
#define IExternalConnection_ReleaseConnection(This,e,r,f) (This)->lpVtbl->ReleaseConnection(This,e,r,f)
DWORD _stdcall IExternalConnection_AddConnection_Proxy(IExternalConnection*,DWORD,DWORD);
void _stdcall IExternalConnection_AddConnection_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
DWORD _stdcall IExternalConnection_ReleaseConnection_Proxy(IExternalConnection*,DWORD,DWORD,BOOL);
void _stdcall IExternalConnection_ReleaseConnection_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);

typedef IEnumUnknown*LPENUMUNKNOWN;
extern const IID IID_IEnumUnknown;

typedef struct IEnumUnknownVtbl { 
	HRESULT (_stdcall*QueryInterface )(IEnumUnknown*,REFIID,void* *);
	ULONG (_stdcall*AddRef )(IEnumUnknown* );
	ULONG (_stdcall*Release )(IEnumUnknown* );
	HRESULT (_stdcall*Next )(IEnumUnknown*,ULONG,IUnknown* *,ULONG*);
	HRESULT (_stdcall*Skip )(IEnumUnknown* ,ULONG );
	HRESULT (_stdcall*Reset )(IEnumUnknown*);
	HRESULT (_stdcall*Clone )(IEnumUnknown*, IEnumUnknown* *);
	} IEnumUnknownVtbl;

interface IEnumUnknown { struct IEnumUnknownVtbl*lpVtbl; };
#define IEnumUnknown_QueryInterface(T,r,p) (This)->lpVtbl->QueryInterface(T,r,p)
#define IEnumUnknown_AddRef(This) (This)->lpVtbl->AddRef(This)
#define IEnumUnknown_Release(This) (This)->lpVtbl->Release(This)
#define IEnumUnknown_Next(This,celt,rgelt,p) (This)->lpVtbl->Next(This,celt,rgelt,p)
#define IEnumUnknown_Skip(This,celt) (This)->lpVtbl->Skip(This,celt)
#define IEnumUnknown_Reset(This) (This)->lpVtbl->Reset(This)
#define IEnumUnknown_Clone(This,ppenum)	 (This)->lpVtbl->Clone(This,ppenum)

HRESULT _stdcall IEnumUnknown_RemoteNext_Proxy(IEnumUnknown*,ULONG,IUnknown* *,ULONG*);
void _stdcall IEnumUnknown_RemoteNext_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IEnumUnknown_Skip_Proxy(IEnumUnknown*,ULONG);
void _stdcall IEnumUnknown_Skip_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IEnumUnknown_Reset_Proxy(IEnumUnknown* );
void _stdcall IEnumUnknown_Reset_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IEnumUnknown_Clone_Proxy(IEnumUnknown*,IEnumUnknown * *);
void _stdcall IEnumUnknown_Clone_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);


typedef IBindCtx*LPBC;

typedef IBindCtx*LPBINDCTX;
typedef struct tagBIND_OPTS {
	DWORD cbStruct;
	DWORD grfFlags;
	DWORD grfMode;
	DWORD dwTickCountDeadline;
	}	BIND_OPTS;
typedef struct tagBIND_OPTS*LPBIND_OPTS;
typedef enum tagBIND_FLAGS
	{	BIND_MAYBOTHERUSER	= 1,
	BIND_JUSTTESTEXISTENCE	= 2
	}	BIND_FLAGS;
extern const IID IID_IBindCtx;
typedef struct IBindCtxVtbl {
	HRESULT (_stdcall*QueryInterface )(IBindCtx* This,REFIID riid,void * * ppvObject);
	ULONG (_stdcall*AddRef )(IBindCtx* This);
	ULONG (_stdcall*Release )(IBindCtx* This);
	HRESULT (_stdcall*RegisterObjectBound )(IBindCtx* This,IUnknown*punk);
	HRESULT (_stdcall*RevokeObjectBound )(IBindCtx* This,IUnknown*punk);
	HRESULT (_stdcall*ReleaseBoundObjects )(IBindCtx* This);
	HRESULT (_stdcall*SetBindOptions )(IBindCtx* This,BIND_OPTS*pbindopts);
	HRESULT (_stdcall*GetBindOptions )(IBindCtx* This,BIND_OPTS*pbindopts);
	HRESULT (_stdcall*GetRunningObjectTable )(IBindCtx* This,IRunningObjectTable * * pprot);
	HRESULT (_stdcall*RegisterObjectParam )(IBindCtx* This,LPCSTR pszKey,IUnknown*punk);
	HRESULT (_stdcall*GetObjectParam )(IBindCtx* This,LPCSTR pszKey,IUnknown * * ppunk);
	HRESULT (_stdcall*EnumObjectParam )(IBindCtx* This,IEnumString * * ppenum);
	HRESULT (_stdcall*RevokeObjectParam )(IBindCtx* This,LPCSTR pszKey);
} IBindCtxVtbl;

interface IBindCtx { struct IBindCtxVtbl*lpVtbl; };

#define IBindCtx_QueryInterface(T,r,p) (T)->lpVtbl->QueryInterface(T,r,p)
#define IBindCtx_AddRef(This) (This)->lpVtbl->AddRef(This)
#define IBindCtx_Release(This)	(This)->lpVtbl->Release(This)
#define IBindCtx_RegisterObjectBound(T,p) (T)->lpVtbl->RegisterObjectBound(T,p)
#define IBindCtx_RevokeObjectBound(T,p)	(T)->lpVtbl->RevokeObjectBound(T,p)
#define IBindCtx_ReleaseBoundObjects(T) (T)->lpVtbl->ReleaseBoundObjects(T)
#define IBindCtx_SetBindOptions(T,p) (T)->lpVtbl->SetBindOptions(T,p)
#define IBindCtx_GetBindOptions(This,pbindopts)	\
	(This)->lpVtbl->GetBindOptions(This,pbindopts)
#define IBindCtx_GetRunningObjectTable(This,pprot)	\
	(This)->lpVtbl->GetRunningObjectTable(This,pprot)
#define IBindCtx_RegisterObjectParam(This,pszKey,punk)	\
	(This)->lpVtbl->RegisterObjectParam(This,pszKey,punk)
#define IBindCtx_GetObjectParam(This,pszKey,ppunk)	\
	(This)->lpVtbl->GetObjectParam(This,pszKey,ppunk)
#define IBindCtx_EnumObjectParam(This,ppenum)	\
	(This)->lpVtbl->EnumObjectParam(This,ppenum)
#define IBindCtx_RevokeObjectParam(This,pszKey)	\
	(This)->lpVtbl->RevokeObjectParam(This,pszKey)
HRESULT _stdcall IBindCtx_RegisterObjectBound_Proxy(IBindCtx* This,IUnknown*punk);
void _stdcall IBindCtx_RegisterObjectBound_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
HRESULT _stdcall IBindCtx_RevokeObjectBound_Proxy(IBindCtx* This,IUnknown*punk);
void _stdcall IBindCtx_RevokeObjectBound_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
HRESULT _stdcall IBindCtx_ReleaseBoundObjects_Proxy(IBindCtx* This);
void _stdcall IBindCtx_ReleaseBoundObjects_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IBindCtx_SetBindOptions_Proxy(IBindCtx* This,BIND_OPTS*pbindopts);
void _stdcall IBindCtx_SetBindOptions_Stub(IRpcStubBuffer *This,IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
HRESULT _stdcall IBindCtx_GetBindOptions_Proxy(IBindCtx* This,BIND_OPTS*pbindopts);
void _stdcall IBindCtx_GetBindOptions_Stub(IRpcStubBuffer *,
	IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IBindCtx_GetRunningObjectTable_Proxy(IBindCtx*,IRunningObjectTable * *);
void _stdcall IBindCtx_GetRunningObjectTable_Stub(IRpcStubBuffer *,
	IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IBindCtx_RegisterObjectParam_Proxy(IBindCtx* This,
	LPCSTR pszKey,IUnknown*punk);
void _stdcall IBindCtx_RegisterObjectParam_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IBindCtx_GetObjectParam_Proxy(IBindCtx* This,
	LPCSTR pszKey,IUnknown * * ppunk);
void _stdcall IBindCtx_GetObjectParam_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
HRESULT _stdcall IBindCtx_EnumObjectParam_Proxy(IBindCtx* This,
	IEnumString * * ppenum);
void _stdcall IBindCtx_EnumObjectParam_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IBindCtx_RevokeObjectParam_Proxy(IBindCtx*,LPCSTR);
void _stdcall IBindCtx_RevokeObjectParam_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);

typedef IEnumMoniker*LPENUMMONIKER;
extern const IID IID_IEnumMoniker;
typedef struct IEnumMonikerVtbl { 
	HRESULT (_stdcall*QueryInterface )(IEnumMoniker*,REFIID,void * *);
	ULONG (_stdcall*AddRef )(IEnumMoniker* This);
	ULONG (_stdcall*Release )(IEnumMoniker* This);
	HRESULT (_stdcall*Next )(IEnumMoniker*,ULONG,IMoniker * *,ULONG*);
	HRESULT (_stdcall*Skip )(IEnumMoniker* This,ULONG celt);
	HRESULT (_stdcall*Reset )(IEnumMoniker* This); 
	HRESULT (_stdcall*Clone )(IEnumMoniker* This,IEnumMoniker * * ppenum);
} IEnumMonikerVtbl;
interface IEnumMoniker { struct IEnumMonikerVtbl*lpVtbl; };

#define IEnumMoniker_QueryInterface(T,r,p) (T)->lpVtbl->QueryInterface(T,r,p)
#define IEnumMoniker_AddRef(This)	\
	(This)->lpVtbl->AddRef(This)
#define IEnumMoniker_Release(This)	\
	(This)->lpVtbl->Release(This)
#define IEnumMoniker_Next(This,celt,rgelt,pceltFetched)	\
	(This)->lpVtbl->Next(This,celt,rgelt,pceltFetched)
#define IEnumMoniker_Skip(This,celt)	\
	(This)->lpVtbl->Skip(This,celt)
#define IEnumMoniker_Reset(This)	\
	(This)->lpVtbl->Reset(This)
#define IEnumMoniker_Clone(This,ppenum)	 (This)->lpVtbl->Clone(This,ppenum)
HRESULT _stdcall IEnumMoniker_RemoteNext_Proxy(IEnumMoniker* This,
	ULONG celt,IMoniker * * rgelt,ULONG*pceltFetched);
void _stdcall IEnumMoniker_RemoteNext_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IEnumMoniker_Skip_Proxy(IEnumMoniker* This,ULONG celt);
void _stdcall IEnumMoniker_Skip_Stub(IRpcStubBuffer *This,IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
HRESULT _stdcall IEnumMoniker_Reset_Proxy(IEnumMoniker* This);
void _stdcall IEnumMoniker_Reset_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IEnumMoniker_Clone_Proxy(IEnumMoniker*,IEnumMoniker * *);
void _stdcall IEnumMoniker_Clone_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,
	PRPC_MESSAGE,DWORD *);

typedef IRunnableObject*LPRUNNABLEOBJECT;
extern const IID IID_IRunnableObject;
typedef struct IRunnableObjectVtbl {
	HRESULT (_stdcall*QueryInterface )(IRunnableObject*,REFIID,void * *);
	ULONG (_stdcall*AddRef )(IRunnableObject* This); 
	ULONG (_stdcall*Release )(IRunnableObject* This); 
	HRESULT (_stdcall*GetRunningClass )(IRunnableObject* This,LPCLSID lpClsid);
	HRESULT (_stdcall*Run )(IRunnableObject* This,LPBINDCTX pbc);
	BOOL (_stdcall*IsRunning )(IRunnableObject* This); 
	HRESULT (_stdcall*LockRunning )(IRunnableObject*,BOOL,BOOL);
	HRESULT (_stdcall*SetContainedObject )(IRunnableObject* This,BOOL fContained);
} IRunnableObjectVtbl;

interface IRunnableObject { struct IRunnableObjectVtbl*lpVtbl; };

#define IRunnableObject_QueryInterface(This,riid,ppvObject)	\
	(This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IRunnableObject_AddRef(This)	\
	(This)->lpVtbl->AddRef(This)
#define IRunnableObject_Release(This)	\
	(This)->lpVtbl->Release(This)
#define IRunnableObject_GetRunningClass(This,lpClsid)	\
	(This)->lpVtbl->GetRunningClass(This,lpClsid)
#define IRunnableObject_Run(This,pbc)	\
	(This)->lpVtbl->Run(This,pbc)
#define IRunnableObject_IsRunning(This)	\
	(This)->lpVtbl->IsRunning(This)
#define IRunnableObject_LockRunning(This,fLock,fLastUnlockCloses)	\
	(This)->lpVtbl->LockRunning(This,fLock,fLastUnlockCloses)
#define IRunnableObject_SetContainedObject(This,fContained)	\
	(This)->lpVtbl->SetContainedObject(This,fContained)
HRESULT _stdcall IRunnableObject_GetRunningClass_Proxy(IRunnableObject* This,
	LPCLSID lpClsid);
void _stdcall IRunnableObject_GetRunningClass_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IRunnableObject_Run_Proxy(IRunnableObject* This,
	LPBINDCTX pbc);
void _stdcall IRunnableObject_Run_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
BOOL _stdcall IRunnableObject_IsRunning_Proxy(IRunnableObject* This);
void _stdcall IRunnableObject_IsRunning_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IRunnableObject_LockRunning_Proxy(IRunnableObject* This,
	BOOL fLock,BOOL fLastUnlockCloses);
void _stdcall IRunnableObject_LockRunning_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IRunnableObject_SetContainedObject_Proxy(IRunnableObject* This,
	BOOL fContained);
void _stdcall IRunnableObject_SetContainedObject_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);


typedef IRunningObjectTable*LPRUNNINGOBJECTTABLE;
extern const IID IID_IRunningObjectTable;
typedef struct IRunningObjectTableVtbl {
	HRESULT (_stdcall*QueryInterface )(IRunningObjectTable* This,
	REFIID riid,void * * ppvObject);
	ULONG (_stdcall*AddRef )(IRunningObjectTable* This); 
	ULONG (_stdcall*Release )(IRunningObjectTable* This);
	HRESULT (_stdcall*Register)(IRunningObjectTable *,DWORD,IUnknown*,IMoniker *,DWORD *);
	HRESULT (_stdcall*Revoke )(IRunningObjectTable*,DWORD);
	HRESULT (_stdcall*IsRunning )(IRunningObjectTable*,IMoniker*);
	HRESULT (_stdcall*GetObject )(IRunningObjectTable* This,
	IMoniker*pmkObjectName,IUnknown * * ppunkObject);
	HRESULT (_stdcall*NoteChangeTime )(IRunningObjectTable* This,
	DWORD dwRegister,FILETIME*pfiletime);
	HRESULT (_stdcall*GetTimeOfLastChange )(IRunningObjectTable* This,
	IMoniker*pmkObjectName,FILETIME*pfiletime);
	HRESULT (_stdcall*EnumRunning )(IRunningObjectTable* This,
	IEnumMoniker * * ppenumMoniker);
} IRunningObjectTableVtbl;

interface IRunningObjectTable { struct IRunningObjectTableVtbl*lpVtbl; };

#define IRunningObjectTable_QueryInterface(This,riid,ppvObject)	\
	(This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IRunningObjectTable_AddRef(This) (This)->lpVtbl->AddRef(This)
#define IRunningObjectTable_Release(This) (This)->lpVtbl->Release(This)
#define IRunningObjectTable_Register(This,grfFlags,punkObject,pmkObjectName,pdwRegister)	\
	(This)->lpVtbl->Register(This,grfFlags,punkObject,pmkObjectName,pdwRegister)
#define IRunningObjectTable_Revoke(This,dwRegister)	\
	(This)->lpVtbl->Revoke(This,dwRegister)
#define IRunningObjectTable_IsRunning(This,pmkObjectName)	\
	(This)->lpVtbl->IsRunning(This,pmkObjectName)
#define IRunningObjectTable_GetObject(This,pmkObjectName,ppunkObject)	\
	(This)->lpVtbl->GetObject(This,pmkObjectName,ppunkObject)
#define IRunningObjectTable_NoteChangeTime(This,dwRegister,pfiletime)	\
	(This)->lpVtbl->NoteChangeTime(This,dwRegister,pfiletime)
#define IRunningObjectTable_GetTimeOfLastChange(This,pmkObjectName,pfiletime)	\
	(This)->lpVtbl->GetTimeOfLastChange(This,pmkObjectName,pfiletime)
#define IRunningObjectTable_EnumRunning(This,ppenumMoniker)	\
	(This)->lpVtbl->EnumRunning(This,ppenumMoniker)
HRESULT _stdcall IRunningObjectTable_Register_Proxy(IRunningObjectTable* This,
	DWORD grfFlags,IUnknown*punkObject,IMoniker*pmkObjectName,DWORD*pdwRegister);
void _stdcall IRunningObjectTable_Register_Stub(IRpcStubBuffer *,
	IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IRunningObjectTable_Revoke_Proxy(IRunningObjectTable*,DWORD);
void _stdcall IRunningObjectTable_Revoke_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IRunningObjectTable_IsRunning_Proxy(IRunningObjectTable* This,
	IMoniker*pmkObjectName);
void _stdcall IRunningObjectTable_IsRunning_Stub(IRpcStubBuffer *,
	IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IRunningObjectTable_GetObject_Proxy(IRunningObjectTable*,IMoniker*,IUnknown * *);
void _stdcall IRunningObjectTable_GetObject_Stub(IRpcStubBuffer *,
	IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IRunningObjectTable_NoteChangeTime_Proxy(IRunningObjectTable*,
	DWORD,FILETIME *);
void _stdcall IRunningObjectTable_NoteChangeTime_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IRunningObjectTable_GetTimeOfLastChange_Proxy(
	IRunningObjectTable* This,IMoniker*pmkObjectName,FILETIME*pfiletime);
void _stdcall IRunningObjectTable_GetTimeOfLastChange_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IRunningObjectTable_EnumRunning_Proxy(IRunningObjectTable* This,
	IEnumMoniker * * ppenumMoniker);
void _stdcall IRunningObjectTable_EnumRunning_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);


typedef IPersist*LPPERSIST;
extern const IID IID_IPersist;

typedef struct IPersistVtbl {
	HRESULT (_stdcall*QueryInterface )(IPersist* This,REFIID riid,void * * ppvObject);
	ULONG (_stdcall*AddRef )(IPersist* This); 
	ULONG (_stdcall*Release )(IPersist* This); 
	HRESULT (_stdcall*GetClassID )(IPersist* This,CLSID*pClassID);
} IPersistVtbl;

interface IPersist { struct IPersistVtbl*lpVtbl; };
#define IPersist_QueryInterface(T,r,p) (T)->lpVtbl->QueryInterface(T,r,p)
#define IPersist_AddRef(This)	(This)->lpVtbl->AddRef(This)
#define IPersist_Release(This)	(This)->lpVtbl->Release(This)
#define IPersist_GetClassID(This,pClassID) (This)->lpVtbl->GetClassID(This,pClassID)
HRESULT _stdcall IPersist_GetClassID_Proxy(IPersist* This,CLSID*pClassID);
void _stdcall IPersist_GetClassID_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);

typedef IPersistStream*LPPERSISTSTREAM;
extern const IID IID_IPersistStream;
typedef struct IPersistStreamVtbl {
	HRESULT (_stdcall*QueryInterface )(IPersistStream* This,REFIID riid,void * * ppvObject);
	ULONG (_stdcall*AddRef )(IPersistStream* This);
	ULONG (_stdcall*Release )(IPersistStream* This);
	HRESULT (_stdcall*GetClassID )(IPersistStream* This,CLSID*pClassID);
	HRESULT (_stdcall*IsDirty )(IPersistStream* This);
	HRESULT (_stdcall*Load )(IPersistStream* This,IStream*pStm); 
	HRESULT (_stdcall*Save )(IPersistStream* This,IStream*pStm,BOOL fClearDirty);
	HRESULT (_stdcall*GetSizeMax )(IPersistStream* This,ULARGE_INTEGER*pcbSize);
	} IPersistStreamVtbl;

interface IPersistStream { struct IPersistStreamVtbl*lpVtbl; };

#define IPersistStream_QueryInterface(T,r,p) (T)->lpVtbl->QueryInterface(T,r,p)
#define IPersistStream_AddRef(This)	(This)->lpVtbl->AddRef(This)
#define IPersistStream_Release(This)	(This)->lpVtbl->Release(This)
#define IPersistStream_GetClassID(T,p) (T)->lpVtbl->GetClassID(T,p)
#define IPersistStream_IsDirty(This)	(This)->lpVtbl->IsDirty(This)
#define IPersistStream_Load(This,pStm)	(This)->lpVtbl->Load(This,pStm)
#define IPersistStream_Save(T,p,f) (T)->lpVtbl->Save(T,p,f)
#define IPersistStream_GetSizeMax(T,p) (T)->lpVtbl->GetSizeMax(T,p)

HRESULT _stdcall IPersistStream_IsDirty_Proxy(IPersistStream* This);
void _stdcall IPersistStream_IsDirty_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IPersistStream_Load_Proxy(IPersistStream* This,IStream*pStm);
void _stdcall IPersistStream_Load_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IPersistStream_Save_Proxy(IPersistStream* This,
	IStream*pStm,BOOL fClearDirty);
void _stdcall IPersistStream_Save_Stub(IRpcStubBuffer *This,IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
HRESULT _stdcall IPersistStream_GetSizeMax_Proxy(IPersistStream* This,
	ULARGE_INTEGER*pcbSize);
void _stdcall IPersistStream_GetSizeMax_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);

typedef IMoniker*LPMONIKER;
typedef enum tagMKSYS
	{	MKSYS_NONE	= 0,
	MKSYS_GENERICCOMPOSITE	= 1,
	MKSYS_FILEMONIKER	= 2,
	MKSYS_ANTIMONIKER	= 3,
	MKSYS_ITEMMONIKER	= 4,
	MKSYS_POINTERMONIKER	= 5
	}	MKSYS;
typedef enum tagMKREDUCE
	{	MKRREDUCE_ONE	= 3 << 16,
	MKRREDUCE_TOUSER	= 2 << 16,
	MKRREDUCE_THROUGHUSER	= 1 << 16,
	MKRREDUCE_ALL	= 0
	}	MKRREDUCE;

extern const IID IID_IMoniker;
typedef struct IMonikerVtbl {
	HRESULT (_stdcall*QueryInterface )(IMoniker* This,REFIID riid,void * * ppvObject);
	ULONG (_stdcall*AddRef )(IMoniker* This); 
	ULONG (_stdcall*Release )(IMoniker* This);
	HRESULT (_stdcall*GetClassID )(IMoniker* This,CLSID*pClassID);
	HRESULT (_stdcall*IsDirty )(IMoniker* This); 
	HRESULT (_stdcall*Load )(IMoniker* This,IStream*pStm);
	HRESULT (_stdcall*Save )(IMoniker* This,IStream*pStm,BOOL fClearDirty);
	HRESULT (_stdcall*GetSizeMax )(IMoniker* This,ULARGE_INTEGER*pcbSize);
	HRESULT (_stdcall*BindToObject )(IMoniker* This,IBindCtx*pbc,
	IMoniker*pmkToLeft,REFIID riidResult,void * * ppvResult);
	HRESULT (_stdcall*BindToStorage )(IMoniker* This,IBindCtx*pbc,
	IMoniker*pmkToLeft,REFIID riid,void * * ppvObj);
	HRESULT (_stdcall*Reduce )(IMoniker* This,IBindCtx*pbc,DWORD dwReduceHowFar,
	IMoniker * * ppmkToLeft,IMoniker * * ppmkReduced);
	HRESULT (_stdcall*ComposeWith )(IMoniker* This,IMoniker*pmkRight,
	BOOL fOnlyIfNotGeneric,IMoniker * * ppmkComposite);
	HRESULT (_stdcall*Enum )(IMoniker* This,BOOL fForward,IEnumMoniker * * ppenumMoniker);
	HRESULT (_stdcall*IsEqual )(IMoniker* This,IMoniker*pmkOtherMoniker);
	HRESULT (_stdcall*Hash )(IMoniker* This,DWORD*pdwHash);
	HRESULT (_stdcall*IsRunning )(IMoniker* This,IBindCtx*pbc,IMoniker*pmkToLeft,
	IMoniker*pmkNewlyRunning);
	HRESULT (_stdcall*GetTimeOfLastChange )(IMoniker* This,IBindCtx*pbc,
	IMoniker*pmkToLeft,FILETIME*pFileTime);
	HRESULT (_stdcall*Inverse )(IMoniker* This,IMoniker * * ppmk);
	HRESULT (_stdcall*CommonPrefixWith )(IMoniker* This,IMoniker*pmkOther,
	IMoniker * * ppmkPrefix);
	HRESULT (_stdcall*RelativePathTo )(IMoniker* This,IMoniker*pmkOther,
	IMoniker * * ppmkRelPath);
	HRESULT (_stdcall*GetDisplayName )(IMoniker* This,IBindCtx*pbc,
	IMoniker*pmkToLeft,LPCSTR*ppszDisplayName);
	HRESULT (_stdcall*ParseDisplayName )(IMoniker* This,IBindCtx*pbc,
	IMoniker*pmkToLeft,LPCSTR pszDisplayName,ULONG*pchEaten,IMoniker * * ppmkOut);
	HRESULT (_stdcall*IsSystemMoniker )(IMoniker* This,DWORD*pdwMksys);
} IMonikerVtbl;

interface IMoniker { struct IMonikerVtbl*lpVtbl; };
	
#define IMoniker_QueryInterface(This,riid,ppvObject) (This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IMoniker_AddRef(This) (This)->lpVtbl->AddRef(This)
#define IMoniker_Release(This)	(This)->lpVtbl->Release(This)
#define IMoniker_GetClassID(This,pClassID) (This)->lpVtbl->GetClassID(This,pClassID)
#define IMoniker_IsDirty(This)	(This)->lpVtbl->IsDirty(This)
#define IMoniker_Load(This,pStm) (This)->lpVtbl->Load(This,pStm)
#define IMoniker_Save(This,pStm,fClearDirty) (This)->lpVtbl->Save(This,pStm,fClearDirty)
#define IMoniker_GetSizeMax(This,pcbSize) (This)->lpVtbl->GetSizeMax(This,pcbSize)
#define IMoniker_BindToObject(T,p,pm,r,pp) (T)->lpVtbl->BindToObject(T,p,pm,r,pp)
#define IMoniker_BindToStorage(This,pbc,pmkToLeft,riid,ppvObj)	\
	(This)->lpVtbl->BindToStorage(This,pbc,pmkToLeft,riid,ppvObj)
#define IMoniker_Reduce(This,pbc,dwReduceHowFar,ppmkToLeft,ppmkReduced)	\
	(This)->lpVtbl->Reduce(This,pbc,dwReduceHowFar,ppmkToLeft,ppmkReduced)
#define IMoniker_ComposeWith(This,pmkRight,fOnlyIfNotGeneric,ppmkComposite)	\
	(This)->lpVtbl->ComposeWith(This,pmkRight,fOnlyIfNotGeneric,ppmkComposite)
#define IMoniker_Enum(T,f,pp) (T)->lpVtbl->Enum(T,f,pp)
#define IMoniker_IsEqual(This,p) (This)->lpVtbl->IsEqual(This,p)
#define IMoniker_Hash(This,pdwHash) (This)->lpVtbl->Hash(This,pdwHash)
#define IMoniker_IsRunning(T,pbc,Left,N) (T)->lpVtbl->IsRunning(T,pbc,Left,N)
#define IMoniker_GetTimeOfLastChange(This,pbc,pmkToLeft,pFileTime)	\
	(This)->lpVtbl->GetTimeOfLastChange(This,pbc,pmkToLeft,pFileTime)
#define IMoniker_Inverse(This,ppmk) (This)->lpVtbl->Inverse(This,ppmk)
#define IMoniker_CommonPrefixWith(This,pmkOther,ppmkPrefix)	\
	(This)->lpVtbl->CommonPrefixWith(This,pmkOther,ppmkPrefix)
#define IMoniker_RelativePathTo(This,pmkOther,ppmkRelPath)	\
	(This)->lpVtbl->RelativePathTo(This,pmkOther,ppmkRelPath)
#define IMoniker_GetDisplayName(This,pbc,pmkToLeft,ppszDisplayName)	\
	(This)->lpVtbl->GetDisplayName(This,pbc,pmkToLeft,ppszDisplayName)
#define IMoniker_ParseDisplayName(This,pbc,pmkToLeft,pszDisplayName,pchEaten,ppmkOut)	\
	(This)->lpVtbl->ParseDisplayName(This,pbc,pmkToLeft,pszDisplayName,pchEaten,ppmkOut)
#define IMoniker_IsSystemMoniker(This,pdwMksys)	\
	(This)->lpVtbl->IsSystemMoniker(This,pdwMksys)
HRESULT _stdcall IMoniker_RemoteBindToObject_Proxy(IMoniker* This,IBindCtx*pbc,
	IMoniker*pmkToLeft,REFIID riidResult,IUnknown * * ppvResult);
void _stdcall IMoniker_RemoteBindToObject_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
HRESULT _stdcall IMoniker_RemoteBindToStorage_Proxy(IMoniker* This,IBindCtx*pbc,
	IMoniker*pmkToLeft,REFIID riid,IUnknown * * ppvObj);
void _stdcall IMoniker_RemoteBindToStorage_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
HRESULT _stdcall IMoniker_Reduce_Proxy(IMoniker* This,IBindCtx*pbc,
	DWORD dwReduceHowFar,IMoniker * * ppmkToLeft,IMoniker * * ppmkReduced);
void _stdcall IMoniker_Reduce_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
HRESULT _stdcall IMoniker_ComposeWith_Proxy(IMoniker* This,IMoniker*pmkRight,
	BOOL fOnlyIfNotGeneric,IMoniker * * ppmkComposite);
void _stdcall IMoniker_ComposeWith_Stub(IRpcStubBuffer *This,IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
HRESULT _stdcall IMoniker_Enum_Proxy(IMoniker* This,
	BOOL fForward,IEnumMoniker * * ppenumMoniker);
void _stdcall IMoniker_Enum_Stub(IRpcStubBuffer *This,IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
HRESULT _stdcall IMoniker_IsEqual_Proxy(IMoniker* This,IMoniker*pmkOtherMoniker);
void _stdcall IMoniker_IsEqual_Stub(IRpcStubBuffer *This,IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
HRESULT _stdcall IMoniker_Hash_Proxy(IMoniker* This,DWORD*pdwHash);
void _stdcall IMoniker_Hash_Stub(IRpcStubBuffer *This,IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
HRESULT _stdcall IMoniker_IsRunning_Proxy(IMoniker* This,IBindCtx*pbc,
	IMoniker*pmkToLeft,IMoniker*pmkNewlyRunning);
void _stdcall IMoniker_IsRunning_Stub(IRpcStubBuffer *This,IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
HRESULT _stdcall IMoniker_GetTimeOfLastChange_Proxy(IMoniker* This,
	IBindCtx*pbc,IMoniker*pmkToLeft,FILETIME*pFileTime);
void _stdcall IMoniker_GetTimeOfLastChange_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IMoniker_Inverse_Proxy(IMoniker* This,IMoniker * * ppmk);
void _stdcall IMoniker_Inverse_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IMoniker_CommonPrefixWith_Proxy(IMoniker* This,
	IMoniker*pmkOther,IMoniker * * ppmkPrefix);
void _stdcall IMoniker_CommonPrefixWith_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IMoniker_RelativePathTo_Proxy(IMoniker* This,
	IMoniker*pmkOther,IMoniker * * ppmkRelPath);
void _stdcall IMoniker_RelativePathTo_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IMoniker_GetDisplayName_Proxy(IMoniker* This,
	IBindCtx*pbc,IMoniker*pmkToLeft,LPCSTR*ppszDisplayName);
void _stdcall IMoniker_GetDisplayName_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IMoniker_ParseDisplayName_Proxy(IMoniker* This,
	IBindCtx*pbc,IMoniker*pmkToLeft,LPCSTR pszDisplayName,
	ULONG*pchEaten,IMoniker * * ppmkOut);
void _stdcall IMoniker_ParseDisplayName_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IMoniker_IsSystemMoniker_Proxy(IMoniker* This,
	DWORD*pdwMksys);
void _stdcall IMoniker_IsSystemMoniker_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);


extern const IID IID_IROTData;
typedef struct IROTDataVtbl {
	HRESULT (_stdcall*QueryInterface )(IROTData* This,REFIID riid,void * * ppvObject);
	ULONG (_stdcall*AddRef )(IROTData* This); 
	ULONG (_stdcall*Release )(IROTData* This);
	HRESULT (_stdcall*GetComparisonData )(IROTData* This,BYTE *pbData,
	ULONG cbMax,ULONG*pcbData);
} IROTDataVtbl;

interface IROTData { struct IROTDataVtbl*lpVtbl; };

#define IROTData_QueryInterface(This,riid,ppvObject)	\
	(This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IROTData_AddRef(This)	\
	(This)->lpVtbl->AddRef(This)
#define IROTData_Release(This)	\
	(This)->lpVtbl->Release(This)
#define IROTData_GetComparisonData(This,pbData,cbMax,pcbData)	\
	(This)->lpVtbl->GetComparisonData(This,pbData,cbMax,pcbData)

HRESULT _stdcall IROTData_GetComparisonData_Proxy(IROTData* This,
	BYTE *pbData,ULONG cbMax,ULONG*pcbData);
void _stdcall IROTData_GetComparisonData_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);


typedef IEnumString*LPENUMSTRING;
extern const IID IID_IEnumString;
typedef struct IEnumStringVtbl {
	HRESULT (_stdcall*QueryInterface )(IEnumString* This,REFIID riid,void * * ppvObject); 
	ULONG (_stdcall*AddRef )(IEnumString* This);
	ULONG (_stdcall*Release )(IEnumString* This);
	HRESULT (_stdcall*Next )(IEnumString* This,ULONG celt,LPCSTR*rgelt,ULONG*pceltFetched);
	HRESULT (_stdcall*Skip )(IEnumString* This,ULONG celt);
	HRESULT (_stdcall*Reset )(IEnumString* This);
	HRESULT (_stdcall*Clone )(IEnumString* This,IEnumString * * ppenum);
} IEnumStringVtbl;
interface IEnumString { struct IEnumStringVtbl*lpVtbl; };
#define IEnumString_QueryInterface(This,riid,ppvObject)	\
	(This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IEnumString_AddRef(This)	\
	(This)->lpVtbl->AddRef(This)
#define IEnumString_Release(This)	\
	(This)->lpVtbl->Release(This)
#define IEnumString_Next(This,celt,rgelt,pceltFetched)	\
	(This)->lpVtbl->Next(This,celt,rgelt,pceltFetched)
#define IEnumString_Skip(This,celt)	\
	(This)->lpVtbl->Skip(This,celt)
#define IEnumString_Reset(This)	\
	(This)->lpVtbl->Reset(This)
#define IEnumString_Clone(This,ppenum)	\
	(This)->lpVtbl->Clone(This,ppenum)

HRESULT _stdcall IEnumString_RemoteNext_Proxy(IEnumString* This,ULONG celt,
	LPCSTR*rgelt,ULONG*pceltFetched);
void _stdcall IEnumString_RemoteNext_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IEnumString_Skip_Proxy(IEnumString* This,ULONG celt);
void _stdcall IEnumString_Skip_Stub(IRpcStubBuffer *This,IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
HRESULT _stdcall IEnumString_Reset_Proxy(IEnumString* This);
void _stdcall IEnumString_Reset_Stub(IRpcStubBuffer *This,IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
HRESULT _stdcall IEnumString_Clone_Proxy(IEnumString* This,IEnumString * * ppenum);
void _stdcall IEnumString_Clone_Stub(IRpcStubBuffer *This,IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);


typedef IStream*LPSTREAM;
typedef struct tagSTATSTG {
	LPCSTR pwcsName;
	DWORD type;
	ULARGE_INTEGER cbSize;
	FILETIME mtime;
	FILETIME ctime;
	FILETIME atime;
	DWORD grfMode;
	DWORD grfLocksSupported;
	CLSID clsid;
	DWORD grfStateBits;
	DWORD reserved;
}	STATSTG;
typedef enum tagSTGTY {
	STGTY_STORAGE	= 1,
	STGTY_STREAM	= 2,
	STGTY_LOCKBYTES	= 3,
	STGTY_PROPERTY	= 4
}	STGTY;
typedef enum tagSTREAM_SEEK
	{	STREAM_SEEK_SET	= 0,
	STREAM_SEEK_CUR	= 1,
	STREAM_SEEK_END	= 2
	}	STREAM_SEEK;

typedef enum tagLOCKTYPE
	{	LOCK_WRITE	= 1,
	LOCK_EXCLUSIVE	= 2,
	LOCK_ONLYONCE	= 4
	}	LOCKTYPE;
extern const IID IID_IStream;
typedef struct IStreamVtbl {
	HRESULT (_stdcall*QueryInterface )(IStream* This,REFIID riid,void * * ppvObject);
	ULONG (_stdcall*AddRef )(IStream* This); 
	ULONG (_stdcall*Release )(IStream* This);
	HRESULT (_stdcall*Read )(IStream* This,void*pv,ULONG cb,ULONG*pcbRead);
	HRESULT (_stdcall*Write )(IStream* This,void*pv,ULONG cb,ULONG*pcbWritten);
	HRESULT (_stdcall*Seek )(IStream*,LARGE_INTEGER,DWORD,ULARGE_INTEGER*);
	HRESULT (_stdcall*SetSize )(IStream* This,ULARGE_INTEGER libNewSize);
	HRESULT (_stdcall*CopyTo )(IStream*,IStream*,ULARGE_INTEGER,ULARGE_INTEGER*,ULARGE_INTEGER*);
	HRESULT (_stdcall*Commit )(IStream* This,DWORD grfCommitFlags);
	HRESULT (_stdcall*Revert )(IStream* This);
	HRESULT (_stdcall*LockRegion )(IStream* This,ULARGE_INTEGER libOffset,
	ULARGE_INTEGER cb,DWORD dwLockType);
	HRESULT (_stdcall*UnlockRegion )(IStream* This,ULARGE_INTEGER libOffset,
	ULARGE_INTEGER cb,DWORD dwLockType);
	HRESULT (_stdcall*Stat )(IStream* This,STATSTG*pstatstg,DWORD grfStatFlag);
	HRESULT (_stdcall*Clone )(IStream* This,IStream * * ppstm);
} IStreamVtbl;

interface IStream { struct IStreamVtbl*lpVtbl; };
#define IStream_QueryInterface(This,riid,ppvObject)	\
	(This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IStream_AddRef(This)	\
	(This)->lpVtbl->AddRef(This)
#define IStream_Release(This)	\
	(This)->lpVtbl->Release(This)
#define IStream_Read(This,pv,cb,pcbRead)	\
	(This)->lpVtbl->Read(This,pv,cb,pcbRead)
#define IStream_Write(This,pv,cb,pcbWritten)	\
	(This)->lpVtbl->Write(This,pv,cb,pcbWritten)
#define IStream_Seek(This,dlibMove,dwOrigin,plibNewPosition)	\
	(This)->lpVtbl->Seek(This,dlibMove,dwOrigin,plibNewPosition)
#define IStream_SetSize(This,libNewSize)	\
	(This)->lpVtbl->SetSize(This,libNewSize)
#define IStream_CopyTo(This,pstm,cb,pcbRead,pcbWritten)	\
	(This)->lpVtbl->CopyTo(This,pstm,cb,pcbRead,pcbWritten)
#define IStream_Commit(This,grfCommitFlags)	\
	(This)->lpVtbl->Commit(This,grfCommitFlags)
#define IStream_Revert(This)	\
	(This)->lpVtbl->Revert(This)
#define IStream_LockRegion(This,libOffset,cb,dwLockType)	\
	(This)->lpVtbl->LockRegion(This,libOffset,cb,dwLockType)
#define IStream_UnlockRegion(This,libOffset,cb,dwLockType)	\
	(This)->lpVtbl->UnlockRegion(This,libOffset,cb,dwLockType)
#define IStream_Stat(This,pstatstg,grfStatFlag)	\
	(This)->lpVtbl->Stat(This,pstatstg,grfStatFlag)
#define IStream_Clone(This,ppstm)	\
	(This)->lpVtbl->Clone(This,ppstm)
HRESULT _stdcall IStream_RemoteRead_Proxy(IStream* This,BYTE*pv,
	ULONG cb,ULONG*pcbRead);
void _stdcall IStream_RemoteRead_Stub(IRpcStubBuffer *This,IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
HRESULT _stdcall IStream_RemoteWrite_Proxy(IStream* This,BYTE *pv,
	ULONG cb,ULONG*pcbWritten);
void _stdcall IStream_RemoteWrite_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IStream_RemoteSeek_Proxy(IStream* This,LARGE_INTEGER dlibMove,
	DWORD dwOrigin,ULARGE_INTEGER*plibNewPosition);
void _stdcall IStream_RemoteSeek_Stub(IRpcStubBuffer *This,IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
HRESULT _stdcall IStream_SetSize_Proxy(IStream* This,ULARGE_INTEGER libNewSize);
void _stdcall IStream_SetSize_Stub(IRpcStubBuffer *This,IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
HRESULT _stdcall IStream_RemoteCopyTo_Proxy(IStream* This,IStream*pstm,
	ULARGE_INTEGER cb,ULARGE_INTEGER*pcbRead,ULARGE_INTEGER*pcbWritten);
void _stdcall IStream_RemoteCopyTo_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IStream_Commit_Proxy(IStream* This,DWORD grfCommitFlags);
void _stdcall IStream_Commit_Stub(IRpcStubBuffer *This,IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
HRESULT _stdcall IStream_Revert_Proxy(IStream* This);
void _stdcall IStream_Revert_Stub(IRpcStubBuffer *This,IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
HRESULT _stdcall IStream_LockRegion_Proxy(IStream* This,ULARGE_INTEGER libOffset,
	ULARGE_INTEGER cb,DWORD dwLockType);
void _stdcall IStream_LockRegion_Stub(IRpcStubBuffer *This,IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
HRESULT _stdcall IStream_UnlockRegion_Proxy(IStream* This,
	ULARGE_INTEGER libOffset,ULARGE_INTEGER cb,DWORD dwLockType);
void _stdcall IStream_UnlockRegion_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
HRESULT _stdcall IStream_Stat_Proxy(IStream* This,STATSTG*pstatstg,
	DWORD grfStatFlag);
void _stdcall IStream_Stat_Stub(IRpcStubBuffer *This,IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
HRESULT _stdcall IStream_Clone_Proxy(IStream* This,IStream * * ppstm);
void _stdcall IStream_Clone_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);


typedef IEnumSTATSTG*LPENUMSTATSTG;
extern const IID IID_IEnumSTATSTG;

typedef struct IEnumSTATSTGVtbl {
	HRESULT (_stdcall*QueryInterface )(IEnumSTATSTG* This,REFIID riid,
	void * * ppvObject);
	ULONG (_stdcall*AddRef )(IEnumSTATSTG* This); 
	ULONG (_stdcall*Release )(IEnumSTATSTG* This); 
	HRESULT (_stdcall*Next )(IEnumSTATSTG* This,ULONG celt,STATSTG*rgelt,
	ULONG*pceltFetched);
	HRESULT (_stdcall*Skip )(IEnumSTATSTG* This,ULONG celt);
	HRESULT (_stdcall*Reset )(IEnumSTATSTG* This);
	HRESULT (_stdcall*Clone )(IEnumSTATSTG* This,IEnumSTATSTG * * ppenum);
} IEnumSTATSTGVtbl;

interface IEnumSTATSTG { struct IEnumSTATSTGVtbl*lpVtbl; };
#define IEnumSTATSTG_QueryInterface(T,r,p) (T)->lpVtbl->QueryInterface(T,r,p)
#define IEnumSTATSTG_AddRef(This) (This)->lpVtbl->AddRef(This)
#define IEnumSTATSTG_Release(This) (This)->lpVtbl->Release(This)
#define IEnumSTATSTG_Next(T,c,r,p) (T)->lpVtbl->Next(T,c,r,p)
#define IEnumSTATSTG_Skip(This,celt)	(This)->lpVtbl->Skip(This,celt)
#define IEnumSTATSTG_Reset(This) (This)->lpVtbl->Reset(This)
#define IEnumSTATSTG_Clone(This,ppenum)	 (This)->lpVtbl->Clone(This,ppenum)

HRESULT _stdcall IEnumSTATSTG_RemoteNext_Proxy(IEnumSTATSTG* This,
	ULONG celt,STATSTG*rgelt,ULONG*pceltFetched);
void _stdcall IEnumSTATSTG_RemoteNext_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IEnumSTATSTG_Skip_Proxy(IEnumSTATSTG* This,ULONG celt);
void _stdcall IEnumSTATSTG_Skip_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IEnumSTATSTG_Reset_Proxy(IEnumSTATSTG* This);
void _stdcall IEnumSTATSTG_Reset_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IEnumSTATSTG_Clone_Proxy(IEnumSTATSTG*,IEnumSTATSTG * *);
void _stdcall IEnumSTATSTG_Clone_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);

typedef IStorage*LPSTORAGE;

typedef struct tagRemSNB
	{
	unsigned long ulCntStr;
	unsigned long ulCntChar;
	OLECHAR rgString[ 1 ];
	}	RemSNB;
typedef OLECHAR * * SNB;
extern const IID IID_IStorage;

typedef struct IStorageVtbl {
	HRESULT(_stdcall*QueryInterface)(IStorage* This,REFIID riid,void * * ppvObject);
	ULONG (_stdcall*AddRef )(IStorage* This); 
	ULONG (_stdcall*Release )(IStorage* This);
	HRESULT (_stdcall*CreateStream )(IStorage* This,OLECHAR*pwcsName,
	DWORD grfMode,DWORD reserved1,DWORD reserved2,IStream * * ppstm);
	HRESULT (_stdcall*OpenStream )(IStorage* This,OLECHAR*pwcsName,
	void*reserved1,DWORD grfMode,DWORD reserved2,IStream * * ppstm);
	HRESULT (_stdcall*CreateStorage )(IStorage* This,const OLECHAR*pwcsName,
	DWORD grfMode,DWORD dwStgFmt,DWORD reserved2,IStorage * * ppstg);
	HRESULT (_stdcall*OpenStorage )(IStorage* This,OLECHAR*pwcsName,
	IStorage*pstgPriority,DWORD grfMode,SNB snbExclude,DWORD reserved,
	IStorage * * ppstg);
	HRESULT (_stdcall*CopyTo )(IStorage* This,DWORD ciidExclude,IID*rgiidExclude,
	SNB snbExclude,IStorage*pstgDest);
	HRESULT (_stdcall*MoveElementTo )(IStorage* This,OLECHAR*pwcsName,
	IStorage*pstgDest,OLECHAR*pwcsNewName,DWORD grfFlags);
	HRESULT (_stdcall*Commit )(IStorage* This,DWORD grfCommitFlags);
	HRESULT (_stdcall*Revert )(IStorage* This);
	HRESULT (_stdcall*EnumElements )(IStorage* This,DWORD reserved1,void*reserved2,
	DWORD reserved3,IEnumSTATSTG * * ppenum);
	HRESULT (_stdcall*DestroyElement )(IStorage* This,OLECHAR*pwcsName);
	HRESULT (_stdcall*RenameElement )(IStorage* This,OLECHAR*pwcsOldName,
	OLECHAR*pwcsNewName);
	HRESULT (_stdcall*SetElementTimes )(IStorage* This,const OLECHAR*pwcsName,
	const FILETIME*pctime,const FILETIME*patime,const FILETIME*pmtime);
	HRESULT (_stdcall*SetClass )(IStorage* This,REFCLSID clsid);
	HRESULT (_stdcall*SetStateBits )(IStorage* This,DWORD grfStateBits,
	DWORD grfMask);
	HRESULT (_stdcall*Stat )(IStorage* This,STATSTG*pstatstg,DWORD grfStatFlag);
} IStorageVtbl;

interface IStorage { struct IStorageVtbl*lpVtbl; };

#define IStorage_QueryInterface(T,r,p) (T)->lpVtbl->QueryInterface(T,r,p)
#define IStorage_AddRef(This)	 (This)->lpVtbl->AddRef(This)
#define IStorage_Release(This)	 (This)->lpVtbl->Release(This)
#define IStorage_CreateStream(T,p,g,r1,r2,pp) (T)->lpVtbl->CreateStream(T,p,g,r1,r2,pp)
#define IStorage_OpenStream(T,p,r1,g,r2,pp) (T)->lpVtbl->OpenStream(T,p,r1,g,r2,pp)
#define IStorage_CreateStorage(T,p,g,d,r2,pp) (This)->lpVtbl->CreateStorage(T,p,g,d,r2,pp)
#define IStorage_OpenStorage(This,pwcsName,pstgPriority,grfMode,snbExclude,reserved,ppstg)	\
	(This)->lpVtbl->OpenStorage(This,pwcsName,pstgPriority,grfMode,snbExclude,reserved,ppstg)
#define IStorage_CopyTo(This,ciidExclude,rgiidExclude,snbExclude,pstgDest)	\
	(This)->lpVtbl->CopyTo(This,ciidExclude,rgiidExclude,snbExclude,pstgDest)
#define IStorage_MoveElementTo(This,pwcsName,pstgDest,pwcsNewName,grfFlags)	\
	(This)->lpVtbl->MoveElementTo(This,pwcsName,pstgDest,pwcsNewName,grfFlags)
#define IStorage_Commit(This,g) (This)->lpVtbl->Commit(This,g)
#define IStorage_Revert(This) (This)->lpVtbl->Revert(This)
#define IStorage_EnumElements(This,reserved1,reserved2,reserved3,ppenum)	\
	(This)->lpVtbl->EnumElements(This,reserved1,reserved2,reserved3,ppenum)
#define IStorage_DestroyElement(This,pwcsName)	\
	(This)->lpVtbl->DestroyElement(This,pwcsName)
#define IStorage_RenameElement(This,pwcsOldName,pwcsNewName)	\
	(This)->lpVtbl->RenameElement(This,pwcsOldName,pwcsNewName)
#define IStorage_SetElementTimes(This,pwcsName,pctime,patime,pmtime)	\
	(This)->lpVtbl->SetElementTimes(This,pwcsName,pctime,patime,pmtime)
#define IStorage_SetClass(This,clsid) (This)->lpVtbl->SetClass(This,clsid)
#define IStorage_SetStateBits(This,grfStateBits,grfMask)	\
	(This)->lpVtbl->SetStateBits(This,grfStateBits,grfMask)
#define IStorage_Stat(This,p,g) (This)->lpVtbl->Stat(This,p,g)

HRESULT _stdcall IStorage_CreateStream_Proxy(IStorage* This,OLECHAR*pwcsName,
	DWORD grfMode,DWORD reserved1,DWORD reserved2,IStream * * ppstm);
void _stdcall IStorage_CreateStream_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IStorage_RemoteOpenStream_Proxy(IStorage* This,
	const OLECHAR*pwcsName,unsigned long cbReserved1,BYTE *reserved1,
	DWORD grfMode,DWORD reserved2,IStream * * ppstm);
void _stdcall IStorage_RemoteOpenStream_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IStorage_CreateStorage_Proxy(IStorage* This,
	OLECHAR*pwcsName,DWORD grfMode,DWORD dwStgFmt,DWORD reserved2,IStorage * * ppstg);
void _stdcall IStorage_CreateStorage_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
HRESULT _stdcall IStorage_OpenStorage_Proxy(IStorage* This,
	OLECHAR*pwcsName,IStorage*pstgPriority,DWORD grfMode,SNB snbExclude,
	DWORD reserved,IStorage * * ppstg);
void _stdcall IStorage_OpenStorage_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IStorage_CopyTo_Proxy(IStorage* This,
	DWORD ciidExclude,const IID*rgiidExclude,SNB snbExclude,IStorage*pstgDest);
void _stdcall IStorage_CopyTo_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IStorage_MoveElementTo_Proxy(IStorage* This,
	const OLECHAR*pwcsName,IStorage*pstgDest,const OLECHAR*pwcsNewName,
	DWORD grfFlags);
void _stdcall IStorage_MoveElementTo_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
HRESULT _stdcall IStorage_Commit_Proxy(IStorage* This,DWORD grfCommitFlags);
void _stdcall IStorage_Commit_Stub(IRpcStubBuffer *This,IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
HRESULT _stdcall IStorage_Revert_Proxy(IStorage* This);
void _stdcall IStorage_Revert_Stub(IRpcStubBuffer *This,IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
HRESULT _stdcall IStorage_RemoteEnumElements_Proxy(IStorage* This,DWORD reserved1,unsigned long cbReserved2,
	BYTE *reserved2,DWORD reserved3,IEnumSTATSTG * * ppenum);
void _stdcall IStorage_RemoteEnumElements_Stub(IRpcStubBuffer *This,IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
HRESULT _stdcall IStorage_DestroyElement_Proxy(IStorage* This,OLECHAR*pwcsName);
void _stdcall IStorage_DestroyElement_Stub(IRpcStubBuffer *This,IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
HRESULT _stdcall IStorage_RenameElement_Proxy(IStorage* This,
	const OLECHAR*pwcsOldName,const OLECHAR*pwcsNewName);
void _stdcall IStorage_RenameElement_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IStorage_SetElementTimes_Proxy(IStorage* This,
	const OLECHAR*pwcsName,const FILETIME*pctime,const FILETIME*patime,
	const FILETIME*pmtime);
void _stdcall IStorage_SetElementTimes_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IStorage_SetClass_Proxy(IStorage* This,REFCLSID clsid);
void _stdcall IStorage_SetClass_Stub(IRpcStubBuffer *This,IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
HRESULT _stdcall IStorage_SetStateBits_Proxy(IStorage* This,
	DWORD grfStateBits,DWORD grfMask);
void _stdcall IStorage_SetStateBits_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IStorage_Stat_Proxy(IStorage* This,
	STATSTG*pstatstg,DWORD grfStatFlag);
void _stdcall IStorage_Stat_Stub(IRpcStubBuffer *This,IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);


typedef IPersistFile*LPPERSISTFILE;
extern const IID IID_IPersistFile;
typedef struct IPersistFileVtbl {
	HRESULT (_stdcall*QueryInterface )(IPersistFile* This,REFIID riid,void * * ppvObject);
	ULONG (_stdcall*AddRef )(IPersistFile* This); 
	ULONG (_stdcall*Release )(IPersistFile* This); 
	HRESULT (_stdcall*GetClassID )(IPersistFile* This,CLSID*pClassID);
	HRESULT (_stdcall*IsDirty )(IPersistFile* This);
	HRESULT (_stdcall*Load )(IPersistFile* This,LPCOLESTR pszFileName,DWORD dwMode);
	HRESULT (_stdcall*Save )(IPersistFile* This,LPCOLESTR pszFileName,BOOL fRemember);
	HRESULT (_stdcall*SaveCompleted )(IPersistFile* This,LPCOLESTR pszFileName);
	HRESULT (_stdcall*GetCurFile )(IPersistFile* This,LPCSTR*ppszFileName);
} IPersistFileVtbl;

interface IPersistFile { struct IPersistFileVtbl*lpVtbl; };
#define IPersistFile_QueryInterface(This,riid,ppvObject)	\
	(This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IPersistFile_AddRef(This)	\
	(This)->lpVtbl->AddRef(This)
#define IPersistFile_Release(This)	\
	(This)->lpVtbl->Release(This)
#define IPersistFile_GetClassID(This,pClassID)	\
	(This)->lpVtbl->GetClassID(This,pClassID)
#define IPersistFile_IsDirty(This)	\
	(This)->lpVtbl->IsDirty(This)
#define IPersistFile_Load(This,pszFileName,dwMode)	\
	(This)->lpVtbl->Load(This,pszFileName,dwMode)

#define IPersistFile_Save(This,pszFileName,fRemember)	\
	(This)->lpVtbl->Save(This,pszFileName,fRemember)

#define IPersistFile_SaveCompleted(This,pszFileName)	\
	(This)->lpVtbl->SaveCompleted(This,pszFileName)

#define IPersistFile_GetCurFile(This,ppszFileName)	\
	(This)->lpVtbl->GetCurFile(This,ppszFileName)

HRESULT _stdcall IPersistFile_IsDirty_Proxy(IPersistFile* This);
void _stdcall IPersistFile_IsDirty_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
HRESULT _stdcall IPersistFile_Load_Proxy(IPersistFile* This,LPCOLESTR pszFileName,
	DWORD dwMode);
void _stdcall IPersistFile_Load_Stub(IRpcStubBuffer *This,IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
HRESULT _stdcall IPersistFile_Save_Proxy(IPersistFile* This,LPCOLESTR pszFileName,
	BOOL fRemember);
void _stdcall IPersistFile_Save_Stub(IRpcStubBuffer *This,IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
HRESULT _stdcall IPersistFile_SaveCompleted_Proxy(IPersistFile* This,
	LPCOLESTR pszFileName);
void _stdcall IPersistFile_SaveCompleted_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IPersistFile_GetCurFile_Proxy(IPersistFile* This,LPCSTR*ppszFileName);
void _stdcall IPersistFile_GetCurFile_Stub(IRpcStubBuffer *This,IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
typedef IPersistStorage*LPPERSISTSTORAGE;
extern const IID IID_IPersistStorage;

typedef struct IPersistStorageVtbl {
	HRESULT (_stdcall*QueryInterface )(IPersistStorage* This,REFIID riid,
	void * * ppvObject);
	ULONG (_stdcall*AddRef )(IPersistStorage* This);
	ULONG (_stdcall*Release )(IPersistStorage* This);
	HRESULT (_stdcall*GetClassID )(IPersistStorage* This,CLSID*pClassID);
	HRESULT (_stdcall*IsDirty )(IPersistStorage* This);
	HRESULT (_stdcall*InitNew )(IPersistStorage* This,IStorage*pStg);
	HRESULT (_stdcall*Load )(IPersistStorage* This,IStorage*pStg);
	HRESULT (_stdcall*Save )(IPersistStorage* This,IStorage*pStgSave,BOOL fSameAsLoad);
	HRESULT (_stdcall*SaveCompleted )(IPersistStorage* This,IStorage*pStgNew);
	HRESULT (_stdcall*HandsOffStorage )(IPersistStorage* This);
} IPersistStorageVtbl;

interface IPersistStorage { struct IPersistStorageVtbl*lpVtbl; };
#define IPersistStorage_QueryInterface(This,riid,ppvObject)	\
	(This)->lpVtbl->QueryInterface(This,riid,ppvObject)

#define IPersistStorage_AddRef(This)	\
	(This)->lpVtbl->AddRef(This)

#define IPersistStorage_Release(This)	\
	(This)->lpVtbl->Release(This)


#define IPersistStorage_GetClassID(This,pClassID)	\
	(This)->lpVtbl->GetClassID(This,pClassID)


#define IPersistStorage_IsDirty(This)	\
	(This)->lpVtbl->IsDirty(This)

#define IPersistStorage_InitNew(This,pStg)	\
	(This)->lpVtbl->InitNew(This,pStg)

#define IPersistStorage_Load(This,pStg)	\
	(This)->lpVtbl->Load(This,pStg)

#define IPersistStorage_Save(This,pStgSave,fSameAsLoad)	\
	(This)->lpVtbl->Save(This,pStgSave,fSameAsLoad)

#define IPersistStorage_SaveCompleted(This,pStgNew)	\
	(This)->lpVtbl->SaveCompleted(This,pStgNew)

#define IPersistStorage_HandsOffStorage(This)	\
	(This)->lpVtbl->HandsOffStorage(This)


	HRESULT _stdcall IPersistStorage_IsDirty_Proxy(
	IPersistStorage* This);


void _stdcall IPersistStorage_IsDirty_Stub(
	IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);


	HRESULT _stdcall IPersistStorage_InitNew_Proxy(
	IPersistStorage* This,
	IStorage*pStg);


void _stdcall IPersistStorage_InitNew_Stub(
	IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);


	HRESULT _stdcall IPersistStorage_Load_Proxy(
	IPersistStorage* This,
	IStorage*pStg);


void _stdcall IPersistStorage_Load_Stub(
	IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);


	HRESULT _stdcall IPersistStorage_Save_Proxy(
	IPersistStorage* This,
	IStorage*pStgSave,
	BOOL fSameAsLoad);


void _stdcall IPersistStorage_Save_Stub(
	IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);


	HRESULT _stdcall IPersistStorage_SaveCompleted_Proxy(
	IPersistStorage* This,
	IStorage*pStgNew);


void _stdcall IPersistStorage_SaveCompleted_Stub(
	IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);


	HRESULT _stdcall IPersistStorage_HandsOffStorage_Proxy(
	IPersistStorage* This);


void _stdcall IPersistStorage_HandsOffStorage_Stub(
	IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);



typedef ILockBytes*LPLOCKBYTES;
extern const IID IID_ILockBytes;

	typedef struct ILockBytesVtbl
	{
	
	HRESULT (_stdcall*QueryInterface )(
	ILockBytes* This,
	REFIID riid,
	void * * ppvObject);
	
	ULONG (_stdcall*AddRef )(
	ILockBytes* This);
	
	ULONG (_stdcall*Release )(
	ILockBytes* This);
	
	HRESULT (_stdcall*ReadAt )(
	ILockBytes* This,
	ULARGE_INTEGER ulOffset,
	void*pv,
	ULONG cb,
	ULONG*pcbRead);
	
	HRESULT (_stdcall*WriteAt )(
	ILockBytes* This,
	ULARGE_INTEGER ulOffset,
	const void*pv,
	ULONG cb,
	ULONG*pcbWritten);
	
	HRESULT (_stdcall*Flush )(
	ILockBytes* This);
	
	HRESULT (_stdcall*SetSize )(
	ILockBytes* This,
	ULARGE_INTEGER cb);
	
	HRESULT (_stdcall*LockRegion )(
	ILockBytes* This,
	ULARGE_INTEGER libOffset,
	ULARGE_INTEGER cb,
	DWORD dwLockType);
	
	HRESULT (_stdcall*UnlockRegion )(
	ILockBytes* This,
	ULARGE_INTEGER libOffset,
	ULARGE_INTEGER cb,
	DWORD dwLockType);
	
	HRESULT (_stdcall*Stat )(
	ILockBytes* This,
	STATSTG*pstatstg,
	DWORD grfStatFlag);
	
	} ILockBytesVtbl;

interface ILockBytes { struct ILockBytesVtbl*lpVtbl; };

#define ILockBytes_QueryInterface(This,riid,ppvObject)	\
	(This)->lpVtbl->QueryInterface(This,riid,ppvObject)

#define ILockBytes_AddRef(This)	\
	(This)->lpVtbl->AddRef(This)

#define ILockBytes_Release(This)	\
	(This)->lpVtbl->Release(This)


#define ILockBytes_ReadAt(This,ulOffset,pv,cb,pcbRead)	\
	(This)->lpVtbl->ReadAt(This,ulOffset,pv,cb,pcbRead)

#define ILockBytes_WriteAt(This,ulOffset,pv,cb,pcbWritten)	\
	(This)->lpVtbl->WriteAt(This,ulOffset,pv,cb,pcbWritten)

#define ILockBytes_Flush(This)	\
	(This)->lpVtbl->Flush(This)

#define ILockBytes_SetSize(This,cb)	\
	(This)->lpVtbl->SetSize(This,cb)

#define ILockBytes_LockRegion(This,libOffset,cb,dwLockType)	\
	(This)->lpVtbl->LockRegion(This,libOffset,cb,dwLockType)

#define ILockBytes_UnlockRegion(This,libOffset,cb,dwLockType)	\
	(This)->lpVtbl->UnlockRegion(This,libOffset,cb,dwLockType)

#define ILockBytes_Stat(This,pstatstg,grfStatFlag)	\
	(This)->lpVtbl->Stat(This,pstatstg,grfStatFlag)

	HRESULT _stdcall ILockBytes_RemoteReadAt_Proxy(ILockBytes* This,
	ULARGE_INTEGER ulOffset,BYTE *pv,ULONG cb,ULONG*pcbRead);

void _stdcall ILockBytes_RemoteReadAt_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);

HRESULT _stdcall ILockBytes_RemoteWriteAt_Proxy(ILockBytes* This,ULARGE_INTEGER ulOffset,
	BYTE *pv,ULONG cb,ULONG*pcbWritten);

void _stdcall ILockBytes_RemoteWriteAt_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall ILockBytes_Flush_Proxy(ILockBytes* This);
void _stdcall ILockBytes_Flush_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall ILockBytes_SetSize_Proxy(ILockBytes* This,ULARGE_INTEGER cb);
void _stdcall ILockBytes_SetSize_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall ILockBytes_LockRegion_Proxy(ILockBytes* This,ULARGE_INTEGER libOffset,
	ULARGE_INTEGER cb,DWORD dwLockType);
void _stdcall ILockBytes_LockRegion_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall ILockBytes_UnlockRegion_Proxy(ILockBytes* This,
	ULARGE_INTEGER libOffset,ULARGE_INTEGER cb,DWORD dwLockType);
void _stdcall ILockBytes_UnlockRegion_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall ILockBytes_Stat_Proxy(ILockBytes* This,
	STATSTG*pstatstg,DWORD grfStatFlag);
void _stdcall ILockBytes_Stat_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
typedef IEnumFORMATETC *LPENUMFORMATETC;
typedef struct tagDVTARGETDEVICE
	{
	DWORD tdSize;
	WORD tdDriverNameOffset;
	WORD tdDeviceNameOffset;
	WORD tdPortNameOffset;
	WORD tdExtDevmodeOffset;
	BYTE tdData[ 1 ];
	}	DVTARGETDEVICE;

typedef WORD CLIPFORMAT;
typedef CLIPFORMAT*LPCLIPFORMAT;
typedef struct tagFORMATETC
	{
	CLIPFORMAT cfFormat;
	DVTARGETDEVICE*ptd;
	DWORD dwAspect;
	LONG lindex;
	DWORD tymed;
	}	FORMATETC;
typedef struct tagFORMATETC *LPFORMATETC;
extern const IID IID_IEnumFORMATETC;
typedef struct IEnumFORMATETCVtbl
{
	
HRESULT (_stdcall*QueryInterface )(IEnumFORMATETC * This,REFIID riid,
	void * * ppvObject);
	
	ULONG (_stdcall*AddRef )(
	IEnumFORMATETC * This);
	
	ULONG (_stdcall*Release )(
	IEnumFORMATETC * This);
	
	HRESULT (_stdcall*Next )(
	IEnumFORMATETC * This,
	ULONG celt,
	FORMATETC *rgelt,
	ULONG*pceltFetched);
	
	HRESULT (_stdcall*Skip )(
	IEnumFORMATETC * This,
	ULONG celt);
	
	HRESULT (_stdcall*Reset )(
	IEnumFORMATETC * This);
	
	HRESULT (_stdcall*Clone )(
	IEnumFORMATETC * This,
	IEnumFORMATETC * * ppenum);
	
	} IEnumFORMATETCVtbl;

interface IEnumFORMATETC { struct IEnumFORMATETCVtbl*lpVtbl; };
#define IEnumFORMATETC_QueryInterface(This,riid,ppvObject)	\
	(This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IEnumFORMATETC_AddRef(This)	\
	(This)->lpVtbl->AddRef(This)
#define IEnumFORMATETC_Release(This)	\
	(This)->lpVtbl->Release(This)
#define IEnumFORMATETC_Next(This,celt,rgelt,pceltFetched)	\
	(This)->lpVtbl->Next(This,celt,rgelt,pceltFetched)
#define IEnumFORMATETC_Skip(This,celt)	\
	(This)->lpVtbl->Skip(This,celt)
#define IEnumFORMATETC_Reset(This)	\
	(This)->lpVtbl->Reset(This)
#define IEnumFORMATETC_Clone(This,ppenum)	\
	(This)->lpVtbl->Clone(This,ppenum)

	HRESULT _stdcall IEnumFORMATETC_RemoteNext_Proxy(
	IEnumFORMATETC * This,
	ULONG celt,
	FORMATETC *rgelt,
	ULONG*pceltFetched);


void _stdcall IEnumFORMATETC_RemoteNext_Stub(
	IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);


	HRESULT _stdcall IEnumFORMATETC_Skip_Proxy(
	IEnumFORMATETC * This,
	ULONG celt);


void _stdcall IEnumFORMATETC_Skip_Stub(
	IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);


	HRESULT _stdcall IEnumFORMATETC_Reset_Proxy(
	IEnumFORMATETC * This);


void _stdcall IEnumFORMATETC_Reset_Stub(
	IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);


	HRESULT _stdcall IEnumFORMATETC_Clone_Proxy(
	IEnumFORMATETC * This,
	IEnumFORMATETC * * ppenum);


void _stdcall IEnumFORMATETC_Clone_Stub(
	IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);


typedef IEnumSTATDATA*LPENUMSTATDATA;
typedef 
enum tagADVF
	{	ADVF_NODATA	= 1,
	ADVF_PRIMEFIRST	= 2,
	ADVF_ONLYONCE	= 4,
	ADVF_DATAONSTOP	= 64,
	ADVFCACHE_NOHANDLER	= 8,
	ADVFCACHE_FORCEBUILTIN	= 16,
	ADVFCACHE_ONSAVE	= 32
	}	ADVF;

typedef struct tagSTATDATA
	{
	FORMATETC formatetc;
	DWORD advf;
	IAdviseSink*pAdvSink;
	DWORD dwConnection;
	}	STATDATA;

typedef STATDATA*LPSTATDATA;
extern const IID IID_IEnumSTATDATA;

typedef struct IEnumSTATDATAVtbl
	{
	
	HRESULT (_stdcall*QueryInterface )(
	IEnumSTATDATA* This,
	REFIID riid,
	void * * ppvObject);
	
	ULONG (_stdcall*AddRef )(
	IEnumSTATDATA* This);
	
	ULONG (_stdcall*Release )(
	IEnumSTATDATA* This);
	
	HRESULT (_stdcall*Next )(
	IEnumSTATDATA* This,
	ULONG celt,
	STATDATA*rgelt,
	ULONG*pceltFetched);
	
	HRESULT (_stdcall*Skip )(
	IEnumSTATDATA* This,
	ULONG celt);
	
	HRESULT (_stdcall*Reset )(
	IEnumSTATDATA* This);
	
	HRESULT (_stdcall*Clone )(
	IEnumSTATDATA* This,
	IEnumSTATDATA * * ppenum);
	
	} IEnumSTATDATAVtbl;

interface IEnumSTATDATA { struct IEnumSTATDATAVtbl*lpVtbl; };

#define IEnumSTATDATA_QueryInterface(This,riid,ppvObject)	\
	(This)->lpVtbl->QueryInterface(This,riid,ppvObject)

#define IEnumSTATDATA_AddRef(This)	\
	(This)->lpVtbl->AddRef(This)

#define IEnumSTATDATA_Release(This)	\
	(This)->lpVtbl->Release(This)


#define IEnumSTATDATA_Next(This,celt,rgelt,pceltFetched)	\
	(This)->lpVtbl->Next(This,celt,rgelt,pceltFetched)

#define IEnumSTATDATA_Skip(This,celt)	\
	(This)->lpVtbl->Skip(This,celt)

#define IEnumSTATDATA_Reset(This)	\
	(This)->lpVtbl->Reset(This)

#define IEnumSTATDATA_Clone(This,ppenum)	\
	(This)->lpVtbl->Clone(This,ppenum)


	HRESULT _stdcall IEnumSTATDATA_RemoteNext_Proxy(IEnumSTATDATA* This,
	ULONG celt,STATDATA*rgelt,ULONG*pceltFetched);


void _stdcall IEnumSTATDATA_RemoteNext_Stub(
	IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);

HRESULT _stdcall IEnumSTATDATA_Skip_Proxy(IEnumSTATDATA*,ULONG);
void _stdcall IEnumSTATDATA_Skip_Stub(IRpcStubBuffer *,
	IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IEnumSTATDATA_Reset_Proxy(IEnumSTATDATA* This);
void _stdcall IEnumSTATDATA_Reset_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IEnumSTATDATA_Clone_Proxy(IEnumSTATDATA* This,
	IEnumSTATDATA * * ppenum);
void _stdcall IEnumSTATDATA_Clone_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);

typedef IRootStorage*LPROOTSTORAGE;
extern const IID IID_IRootStorage;
typedef struct IRootStorageVtbl {
	HRESULT (_stdcall*QueryInterface )(IRootStorage* This,REFIID riid,
	void * * ppvObject);
	ULONG (_stdcall*AddRef )(IRootStorage* This);
	ULONG (_stdcall*Release )(IRootStorage* This);
	HRESULT (_stdcall*SwitchToFile )(IRootStorage* This,LPCSTR pszFile);
} IRootStorageVtbl;

interface IRootStorage { struct IRootStorageVtbl*lpVtbl; };

#define IRootStorage_QueryInterface(T,r,O) (T)->lpVtbl->QueryInterface(T,r,O)
#define IRootStorage_AddRef(This) (This)->lpVtbl->AddRef(This)
#define IRootStorage_Release(This)	 (This)->lpVtbl->Release(This)
#define IRootStorage_SwitchToFile(This,pszFile)	 (This)->lpVtbl->SwitchToFile(This,pszFile)
HRESULT _stdcall IRootStorage_SwitchToFile_Proxy(IRootStorage* This,LPCSTR pszFile);
void _stdcall IRootStorage_SwitchToFile_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);

typedef IAdviseSink*LPADVISESINK;
typedef enum tagTYMED
	{	TYMED_HGLOBAL	= 1,
	TYMED_FILE	= 2,
	TYMED_ISTREAM	= 4,
	TYMED_ISTORAGE	= 8,
	TYMED_GDI	= 16,
	TYMED_MFPICT	= 32,
	TYMED_ENHMF	= 64,
	TYMED_NULL	= 0
	}	TYMED;

#ifndef RC_INVOKED
#pragma warning(disable:4200)
#endif
typedef struct tagRemSTGMEDIUM {
	DWORD tymed;
	DWORD dwHandleType;
	unsigned long pData;
	unsigned long pUnkForRelease;
	unsigned long cbData;
	BYTE data[ 1 ];
	}	RemSTGMEDIUM;

#ifndef RC_INVOKED
#pragma warning(default:4200)
#endif
#ifdef NONAMELESSUNION
typedef struct tagSTGMEDIUM {
	DWORD tymed;
	union {
	HBITMAP hBitmap;
	void *hMetaFilePict;
	HENHMETAFILE hEnhMetaFile;
	HGLOBAL hGlobal;
	LPCSTR lpszFileName;
	IStream *pstm;
	IStorage *pstg;
	} u;
	IUnknown *pUnkForRelease;
}STGMEDIUM;
#else
typedef struct tagSTGMEDIUM
	{
	DWORD tymed;
	union 
	{
	HBITMAP hBitmap;
	void * hMetaFilePict;
	HENHMETAFILE hEnhMetaFile;
	HGLOBAL hGlobal;
	LPCSTR lpszFileName;
	IStream*pstm;
	IStorage*pstg;
	};
	IUnknown*pUnkForRelease;
	}	STGMEDIUM;

#endif /* !NONAMELESSUNION */
typedef STGMEDIUM*LPSTGMEDIUM;

extern const IID IID_IAdviseSink;

typedef struct IAdviseSinkVtbl {
	HRESULT (_stdcall*QueryInterface )(IAdviseSink* This,REFIID riid,
	void * * ppvObject);
	ULONG (_stdcall*AddRef )(IAdviseSink* This);
	ULONG (_stdcall*Release )(IAdviseSink* This); 
	void (_stdcall*OnDataChange )(IAdviseSink* This,FORMATETC *pFormatetc,
	STGMEDIUM*pStgmed); 
	void (_stdcall*OnViewChange )(IAdviseSink* This,DWORD dwAspect,
	LONG lindex);
	void (_stdcall*OnRename )(IAdviseSink* This,IMoniker*pmk);
	void (_stdcall*OnSave )(IAdviseSink* This);
	void (_stdcall*OnClose )(IAdviseSink* This);
} IAdviseSinkVtbl;

interface IAdviseSink { struct IAdviseSinkVtbl*lpVtbl; };
#define IAdviseSink_QueryInterface(This,riid,ppvObject)	\
	(This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IAdviseSink_AddRef(This)	\
	(This)->lpVtbl->AddRef(This)
#define IAdviseSink_Release(This)	\
	(This)->lpVtbl->Release(This)
#define IAdviseSink_OnDataChange(This,pFormatetc,pStgmed)	\
	(This)->lpVtbl->OnDataChange(This,pFormatetc,pStgmed)
#define IAdviseSink_OnViewChange(This,dwAspect,lindex)	\
	(This)->lpVtbl->OnViewChange(This,dwAspect,lindex)
#define IAdviseSink_OnRename(This,pmk)	\
	(This)->lpVtbl->OnRename(This,pmk)
#define IAdviseSink_OnSave(This)	\
	(This)->lpVtbl->OnSave(This)
#define IAdviseSink_OnClose(This)	\
	(This)->lpVtbl->OnClose(This)

void _stdcall IAdviseSink_RemoteOnDataChange_Proxy(IAdviseSink* This,
	FORMATETC *pFormatetc,RemSTGMEDIUM*pStgmed);
void _stdcall IAdviseSink_RemoteOnDataChange_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);

	void _stdcall IAdviseSink_RemoteOnViewChange_Proxy(IAdviseSink* This,
	DWORD dwAspect,LONG lindex);

void _stdcall IAdviseSink_RemoteOnViewChange_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);

void _stdcall IAdviseSink_RemoteOnRename_Proxy(IAdviseSink* This,IMoniker*pmk);

void _stdcall IAdviseSink_RemoteOnRename_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
void _stdcall IAdviseSink_RemoteOnSave_Proxy(IAdviseSink* This);
void _stdcall IAdviseSink_RemoteOnSave_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IAdviseSink_RemoteOnClose_Proxy(IAdviseSink* This);
void _stdcall IAdviseSink_RemoteOnClose_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
typedef IAdviseSink2*LPADVISESINK2;
extern const IID IID_IAdviseSink2;
typedef struct IAdviseSink2Vtbl {
	HRESULT (_stdcall*QueryInterface )(IAdviseSink2* This,REFIID riid,
	void * * ppvObject);
	ULONG (_stdcall*AddRef )(IAdviseSink2* This);
	ULONG (_stdcall*Release )(IAdviseSink2* This);
	void (_stdcall*OnDataChange )(IAdviseSink2* This,FORMATETC *pFormatetc,
	STGMEDIUM*pStgmed);
	void (_stdcall*OnViewChange )(IAdviseSink2* This,DWORD dwAspect,LONG lindex);
	void (_stdcall*OnRename )(IAdviseSink2* This,IMoniker*pmk);
	void (_stdcall*OnSave )(IAdviseSink2* This); 
	void (_stdcall*OnClose )(IAdviseSink2* This);
	void (_stdcall*OnLinkSrcChange )(IAdviseSink2* This,IMoniker*pmk);
} IAdviseSink2Vtbl;

interface IAdviseSink2 { struct IAdviseSink2Vtbl*lpVtbl; };
#define IAdviseSink2_QueryInterface(This,riid,ppvObject)	\
	(This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IAdviseSink2_AddRef(This)	\
	(This)->lpVtbl->AddRef(This)
#define IAdviseSink2_Release(This)	\
	(This)->lpVtbl->Release(This)
#define IAdviseSink2_OnDataChange(This,pFormatetc,pStgmed)	\
	(This)->lpVtbl->OnDataChange(This,pFormatetc,pStgmed)
#define IAdviseSink2_OnViewChange(This,dwAspect,lindex)	\
	(This)->lpVtbl->OnViewChange(This,dwAspect,lindex)
#define IAdviseSink2_OnRename(This,pmk)	\
	(This)->lpVtbl->OnRename(This,pmk)
#define IAdviseSink2_OnSave(This)	\
	(This)->lpVtbl->OnSave(This)
#define IAdviseSink2_OnClose(This)	\
	(This)->lpVtbl->OnClose(This)
#define IAdviseSink2_OnLinkSrcChange(This,pmk)	\
	(This)->lpVtbl->OnLinkSrcChange(This,pmk)
	void _stdcall IAdviseSink2_RemoteOnLinkSrcChange_Proxy(IAdviseSink2* This,IMoniker*pmk);
void _stdcall IAdviseSink2_RemoteOnLinkSrcChange_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
typedef IDataObject*LPDATAOBJECT;
typedef enum tagDATADIR
	{	DATADIR_GET	= 1,
	DATADIR_SET	= 2
	}	DATADIR;

extern const IID IID_IDataObject;

typedef struct IDataObjectVtbl {
	HRESULT (_stdcall*QueryInterface )(IDataObject* This,
	REFIID riid,void * * ppvObject);
	ULONG (_stdcall*AddRef )(IDataObject* This);
	ULONG (_stdcall*Release )(IDataObject* This);
	HRESULT (_stdcall*GetData )(IDataObject* This,FORMATETC *pformatetcIn,
	STGMEDIUM*pmedium);
	HRESULT (_stdcall*GetDataHere )(IDataObject* This,FORMATETC *pformatetc,
	STGMEDIUM*pmedium);
	HRESULT (_stdcall*QueryGetData )(IDataObject* This,FORMATETC *pformatetc);
	HRESULT (_stdcall*GetCanonicalFormatEtc )(IDataObject* This,FORMATETC *pformatectIn,
	FORMATETC *pformatetcOut);
	HRESULT (_stdcall*SetData )(IDataObject* This,FORMATETC *pformatetc,
	STGMEDIUM*pmedium,BOOL fRelease);
	HRESULT (_stdcall*EnumFormatEtc )(IDataObject* This,DWORD dwDirection,
	IEnumFORMATETC * * ppenumFormatEtc);
	HRESULT (_stdcall*DAdvise )(IDataObject* This,FORMATETC *pformatetc,
	DWORD advf,IAdviseSink*pAdvSink,DWORD*pdwConnection);
	HRESULT (_stdcall*DUnadvise )(IDataObject* This,DWORD dwConnection);
	HRESULT (_stdcall*EnumDAdvise )(IDataObject* This,IEnumSTATDATA * * ppenumAdvise);
} IDataObjectVtbl;

interface IDataObject { struct IDataObjectVtbl*lpVtbl; };

#define IDataObject_QueryInterface(This,riid,ppvObject)	\
	(This)->lpVtbl->QueryInterface(This,riid,ppvObject)

#define IDataObject_AddRef(This)	\
	(This)->lpVtbl->AddRef(This)

#define IDataObject_Release(This)	\
	(This)->lpVtbl->Release(This)


#define IDataObject_GetData(This,pformatetcIn,pmedium)	\
	(This)->lpVtbl->GetData(This,pformatetcIn,pmedium)

#define IDataObject_GetDataHere(This,pformatetc,pmedium)	\
	(This)->lpVtbl->GetDataHere(This,pformatetc,pmedium)

#define IDataObject_QueryGetData(This,pformatetc)	\
	(This)->lpVtbl->QueryGetData(This,pformatetc)

#define IDataObject_GetCanonicalFormatEtc(This,pformatectIn,pformatetcOut)	\
	(This)->lpVtbl->GetCanonicalFormatEtc(This,pformatectIn,pformatetcOut)

#define IDataObject_SetData(This,pformatetc,pmedium,fRelease)	\
	(This)->lpVtbl->SetData(This,pformatetc,pmedium,fRelease)

#define IDataObject_EnumFormatEtc(This,dwDirection,ppenumFormatEtc)	\
	(This)->lpVtbl->EnumFormatEtc(This,dwDirection,ppenumFormatEtc)

#define IDataObject_DAdvise(This,pformatetc,advf,pAdvSink,pdwConnection)	\
	(This)->lpVtbl->DAdvise(This,pformatetc,advf,pAdvSink,pdwConnection)

#define IDataObject_DUnadvise(This,dwConnection)	\
	(This)->lpVtbl->DUnadvise(This,dwConnection)

#define IDataObject_EnumDAdvise(This,ppenumAdvise)	\
	(This)->lpVtbl->EnumDAdvise(This,ppenumAdvise)


	HRESULT _stdcall IDataObject_RemoteGetData_Proxy(
	IDataObject* This,
	FORMATETC *pformatetcIn,
	RemSTGMEDIUM * * ppRemoteMedium);


void _stdcall IDataObject_RemoteGetData_Stub(
	IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);


	HRESULT _stdcall IDataObject_RemoteGetDataHere_Proxy(
	IDataObject* This,
	FORMATETC *pformatetc,
	RemSTGMEDIUM * * ppRemoteMedium);


void _stdcall IDataObject_RemoteGetDataHere_Stub(
	IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);


	HRESULT _stdcall IDataObject_QueryGetData_Proxy(
	IDataObject* This,
	FORMATETC *pformatetc);


void _stdcall IDataObject_QueryGetData_Stub(
	IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);

HRESULT _stdcall IDataObject_GetCanonicalFormatEtc_Proxy(IDataObject* This,
	FORMATETC *pformatectIn,FORMATETC *pformatetcOut);

void _stdcall IDataObject_GetCanonicalFormatEtc_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);

HRESULT _stdcall IDataObject_RemoteSetData_Proxy(IDataObject* This,
	FORMATETC *pformatetc,RemSTGMEDIUM*pmedium,BOOL fRelease);

void _stdcall IDataObject_RemoteSetData_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);


	HRESULT _stdcall IDataObject_EnumFormatEtc_Proxy(IDataObject* This,
	DWORD dwDirection,
	IEnumFORMATETC * * ppenumFormatEtc);


void _stdcall IDataObject_EnumFormatEtc_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);


	HRESULT _stdcall IDataObject_DAdvise_Proxy(
	IDataObject* This,
	FORMATETC *pformatetc,
	DWORD advf,
	IAdviseSink*pAdvSink,
	DWORD*pdwConnection);


void _stdcall IDataObject_DAdvise_Stub(
	IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);


	HRESULT _stdcall IDataObject_DUnadvise_Proxy(
	IDataObject* This,
	DWORD dwConnection);


void _stdcall IDataObject_DUnadvise_Stub(
	IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);


	HRESULT _stdcall IDataObject_EnumDAdvise_Proxy(
	IDataObject* This,
	IEnumSTATDATA * * ppenumAdvise);
void _stdcall IDataObject_EnumDAdvise_Stub(
	IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);


typedef IDataAdviseHolder*LPDATAADVISEHOLDER;
extern const IID IID_IDataAdviseHolder;
typedef struct IDataAdviseHolderVtbl {
	HRESULT (_stdcall*QueryInterface )(
	IDataAdviseHolder* This,
	REFIID riid,
	void * * ppvObject);
	
	ULONG (_stdcall*AddRef )(
	IDataAdviseHolder* This);
	
	ULONG (_stdcall*Release )(
	IDataAdviseHolder* This);
	
	HRESULT (_stdcall*Advise )(
	IDataAdviseHolder* This,
	IDataObject*pDataObject,
	FORMATETC *pFetc,
	DWORD advf,
	IAdviseSink*pAdvise,
	DWORD*pdwConnection);
	
	HRESULT (_stdcall*Unadvise )(
	IDataAdviseHolder* This,
	DWORD dwConnection);
	
	HRESULT (_stdcall*EnumAdvise )(
	IDataAdviseHolder* This,
	IEnumSTATDATA * * ppenumAdvise);
	HRESULT (_stdcall*SendOnDataChange )(
	IDataAdviseHolder* This,
	IDataObject*pDataObject,
	DWORD dwReserved,
	DWORD advf);
	} IDataAdviseHolderVtbl;

interface IDataAdviseHolder { struct IDataAdviseHolderVtbl*lpVtbl; };

#define IDataAdviseHolder_QueryInterface(This,riid,ppvObject)	\
	(This)->lpVtbl->QueryInterface(This,riid,ppvObject)

#define IDataAdviseHolder_AddRef(This)	\
	(This)->lpVtbl->AddRef(This)

#define IDataAdviseHolder_Release(This)	\
	(This)->lpVtbl->Release(This)


#define IDataAdviseHolder_Advise(This,pDataObject,pFetc,advf,pAdvise,pdwConnection)	\
	(This)->lpVtbl->Advise(This,pDataObject,pFetc,advf,pAdvise,pdwConnection)

#define IDataAdviseHolder_Unadvise(This,dwConnection)	\
	(This)->lpVtbl->Unadvise(This,dwConnection)

#define IDataAdviseHolder_EnumAdvise(This,ppenumAdvise)	\
	(This)->lpVtbl->EnumAdvise(This,ppenumAdvise)

#define IDataAdviseHolder_SendOnDataChange(This,pDataObject,dwReserved,advf)	\
	(This)->lpVtbl->SendOnDataChange(This,pDataObject,dwReserved,advf)


HRESULT _stdcall IDataAdviseHolder_Advise_Proxy(IDataAdviseHolder* This,
	IDataObject*pDataObject,
	FORMATETC *pFetc,
	DWORD advf,
	IAdviseSink*pAdvise,
	DWORD*pdwConnection);


void _stdcall IDataAdviseHolder_Advise_Stub(
	IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);

HRESULT _stdcall IDataAdviseHolder_Unadvise_Proxy(IDataAdviseHolder* This,
	DWORD dwConnection);

void _stdcall IDataAdviseHolder_Unadvise_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);

	HRESULT _stdcall IDataAdviseHolder_EnumAdvise_Proxy(IDataAdviseHolder* This,
	IEnumSTATDATA * * ppenumAdvise);

void _stdcall IDataAdviseHolder_EnumAdvise_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);


HRESULT _stdcall IDataAdviseHolder_SendOnDataChange_Proxy(IDataAdviseHolder* This,
	IDataObject*pDataObject,
	DWORD dwReserved,
	DWORD advf);


void _stdcall IDataAdviseHolder_SendOnDataChange_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);

typedef IMessageFilter*LPMESSAGEFILTER;
typedef enum tagCALLTYPE
	{	CALLTYPE_TOPLEVEL	= 1,
	CALLTYPE_NESTED	= 2,
	CALLTYPE_ASYNC	= 3,
	CALLTYPE_TOPLEVEL_CALLPENDING	= 4,
	CALLTYPE_ASYNC_CALLPENDING	= 5
	}	CALLTYPE;
typedef enum tagSERVERCALL
	{	SERVERCALL_ISHANDLED	= 0,
	SERVERCALL_REJECTED	= 1,
	SERVERCALL_RETRYLATER	= 2
	}	SERVERCALL;
typedef enum tagPENDINGTYPE
	{	PENDINGTYPE_TOPLEVEL	= 1,
	PENDINGTYPE_NESTED	= 2
	}	PENDINGTYPE;
typedef enum tagPENDINGMSG
	{	PENDINGMSG_CANCELCALL	= 0,
	PENDINGMSG_WAITNOPROCESS	= 1,
	PENDINGMSG_WAITDEFPROCESS	= 2
	}	PENDINGMSG;

typedef struct tagINTERFACEINFO
	{
	IUnknown*pUnk;
	IID iid;
	WORD wMethod;
	}	INTERFACEINFO;

typedef struct tagINTERFACEINFO*LPINTERFACEINFO;

extern const IID IID_IMessageFilter;

typedef struct IMessageFilterVtbl {
HRESULT (_stdcall*QueryInterface )(IMessageFilter* This,REFIID riid,
	void * * ppvObject);
ULONG (_stdcall*AddRef )(IMessageFilter* This); 
ULONG (_stdcall*Release )(IMessageFilter* This); 
DWORD (_stdcall*HandleInComingCall )(IMessageFilter* This,DWORD dwCallType,
	HTASK htaskCaller,DWORD dwTickCount,LPINTERFACEINFO lpInterfaceInfo);
DWORD (_stdcall*RetryRejectedCall )(IMessageFilter* ,HTASK,DWORD ,DWORD);
DWORD (_stdcall*MessagePending )(IMessageFilter* ,HTASK, DWORD,DWORD); 
} IMessageFilterVtbl;

interface IMessageFilter { struct IMessageFilterVtbl*lpVtbl; };
#define IMessageFilter_QueryInterface(This,riid,ppvObject)	 (This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IMessageFilter_AddRef(This)	 (This)->lpVtbl->AddRef(This)
#define IMessageFilter_Release(This)	 (This)->lpVtbl->Release(This)
#define IMessageFilter_HandleInComingCall(T,d,h,dw,lp) (T)->lpVtbl->HandleInComingCall(T,d,h,dw,lp)
#define IMessageFilter_RetryRejectedCall(s,C,T,R) (s)->lpVtbl->RetryRejectedCall(s,C,T,R)
#define IMessageFilter_MessagePending(s,C,T,P) (s)->lpVtbl->MessagePending(This,C,T,P)
DWORD _stdcall IMessageFilter_HandleInComingCall_Proxy(IMessageFilter*,DWORD,HTASK,DWORD,LPINTERFACEINFO);
void _stdcall IMessageFilter_HandleInComingCall_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,
	PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
DWORD _stdcall IMessageFilter_RetryRejectedCall_Proxy(IMessageFilter* This,
	HTASK htaskCallee,DWORD dwTickCount,DWORD dwRejectType);
void _stdcall IMessageFilter_RetryRejectedCall_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,DWORD *_pdwStubPhase);
DWORD _stdcall IMessageFilter_MessagePending_Proxy(IMessageFilter* This,
	HTASK htaskCallee,DWORD dwTickCount,DWORD dwPendingType);
void _stdcall IMessageFilter_MessagePending_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);

typedef unsigned long RPCOLEDATAREP;
typedef struct tagRPCOLEMESSAGE {
	void*reserved1;
	RPCOLEDATAREP dataRepresentation;
	void*Buffer;
	ULONG cbBuffer;
	ULONG iMethod;
	void*reserved2[ 5 ];
	ULONG rpcFlags;
	}	RPCOLEMESSAGE;
typedef RPCOLEMESSAGE*PRPCOLEMESSAGE;
extern const IID IID_IRpcChannelBuffer;
typedef struct IRpcChannelBufferVtbl {
	HRESULT(_stdcall*QueryInterface)(IRpcChannelBuffer* This,REFIID riid,void * * ppvObject);
	ULONG (_stdcall*AddRef )(IRpcChannelBuffer* This);
	ULONG (_stdcall*Release )(IRpcChannelBuffer* This);
	HRESULT (_stdcall*GetBuffer )(IRpcChannelBuffer* This,RPCOLEMESSAGE*pMessage,
	REFIID riid);
	HRESULT (_stdcall*SendReceive )(IRpcChannelBuffer* This,RPCOLEMESSAGE*pMessage,
	ULONG*pStatus);
	HRESULT (_stdcall*FreeBuffer )(IRpcChannelBuffer* This,RPCOLEMESSAGE*pMessage);
	HRESULT (_stdcall*GetDestCtx )(IRpcChannelBuffer* This,
	DWORD*pdwDestContext,void * * ppvDestContext);
	HRESULT (_stdcall*IsConnected )(IRpcChannelBuffer* This);
} IRpcChannelBufferVtbl;

interface IRpcChannelBuffer { struct IRpcChannelBufferVtbl*lpVtbl;};
#define IRpcChannelBuffer_QueryInterface(T,r,p)	(T)->lpVtbl->QueryInterface(T,r,p)
#define IRpcChannelBuffer_AddRef(This)	(This)->lpVtbl->AddRef(This)
#define IRpcChannelBuffer_Release(This)	(This)->lpVtbl->Release(This)
#define IRpcChannelBuffer_GetBuffer(This,pMessage,riid)	\
	(This)->lpVtbl->GetBuffer(This,pMessage,riid)
#define IRpcChannelBuffer_SendReceive(T,p,pS) (T)->lpVtbl->SendReceive(T,p,pS)
#define IRpcChannelBuffer_FreeBuffer(T,p) (T)->lpVtbl->FreeBuffer(T,p)
#define IRpcChannelBuffer_GetDestCtx(This,pdwDestContext,ppvDestContext)	\
	(This)->lpVtbl->GetDestCtx(This,pdwDestContext,ppvDestContext)
#define IRpcChannelBuffer_IsConnected(This)	\
	(This)->lpVtbl->IsConnected(This)
	HRESULT _stdcall IRpcChannelBuffer_GetBuffer_Proxy(IRpcChannelBuffer* This,
	RPCOLEMESSAGE*pMessage,REFIID riid);
void _stdcall IRpcChannelBuffer_GetBuffer_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IRpcChannelBuffer_SendReceive_Proxy(IRpcChannelBuffer* This,
	RPCOLEMESSAGE*pMessage,ULONG*pStatus);
void _stdcall IRpcChannelBuffer_SendReceive_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IRpcChannelBuffer_FreeBuffer_Proxy(IRpcChannelBuffer* This,
	RPCOLEMESSAGE*pMessage);
void _stdcall IRpcChannelBuffer_FreeBuffer_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
HRESULT _stdcall IRpcChannelBuffer_GetDestCtx_Proxy(IRpcChannelBuffer* This,
	DWORD*pdwDestContext,void * * ppvDestContext);
void _stdcall IRpcChannelBuffer_GetDestCtx_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
	HRESULT _stdcall IRpcChannelBuffer_IsConnected_Proxy(IRpcChannelBuffer* This);
void _stdcall IRpcChannelBuffer_IsConnected_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);

extern const IID IID_IRpcProxyBuffer;

typedef struct IRpcProxyBufferVtbl {
	HRESULT (_stdcall*QueryInterface)(IRpcProxyBuffer* ,REFIID ,void * *);
	ULONG (_stdcall*AddRef )(IRpcProxyBuffer*);
	ULONG (_stdcall*Release )(IRpcProxyBuffer*);
	HRESULT (_stdcall* Connect)(IRpcProxyBuffer*,IRpcChannelBuffer*);
	void (_stdcall*Disconnect )(IRpcProxyBuffer* This);
} IRpcProxyBufferVtbl;

interface IRpcProxyBuffer { struct IRpcProxyBufferVtbl*lpVtbl; };

#define IRpcProxyBuffer_QueryInterface(This,riid,ppvObject)	\
	(This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IRpcProxyBuffer_AddRef(This)	\
	(This)->lpVtbl->AddRef(This)
#define IRpcProxyBuffer_Release(This)	\
	(This)->lpVtbl->Release(This)
#define IRpcProxyBuffer_Connect(This,pRpcChannelBuffer)	\
	(This)->lpVtbl->Connect(This,pRpcChannelBuffer)
#define IRpcProxyBuffer_Disconnect(This)	\
	(This)->lpVtbl->Disconnect(This)
	HRESULT _stdcall IRpcProxyBuffer_Connect_Proxy(IRpcProxyBuffer* This,
	IRpcChannelBuffer*pRpcChannelBuffer);
void _stdcall IRpcProxyBuffer_Connect_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);
void _stdcall IRpcProxyBuffer_Disconnect_Proxy(IRpcProxyBuffer* This);
void _stdcall IRpcProxyBuffer_Disconnect_Stub(IRpcStubBuffer *This,
	IRpcChannelBuffer *_pRpcChannelBuffer,PRPC_MESSAGE _pRpcMessage,
	DWORD *_pdwStubPhase);


extern const IID IID_IRpcStubBuffer;

typedef struct IRpcStubBufferVtbl {
	HRESULT (_stdcall*QueryInterface )(IRpcStubBuffer* ,REFIID , void * *);
	ULONG (_stdcall*AddRef )(IRpcStubBuffer* ); 
	ULONG (_stdcall*Release )(IRpcStubBuffer* );
	HRESULT (_stdcall*Connect )(IRpcStubBuffer* ,IUnknown*);
	void (_stdcall*Disconnect )(IRpcStubBuffer* );
	HRESULT (_stdcall*Invoke )(IRpcStubBuffer* ,RPCOLEMESSAGE*, IRpcChannelBuffer*);
	IRpcStubBuffer*(_stdcall*IsIIDSupported )(IRpcStubBuffer* ,REFIID );
	ULONG (_stdcall*CountRefs )(IRpcStubBuffer* );
	HRESULT (_stdcall*DebugServerQueryInterface )(IRpcStubBuffer* ,void **);
	void (_stdcall*DebugServerRelease )(IRpcStubBuffer* ,void*);
} IRpcStubBufferVtbl;

interface IRpcStubBuffer { struct IRpcStubBufferVtbl*lpVtbl; };

#define IRpcStubBuffer_QueryInterface(T,r,pp) (T)->lpVtbl->QueryInterface(T,r,pp)
#define IRpcStubBuffer_AddRef(This) (This)->lpVtbl->AddRef(This)
#define IRpcStubBuffer_Release(This)	(This)->lpVtbl->Release(This)
#define IRpcStubBuffer_Connect(This,p)	 (This)->lpVtbl->Connect(This,p)
#define IRpcStubBuffer_Disconnect(This)	 (This)->lpVtbl->Disconnect(This)
#define IRpcStubBuffer_Invoke(T,_prpcmsg,_p)	 (T)->lpVtbl->Invoke(This,_prpcmsg,_p)
#define IRpcStubBuffer_IsIIDSupported(T,d) (T)->lpVtbl->IsIIDSupported(T,d)
#define IRpcStubBuffer_CountRefs(This)	 (This)->lpVtbl->CountRefs(This)
#define IRpcStubBuffer_DebugServerQueryInterface(T,p) (T)->lpVtbl->DebugServerQueryInterface(T,p)
#define IRpcStubBuffer_DebugServerRelease(T,p) (T)->lpVtbl->DebugServerRelease(T,p)
HRESULT _stdcall IRpcStubBuffer_Connect_Proxy(IRpcStubBuffer*,IUnknown*);
void _stdcall IRpcStubBuffer_Connect_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
void _stdcall IRpcStubBuffer_Disconnect_Proxy(IRpcStubBuffer*);
void _stdcall IRpcStubBuffer_Disconnect_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IRpcStubBuffer_Invoke_Proxy(IRpcStubBuffer*,RPCOLEMESSAGE*,IRpcChannelBuffer*);
void _stdcall IRpcStubBuffer_Invoke_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
IRpcStubBuffer*_stdcall IRpcStubBuffer_IsIIDSupported_Proxy(IRpcStubBuffer*,REFIID);
void _stdcall IRpcStubBuffer_IsIIDSupported_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
ULONG _stdcall IRpcStubBuffer_CountRefs_Proxy(IRpcStubBuffer* This);
void _stdcall IRpcStubBuffer_CountRefs_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IRpcStubBuffer_DebugServerQueryInterface_Proxy(IRpcStubBuffer*,void * *);
void _stdcall IRpcStubBuffer_DebugServerQueryInterface_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
void _stdcall IRpcStubBuffer_DebugServerRelease_Proxy(IRpcStubBuffer*, void*);
void _stdcall IRpcStubBuffer_DebugServerRelease_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
extern const IID IID_IPSFactoryBuffer;
typedef struct IPSFactoryBufferVtbl {
	HRESULT (_stdcall*QueryInterface )(IPSFactoryBuffer* , REFIID ,void * * ); 
	ULONG (_stdcall*AddRef )(IPSFactoryBuffer*);
	ULONG (_stdcall*Release )(IPSFactoryBuffer* );
	HRESULT (_stdcall*CreateProxy )(IPSFactoryBuffer*, IUnknown*,REFIID,IRpcProxyBuffer * *,void * *);
	HRESULT (_stdcall*CreateStub )(IPSFactoryBuffer*,REFIID,IUnknown*,IRpcStubBuffer * *);
} IPSFactoryBufferVtbl;

interface IPSFactoryBuffer { struct IPSFactoryBufferVtbl*lpVtbl; };

#define IPSFactoryBuffer_QueryInterface(This,riid,ppvObject) (This)->lpVtbl->QueryInterface(This,riid,ppvObject)
#define IPSFactoryBuffer_AddRef(This)	(This)->lpVtbl->AddRef(This)
#define IPSFactoryBuffer_Release(This)	(This)->lpVtbl->Release(This)
#define IPSFactoryBuffer_CreateProxy(T,U,r,P,p) (T)->lpVtbl->CreateProxy(T,U,r,P,p)
#define IPSFactoryBuffer_CreateStub(T,r,U,p) (T)->lpVtbl->CreateStub(T,r,U,p)
HRESULT _stdcall IPSFactoryBuffer_CreateProxy_Proxy(IPSFactoryBuffer*,IUnknown*,REFIID,IRpcProxyBuffer * *,void * *);
void _stdcall IPSFactoryBuffer_CreateProxy_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT _stdcall IPSFactoryBuffer_CreateStub_Proxy(IPSFactoryBuffer*,REFIID,IUnknown*,IRpcStubBuffer * *);
void _stdcall IPSFactoryBuffer_CreateStub_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
void _stdcall SNB_to_xmit(SNB*,RemSNB** );
void _stdcall SNB_from_xmit(RemSNB*,SNB* );
void _stdcall SNB_free_inst(SNB* );
void _stdcall SNB_free_xmit(RemSNB* );
HRESULT _stdcall IEnumUnknown_Next_Proxy(IEnumUnknown*,ULONG,IUnknown * *,ULONG*);
HRESULT _stdcall IEnumUnknown_Next_Stub(IEnumUnknown*,ULONG,IUnknown * *,ULONG*);
HRESULT _stdcall IEnumMoniker_Next_Proxy(IEnumMoniker*,ULONG,IMoniker * *,ULONG*);
HRESULT _stdcall IEnumMoniker_Next_Stub(IEnumMoniker*,ULONG,IMoniker * *,ULONG*);
HRESULT _stdcall IMoniker_BindToObject_Proxy(IMoniker*,IBindCtx*,IMoniker*,REFIID,void * *);
HRESULT _stdcall IMoniker_BindToObject_Stub(IMoniker*,IBindCtx*,IMoniker*,REFIID,IUnknown * *);
HRESULT _stdcall IMoniker_BindToStorage_Proxy(IMoniker*,IBindCtx*,IMoniker*,REFIID,void * *);
HRESULT _stdcall IMoniker_BindToStorage_Stub(IMoniker*,IBindCtx*,IMoniker*,REFIID,IUnknown * *);
HRESULT _stdcall IEnumString_Next_Proxy(IEnumString*,ULONG,LPCSTR*,ULONG *);
HRESULT _stdcall IEnumString_Next_Stub(IEnumString*,ULONG,LPCSTR*,ULONG*);
HRESULT _stdcall IStream_Read_Proxy(IStream*,void*,ULONG,ULONG*);
HRESULT _stdcall IStream_Read_Stub(IStream*,BYTE *,ULONG,ULONG *);
HRESULT _stdcall IStream_Write_Proxy(IStream*,void*,ULONG,ULONG*);
HRESULT _stdcall IStream_Write_Stub(IStream*,BYTE *,ULONG,ULONG*);
HRESULT _stdcall IStream_Seek_Proxy(IStream*,LARGE_INTEGER,DWORD,ULARGE_INTEGER*);
HRESULT _stdcall IStream_Seek_Stub(IStream*,LARGE_INTEGER,DWORD,ULARGE_INTEGER*);
HRESULT _stdcall IStream_CopyTo_Proxy(IStream*,IStream*,ULARGE_INTEGER,ULARGE_INTEGER*, ULARGE_INTEGER*);
HRESULT _stdcall IStream_CopyTo_Stub(IStream*,IStream*,ULARGE_INTEGER,ULARGE_INTEGER*,ULARGE_INTEGER*);
HRESULT _stdcall IEnumSTATSTG_Next_Proxy(IEnumSTATSTG*,ULONG,STATSTG*,ULONG*);
HRESULT _stdcall IEnumSTATSTG_Next_Stub(IEnumSTATSTG*,ULONG,STATSTG*,ULONG*);
HRESULT _stdcall IStorage_OpenStream_Proxy(IStorage*,OLECHAR*,void*,DWORD,DWORD,IStream * *);
HRESULT _stdcall IStorage_OpenStream_Stub(IStorage*,OLECHAR*,unsigned long,BYTE *,DWORD,DWORD,IStream * * );
HRESULT _stdcall IStorage_EnumElements_Proxy(IStorage*,DWORD,void*,DWORD,IEnumSTATSTG **);
HRESULT _stdcall IStorage_EnumElements_Stub(IStorage*,DWORD,unsigned long,BYTE *,DWORD,IEnumSTATSTG * *);
HRESULT _stdcall ILockBytes_ReadAt_Proxy(ILockBytes*,ULARGE_INTEGER,void*,ULONG,ULONG*);
HRESULT _stdcall ILockBytes_ReadAt_Stub(ILockBytes*,ULARGE_INTEGER,BYTE *,ULONG,ULONG*);
HRESULT _stdcall ILockBytes_WriteAt_Proxy(ILockBytes*,ULARGE_INTEGER,const void*,ULONG,ULONG*);
HRESULT _stdcall ILockBytes_WriteAt_Stub(ILockBytes*,ULARGE_INTEGER,BYTE *,ULONG,ULONG*);
HRESULT _stdcall IEnumFORMATETC_Next_Proxy(IEnumFORMATETC *,ULONG,FORMATETC *,ULONG*);
HRESULT _stdcall IEnumFORMATETC_Next_Stub(IEnumFORMATETC *,ULONG,FORMATETC *,ULONG*);
HRESULT _stdcall IEnumSTATDATA_Next_Proxy(IEnumSTATDATA*,ULONG,STATDATA*,ULONG*);
HRESULT _stdcall IEnumSTATDATA_Next_Stub(IEnumSTATDATA*,ULONG,STATDATA*,ULONG*);
void _stdcall IAdviseSink_OnDataChange_Proxy(IAdviseSink*,FORMATETC *,STGMEDIUM*);
void _stdcall IAdviseSink_OnDataChange_Stub(IAdviseSink*,FORMATETC *,RemSTGMEDIUM*);
void _stdcall IAdviseSink_OnViewChange_Proxy(IAdviseSink*,DWORD,LONG);
void _stdcall IAdviseSink_OnViewChange_Stub(IAdviseSink*,DWORD,LONG);
void _stdcall IAdviseSink_OnRename_Proxy(IAdviseSink*,IMoniker*);
void _stdcall IAdviseSink_OnRename_Stub(IAdviseSink* This,IMoniker*pmk);
void _stdcall IAdviseSink_OnSave_Proxy(IAdviseSink* This);
void _stdcall IAdviseSink_OnSave_Stub(IAdviseSink* This);
void _stdcall IAdviseSink_OnClose_Proxy(IAdviseSink* This);
HRESULT _stdcall IAdviseSink_OnClose_Stub(IAdviseSink* This);
void _stdcall IAdviseSink2_OnLinkSrcChange_Proxy(IAdviseSink2 *,IMoniker *);
void _stdcall IAdviseSink2_OnLinkSrcChange_Stub(IAdviseSink2 *,IMoniker *);
HRESULT _stdcall IDataObject_GetData_Proxy(IDataObject *,FORMATETC *,STGMEDIUM *);
HRESULT _stdcall IDataObject_GetData_Stub(IDataObject *,FORMATETC *,RemSTGMEDIUM * *);
HRESULT _stdcall IDataObject_GetDataHere_Proxy(IDataObject*,FORMATETC *,STGMEDIUM*);
HRESULT _stdcall IDataObject_GetDataHere_Stub(IDataObject*,FORMATETC *,RemSTGMEDIUM * *);
HRESULT _stdcall IDataObject_SetData_Proxy(IDataObject*,FORMATETC *,STGMEDIUM*,BOOL);
HRESULT _stdcall IDataObject_SetData_Stub(IDataObject*,FORMATETC *,RemSTGMEDIUM*,BOOL);
#endif
#endif
