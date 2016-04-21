

/* this ALWAYS GENERATED file contains the definitions for the interfaces */


 /* File created by MIDL compiler version 6.00.0361 */
/* at Wed Mar 24 02:16:46 2004
 */
/* Compiler settings for .\mwkeithley.idl:
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

#ifndef __mwkeithley_h__
#define __mwkeithley_h__

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

/* Forward Declarations */ 

#ifndef __IKeithleyAIn_FWD_DEFINED__
#define __IKeithleyAIn_FWD_DEFINED__
typedef interface IKeithleyAIn IKeithleyAIn;
#endif 	/* __IKeithleyAIn_FWD_DEFINED__ */


#ifndef __IKeithleyAOut_FWD_DEFINED__
#define __IKeithleyAOut_FWD_DEFINED__
typedef interface IKeithleyAOut IKeithleyAOut;
#endif 	/* __IKeithleyAOut_FWD_DEFINED__ */


#ifndef __IKeithleyDIO_FWD_DEFINED__
#define __IKeithleyDIO_FWD_DEFINED__
typedef interface IKeithleyDIO IKeithleyDIO;
#endif 	/* __IKeithleyDIO_FWD_DEFINED__ */


#ifndef __keithleyadapt_FWD_DEFINED__
#define __keithleyadapt_FWD_DEFINED__

#ifdef __cplusplus
typedef class keithleyadapt keithleyadapt;
#else
typedef struct keithleyadapt keithleyadapt;
#endif /* __cplusplus */

#endif 	/* __keithleyadapt_FWD_DEFINED__ */


#ifndef __keithleyain_FWD_DEFINED__
#define __keithleyain_FWD_DEFINED__

#ifdef __cplusplus
typedef class keithleyain keithleyain;
#else
typedef struct keithleyain keithleyain;
#endif /* __cplusplus */

#endif 	/* __keithleyain_FWD_DEFINED__ */


#ifndef __keithleyaout_FWD_DEFINED__
#define __keithleyaout_FWD_DEFINED__

#ifdef __cplusplus
typedef class keithleyaout keithleyaout;
#else
typedef struct keithleyaout keithleyaout;
#endif /* __cplusplus */

#endif 	/* __keithleyaout_FWD_DEFINED__ */


#ifndef __keithleydio_FWD_DEFINED__
#define __keithleydio_FWD_DEFINED__

#ifdef __cplusplus
typedef class keithleydio keithleydio;
#else
typedef struct keithleydio keithleydio;
#endif /* __cplusplus */

#endif 	/* __keithleydio_FWD_DEFINED__ */


/* header files for imported files */
#include "oaidl.h"
#include "ocidl.h"
#include "daqmex.h"

