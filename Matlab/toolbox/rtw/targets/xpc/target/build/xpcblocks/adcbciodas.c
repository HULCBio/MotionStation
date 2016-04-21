/* $Revision: 1.7 $ $Date: 2002/03/25 03:59:21 $ */
/* adcbciodas.c - xPC Target, non-inlined S-function driver for A/D section of CB CIO-DAS series boards  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME 	adcbciodas

#include 	<stddef.h>
#include 	<stdlib.h>

#include 	"simstruc.h" 

#ifdef 		MATLAB_MEX_FILE
#include 	"mex.h"
#endif

#ifndef 	MATLAB_MEX_FILE
#include 	<windows.h>
#include 	"io_xpcimport.h"
#endif


/* Input Arguments */
#define NUMBER_OF_ARGS          (9)
#define CHANNEL_ARG             ssGetSFcnParam(S,0)
#define RANGE_ARG            	ssGetSFcnParam(S,1)
#define GAIN_ARG            	ssGetSFcnParam(S,2)
#define OFFSET_ARG            	ssGetSFcnParam(S,3)
#define CONTROL_ARG            	ssGetSFcnParam(S,4)
#define MUX_ARG            		ssGetSFcnParam(S,5)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,6)
#define BASE_ARG             	ssGetSFcnParam(S,7)
#define DEV_ARG             	ssGetSFcnParam(S,8)

#define SAMP_TIME_IND           (0)

#define NO_I_WORKS              (0)

#define NO_R_WORKS              (0)


static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{

	uint_T i;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
		sprintf(msg,"Wrong number of input arguments passed.\n%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

	ssSetNumOutputPorts(S, (int_T)mxGetPr(CHANNEL_ARG)[0]);
	for (i=0; i<(int_T)mxGetPr(CHANNEL_ARG)[0]; i++) {
		ssSetOutputPortWidth(S, i, 1);
	}

    ssSetNumInputPorts(S, 0);

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
	ssSetSFcnParamNotTunable(S,4);
	ssSetSFcnParamNotTunable(S,5);
	ssSetSFcnParamNotTunable(S,6);
	ssSetSFcnParamNotTunable(S,7);
	ssSetSFcnParamNotTunable(S,8);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
	
        
}


 
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME_ARG)[SAMP_TIME_IND]);
    ssSetOffsetTime(S, 0, 0.0);
}
 

