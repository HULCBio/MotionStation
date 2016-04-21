/* $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:01:36 $ */
/* can527receive.c - xPC Target, non-inlined S-function driver for Intel 82527 */
/* Copyright 1994-2004 The MathWorks, Inc. */

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME can527receive

#include 	<stddef.h>
#include 	<stdlib.h>
#include 	<string.h>

#include 	"tmwtypes.h"
#include 	"simstruc.h" 

#ifdef MATLAB_MEX_FILE
#include 	"mex.h"
#else
#include 	<windows.h>
#include 	"time_xpcimport.h"
#include 	"io_xpcimport.h"
#include	"canxpc527.h"
#endif

#define 	NUMBER_OF_ARGS        	(6)
#define 	CANIDS_ARG         		ssGetSFcnParam(S,0)
#define 	CANSIZE_ARG         	ssGetSFcnParam(S,1)
#define 	COUNT_ARG         		ssGetSFcnParam(S,2)
#define 	OUTPORT_ARG         	ssGetSFcnParam(S,3)
#define 	SAMP_TIME_ARG          	ssGetSFcnParam(S,4)
#define		CANINDEX_ARG          	ssGetSFcnParam(S,5)


#define 	SAMP_TIME_IND           (0)

#define 	NO_I_WORKS             	(1)

#define 	NO_R_WORKS              (0)

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
	int_T num_channels, i;

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

	ssSetNumOutputPorts(S, mxGetN(CANIDS_ARG));
	for (i=0;i<mxGetN(CANIDS_ARG);i++) {
		ssSetOutputPortWidth(S, i, (int_T)mxGetPr(OUTPORT_ARG)[0]);
		//ssSetInputPortDirectFeedThrough(S, i, 1);
		//ssSetInputPortRequiredContiguous(S, i, 1);
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

	uint16_T resourceReg, baseAddr, presc, tsync, tseg1, tseg2, i;

	resourceReg= (uint16_T)rl32eInpB(0x804);
    switch (resourceReg & 0xf) {
	case 1:
		baseAddr= 0x1000;
		break;
	case 2:
		baseAddr= 0x8000;
		break;
	case 3:
		baseAddr= 0xe000;
		break;
    default: 
		sprintf(msg,"xPC TargetBox CAN controller disabled in BIOS");
        ssSetErrorStatus(S,msg);
        return;
	}
	
	ssSetIWorkValue(S,0,(int_T)baseAddr);

#endif

}

	

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

	int_T i, j, count, done, tmp;
	uint16_T baseAddr= ssGetIWorkValue(S,0);
	uint16_T index, ctr, newdata;
	real_T *y, y1;


	uint8_T *p_data;

	for (i = 0; i<mxGetN(CANIDS_ARG); i++) {

		y= ssGetOutputPortSignal(S,i);
		p_data= (uint8_T *) &y1;
		index= (int_T)mxGetPr(CANINDEX_ARG)[i];

		ctr= (uint16_T)rl32eInpW(baseAddr + (16*(index+1)+0));

		count=0;
		tmp=0;

		//printf("0x%x\n", ctr);


		if ((ctr & 0x0200) == 0x0200) { //new data
			
			if ((ctr & 0x0800) == 0x0800) { //message lost
				tmp=-1;
			} else {
				tmp=1;
			}
            
			rl32eOutpB(baseAddr + (16*(index+1)+1), CLR(NewDat) & CLR(MsgLst));

			done=0;

			while (!done) {

				/* Read the data bytes: */
				for (j = 0; j < (int_T)mxGetPr(CANSIZE_ARG)[i]; j++) {
					p_data[j]= (uint8_T)rl32eInpB(baseAddr + (16*(index+1)+7+j));
				}

				count++;

				ctr= (uint16_T)rl32eInpW(baseAddr + (16*(index+1)+0));

				if ((ctr & 0x0200) == 0x0000) { //no new data
					done=1;
				} else {
					rl32eOutpB(baseAddr + (16*(index+1)+1), CLR(NewDat) & CLR(MsgLst));
					if (count==(int_T)mxGetPr(COUNT_ARG)[0]) {
						done=1;
						tmp=-2;
					}
				}

			}

			y[0]=y1;
			

		}

		if ((int_T)mxGetPr(OUTPORT_ARG)[0]>1) {
			y[1]= (real_T)tmp;
		}
		if ((int_T)mxGetPr(OUTPORT_ARG)[0]>2) {
			y[2]= (real_T)count;
		}
	


	}

#endif
        
}

static void mdlTerminate(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE


#endif

}

#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

