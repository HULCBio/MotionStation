/* this ALWAYS GENERATED file contains the definitions for the interfaces */


/* File created by MIDL compiler version 5.01.0164 */
/* at Wed Jun 05 11:37:33 2002
 */
/* Compiler settings for C:\R13\toolbox\daq\daq\src\include\daqmex.idl:
    Oicf (OptLev=i2), W1, Zp8, env=Win32, ms_ext, c_ext
    error checks: allocation ref bounds_check enum stub_data 
*/
//@@MIDL_FILE_HEADING(  )


/* verify that the <rpcndr.h> version is high enough to compile this file*/
#ifndef __REQUIRED_RPCNDR_H_VERSION__
#define __REQUIRED_RPCNDR_H_VERSION__ 440
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

#ifndef __daqmex_h__
#define __daqmex_h__

#ifdef __cplusplus
extern "C"{
#endif 

/* Forward Declarations */ 

#ifndef __IPropRoot_FWD_DEFINED__
#define __IPropRoot_FWD_DEFINED__
typedef interface IPropRoot IPropRoot;
#endif 	/* __IPropRoot_FWD_DEFINED__ */


#ifndef __IDaqEnum_FWD_DEFINED__
#define __IDaqEnum_FWD_DEFINED__
typedef interface IDaqEnum IDaqEnum;
#endif 	/* __IDaqEnum_FWD_DEFINED__ */


#ifndef __IDaqMappedEnum_FWD_DEFINED__
#define __IDaqMappedEnum_FWD_DEFINED__
typedef interface IDaqMappedEnum IDaqMappedEnum;
#endif 	/* __IDaqMappedEnum_FWD_DEFINED__ */


#ifndef __IProp_FWD_DEFINED__
#define __IProp_FWD_DEFINED__
typedef interface IProp IProp;
#endif 	/* __IProp_FWD_DEFINED__ */


#ifndef __IPropValue_FWD_DEFINED__
#define __IPropValue_FWD_DEFINED__
typedef interface IPropValue IPropValue;
#endif 	/* __IPropValue_FWD_DEFINED__ */


#ifndef __IPropContainer_FWD_DEFINED__
#define __IPropContainer_FWD_DEFINED__
typedef interface IPropContainer IPropContainer;
#endif 	/* __IPropContainer_FWD_DEFINED__ */


#ifndef __IChannelList_FWD_DEFINED__
#define __IChannelList_FWD_DEFINED__
typedef interface IChannelList IChannelList;
#endif 	/* __IChannelList_FWD_DEFINED__ */


#ifndef __IChannel_FWD_DEFINED__
#define __IChannel_FWD_DEFINED__
typedef interface IChannel IChannel;
#endif 	/* __IChannel_FWD_DEFINED__ */


#ifndef __IDaqEngine_FWD_DEFINED__
#define __IDaqEngine_FWD_DEFINED__
typedef interface IDaqEngine IDaqEngine;
#endif 	/* __IDaqEngine_FWD_DEFINED__ */


#ifndef __ImwAdaptor_FWD_DEFINED__
#define __ImwAdaptor_FWD_DEFINED__
typedef interface ImwAdaptor ImwAdaptor;
#endif 	/* __ImwAdaptor_FWD_DEFINED__ */


#ifndef __ImwDevice_FWD_DEFINED__
#define __ImwDevice_FWD_DEFINED__
typedef interface ImwDevice ImwDevice;
#endif 	/* __ImwDevice_FWD_DEFINED__ */


#ifndef __ImwInput_FWD_DEFINED__
#define __ImwInput_FWD_DEFINED__
typedef interface ImwInput ImwInput;
#endif 	/* __ImwInput_FWD_DEFINED__ */


#ifndef __ImwOutput_FWD_DEFINED__
#define __ImwOutput_FWD_DEFINED__
typedef interface ImwOutput ImwOutput;
#endif 	/* __ImwOutput_FWD_DEFINED__ */


#ifndef __ImwDIO_FWD_DEFINED__
#define __ImwDIO_FWD_DEFINED__
typedef interface ImwDIO ImwDIO;
#endif 	/* __ImwDIO_FWD_DEFINED__ */


#ifndef __ImwAdaptor_FWD_DEFINED__
#define __ImwAdaptor_FWD_DEFINED__
typedef interface ImwAdaptor ImwAdaptor;
#endif 	/* __ImwAdaptor_FWD_DEFINED__ */


#ifndef __ImwDevice_FWD_DEFINED__
#define __ImwDevice_FWD_DEFINED__
typedef interface ImwDevice ImwDevice;
#endif 	/* __ImwDevice_FWD_DEFINED__ */


#ifndef __ImwInput_FWD_DEFINED__
#define __ImwInput_FWD_DEFINED__
typedef interface ImwInput ImwInput;
#endif 	/* __ImwInput_FWD_DEFINED__ */


#ifndef __ImwOutput_FWD_DEFINED__
#define __ImwOutput_FWD_DEFINED__
typedef interface ImwOutput ImwOutput;
#endif 	/* __ImwOutput_FWD_DEFINED__ */


#ifndef __ImwDIO_FWD_DEFINED__
#define __ImwDIO_FWD_DEFINED__
typedef interface ImwDIO ImwDIO;
#endif 	/* __ImwDIO_FWD_DEFINED__ */


#ifndef __Prop_FWD_DEFINED__
#define __Prop_FWD_DEFINED__

#ifdef __cplusplus
typedef class Prop Prop;
#else
typedef struct Prop Prop;
#endif /* __cplusplus */

#endif 	/* __Prop_FWD_DEFINED__ */


#ifndef __DaqEngine_FWD_DEFINED__
#define __DaqEngine_FWD_DEFINED__

#ifdef __cplusplus
typedef class DaqEngine DaqEngine;
#else
typedef struct DaqEngine DaqEngine;
#endif /* __cplusplus */

#endif 	/* __DaqEngine_FWD_DEFINED__ */


#ifndef __PropContainer_FWD_DEFINED__
#define __PropContainer_FWD_DEFINED__

#ifdef __cplusplus
typedef class PropContainer PropContainer;
#else
typedef struct PropContainer PropContainer;
#endif /* __cplusplus */

#endif 	/* __PropContainer_FWD_DEFINED__ */


#ifndef __DaqMappedEnum_FWD_DEFINED__
#define __DaqMappedEnum_FWD_DEFINED__

#ifdef __cplusplus
typedef class DaqMappedEnum DaqMappedEnum;
#else
typedef struct DaqMappedEnum DaqMappedEnum;
#endif /* __cplusplus */

#endif 	/* __DaqMappedEnum_FWD_DEFINED__ */


/* header files for imported files */
#include "oaidl.h"
#include "ocidl.h"

void __RPC_FAR * __RPC_USER MIDL_user_allocate(size_t);
void __RPC_USER MIDL_user_free( void __RPC_FAR * ); 

/* interface __MIDL_itf_daqmex_0000 */
/* [local] */ 

//Copyright 1998-2003 The MathWorks, Inc.
// built from  daqmex.idl $Revision: 1.3.4.3 $  $Date: 2003/08/29 04:44:08 $
typedef struct  tagBUFFER
    {
    long Size;
    long ValidPoints;
    /* [size_is][ref] */ unsigned char __RPC_FAR *ptr;
    DWORD dwAdaptorData;
    unsigned long Flags;
    unsigned long Reserved;
    hyper StartPoint;
    double StartTime;
    double EndTime;
    }	BUFFER_ST;

typedef /* [v1_enum] */ 
enum tagNESTABLEPROPTYPES
    {	NPAICHANNEL	= 0,
	NPAOCHANNEL	= NPAICHANNEL + 1,
	NPDIGITALLINE	= NPAOCHANNEL + 1
    }	NESTABLEPROPTYPES;

#if 0
typedef struct  tagNESTABLEPROP
    {
    long StructSize;
    long Index;
    NESTABLEPROPTYPES Type;
    long HwChan;
    BSTR Name;
    /* [size_is] */ BYTE extra[ 1 ];
    }	NESTABLEPROP;

#endif
typedef struct tagNESTABLEPROP
{
    long StructSize;
    long Index;
    NESTABLEPROPTYPES Type;
    long HwChan;
    BSTR Name;
} NESTABLEPROP;
#ifdef __cplusplus
typedef const VARIANT &VARIANTREF;
#else
typedef const VARIANT __RPC_FAR *VARIANTREF;

#endif


extern RPC_IF_HANDLE __MIDL_itf_daqmex_0000_v0_0_c_ifspec;
extern RPC_IF_HANDLE __MIDL_itf_daqmex_0000_v0_0_s_ifspec;

#ifndef __IPropRoot_INTERFACE_DEFINED__
#define __IPropRoot_INTERFACE_DEFINED__

/* interface IPropRoot */
/* [object][unique][helpstring][uuid] */ 


EXTERN_C const IID IID_IPropRoot;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("8BEEFABE-E54A-11d3-A551-00902757EA8D")
    IPropRoot : public IUnknown
    {
    public:
        virtual /* [helpstring][propget] */ HRESULT STDMETHODCALLTYPE get_Name( 
            /* [retval][out] */ BSTR __RPC_FAR *pVal) = 0;
        
        virtual /* [helpstring][propput] */ HRESULT STDMETHODCALLTYPE put_Name( 
            /* [string][in] */ LPCOLESTR newVal) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE GetType( 
            /* [out] */ long __RPC_FAR *Type) = 0;
        
        virtual /* [helpstring][propget] */ HRESULT STDMETHODCALLTYPE get_User( 
            /* [retval][out] */ long __RPC_FAR *pVal) = 0;
        
        virtual /* [helpstring][propput] */ HRESULT STDMETHODCALLTYPE put_User( 
            /* [in] */ long newVal) = 0;
        
        virtual /* [helpstring][propget] */ HRESULT STDMETHODCALLTYPE get_IsHidden( 
            /* [retval][out] */ BOOL __RPC_FAR *pVal) = 0;
        
        virtual /* [helpstring][propput] */ HRESULT STDMETHODCALLTYPE put_IsHidden( 
            /* [in] */ BOOL newVal) = 0;
        
        virtual /* [helpstring][propget] */ HRESULT STDMETHODCALLTYPE get_IsReadOnly( 
            /* [retval][out] */ BOOL __RPC_FAR *pVal) = 0;
        
        virtual /* [helpstring][propput] */ HRESULT STDMETHODCALLTYPE put_IsReadOnly( 
            /* [in] */ BOOL newVal) = 0;
        
        virtual /* [helpstring][propget] */ HRESULT STDMETHODCALLTYPE get_IsReadonlyRunning( 
            /* [retval][out] */ BOOL __RPC_FAR *pVal) = 0;
        
        virtual /* [helpstring][propput] */ HRESULT STDMETHODCALLTYPE put_IsReadonlyRunning( 
            /* [in] */ BOOL newVal) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE GetRange( 
            /* [out] */ VARIANT __RPC_FAR *min,
            /* [out] */ VARIANT __RPC_FAR *max) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE SetRange( 
            /* [in] */ VARIANT __RPC_FAR *min,
            /* [in] */ VARIANT __RPC_FAR *max) = 0;
        
        virtual /* [local][restricted][hidden][helpstring] */ long STDMETHODCALLTYPE _GetObject( void) = 0;
        
        virtual /* [helpstring][propget] */ HRESULT STDMETHODCALLTYPE get_DefaultValue( 
            /* [retval][out] */ VARIANT __RPC_FAR *pVal) = 0;
        
        virtual /* [helpstring][propput] */ HRESULT STDMETHODCALLTYPE put_DefaultValue( 
            /* [in] */ VARIANTREF newVal) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE IsValidValue( 
            /* [in] */ VARIANTREF value) = 0;
        
    };
    
#else 	/* C style interface */

    typedef struct IPropRootVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *QueryInterface )( 
            IPropRoot __RPC_FAR * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *ppvObject);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *AddRef )( 
            IPropRoot __RPC_FAR * This);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *Release )( 
            IPropRoot __RPC_FAR * This);
        
        /* [helpstring][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Name )( 
            IPropRoot __RPC_FAR * This,
            /* [retval][out] */ BSTR __RPC_FAR *pVal);
        
        /* [helpstring][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_Name )( 
            IPropRoot __RPC_FAR * This,
            /* [string][in] */ LPCOLESTR newVal);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetType )( 
            IPropRoot __RPC_FAR * This,
            /* [out] */ long __RPC_FAR *Type);
        
        /* [helpstring][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_User )( 
            IPropRoot __RPC_FAR * This,
            /* [retval][out] */ long __RPC_FAR *pVal);
        
        /* [helpstring][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_User )( 
            IPropRoot __RPC_FAR * This,
            /* [in] */ long newVal);
        
        /* [helpstring][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_IsHidden )( 
            IPropRoot __RPC_FAR * This,
            /* [retval][out] */ BOOL __RPC_FAR *pVal);
        
        /* [helpstring][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_IsHidden )( 
            IPropRoot __RPC_FAR * This,
            /* [in] */ BOOL newVal);
        
        /* [helpstring][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_IsReadOnly )( 
            IPropRoot __RPC_FAR * This,
            /* [retval][out] */ BOOL __RPC_FAR *pVal);
        
        /* [helpstring][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_IsReadOnly )( 
            IPropRoot __RPC_FAR * This,
            /* [in] */ BOOL newVal);
        
        /* [helpstring][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_IsReadonlyRunning )( 
            IPropRoot __RPC_FAR * This,
            /* [retval][out] */ BOOL __RPC_FAR *pVal);
        
        /* [helpstring][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_IsReadonlyRunning )( 
            IPropRoot __RPC_FAR * This,
            /* [in] */ BOOL newVal);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetRange )( 
            IPropRoot __RPC_FAR * This,
            /* [out] */ VARIANT __RPC_FAR *min,
            /* [out] */ VARIANT __RPC_FAR *max);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *SetRange )( 
            IPropRoot __RPC_FAR * This,
            /* [in] */ VARIANT __RPC_FAR *min,
            /* [in] */ VARIANT __RPC_FAR *max);
        
        /* [local][restricted][hidden][helpstring] */ long ( STDMETHODCALLTYPE __RPC_FAR *_GetObject )( 
            IPropRoot __RPC_FAR * This);
        
        /* [helpstring][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_DefaultValue )( 
            IPropRoot __RPC_FAR * This,
            /* [retval][out] */ VARIANT __RPC_FAR *pVal);
        
        /* [helpstring][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_DefaultValue )( 
            IPropRoot __RPC_FAR * This,
            /* [in] */ VARIANTREF newVal);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *IsValidValue )( 
            IPropRoot __RPC_FAR * This,
            /* [in] */ VARIANTREF value);
        
        END_INTERFACE
    } IPropRootVtbl;

    interface IPropRoot
    {
        CONST_VTBL struct IPropRootVtbl __RPC_FAR *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IPropRoot_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define IPropRoot_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define IPropRoot_Release(This)	\
    (This)->lpVtbl -> Release(This)


#define IPropRoot_get_Name(This,pVal)	\
    (This)->lpVtbl -> get_Name(This,pVal)

#define IPropRoot_put_Name(This,newVal)	\
    (This)->lpVtbl -> put_Name(This,newVal)

#define IPropRoot_GetType(This,Type)	\
    (This)->lpVtbl -> GetType(This,Type)

#define IPropRoot_get_User(This,pVal)	\
    (This)->lpVtbl -> get_User(This,pVal)

#define IPropRoot_put_User(This,newVal)	\
    (This)->lpVtbl -> put_User(This,newVal)

#define IPropRoot_get_IsHidden(This,pVal)	\
    (This)->lpVtbl -> get_IsHidden(This,pVal)

#define IPropRoot_put_IsHidden(This,newVal)	\
    (This)->lpVtbl -> put_IsHidden(This,newVal)

#define IPropRoot_get_IsReadOnly(This,pVal)	\
    (This)->lpVtbl -> get_IsReadOnly(This,pVal)

#define IPropRoot_put_IsReadOnly(This,newVal)	\
    (This)->lpVtbl -> put_IsReadOnly(This,newVal)

#define IPropRoot_get_IsReadonlyRunning(This,pVal)	\
    (This)->lpVtbl -> get_IsReadonlyRunning(This,pVal)

#define IPropRoot_put_IsReadonlyRunning(This,newVal)	\
    (This)->lpVtbl -> put_IsReadonlyRunning(This,newVal)

#define IPropRoot_GetRange(This,min,max)	\
    (This)->lpVtbl -> GetRange(This,min,max)

#define IPropRoot_SetRange(This,min,max)	\
    (This)->lpVtbl -> SetRange(This,min,max)

#define IPropRoot__GetObject(This)	\
    (This)->lpVtbl -> _GetObject(This)

#define IPropRoot_get_DefaultValue(This,pVal)	\
    (This)->lpVtbl -> get_DefaultValue(This,pVal)

#define IPropRoot_put_DefaultValue(This,newVal)	\
    (This)->lpVtbl -> put_DefaultValue(This,newVal)

#define IPropRoot_IsValidValue(This,value)	\
    (This)->lpVtbl -> IsValidValue(This,value)

#endif /* COBJMACROS */


#endif 	/* C style interface */



/* [helpstring][propget] */ HRESULT STDMETHODCALLTYPE IPropRoot_get_Name_Proxy( 
    IPropRoot __RPC_FAR * This,
    /* [retval][out] */ BSTR __RPC_FAR *pVal);


void __RPC_STUB IPropRoot_get_Name_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][propput] */ HRESULT STDMETHODCALLTYPE IPropRoot_put_Name_Proxy( 
    IPropRoot __RPC_FAR * This,
    /* [string][in] */ LPCOLESTR newVal);


