/* $Revision: 1.3 $ $Date: 2002/03/25 03:59:03 $ */
/* adadvpcl812.c - xPC Target, non-inlined S-function driver for A/D section of Advantech PCL-812 series boards  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME 	adadvpcl812

#include 	<stddef.h>
#include 	<stdlib.h>

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
#define SAMPLE_TIME            ((real_T) mxGetPr(SAMPLE_TIME_PARAM)[0])
#define SAMPLE_OFFSET          ((real_T) mxGetPr(SAMPLE_TIME_PARAM)[1])


static char_T msg[256];


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

	

    if (!ssSetNumInputPorts(S, 0)) return;

    if (!ssSetNumOutputPorts(S, mxGetNumberOfElements(CHANNEL_ARG))) return;

    for (i=0;i<mxGetNumberOfElements(CHANNEL_ARG);i++) {
        ssSetOutputPortWidth(S, i, 1);
    }

    ssSetNumSampleTimes(S, 1);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

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


    uint_T i, channel;
    char devName[20];

    switch ((int_T)mxGetPr(DEV_ARG)[0]) {
        case 1:
            strcpy(devName,"Advantech PCL-812");
            break;
        case 2:
            strcpy(devName,"Advantech PCL-812PG");
           break;
        case 3:
            strcpy(devName,"Advantech PCL-711B");
            break;
	}

    /* Check That The Hardware is functioning */

    /* Setup ADCTRL Parameters */
    rl32eOutpB(BASE+11,0);          /* set disabled mode */
    rl32eOutpB(BASE+8,0);           /* clear interrupt */
    rl32eInpW(BASE+4);              /* dummy read from A/D */
    rl32eOutpB(BASE+11,1);          /* enable software trigger */

    if (!(rl32eInpB(BASE+5) & 0x10)) { /* if data ready, error */
        sprintf(msg,"%s (0x%x): test A/D conversion failed", devName, BASE);
        ssSetErrorStatus(S,msg);
        return;
    }

    rl32eOutpB(BASE+12,0);          /* try the conversion */
    for (i=0;i<0x10000;i++) {
        if (!(rl32eInpB(BASE+5) & 0x10)) break;
        if (i==0x10000) {           /* if no conversion, error */
            sprintf(msg,"%s (0x%x): test A/D conversion failed", devName, BASE);
            ssSetErrorStatus(S,msg);
            return;
        }
    }

    rl32eInpW(BASE+4);               /* read data */
    rl32eOutpB(BASE+8,0);            /* clear interrupt */
    if (!(rl32eInpB(BASE+5) & 0x10))  { /* if data still ready, error */
        sprintf(msg,"%s (0x%x): test A/D conversion failed", devName, BASE);
        ssSetErrorStatus(S,msg);
        return;
    }

#endif
                 
}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

    uint_T i, n, channel;
    uint_T baseAddr = BASE;
    real_T *y, range, res;
	
    for (i=0;i<mxGetNumberOfElements(CHANNEL_ARG);i++) {
        channel=(uint_T)mxGetPr(CHANNEL_ARG)[i]-1;
        y=ssGetOutputPortSignal(S,i);
        range=mxGetPr(RANGE_ARG)[i];

        rl32eOutpB(baseAddr+10,channel);             /* select channel */
        if ((int_T)mxGetPr(DEV_ARG)[0]!=1) {         /* not PCL-812 */
            switch ((int_T)(1000*mxGetPr(RANGE_ARG)[i])) {
                case -10000:
                    rl32eOutpB(BASE+9,0);
                    break;
                case -5000:
                    rl32eOutpB(BASE+9,1);
                    break;
                case -2500:
                    rl32eOutpB(BASE+9,2);
                    break;
                case -1250:
                    rl32eOutpB(BASE+9,3);
                    break;
                case 625:
                    rl32eOutpB(BASE+9,4);
                    break;
            }
        }

        rl32eOutpB(baseAddr+12,0);                   /* start conversion */
        while (rl32eInpB(baseAddr+5) & 0x10);        /* wait until data ready */
        res=rl32eInpW(baseAddr+4)&0x0FFF;            /* read data */
        rl32eOutpB(baseAddr+8,0);                    /* clear interrupt request */
        if (range>0) {                               /* unipolar input */
            y[0]=range*res/4096; 
        } else {                                     /* bipolar input */
            y[0]=range*(1-res/2048); 
        }
    }

#endif
        	        
}

static void mdlTerminate(SimStruct *S)
{   
}


#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif


