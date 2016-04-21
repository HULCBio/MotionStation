/*
 *  float.h     Floating point functions
 *
 *                          Open Watcom Project
 *
 *    Portions Copyright (c) 1983-2002 Sybase, Inc. All Rights Reserved.
 *
 *  ========================================================================
 *
 *    This file contains Original Code and/or Modifications of Original
 *    Code as defined in and that are subject to the Sybase Open Watcom
 *    Public License version 1.0 (the 'License'). You may not use this file
 *    except in compliance with the License. BY USING THIS FILE YOU AGREE TO
 *    ALL TERMS AND CONDITIONS OF THE LICENSE. A copy of the License is
 *    provided with the Original Code and Modifications, and is also
 *    available at www.sybase.com/developer/opensource.
 *
 *    The Original Code and all software distributed under the License are
 *    distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER
 *    EXPRESS OR IMPLIED, AND SYBASE AND ALL CONTRIBUTORS HEREBY DISCLAIM
 *    ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF
 *    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR
 *    NON-INFRINGEMENT. Please see the License for the specific language
 *    governing rights and limitations under the License.
 *
 *  ========================================================================
 */
#ifndef _FLOAT_H_INCLUDED
#define _FLOAT_H_INCLUDED
#if !defined(_ENABLE_AUTODEPEND)
  #pragma read_only_file;
#endif

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#ifndef _COMDEF_H_INCLUDED
 #include <_comdef.h>
#endif

#ifndef NULL
 #if defined(__SMALL__) || defined(__MEDIUM__) || defined(__386__) || defined(__AXP__) || defined(__PPC__)
  #define NULL   0
 #else
  #define NULL   0L
 #endif
#endif

#define FLT_NORMALIZE   0
#define FLT_RADIX       2
#define FLT_ROUNDS      1       /* round to nearest */
#define _DBL_RADIX      2
#define _DBL_ROUNDS     1
#define _LDBL_RADIX     _DBL_RADIX
#define _LDBL_ROUNDS    _DBL_ROUNDS
#if !defined(NO_EXT_KEYS) /* extensions enabled */
#define DBL_RADIX      _DBL_RADIX
#define DBL_ROUNDS     _DBL_ROUNDS
#define LDBL_RADIX     _DBL_RADIX
#define LDBL_ROUNDS    _DBL_ROUNDS
#endif

/* number of base-FLT_RADIX digits in the floating-point mantissa */
#define FLT_MANT_DIG    24
#define DBL_MANT_DIG    53
#define LDBL_MANT_DIG   53

/* number of decimal digits of precision */
#define FLT_DIG         6
#define DBL_DIG         15
#define LDBL_DIG        15

/* minimum negative integer such that FLT_RADIX raised to that power minus 1
 is a normalized floating-point number */
#define FLT_MIN_EXP     (-125)
#define DBL_MIN_EXP     (-1021)
#define LDBL_MIN_EXP    (-1021)

/* minimum negative integer such that 10 raised to that power is in the
   range of normalized floating-point numbers */
#define FLT_MIN_10_EXP  (-37)
#define DBL_MIN_10_EXP  (-307)
#define LDBL_MIN_10_EXP (-307)

/* maximum integer such that FLT_RADIX raised to that power minus 1 is a
   representable floating-point number */
#define FLT_MAX_EXP     128
#define DBL_MAX_EXP     1024
#define LDBL_MAX_EXP    1024

/* maximum integer such that 10 raised to that power is in the range of
   representable floating-point numbers */
#define FLT_MAX_10_EXP  38
#define DBL_MAX_10_EXP  308
#define LDBL_MAX_10_EXP 308

/*
 *  The Watcom C/C++ 11.0 compile-time constant analyzer for
 *  doubles is inaccurate. For accurate numeric representation
 *  use _DBL_MAX, _DBL_MIN, and _DBL_EPSILON (ANSI C allows
 *  these values to be non-constant expressions).
 */
_WMRTLINK extern double  strtod( const char *__nptr, char **__endptr );

/* maximum representable floating-point number */
#define FLT_MAX         3.402823466e+38f
#define DBL_MAX         1.7976931348623150e+308 /* inaccurate constant value */
#define _DBL_MAX        (strtod("1.7976931348623157e+308",NULL))
#define LDBL_MAX        DBL_MAX

/* minimum positive floating-point number x such that 1.0 + x != 1.0 */
#define FLT_EPSILON     1.192092896e-7f
#define DBL_EPSILON     2.2204460492503130e-16  /* inaccurate constant value */
#define _DBL_EPSILON    (strtod("2.2204460492503131e-16",NULL))
#define LDBL_EPSILON    DBL_EPSILON

/* minimum representable positive floating-point number */
#define FLT_MIN         1.175494351e-38f
#define DBL_MIN         2.2250738585072020e-308 /* inaccurate constant value */
#define _DBL_MIN        (strtod("2.2250738585072014e-308",NULL))
#define LDBL_MIN        DBL_MIN

/*
 *  8087/80287/80387 math co-processor control information
 */

/* 80(x)87 Control Word Mask and bit definitions. */

#define _MCW_EM         0x003f  /* Interrupt Exception Masks */
#define _EM_INVALID     0x0001  /*   invalid */
#define _EM_DENORMAL    0x0002  /*   denormal */
#define _EM_ZERODIVIDE  0x0004  /*   zero divide */
#define _EM_OVERFLOW    0x0008  /*   overflow */
#define _EM_UNDERFLOW   0x0010  /*   underflow */
#define _EM_INEXACT     0x0020  /*   inexact result - precision */

#define _MCW_IC         0x1000  /* Infinity Control */
#define _IC_AFFINE      0x1000  /*   affine */
#define _IC_PROJECTIVE  0x0000  /*   projective */

