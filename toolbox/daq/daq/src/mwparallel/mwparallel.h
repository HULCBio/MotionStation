

/* this ALWAYS GENERATED file contains the definitions for the interfaces */


 /* File created by MIDL compiler version 6.00.0361 */
/* at Wed Mar 24 02:17:53 2004
 */
/* Compiler settings for .\mwparallel.idl:
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


#ifndef __mwparallel_h__
#define __mwparallel_h__

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

/* Forward Declarations */ 

#ifndef __ParallelAdapt_FWD_DEFINED__
#define __ParallelAdapt_FWD_DEFINED__

#ifdef __cplusplus
typedef class ParallelAdapt ParallelAdapt;
#else
typedef struct ParallelAdapt ParallelAdapt;
#endif /* __cplusplus */

#endif 	/* __ParallelAdapt_FWD_DEFINED__ */


#ifndef __ParallelDio_FWD_DEFINED__
#define __ParallelDio_FWD_DEFINED__

#ifdef __cplusplus
typedef class ParallelDio ParallelDio;
#else
typedef struct ParallelDio ParallelDio;
#endif /* __cplusplus */

#endif 	/* __ParallelDio_FWD_DEFINED__ */


/* header files for imported files */
#include "daqmex.h"

#ifdef __cplusplus
extern "C"{
#endif 

void * __RPC_USER MIDL_user_allocate(size_t);
void __RPC_USER MIDL_user_free( void * ); 


#ifndef __PARALLELADAPTORLib_LIBRARY_DEFINED__
#define __PARALLELADAPTORLib_LIBRARY_DEFINED__

/* library PARALLELADAPTORLib */
/* [helpstring][version][uuid] */ 


EXTERN_C const IID LIBID_PARALLELADAPTORLib;

EXTERN_C const CLSID CLSID_ParallelAdapt;

#ifdef __cplusplus

class DECLSPEC_UUID("890C55F6-1DEF-4719-B1A6-5C3726DC054F")
ParallelAdapt;
#endif

EXTERN_C const CLSID CLSID_ParallelDio;

#ifdef __cplusplus

class DECLSPEC_UUID("42B1047E-5A2D-4BB1-9646-361C6A53D9F1")
ParallelDio;
#endif
#endif /* __PARALLELADAPTORLib_LIBRARY_DEFINED__ */

/* Additional Prototypes for ALL interfaces */

/* end of Additional Prototypes */

#ifdef __cplusplus
}
#endif

#endif


