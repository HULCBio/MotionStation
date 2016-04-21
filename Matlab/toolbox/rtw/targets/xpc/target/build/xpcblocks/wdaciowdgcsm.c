/* $Revision: 1.6 $ $Date: 2002/03/25 04:11:42 $*/
/* wdaciowdgcsm.c - xPC Target, non-inlined S-function driver for WDG-CSM Watchdog board from ACCES I/O */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME  wdaciowdgcsm

#include <math.h>
#include "simstruc.h"
#include "tmwtypes.h"

#ifdef MATLAB_MEX_FILE
#include "mex.h"
#else
#include <windows.h>
#include "io_xpcimport.h"
#endif


/* Input Arguments */
#define NUMBER_OF_ARGS        		(4)
#define WD_TIME_ARG            	    ssGetSFcnParam(S,0)
#define SHOW_RESET_ARG 	           	ssGetSFcnParam(S,1)
#define SAMP_TIME_ARG              	ssGetSFcnParam(S,2)
#define BASE_ADDR_ARG           	ssGetSFcnParam(S,3)

#define NO_I_WORKS              	(3)
#define WDCOUNT_I_IND          		(0)
#define BASE_ADDR_I_IND         	(1)
#define RESET_I_IND         		(2)


#define NO_R_WORKS              	(0)


static char_T msg[256];

static int_T first=1;
static int_T reset=0;


static void mdlInitializeSizes(SimStruct *S)
{

	int_T i, num_inpports;
	real_T wdtime;


#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#endif



    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
		sprintf(msg,"Wrong number of input arguments passed.\n4 arguments are expected\n");
        ssSetErrorStatus(S,msg);
        return;
    }
	

    if ( mxGetM(WD_TIME_ARG)!=1 | mxGetN(WD_TIME_ARG)!=1 ) {
    	sprintf(msg,"watchdog time argument must be a scalar\n");
        ssSetErrorStatus(S,msg);
        return;
    }

	wdtime=mxGetPr(WD_TIME_ARG)[0];
	if (wdtime < 0.00002 || wdtime > 4800.0) {
    	sprintf(msg,"watchdog time must be in the range: 20us..4800s\n");
        ssSetErrorStatus(S,msg);
        return;
   	}	
    
    if ( mxGetM(SAMP_TIME_ARG)!=1 | mxGetN(SAMP_TIME_ARG)!=1 ) {
    	sprintf(msg,"sample time argument must be a scalar\n");
        ssSetErrorStatus(S,msg);
        return;
   	}

    if ( mxGetM(BASE_ADDR_ARG)!=1 | mxGetN(BASE_ADDR_ARG)!=1 ) {
             sprintf(msg,"base address argument must be scalar\n");
             ssSetErrorStatus(S,msg);
             return;
        }


	
    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

	ssSetNumOutputPorts(S, 0);

	num_inpports=0;
	if ((int_T)mxGetPr(SHOW_RESET_ARG)[0]) {
		num_inpports=1;
	}
    ssSetNumInputPorts(S, num_inpports);
	for (i=0;i<num_inpports;i++) {
	     ssSetInputPortWidth(S, i, 1);
             ssSetInputPortDirectFeedThrough(S,i,1);   
	}										
	
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
    ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME_ARG)[0]);
    ssSetOffsetTime(S, 0, 0.0);

}


#undef MDL_INITIALIZE_CONDITIONS   /* Change to #undef to remove function */
#if defined(MDL_INITIALIZE_CONDITIONS)
  static void mdlInitializeConditions(SimStruct *S)
  {
  }
#endif /* MDL_INITIALIZE_CONDITIONS */



