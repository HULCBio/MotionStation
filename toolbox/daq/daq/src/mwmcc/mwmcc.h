

/* this ALWAYS GENERATED file contains the definitions for the interfaces */


 /* File created by MIDL compiler version 6.00.0361 */
/* at Wed Mar 24 02:16:24 2004
 */
/* Compiler settings for .\mwmcc.idl:
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

#ifndef __mwmcc_h__
#define __mwmcc_h__

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

/* Forward Declarations */ 

#ifndef __IAin_FWD_DEFINED__
#define __IAin_FWD_DEFINED__
typedef interface IAin IAin;
#endif 	/* __IAin_FWD_DEFINED__ */


#ifndef __IAout_FWD_DEFINED__
#define __IAout_FWD_DEFINED__
typedef interface IAout IAout;
#endif 	/* __IAout_FWD_DEFINED__ */


#ifndef __IDio_FWD_DEFINED__
#define __IDio_FWD_DEFINED__
typedef interface IDio IDio;
#endif 	/* __IDio_FWD_DEFINED__ */


#ifndef __Ain_FWD_DEFINED__
#define __Ain_FWD_DEFINED__

#ifdef __cplusplus
typedef class Ain Ain;
#else
typedef struct Ain Ain;
#endif /* __cplusplus */

#endif 	/* __Ain_FWD_DEFINED__ */


#ifndef __Aout_FWD_DEFINED__
#define __Aout_FWD_DEFINED__

#ifdef __cplusplus
typedef class Aout Aout;
#else
typedef struct Aout Aout;
#endif /* __cplusplus */

#endif 	/* __Aout_FWD_DEFINED__ */


#ifndef __Dio_FWD_DEFINED__
#define __Dio_FWD_DEFINED__

#ifdef __cplusplus
typedef class Dio Dio;
#else
typedef struct Dio Dio;
#endif /* __cplusplus */

#endif 	/* __Dio_FWD_DEFINED__ */


/* header files for imported files */
#include "oaidl.h"
#include "ocidl.h"
#include "daqmex.h"

#ifdef __cplusplus
extern "C"{
#endif 

void * __RPC_USER MIDL_user_allocate(size_t);
void __RPC_USER MIDL_user_free( void * ); 

#ifndef __IAin_INTERFACE_DEFINED__
#define __IAin_INTERFACE_DEFINED__

/* interface IAin */
/* [unique][helpstring][dual][uuid][object] */ 


EXTERN_C const IID IID_IAin;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("9F4D6A59-3BA3-4ea4-B970-98ED41DE907D")
    IAin : public IDispatch
    {
    public:
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE SetConfig( 
            long InfoType,
            long DevNum,
            long ConfigItem,
            long ConfigVal) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE GetConfig( 
            long InfoType,
            long DevNum,
            long ConfigItem,
            /* [retval][out] */ long *ConfigVal) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE AIn( 
            long Channel,
            long Range,
            /* [retval][out] */ unsigned short *DataValue) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE C8254Config( 
            long CounterNum,
            long Config) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE CLoad( 
            VARIANT RegName,
            unsigned long LoadValue) = 0;
        
    };
    
#else 	/* C style interface */

    typedef struct IAinVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            IAin * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void **ppvObject);
        
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            IAin * This);
        
        ULONG ( STDMETHODCALLTYPE *Release )( 
            IAin * This);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfoCount )( 
            IAin * This,
            /* [out] */ UINT *pctinfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfo )( 
            IAin * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo **ppTInfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetIDsOfNames )( 
            IAin * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR *rgszNames,
            /* [in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID *rgDispId);
        
        /* [local] */ HRESULT ( STDMETHODCALLTYPE *Invoke )( 
            IAin * This,
            /* [in] */ DISPID dispIdMember,
            /* [in] */ REFIID riid,
            /* [in] */ LCID lcid,
            /* [in] */ WORD wFlags,
            /* [out][in] */ DISPPARAMS *pDispParams,
            /* [out] */ VARIANT *pVarResult,
            /* [out] */ EXCEPINFO *pExcepInfo,
            /* [out] */ UINT *puArgErr);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *SetConfig )( 
            IAin * This,
            long InfoType,
            long DevNum,
            long ConfigItem,
            long ConfigVal);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *GetConfig )( 
            IAin * This,
            long InfoType,
            long DevNum,
            long ConfigItem,
            /* [retval][out] */ long *ConfigVal);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *AIn )( 
            IAin * This,
            long Channel,
            long Range,
            /* [retval][out] */ unsigned short *DataValue);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *C8254Config )( 
            IAin * This,
            long CounterNum,
            long Config);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *CLoad )( 
            IAin * This,
            VARIANT RegName,
            unsigned long LoadValue);
        
        END_INTERFACE
    } IAinVtbl;

    interface IAin
    {
        CONST_VTBL struct IAinVtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IAin_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define IAin_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define IAin_Release(This)	\
    (This)->lpVtbl -> Release(This)


#define IAin_GetTypeInfoCount(This,pctinfo)	\
    (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo)

#define IAin_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo)

#define IAin_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)

#define IAin_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)


#define IAin_SetConfig(This,InfoType,DevNum,ConfigItem,ConfigVal)	\
    (This)->lpVtbl -> SetConfig(This,InfoType,DevNum,ConfigItem,ConfigVal)

#define IAin_GetConfig(This,InfoType,DevNum,ConfigItem,ConfigVal)	\
    (This)->lpVtbl -> GetConfig(This,InfoType,DevNum,ConfigItem,ConfigVal)

#define IAin_AIn(This,Channel,Range,DataValue)	\
    (This)->lpVtbl -> AIn(This,Channel,Range,DataValue)

#define IAin_C8254Config(This,CounterNum,Config)	\
    (This)->lpVtbl -> C8254Config(This,CounterNum,Config)

#define IAin_CLoad(This,RegName,LoadValue)	\
    (This)->lpVtbl -> CLoad(This,RegName,LoadValue)

#endif /* COBJMACROS */


#endif 	/* C style interface */



/* [helpstring][id] */ HRESULT STDMETHODCALLTYPE IAin_SetConfig_Proxy( 
    IAin * This,
    long InfoType,
    long DevNum,
    long ConfigItem,
    long ConfigVal);


void __RPC_STUB IAin_SetConfig_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id] */ HRESULT STDMETHODCALLTYPE IAin_GetConfig_Proxy( 
    IAin * This,
    long InfoType,
    long DevNum,
    long ConfigItem,
    /* [retval][out] */ long *ConfigVal);


