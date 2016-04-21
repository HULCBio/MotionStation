/* $Revision: 1.2 $ */
/* float.h for target with IEEE 32 bit and 64 bit floating point formats */
#ifndef _FLOAT_H_
#define _FLOAT_H_
   /* Radix of exponent representation */
#undef FLT_RADIX
#define FLT_RADIX 2
   /* Number of base-FLT_RADIX digits in the significand of a float */
#undef FLT_MANT_DIG
#define FLT_MANT_DIG 24
   /* Number of decimal digits of precision in a float */
#undef FLT_DIG
#define FLT_DIG 6
   /* Addition rounds to 0: zero, 1: nearest, 2: +inf, 3: -inf, -1: unknown */
#undef FLT_ROUNDS
#define FLT_ROUNDS 1
   /* Difference between 1.0 and the minimum float greater than 1.0 */
#undef FLT_EPSILON
#define FLT_EPSILON 1.19209290e-07F
   /* Minimum int x such that FLT_RADIX**(x-1) is a normalised float */
#undef FLT_MIN_EXP
#define FLT_MIN_EXP (-125)
   /* Minimum normalised float */
#undef FLT_MIN
#define FLT_MIN 1.17549435e-38F
   /* Minimum int x such that 10**x is a normalised float */
#undef FLT_MIN_10_EXP
#define FLT_MIN_10_EXP (-37)
   /* Maximum int x such that FLT_RADIX**(x-1) is a representable float */
#undef FLT_MAX_EXP
#define FLT_MAX_EXP 128
   /* Maximum float */
#undef FLT_MAX
#define FLT_MAX 3.40282e+38F
   /* Maximum int x such that 10**x is a representable float */
#undef FLT_MAX_10_EXP
#define FLT_MAX_10_EXP 38

   /* Number of base-FLT_RADIX digits in the significand of a double */
#undef DBL_MANT_DIG
#define DBL_MANT_DIG 53
   /* Number of decimal digits of precision in a double */
#undef DBL_DIG
#define DBL_DIG 15
   /* Difference between 1.0 and the minimum double greater than 1.0 */
#undef DBL_EPSILON
#define DBL_EPSILON 2.2204460492503131e-16
   /* Minimum int x such that FLT_RADIX**(x-1) is a normalised double */
#undef DBL_MIN_EXP
#define DBL_MIN_EXP (-1021)
   /* Minimum normalised double */
#undef DBL_MIN
#define DBL_MIN 2.2250738585072014e-308
   /* Minimum int x such that 10**x is a normalised double */
#undef DBL_MIN_10_EXP
#define DBL_MIN_10_EXP (-307)
   /* Maximum int x such that FLT_RADIX**(x-1) is a representable double */
#undef DBL_MAX_EXP
#define DBL_MAX_EXP 1024
   /* Maximum double */
#undef DBL_MAX
#define DBL_MAX 1.7976931348623157e+308
   /* Maximum int x such that 10**x is a representable double */
#undef DBL_MAX_10_EXP
#define DBL_MAX_10_EXP 308

   /* Number of base-FLT_RADIX digits in the significand of a long double */
#undef LDBL_MANT_DIG
#define LDBL_MANT_DIG 53
   /* Number of decimal digits of precision in a long double */
#undef LDBL_DIG
#define LDBL_DIG 15
   /* Difference between 1.0 and the minimum long double greater than 1.0 */
#undef LDBL_EPSILON
#define LDBL_EPSILON 2.2204460492503131e-16L
   /* Minimum int x such that FLT_RADIX**(x-1) is a normalised long double */
#undef LDBL_MIN_EXP
#define LDBL_MIN_EXP (-1021)
   /* Minimum normalised long double */
#undef LDBL_MIN
#define LDBL_MIN 2.2250738585072014e-308L
   /* Minimum int x such that 10**x is a normalised long double */
