

/* this ALWAYS GENERATED file contains the definitions for the interfaces */


 /* File created by MIDL compiler version 6.00.0361 */
/* at Wed Mar 24 02:15:52 2004
 */
/* Compiler settings for .\Mwnidaq.idl:
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

#ifndef __mwnidaq_h__
#define __mwnidaq_h__

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

/* Forward Declarations */ 

#ifndef __IniDisp_FWD_DEFINED__
#define __IniDisp_FWD_DEFINED__
typedef interface IniDisp IniDisp;
#endif 	/* __IniDisp_FWD_DEFINED__ */


#ifndef __CniAdaptor_FWD_DEFINED__
#define __CniAdaptor_FWD_DEFINED__

#ifdef __cplusplus
typedef class CniAdaptor CniAdaptor;
#else
typedef struct CniAdaptor CniAdaptor;
#endif /* __cplusplus */

#endif 	/* __CniAdaptor_FWD_DEFINED__ */


#ifndef __Cnia2d_FWD_DEFINED__
#define __Cnia2d_FWD_DEFINED__

#ifdef __cplusplus
typedef class Cnia2d Cnia2d;
#else
typedef struct Cnia2d Cnia2d;
#endif /* __cplusplus */

#endif 	/* __Cnia2d_FWD_DEFINED__ */


#ifndef __Cnid2a_FWD_DEFINED__
#define __Cnid2a_FWD_DEFINED__

#ifdef __cplusplus
typedef class Cnid2a Cnid2a;
#else
typedef struct Cnid2a Cnid2a;
#endif /* __cplusplus */

#endif 	/* __Cnid2a_FWD_DEFINED__ */


#ifndef __niDIO_FWD_DEFINED__
#define __niDIO_FWD_DEFINED__

#ifdef __cplusplus
typedef class niDIO niDIO;
#else
typedef struct niDIO niDIO;
#endif /* __cplusplus */

#endif 	/* __niDIO_FWD_DEFINED__ */


#ifndef __niDisp_FWD_DEFINED__
#define __niDisp_FWD_DEFINED__

#ifdef __cplusplus
typedef class niDisp niDisp;
#else
typedef struct niDisp niDisp;
#endif /* __cplusplus */

#endif 	/* __niDisp_FWD_DEFINED__ */


/* header files for imported files */
#include "oaidl.h"
#include "ocidl.h"
#include "daqmex.h"