#define _MCW_RC         0x0c00  /* Rounding Control */
#define _RC_NEAR        0x0000  /*   near */
#define _RC_DOWN        0x0400  /*   down */
#define _RC_UP          0x0800  /*   up */
#define _RC_CHOP        0x0c00  /*   chop */

#define _MCW_PC         0x0300  /* Precision Control */
#define _PC_24          0x0000  /*    24 bits */
#define _PC_53          0x0200  /*    53 bits */
#define _PC_64          0x0300  /*    64 bits */

/* initial Control Word value */

#define _CW_DEFAULT (_IC_AFFINE | _RC_NEAR | _PC_53 \
                    | _EM_INVALID | _EM_DENORMAL | _EM_ZERODIVIDE \
                    | _EM_OVERFLOW | _EM_UNDERFLOW | _EM_INEXACT)

/* 80(x)87 Status Word bit definitions */

#define _SW_INVALID     0x0001  /* invalid */
#define _SW_DENORMAL    0x0002  /* denormal */
#define _SW_ZERODIVIDE  0x0004  /* zero divide */
#define _SW_OVERFLOW    0x0008  /* overflow */
#define _SW_UNDERFLOW   0x0010  /* underflow */
#define _SW_INEXACT     0x0020  /* inexact (precision) */

/* the following are generated by software */

#define _SW_UNEMULATED      0x0040  /* unemulated instruction */
/* invalid subconditions (_SW_INVALID also set) */
#define _SW_SQRTNEG         0x0080  /* square root of a neg number */
#define _SW_STACKOVERFLOW   0x0200  /* FP stack overflow */
#define _SW_STACKUNDERFLOW  0x0400  /* FP stack underflow */

/* Floating-point error codes */

#define _FPE_INVALID            0x81
#define _FPE_DENORMAL           0x82
#define _FPE_ZERODIVIDE         0x83
#define _FPE_OVERFLOW           0x84
#define _FPE_UNDERFLOW          0x85
#define _FPE_INEXACT            0x86

#define _FPE_UNEMULATED         0x87
#define _FPE_SQRTNEG            0x88
#define _FPE_STACKOVERFLOW      0x8a
#define _FPE_STACKUNDERFLOW     0x8b
#define _FPE_EXPLICITGEN        0x8c
#define _FPE_IOVERFLOW          0x8d /* issued on fist(p) when value is too
                                        large to be represented as integer */
#define _FPE_LOGERR             0x8e
#define _FPE_MODERR             0x8f

#if !defined(NO_EXT_KEYS) /* extensions enabled */
/*
 *  8087/80287/80387 math co-processor control information
 */

/* 80(x)87 Control Word Mask and bit definitions. */

#define MCW_EM          _MCW_EM
#define EM_INVALID      _EM_INVALID
#define EM_DENORMAL     _EM_DENORMAL
#define EM_ZERODIVIDE   _EM_ZERODIVIDE
#define EM_OVERFLOW     _EM_OVERFLOW
#define EM_UNDERFLOW    _EM_UNDERFLOW
#define EM_INEXACT      _EM_INEXACT
#define EM_PRECISION    _EM_INEXACT     /* WATCOM's name */

#define MCW_IC          _MCW_IC
#define IC_AFFINE       _IC_AFFINE
#define IC_PROJECTIVE   _IC_PROJECTIVE

#define MCW_RC          _MCW_RC
#define RC_NEAR         _RC_NEAR
#define RC_DOWN         _RC_DOWN
#define RC_UP           _RC_UP
#define RC_CHOP         _RC_CHOP

#define MCW_PC          _MCW_PC
#define PC_24           _PC_24
#define PC_53           _PC_53
#define PC_64           _PC_64

/* 80(x)87 Status Word bit definitions */

#define SW_INVALID          _SW_INVALID
#define SW_DENORMAL         _SW_DENORMAL
#define SW_ZERODIVIDE       _SW_ZERODIVIDE
#define SW_OVERFLOW         _SW_OVERFLOW
#define SW_UNDERFLOW        _SW_UNDERFLOW
#define SW_INEXACT          _SW_INEXACT
/* the following are generated by software */
#define SW_UNEMULATED       _SW_UNEMULATED
#define SW_SQRTNEG          _SW_SQRTNEG
#define SW_STACKOVERFLOW    _SW_STACKOVERFLOW
#define SW_STACKUNDERFLOW   _SW_STACKUNDERFLOW

/* Floating-point error codes */

#define FPE_INVALID         _FPE_INVALID
#define FPE_DENORMAL        _FPE_DENORMAL
#define FPE_ZERODIVIDE      _FPE_ZERODIVIDE
#define FPE_OVERFLOW        _FPE_OVERFLOW
#define FPE_UNDERFLOW       _FPE_UNDERFLOW
#define FPE_INEXACT         _FPE_INEXACT
#define FPE_UNEMULATED      _FPE_UNEMULATED
#define FPE_SQRTNEG         _FPE_SQRTNEG
#define FPE_STACKOVERFLOW   _FPE_STACKOVERFLOW
#define FPE_STACKUNDERFLOW  _FPE_STACKUNDERFLOW
#define FPE_EXPLICITGEN     _FPE_EXPLICITGEN
#define FPE_IOVERFLOW       _FPE_IOVERFLOW
#define FPE_LOGERR          _FPE_LOGERR
#define FPE_MODERR          _FPE_MODERR

_WMRTLINK extern unsigned _clear87(void);
_WCRTLINK extern unsigned _control87(unsigned,unsigned);
_WCRTLINK extern void     _fpreset(void);
_WMRTLINK extern unsigned _status87(void);
_WMRTLINK extern int      _finite(double);

#endif

#ifdef __cplusplus
};
#endif /* __cplusplus */
#endif