#undef LDBL_MIN_10_EXP
#define LDBL_MIN_10_EXP (-307)
   /* Maximum int x such that FLT_RADIX**(x-1) is a representable long double */
#undef LDBL_MAX_EXP
#define LDBL_MAX_EXP 1024
   /* Maximum long double */
#undef LDBL_MAX
#define LDBL_MAX 1.7976931348623157e+308L
   /* Maximum int x such that 10**x is a representable long double */
#undef LDBL_MAX_10_EXP
#define LDBL_MAX_10_EXP 308

#define _CW_DEFAULT ( _RC_NEAR+_PC_53+_EM_INVALID+_EM_ZERODIVIDE+_EM_OVERFLOW \
	+ _EM_UNDERFLOW + _EM_INEXACT + _EM_DENORMAL)
#define _EM_DENORMAL	0x80000		/* denormal exception mask (_control87 only) */
#define _EM_INEXACT	0x1		/*   precision inexact  */
#define _EM_INVALID	0x10		/*   Invalid */
#define _EM_OVERFLOW	0x4		/*   Overflow */
#define _EM_UNDERFLOW	0x2		/*   Underflow */
#define _EM_ZERODIVIDE	0x8		/*   Zero divide */
#define _FPCLASS_ND	0x10	/* negative denormal */
#define _FPCLASS_NINF	0x4	/* negative infinity */
#define _FPCLASS_NN	0x8	/* negative normal */
#define _FPCLASS_NZ	0x20	/* -0 */
#define _FPCLASS_PD	0x80	/* positive denormal */
#define _FPCLASS_PINF	0x200	/* positive infinity */
#define _FPCLASS_PN	0x100	/* positive normal */
#define _FPCLASS_PZ	0x40	/* +0 */
#define _FPCLASS_QNAN	0x2	/* quiet NaN */
#define _FPCLASS_SNAN	0x1	/* signaling NaN */
#define _FPE_DENORMAL		0x82
#define _FPE_EXPLICITGEN	0x8c	/* raise( SIGFPE ); */
#define _FPE_INEXACT		0x86
#define _FPE_INVALID		0x81
#define _FPE_OVERFLOW		0x84
#define _FPE_SQRTNEG		0x88
#define _FPE_STACKOVERFLOW	0x8a
#define _FPE_STACKUNDERFLOW	0x8b
#define _FPE_UNDERFLOW		0x85
#define _FPE_UNEMULATED 	0x87
#define _FPE_ZERODIVIDE 	0x83
#define _IC_AFFINE	0x40000	
#define _IC_PROJECTIVE	0x0	
#define _MCW_EM 	0x1f	
#define _MCW_IC 	0x40000	
#define _MCW_PC 	0x30000	
#define _MCW_RC 	0x300	
#define _PC_24		0x20000	
#define _PC_53		0x10000	
#define _PC_64		0x0	
#define _RC_CHOP	0x300	
#define _RC_DOWN	0x100		
#define _RC_NEAR	0x0		
#define _RC_UP		0x200	
#define _SW_DENORMAL	0x80000		
#define _SW_INEXACT	1		
#define _SW_INVALID	16
#define _SW_OVERFLOW	4		
#define _SW_SQRTNEG		0x80	
#define _SW_STACKOVERFLOW	0x200	
#define _SW_STACKUNDERFLOW	0x400	
#define _SW_UNDERFLOW	0x2		
#define _SW_UNEMULATED		0x40	
#define _SW_ZERODIVIDE	0x8		
double  _chgsign (double);
double  _copysign (double, double);
double  _logb(double);
double  _nextafter(double, double);
double  _scalb(double, long);
extern int * __fpecode(void);
int     _finite(double);
int     _fpclass(double);
int     _isnan(double);
unsigned int  _clearfp(void);
unsigned int  _controlfp(unsigned int,unsigned int);
unsigned int  _statusfp(void);
unsigned int _control87(unsigned int,unsigned int);
void  _fpreset(void);
#endif /*  _FLOAT_H_ */