#ifdef __cplusplus
extern "C"{
#endif 

void * __RPC_USER MIDL_user_allocate(size_t);
void __RPC_USER MIDL_user_free( void * ); 

#ifndef __IniDisp_INTERFACE_DEFINED__
#define __IniDisp_INTERFACE_DEFINED__

/* interface IniDisp */
/* [unique][helpstring][dual][uuid][object] */ 


EXTERN_C const IID IID_IniDisp;

#if defined(__cplusplus) && !defined(CINTERFACE)
    
    MIDL_INTERFACE("D96CE0F1-066A-11D4-A55A-00902757EA8D")
    IniDisp : public IDispatch
    {
    public:
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE Select_Signal( 
            unsigned long signal,
            unsigned long source,
            unsigned long sourceSpec) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE Calibrate_1200( 
            short calOP,
            short saveNewCal,
            short EEPROMloc,
            short calRevChan,
            short gndRefChan,
            short DAC0chan,
            short DAC1chan,
            double calRefVolts,
            double gain) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE Calibrate_DSA( 
            unsigned long operation,
            double refVoltage) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE Calibrate_E_Series( 
            unsigned long calOP,
            unsigned long setOfCalConst,
            double calRefVolts) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE AO_Calibrate( 
            short operation,
            short EEPROMloc) = 0;
        
        virtual /* [helpstring][id] */ HRESULT STDMETHODCALLTYPE AI_Change_Parameter( 
            short channel,
            unsigned long paramID,
            unsigned long paramValue) = 0;
        
    };
    
#else 	/* C style interface */

    typedef struct IniDispVtbl
    {
        BEGIN_INTERFACE
        
        HRESULT ( STDMETHODCALLTYPE *QueryInterface )( 
            IniDisp * This,
            /* [in] */ REFIID riid,
            /* [iid_is][out] */ void **ppvObject);
        
        ULONG ( STDMETHODCALLTYPE *AddRef )( 
            IniDisp * This);
        
        ULONG ( STDMETHODCALLTYPE *Release )( 
            IniDisp * This);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfoCount )( 
            IniDisp * This,
            /* [out] */ UINT *pctinfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetTypeInfo )( 
            IniDisp * This,
            /* [in] */ UINT iTInfo,
            /* [in] */ LCID lcid,
            /* [out] */ ITypeInfo **ppTInfo);
        
        HRESULT ( STDMETHODCALLTYPE *GetIDsOfNames )( 
            IniDisp * This,
            /* [in] */ REFIID riid,
            /* [size_is][in] */ LPOLESTR *rgszNames,
            /* [in] */ UINT cNames,
            /* [in] */ LCID lcid,
            /* [size_is][out] */ DISPID *rgDispId);
        
        /* [local] */ HRESULT ( STDMETHODCALLTYPE *Invoke )( 
            IniDisp * This,
            /* [in] */ DISPID dispIdMember,
            /* [in] */ REFIID riid,
            /* [in] */ LCID lcid,
            /* [in] */ WORD wFlags,
            /* [out][in] */ DISPPARAMS *pDispParams,
            /* [out] */ VARIANT *pVarResult,
            /* [out] */ EXCEPINFO *pExcepInfo,
            /* [out] */ UINT *puArgErr);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Select_Signal )( 
            IniDisp * This,
            unsigned long signal,
            unsigned long source,
            unsigned long sourceSpec);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Calibrate_1200 )( 
            IniDisp * This,
            short calOP,
            short saveNewCal,
            short EEPROMloc,
            short calRevChan,
            short gndRefChan,
            short DAC0chan,
            short DAC1chan,
            double calRefVolts,
            double gain);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Calibrate_DSA )( 
            IniDisp * This,
            unsigned long operation,
            double refVoltage);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *Calibrate_E_Series )( 
            IniDisp * This,
            unsigned long calOP,
            unsigned long setOfCalConst,
            double calRefVolts);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *AO_Calibrate )( 
            IniDisp * This,
            short operation,
            short EEPROMloc);
        
        /* [helpstring][id] */ HRESULT ( STDMETHODCALLTYPE *AI_Change_Parameter )( 
            IniDisp * This,
            short channel,
            unsigned long paramID,
            unsigned long paramValue);
        
        END_INTERFACE
    } IniDispVtbl;

    interface IniDisp
    {
        CONST_VTBL struct IniDispVtbl *lpVtbl;
    };

    

#ifdef COBJMACROS


#define IniDisp_QueryInterface(This,riid,ppvObject)	\
    (This)->lpVtbl -> QueryInterface(This,riid,ppvObject)

#define IniDisp_AddRef(This)	\
    (This)->lpVtbl -> AddRef(This)

#define IniDisp_Release(This)	\
    (This)->lpVtbl -> Release(This)


#define IniDisp_GetTypeInfoCount(This,pctinfo)	\
    (This)->lpVtbl -> GetTypeInfoCount(This,pctinfo)

#define IniDisp_GetTypeInfo(This,iTInfo,lcid,ppTInfo)	\
    (This)->lpVtbl -> GetTypeInfo(This,iTInfo,lcid,ppTInfo)

#define IniDisp_GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)	\
    (This)->lpVtbl -> GetIDsOfNames(This,riid,rgszNames,cNames,lcid,rgDispId)

#define IniDisp_Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)	\
    (This)->lpVtbl -> Invoke(This,dispIdMember,riid,lcid,wFlags,pDispParams,pVarResult,pExcepInfo,puArgErr)


#define IniDisp_Select_Signal(This,signal,source,sourceSpec)	\
    (This)->lpVtbl -> Select_Signal(This,signal,source,sourceSpec)

#define IniDisp_Calibrate_1200(This,calOP,saveNewCal,EEPROMloc,calRevChan,gndRefChan,DAC0chan,DAC1chan,calRefVolts,gain)	\
    (This)->lpVtbl -> Calibrate_1200(This,calOP,saveNewCal,EEPROMloc,calRevChan,gndRefChan,DAC0chan,DAC1chan,calRefVolts,gain)

#define IniDisp_Calibrate_DSA(This,operation,refVoltage)	\
    (This)->lpVtbl -> Calibrate_DSA(This,operation,refVoltage)

