/* $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:01:38 $ */
/* can527setup.c - xPC Target, non-inlined S-function driver for for Intel 82527 */
/* Copyright 1994-2004 The MathWorks, Inc. */

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME can527setup

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

#define 	NUMBER_OF_ARGS        	(7)
#define		CANBR_ARG				ssGetSFcnParam(S,0)
#define 	CANLIST_ARG         	ssGetSFcnParam(S,1)
#define 	CANDIRECT_ARG          	ssGetSFcnParam(S,2)
#define 	CANTYPE_ARG				ssGetSFcnParam(S,3)
#define 	CANSIZE_ARG				ssGetSFcnParam(S,4)
#define 	INIT_ARG				ssGetSFcnParam(S,5)
#define 	TERM_ARG				ssGetSFcnParam(S,6)



#define 	SAMP_TIME_IND           (0)

#define 	NO_I_WORKS             	(1)

#define 	NO_R_WORKS              (0)


static init=1;
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

	uint16_T resourceReg, baseAddr, presc, tsync, tseg1, tseg2, i, tmp, j;
	

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

	if (init) {

	printf("        xPC TargetBox CAN Controller at: 0x%x\n",baseAddr);

	/* reset controller */
	rl32eOutpB((unsigned short)0x805,(unsigned short)0x01);
	rl32eWaitDouble(0.050);
	/* Release the chip reset */
	rl32eOutpB((unsigned short)0x805,(unsigned short)0x00);
	rl32eWaitDouble(0.050);

	if (rl32eInpB(baseAddr + 0x02) & 0x80) {
        printf( "CAN controller reset is stuck in active state!\n");
        return;
    }

	/* controller clocks */
	rl32eOutpB(baseAddr + 0x02, (unsigned short)0x00);

	/* Initialize the 82527: */
    rl32eOutpB(baseAddr + 0x00, (unsigned short)0x41);

	/* clock out slew rate */
	/* rl32eOutpB(baseAddr + 0x1f, (unsigned short)0x21); */

    /* Bus configuration. */
	rl32eOutpB(baseAddr + 0x2f, (unsigned short)0x00);

	/* clear bus error */
	rl32eOutpB(baseAddr + 0x01, (unsigned short)0x00);

	/* The bit timing. SCLK = 8 MHz. */
    presc= (uint16_T)mxGetPr(CANBR_ARG)[0];
	tsync= (uint16_T)mxGetPr(CANBR_ARG)[1];
	tseg1= (uint16_T)mxGetPr(CANBR_ARG)[2];
	tseg2= (uint16_T)mxGetPr(CANBR_ARG)[3];

	rl32eOutpB(baseAddr + CAN_BTR0, ((tsync-1)<<6)|(presc-1));  
    rl32eOutpB(baseAddr + CAN_BTR1, ((tseg2-1)<<4)|(tseg1-1)); 
	//rl32eOutpB(baseAddr + 0x3f, (unsigned short)0x00);  
    //rl32eOutpB(baseAddr + 0x4f, (unsigned short)0x32); 

	rl32eOutpB(baseAddr + 0x06, (unsigned short)0xff);
	rl32eOutpB(baseAddr + 0x07, (unsigned short)0xff);

	init=0;

	}


    /* Set all message buffers to Invalid and Interrupts disable. */
    for (i = 1; i < 16; i++) {
		rl32eOutpB(baseAddr + (16*i), (unsigned short)0x55);
		rl32eOutpB(baseAddr + (16*i+1), (unsigned short)0x55);
    }

    rl32eOutpB(baseAddr + 0x01, (unsigned short)0x00);

    rl32eOutpB(baseAddr + 0x00, (unsigned short)0x00);

	//printf("%x\n",0xff & rl32eInpB(baseAddr + CAN_STAT));

	for (i = 0; i<mxGetN(CANLIST_ARG); i++) {

		/* set size, direction, and type */
		tmp= CANmsg_DLC((int_T)mxGetPr(CANSIZE_ARG)[i]);
		if ((int_T)mxGetPr(CANDIRECT_ARG)[i]==0) {
			tmp |= CANmsg_Transmit;
		} else {
			tmp |= CANmsg_Receive;
		}
		if ((int_T)mxGetPr(CANTYPE_ARG)[i]==0) {
			tmp |= CANmsg_Standard;
		} else {
			tmp |= CANmsg_Extended;
		}

		/* Prevent the 82527 to transmit the message while we are updating it. */
		rl32eOutpB(baseAddr + (16*(i+1)),CLR(MsgVal) & CLR(TxIE) & CLR(RxIE) & CLR(IntPnd));

		if ((int_T)mxGetPr(CANDIRECT_ARG)[i]==0) { /* Set up the transmit object */

			rl32eOutpB(baseAddr + (16*(i+1)+1), CLR(RmtPnd) & CLR(TxRqst) & SET(CPUUpd));

		} else {

			rl32eOutpB(baseAddr + (16*(i+1)+1), CLR(RmtPnd) & CLR(TxRqst) & CLR(NewDat));

		}

		/* Set the message id to identifier and up */
		//printf("%d 0x%x\n", (int_T)mxGetPr(CANLIST_ARG)[i], tmp);
		if ((int_T)mxGetPr(CANTYPE_ARG)[i]==0) {
			rl32eOutpB(baseAddr + (16*(i+1)+2), (unsigned short)(((int_T)mxGetPr(CANLIST_ARG)[i]>>3) & 0xff));
			rl32eOutpB(baseAddr + (16*(i+1)+3), (unsigned short)(((int_T)mxGetPr(CANLIST_ARG)[i] & 0x07) << 5));
		} else {
			rl32eOutpB(baseAddr + (16*(i+1)+2), (unsigned short)(((int_T)mxGetPr(CANLIST_ARG)[i] >> 21) & 0xff));
			rl32eOutpB(baseAddr + (16*(i+1)+3), (unsigned short)(((int_T)mxGetPr(CANLIST_ARG)[i] >> 13) & 0xff));
			rl32eOutpB(baseAddr + (16*(i+1)+4), (unsigned short)(((int_T)mxGetPr(CANLIST_ARG)[i] >> 5) & 0xff));
			rl32eOutpB(baseAddr + (16*(i+1)+5), (unsigned short)(((int_T)mxGetPr(CANLIST_ARG)[i] & 0xff)<<3));
		}

		for (j = 0; j < (int_T)mxGetPr(CANSIZE_ARG)[i]; j++) {
			rl32eOutpB(baseAddr + (16*(i+1)+7+j), 0x00);
		}

		rl32eOutpB(baseAddr + (16*(i+1)+1), CLR(NewDat));

		rl32eOutpB(baseAddr + (16*(i+1)+6), (unsigned short)tmp);

		rl32eOutpB(baseAddr + (16*(i+1)), SET(MsgVal));

	}

	//printf("%x\n",0xff & rl32eInpB(baseAddr + CAN_STAT));


#endif

}

	

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

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

