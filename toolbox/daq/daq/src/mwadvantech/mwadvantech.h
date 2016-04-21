

/* this ALWAYS GENERATED file contains the definitions for the interfaces */


 /* File created by MIDL compiler version 6.00.0361 */
/* at Wed Mar 24 02:17:30 2004
 */
/* Compiler settings for .\mwadvantech.idl:
    Oicf, W1, Zp8, env=Win32 (32b run)
    protocol : dce , ms_ext, c_ext, robust
    error checks: allocation ref bounds_check enum stub_data 
    VC __declspec() decoration level: 
         __declspec(uuid()), __declspec(selectany), __declspec(novtable)
         DECLSPEC_UUID(), MIDL_INTERFACE()
*/
//@@MIDL_FILE_HEADING(  )

#pragma warning( disable: 4049 )  /* more than 64k source lines */


/* verify that the <rpcndr.h> version is high enough to compile this file*/
#ifndef __REQUIRED_RPCNDR_H_VERSION__
#define __REQUIRED_RPCNDR_H_VERSION__ 475
#endif

#include "rpc.h"
#include "rpcndr.h"

#ifndef __RPCNDR_H_VERSION__
#error this stub requires an updated version of <rpcndr.h>
#endif // __RPCNDR_H_VERSION__

#ifndef COM_NO_WINDOWS_H
#include "windows.h"
#include "ole2.h"
#endif /*COM_NO_WINDOWS_H*/

#ifndef __mwadvantech_h__
#define __mwadvantech_h__

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

/* Forward Declarations */ 

#ifndef __IadvantechAin_FWD_DEFINED__
#define __IadvantechAin_FWD_DEFINED__
typedef interface IadvantechAin IadvantechAin;
#endif 	/* __IadvantechAin_FWD_DEFINED__ */


#ifndef __IadvantechAout_FWD_DEFINED__
#define __IadvantechAout_FWD_DEFINED__
typedef interface IadvantechAout IadvantechAout;
#endif 	/* __IadvantechAout_FWD_DEFINED__ */


#ifndef __IadvantechDio_FWD_DEFINED__
#define __IadvantechDio_FWD_DEFINED__
typedef interface IadvantechDio IadvantechDio;
#endif 	/* __IadvantechDio_FWD_DEFINED__ */


#ifndef __advantechadapt_FWD_DEFINED__
#define __advantechadapt_FWD_DEFINED__

#ifdef __cplusplus
typedef class advantechadapt advantechadapt;
#else
typedef struct advantechadapt advantechadapt;
#endif /* __cplusplus */

#endif 	/* __advantechadapt_FWD_DEFINED__ */


#ifndef __advantechAin_FWD_DEFINED__
#define __advantechAin_FWD_DEFINED__

#ifdef __cplusplus
typedef class advantechAin advantechAin;
#else
typedef struct advantechAin advantechAin;
#endif /* __cplusplus */

#endif 	/* __advantechAin_FWD_DEFINED__ */


#ifndef __advantechAout_FWD_DEFINED__
#define __advantechAout_FWD_DEFINED__

#ifdef __cplusplus
typedef class advantechAout advantechAout;
#else
typedef struct advantechAout advantechAout;
#endif /* __cplusplus */

#endif 	/* __advantechAout_FWD_DEFINED__ */


#ifndef __advantechDio_FWD_DEFINED__
#define __advantechDio_FWD_DEFINED__

#ifdef __cplusplus
typedef class advantechDio advantechDio;
#else
typedef struct advantechDio advantechDio;
#endif /* __cplusplus */

#endif 	/* __advantechDio_FWD_DEFINED__ */


/* header files for imported files */
#include "oaidl.h"
#include "ocidl.h"
#include "daqmex.h"

