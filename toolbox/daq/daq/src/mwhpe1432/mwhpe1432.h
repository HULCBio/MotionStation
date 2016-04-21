

/* this ALWAYS GENERATED file contains the definitions for the interfaces */


 /* File created by MIDL compiler version 6.00.0361 */
/* at Wed Mar 24 02:17:13 2004
 */
/* Compiler settings for .\mwhpe1432.idl:
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


#ifndef __mwhpe1432_h__
#define __mwhpe1432_h__

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

/* Forward Declarations */ 

#ifndef __hpvxiAD_FWD_DEFINED__
#define __hpvxiAD_FWD_DEFINED__

#ifdef __cplusplus
typedef class hpvxiAD hpvxiAD;
#else
typedef struct hpvxiAD hpvxiAD;
#endif /* __cplusplus */

#endif 	/* __hpvxiAD_FWD_DEFINED__ */


#ifndef __hpvxiDA_FWD_DEFINED__
#define __hpvxiDA_FWD_DEFINED__

#ifdef __cplusplus
typedef class hpvxiDA hpvxiDA;
#else
typedef struct hpvxiDA hpvxiDA;
#endif /* __cplusplus */

#endif 	/* __hpvxiDA_FWD_DEFINED__ */


/* header files for imported files */
#include "oaidl.h"
#include "ocidl.h"

#ifdef __cplusplus
extern "C"{
#endif 

void * __RPC_USER MIDL_user_allocate(size_t);
void __RPC_USER MIDL_user_free( void * ); 


#ifndef __MWHPVXILib_LIBRARY_DEFINED__
#define __MWHPVXILib_LIBRARY_DEFINED__

/* library MWHPVXILib */
/* [helpstring][version][uuid] */ 


EXTERN_C const IID LIBID_MWHPVXILib;

EXTERN_C const CLSID CLSID_hpvxiAD;

#ifdef __cplusplus

class DECLSPEC_UUID("7A842F2A-B3F6-11d3-B32F-00A0C9F223E2")
hpvxiAD;
#endif

EXTERN_C const CLSID CLSID_hpvxiDA;

#ifdef __cplusplus

class DECLSPEC_UUID("7A842F2B-B3F6-11d3-B32F-00A0C9F223E2")
hpvxiDA;
#endif
#endif /* __MWHPVXILib_LIBRARY_DEFINED__ */

/* Additional Prototypes for ALL interfaces */

/* end of Additional Prototypes */

#ifdef __cplusplus
}
#endif

#endif