void __RPC_STUB IPropRoot_put_Name_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE IPropRoot_GetType_Proxy( 
    IPropRoot __RPC_FAR * This,
    /* [out] */ long __RPC_FAR *Type);


void __RPC_STUB IPropRoot_GetType_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][propget] */ HRESULT STDMETHODCALLTYPE IPropRoot_get_User_Proxy( 
    IPropRoot __RPC_FAR * This,
    /* [retval][out] */ long __RPC_FAR *pVal);


void __RPC_STUB IPropRoot_get_User_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][propput] */ HRESULT STDMETHODCALLTYPE IPropRoot_put_User_Proxy( 
    IPropRoot __RPC_FAR * This,
    /* [in] */ long newVal);


void __RPC_STUB IPropRoot_put_User_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][propget] */ HRESULT STDMETHODCALLTYPE IPropRoot_get_IsHidden_Proxy( 
    IPropRoot __RPC_FAR * This,
    /* [retval][out] */ BOOL __RPC_FAR *pVal);


void __RPC_STUB IPropRoot_get_IsHidden_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][propput] */ HRESULT STDMETHODCALLTYPE IPropRoot_put_IsHidden_Proxy( 
    IPropRoot __RPC_FAR * This,
    /* [in] */ BOOL newVal);


void __RPC_STUB IPropRoot_put_IsHidden_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][propget] */ HRESULT STDMETHODCALLTYPE IPropRoot_get_IsReadOnly_Proxy( 
    IPropRoot __RPC_FAR * This,
    /* [retval][out] */ BOOL __RPC_FAR *pVal);


void __RPC_STUB IPropRoot_get_IsReadOnly_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][propput] */ HRESULT STDMETHODCALLTYPE IPropRoot_put_IsReadOnly_Proxy( 
    IPropRoot __RPC_FAR * This,
    /* [in] */ BOOL newVal);


void __RPC_STUB IPropRoot_put_IsReadOnly_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][propget] */ HRESULT STDMETHODCALLTYPE IPropRoot_get_IsReadonlyRunning_Proxy( 
    IPropRoot __RPC_FAR * This,
    /* [retval][out] */ BOOL __RPC_FAR *pVal);


void __RPC_STUB IPropRoot_get_IsReadonlyRunning_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][propput] */ HRESULT STDMETHODCALLTYPE IPropRoot_put_IsReadonlyRunning_Proxy( 
    IPropRoot __RPC_FAR * This,
    /* [in] */ BOOL newVal);


void __RPC_STUB IPropRoot_put_IsReadonlyRunning_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE IPropRoot_GetRange_Proxy( 
    IPropRoot __RPC_FAR * This,
    /* [out] */ VARIANT __RPC_FAR *min,
    /* [out] */ VARIANT __RPC_FAR *max);


void __RPC_STUB IPropRoot_GetRange_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE IPropRoot_SetRange_Proxy( 
    IPropRoot __RPC_FAR * This,
    /* [in] */ VARIANT __RPC_FAR *min,
    /* [in] */ VARIANT __RPC_FAR *max);


void __RPC_STUB IPropRoot_SetRange_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [local][restricted][hidden][helpstring] */ long STDMETHODCALLTYPE IPropRoot__GetObject_Proxy( 
    IPropRoot __RPC_FAR * This);


void __RPC_STUB IPropRoot__GetObject_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][propget] */ HRESULT STDMETHODCALLTYPE IPropRoot_get_DefaultValue_Proxy( 
    IPropRoot __RPC_FAR * This,
    /* [retval][out] */ VARIANT __RPC_FAR *pVal);


void __RPC_STUB IPropRoot_get_DefaultValue_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][propput] */ HRESULT STDMETHODCALLTYPE IPropRoot_put_DefaultValue_Proxy( 
    IPropRoot __RPC_FAR * This,
    /* [in] */ VARIANTREF newVal);


void __RPC_STUB IPropRoot_put_DefaultValue_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE IPropRoot_IsValidValue_Proxy( 
    IPropRoot __RPC_FAR * This,
    /* [in] */ VARIANTREF value);


void __RPC_STUB IPropRoot_IsValidValue_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);



#endif 	/* __IPropRoot_INTERFACE_DEFINED__ */


#ifndef __IDaqEnum_INTERFACE_DEFINED__
#define __IDaqEnum_INTERFACE_DEFINED__

/* interface IDaqEnum */
/* [object][unique][helpstring][uuid] */ 


EXTERN_C const IID IID_IDaqEnum;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("F3F93B7F-93C7-11d3-A526-00902757EA8D")
    IDaqEnum : public IPropRoot
    {
    public:
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE AddEnumValues( 
            /* [in] */ VARIANTREF values) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE ClearEnumValues( void) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE RemoveEnumValue( 
            /* [in] */ VARIANTREF values) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE EnumValues( 
            /* [out] */ IEnumVARIANT __RPC_FAR *__RPC_FAR *EnumVARIANT) = 0;
        
    };
    
