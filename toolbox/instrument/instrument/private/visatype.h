/*---------------------------------------------------------------------------*/
/* Distributed by VXIplug&play Systems Alliance                              */
/*                                                                           */
/* Do not modify the contents of this file.                                  */
/*---------------------------------------------------------------------------*/
/*                                                                           */
/* Title : VISATYPE.H                                                        */
/* Date : 08-01-98                                                           */
/* Purpose : Fundamental VISA data types and macro definitions               */
/*                                                                           */
/*---------------------------------------------------------------------------*/
#ifndef __VISATYPE_HEADER__
#define __VISATYPE_HEADER__
#if (defined(WIN32) || defined(_WIN32) || defined(__WIN32__) || defined(__NT__)) && !defined(_NI_mswin16_)
#define _VI_FAR
#define _VI_FUNC __stdcall
#define _VI_FUNCC __cdecl
#define _VI_FUNCH __stdcall
#define _VI_SIGNED signed
#elif defined(_CVI_) && defined(_NI_i386_)
#define _VI_FAR
#define _VI_FUNC _pascal
#define _VI_FUNCC
#define _VI_FUNCH _pascal
#define _VI_SIGNED signed
#elif (defined(_WINDOWS) || defined(_Windows)) && !defined(_NI_mswin16_)
#define _VI_FAR _far
#define _VI_FUNC _far _pascal _export
#define _VI_FUNCC _far _cdecl _export
#define _VI_FUNCH _far _pascal
#define _VI_SIGNED signed
#elif (defined(hpux) || defined(__hpux)) && (defined(__cplusplus) || defined(__cplusplus__))
#define _VI_FAR
#define _VI_FUNC
#define _VI_FUNCC
#define _VI_FUNCH
#define _VI_SIGNED
#else
#define _VI_FAR
#define _VI_FUNC
#define _VI_FUNCC
#define _VI_FUNCH
#define _VI_SIGNED signed
#endif
#define _VI_ERROR (-2147483647L-1) /* 0x80000000 */
#define _VI_PTR _VI_FAR *

/*- VISA Types --------------------------------------------------------------*/
typedef unsigned long ViUInt32;
typedef ViUInt32 _VI_PTR ViPUInt32;
typedef ViUInt32 _VI_PTR ViAUInt32;
typedef _VI_SIGNED long ViInt32;
typedef ViInt32 _VI_PTR ViPInt32;
typedef ViInt32 _VI_PTR ViAInt32;
typedef unsigned short ViUInt16;
typedef ViUInt16 _VI_PTR ViPUInt16;
typedef ViUInt16 _VI_PTR ViAUInt16;
typedef _VI_SIGNED short ViInt16;
typedef ViInt16 _VI_PTR ViPInt16;
typedef ViInt16 _VI_PTR ViAInt16;
typedef unsigned char ViUInt8;
typedef ViUInt8 _VI_PTR ViPUInt8;
typedef ViUInt8 _VI_PTR ViAUInt8;
typedef _VI_SIGNED char ViInt8;
typedef ViInt8 _VI_PTR ViPInt8;
typedef ViInt8 _VI_PTR ViAInt8;
typedef char ViChar;
typedef ViChar _VI_PTR ViPChar;
typedef ViChar _VI_PTR ViAChar;
typedef unsigned char ViByte;
typedef ViByte _VI_PTR ViPByte;
typedef ViByte _VI_PTR ViAByte;
typedef void _VI_PTR ViAddr;
typedef ViAddr _VI_PTR ViPAddr;
typedef ViAddr _VI_PTR ViAAddr;
typedef float ViReal32;
typedef ViReal32 _VI_PTR ViPReal32;
typedef ViReal32 _VI_PTR ViAReal32;
typedef double ViReal64;
typedef ViReal64 _VI_PTR ViPReal64;
typedef ViReal64 _VI_PTR ViAReal64;
typedef ViPByte ViBuf;
typedef ViPByte ViPBuf;
typedef ViPByte _VI_PTR ViABuf;
typedef ViPChar ViString;
typedef ViPChar ViPString;
typedef ViPChar _VI_PTR ViAString;
typedef ViString ViRsrc;
typedef ViString ViPRsrc;
typedef ViString _VI_PTR ViARsrc;
typedef ViUInt16 ViBoolean;
typedef ViBoolean _VI_PTR ViPBoolean;
typedef ViBoolean _VI_PTR ViABoolean;
typedef ViInt32 ViStatus;
typedef ViStatus _VI_PTR ViPStatus;
typedef ViStatus _VI_PTR ViAStatus;
typedef ViUInt32 ViVersion;
typedef ViVersion _VI_PTR ViPVersion;
typedef ViVersion _VI_PTR ViAVersion;
typedef ViUInt32 ViObject;
typedef ViObject _VI_PTR ViPObject;
typedef ViObject _VI_PTR ViAObject;
typedef ViObject ViSession;
typedef ViSession _VI_PTR ViPSession;
typedef ViSession _VI_PTR ViASession;
typedef ViUInt32 ViAttr;
#ifndef _VI_CONST_STRING_DEFINED
typedef const ViChar * ViConstString;
#define _VI_CONST_STRING_DEFINED
#endif
/*- Completion and Error Codes ----------------------------------------------*/
#define VI_SUCCESS (0L)
/*- Other VISA Definitions --------------------------------------------------*/
#define VI_NULL (0)
#define VI_TRUE (1)
#define VI_FALSE (0)
/*- Backward Compatibility Macros -------------------------------------------*/
#define VISAFN _VI_FUNC
#define ViPtr _VI_PTR
#endif
/*- The End -----------------------------------------------------------------*/
