/* $Revision: 1.3 $ $Date: */
/* dovsbc6.c - xPC Target, non-inlined S-function driver for digital I/O section of VSBC-6 SBC from Versalogic  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/


//#define DEBUG


#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME srapexpc12sd

#include 	<stddef.h>
#include 	<stdlib.h>
#include 	<string.h>

#include 	"tmwtypes.h"
#include 	"simstruc.h" 

#ifdef MATLAB_MEX_FILE
#include 	"mex.h"
#else
#include 	<windows.h>
#include 	"io_xpcimport.h"
#include 	"time_xpcimport.h"

#endif

#define 	NUMBER_OF_ARGS        	(9)
#define 	CHANNEL_ARG         	ssGetSFcnParam(S,0)
#define     SRTYPE_ARG				ssGetSFcnParam(S,1)
#define 	RATIO_ARG				ssGetSFcnParam(S,2)
#define 	OUTPUT_ARG				ssGetSFcnParam(S,3)
#define 	SCALE_ENABLE_ARG		ssGetSFcnParam(S,4)
#define 	VELOC_SCALE_ARG 		ssGetSFcnParam(S,5)
#define 	REF_ARG					ssGetSFcnParam(S,6)
#define 	SAMP_TIME_ARG          	ssGetSFcnParam(S,7)
#define 	BASE_ADDR_ARG           ssGetSFcnParam(S,8)


#define 	SAMP_TIME_IND           (0)

#define 	NO_I_WORKS             	(0)

#define 	NO_R_WORKS              (0)

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
	int_T i;
	int_T nwidth;

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

    ssSetNumOutputPorts(S, mxGetN(CHANNEL_ARG));
	switch ((uint16_T)mxGetPr(OUTPUT_ARG)[0]) {
		case 1:
			nwidth=1;
			break;
		case 2:
		case 3:
			nwidth=2;
			break;
		case 4:
			nwidth=3;
			break;
	} 
	for (i=0;i<mxGetN(CHANNEL_ARG);i++) {
		ssSetOutputPortWidth(S, i, nwidth);
	}

	if ((uint16_T)mxGetPr(SCALE_ENABLE_ARG)[0]) {
		ssSetNumInputPorts(S, mxGetN(CHANNEL_ARG));
		for (i=0;i<mxGetN(CHANNEL_ARG);i++) {
			ssSetInputPortWidth(S, i, 1);
			ssSetInputPortDirectFeedThrough(S, i, 1);
		}
	} else {
		ssSetNumInputPorts(S, 0);
	}

    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumPWork(S, 0);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

	for (i=0;i<NUMBER_OF_ARGS;i++) {
		ssSetSFcnParamNotTunable(S,i);
	}

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
        
}
 
static void mdlInitializeSampleTimes(SimStruct *S)
{    
   	ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME_ARG)[SAMP_TIME_IND]);
    if (mxGetN((SAMP_TIME_ARG))==1) {
		ssSetOffsetTime(S, 0, 0.0);
	} else {
       	ssSetOffsetTime(S, 0, mxGetPr(SAMP_TIME_ARG)[1]);
	}

}

#define MDL_START 
static void mdlStart(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE

	uint_T baseAddr, i;
	uint_T tmp, channel;
	uint16_T actChannels, srTypes, type, ratios, velocScale, refFreq, refVolt;

	baseAddr= (uint_T)mxGetPr(BASE_ADDR_ARG)[0];

	// soft reset

	/* activate page 4 */
	/*
	rl32eOutpB(baseAddr+0x1e, 0x05);
	rl32eOutpW(baseAddr+0x1c, 0x0001);
	rl32eWaitDouble(1.0);
	rl32eOutpW(baseAddr+0x1c, 0x0000);
	rl32eWaitDouble(1.0);
	*/

	/* activate page 3 */
	rl32eOutpB(baseAddr+0x1e, 0x02);
	/* read part number */
	tmp=rl32eInpW(baseAddr+0x0c);
	//printf("P/N: %x\n",tmp);
	/* read serial number */
	//printf("S/N: %x\n",rl32eInpW(baseAddr+0x0e));


	/* activate channels */
	actChannels=0x0000;
	for (i=0;i<mxGetN(CHANNEL_ARG);i++) {
		channel= (uint16_T)mxGetPr(CHANNEL_ARG)[i];
		actChannels|= 1 << (channel-1);
	}
	/* activate page 3 */
	rl32eOutpB(baseAddr+0x1e, 0x02);
	/* write channels */
	rl32eOutpW(baseAddr+0x14, actChannels);


	/* set S/R type */
	if ( mxGetN(SRTYPE_ARG) != 0 ) {
 		srTypes=0x0000;
		for (i=0;i<mxGetN(CHANNEL_ARG);i++) {
			channel= (uint16_T)mxGetPr(CHANNEL_ARG)[i];
			type= (uint16_T)mxGetPr(SRTYPE_ARG)[i];
			srTypes|= type << (channel-1);
		}
		/* activate page 2 */
		rl32eOutpB(baseAddr+0x1e, 0x01);
		/* write types */
		rl32eOutpW(baseAddr+0x1c, srTypes);
	}


   
  	/* set ratios */
	/* activate page 3 */
	rl32eOutpB(baseAddr+0x1e, 0x02);
  	for (i=0;i<mxGetN(CHANNEL_ARG);i++) {
  		channel= (uint16_T)mxGetPr(CHANNEL_ARG)[i];
  		ratios= (uint16_T)mxGetPr(RATIO_ARG)[i];
  		/* write ratios */
		//printf("%d\n",((channel-1) / 2) *2);
  		rl32eOutpW(baseAddr+(((channel-1) / 2) *2), ratios);
	}

	/* set velocity scale */
	if ( mxGetN(VELOC_SCALE_ARG) != 0  ) {
	  	/* activate page 6 */
	  	rl32eOutpB(baseAddr+0x1e, 0x05);
		for (i=0;i<mxGetN(CHANNEL_ARG);i++) {
	  		channel= (uint16_T)mxGetPr(CHANNEL_ARG)[i];
	  		velocScale= (uint16_T)(4095*150/mxGetPr(VELOC_SCALE_ARG)[i]);
			/* write velocity scales */
	  		rl32eOutpW(baseAddr+(channel-1)*2, velocScale);
		}
	}


	/* reference */
	if ( mxGetN(REF_ARG) != 0 ) {
	  	/* activate page 2 */
	  	rl32eOutpB(baseAddr+0x1e, 0x01);
		refFreq= mxGetPr(REF_ARG)[0];
		refVolt= mxGetPr(REF_ARG)[1];
		rl32eOutpW(baseAddr+0x1a, (uint16_T)(refVolt/0.1));
		rl32eOutpW(baseAddr+0x18, (uint16_T)(refFreq));
	}


#endif

    

}
	

static void mdlOutputs(SimStruct *S, int_T tid)
{

 	uint_T baseAddr;
    int_T i;
    int_T channel;
	real_T  *y;
	InputRealPtrsType uPtrs;
	uint16_T angle, outputFormat, testStatus, signalStatus, refStatus, index, velocScale; 
	int16_T veloc;

	
#ifndef MATLAB_MEX_FILE


	baseAddr=(uint_T)mxGetPr(BASE_ADDR_ARG)[0];

	/* latch channels */
	/* activate page 3 */
	rl32eOutpB(baseAddr+0x1e, 0x02);
	rl32eOutpB(baseAddr+0x1c, 0x02);

	/* read angle */
	/* activate page 1 */
	rl32eOutpB(baseAddr+0x1e, 0x00);
  	for (i=0;i<mxGetN(CHANNEL_ARG);i++) {
		y=ssGetOutputPortSignal(S,i);
  		channel= (uint16_T)mxGetPr(CHANNEL_ARG)[i];
		/* read angle */
		if ((uint16_T)mxGetPr(RATIO_ARG)[i]==1) {
			angle= rl32eInpW(baseAddr+(channel-1)*2);
		} else {
			angle= rl32eInpW(baseAddr+(channel-1)*4+2);
		}
		y[0]=(real_T)angle * 4.793763109162727e-005;
#ifdef DEBUG
		printf("angle of channel %d: %f\n",channel,y[0]);
#endif
	}

	/* read status */
	outputFormat= (uint16_T)mxGetPr(OUTPUT_ARG)[0];
	if (outputFormat==2 || outputFormat==4) {
		testStatus=   rl32eInpW(baseAddr+0x1c);
		signalStatus= rl32eInpW(baseAddr+0x18);
		refStatus=    rl32eInpW(baseAddr+0x1a);
#ifdef DEBUG
		printf("test: %x, signal: %x, ref: %x\n", testStatus, signalStatus, refStatus);
#endif

		for (i=0;i<mxGetN(CHANNEL_ARG);i++) {
			y=ssGetOutputPortSignal(S,i);
			channel= (uint16_T)mxGetPr(CHANNEL_ARG)[i];	
			if (outputFormat==2) {
				index=1;
			} else {
				index=2;
			}
			if (mxGetN(REF_ARG) == 0) {
#ifdef DEBUG
				printf("without ref\n");
#endif
				y[index]=(real_T)( ((~testStatus >> (channel-1)) & 0x01) | ((~signalStatus >> (channel-1)) & 0x01)<<1 );
			} else { 
#ifdef DEBUG
				printf("with ref\n");
#endif
				y[index]=(real_T)(((~testStatus >> (channel-1)) & 0x01) | ((~signalStatus >> (channel-1)) & 0x01)<<1 | ((~refStatus >> (channel-1)) & 0x01)<<2);
			}
#ifdef DEBUG
			printf("status of channel %d: %f\n",channel,y[index]);
#endif
		}
	}
				
	/* read velocity if required */
	if (outputFormat >2) {
  		for (i=0;i<mxGetN(CHANNEL_ARG);i++) {
			y=ssGetOutputPortSignal(S,i);
  			channel= (uint16_T)mxGetPr(CHANNEL_ARG)[i];
			if ((uint16_T)mxGetPr(SCALE_ENABLE_ARG)[0]) {
				uPtrs=ssGetInputPortRealSignalPtrs(S,i);
				velocScale= (uint16_T)(4095*150/ *uPtrs[0]);
	  			/* activate page 6 */
	  			rl32eOutpB(baseAddr+0x1e, 0x05);
				/* write velocity scale */
	  			rl32eOutpW(baseAddr+(channel-1)*2, velocScale);
			}
			/* activate page 2 */
	  		rl32eOutpB(baseAddr+0x1e, 0x01);
			veloc= (int16_T)rl32eInpW(baseAddr+(channel-1)*2);
			y[1]=(real_T)veloc;
#ifdef DEBUG
			printf("velocity of channel %d: %f\n",channel,y[1]);
#endif
		}
	}

#ifdef DEBUG
		printf("exiting\n");
#endif


	
#endif        
}

static void mdlTerminate(SimStruct *S)
{


}

#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