#else 	/* C style interface */

    typedef struct IDaqEnumVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *QueryInterface )( 
            IDaqEnum __RPC_FAR * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *ppvObject);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *AddRef )( 
            IDaqEnum __RPC_FAR * This);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *Release )( 
            IDaqEnum __RPC_FAR * This);
        
        /* [helpstring][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Name )( 
            IDaqEnum __RPC_FAR * This,
            /* [retval][out] */ BSTR __RPC_FAR *pVal);
        
        /* [helpstring][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_Name )( 
            IDaqEnum __RPC_FAR * This,
            /* [string][in] */ LPCOLESTR newVal);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetType )( 
            IDaqEnum __RPC_FAR * This,
            /* [out] */ long __RPC_FAR *Type);
        
        /* [helpstring][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_User )( 
            IDaqEnum __RPC_FAR * This,
            /* [retval][out] */ long __RPC_FAR *pVal);
        
        /* [helpstring][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_User )( 
            IDaqEnum __RPC_FAR * This,
            /* [in] */ long newVal);
        
        /* [helpstring][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_IsHidden )( 
            IDaqEnum __RPC_FAR * This,
            /* [retval][out] */ BOOL __RPC_FAR *pVal);
        
        /* [helpstring][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_IsHidden )( 
            IDaqEnum __RPC_FAR * This,
            /* [in] */ BOOL newVal);
        
        /* [helpstring][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_IsReadOnly )( 
            IDaqEnum __RPC_FAR * This,
            /* [retval][out] */ BOOL __RPC_FAR *pVal);
        
        /* [helpstring][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_IsReadOnly )( 
            IDaqEnum __RPC_FAR * This,
            /* [in] */ BOOL newVal);
        
        /* [helpstring][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_IsReadonlyRunning )( 
            IDaqEnum __RPC_FAR * This,
            /* [retval][out] */ BOOL __RPC_FAR *pVal);
        
        /* [helpstring][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_IsReadonlyRunning )( 
            IDaqEnum __RPC_FAR * This,
            /* [in] */ BOOL newVal);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetRange )( 
            IDaqEnum __RPC_FAR * This,
            /* [out] */ VARIANT __RPC_FAR *min,
            /* [out] */ VARIANT __RPC_FAR *max);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *SetRange )( 
            IDaqEnum __RPC_FAR * This,
            /* [in] */ VARIANT __RPC_FAR *min,
            /* [in] */ VARIANT __RPC_FAR *max);
        
        /* [local][restricted][hidden][helpstring] */ long ( STDMETHODCALLTYPE __RPC_FAR *_GetObject )( 
            IDaqEnum __RPC_FAR * This);
        
        /* [helpstring][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_DefaultValue )( 
            IDaqEnum __RPC_FAR * This,
            /* [retval][out] */ VARIANT __RPC_FAR *pVal);
        
        /* [helpstring][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_DefaultValue )( 
            IDaqEnum __RPC_FAR * This,
            /* [in] */ VARIANTREF newVal);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *IsValidValue )( 
            IDaqEnum __RPC_FAR * This,
            /* [in] */ VARIANTREF value);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *AddEnumValues )( 
            IDaqEnum __RPC_FAR * This,
            /* [in] */ VARIANTREF values);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *ClearEnumValues )( 
            IDaqEnum __RPC_FAR * This);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *RemoveEnumValue )( 
            IDaqEnum __RPC_FAR * This,
            /* [in] */ VARIANTREF values);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *EnumValues )( 
            IDaqEnum __RPC_FAR * This,
            /* [out] */ IEnumVARIANT __RPC_FAR *__RPC_FAR *EnumVARIANT);
        
        END_INTERFACE
    } IDaqEnumVtbl;

    interface IDaqEnum
    {
        CONST_VTBL struct IDaqEnumVtbl __RPC_FAR *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IDaqEnum_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define IDaqEnum_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define IDaqEnum_Release(This)	\
    (This)->lpVtbl -> Release(This)


#define IDaqEnum_get_Name(This,pVal)	\
    (This)->lpVtbl -> get_Name(This,pVal)

#define IDaqEnum_put_Name(This,newVal)	\
    (This)->lpVtbl -> put_Name(This,newVal)

#define IDaqEnum_GetType(This,Type)	\
    (This)->lpVtbl -> GetType(This,Type)

#define IDaqEnum_get_User(This,pVal)	\
    (This)->lpVtbl -> get_User(This,pVal)

#define IDaqEnum_put_User(This,newVal)	\
    (This)->lpVtbl -> put_User(This,newVal)

#define IDaqEnum_get_IsHidden(This,pVal)	\
    (This)->lpVtbl -> get_IsHidden(This,pVal)

#define IDaqEnum_put_IsHidden(This,newVal)	\
    (This)->lpVtbl -> put_IsHidden(This,newVal)

#define IDaqEnum_get_IsReadOnly(This,pVal)	\
    (This)->lpVtbl -> get_IsReadOnly(This,pVal)

#define IDaqEnum_put_IsReadOnly(This,newVal)	\
    (This)->lpVtbl -> put_IsReadOnly(This,newVal)

#define IDaqEnum_get_IsReadonlyRunning(This,pVal)	\
    (This)->lpVtbl -> get_IsReadonlyRunning(This,pVal)

#define IDaqEnum_put_IsReadonlyRunning(This,newVal)	\
    (This)->lpVtbl -> put_IsReadonlyRunning(This,newVal)

#define IDaqEnum_GetRange(This,min,max)	\
    (This)->lpVtbl -> GetRange(This,min,max)

#define IDaqEnum_SetRange(This,min,max)	\
    (This)->lpVtbl -> SetRange(This,min,max)

#define IDaqEnum__GetObject(This)	\
    (This)->lpVtbl -> _GetObject(This)

#define IDaqEnum_get_DefaultValue(This,pVal)	\
    (This)->lpVtbl -> get_DefaultValue(This,pVal)

#define IDaqEnum_put_DefaultValue(This,newVal)	\
    (This)->lpVtbl -> put_DefaultValue(This,newVal)

#define IDaqEnum_IsValidValue(This,value)	\
    (This)->lpVtbl -> IsValidValue(This,value)


#define IDaqEnum_AddEnumValues(This,values)	\
    (This)->lpVtbl -> AddEnumValues(This,values)

#define IDaqEnum_ClearEnumValues(This)	\
    (This)->lpVtbl -> ClearEnumValues(This)

#define IDaqEnum_RemoveEnumValue(This,values)	\
    (This)->lpVtbl -> RemoveEnumValue(This,values)

#define IDaqEnum_EnumValues(This,EnumVARIANT)	\
    (This)->lpVtbl -> EnumValues(This,EnumVARIANT)

#endif /* COBJMACROS */


#endif 	/* C style interface */



/* [helpstring] */ HRESULT STDMETHODCALLTYPE IDaqEnum_AddEnumValues_Proxy( 
    IDaqEnum __RPC_FAR * This,
    /* [in] */ VARIANTREF values);


void __RPC_STUB IDaqEnum_AddEnumValues_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE IDaqEnum_ClearEnumValues_Proxy( 
    IDaqEnum __RPC_FAR * This);


void __RPC_STUB IDaqEnum_ClearEnumValues_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE IDaqEnum_RemoveEnumValue_Proxy( 
    IDaqEnum __RPC_FAR * This,
    /* [in] */ VARIANTREF values);


void __RPC_STUB IDaqEnum_RemoveEnumValue_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE IDaqEnum_EnumValues_Proxy( 
    IDaqEnum __RPC_FAR * This,
    /* [out] */ IEnumVARIANT __RPC_FAR *__RPC_FAR *EnumVARIANT);


void __RPC_STUB IDaqEnum_EnumValues_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);



#endif 	/* __IDaqEnum_INTERFACE_DEFINED__ */


#ifndef __IDaqMappedEnum_INTERFACE_DEFINED__
#define __IDaqMappedEnum_INTERFACE_DEFINED__

/* interface IDaqMappedEnum */
/* [object][unique][helpstring][uuid] */ 


EXTERN_C const IID IID_IDaqMappedEnum;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("F3F93B80-93C7-11d3-A526-00902757EA8D")
    IDaqMappedEnum : public IDaqEnum
    {
    public:
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE AddMappedEnumValue( 
            long Value,
            /* [string][in] */ LPCOLESTR StringValue) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE FindString( 
            /* [in] */ long Value,
            /* [out] */ BSTR __RPC_FAR *StringValue) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE FindValue( 
            /* [string][in] */ LPCOLESTR StringValue,
            /* [out] */ long __RPC_FAR *value) = 0;
        
    };
    
#else 	/* C style interface */

    typedef struct IDaqMappedEnumVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *QueryInterface )( 
            IDaqMappedEnum __RPC_FAR * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *ppvObject);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *AddRef )( 
            IDaqMappedEnum __RPC_FAR * This);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *Release )( 
            IDaqMappedEnum __RPC_FAR * This);
        
        /* [helpstring][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Name )( 
            IDaqMappedEnum __RPC_FAR * This,
            /* [retval][out] */ BSTR __RPC_FAR *pVal);
        
        /* [helpstring][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_Name )( 
            IDaqMappedEnum __RPC_FAR * This,
            /* [string][in] */ LPCOLESTR newVal);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetType )( 
            IDaqMappedEnum __RPC_FAR * This,
            /* [out] */ long __RPC_FAR *Type);
        
        /* [helpstring][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_User )( 
            IDaqMappedEnum __RPC_FAR * This,
            /* [retval][out] */ long __RPC_FAR *pVal);
        
        /* [helpstring][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_User )( 
            IDaqMappedEnum __RPC_FAR * This,
            /* [in] */ long newVal);
        
        /* [helpstring][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_IsHidden )( 
            IDaqMappedEnum __RPC_FAR * This,
            /* [retval][out] */ BOOL __RPC_FAR *pVal);
        
        /* [helpstring][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_IsHidden )( 
            IDaqMappedEnum __RPC_FAR * This,
            /* [in] */ BOOL newVal);
        
        /* [helpstring][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_IsReadOnly )( 
            IDaqMappedEnum __RPC_FAR * This,
            /* [retval][out] */ BOOL __RPC_FAR *pVal);
        
        /* [helpstring][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_IsReadOnly )( 
            IDaqMappedEnum __RPC_FAR * This,
            /* [in] */ BOOL newVal);
        
        /* [helpstring][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_IsReadonlyRunning )( 
            IDaqMappedEnum __RPC_FAR * This,
            /* [retval][out] */ BOOL __RPC_FAR *pVal);
        
        /* [helpstring][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_IsReadonlyRunning )( 
            IDaqMappedEnum __RPC_FAR * This,
            /* [in] */ BOOL newVal);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetRange )( 
            IDaqMappedEnum __RPC_FAR * This,
            /* [out] */ VARIANT __RPC_FAR *min,
            /* [out] */ VARIANT __RPC_FAR *max);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *SetRange )( 
            IDaqMappedEnum __RPC_FAR * This,
            /* [in] */ VARIANT __RPC_FAR *min,
            /* [in] */ VARIANT __RPC_FAR *max);
        
        /* [local][restricted][hidden][helpstring] */ long ( STDMETHODCALLTYPE __RPC_FAR *_GetObject )( 
            IDaqMappedEnum __RPC_FAR * This);
        
        /* [helpstring][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_DefaultValue )( 
            IDaqMappedEnum __RPC_FAR * This,
            /* [retval][out] */ VARIANT __RPC_FAR *pVal);
        
        /* [helpstring][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_DefaultValue )( 
            IDaqMappedEnum __RPC_FAR * This,
            /* [in] */ VARIANTREF newVal);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *IsValidValue )( 
            IDaqMappedEnum __RPC_FAR * This,
            /* [in] */ VARIANTREF value);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *AddEnumValues )( 
            IDaqMappedEnum __RPC_FAR * This,
            /* [in] */ VARIANTREF values);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *ClearEnumValues )( 
            IDaqMappedEnum __RPC_FAR * This);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *RemoveEnumValue )( 
            IDaqMappedEnum __RPC_FAR * This,
            /* [in] */ VARIANTREF values);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *EnumValues )( 
            IDaqMappedEnum __RPC_FAR * This,
            /* [out] */ IEnumVARIANT __RPC_FAR *__RPC_FAR *EnumVARIANT);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *AddMappedEnumValue )( 
            IDaqMappedEnum __RPC_FAR * This,
            long Value,
            /* [string][in] */ LPCOLESTR StringValue);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *FindString )( 
            IDaqMappedEnum __RPC_FAR * This,
            /* [in] */ long Value,
            /* [out] */ BSTR __RPC_FAR *StringValue);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *FindValue )( 
            IDaqMappedEnum __RPC_FAR * This,
            /* [string][in] */ LPCOLESTR StringValue,
            /* [out] */ long __RPC_FAR *value);
        
        END_INTERFACE
    } IDaqMappedEnumVtbl;

    interface IDaqMappedEnum
    {
        CONST_VTBL struct IDaqMappedEnumVtbl __RPC_FAR *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IDaqMappedEnum_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define IDaqMappedEnum_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define IDaqMappedEnum_Release(This)	\
    (This)->lpVtbl -> Release(This)


#define IDaqMappedEnum_get_Name(This,pVal)	\
    (This)->lpVtbl -> get_Name(This,pVal)

#define IDaqMappedEnum_put_Name(This,newVal)	\
    (This)->lpVtbl -> put_Name(This,newVal)

#define IDaqMappedEnum_GetType(This,Type)	\
    (This)->lpVtbl -> GetType(This,Type)

#define IDaqMappedEnum_get_User(This,pVal)	\
    (This)->lpVtbl -> get_User(This,pVal)

#define IDaqMappedEnum_put_User(This,newVal)	\
    (This)->lpVtbl -> put_User(This,newVal)

#define IDaqMappedEnum_get_IsHidden(This,pVal)	\
    (This)->lpVtbl -> get_IsHidden(This,pVal)

#define IDaqMappedEnum_put_IsHidden(This,newVal)	\
    (This)->lpVtbl -> put_IsHidden(This,newVal)

#define IDaqMappedEnum_get_IsReadOnly(This,pVal)	\
    (This)->lpVtbl -> get_IsReadOnly(This,pVal)

#define IDaqMappedEnum_put_IsReadOnly(This,newVal)	\
    (This)->lpVtbl -> put_IsReadOnly(This,newVal)

#define IDaqMappedEnum_get_IsReadonlyRunning(This,pVal)	\
    (This)->lpVtbl -> get_IsReadonlyRunning(This,pVal)

#define IDaqMappedEnum_put_IsReadonlyRunning(This,newVal)	\
    (This)->lpVtbl -> put_IsReadonlyRunning(This,newVal)

#define IDaqMappedEnum_GetRange(This,min,max)	\
    (This)->lpVtbl -> GetRange(This,min,max)

#define IDaqMappedEnum_SetRange(This,min,max)	\
    (This)->lpVtbl -> SetRange(This,min,max)

#define IDaqMappedEnum__GetObject(This)	\
    (This)->lpVtbl -> _GetObject(This)

#define IDaqMappedEnum_get_DefaultValue(This,pVal)	\
    (This)->lpVtbl -> get_DefaultValue(This,pVal)

#define IDaqMappedEnum_put_DefaultValue(This,newVal)	\
    (This)->lpVtbl -> put_DefaultValue(This,newVal)

#define IDaqMappedEnum_IsValidValue(This,value)	\
    (This)->lpVtbl -> IsValidValue(This,value)


#define IDaqMappedEnum_AddEnumValues(This,values)	\
    (This)->lpVtbl -> AddEnumValues(This,values)

#define IDaqMappedEnum_ClearEnumValues(This)	\
    (This)->lpVtbl -> ClearEnumValues(This)

#define IDaqMappedEnum_RemoveEnumValue(This,values)	\
    (This)->lpVtbl -> RemoveEnumValue(This,values)

#define IDaqMappedEnum_EnumValues(This,EnumVARIANT)	\
    (This)->lpVtbl -> EnumValues(This,EnumVARIANT)


#define IDaqMappedEnum_AddMappedEnumValue(This,Value,StringValue)	\
    (This)->lpVtbl -> AddMappedEnumValue(This,Value,StringValue)

#define IDaqMappedEnum_FindString(This,Value,StringValue)	\
    (This)->lpVtbl -> FindString(This,Value,StringValue)

#define IDaqMappedEnum_FindValue(This,StringValue,value)	\
    (This)->lpVtbl -> FindValue(This,StringValue,value)

#endif /* COBJMACROS */


#endif 	/* C style interface */



/* [helpstring] */ HRESULT STDMETHODCALLTYPE IDaqMappedEnum_AddMappedEnumValue_Proxy( 
    IDaqMappedEnum __RPC_FAR * This,
    long Value,
    /* [string][in] */ LPCOLESTR StringValue);


void __RPC_STUB IDaqMappedEnum_AddMappedEnumValue_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE IDaqMappedEnum_FindString_Proxy( 
    IDaqMappedEnum __RPC_FAR * This,
    /* [in] */ long Value,
    /* [out] */ BSTR __RPC_FAR *StringValue);


void __RPC_STUB IDaqMappedEnum_FindString_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE IDaqMappedEnum_FindValue_Proxy( 
    IDaqMappedEnum __RPC_FAR * This,
    /* [string][in] */ LPCOLESTR StringValue,
    /* [out] */ long __RPC_FAR *value);


void __RPC_STUB IDaqMappedEnum_FindValue_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);