#ifdef __cplusplus
extern "C"{
#endif 

void * __RPC_USER MIDL_user_allocate(size_t);
void __RPC_USER MIDL_user_free( void * ); 

#ifndef __IadvantechAin_INTERFACE_DEFINED__
#define __IadvantechAin_INTERFACE_DEFINED__

/* interface IadvantechAin */
/* [unique][helpstring][dual][uuid][object] */ 


EXTERN_C const IID IID_IadvantechAin;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("FACDD47E-089A-4ae2-A951-661F95723898")
    IadvantechAin : public IDispatch
    {
    public:
    };
    
#else 	/* C style interface */

    typedef struct IadvantechAinVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            IadvantechAin * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void **ppvObject);
        
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            IadvantechAin * This);
        
        ULONG ( STDMETHODCALLTYPE *Release )( 
            IadvantechAin * This);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfoCount )( 
            IadvantechAin * This,
            /* [out] */ UINT *pctinfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfo )( 
            IadvantechAin * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo **ppTInfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetIDsOfNames )( 
            IadvantechAin * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR *rgszNames,
            /* [in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID *rgDispId);
        
        /* [local] */ HRESULT ( STDMETHODCALLTYPE *Invoke )( 
            IadvantechAin * This,
            /* [in] */ DISPID dispIdMember,
            /* [in] */ REFIID riid,
            /* [in] */ LCID lcid,
            /* [in] */ WORD wFlags,
            /* [out][in] */ DISPPARAMS *pDispParams,
            /* [out] */ VARIANT *pVarResult,
            /* [out] */ EXCEPINFO *pExcepInfo,
            /* [out] */ UINT *puArgErr);
        
        END_INTERFACE
    } IadvantechAinVtbl;

    interface IadvantechAin
    {
        CONST_VTBL struct IadvantechAinVtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IadvantechAin_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define IadvantechAin_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define IadvantechAin_Release(This)	\
    (This)->lpVtbl -> Release(This)


#define IadvantechAin_GetTypeInfoCount(This,pctinfo)	\
    (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo)

#define IadvantechAin_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo)

#define IadvantechAin_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)

#define IadvantechAin_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)


#endif /* COBJMACROS */


#endif 	/* C style interface */




#endif 	/* __IadvantechAin_INTERFACE_DEFINED__ */


#ifndef __IadvantechAout_INTERFACE_DEFINED__
#define __IadvantechAout_INTERFACE_DEFINED__

/* interface IadvantechAout */
/* [unique][helpstring][dual][uuid][object] */ 


EXTERN_C const IID IID_IadvantechAout;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("946FA2DD-F51D-48f7-88CB-50E6F05E6266")
    IadvantechAout : public IDispatch
    {
    public:
    };
    
#else 	/* C style interface */

    typedef struct IadvantechAoutVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            IadvantechAout * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void **ppvObject);
        
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            IadvantechAout * This);
        
        ULONG ( STDMETHODCALLTYPE *Release )( 
            IadvantechAout * This);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfoCount )( 
            IadvantechAout * This,
            /* [out] */ UINT *pctinfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfo )( 
            IadvantechAout * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo **ppTInfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetIDsOfNames )( 
            IadvantechAout * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR *rgszNames,
            /* [in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID *rgDispId);
        
        /* [local] */ HRESULT ( STDMETHODCALLTYPE *Invoke )( 
            IadvantechAout * This,
            /* [in] */ DISPID dispIdMember,
            /* [in] */ REFIID riid,
            /* [in] */ LCID lcid,
            /* [in] */ WORD wFlags,
            /* [out][in] */ DISPPARAMS *pDispParams,
            /* [out] */ VARIANT *pVarResult,
            /* [out] */ EXCEPINFO *pExcepInfo,
            /* [out] */ UINT *puArgErr);
        
        END_INTERFACE
    } IadvantechAoutVtbl;

    interface IadvantechAout
    {
        CONST_VTBL struct IadvantechAoutVtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IadvantechAout_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define IadvantechAout_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define IadvantechAout_Release(This)	\
    (This)->lpVtbl -> Release(This)


#define IadvantechAout_GetTypeInfoCount(This,pctinfo)	\
    (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo)

#define IadvantechAout_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo)

#define IadvantechAout_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)

#define IadvantechAout_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)


#endif /* COBJMACROS */


#endif 	/* C style interface */




#endif 	/* __IadvantechAout_INTERFACE_DEFINED__ */


#ifndef __IadvantechDio_INTERFACE_DEFINED__
#define __IadvantechDio_INTERFACE_DEFINED__

/* interface IadvantechDio */
/* [unique][helpstring][dual][uuid][object] */ 


EXTERN_C const IID IID_IadvantechDio;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("5EF1D532-045C-4096-9598-F74966F47AF6")
    IadvantechDio : public IUnknown
    {
    public:
    };
    
#else 	/* C style interface */

    typedef struct IadvantechDioVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            IadvantechDio * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void **ppvObject);
        
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            IadvantechDio * This);
        
        ULONG ( STDMETHODCALLTYPE *Release )( 
            IadvantechDio * This);
        
        END_INTERFACE
    } IadvantechDioVtbl;

    interface IadvantechDio
    {
        CONST_VTBL struct IadvantechDioVtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IadvantechDio_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define IadvantechDio_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define IadvantechDio_Release(This)	\
    (This)->lpVtbl -> Release(This)


#endif /* COBJMACROS */


#endif 	/* C style interface */




#endif 	/* __IadvantechDio_INTERFACE_DEFINED__ */



#ifndef __ADVANTECHLib_LIBRARY_DEFINED__
#define __ADVANTECHLib_LIBRARY_DEFINED__

/* library ADVANTECHLib */
/* [helpstring][version][uuid] */ 


EXTERN_C const IID LIBID_ADVANTECHLib;

EXTERN_C const CLSID CLSID_advantechadapt;

#ifdef __cplusplus

class DECLSPEC_UUID("98EAB8A1-7BA1-4099-B703-B70C8A507F5F")
advantechadapt;
#endif

EXTERN_C const CLSID CLSID_advantechAin;

#ifdef __cplusplus

class DECLSPEC_UUID("8B00CFAD-83C2-49e7-91AB-5833BDE24A2F")
advantechAin;
#endif

EXTERN_C const CLSID CLSID_advantechAout;

#ifdef __cplusplus

class DECLSPEC_UUID("759C2567-9E65-460a-AC04-C7AA93F29B93")
advantechAout;
#endif

EXTERN_C const CLSID CLSID_advantechDio;

#ifdef __cplusplus

class DECLSPEC_UUID("1D5D1242-C670-4aef-A885-07FBEE0A530A")
advantechDio;
#endif
#endif /* __ADVANTECHLib_LIBRARY_DEFINED__ */

/* Additional Prototypes for ALL interfaces */

/* end of Additional Prototypes */

#ifdef __cplusplus
}
#endif

#endif