#define MDL_START  /* Change to #undef to remove function */
#if defined(MDL_START) 
static void mdlStart(SimStruct *S)
{
    int_T 	arg_str_len = 128;
    char_T 	arg_str[128];
    uint_T 	base_addr;
    int_T 	num_channels;
    real_T 	*RWork=ssGetRWork(S);
    int_T 	wdcount;
    real_T	wdtime;

	wdtime=sqrt(mxGetPr(WD_TIME_ARG)[0]*894.88625e3);
	wdcount=(int_T)wdtime;
	ssSetIWorkValue(S,WDCOUNT_I_IND , wdcount);

	ssSetIWorkValue(S,RESET_I_IND , (int_T)mxGetPr(SHOW_RESET_ARG)[0]);

    //2.50
    base_addr = (uint_T)mxGetPr(BASE_ADDR_ARG)[0];
    ssSetIWorkValue(S, BASE_ADDR_I_IND, (int_T)base_addr); 

#ifndef MATLAB_MEX_FILE

		// reset counters
		rl32eInpB((unsigned short)(base_addr+0x7));


		// program counter 0 for mode 3
		rl32eOutpB((unsigned short)(base_addr+0x3),0x36);

		// program counter 1 for mode 2
		rl32eOutpB((unsigned short)(base_addr+0x3),0x74);

		// program counter 2 for mode 0
		rl32eOutpB((unsigned short)(base_addr+0x3),0xb0);

		// load counter 0 with 0x0843, first low then high
		rl32eOutpB((unsigned short)(base_addr+0x0),(unsigned short)(wdcount & 0xff));
		rl32eOutpB((unsigned short)(base_addr+0x0),(unsigned short)((wdcount >> 8) & 0xff));

		// load counter 1 with 0x0843, first low then high
		rl32eOutpB((unsigned short)(base_addr+0x1),(unsigned short)(wdcount & 0xff));
		rl32eOutpB((unsigned short)(base_addr+0x1),(unsigned short)((wdcount >> 8) & 0xff));

#endif
		
}
#endif /*  MDL_START */



/* Function: mdlOutputs =======================================================
 * Abstract:
 *    In this function, you compute the outputs of your S-function
 *    block. Generally outputs are placed in the output vector, ssGetY(S).
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
        
#ifndef MATLAB_MEX_FILE

    uint_T	base_addr = ssGetIWorkValue(S, BASE_ADDR_I_IND);
    int_T 	wdcount = ssGetIWorkValue(S, WDCOUNT_I_IND);
	int_T 	resetinput = ssGetIWorkValue(S, RESET_I_IND);
	InputRealPtrsType uPtrs;

	if (first) {
		// enable counters
		rl32eOutpB((unsigned short)(base_addr+0x7),0x0);
		first=0;
	} else {

		if (!reset) {
		
			// program counter 1 for mode 2
			rl32eOutpB((unsigned short)(base_addr+0x3),0x74);

			// load counter 1 with 0x0843, first low then high
			rl32eOutpB((unsigned short)(base_addr+0x1),(unsigned short)(wdcount & 0xff));
			rl32eOutpB((unsigned short)(base_addr+0x1),(unsigned short)((wdcount >> 8) & 0xff));

	    	if (resetinput) {
				uPtrs=ssGetInputPortRealSignalPtrs(S,0);
				if (*uPtrs[0]) {
					// program counter 1 for mode 2
		   			rl32eOutpB((unsigned short)(base_addr+0x3),0x74);

					// load counter 1 with 0x0843, first low then high
					rl32eOutpB((unsigned short)(base_addr+0x1),0x10);
					rl32eOutpB((unsigned short)(base_addr+0x1),0x0);
					
					reset=1;
				}
			}

		}
			
	}


#endif
        
	

}



#undef MDL_UPDATE  /* Change to #undef to remove function */
#undef MDL_DERIVATIVES  /* Change to #undef to remove function */

static void mdlTerminate(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE

  	uint_T base_addr = ssGetIWorkValue(S, BASE_ADDR_I_IND);

    rl32eInpB((unsigned short)(base_addr+0x7));
	first=1;

#endif

}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