#endif 	/* __IDaqMappedEnum_INTERFACE_DEFINED__ */


#ifndef __IProp_INTERFACE_DEFINED__
#define __IProp_INTERFACE_DEFINED__

/* interface IProp */
/* [object][unique][helpstring][uuid] */ 


EXTERN_C const IID IID_IProp;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("0BFA2913-D48E-11D1-90BE-00600841F9FF")
    IProp : public IDaqMappedEnum
    {
    public:
        virtual /* [helpstring][propget] */ HRESULT STDMETHODCALLTYPE get_Value( 
            /* [retval][out] */ VARIANT __RPC_FAR *pVal) = 0;
        
        virtual /* [helpstring][propput] */ HRESULT STDMETHODCALLTYPE put_Value( 
            /* [in] */ VARIANTREF newVal) = 0;
        
    };
    
#else 	/* C style interface */

    typedef struct IPropVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *QueryInterface )( 
            IProp __RPC_FAR * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *ppvObject);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *AddRef )( 
            IProp __RPC_FAR * This);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *Release )( 
            IProp __RPC_FAR * This);
        
        /* [helpstring][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Name )( 
            IProp __RPC_FAR * This,
            /* [retval][out] */ BSTR __RPC_FAR *pVal);
        
        /* [helpstring][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_Name )( 
            IProp __RPC_FAR * This,
            /* [string][in] */ LPCOLESTR newVal);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetType )( 
            IProp __RPC_FAR * This,
            /* [out] */ long __RPC_FAR *Type);
        
        /* [helpstring][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_User )( 
            IProp __RPC_FAR * This,
            /* [retval][out] */ long __RPC_FAR *pVal);
        
        /* [helpstring][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_User )( 
            IProp __RPC_FAR * This,
            /* [in] */ long newVal);
        
        /* [helpstring][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_IsHidden )( 
            IProp __RPC_FAR * This,
            /* [retval][out] */ BOOL __RPC_FAR *pVal);
        
        /* [helpstring][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_IsHidden )( 
            IProp __RPC_FAR * This,
            /* [in] */ BOOL newVal);
        
        /* [helpstring][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_IsReadOnly )( 
            IProp __RPC_FAR * This,
            /* [retval][out] */ BOOL __RPC_FAR *pVal);
        
        /* [helpstring][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_IsReadOnly )( 
            IProp __RPC_FAR * This,
            /* [in] */ BOOL newVal);
        
        /* [helpstring][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_IsReadonlyRunning )( 
            IProp __RPC_FAR * This,
            /* [retval][out] */ BOOL __RPC_FAR *pVal);
        
        /* [helpstring][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_IsReadonlyRunning )( 
            IProp __RPC_FAR * This,
            /* [in] */ BOOL newVal);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetRange )( 
            IProp __RPC_FAR * This,
            /* [out] */ VARIANT __RPC_FAR *min,
            /* [out] */ VARIANT __RPC_FAR *max);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *SetRange )( 
            IProp __RPC_FAR * This,
            /* [in] */ VARIANT __RPC_FAR *min,
            /* [in] */ VARIANT __RPC_FAR *max);
        
        /* [local][restricted][hidden][helpstring] */ long ( STDMETHODCALLTYPE __RPC_FAR *_GetObject )( 
            IProp __RPC_FAR * This);
        
        /* [helpstring][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_DefaultValue )( 
            IProp __RPC_FAR * This,
            /* [retval][out] */ VARIANT __RPC_FAR *pVal);
        
        /* [helpstring][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_DefaultValue )( 
            IProp __RPC_FAR * This,
            /* [in] */ VARIANTREF newVal);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *IsValidValue )( 
            IProp __RPC_FAR * This,
            /* [in] */ VARIANTREF value);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *AddEnumValues )( 
            IProp __RPC_FAR * This,
            /* [in] */ VARIANTREF values);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *ClearEnumValues )( 
            IProp __RPC_FAR * This);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *RemoveEnumValue )( 
            IProp __RPC_FAR * This,
            /* [in] */ VARIANTREF values);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *EnumValues )( 
            IProp __RPC_FAR * This,
            /* [out] */ IEnumVARIANT __RPC_FAR *__RPC_FAR *EnumVARIANT);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *AddMappedEnumValue )( 
            IProp __RPC_FAR * This,
            long Value,
            /* [string][in] */ LPCOLESTR StringValue);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *FindString )( 
            IProp __RPC_FAR * This,
            /* [in] */ long Value,
            /* [out] */ BSTR __RPC_FAR *StringValue);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *FindValue )( 
            IProp __RPC_FAR * This,
            /* [string][in] */ LPCOLESTR StringValue,
            /* [out] */ long __RPC_FAR *value);
        
        /* [helpstring][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Value )( 
            IProp __RPC_FAR * This,
            /* [retval][out] */ VARIANT __RPC_FAR *pVal);
        
        /* [helpstring][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_Value )( 
            IProp __RPC_FAR * This,
            /* [in] */ VARIANTREF newVal);
        
        END_INTERFACE
    } IPropVtbl;

    interface IProp
    {
        CONST_VTBL struct IPropVtbl __RPC_FAR *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IProp_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define IProp_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define IProp_Release(This)	\
    (This)->lpVtbl -> Release(This)


#define IProp_get_Name(This,pVal)	\
    (This)->lpVtbl -> get_Name(This,pVal)

#define IProp_put_Name(This,newVal)	\
    (This)->lpVtbl -> put_Name(This,newVal)

#define IProp_GetType(This,Type)	\
    (This)->lpVtbl -> GetType(This,Type)

#define IProp_get_User(This,pVal)	\
    (This)->lpVtbl -> get_User(This,pVal)

#define IProp_put_User(This,newVal)	\
    (This)->lpVtbl -> put_User(This,newVal)

#define IProp_get_IsHidden(This,pVal)	\
    (This)->lpVtbl -> get_IsHidden(This,pVal)

#define IProp_put_IsHidden(This,newVal)	\
    (This)->lpVtbl -> put_IsHidden(This,newVal)

#define IProp_get_IsReadOnly(This,pVal)	\
    (This)->lpVtbl -> get_IsReadOnly(This,pVal)

#define IProp_put_IsReadOnly(This,newVal)	\
    (This)->lpVtbl -> put_IsReadOnly(This,newVal)

#define IProp_get_IsReadonlyRunning(This,pVal)	\
    (This)->lpVtbl -> get_IsReadonlyRunning(This,pVal)

#define IProp_put_IsReadonlyRunning(This,newVal)	\
    (This)->lpVtbl -> put_IsReadonlyRunning(This,newVal)

#define IProp_GetRange(This,min,max)	\
    (This)->lpVtbl -> GetRange(This,min,max)

#define IProp_SetRange(This,min,max)	\
    (This)->lpVtbl -> SetRange(This,min,max)

#define IProp__GetObject(This)	\
    (This)->lpVtbl -> _GetObject(This)

#define IProp_get_DefaultValue(This,pVal)	\
    (This)->lpVtbl -> get_DefaultValue(This,pVal)

#define IProp_put_DefaultValue(This,newVal)	\
    (This)->lpVtbl -> put_DefaultValue(This,newVal)

#define IProp_IsValidValue(This,value)	\
    (This)->lpVtbl -> IsValidValue(This,value)


#define IProp_AddEnumValues(This,values)	\
    (This)->lpVtbl -> AddEnumValues(This,values)

#define IProp_ClearEnumValues(This)	\
    (This)->lpVtbl -> ClearEnumValues(This)

#define IProp_RemoveEnumValue(This,values)	\
    (This)->lpVtbl -> RemoveEnumValue(This,values)

#define IProp_EnumValues(This,EnumVARIANT)	\
    (This)->lpVtbl -> EnumValues(This,EnumVARIANT)


#define IProp_AddMappedEnumValue(This,Value,StringValue)	\
    (This)->lpVtbl -> AddMappedEnumValue(This,Value,StringValue)

#define IProp_FindString(This,Value,StringValue)	\
    (This)->lpVtbl -> FindString(This,Value,StringValue)

#define IProp_FindValue(This,StringValue,value)	\
    (This)->lpVtbl -> FindValue(This,StringValue,value)


#define IProp_get_Value(This,pVal)	\
    (This)->lpVtbl -> get_Value(This,pVal)

#define IProp_put_Value(This,newVal)	\
    (This)->lpVtbl -> put_Value(This,newVal)

#endif /* COBJMACROS */


#endif 	/* C style interface */



/* [helpstring][propget] */ HRESULT STDMETHODCALLTYPE IProp_get_Value_Proxy( 
    IProp __RPC_FAR * This,
    /* [retval][out] */ VARIANT __RPC_FAR *pVal);


void __RPC_STUB IProp_get_Value_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][propput] */ HRESULT STDMETHODCALLTYPE IProp_put_Value_Proxy( 
    IProp __RPC_FAR * This,
    /* [in] */ VARIANTREF newVal);


void __RPC_STUB IProp_put_Value_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);



#endif 	/* __IProp_INTERFACE_DEFINED__ */


#ifndef __IPropValue_INTERFACE_DEFINED__
#define __IPropValue_INTERFACE_DEFINED__

/* interface IPropValue */
/* [object][unique][helpstring][uuid] */ 


EXTERN_C const IID IID_IPropValue;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("2A27FFA5-5CEF-11d4-A591-00902757EA8D")
    IPropValue : public IUnknown
    {
    public:
        virtual /* [helpstring][propget] */ HRESULT STDMETHODCALLTYPE get_Value( 
            /* [retval][out] */ VARIANT __RPC_FAR *pVal) = 0;
        
        virtual /* [helpstring][propput] */ HRESULT STDMETHODCALLTYPE put_Value( 
            /* [in] */ VARIANTREF newVal) = 0;
        
    };
    
#else 	/* C style interface */

    typedef struct IPropValueVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *QueryInterface )( 
            IPropValue __RPC_FAR * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *ppvObject);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *AddRef )( 
            IPropValue __RPC_FAR * This);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *Release )( 
            IPropValue __RPC_FAR * This);
        
        /* [helpstring][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_Value )( 
            IPropValue __RPC_FAR * This,
            /* [retval][out] */ VARIANT __RPC_FAR *pVal);
        
        /* [helpstring][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_Value )( 
            IPropValue __RPC_FAR * This,
            /* [in] */ VARIANTREF newVal);
        
        END_INTERFACE
    } IPropValueVtbl;

    interface IPropValue
    {
        CONST_VTBL struct IPropValueVtbl __RPC_FAR *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IPropValue_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define IPropValue_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define IPropValue_Release(This)	\
    (This)->lpVtbl -> Release(This)


#define IPropValue_get_Value(This,pVal)	\
    (This)->lpVtbl -> get_Value(This,pVal)

#define IPropValue_put_Value(This,newVal)	\
    (This)->lpVtbl -> put_Value(This,newVal)

#endif /* COBJMACROS */


#endif 	/* C style interface */



/* [helpstring][propget] */ HRESULT STDMETHODCALLTYPE IPropValue_get_Value_Proxy( 
    IPropValue __RPC_FAR * This,
    /* [retval][out] */ VARIANT __RPC_FAR *pVal);


void __RPC_STUB IPropValue_get_Value_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][propput] */ HRESULT STDMETHODCALLTYPE IPropValue_put_Value_Proxy( 
    IPropValue __RPC_FAR * This,
    /* [in] */ VARIANTREF newVal);


