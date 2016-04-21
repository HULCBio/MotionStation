/* $Revision: 1.4 $ $Date: 2002/03/25 03:59:06 $ */
/* adadvpcl818.c - xPC Target, non-inlined S-function driver for A/D section of Advantech PCL-818 series boards  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME 	adadvpcl818

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
#define NUM_PARAMS             (6)
#define BASE_ADDRESS_ARG       (ssGetSFcnParam(S,0))
#define DEV_ARG                (ssGetSFcnParam(S,1))
#define CHANNEL_ARG            (ssGetSFcnParam(S,2))
#define RANGE_ARG              (ssGetSFcnParam(S,3))
#define MUX_ARG                (ssGetSFcnParam(S,4))
#define SAMPLE_TIME_PARAM      (ssGetSFcnParam(S,5))

/* Convert S Function Parameters to Varibles */

#define BASE                   ((uint_T) mxGetPr(BASE_ADDRESS_ARG)[0])
#define SAMPLE_TIME            ((real_T) mxGetPr(SAMPLE_TIME_PARAM)[0])
#define SAMPLE_OFFSET          ((real_T) mxGetPr(SAMPLE_TIME_PARAM)[1])


static char_T msg[256];
static char MuxDelay[16]={1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1};


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
    ssSetSFcnParamNotTunable(S,5);

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
            strcpy(devName,"Advantech PCL-818");
            break;
        case 2:
            strcpy(devName,"Advantech PCL-818L");
           break;
        case 3:
            strcpy(devName,"Advantech PCL-818H");
            break;
        case 4:
            strcpy(devName,"Advantech PCL-818HD");
            break;
        case 5:
            strcpy(devName,"Advantech PCL-818HG");
            break;
        case 9:
            strcpy(devName,"Advantech PCL-1800");
            break;
	}

    /* Check That The Hardware is functioning */

    /* Setup ADCTRL Parameters */
    rl32eOutpB((unsigned short)(BASE+9),0);           /* set disabled mode */
    if ((int_T)mxGetPr(DEV_ARG)[0]==9) {    /* PCL-1800 */
        rl32eOutpB((unsigned short)(BASE+30),0);      /* flush the FIFO */
    }
    rl32eOutpB((unsigned short)(BASE+6),0);           /* disable FIFO interrupts */
    rl32eOutpB((unsigned short)(BASE+10),0);          /* set pacer & ext. counter */
    rl32eOutpB((unsigned short)(BASE+8),0);           /* reset any interrupt request */
    rl32eInpW((unsigned short)(BASE+0));              /* dummy read from A/D */

    rl32eOutpB((unsigned short)BASE,0);             /* enable software trigger */
    if (rl32eInpB((unsigned short)(BASE+8)) & 0x10) { /* if data ready, error */
        sprintf(msg,"%s (0x%x): test A/D conversion failed", devName, BASE);
        ssSetErrorStatus(S,msg);
        return;
    }

    rl32eOutpB((unsigned short)BASE,0);             /* try the conversion */
    for (i=0;i<0x10000;i++) {
        if (rl32eInpB((unsigned short)(BASE+8)) & 0x10) break;
        if (i==0x10000) {           /* if no conversion, error */
            sprintf(msg,"%s (0x%x): test A/D conversion failed", devName, BASE);
            ssSetErrorStatus(S,msg);
            return;
        }
    }

    rl32eInpW((unsigned short)(BASE+0));
    rl32eOutpB((unsigned short)(BASE+8),0);            /* clear interrupt request */
    if (rl32eInpB((unsigned short)(BASE+8)) & 0x10)  { /* if data still ready, error */
        sprintf(msg,"%s (0x%x): test A/D conversion failed", devName, BASE);
        ssSetErrorStatus(S,msg);
        return;
    }

    switch ((int_T)mxGetPr(MUX_ARG)[0]) {
        case 1:
            if (!(rl32eInpB((unsigned short)(BASE+8)) & 0x20))  { /* input mux error */
                sprintf(msg,"%s (0x%x): set input mux to single-ended", devName, BASE);
                ssSetErrorStatus(S,msg);
                return;
            }
            break; 
        case 2:
            if (rl32eInpB((unsigned short)(BASE+8)) & 0x20)  { /* input mux error */
                sprintf(msg,"%s (0x%x): set input mux to differential", devName, BASE);
                ssSetErrorStatus(S,msg);
                return;
            }
            break;
	}

    /* set input gains */
    for (i=0;i<mxGetNumberOfElements(CHANNEL_ARG);i++) {
        channel=(uint_T)mxGetPr(CHANNEL_ARG)[i]-1;
        rl32eOutpB((unsigned short)(BASE+2),(unsigned short)(0x11*channel));
        if ((int_T)mxGetPr(DEV_ARG)[0]==5) {               /* PCL-818HG */
            switch ((int_T)(1000*mxGetPr(RANGE_ARG)[i])) {
                case -5000:
                    rl32eOutpB((unsigned short)(BASE+1),0);
                    MuxDelay[channel]=3;
                    break;
                case -500:
                    rl32eOutpB((unsigned short)(BASE+1),1);
                    MuxDelay[channel]=3;
                    break;
                case -50:
                    rl32eOutpB((unsigned short)(BASE+1),2);
                    MuxDelay[channel]=15;
                    break;
                case -5:
                    rl32eOutpB((unsigned short)(BASE+1),3);
                    MuxDelay[channel]=100;
                    break;
                case 10000:
                    rl32eOutpB((unsigned short)(BASE+1),4);
                    MuxDelay[channel]=3;
                    break;
                case 1000:
                    rl32eOutpB((unsigned short)(BASE+1),5);
                    MuxDelay[channel]=3;
                    break;
                case 100:
                    rl32eOutpB((unsigned short)(BASE+1),6);
                    MuxDelay[channel]=15;
                    break;
                case 10:
                    rl32eOutpB((unsigned short)(BASE+1),7);
                    MuxDelay[channel]=100;
                    break;
                case -10000:
                    rl32eOutpB((unsigned short)(BASE+1),8);
                    MuxDelay[channel]=3;
                    break;
                case -1000:
                    rl32eOutpB((unsigned short)(BASE+1),9);
                    MuxDelay[channel]=3;
                    break;
                case -100:
                    rl32eOutpB((unsigned short)(BASE+1),10);
                    MuxDelay[channel]=15;
                    break;
                case -10:
                    rl32eOutpB((unsigned short)(BASE+1),11);
                    MuxDelay[channel]=100;
                    break;
            }
        } else {
            switch ((int_T)(1000*mxGetPr(RANGE_ARG)[i])) {
                case -5000:
                    rl32eOutpB((unsigned short)(BASE+1),0);
                    break;
                case -2500:
                    rl32eOutpB((unsigned short)(BASE+1),1);
                    break;
                case -1250:
                    rl32eOutpB((unsigned short)(BASE+1),2);
                    break;
                case -625:
                    rl32eOutpB((unsigned short)(BASE+1),3);
                    break;
                case 10000:
                    rl32eOutpB((unsigned short)(BASE+1),4);
                    break;
                case 5000:
                    rl32eOutpB((unsigned short)(BASE+1),5);
                    break;
                case 2500:
                    rl32eOutpB((unsigned short)(BASE+1),6);
                    break;
                case 1250:
                    rl32eOutpB((unsigned short)(BASE+1),7);
                    break;
                case -10000:
                    rl32eOutpB((unsigned short)(BASE+1),8);
                    break;
            }
        }
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

        if ((rl32eInpB((unsigned short)(baseAddr+8)) & 0x0F)!=channel); {      /* channel not set */
            rl32eOutpB((unsigned short)(baseAddr+2),(unsigned short)(0x11*channel));             /* select channel */
            for (n=0;n<MuxDelay[channel];n++) {              /* n dummy conversions */
                rl32eOutpB((unsigned short)baseAddr,0);                      /* start conversion */
                while (!(rl32eInpB((unsigned short)(baseAddr+8)) & 0x10));     /* wait until data ready */
                rl32eInpW((unsigned short)baseAddr);                         /* read data */
                rl32eOutpB((unsigned short)(baseAddr+8),0);                    /* clear interrupt request */
            }
        }
        rl32eOutpB((unsigned short)(baseAddr+2),(unsigned short)(0x11*channel));         /* select channel */
        if ((int_T)mxGetPr(DEV_ARG)[0]==9) {         /* PCL-1800 */
            rl32eOutpB((unsigned short)(BASE+30),0);                   /* flush the FIFO */
        }
        rl32eOutpB((unsigned short)baseAddr,0);                      /* start conversion */
        if ((int_T)mxGetPr(DEV_ARG)[0]!=5) {         /* if not PCL-818HG */
            rl32eOutpB((unsigned short)(baseAddr+2),(unsigned short)(0x11*((uint_T) mxGetPr(CHANNEL_ARG)[(i+1)%mxGetNumberOfElements(CHANNEL_ARG)]-1)));  /* select next channel */
        }
        while (!(rl32eInpB((unsigned short)(baseAddr+8)) & 0x10));     /* wait until data ready */
        res=rl32eInpW((unsigned short)baseAddr)>>4;                  /* read data */
        rl32eOutpB((unsigned short)(baseAddr+8),0);                    /* clear interrupt request */
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