#ifdef __cplusplus
extern "C"{
#endif 

void * __RPC_USER MIDL_user_allocate(size_t);
void __RPC_USER MIDL_user_free( void * ); 

#ifndef __IKeithleyAIn_INTERFACE_DEFINED__
#define __IKeithleyAIn_INTERFACE_DEFINED__

/* interface IKeithleyAIn */
/* [unique][helpstring][dual][uuid][object] */ 


EXTERN_C const IID IID_IKeithleyAIn;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("881AF6CD-75CD-4eee-9359-2B131270E5BB")
    IKeithleyAIn : public IDispatch
    {
    public:
    };
    
#else 	/* C style interface */

    typedef struct IKeithleyAInVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            IKeithleyAIn * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void **ppvObject);
        
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            IKeithleyAIn * This);
        
        ULONG ( STDMETHODCALLTYPE *Release )( 
            IKeithleyAIn * This);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfoCount )( 
            IKeithleyAIn * This,
            /* [out] */ UINT *pctinfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfo )( 
            IKeithleyAIn * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo **ppTInfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetIDsOfNames )( 
            IKeithleyAIn * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR *rgszNames,
            /* [in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID *rgDispId);
        
        /* [local] */ HRESULT ( STDMETHODCALLTYPE *Invoke )( 
            IKeithleyAIn * This,
            /* [in] */ DISPID dispIdMember,
            /* [in] */ REFIID riid,
            /* [in] */ LCID lcid,
            /* [in] */ WORD wFlags,
            /* [out][in] */ DISPPARAMS *pDispParams,
            /* [out] */ VARIANT *pVarResult,
            /* [out] */ EXCEPINFO *pExcepInfo,
            /* [out] */ UINT *puArgErr);
        
        END_INTERFACE
    } IKeithleyAInVtbl;

    interface IKeithleyAIn
    {
        CONST_VTBL struct IKeithleyAInVtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IKeithleyAIn_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define IKeithleyAIn_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define IKeithleyAIn_Release(This)	\
    (This)->lpVtbl -> Release(This)


#define IKeithleyAIn_GetTypeInfoCount(This,pctinfo)	\
    (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo)

#define IKeithleyAIn_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo)

#define IKeithleyAIn_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)

#define IKeithleyAIn_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)


#endif /* COBJMACROS */


#endif 	/* C style interface */




#endif 	/* __IKeithleyAIn_INTERFACE_DEFINED__ */


#ifndef __IKeithleyAOut_INTERFACE_DEFINED__
#define __IKeithleyAOut_INTERFACE_DEFINED__

/* interface IKeithleyAOut */
/* [unique][helpstring][dual][uuid][object] */ 


EXTERN_C const IID IID_IKeithleyAOut;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("77F4DFDF-3E26-47de-8321-D44224F05A26")
    IKeithleyAOut : public IDispatch
    {
    public:
    };
    
#else 	/* C style interface */

    typedef struct IKeithleyAOutVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            IKeithleyAOut * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void **ppvObject);
        
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            IKeithleyAOut * This);
        
        ULONG ( STDMETHODCALLTYPE *Release )( 
            IKeithleyAOut * This);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfoCount )( 
            IKeithleyAOut * This,
            /* [out] */ UINT *pctinfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfo )( 
            IKeithleyAOut * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo **ppTInfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetIDsOfNames )( 
            IKeithleyAOut * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR *rgszNames,
            /* [in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID *rgDispId);
        
        /* [local] */ HRESULT ( STDMETHODCALLTYPE *Invoke )( 
            IKeithleyAOut * This,
            /* [in] */ DISPID dispIdMember,
            /* [in] */ REFIID riid,
            /* [in] */ LCID lcid,
            /* [in] */ WORD wFlags,
            /* [out][in] */ DISPPARAMS *pDispParams,
            /* [out] */ VARIANT *pVarResult,
            /* [out] */ EXCEPINFO *pExcepInfo,
            /* [out] */ UINT *puArgErr);
        
        END_INTERFACE
    } IKeithleyAOutVtbl;

    interface IKeithleyAOut
    {
        CONST_VTBL struct IKeithleyAOutVtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IKeithleyAOut_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define IKeithleyAOut_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define IKeithleyAOut_Release(This)	\
    (This)->lpVtbl -> Release(This)


#define IKeithleyAOut_GetTypeInfoCount(This,pctinfo)	\
    (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo)

#define IKeithleyAOut_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo)

#define IKeithleyAOut_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)

#define IKeithleyAOut_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)


#endif /* COBJMACROS */


#endif 	/* C style interface */




#endif 	/* __IKeithleyAOut_INTERFACE_DEFINED__ */


#ifndef __IKeithleyDIO_INTERFACE_DEFINED__
#define __IKeithleyDIO_INTERFACE_DEFINED__

/* interface IKeithleyDIO */
/* [unique][helpstring][uuid][object] */ 


EXTERN_C const IID IID_IKeithleyDIO;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("42C73F21-2251-4106-A198-D8FA99E8D8DB")
    IKeithleyDIO : public IUnknown
    {
    public:
    };
    
#else 	/* C style interface */

    typedef struct IKeithleyDIOVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            IKeithleyDIO * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void **ppvObject);
        
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            IKeithleyDIO * This);
        
        ULONG ( STDMETHODCALLTYPE *Release )( 
            IKeithleyDIO * This);
        
        END_INTERFACE
    } IKeithleyDIOVtbl;

    interface IKeithleyDIO
    {
        CONST_VTBL struct IKeithleyDIOVtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IKeithleyDIO_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define IKeithleyDIO_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define IKeithleyDIO_Release(This)	\
    (This)->lpVtbl -> Release(This)


#endif /* COBJMACROS */


#endif 	/* C style interface */




#endif 	/* __IKeithleyDIO_INTERFACE_DEFINED__ */



#ifndef __KEITHLEYLib_LIBRARY_DEFINED__
#define __KEITHLEYLib_LIBRARY_DEFINED__

/* library KEITHLEYLib */
/* [helpstring][version][uuid] */ 


EXTERN_C const IID LIBID_KEITHLEYLib;

EXTERN_C const CLSID CLSID_keithleyadapt;

#ifdef __cplusplus

class DECLSPEC_UUID("719A7527-2758-473f-A530-583E823C40B7")
keithleyadapt;
#endif

EXTERN_C const CLSID CLSID_keithleyain;

#ifdef __cplusplus

class DECLSPEC_UUID("DF084B52-04D6-4e6e-B448-CE2D511BDC24")
keithleyain;
#endif

EXTERN_C const CLSID CLSID_keithleyaout;

#ifdef __cplusplus

class DECLSPEC_UUID("64604F25-F644-43bf-8DCC-968788EDF01B")
keithleyaout;
#endif

EXTERN_C const CLSID CLSID_keithleydio;

#ifdef __cplusplus

class DECLSPEC_UUID("E674596A-2840-429d-9AC6-664A1E781CD3")
keithleydio;
#endif
#endif /* __KEITHLEYLib_LIBRARY_DEFINED__ */

/* Additional Prototypes for ALL interfaces */

/* end of Additional Prototypes */

#ifdef __cplusplus
}
#endif

#endif


