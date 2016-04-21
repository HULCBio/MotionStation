/* $Revision: 1.3 $ $Date: 2002/03/25 03:59:36 $ */
/* addiamondmmx.c - xPC Target, non-inlined S-function driver for A/D section of Diamond Systems MM-x series boards  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME 	addiamondmmx

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
#define NUMBER_OF_ARGS          (10)
#define STARTCHANNEL_ARG        ssGetSFcnParam(S,0)
#define NCHANNEL_ARG            ssGetSFcnParam(S,1)
#define RANGE_ARG            	ssGetSFcnParam(S,2)
#define GAIN_ARG            	ssGetSFcnParam(S,3)
#define OFFSET_ARG            	ssGetSFcnParam(S,4)
#define CONTROL_ARG            	ssGetSFcnParam(S,5)
#define MUX_ARG            		ssGetSFcnParam(S,6)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,7)
#define BASE_ARG             	ssGetSFcnParam(S,8)
#define DEV_ARG             	ssGetSFcnParam(S,9)

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

	ssSetNumOutputPorts(S, (int_T)mxGetPr(NCHANNEL_ARG)[0]);
	for (i=0; i<(int_T)mxGetPr(NCHANNEL_ARG)[0]; i++) {
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
	ssSetSFcnParamNotTunable(S,9);

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
	numChannels= (int_T)mxGetPr(NCHANNEL_ARG)[0];
	range= (int_T)mxGetPr(RANGE_ARG)[0];
	mux= (int_T)mxGetPr(MUX_ARG)[0];
		
	switch ((int_T)mxGetPr(DEV_ARG)[0]) {
		case 1:
			strcpy(devName,"Diamond MM-32");
			break;
	}

	/* disable interrupts and ... */
	rl32eOutpB((unsigned short)(baseAddr+0x09),(unsigned short)0x00);

	/* enable scan mode */
	rl32eOutpB((unsigned short)(baseAddr+0x07),(unsigned short)0x06);

	/* set MUX start and stop channel */
    rl32eOutpB((unsigned short)(baseAddr+0x02),(unsigned short)(mxGetPr(STARTCHANNEL_ARG)[0]-1));
    rl32eOutpB((unsigned short)(baseAddr+0x03),(unsigned short)(mxGetPr(STARTCHANNEL_ARG)[0]-1)+(unsigned short)(numChannels-1));


	/* set GAIN and conversion speed */
	rl32eOutpB((unsigned short)(baseAddr+0x0b),(unsigned short)0x20 | (unsigned short)mxGetPr(CONTROL_ARG)[0]);

	/* wait for the analog input circuitry to settle */
	while (rl32eInpB(baseAddr+0x0b) & 0x80);

#endif
                 
}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

    uint_T baseAddr= (uint_T)mxGetPr(BASE_ARG)[0];
    uint_T numChannels = (int_T)mxGetPr(NCHANNEL_ARG)[0];
    real_T gain = mxGetPr(GAIN_ARG)[0];
    real_T offset = mxGetPr(OFFSET_ARG)[0];
    int16_T res;
	uint_T i;
	real_T *y;


	/* start scan */
	rl32eOutpB((unsigned short)(baseAddr+0x00),(unsigned short)0x00);
	
    for (i=0; i<numChannels; i++) {
		int k=0;
		y=ssGetOutputPortSignal(S,i);
        /* wait until FIFO contains data */
        while ((rl32eInpB((unsigned short)(baseAddr+0x7)) & 0x80)) k++;
        /* get value */
		res= rl32eInpW((unsigned short)(baseAddr+0x00)) & 0xffff;
        y[0]=res* gain - offset; 		    
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


