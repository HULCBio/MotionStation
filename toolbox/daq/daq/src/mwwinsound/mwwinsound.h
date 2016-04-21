

/* this ALWAYS GENERATED file contains the definitions for the interfaces */


 /* File created by MIDL compiler version 6.00.0361 */
/* at Wed Apr 07 12:25:27 2004
 */
/* Compiler settings for .\mwwinsound.idl:
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


#ifndef __mwwinsound_h__
#define __mwwinsound_h__

#if defined(_MSC_VER) && (_MSC_VER >= 1020)
#pragma once
#endif

/* Forward Declarations */ 

#ifndef __Adaptor_FWD_DEFINED__
#define __Adaptor_FWD_DEFINED__

#ifdef __cplusplus
typedef class Adaptor Adaptor;
#else
typedef struct Adaptor Adaptor;
#endif /* __cplusplus */

#endif 	/* __Adaptor_FWD_DEFINED__ */


#ifndef __SoundAD_FWD_DEFINED__
#define __SoundAD_FWD_DEFINED__

#ifdef __cplusplus
typedef class SoundAD SoundAD;
#else
typedef struct SoundAD SoundAD;
#endif /* __cplusplus */

#endif 	/* __SoundAD_FWD_DEFINED__ */


#ifndef __SoundDA_FWD_DEFINED__
#define __SoundDA_FWD_DEFINED__

#ifdef __cplusplus
typedef class SoundDA SoundDA;
#else
typedef struct SoundDA SoundDA;
#endif /* __cplusplus */

#endif 	/* __SoundDA_FWD_DEFINED__ */


/* header files for imported files */
#include "oaidl.h"
#include "ocidl.h"
#include "daqmex.h"

#ifdef __cplusplus
extern "C"{
#endif 

void * __RPC_USER MIDL_user_allocate(size_t);
void __RPC_USER MIDL_user_free( void * ); 


#ifndef __MWWINSOUNDLib_LIBRARY_DEFINED__
#define __MWWINSOUNDLib_LIBRARY_DEFINED__

/* library MWWINSOUNDLib */
/* [helpstring][version][uuid] */ 


EXTERN_C const IID LIBID_MWWINSOUNDLib;

EXTERN_C const CLSID CLSID_Adaptor;

#ifdef __cplusplus

class DECLSPEC_UUID("E3A3FC7A-B3CE-11D3-B32F-00A0C9F223E0")
Adaptor;
#endif

EXTERN_C const CLSID CLSID_SoundAD;

#ifdef __cplusplus

class DECLSPEC_UUID("93DA44DC-C20F-11d3-A53E-00902757EA8D")
SoundAD;
#endif

EXTERN_C const CLSID CLSID_SoundDA;

#ifdef __cplusplus

class DECLSPEC_UUID("93DA44DB-C20F-11d3-A53E-00902757EA8D")
SoundDA;
#endif
#endif /* __MWWINSOUNDLib_LIBRARY_DEFINED__ */

/* Additional Prototypes for ALL interfaces */

/* end of Additional Prototypes */

#ifdef __cplusplus
}
#endif

#endif