void __RPC_STUB IPropValue_put_Value_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);



#endif 	/* __IPropValue_INTERFACE_DEFINED__ */


#ifndef __IPropContainer_INTERFACE_DEFINED__
#define __IPropContainer_INTERFACE_DEFINED__

/* interface IPropContainer */
/* [object][unique][helpstring][uuid] */ 


EXTERN_C const IID IID_IPropContainer;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("E79D1B45-DF5F-11D1-90C1-00600841F9FF")
    IPropContainer : public IUnknown
    {
    public:
        virtual /* [helpstring][propget] */ HRESULT STDMETHODCALLTYPE get_MemberValue( 
            /* [string][in] */ LPCOLESTR MemberName,
            /* [retval][out] */ VARIANT __RPC_FAR *pVal) = 0;
        
        virtual /* [helpstring][propput] */ HRESULT STDMETHODCALLTYPE put_MemberValue( 
            /* [string][in] */ LPCOLESTR MemberName,
            /* [in] */ VARIANTREF newVal) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE GetMemberInterface( 
            /* [unique][string][in] */ LPCOLESTR MemberName,
            /* [in] */ REFIID RequesedIID,
            /* [iid_is][retval][out] */ void __RPC_FAR *__RPC_FAR *Interface) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE CreateProperty( 
            /* [string][in] */ LPCOLESTR Name,
            /* [in] */ VARIANT __RPC_FAR *InitialValue,
            /* [in] */ REFIID RequesedIID,
            /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *NewProp) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE EnumMembers( 
            /* [out] */ IEnumUnknown __RPC_FAR *__RPC_FAR *ppIEnumUnk) = 0;
        
    };
    
#else 	/* C style interface */

    typedef struct IPropContainerVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *QueryInterface )( 
            IPropContainer __RPC_FAR * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *ppvObject);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *AddRef )( 
            IPropContainer __RPC_FAR * This);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *Release )( 
            IPropContainer __RPC_FAR * This);
        
        /* [helpstring][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_MemberValue )( 
            IPropContainer __RPC_FAR * This,
            /* [string][in] */ LPCOLESTR MemberName,
            /* [retval][out] */ VARIANT __RPC_FAR *pVal);
        
        /* [helpstring][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_MemberValue )( 
            IPropContainer __RPC_FAR * This,
            /* [string][in] */ LPCOLESTR MemberName,
            /* [in] */ VARIANTREF newVal);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetMemberInterface )( 
            IPropContainer __RPC_FAR * This,
            /* [unique][string][in] */ LPCOLESTR MemberName,
            /* [in] */ REFIID RequesedIID,
            /* [iid_is][retval][out] */ void __RPC_FAR *__RPC_FAR *Interface);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *CreateProperty )( 
            IPropContainer __RPC_FAR * This,
            /* [string][in] */ LPCOLESTR Name,
            /* [in] */ VARIANT __RPC_FAR *InitialValue,
            /* [in] */ REFIID RequesedIID,
            /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *NewProp);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *EnumMembers )( 
            IPropContainer __RPC_FAR * This,
            /* [out] */ IEnumUnknown __RPC_FAR *__RPC_FAR *ppIEnumUnk);
        
        END_INTERFACE
    } IPropContainerVtbl;

    interface IPropContainer
    {
        CONST_VTBL struct IPropContainerVtbl __RPC_FAR *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IPropContainer_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define IPropContainer_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define IPropContainer_Release(This)	\
    (This)->lpVtbl -> Release(This)


#define IPropContainer_get_MemberValue(This,MemberName,pVal)	\
    (This)->lpVtbl -> get_MemberValue(This,MemberName,pVal)

#define IPropContainer_put_MemberValue(This,MemberName,newVal)	\
    (This)->lpVtbl -> put_MemberValue(This,MemberName,newVal)

#define IPropContainer_GetMemberInterface(This,MemberName,RequesedIID,Interface)	\
    (This)->lpVtbl -> GetMemberInterface(This,MemberName,RequesedIID,Interface)

#define IPropContainer_CreateProperty(This,Name,InitialValue,RequesedIID,NewProp)	\
    (This)->lpVtbl -> CreateProperty(This,Name,InitialValue,RequesedIID,NewProp)

#define IPropContainer_EnumMembers(This,ppIEnumUnk)	\
    (This)->lpVtbl -> EnumMembers(This,ppIEnumUnk)

#endif /* COBJMACROS */


#endif 	/* C style interface */



/* [helpstring][propget] */ HRESULT STDMETHODCALLTYPE IPropContainer_get_MemberValue_Proxy( 
    IPropContainer __RPC_FAR * This,
    /* [string][in] */ LPCOLESTR MemberName,
    /* [retval][out] */ VARIANT __RPC_FAR *pVal);


void __RPC_STUB IPropContainer_get_MemberValue_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][propput] */ HRESULT STDMETHODCALLTYPE IPropContainer_put_MemberValue_Proxy( 
    IPropContainer __RPC_FAR * This,
    /* [string][in] */ LPCOLESTR MemberName,
    /* [in] */ VARIANTREF newVal);


void __RPC_STUB IPropContainer_put_MemberValue_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE IPropContainer_GetMemberInterface_Proxy( 
    IPropContainer __RPC_FAR * This,
    /* [unique][string][in] */ LPCOLESTR MemberName,
    /* [in] */ REFIID RequesedIID,
    /* [iid_is][retval][out] */ void __RPC_FAR *__RPC_FAR *Interface);


void __RPC_STUB IPropContainer_GetMemberInterface_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE IPropContainer_CreateProperty_Proxy( 
    IPropContainer __RPC_FAR * This,
    /* [string][in] */ LPCOLESTR Name,
    /* [in] */ VARIANT __RPC_FAR *InitialValue,
    /* [in] */ REFIID RequesedIID,
    /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *NewProp);


void __RPC_STUB IPropContainer_CreateProperty_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE IPropContainer_EnumMembers_Proxy( 
    IPropContainer __RPC_FAR * This,
    /* [out] */ IEnumUnknown __RPC_FAR *__RPC_FAR *ppIEnumUnk);


void __RPC_STUB IPropContainer_EnumMembers_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);



#endif 	/* __IPropContainer_INTERFACE_DEFINED__ */


#ifndef __IChannelList_INTERFACE_DEFINED__
#define __IChannelList_INTERFACE_DEFINED__

/* interface IChannelList */
/* [object][unique][helpstring][uuid] */ 


EXTERN_C const IID IID_IChannelList;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("8BEEFAC1-E54A-11d3-A551-00902757EA8D")
    IChannelList : public IPropContainer
    {
    public:
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE GetChannelContainer( 
            long index,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *Cont) = 0;
        
        virtual /* [local][helpstring] */ HRESULT STDMETHODCALLTYPE GetChannelStructLocal( 
            long index,
            /* [ref][out] */ NESTABLEPROP __RPC_FAR *__RPC_FAR *Channel) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE GetChannelStruct( 
            long index,
            /* [out] */ NESTABLEPROP __RPC_FAR *__RPC_FAR *Channel) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE GetNumberOfChannels( 
            /* [out] */ long __RPC_FAR *Number) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE CreateChannel( 
            long HwChannel,
            /* [out] */ IPropContainer __RPC_FAR *__RPC_FAR *Cont) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE DeleteChannel( 
            long index) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE DeleteAllChannels( void) = 0;
        
    };
    
#else 	/* C style interface */

    typedef struct IChannelListVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *QueryInterface )( 
            IChannelList __RPC_FAR * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *ppvObject);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *AddRef )( 
            IChannelList __RPC_FAR * This);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *Release )( 
            IChannelList __RPC_FAR * This);
        
        /* [helpstring][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_MemberValue )( 
            IChannelList __RPC_FAR * This,
            /* [string][in] */ LPCOLESTR MemberName,
            /* [retval][out] */ VARIANT __RPC_FAR *pVal);
        
        /* [helpstring][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_MemberValue )( 
            IChannelList __RPC_FAR * This,
            /* [string][in] */ LPCOLESTR MemberName,
            /* [in] */ VARIANTREF newVal);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetMemberInterface )( 
            IChannelList __RPC_FAR * This,
            /* [unique][string][in] */ LPCOLESTR MemberName,
            /* [in] */ REFIID RequesedIID,
            /* [iid_is][retval][out] */ void __RPC_FAR *__RPC_FAR *Interface);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *CreateProperty )( 
            IChannelList __RPC_FAR * This,
            /* [string][in] */ LPCOLESTR Name,
            /* [in] */ VARIANT __RPC_FAR *InitialValue,
            /* [in] */ REFIID RequesedIID,
            /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *NewProp);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *EnumMembers )( 
            IChannelList __RPC_FAR * This,
            /* [out] */ IEnumUnknown __RPC_FAR *__RPC_FAR *ppIEnumUnk);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetChannelContainer )( 
            IChannelList __RPC_FAR * This,
            long index,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *Cont);
        
        /* [local][helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetChannelStructLocal )( 
            IChannelList __RPC_FAR * This,
            long index,
            /* [ref][out] */ NESTABLEPROP __RPC_FAR *__RPC_FAR *Channel);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetChannelStruct )( 
            IChannelList __RPC_FAR * This,
            long index,
            /* [out] */ NESTABLEPROP __RPC_FAR *__RPC_FAR *Channel);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetNumberOfChannels )( 
            IChannelList __RPC_FAR * This,
            /* [out] */ long __RPC_FAR *Number);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *CreateChannel )( 
            IChannelList __RPC_FAR * This,
            long HwChannel,
            /* [out] */ IPropContainer __RPC_FAR *__RPC_FAR *Cont);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *DeleteChannel )( 
            IChannelList __RPC_FAR * This,
            long index);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *DeleteAllChannels )( 
            IChannelList __RPC_FAR * This);
        
        END_INTERFACE
    } IChannelListVtbl;

    interface IChannelList
    {
        CONST_VTBL struct IChannelListVtbl __RPC_FAR *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IChannelList_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define IChannelList_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define IChannelList_Release(This)	\
    (This)->lpVtbl -> Release(This)


#define IChannelList_get_MemberValue(This,MemberName,pVal)	\
    (This)->lpVtbl -> get_MemberValue(This,MemberName,pVal)

#define IChannelList_put_MemberValue(This,MemberName,newVal)	\
    (This)->lpVtbl -> put_MemberValue(This,MemberName,newVal)

#define IChannelList_GetMemberInterface(This,MemberName,RequesedIID,Interface)	\
    (This)->lpVtbl -> GetMemberInterface(This,MemberName,RequesedIID,Interface)

#define IChannelList_CreateProperty(This,Name,InitialValue,RequesedIID,NewProp)	\
    (This)->lpVtbl -> CreateProperty(This,Name,InitialValue,RequesedIID,NewProp)

#define IChannelList_EnumMembers(This,ppIEnumUnk)	\
    (This)->lpVtbl -> EnumMembers(This,ppIEnumUnk)


#define IChannelList_GetChannelContainer(This,index,riid,Cont)	\
    (This)->lpVtbl -> GetChannelContainer(This,index,riid,Cont)

#define IChannelList_GetChannelStructLocal(This,index,Channel)	\
    (This)->lpVtbl -> GetChannelStructLocal(This,index,Channel)

#define IChannelList_GetChannelStruct(This,index,Channel)	\
    (This)->lpVtbl -> GetChannelStruct(This,index,Channel)

#define IChannelList_GetNumberOfChannels(This,Number)	\
    (This)->lpVtbl -> GetNumberOfChannels(This,Number)

#define IChannelList_CreateChannel(This,HwChannel,Cont)	\
    (This)->lpVtbl -> CreateChannel(This,HwChannel,Cont)

#define IChannelList_DeleteChannel(This,index)	\
    (This)->lpVtbl -> DeleteChannel(This,index)

#define IChannelList_DeleteAllChannels(This)	\
    (This)->lpVtbl -> DeleteAllChannels(This)

#endif /* COBJMACROS */


#endif 	/* C style interface */



/* [helpstring] */ HRESULT STDMETHODCALLTYPE IChannelList_GetChannelContainer_Proxy( 
    IChannelList __RPC_FAR * This,
    long index,
    /* [in] */ REFIID riid,
    /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *Cont);


void __RPC_STUB IChannelList_GetChannelContainer_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [local][helpstring] */ HRESULT STDMETHODCALLTYPE IChannelList_GetChannelStructLocal_Proxy( 
    IChannelList __RPC_FAR * This,
    long index,
    /* [ref][out] */ NESTABLEPROP __RPC_FAR *__RPC_FAR *Channel);


void __RPC_STUB IChannelList_GetChannelStructLocal_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE IChannelList_GetChannelStruct_Proxy( 
    IChannelList __RPC_FAR * This,
    long index,
    /* [out] */ NESTABLEPROP __RPC_FAR *__RPC_FAR *Channel);


void __RPC_STUB IChannelList_GetChannelStruct_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE IChannelList_GetNumberOfChannels_Proxy( 
    IChannelList __RPC_FAR * This,
    /* [out] */ long __RPC_FAR *Number);


void __RPC_STUB IChannelList_GetNumberOfChannels_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE IChannelList_CreateChannel_Proxy( 
    IChannelList __RPC_FAR * This,
    long HwChannel,
    /* [out] */ IPropContainer __RPC_FAR *__RPC_FAR *Cont);


void __RPC_STUB IChannelList_CreateChannel_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE IChannelList_DeleteChannel_Proxy( 
    IChannelList __RPC_FAR * This,
    long index);


void __RPC_STUB IChannelList_DeleteChannel_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE IChannelList_DeleteAllChannels_Proxy( 
    IChannelList __RPC_FAR * This);


void __RPC_STUB IChannelList_DeleteAllChannels_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);



