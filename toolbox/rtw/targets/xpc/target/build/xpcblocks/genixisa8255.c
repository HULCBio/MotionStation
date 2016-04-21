/* $Revision: 1.6 $ $Date: 2002/03/25 04:04:12 $ */
/* genixisa8255.c - xPC Target, non-inlined S-function driver for digital input/output section of ISA boards using the 8255 chip driving Genix */
/* Copyright 1996-2002 The MathWorks, Inc.
*/


#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME 	genixisa8255

#include 	<stddef.h>
#include 	<stdlib.h>

#include 	"simstruc.h" 

#ifdef 		MATLAB_MEX_FILE
#include 	"mex.h"
#endif

#ifndef 	MATLAB_MEX_FILE
#include 	<windows.h>
#include 	"io_xpcimport.h"
#include 	"time_xpcimport.h"
#endif

static uchar_T f1(uchar_T n1, uchar_T n2, uchar_T n3, uint_T b);
static uchar_T f2(uchar_T *n1, uint_T b);
static uchar_T f3(uchar_T n1, const real_T *a1, uint_T b);
static uchar_T f4(uchar_T n1, uchar_T n2);
static void f5(uchar_T *n1, uchar_T n2);
static void f6(uchar_T *n1, uchar_T n2, uchar_T n3);
static uchar_T f7(uint_T n1, uchar_T n2);
static void f8(uint_T n1, uchar_T n2);
static void f9(uint_T n1, uchar_T n2);
static void f10(uint_T n1, uchar_T n2, uchar_T n3);
static void f11(ushort_T *w1, uchar_T n1, uchar_T n2);
static void f12(void);
static void f13(const real_T *a1, int_T i1, uint_T b);

#define NUMBER_OF_ARGS          (4)
#define DATA_ARG            	ssGetSFcnParam(S,0)
#define BASE_8255_ARG           ssGetSFcnParam(S,1)
#define BASE_ARG            	ssGetSFcnParam(S,2)
#define CONTROL_ARG            	ssGetSFcnParam(S,3)

#define NO_I_WORKS              (0)

#define NO_R_WORKS              (0)

#define WAIT_PERIOD				0.0001

static char_T msg[256];


static void mdlInitializeSizes(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "time_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
		sprintf(msg,"Wrong number of input arguments passed.\n%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

	ssSetNumInputPorts(S, 0);

    ssSetNumOutputPorts(S, 0);

    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumPWork(S, 0);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

	ssSetSFcnParamNotTunable(S,0);
	ssSetSFcnParamNotTunable(S,1);
	ssSetSFcnParamNotTunable(S,2);
	ssSetSFcnParamNotTunable(S,3);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
	
}
 
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}
 
#define MDL_START
static void mdlStart(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE

  	int_T num_channels, base, port, control; 
	const real_T *data;
	uint_T base8255;


	base8255= (uint_T)mxGetPr(BASE_ARG)[0] + (int_T)mxGetPr(BASE_8255_ARG)[0];
    control=(int_T)mxGetPr(CONTROL_ARG)[0];

	data=mxGetPr(DATA_ARG);

	rl32eOutpB((unsigned short)(base8255+3),(unsigned short)control);

	if (mxGetN(DATA_ARG)!=0 && mxGetN(DATA_ARG)!=0) { 
		f13(data, mxGetN(DATA_ARG), base8255);
	}
	  
#endif
                 
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
}

static void mdlTerminate(SimStruct *S)
{   
}


#ifndef MATLAB_MEX_FILE

void f13(const real_T *a1, int_T i1, uint_T b)
{
	uchar_T n1 = 0;
    uchar_T n2, n3, n4;
    uchar_T n5;
    const real_T *a2;
	uint_T n6;

    f8(b, 7);

	n6=0;

	while (i1 > n6) {
		n2=(uchar_T)*(a1+n6+0);
		n3=(uchar_T)*(a1+n6+1);
		n4=(uchar_T)*(a1+n6+2);

		a2=a1+n6+3;

		n1=f1(n2, n3, n4, b);

		if (n1==0) {
        	n1=f2(&n5, b);
			if (	(n1 == 0) && 
					((uchar_T)a2[0] == n5) && 
					(uchar_T)a2[1] && 
					((uchar_T)a2[1] <= 34) ) {
				n1=f3((uchar_T)a2[1], &a2[2], b);
				if (n1 != 0) {
            		f8(b, 3);
          		}
			}
		}
		n6+=(uchar_T)a2[1]+5; 
	}
}