void __RPC_STUB IAin_GetConfig_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id] */ HRESULT STDMETHODCALLTYPE IAin_AIn_Proxy( 
    IAin * This,
    long Channel,
    long Range,
    /* [retval][out] */ unsigned short *DataValue);


void __RPC_STUB IAin_AIn_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id] */ HRESULT STDMETHODCALLTYPE IAin_C8254Config_Proxy( 
    IAin * This,
    long CounterNum,
    long Config);


void __RPC_STUB IAin_C8254Config_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id] */ HRESULT STDMETHODCALLTYPE IAin_CLoad_Proxy( 
    IAin * This,
    VARIANT RegName,
    unsigned long LoadValue);


void __RPC_STUB IAin_CLoad_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);



#endif 	/* __IAin_INTERFACE_DEFINED__ */


#ifndef __IAout_INTERFACE_DEFINED__
#define __IAout_INTERFACE_DEFINED__

/* interface IAout */
/* [unique][helpstring][dual][uuid][object] */ 


EXTERN_C const IID IID_IAout;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("507734E3-669D-4aab-A019-5C9D049CF7D5")
    IAout : public IUnknown
    {
    public:
    };
    
#else 	/* C style interface */

    typedef struct IAoutVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            IAout * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void **ppvObject);
        
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            IAout * This);
        
        ULONG ( STDMETHODCALLTYPE *Release )( 
            IAout * This);
        
        END_INTERFACE
    } IAoutVtbl;

    interface IAout
    {
        CONST_VTBL struct IAoutVtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IAout_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define IAout_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define IAout_Release(This)	\
    (This)->lpVtbl -> Release(This)


#endif /* COBJMACROS */


#endif 	/* C style interface */




#endif 	/* __IAout_INTERFACE_DEFINED__ */


#ifndef __IDio_INTERFACE_DEFINED__
#define __IDio_INTERFACE_DEFINED__

/* interface IDio */
/* [unique][helpstring][uuid][object] */ 


EXTERN_C const IID IID_IDio;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("335866FD-353C-4995-B5D6-093EC7D3F815")
    IDio : public IUnknown
    {
    public:
    };
    
#else 	/* C style interface */

    typedef struct IDioVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            IDio * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void **ppvObject);
        
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            IDio * This);
        
        ULONG ( STDMETHODCALLTYPE *Release )( 
            IDio * This);
        
        END_INTERFACE
    } IDioVtbl;

    interface IDio
    {
        CONST_VTBL struct IDioVtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IDio_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define IDio_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define IDio_Release(This)	\
    (This)->lpVtbl -> Release(This)


#endif /* COBJMACROS */


#endif 	/* C style interface */




#endif 	/* __IDio_INTERFACE_DEFINED__ */



#ifndef __MWMCCLib_LIBRARY_DEFINED__
#define __MWMCCLib_LIBRARY_DEFINED__

/* library MWMCCLib */
/* [helpstring][version][uuid] */ 


EXTERN_C const IID LIBID_MWMCCLib;

EXTERN_C const CLSID CLSID_Ain;

#ifdef __cplusplus

class DECLSPEC_UUID("F22FC4CC-E10A-4b61-9D55-E62283C5E8E2")
Ain;
#endif

EXTERN_C const CLSID CLSID_Aout;

#ifdef __cplusplus

class DECLSPEC_UUID("5753AE23-22D7-4181-892E-CB18C118ED4E")
Aout;
#endif

EXTERN_C const CLSID CLSID_Dio;

#ifdef __cplusplus

class DECLSPEC_UUID("1078DD6C-E4C2-4309-A0EC-27A09FAB215C")
Dio;
#endif
#endif /* __MWMCCLib_LIBRARY_DEFINED__ */

/* Additional Prototypes for ALL interfaces */

unsigned long             __RPC_USER  VARIANT_UserSize(     unsigned long *, unsigned long            , VARIANT * ); 
unsigned char * __RPC_USER  VARIANT_UserMarshal(  unsigned long *, unsigned char *, VARIANT * ); 
unsigned char * __RPC_USER  VARIANT_UserUnmarshal(unsigned long *, unsigned char *, VARIANT * ); 
void                      __RPC_USER  VARIANT_UserFree(     unsigned long *, VARIANT * ); 

/* end of Additional Prototypes */

#ifdef __cplusplus
}
#endif

#endif


