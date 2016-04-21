/*-------------------------------------------------------------------*
 * HILTUT.C - Target Source code for demo : HILTUTORIAL
 * Simple program example to show HIL features
 *
 *------------------------------------------------------------------*/
/* Copyright 2002-2003 The MathWorks, Inc.
 * $Revision: 1.2.4.1 $ $Date: 2003/11/30 23:04:43 $ */
#include "stdio.h"
#include "limits.h"
#include "fir_filter.h"

#define NX 128
#define NH 11

 
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
 * Buffers/definitions/FIR Parameters initialization
 *------------------------------------------------------------------*/ 
short idat[2][3] = { -1, 508, 647, 7000, 8, 619};
double ddat[] = { 16.3, -2.13, 5.1, 11.8 };

char myString[] = "Treat me like an ANSI String";
short ibuf[63];
short obuf[63];


typedef short INT16;

// fir_filter parameters
INT16 din[NX];
INT16 dout[NX];
INT16 coeff[NH];
INT16 ncoeff;
INT16 nbuf;

short sin_taylor(short x);
short *sin_taylor_vect(short *x,short *y,short npts);

/*----------- main ---------------------------------------------*
 * Simple main program to print values in ddat and idat
 *-------------------------------------------------------------*/
void main()
{ 
	
	short result;
	short data = 1;
	short min = 0;
	short i;
	puts("Link for Code Composer: HIL Tutorial \n");
   
  	result = sin_taylor(data*8192);
    sin_taylor_vect(ibuf,ibuf,63);

  	
  	// FIR Computation 
  	// clear
	for (i=0; i<NX; i++) dout[i] = 0;	// clear output buffer (optional)

	// compute
  	fir_filter(din,coeff,dout,ncoeff,nbuf); 
	
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

short sin_taylor(short x)
{	

// Define 16/32 bit local variables depending on processor
#if INT_MAX == 0x7FFFFFFF 
int acc,a1,a2,a3,xpow;
#elif LONG_MAX == 0x7FFFFFFF
long acc,a1,a2,a3,xpow;
#endif
	
	
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
short *sin_taylor_vect(short *x,short *y,short npts)
{
    int i;
    short *yt = y;
    for(i=0; i<npts; i++) {
        *yt++ = sin_taylor(*x++);
    }
    return y;
}