#define MDL_START
static void mdlStart(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE


  	int_T numChannels; 
    int_T control, i, status, range, mux;
	uint_T baseAddr;
   	char devName[20];

    baseAddr= (uint_T)mxGetPr(BASE_ARG)[0];
	numChannels= (int_T)mxGetPr(CHANNEL_ARG)[0];
	range= (int_T)mxGetPr(RANGE_ARG)[0];
	mux= (int_T)mxGetPr(MUX_ARG)[0];

	status=(int_T)rl32eInpB((unsigned short)(baseAddr+0x8));
		
	switch ((int_T)mxGetPr(DEV_ARG)[0]) {
		case 1:
			strcpy(devName,"CB CIO-DAS16/JR");
			break;
		case 2:
			strcpy(devName,"CB CIO-DAS1601/12");
			if (range<5) { // Bipolar
				if ( (status & 0x40) == 0x40 ) {
    				sprintf(msg,"%s (0x%x): Polarity switch is not set to 'Bipolar'", devName, baseAddr);
					ssSetErrorStatus(S,msg);
            		return;
      			}
			} else {
				if ( (status & 0x40) == 0x00 ) {
    				sprintf(msg,"%s (0x%x): Polarity switch is not set to 'Unipolar'", devName, baseAddr);
					ssSetErrorStatus(S,msg);
            		return;
      			}
			}	
			break;
		case 3:
			strcpy(devName,"CB CIO-DAS1602/12");
			if (range<5) { // Bipolar
				if ( (status & 0x40) == 0x40 ) {
    				sprintf(msg,"%s (0x%x): Polarity switch is not set to 'Bipolar'", devName, baseAddr);
					ssSetErrorStatus(S,msg);
            		return;
      			}
			} else {
				if ( (status & 0x40) == 0x00 ) {
    				sprintf(msg,"%s (0x%x): Polarity switch is not set to 'Unipolar'", devName, baseAddr);
					ssSetErrorStatus(S,msg);
            		return;
      			}
			}	
			break;
		case 4:
			strcpy(devName,"CB CIO-DAS16/330");
			break;
		case 5:
			strcpy(devName,"CB PC104-DAS16JR/12");
			break;
		case 6:
			strcpy(devName,"CB CIO-DAS16JR/16");
			break;
		case 7:
			strcpy(devName,"CB CIO-DAS1602/16");
			if (range<5) { // Bipolar
				if ( (status & 0x40) == 0x40 ) {
    				sprintf(msg,"%s (0x%x): Polarity switch is not set to 'Bipolar'", devName, baseAddr);
					ssSetErrorStatus(S,msg);
            		return;
      			}
			} else {
				if ( (status & 0x40) == 0x00 ) {
    				sprintf(msg,"%s (0x%x): Polarity switch is not set to 'Unipolar'", devName, baseAddr);
					ssSetErrorStatus(S,msg);
            		return;
      			}
			}	
			break;
		case 8:
			strcpy(devName,"CB PC104-DAS16JR/16");
			break;
	}

	if (mux==1) { // Single-ended
		if ( (status & 0x20) == 0x00 ) {
			sprintf(msg,"%s (0x%x): MUX switch is not set to 'single-ended'", devName, baseAddr);
			ssSetErrorStatus(S,msg);
    		return;
		}
	} else {
		if ( (status & 0x20) == 0x20 ) {
			sprintf(msg,"%s (0x%x): MUX switch is not set to 'differential'", devName, baseAddr);
			ssSetErrorStatus(S,msg);
    		return;
		}
	}	
	

    rl32eOutpB((unsigned short)(baseAddr+0xb),(unsigned short)((int_T)mxGetPr(CONTROL_ARG)[0]));

    /* no DMA, Software triggered A/D, interrupts disabled */
    rl32eOutpB((unsigned short)(baseAddr+0x9), 0x0);

    // test A/D conversion
    rl32eOutpB((unsigned short)(baseAddr+0x0), 0x0);
    i=0;
    while ((rl32eInpB((unsigned short)(baseAddr+0x8)) & 0x80) == 0x80 ) {
    	if (100<i++) {
    		sprintf(msg,"%s (0x%x): test A/D conversion failed", devName, baseAddr);
			ssSetErrorStatus(S,msg);
            return;
      	}
   	}

    /* set MUX start and stop channel */
    rl32eOutpB((unsigned short)(baseAddr+0x2),(unsigned short)((numChannels-1)<<4));

#endif
                 
}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

    uint_T baseAddr= (uint_T)mxGetPr(BASE_ARG)[0];
    uint_T numChannels = (int_T)mxGetPr(CHANNEL_ARG)[0];
    real_T gain = mxGetPr(GAIN_ARG)[0];
    real_T offset = mxGetPr(OFFSET_ARG)[0];
    uint_T i, res;
	real_T *y;
	
    for (i=0; i<numChannels; i++) {
		y=ssGetOutputPortSignal(S,i);
		/* start conversion */
        rl32eOutpB((unsigned short)(baseAddr+0x0),0x0);
        /* wait until conversion finished */
        while ((rl32eInpB((unsigned short)(baseAddr+0x8)) & 0x80) == 0x80 );
        /* get value */
		if ((int_T)mxGetPr(DEV_ARG)[0] <6) { //12bit
        	res=(0xfff0 & rl32eInpW((unsigned short)(baseAddr+0x0))) >>4;
		} else { //16bit
			res= rl32eInpW((unsigned short)(baseAddr+0x0));
		}
        y[0]=res*gain-offset; 
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


