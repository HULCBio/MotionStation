#include "rpc.h"
#include "rpcndr.h"
#ifndef COM_NO_WINDOWS_H
#include <windows.h>
#endif 
#ifndef __unknwn_h__
#define __unknwn_h__
#ifndef _OBJBASE_H_
#include <objbase.h>
#endif
#ifndef __IUnknown_FWD_DEFINED__
#define __IUnknown_FWD_DEFINED__
typedef interface IUnknown IUnknown;
#endif 	
#ifndef __IClassFactory_FWD_DEFINED__
#define __IClassFactory_FWD_DEFINED__
typedef interface IClassFactory IClassFactory;
#endif 	
#include "wtypes.h"
#ifndef __MIDL_USER_DEFINED
#define __MIDL_USER_DEFINED
void * __RPC_USER MIDL_user_allocate(size_t);
void __RPC_USER MIDL_user_free(void * ); 
#endif
extern RPC_IF_HANDLE __MIDL__intf_0000_v0_0_c_ifspec;
extern RPC_IF_HANDLE __MIDL__intf_0000_v0_0_s_ifspec;
#ifndef __IUnknown_INTERFACE_DEFINED__
#define __IUnknown_INTERFACE_DEFINED__
#ifndef LPUNKNOWN_DEFINED
#define LPUNKNOWN_DEFINED
typedef IUnknown *LPUNKNOWN;
#endif
#ifndef BEGIN_INTERFACE
#define BEGIN_INTERFACE
#define END_INTERFACE
#endif
#ifndef STDMETHODCALLTYPE
#define STDMETHODCALLTYPE STDCALL
#endif
#ifndef __RPC_STUB
#define __RPC_STUB STDCALL
#endif 
const IID IID_IUnknown;
typedef struct IUnknownVtbl {
	BEGIN_INTERFACE
	HRESULT (STDMETHODCALLTYPE *QueryInterface)(IUnknown *,REFIID,void * *);
	ULONG (STDMETHODCALLTYPE *AddRef)(IUnknown * );
	ULONG (STDMETHODCALLTYPE *Release)(IUnknown *);
	END_INTERFACE
} IUnknownVtbl;
interface IUnknown { CONST_VTBL struct IUnknownVtbl *lpVtbl; };
#define IUnknown_QueryInterface(T,r,O) (T)->lpVtbl->QueryInterface(T,r,O)
#define IUnknown_AddRef(T) (T)->lpVtbl->AddRef(T)
#define IUnknown_Release(T) (T)->lpVtbl->Release(T)
HRESULT STDMETHODCALLTYPE IUnknown_QueryInterface_Proxy(IUnknown * T,REFIID,void * *);
void __RPC_STUB IUnknown_QueryInterface_Stub(IRpcStubBuffer *, IRpcChannelBuffer *, PRPC_MESSAGE, DWORD *);
ULONG STDMETHODCALLTYPE IUnknown_AddRef_Proxy(IUnknown *);
void __RPC_STUB IUnknown_AddRef_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE, DWORD *);
ULONG STDMETHODCALLTYPE IUnknown_Release_Proxy(IUnknown * );
void __RPC_STUB IUnknown_Release_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
#endif 	
#ifndef __IClassFactory_INTERFACE_DEFINED__
#define __IClassFactory_INTERFACE_DEFINED__
typedef IClassFactory *LPCLASSFACTORY;
const IID IID_IClassFactory;
typedef struct IClassFactoryVtbl {
	BEGIN_INTERFACE
	HRESULT (STDMETHODCALLTYPE *QueryInterface)(IClassFactory *,REFIID, void * *);
	ULONG (STDMETHODCALLTYPE *AddRef)(IClassFactory *);
	ULONG (STDMETHODCALLTYPE *Release)(IClassFactory *);
	HRESULT (STDMETHODCALLTYPE *CreateInstance )(IClassFactory *,IUnknown *,REFIID,void * *);
	HRESULT (STDMETHODCALLTYPE *LockServer )(IClassFactory *,BOOL);
	END_INTERFACE
} IClassFactoryVtbl;
interface IClassFactory { CONST_VTBL struct IClassFactoryVtbl *lpVtbl; };
#define IClassFactory_QueryInterface(T,r,O) (T)->lpVtbl->QueryInterface(T,r,O)
#define IClassFactory_AddRef(T) (T)->lpVtbl->AddRef(T)
#define IClassFactory_Release(T) (T)->lpVtbl->Release(T)
#define IClassFactory_CreateInstance(T,p,r,O) (T)->lpVtbl->CreateInstance(T,p,r,O)
#define IClassFactory_LockServer(T,f) (T)->lpVtbl->LockServer(T,f)
HRESULT STDMETHODCALLTYPE IClassFactory_RemoteCreateInstance_Proxy(IClassFactory * , REFIID , IUnknown * *);
void __RPC_STUB IClassFactory_RemoteCreateInstance_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
HRESULT __stdcall IClassFactory_RemoteLockServer_Proxy(IClassFactory *, BOOL);
void __RPC_STUB IClassFactory_RemoteLockServer_Stub(IRpcStubBuffer *,IRpcChannelBuffer *,PRPC_MESSAGE,DWORD *);
#endif 	
HRESULT STDMETHODCALLTYPE IClassFactory_CreateInstance_Proxy(IClassFactory *,IUnknown *,REFIID, void * *);
HRESULT STDMETHODCALLTYPE IClassFactory_CreateInstance_Stub(IClassFactory *,REFIID,IUnknown * *);
HRESULT STDMETHODCALLTYPE IClassFactory_LockServer_Proxy(IClassFactory *,BOOL);
HRESULT __stdcall IClassFactory_LockServer_Stub(IClassFactory * ,BOOL);
#endif