#define IniDisp_Calibrate_E_Series(This,calOP,setOfCalConst,calRefVolts)	\
    (This)->lpVtbl -> Calibrate_E_Series(This,calOP,setOfCalConst,calRefVolts)

#define IniDisp_AO_Calibrate(This,operation,EEPROMloc)	\
    (This)->lpVtbl -> AO_Calibrate(This,operation,EEPROMloc)

#define IniDisp_AI_Change_Parameter(This,channel,paramID,paramValue)	\
    (This)->lpVtbl -> AI_Change_Parameter(This,channel,paramID,paramValue)

#endif /* COBJMACROS */


#endif 	/* C style interface */



/* [helpstring][id] */ HRESULT STDMETHODCALLTYPE IniDisp_Select_Signal_Proxy( 
    IniDisp * This,
    unsigned long signal,
    unsigned long source,
    unsigned long sourceSpec);


void __RPC_STUB IniDisp_Select_Signal_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id] */ HRESULT STDMETHODCALLTYPE IniDisp_Calibrate_1200_Proxy( 
    IniDisp * This,
    short calOP,
    short saveNewCal,
    short EEPROMloc,
    short calRevChan,
    short gndRefChan,
    short DAC0chan,
    short DAC1chan,
    double calRefVolts,
    double gain);


void __RPC_STUB IniDisp_Calibrate_1200_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id] */ HRESULT STDMETHODCALLTYPE IniDisp_Calibrate_DSA_Proxy( 
    IniDisp * This,
    unsigned long operation,
    double refVoltage);


void __RPC_STUB IniDisp_Calibrate_DSA_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id] */ HRESULT STDMETHODCALLTYPE IniDisp_Calibrate_E_Series_Proxy( 
    IniDisp * This,
    unsigned long calOP,
    unsigned long setOfCalConst,
    double calRefVolts);


void __RPC_STUB IniDisp_Calibrate_E_Series_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id] */ HRESULT STDMETHODCALLTYPE IniDisp_AO_Calibrate_Proxy( 
    IniDisp * This,
    short operation,
    short EEPROMloc);


void __RPC_STUB IniDisp_AO_Calibrate_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);


/* [helpstring][id] */ HRESULT STDMETHODCALLTYPE IniDisp_AI_Change_Parameter_Proxy( 
    IniDisp * This,
    short channel,
    unsigned long paramID,
    unsigned long paramValue);


void __RPC_STUB IniDisp_AI_Change_Parameter_Stub(
    IRpcStubBuffer *This,
    IRpcChannelBuffer *_pRpcChannelBuffer,
    PRPC_MESSAGE _pRpcMessage,
    DWORD *_pdwStubPhase);



#endif 	/* __IniDisp_INTERFACE_DEFINED__ */



#ifndef __MWNIDAQLib_LIBRARY_DEFINED__
#define __MWNIDAQLib_LIBRARY_DEFINED__

/* library MWNIDAQLib */
/* [helpstring][version][uuid] */ 


EXTERN_C const IID LIBID_MWNIDAQLib;

EXTERN_C const CLSID CLSID_CniAdaptor;

#ifdef __cplusplus

class DECLSPEC_UUID("8BEEFAC3-E54A-11d3-A551-00902757EA8D")
CniAdaptor;
#endif

EXTERN_C const CLSID CLSID_Cnia2d;

#ifdef __cplusplus

class DECLSPEC_UUID("F4A40AF4-BC90-11d3-A53C-00902757EA8D")
Cnia2d;
#endif

EXTERN_C const CLSID CLSID_Cnid2a;

#ifdef __cplusplus

class DECLSPEC_UUID("F4A40AF5-BC90-11d3-A53C-00902757EA8D")
Cnid2a;
#endif

EXTERN_C const CLSID CLSID_niDIO;

#ifdef __cplusplus

class DECLSPEC_UUID("F4A40AF6-BC90-11d3-A53C-00902757EA8D")
niDIO;
#endif

EXTERN_C const CLSID CLSID_niDisp;

#ifdef __cplusplus

class DECLSPEC_UUID("D96CE0F2-066A-11D4-A55A-00902757EA8D")
niDisp;
#endif
#endif /* __MWNIDAQLib_LIBRARY_DEFINED__ */

/* Additional Prototypes for ALL interfaces */

/* end of Additional Prototypes */

#ifdef __cplusplus
}
#endif

#endif