#endif 	/* __IChannelList_INTERFACE_DEFINED__ */


#ifndef __IChannel_INTERFACE_DEFINED__
#define __IChannel_INTERFACE_DEFINED__

/* interface IChannel */
/* [object][unique][helpstring][uuid] */ 


EXTERN_C const IID IID_IChannel;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("8BEEFAC0-E54A-11d3-A551-00902757EA8D")
    IChannel : public IPropContainer
    {
    public:
        virtual /* [helpstring][propget] */ HRESULT STDMETHODCALLTYPE get_PropValue( 
            /* [in] */ REFIID riid,
            /* [iid_is][in] */ IPropRoot __RPC_FAR *Member,
            /* [retval][out] */ VARIANT __RPC_FAR *pVal) = 0;
        
        virtual /* [helpstring][propput] */ HRESULT STDMETHODCALLTYPE put_PropValue( 
            /* [in] */ REFIID riid,
            /* [iid_is][in] */ IPropRoot __RPC_FAR *Member,
            /* [in] */ VARIANTREF newVal) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE UnitsToBinary( 
            /* [in] */ double UnitsVal,
            /* [out] */ VARIANT __RPC_FAR *pVal) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE BinaryToUnits( 
            /* [in] */ VARIANTREF BinaryVal,
            /* [out] */ double __RPC_FAR *UnitsVal) = 0;
        
    };
    
#else 	/* C style interface */

    typedef struct IChannelVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *QueryInterface )( 
            IChannel __RPC_FAR * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *ppvObject);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *AddRef )( 
            IChannel __RPC_FAR * This);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *Release )( 
            IChannel __RPC_FAR * This);
        
        /* [helpstring][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_MemberValue )( 
            IChannel __RPC_FAR * This,
            /* [string][in] */ LPCOLESTR MemberName,
            /* [retval][out] */ VARIANT __RPC_FAR *pVal);
        
        /* [helpstring][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_MemberValue )( 
            IChannel __RPC_FAR * This,
            /* [string][in] */ LPCOLESTR MemberName,
            /* [in] */ VARIANTREF newVal);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetMemberInterface )( 
            IChannel __RPC_FAR * This,
            /* [unique][string][in] */ LPCOLESTR MemberName,
            /* [in] */ REFIID RequesedIID,
            /* [iid_is][retval][out] */ void __RPC_FAR *__RPC_FAR *Interface);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *CreateProperty )( 
            IChannel __RPC_FAR * This,
            /* [string][in] */ LPCOLESTR Name,
            /* [in] */ VARIANT __RPC_FAR *InitialValue,
            /* [in] */ REFIID RequesedIID,
            /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *NewProp);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *EnumMembers )( 
            IChannel __RPC_FAR * This,
            /* [out] */ IEnumUnknown __RPC_FAR *__RPC_FAR *ppIEnumUnk);
        
        /* [helpstring][propget] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *get_PropValue )( 
            IChannel __RPC_FAR * This,
            /* [in] */ REFIID riid,
            /* [iid_is][in] */ IPropRoot __RPC_FAR *Member,
            /* [retval][out] */ VARIANT __RPC_FAR *pVal);
        
        /* [helpstring][propput] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *put_PropValue )( 
            IChannel __RPC_FAR * This,
            /* [in] */ REFIID riid,
            /* [iid_is][in] */ IPropRoot __RPC_FAR *Member,
            /* [in] */ VARIANTREF newVal);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *UnitsToBinary )( 
            IChannel __RPC_FAR * This,
            /* [in] */ double UnitsVal,
            /* [out] */ VARIANT __RPC_FAR *pVal);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *BinaryToUnits )( 
            IChannel __RPC_FAR * This,
            /* [in] */ VARIANTREF BinaryVal,
            /* [out] */ double __RPC_FAR *UnitsVal);
        
        END_INTERFACE
    } IChannelVtbl;

    interface IChannel
    {
        CONST_VTBL struct IChannelVtbl __RPC_FAR *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IChannel_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define IChannel_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define IChannel_Release(This)	\
    (This)->lpVtbl -> Release(This)


#define IChannel_get_MemberValue(This,MemberName,pVal)	\
    (This)->lpVtbl -> get_MemberValue(This,MemberName,pVal)

#define IChannel_put_MemberValue(This,MemberName,newVal)	\
    (This)->lpVtbl -> put_MemberValue(This,MemberName,newVal)

#define IChannel_GetMemberInterface(This,MemberName,RequesedIID,Interface)	\
    (This)->lpVtbl -> GetMemberInterface(This,MemberName,RequesedIID,Interface)

#define IChannel_CreateProperty(This,Name,InitialValue,RequesedIID,NewProp)	\
    (This)->lpVtbl -> CreateProperty(This,Name,InitialValue,RequesedIID,NewProp)

#define IChannel_EnumMembers(This,ppIEnumUnk)	\
    (This)->lpVtbl -> EnumMembers(This,ppIEnumUnk)


#define IChannel_get_PropValue(This,riid,Member,pVal)	\
    (This)->lpVtbl -> get_PropValue(This,riid,Member,pVal)

#define IChannel_put_PropValue(This,riid,Member,newVal)	\
    (This)->lpVtbl -> put_PropValue(This,riid,Member,newVal)

#define IChannel_UnitsToBinary(This,UnitsVal,pVal)	\
    (This)->lpVtbl -> UnitsToBinary(This,UnitsVal,pVal)

#define IChannel_BinaryToUnits(This,BinaryVal,UnitsVal)	\
    (This)->lpVtbl -> BinaryToUnits(This,BinaryVal,UnitsVal)

#endif /* COBJMACROS */


#endif 	/* C style interface */



/* [helpstring][propget] */ HRESULT STDMETHODCALLTYPE IChannel_get_PropValue_Proxy( 
    IChannel __RPC_FAR * This,
    /* [in] */ REFIID riid,
    /* [iid_is][in] */ IPropRoot __RPC_FAR *Member,
    /* [retval][out] */ VARIANT __RPC_FAR *pVal);


void __RPC_STUB IChannel_get_PropValue_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][propput] */ HRESULT STDMETHODCALLTYPE IChannel_put_PropValue_Proxy( 
    IChannel __RPC_FAR * This,
    /* [in] */ REFIID riid,
    /* [iid_is][in] */ IPropRoot __RPC_FAR *Member,
    /* [in] */ VARIANTREF newVal);


void __RPC_STUB IChannel_put_PropValue_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE IChannel_UnitsToBinary_Proxy( 
    IChannel __RPC_FAR * This,
    /* [in] */ double UnitsVal,
    /* [out] */ VARIANT __RPC_FAR *pVal);


void __RPC_STUB IChannel_UnitsToBinary_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE IChannel_BinaryToUnits_Proxy( 
    IChannel __RPC_FAR * This,
    /* [in] */ VARIANTREF BinaryVal,
    /* [out] */ double __RPC_FAR *UnitsVal);


void __RPC_STUB IChannel_BinaryToUnits_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);



#endif 	/* __IChannel_INTERFACE_DEFINED__ */


#ifndef __IDaqEngine_INTERFACE_DEFINED__
#define __IDaqEngine_INTERFACE_DEFINED__

/* interface IDaqEngine */
/* [object][unique][helpstring][uuid] */ 


EXTERN_C const IID IID_IDaqEngine;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("8BEEFABF-E54A-11d3-A551-00902757EA8D")
    IDaqEngine : public IUnknown
    {
    public:
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE GetTime( 
            /* [out] */ double __RPC_FAR *Time) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE WarningMessage( 
            /* [in] */ BSTR Message) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE DaqEvent( 
            DWORD event,
            double time,
            hyper sample,
            /* [unique][in] */ BSTR Message) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE GetBufferingConfig( 
            /* [out] */ long __RPC_FAR *BufferSizeSamples,
            /* [out] */ long __RPC_FAR *NumBuffers) = 0;
        
        virtual /* [helpstring][local] */ HRESULT STDMETHODCALLTYPE PutBuffer( 
            /* [unique][in] */ BUFFER_ST __RPC_FAR *Buffer) = 0;
        
        virtual /* [helpstring][local] */ HRESULT STDMETHODCALLTYPE GetBuffer( 
            long Timeout,
            /* [unique][out] */ BUFFER_ST __RPC_FAR *__RPC_FAR *Buffer) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE PutInputData( 
            /* [in] */ long Timeout,
            /* [in] */ BUFFER_ST __RPC_FAR *Buffer) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE GetOutputData( 
            /* [in] */ long Timeout,
            /* [out] */ BUFFER_ST __RPC_FAR *Buffer) = 0;
        
    };
    
#else 	/* C style interface */

    typedef struct IDaqEngineVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *QueryInterface )( 
            IDaqEngine __RPC_FAR * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *ppvObject);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *AddRef )( 
            IDaqEngine __RPC_FAR * This);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *Release )( 
            IDaqEngine __RPC_FAR * This);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetTime )( 
            IDaqEngine __RPC_FAR * This,
            /* [out] */ double __RPC_FAR *Time);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *WarningMessage )( 
            IDaqEngine __RPC_FAR * This,
            /* [in] */ BSTR Message);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *DaqEvent )( 
            IDaqEngine __RPC_FAR * This,
            DWORD event,
            double time,
            hyper sample,
            /* [unique][in] */ BSTR Message);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetBufferingConfig )( 
            IDaqEngine __RPC_FAR * This,
            /* [out] */ long __RPC_FAR *BufferSizeSamples,
            /* [out] */ long __RPC_FAR *NumBuffers);
        
        /* [helpstring][local] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *PutBuffer )( 
            IDaqEngine __RPC_FAR * This,
            /* [unique][in] */ BUFFER_ST __RPC_FAR *Buffer);
        
        /* [helpstring][local] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetBuffer )( 
            IDaqEngine __RPC_FAR * This,
            long Timeout,
            /* [unique][out] */ BUFFER_ST __RPC_FAR *__RPC_FAR *Buffer);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *PutInputData )( 
            IDaqEngine __RPC_FAR * This,
            /* [in] */ long Timeout,
            /* [in] */ BUFFER_ST __RPC_FAR *Buffer);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetOutputData )( 
            IDaqEngine __RPC_FAR * This,
            /* [in] */ long Timeout,
            /* [out] */ BUFFER_ST __RPC_FAR *Buffer);
        
        END_INTERFACE
    } IDaqEngineVtbl;

    interface IDaqEngine
    {
        CONST_VTBL struct IDaqEngineVtbl __RPC_FAR *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IDaqEngine_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define IDaqEngine_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define IDaqEngine_Release(This)	\
    (This)->lpVtbl -> Release(This)


#define IDaqEngine_GetTime(This,Time)	\
    (This)->lpVtbl -> GetTime(This,Time)

#define IDaqEngine_WarningMessage(This,Message)	\
    (This)->lpVtbl -> WarningMessage(This,Message)

#define IDaqEngine_DaqEvent(This,event,time,sample,Message)	\
    (This)->lpVtbl -> DaqEvent(This,event,time,sample,Message)

#define IDaqEngine_GetBufferingConfig(This,BufferSizeSamples,NumBuffers)	\
    (This)->lpVtbl -> GetBufferingConfig(This,BufferSizeSamples,NumBuffers)

#define IDaqEngine_PutBuffer(This,Buffer)	\
    (This)->lpVtbl -> PutBuffer(This,Buffer)

#define IDaqEngine_GetBuffer(This,Timeout,Buffer)	\
    (This)->lpVtbl -> GetBuffer(This,Timeout,Buffer)

#define IDaqEngine_PutInputData(This,Timeout,Buffer)	\
    (This)->lpVtbl -> PutInputData(This,Timeout,Buffer)

#define IDaqEngine_GetOutputData(This,Timeout,Buffer)	\
    (This)->lpVtbl -> GetOutputData(This,Timeout,Buffer)

#endif /* COBJMACROS */


#endif 	/* C style interface */



/* [helpstring] */ HRESULT STDMETHODCALLTYPE IDaqEngine_GetTime_Proxy( 
    IDaqEngine __RPC_FAR * This,
    /* [out] */ double __RPC_FAR *Time);


void __RPC_STUB IDaqEngine_GetTime_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE IDaqEngine_WarningMessage_Proxy( 
    IDaqEngine __RPC_FAR * This,
    /* [in] */ BSTR Message);


void __RPC_STUB IDaqEngine_WarningMessage_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE IDaqEngine_DaqEvent_Proxy( 
    IDaqEngine __RPC_FAR * This,
    DWORD event,
    double time,
    hyper sample,
    /* [unique][in] */ BSTR Message);


void __RPC_STUB IDaqEngine_DaqEvent_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE IDaqEngine_GetBufferingConfig_Proxy( 
    IDaqEngine __RPC_FAR * This,
    /* [out] */ long __RPC_FAR *BufferSizeSamples,
    /* [out] */ long __RPC_FAR *NumBuffers);


void __RPC_STUB IDaqEngine_GetBufferingConfig_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][local] */ HRESULT STDMETHODCALLTYPE IDaqEngine_PutBuffer_Proxy( 
    IDaqEngine __RPC_FAR * This,
    /* [unique][in] */ BUFFER_ST __RPC_FAR *Buffer);