uchar_T f1(uchar_T n1, uchar_T n2, uchar_T n3, uint_T b)
{
    f9(b, 0);

    f12();

    f10(b+2, 0, f4(n3, 0));
    f10(b+2, 1, f4(n3, 1));
    f10(b+2, 2, f4(n3, 2));
    f10(b+2, 3, f4(n1, 0));
    f10(b+2, 4, f4(n1, 1));
    f10(b+2, 5, f4(n1, 2));
    f10(b+2, 6, f4(n2, 0));
    f10(b+2, 7, f4(n2, 1));

    f12();

    f8(b, 0);

    return((uchar_T)0);
}

uchar_T f2(uchar_T *n1, uint_T b)
{
    *n1=0;
	
    f6(n1, 0, (uchar_T)!f7(b+1, 0));
    f6(n1, 1, (uchar_T)!f7(b+1, 1));
    f6(n1, 2, (uchar_T)!f7(b+1, 2));
    f6(n1, 3, (uchar_T)!f7(b+1, 3));
    f6(n1, 4, (uchar_T)!f7(b+1, 4));

    return((uchar_T)0);
}

uchar_T f3(uchar_T n1, const real_T *a1, uint_T b)
{
    uchar_T	n2 = 0;
    ushort_T w1, w2;
    uchar_T n3;
    int_T i1, i2;

    w1=((uchar_T)a1[n1 - 1] << 8) | (uchar_T)a1[n1 - 2];

    f9(b, 2);
    f12();
    f8(b, 3);
    f12();
    f9(b, 3);
    f12();
    f8(b, 4);

    if (n1 & 1)	{n3=8;} else {n3=0;}

    for (i1 = n1 - 1; i1 >= 0; i1--) {
        for (i2 = 7; i2 >= 0; i2--) {
            f12();

            if (n3 < 8) {
                f11(&w2, (uchar_T)(i2 + 8), (uchar_T)!f7(b+1, 5));
            } else {
                f11(&w2, (uchar_T)i2,  (uchar_T)!f7(b+1, 5));
			}
            n3++;
            if (n3 == 16) {
                n3 = 0;
			}
            f10(b, 1, f4((uchar_T)a1[i1], (uchar_T)i2));
            f8(b, 2);
            f9(b, 2);
      	}
  	}

    n2 = 0;
    if (n2 == 0) {
    	if (w2 != w1) {
            n2 = -1;
            f8(b, 3);
            f12();
            f9(b, 3);
        } else {
            f12();
            f9(b, 4);
        }
	}
    return(n2);
}

uchar_T f4(uchar_T n1, uchar_T n2)
{
    return((n1 >> n2) & 0x01);
}

void f5(uchar_T *n1, uchar_T n2)
{
	uchar_T n3;
	
	n3=*n1; 
    n3 |= (0x01 << n2);
	*n1=n3;
}

void f6(uchar_T *n1, uchar_T n2, uchar_T n3)
{
	uchar_T n4;

	n4=*n1;
    if (n3) {
        n4 |= (0x01 << n2);
    } else {
        n4 &= ~(0x01 << n2);
	}
	*n1= n4;
}

uchar_T f7(uint_T n1, uchar_T n2)
{
    return ((rl32eInpB((unsigned short)n1) >> n2) & 0x01);
}

void f8(uint_T n1, uchar_T n2)
{
	uchar_T	n3;

	n3=rl32eInpB((unsigned short)n1);
    n3 |= (0x01 << n2);
	rl32eOutpB((unsigned short)n1,(unsigned short)n3);
}

void f9(uint_T n1, uchar_T n2)
{
	uchar_T	n3;

	n3=rl32eInpB((unsigned short)n1);
    n3 &= ~(0x01 << n2);
	rl32eOutpB((unsigned short)n1,(unsigned short)n3);	
}

void f10(uint_T n1, uchar_T n2, uchar_T n3)
{
	uchar_T	n4;

	n4=rl32eInpB((unsigned short)n1);
    if (n3) {
        n4 |= (0x01 << n2);
    } else {
        n4 &= ~(0x01 << n2);
	}
	rl32eOutpB((unsigned short)n1,(unsigned short)n4);
}

void f11(ushort_T *w1, uchar_T n1, uchar_T n2)
{
	ushort_T w2;

	w2=*w1;
    if (n2) {
        w2 |= (0x01 << n1);
    } else {
        w2 &= ~(0x01 << n1);
	}
	*w1=w2;
}

void f12(void)
{
	rl32eWaitDouble(WAIT_PERIOD);
}

#endif


#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif


