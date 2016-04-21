/* $Revision: 1.7 $ $Date: 2002/03/25 04:05:06 $ */
/* daadvpcl818.c - xPC Target, non-inlined S-function driver for Advantech PCL-818 family D/A section */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME  daadvpcl818
									    
#include 	<stddef.h>
#include 	<stdlib.h>
#include 	<math.h>

#include 	"simstruc.h"

#ifdef 		MATLAB_MEX_FILE
#include 	"mex.h"
#else
#include 	<windows.h>
#include 	"io_xpcimport.h"
#endif

/* Input Arguments */
#define NUM_PARAMS             (5)
#define BASE_ADDRESS_ARG       (ssGetSFcnParam(S,0))
#define DEV_ARG                (ssGetSFcnParam(S,1))
#define CHANNEL_ARG            (ssGetSFcnParam(S,2))
#define RANGE_ARG              (ssGetSFcnParam(S,3))
#define SAMPLE_TIME_PARAM      (ssGetSFcnParam(S,4))

/* Convert S Function Parameters to Varibles */

#define BASE                   ((uint_T) mxGetPr(BASE_ADDRESS_ARG)[0])
#define DEVICE                 ((uint_T) mxGetPr(DEV_ARG)[0])
#define SAMPLE_TIME            ((real_T) mxGetPr(SAMPLE_TIME_PARAM)[0])
#define SAMPLE_OFFSET          ((real_T) mxGetPr(SAMPLE_TIME_PARAM)[1])
 

static char_T msg[256];


#ifndef MATLAB_MEX_FILE
unsigned short swapbytes(unsigned short x)
{
    return(((x>>8)&0xff)|(x<<8));
}


static void DA_Output(SimStruct *S, uint_T device, uint_T channel, real_T value, real_T range)
{
real_T out;

    
	
    if (range>0) {                               /* unipolar output */
        if (range==20) {                         /* 4-20 mA current output */
            out=256*(value-4);
        } else {                                 /* voltage output */
            out=4096*value/range;
        } 
    } else {                                     /* bipolar output */
        out=2048*(1-value/range); 
    }

    out=max(out,0);
    out=min(out,4095);
    out=floor(out+0.5);

	//printf("%f\n", out);

    if (device<10) {
        if (device==9 & channel==1) {            /* second D/A on PCL-1800 */
			//printf("base: %x, value: %d\n", BASE+26, (unsigned short)((uint_T)out)); 
            rl32eOutpW((unsigned short)(BASE+26),(unsigned short)((uint_T)out));
        } else {
        	//printf("base: %x, value: %d\n", BASE+4+2*channel, (unsigned short)((uint_T)out));  
            rl32eOutpW((unsigned short)(BASE+4+2*channel),(unsigned short)(((uint_T)out)<<4));
        }
    } else {
		//printf("base: %x, value: %d\n", BASE+2*channel, swapbytes((unsigned short)out));
        rl32eOutpW((unsigned short)(BASE+2*channel),swapbytes((unsigned short)out));        
		//rl32eOutpB((unsigned short)(BASE+2*channel),(((uint16_T)out)>>8)&0x0f);  
		//rl32eOutpB((unsigned short)(BASE+2*channel+1),((uint16_T)out)&0xff);
    }
}
#endif

/*====================*
 * S-function methods *
 *====================*/

static void mdlCheckParameters(SimStruct *S)
{
}

static void mdlInitializeSizes(SimStruct *S)
{
    uint_T i;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUM_PARAMS);
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
        mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL) {
            return;
        }
    } else {
        return; /* Parameter mismatch will be reported by Simulink */
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    if (!ssSetNumInputPorts(S, (mxGetNumberOfElements(CHANNEL_ARG)))) return;

    for (i=0;i<mxGetNumberOfElements(CHANNEL_ARG);i++) {
        ssSetInputPortWidth(S, i, 1);
		ssSetInputPortDirectFeedThrough(S, i, 1);
    }

    if (!ssSetNumOutputPorts(S, 0)) return;
 
    ssSetNumSampleTimes(S, 1);

    ssSetSFcnParamNotTunable(S,0);
    ssSetSFcnParamNotTunable(S,1);
    ssSetSFcnParamNotTunable(S,2);
    ssSetSFcnParamNotTunable(S,3);
    ssSetSFcnParamNotTunable(S,4);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, SAMPLE_TIME);
    ssSetOffsetTime(S, 0, SAMPLE_OFFSET);
}


#define MDL_START
static void mdlStart(SimStruct *S)
{
 
#ifndef MATLAB_MEX_FILE
    uint_T i;

/* Set initial outputs to zero */
    for (i=0;i<mxGetNumberOfElements(CHANNEL_ARG);i++) {
	    DA_Output(S, DEVICE, (uint_T)mxGetPr(CHANNEL_ARG)[i]-1, 0.0, mxGetPr(RANGE_ARG)[i]);
    }
  
#endif /* MATLAB_MEX_FILE */

}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE

InputRealPtrsType uPtrs;
uint_T i;

    for (i=0;i<mxGetNumberOfElements(CHANNEL_ARG);i++) {
        uPtrs = ssGetInputPortRealSignalPtrs(S,i);
        DA_Output(S, DEVICE, (uint_T)mxGetPr(CHANNEL_ARG)[i]-1, *uPtrs[0], mxGetPr(RANGE_ARG)[i]);
    }

#endif /* MATLAB_MEX_FILE */

}


static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
    uint_T i;

/* Set final outputs to zero */
    for (i=0;i < mxGetNumberOfElements(CHANNEL_ARG);i++) {
    	DA_Output(S, DEVICE, (uint_T)mxGetPr(CHANNEL_ARG)[i]-1, 0.0, mxGetPr(RANGE_ARG)[i]);
    }
  
#endif /* MATLAB_MEX_FILE */
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