void __RPC_STUB IDaqEngine_PutBuffer_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][local] */ HRESULT STDMETHODCALLTYPE IDaqEngine_GetBuffer_Proxy( 
    IDaqEngine __RPC_FAR * This,
    long Timeout,
    /* [unique][out] */ BUFFER_ST __RPC_FAR *__RPC_FAR *Buffer);


void __RPC_STUB IDaqEngine_GetBuffer_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE IDaqEngine_PutInputData_Proxy( 
    IDaqEngine __RPC_FAR * This,
    /* [in] */ long Timeout,
    /* [in] */ BUFFER_ST __RPC_FAR *Buffer);


void __RPC_STUB IDaqEngine_PutInputData_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE IDaqEngine_GetOutputData_Proxy( 
    IDaqEngine __RPC_FAR * This,
    /* [in] */ long Timeout,
    /* [out] */ BUFFER_ST __RPC_FAR *Buffer);


void __RPC_STUB IDaqEngine_GetOutputData_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);



#endif 	/* __IDaqEngine_INTERFACE_DEFINED__ */


#ifndef __ImwAdaptor_INTERFACE_DEFINED__
#define __ImwAdaptor_INTERFACE_DEFINED__

/* interface ImwAdaptor */
/* [object][unique][helpstring][uuid] */ 


EXTERN_C const IID IID_ImwAdaptor;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("69CA3484-95F5-11d3-A527-00902757EA8D")
    ImwAdaptor : public IUnknown
    {
    public:
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE AdaptorInfo( 
            /* [in] */ IPropContainer __RPC_FAR *Container) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE OpenDevice( 
            /* [in] */ REFIID DevIID,
            /* [in] */ long nParams,
            /* [size_is][in] */ VARIANT __RPC_FAR *Param,
            /* [in] */ REFIID EngineIID,
            /* [iid_is][in] */ IUnknown __RPC_FAR *pEngine,
            /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *ppIDevice) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE TranslateError( 
            HRESULT eCode,
            /* [out] */ BSTR __RPC_FAR *retVal) = 0;
        
    };
    
#else 	/* C style interface */

    typedef struct ImwAdaptorVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *QueryInterface )( 
            ImwAdaptor __RPC_FAR * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *ppvObject);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *AddRef )( 
            ImwAdaptor __RPC_FAR * This);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *Release )( 
            ImwAdaptor __RPC_FAR * This);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *AdaptorInfo )( 
            ImwAdaptor __RPC_FAR * This,
            /* [in] */ IPropContainer __RPC_FAR *Container);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *OpenDevice )( 
            ImwAdaptor __RPC_FAR * This,
            /* [in] */ REFIID DevIID,
            /* [in] */ long nParams,
            /* [size_is][in] */ VARIANT __RPC_FAR *Param,
            /* [in] */ REFIID EngineIID,
            /* [iid_is][in] */ IUnknown __RPC_FAR *pEngine,
            /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *ppIDevice);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *TranslateError )( 
            ImwAdaptor __RPC_FAR * This,
            HRESULT eCode,
            /* [out] */ BSTR __RPC_FAR *retVal);
        
        END_INTERFACE
    } ImwAdaptorVtbl;

    interface ImwAdaptor
    {
        CONST_VTBL struct ImwAdaptorVtbl __RPC_FAR *lpVtbl;
    };

    

#ifdef COBJMACROS


#define ImwAdaptor_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define ImwAdaptor_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define ImwAdaptor_Release(This)	\
    (This)->lpVtbl -> Release(This)


#define ImwAdaptor_AdaptorInfo(This,Container)	\
    (This)->lpVtbl -> AdaptorInfo(This,Container)

#define ImwAdaptor_OpenDevice(This,DevIID,nParams,Param,EngineIID,pEngine,ppIDevice)	\
    (This)->lpVtbl -> OpenDevice(This,DevIID,nParams,Param,EngineIID,pEngine,ppIDevice)

#define ImwAdaptor_TranslateError(This,eCode,retVal)	\
    (This)->lpVtbl -> TranslateError(This,eCode,retVal)

#endif /* COBJMACROS */


#endif 	/* C style interface */



/* [helpstring] */ HRESULT STDMETHODCALLTYPE ImwAdaptor_AdaptorInfo_Proxy( 
    ImwAdaptor __RPC_FAR * This,
    /* [in] */ IPropContainer __RPC_FAR *Container);


void __RPC_STUB ImwAdaptor_AdaptorInfo_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE ImwAdaptor_OpenDevice_Proxy( 
    ImwAdaptor __RPC_FAR * This,
    /* [in] */ REFIID DevIID,
    /* [in] */ long nParams,
    /* [size_is][in] */ VARIANT __RPC_FAR *Param,
    /* [in] */ REFIID EngineIID,
    /* [iid_is][in] */ IUnknown __RPC_FAR *pEngine,
    /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *ppIDevice);


void __RPC_STUB ImwAdaptor_OpenDevice_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE ImwAdaptor_TranslateError_Proxy( 
    ImwAdaptor __RPC_FAR * This,
    HRESULT eCode,
    /* [out] */ BSTR __RPC_FAR *retVal);


void __RPC_STUB ImwAdaptor_TranslateError_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);



#endif 	/* __ImwAdaptor_INTERFACE_DEFINED__ */


#ifndef __ImwDevice_INTERFACE_DEFINED__
#define __ImwDevice_INTERFACE_DEFINED__

/* interface ImwDevice */
/* [object][unique][helpstring][uuid] */ 


EXTERN_C const IID IID_ImwDevice;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("42680178-65FA-11d3-A51B-00902757EA8D")
    ImwDevice : public IUnknown
    {
    public:
        virtual /* [helpstring][local] */ HRESULT STDMETHODCALLTYPE AllocBufferData( 
            /* [out][in] */ BUFFER_ST __RPC_FAR *pBuffer) = 0;
        
        virtual /* [helpstring][local] */ HRESULT STDMETHODCALLTYPE FreeBufferData( 
            /* [out][in] */ BUFFER_ST __RPC_FAR *pBuffer) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE SetChannelProperty( 
            /* [in] */ long user,
            /* [in] */ NESTABLEPROP __RPC_FAR *pChan,
            /* [out][in] */ VARIANT __RPC_FAR *NewValue) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE SetProperty( 
            /* [in] */ long user,
            /* [out][in] */ VARIANT __RPC_FAR *NewValue) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE Start( void) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE Stop( void) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE GetStatus( 
            /* [out] */ hyper __RPC_FAR *samplesProcessed,
            /* [out] */ BOOL __RPC_FAR *running) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE ChildChange( 
            /* [in] */ DWORD typeofchange,
            /* [out][in] */ NESTABLEPROP __RPC_FAR *pChan) = 0;
        
    };
    
#else 	/* C style interface */

    typedef struct ImwDeviceVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *QueryInterface )( 
            ImwDevice __RPC_FAR * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *ppvObject);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *AddRef )( 
            ImwDevice __RPC_FAR * This);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *Release )( 
            ImwDevice __RPC_FAR * This);
        
        /* [helpstring][local] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *AllocBufferData )( 
            ImwDevice __RPC_FAR * This,
            /* [out][in] */ BUFFER_ST __RPC_FAR *pBuffer);
        
        /* [helpstring][local] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *FreeBufferData )( 
            ImwDevice __RPC_FAR * This,
            /* [out][in] */ BUFFER_ST __RPC_FAR *pBuffer);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *SetChannelProperty )( 
            ImwDevice __RPC_FAR * This,
            /* [in] */ long user,
            /* [in] */ NESTABLEPROP __RPC_FAR *pChan,
            /* [out][in] */ VARIANT __RPC_FAR *NewValue);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *SetProperty )( 
            ImwDevice __RPC_FAR * This,
            /* [in] */ long user,
            /* [out][in] */ VARIANT __RPC_FAR *NewValue);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *Start )( 
            ImwDevice __RPC_FAR * This);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *Stop )( 
            ImwDevice __RPC_FAR * This);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetStatus )( 
            ImwDevice __RPC_FAR * This,
            /* [out] */ hyper __RPC_FAR *samplesProcessed,
            /* [out] */ BOOL __RPC_FAR *running);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *ChildChange )( 
            ImwDevice __RPC_FAR * This,
            /* [in] */ DWORD typeofchange,
            /* [out][in] */ NESTABLEPROP __RPC_FAR *pChan);
        
        END_INTERFACE
    } ImwDeviceVtbl;

    interface ImwDevice
    {
        CONST_VTBL struct ImwDeviceVtbl __RPC_FAR *lpVtbl;
    };

    

#ifdef COBJMACROS


#define ImwDevice_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define ImwDevice_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define ImwDevice_Release(This)	\
    (This)->lpVtbl -> Release(This)


#define ImwDevice_AllocBufferData(This,pBuffer)	\
    (This)->lpVtbl -> AllocBufferData(This,pBuffer)

#define ImwDevice_FreeBufferData(This,pBuffer)	\
    (This)->lpVtbl -> FreeBufferData(This,pBuffer)

#define ImwDevice_SetChannelProperty(This,user,pChan,NewValue)	\
    (This)->lpVtbl -> SetChannelProperty(This,user,pChan,NewValue)

#define ImwDevice_SetProperty(This,user,NewValue)	\
    (This)->lpVtbl -> SetProperty(This,user,NewValue)

#define ImwDevice_Start(This)	\
    (This)->lpVtbl -> Start(This)

#define ImwDevice_Stop(This)	\
    (This)->lpVtbl -> Stop(This)

#define ImwDevice_GetStatus(This,samplesProcessed,running)	\
    (This)->lpVtbl -> GetStatus(This,samplesProcessed,running)

#define ImwDevice_ChildChange(This,typeofchange,pChan)	\
    (This)->lpVtbl -> ChildChange(This,typeofchange,pChan)

#endif /* COBJMACROS */


#endif 	/* C style interface */



/* [helpstring][local] */ HRESULT STDMETHODCALLTYPE ImwDevice_AllocBufferData_Proxy( 
    ImwDevice __RPC_FAR * This,
    /* [out][in] */ BUFFER_ST __RPC_FAR *pBuffer);


void __RPC_STUB ImwDevice_AllocBufferData_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][local] */ HRESULT STDMETHODCALLTYPE ImwDevice_FreeBufferData_Proxy( 
    ImwDevice __RPC_FAR * This,
    /* [out][in] */ BUFFER_ST __RPC_FAR *pBuffer);


void __RPC_STUB ImwDevice_FreeBufferData_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE ImwDevice_SetChannelProperty_Proxy( 
    ImwDevice __RPC_FAR * This,
    /* [in] */ long user,
    /* [in] */ NESTABLEPROP __RPC_FAR *pChan,
    /* [out][in] */ VARIANT __RPC_FAR *NewValue);


void __RPC_STUB ImwDevice_SetChannelProperty_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE ImwDevice_SetProperty_Proxy( 
    ImwDevice __RPC_FAR * This,
    /* [in] */ long user,
    /* [out][in] */ VARIANT __RPC_FAR *NewValue);


void __RPC_STUB ImwDevice_SetProperty_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE ImwDevice_Start_Proxy( 
    ImwDevice __RPC_FAR * This);


void __RPC_STUB ImwDevice_Start_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE ImwDevice_Stop_Proxy( 
    ImwDevice __RPC_FAR * This);


void __RPC_STUB ImwDevice_Stop_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE ImwDevice_GetStatus_Proxy( 
    ImwDevice __RPC_FAR * This,
    /* [out] */ hyper __RPC_FAR *samplesProcessed,
    /* [out] */ BOOL __RPC_FAR *running);


