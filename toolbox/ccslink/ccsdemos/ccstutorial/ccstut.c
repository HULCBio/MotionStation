/*-------------------------------------------------------------------*
 * CCSTUT.C - Target Source code for demo : CCSTUTORIAL
 * Simple program example to show Memory Read/Write
 *
 *------------------------------------------------------------------*/
/* Copyright 2002-2003 The MathWorks, Inc.
 * $Revision: 1.8.4.2 $ $Date: 2004/04/01 16:00:40 $ */
#include "stdio.h"
#include "limits.h"
/*-------------------------------------------------------------------*
 * Define 16/32 bit types (for either 28x or 5x or 6x family)
 *------------------------------------------------------------------*/
#if SHRT_MAX == 0x7FFF
#define int16_T short
#elif INT_MAX == 0x7FFF
#define int16_T int
#endif

#if INT_MAX == 0x7FFFFFFF 
#define int32_T int
#elif LONG_MAX == 0x7FFFFFFF
# define int32_T long
#endif
 
/*-------------------------------------------------------------------*
 * Complex Data types - enumerated, structures, 
 *------------------------------------------------------------------*/
typedef enum TAG_myEnum {
	MATLAB = 0,
	Simulink,
	SignalToolbox,
	MatlabLink,
	EmbeddedTargetC6x
} myEnum;

struct TAG_myStruct {
	int iy[2][3];
	myEnum iz;
} myStruct = { {{1,2,3},{4,-5,6}}, MatlabLink};

/*------------------------------------------------------------------*
 * Buffers/definitions
 *------------------------------------------------------------------*/ 
int16_T idat[] = { 1,508,647,7000};
double ddat[] = { 16.3, -2.13, 5.1, 11.8 };

char myString[] = "Treat me like an ANSI String";
int16_T ibuf[10];

int16_T sin_taylor(int16_T x);
int16_T *sin_taylor_vect(int16_T *x,int16_T *y,int16_T npts);
/*----------- main ---------------------------------------------*
 * Simple main program to print values in ddat and idat
 *-------------------------------------------------------------*/
void main()
{ 

   puts("Link for Code Composer: Tutorial - Initialized Memory\n");
   
    printf("Double Data array = %g %g %g %g\n",ddat[0],ddat[1],ddat[2],ddat[3]);
    printf("Integer Data array = %1d-%3d-%3d-%4d (Call me anytime!)\n\n",idat[0],idat[1],idat[2],idat[3]);
 
    /*  Breakpoint on next line ! */
    printf("Link for Code Composer: Tutorial - Memory Modified by MATLAB!\n\n");
    
    printf("Double Data array = %g %g %g %g\n",ddat[0],ddat[1],ddat[2],ddat[3]);
    printf("Integer Data array = %d %d %d %d\n",idat[0],idat[1],idat[2],idat[3]);

	ibuf[0] = sin_taylor(ibuf[0]);
	sin_taylor_vect(ibuf,ibuf,10);
}
/*------------------------------------------------------------*
 * Taylor Series expansion of sin function - Fixed Point
 *  Limitations: input range:  -pi <x <pi;
 *
 * Input Datatype is:
 *   Q2.13 (or MATLAB sfix16_En13), scale factor = 2^13
 * Output Datatype is:
 *   Q1.14 (or MATLAB sfix16_En14), scale factor = 2^14
 *
 * Taylor Expansion of sin function (first 4 terms)
 *  sin(x) =(approx) x[1 - (x^2/6)*[1 + (x^2/20)*[ 1 - (x^2/42)]]]
 *-------------------------------------------------------------*/
#define SFIX32_EN26_VAL_1    67108864  // Integer equivalent of 1.0 in Q5.26
#define SFIX32_EN28_VAL_1   268435456  // Integer equivalent of 1.0 in Q3.28
#define SFIX32_EN30_VAL_1  1073741824  // Integer equivalent of 1.0 in Q1.30

int16_T sin_taylor(int16_T x)
{
	int32_T  acc,a1,a2,a3;
	int32_T  xpow;  

	xpow = x*x;   // x^2  sfix32_En26

        a1 = xpow/42;  // x^2/42  sfix32_En26
        a2 = xpow/20;  // x^2/20  sfix32_En26
        a3 = xpow/6;   // x^2/6   sfix32_En26

        acc = SFIX32_EN26_VAL_1 - a1;
        acc >>= 11;   
        acc *= (a2>>11);

        acc = SFIX32_EN30_VAL_1 - acc;
        acc >>= 14;
        acc *= (a3>>14);

        acc = SFIX32_EN28_VAL_1 - acc;
        acc >>= 11;
        acc *= x; 

        return (acc>>16);
}
/*------------------------------------------------------------*
 * Vectorized version of fixed-point sin function
 * Supports inplace
 * Input Parameters
 *    x = array of phases to be converted
 *    y = storage for converted results: sin(x)
 *    npts = size of x array (and y)
 * Return value
 *    Returns y pointer (for convenience)
 *------------------------------------------------------------*/
int16_T *sin_taylor_vect(int16_T *x,int16_T *y,int16_T npts)
{
    int i;
    int16_T *yt = y;
    for(i=0; i<npts; i++) {
        *yt++ = sin_taylor(*x++);
    }
    return y;
}

