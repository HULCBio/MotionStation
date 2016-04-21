/* $Revision: 1.1 $ */
/***************************************************************************/
/*                                                                         */
/*   Softing GmbH          Richard-Reitzner-Allee 6       85540 Haar       */
/*                                                                         */
/***************************************************************************/
/*                                                                         */
/*   Copyright (C) by Softing GmbH, 1997, All rights reserved.             */
/*                                                                         */
/***************************************************************************/
/*                                                                         */
/*                     C A N _ D E F . H                                   */
/*                                                                         */
/***************************************************************************/
/*                                                                         */
/* PROJECT:            CANLIB                                              */
/*                                                                         */
/* MODULE:             CAN_DEF.H                                           */
/*                                                                         */
/* AUTHOR:             Softing GmbH                                        */
/*                                                                         */
/* MODULE_DESCRIPTION  definitions for CAN-LAYER2 LIB                      */
/*                     CANcard and CAN-AC2                                 */
/*                                                                         */
/* USAGE               description of the macro definitions                */
/*                                                                         */
/*       Macro         Description                                         */                         
/*                                                                         */
/*       WIN16         define for building 16-bit windows (WIN3.11)        */
/*                     applications                                        */
/*                                                                         */
/*       WIN32         define for building 32-bit applications             */   
/*                     (WIN-NT 4.0 and WIN 95)                             */
/*                                                                         */
/*       DOS           define for MSDOS applications. DOS is               */
/*                     automatically defined, if neither WIN16             */
/*                     nor WIN32 is set.                                   */  
/*                                                                         */
/*       __cplusplus   define for C++ applications (normally defined       */
/*                     automatically by the compiler)                      */
/*                                                                         */
/***************************************************************************/
/*
* 
*/
#ifndef  _CAN_DEF_H
#define  _CAN_DEF_H


#ifdef __cplusplus
#ifndef PRAEDEF 
#define PRAEDEF extern "C"
#endif
#ifndef PRAEDECL
#define PRAEDECL  extern "C"
#endif
#else /* cplusplus */
#ifndef PRAEDEF
#define PRAEDEF 
#endif
#ifndef PRAEDECL
#define PRAEDECL 
#endif
#endif


#ifndef PRAEDECL
#define PRAEDECL 
#endif

#ifndef MIDDECL
#define MIDDECL  
#endif

#ifndef MIDDEF
#define MIDDEF  
#endif
 
typedef int                     BOOL;
#define FALSE                   0
#define TRUE                    1
typedef unsigned char       BYTE;
typedef unsigned short      WORD;
typedef unsigned long       DWORD;
typedef unsigned int        UINT;
#ifndef NULL
#define NULL                    0
#endif

typedef char *                  LPSTR;
#ifndef WIN32
typedef const char *            LPCSTR;
#endif
typedef BYTE *                  LPBYTE;
typedef int *                   LPINT;
typedef WORD *                  LPWORD;
typedef long *                  LPLONG;
typedef DWORD *                 LPDWORD;
typedef void *                  LPVOID;



#endif /* _CAN_DEF_H */
                                                                       