void __RPC_STUB ImwDevice_GetStatus_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE ImwDevice_ChildChange_Proxy( 
    ImwDevice __RPC_FAR * This,
    /* [in] */ DWORD typeofchange,
    /* [out][in] */ NESTABLEPROP __RPC_FAR *pChan);


void __RPC_STUB ImwDevice_ChildChange_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);



#endif 	/* __ImwDevice_INTERFACE_DEFINED__ */


#ifndef __ImwInput_INTERFACE_DEFINED__
#define __ImwInput_INTERFACE_DEFINED__

/* interface ImwInput */
/* [object][unique][helpstring][uuid] */ 


EXTERN_C const IID IID_ImwInput;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("42680175-65FA-11d3-A51B-00902757EA8D")
    ImwInput : public IUnknown
    {
    public:
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE GetSingleValues( 
            /* [out] */ VARIANT __RPC_FAR *Values) = 0;
        
        virtual /* [helpstring][local] */ HRESULT STDMETHODCALLTYPE PeekData( 
            /* [out][in] */ BUFFER_ST __RPC_FAR *pBuffer) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE Trigger( void) = 0;
        
    };
    
#else 	/* C style interface */

    typedef struct ImwInputVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *QueryInterface )( 
            ImwInput __RPC_FAR * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *ppvObject);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *AddRef )( 
            ImwInput __RPC_FAR * This);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *Release )( 
            ImwInput __RPC_FAR * This);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *GetSingleValues )( 
            ImwInput __RPC_FAR * This,
            /* [out] */ VARIANT __RPC_FAR *Values);
        
        /* [helpstring][local] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *PeekData )( 
            ImwInput __RPC_FAR * This,
            /* [out][in] */ BUFFER_ST __RPC_FAR *pBuffer);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *Trigger )( 
            ImwInput __RPC_FAR * This);
        
        END_INTERFACE
    } ImwInputVtbl;

    interface ImwInput
    {
        CONST_VTBL struct ImwInputVtbl __RPC_FAR *lpVtbl;
    };

    

#ifdef COBJMACROS


#define ImwInput_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define ImwInput_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define ImwInput_Release(This)	\
    (This)->lpVtbl -> Release(This)


#define ImwInput_GetSingleValues(This,Values)	\
    (This)->lpVtbl -> GetSingleValues(This,Values)

#define ImwInput_PeekData(This,pBuffer)	\
    (This)->lpVtbl -> PeekData(This,pBuffer)

#define ImwInput_Trigger(This)	\
    (This)->lpVtbl -> Trigger(This)

#endif /* COBJMACROS */


#endif 	/* C style interface */



/* [helpstring] */ HRESULT STDMETHODCALLTYPE ImwInput_GetSingleValues_Proxy( 
    ImwInput __RPC_FAR * This,
    /* [out] */ VARIANT __RPC_FAR *Values);


void __RPC_STUB ImwInput_GetSingleValues_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][local] */ HRESULT STDMETHODCALLTYPE ImwInput_PeekData_Proxy( 
    ImwInput __RPC_FAR * This,
    /* [out][in] */ BUFFER_ST __RPC_FAR *pBuffer);


void __RPC_STUB ImwInput_PeekData_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE ImwInput_Trigger_Proxy( 
    ImwInput __RPC_FAR * This);


void __RPC_STUB ImwInput_Trigger_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);



#endif 	/* __ImwInput_INTERFACE_DEFINED__ */


#ifndef __ImwOutput_INTERFACE_DEFINED__
#define __ImwOutput_INTERFACE_DEFINED__

/* interface ImwOutput */
/* [object][unique][helpstring][uuid] */ 


EXTERN_C const IID IID_ImwOutput;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("42680176-65FA-11d3-A51B-00902757EA8D")
    ImwOutput : public IUnknown
    {
    public:
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE PutSingleValues( 
            /* [in] */ VARIANT __RPC_FAR *Values) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE Trigger( void) = 0;
        
    };
    
#else 	/* C style interface */

    typedef struct ImwOutputVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *QueryInterface )( 
            ImwOutput __RPC_FAR * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *ppvObject);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *AddRef )( 
            ImwOutput __RPC_FAR * This);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *Release )( 
            ImwOutput __RPC_FAR * This);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *PutSingleValues )( 
            ImwOutput __RPC_FAR * This,
            /* [in] */ VARIANT __RPC_FAR *Values);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *Trigger )( 
            ImwOutput __RPC_FAR * This);
        
        END_INTERFACE
    } ImwOutputVtbl;

    interface ImwOutput
    {
        CONST_VTBL struct ImwOutputVtbl __RPC_FAR *lpVtbl;
    };

    

#ifdef COBJMACROS


#define ImwOutput_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define ImwOutput_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define ImwOutput_Release(This)	\
    (This)->lpVtbl -> Release(This)


#define ImwOutput_PutSingleValues(This,Values)	\
    (This)->lpVtbl -> PutSingleValues(This,Values)

#define ImwOutput_Trigger(This)	\
    (This)->lpVtbl -> Trigger(This)

#endif /* COBJMACROS */


#endif 	/* C style interface */



/* [helpstring] */ HRESULT STDMETHODCALLTYPE ImwOutput_PutSingleValues_Proxy( 
    ImwOutput __RPC_FAR * This,
    /* [in] */ VARIANT __RPC_FAR *Values);


void __RPC_STUB ImwOutput_PutSingleValues_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE ImwOutput_Trigger_Proxy( 
    ImwOutput __RPC_FAR * This);


void __RPC_STUB ImwOutput_Trigger_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);



#endif 	/* __ImwOutput_INTERFACE_DEFINED__ */


#ifndef __ImwDIO_INTERFACE_DEFINED__
#define __ImwDIO_INTERFACE_DEFINED__

/* interface ImwDIO */
/* [object][unique][helpstring][uuid] */ 


EXTERN_C const IID IID_ImwDIO;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("42680177-65FA-11d3-A51B-00902757EA8D")
    ImwDIO : public IUnknown
    {
    public:
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE ReadValues( 
            /* [in] */ long NumberOfPorts,
            /* [size_is][in] */ long __RPC_FAR *PortList,
            /* [size_is][out] */ unsigned long __RPC_FAR *Data) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE WriteValues( 
            /* [in] */ long NumberOfPorts,
            /* [size_is][in] */ long __RPC_FAR *PortList,
            /* [size_is][in] */ unsigned long __RPC_FAR *Data,
            /* [size_is][in] */ unsigned long __RPC_FAR *Mask) = 0;
        
        virtual /* [helpstring] */ HRESULT STDMETHODCALLTYPE SetPortDirection( 
            /* [in] */ long Port,
            /* [in] */ unsigned long DirectionValues) = 0;
        
    };
    
#else 	/* C style interface */

    typedef struct ImwDIOVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE __RPC_FAR *QueryInterface )( 
            ImwDIO __RPC_FAR * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void __RPC_FAR *__RPC_FAR *ppvObject);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *AddRef )( 
            ImwDIO __RPC_FAR * This);
        
        ULONG ( STDMETHODCALLTYPE __RPC_FAR *Release )( 
            ImwDIO __RPC_FAR * This);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *ReadValues )( 
            ImwDIO __RPC_FAR * This,
            /* [in] */ long NumberOfPorts,
            /* [size_is][in] */ long __RPC_FAR *PortList,
            /* [size_is][out] */ unsigned long __RPC_FAR *Data);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *WriteValues )( 
            ImwDIO __RPC_FAR * This,
            /* [in] */ long NumberOfPorts,
            /* [size_is][in] */ long __RPC_FAR *PortList,
            /* [size_is][in] */ unsigned long __RPC_FAR *Data,
            /* [size_is][in] */ unsigned long __RPC_FAR *Mask);
        
        /* [helpstring] */ HRESULT ( STDMETHODCALLTYPE __RPC_FAR *SetPortDirection )( 
            ImwDIO __RPC_FAR * This,
            /* [in] */ long Port,
            /* [in] */ unsigned long DirectionValues);
        
        END_INTERFACE
    } ImwDIOVtbl;

    interface ImwDIO
    {
        CONST_VTBL struct ImwDIOVtbl __RPC_FAR *lpVtbl;
    };

    

#ifdef COBJMACROS


#define ImwDIO_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define ImwDIO_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define ImwDIO_Release(This)	\
    (This)->lpVtbl -> Release(This)


#define ImwDIO_ReadValues(This,NumberOfPorts,PortList,Data)	\
    (This)->lpVtbl -> ReadValues(This,NumberOfPorts,PortList,Data)

#define ImwDIO_WriteValues(This,NumberOfPorts,PortList,Data,Mask)	\
    (This)->lpVtbl -> WriteValues(This,NumberOfPorts,PortList,Data,Mask)

#define ImwDIO_SetPortDirection(This,Port,DirectionValues)	\
    (This)->lpVtbl -> SetPortDirection(This,Port,DirectionValues)

#endif /* COBJMACROS */


#endif 	/* C style interface */



/* [helpstring] */ HRESULT STDMETHODCALLTYPE ImwDIO_ReadValues_Proxy( 
    ImwDIO __RPC_FAR * This,
    /* [in] */ long NumberOfPorts,
    /* [size_is][in] */ long __RPC_FAR *PortList,
    /* [size_is][out] */ unsigned long __RPC_FAR *Data);


void __RPC_STUB ImwDIO_ReadValues_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE ImwDIO_WriteValues_Proxy( 
    ImwDIO __RPC_FAR * This,
    /* [in] */ long NumberOfPorts,
    /* [size_is][in] */ long __RPC_FAR *PortList,
    /* [size_is][in] */ unsigned long __RPC_FAR *Data,
    /* [size_is][in] */ unsigned long __RPC_FAR *Mask);


void __RPC_STUB ImwDIO_WriteValues_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring] */ HRESULT STDMETHODCALLTYPE ImwDIO_SetPortDirection_Proxy( 
    ImwDIO __RPC_FAR * This,
    /* [in] */ long Port,
    /* [in] */ unsigned long DirectionValues);


void __RPC_STUB ImwDIO_SetPortDirection_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);



#endif 	/* __ImwDIO_INTERFACE_DEFINED__ */



#ifndef __DAQMEXLib_LIBRARY_DEFINED__
#define __DAQMEXLib_LIBRARY_DEFINED__

/* library DAQMEXLib */
/* [helpstring][version][uuid] */ 







EXTERN_C const IID LIBID_DAQMEXLib;

EXTERN_C const CLSID CLSID_Prop;

#ifdef __cplusplus

class DECLSPEC_UUID("0BFA2914-D48E-11D1-90BE-00600841F9FF")
Prop;
#endif

EXTERN_C const CLSID CLSID_DaqEngine;

#ifdef __cplusplus

class DECLSPEC_UUID("E79D1B43-DF5F-11D1-90C1-00600841F9FF")
DaqEngine;
#endif

EXTERN_C const CLSID CLSID_PropContainer;

#ifdef __cplusplus

class DECLSPEC_UUID("E79D1B46-DF5F-11D1-90C1-00600841F9FF")
PropContainer;
#endif

EXTERN_C const CLSID CLSID_DaqMappedEnum;

#ifdef __cplusplus

class DECLSPEC_UUID("61D9F511-B6E9-11D3-A538-00902757EA8D")
DaqMappedEnum;
#endif
#endif /* __DAQMEXLib_LIBRARY_DEFINED__ */

/* Additional Prototypes for ALL interfaces */

unsigned long             __RPC_USER  BSTR_UserSize(     unsigned long __RPC_FAR *, unsigned long            , BSTR __RPC_FAR * ); 
unsigned char __RPC_FAR * __RPC_USER  BSTR_UserMarshal(  unsigned long __RPC_FAR *, unsigned char __RPC_FAR *, BSTR __RPC_FAR * ); 
unsigned char __RPC_FAR * __RPC_USER  BSTR_UserUnmarshal(unsigned long __RPC_FAR *, unsigned char __RPC_FAR *, BSTR __RPC_FAR * ); 
void                      __RPC_USER  BSTR_UserFree(     unsigned long __RPC_FAR *, BSTR __RPC_FAR * ); 

unsigned long             __RPC_USER  VARIANT_UserSize(     unsigned long __RPC_FAR *, unsigned long            , VARIANT __RPC_FAR * ); 
unsigned char __RPC_FAR * __RPC_USER  VARIANT_UserMarshal(  unsigned long __RPC_FAR *, unsigned char __RPC_FAR *, VARIANT __RPC_FAR * ); 
unsigned char __RPC_FAR * __RPC_USER  VARIANT_UserUnmarshal(unsigned long __RPC_FAR *, unsigned char __RPC_FAR *, VARIANT __RPC_FAR * ); 
void                      __RPC_USER  VARIANT_UserFree(     unsigned long __RPC_FAR *, VARIANT __RPC_FAR * ); 

/* end of Additional Prototypes */

#ifdef __cplusplus
}
#endif

#endif
