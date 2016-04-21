/* $Revision: 1.5 $ $Date: 2002/03/25 04:03:09 $ */
/* ctrcbctr05.c - xPC Target, non-inlined S-function driver for Counter section of NI PC-TIO-10 board  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#undef S_FUNCTION_NAME
#define S_FUNCTION_NAME ctrnipctio10

#include <stddef.h>
#include <stdlib.h>

#include "tmwtypes.h"
#include "simstruc.h" 

#ifdef MATLAB_MEX_FILE
#include "mex.h"
#else
#include <windows.h>
#include "io_xpcimport.h"
#endif


/* Input Arguments */
#define NUMBER_OF_ARGS          (11)
#define COUNTER_ARG             ssGetSFcnParam(S,0)
#define MODE_ARG                ssGetSFcnParam(S,1)
#define TOGGLE_ARG              ssGetSFcnParam(S,2)
#define LOAD_ARG           		ssGetSFcnParam(S,3)
#define HOLD_ARG           		ssGetSFcnParam(S,4)
#define LOAD_READ_ARG           ssGetSFcnParam(S,5)
#define HOLD_READ_ARG           ssGetSFcnParam(S,6)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,7)
#define BASE_ADDR_ARG           ssGetSFcnParam(S,8)
#define INIT_ARM_ARG           	ssGetSFcnParam(S,9)
#define ARM_READ_ARG           	ssGetSFcnParam(S,10)




#define COUNTER_IND             (0)
#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)

#define NO_I_WORKS              (7)
#define COUNTER_I_IND           (0)
#define LOAD_I_IND              (1)
#define HOLD_I_IND              (2)
#define BASE_ADDR_I_IND         (3)
#define BASE_OFFSET_I_IND       (4)
#define ACT_ARM_I_IND       	(5)
#define ARM_I_IND              	(6)



#define NO_R_WORKS              (0)


static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#endif


#ifdef MATLAB_MEX_FILE
       ssSetNumSFcnParams(S, NUMBER_OF_ARGS);  /* Number of expected parameters */
       if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
            sprintf(msg,"Wrong number of input arguments passed.\nEleven arguments are expected\n");
            ssSetErrorStatus(S,msg);
            return;
        }
#endif


#ifdef MATLAB_MEX_FILE
        if ( mxGetM(SAMP_TIME_ARG)!=1 | mxGetN(SAMP_TIME_ARG)!=1 ) {
             sprintf(msg,"sample time argument must be scalar\n");
            ssSetErrorStatus(S,msg);
            return;
        }
        if ( mxGetM(BASE_ADDR_ARG)!=1 | mxGetN(BASE_ADDR_ARG)!=1 ) {
             sprintf(msg,"base address argument must be scalar\n");
             ssSetErrorStatus(S,msg);
             return;
        }

#endif
        
        /* Set-up size information */
        ssSetNumContStates(S, 0);
        ssSetNumDiscStates(S, 0);
        ssSetNumOutputs(S, 0);
        ssSetNumInputs(S, 3);
        ssSetDirectFeedThrough(S, 0); /* Direct dependency on inputs */
        ssSetNumSampleTimes(S,1);
        ssSetNumInputArgs(S, NUMBER_OF_ARGS);
        ssSetNumIWork(S, NO_I_WORKS); 
        ssSetNumRWork(S, NO_R_WORKS);
        ssSetNumPWork(         S, 0);   /* number of pointer work vector elements*/
        ssSetNumModes(         S, 0);   /* number of mode work vector elements   */
        ssSetNumNonsampledZCs( S, 0);   /* number of nonsampled zero crossings   */
        ssSetOptions(          S, 0);   /* general options (SS_OPTION_xx)        */
        
}
 
/* Function to initialize sample times */
static void mdlInitializeSampleTimes(SimStruct *S)
{
        
        ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME_ARG)[SAMP_TIME_IND]);
        if (mxGetN((SAMP_TIME_ARG))==1) {
			ssSetOffsetTime(S, 0, 0.0);
		} else {
        	ssSetOffsetTime(S, 0, mxGetPr(SAMP_TIME_ARG)[1]);
		}

}
 

static void mdlInitializeConditions(real_T *x0, SimStruct *S)
{


        int_T arg_str_len = 128;
        char_T arg_str[128];
        uint_T base_addr, base_offset;
        int_T num_counter, hold, load, arm, out; 

         
        num_counter = (int_T)mxGetPr(COUNTER_ARG)[COUNTER_IND];
        

        //2.50
        base_addr = (unsigned int) mxGetPr(BASE_ADDR_ARG)[0]; //2.50
        ssSetIWorkValue(S, BASE_ADDR_I_IND, (int_T)base_addr);

		load = (int_T)mxGetPr(LOAD_READ_ARG)[0];
        ssSetIWorkValue(S,LOAD_I_IND , load);

		hold = (int_T)mxGetPr(HOLD_READ_ARG)[0];
        ssSetIWorkValue(S,HOLD_I_IND , hold);

		arm = (int_T)mxGetPr(ARM_READ_ARG)[0];
        ssSetIWorkValue(S,ARM_I_IND , arm);
		

		if (num_counter<6) {
			base_offset=0x0;
		} else {
			base_offset=0x2;
			num_counter=num_counter-5;
		}
		ssSetIWorkValue(S, BASE_OFFSET_I_IND, base_offset);
		ssSetIWorkValue(S,COUNTER_I_IND , num_counter);


			

    

#ifndef MATLAB_MEX_FILE

	//master reset 
	//rl32eOutpB(base_addr+0x01,0xff);

	// define Master Mode register
	rl32eOutpB((unsigned short)(base_addr+base_offset+0x01),0x17);
	// write to Master Mode register
	// low byte
	rl32eOutpB((unsigned short)(base_addr+base_offset+0x00),0x00);
	// high byte
	rl32eOutpB((unsigned short)(base_addr+base_offset+0x00),0x80);
	
	//enable data pointer sequencing 
	rl32eOutpB((unsigned short)(base_addr+base_offset+0x01),0xe0);

	// define counter
	rl32eOutpB((unsigned short)(base_addr+base_offset+0x01),(unsigned short)num_counter); 

	// build mode register
	out=0x0;
	out|=(((int_T)mxGetPr(MODE_ARG)[0])-1) << 13;
	out|=(((int_T)mxGetPr(MODE_ARG)[1])-1) << 11;
	out|=(((int_T)mxGetPr(MODE_ARG)[2])-1) << 8;
	out|=(((int_T)mxGetPr(MODE_ARG)[3])-1) << 7;
	out|=(((int_T)mxGetPr(MODE_ARG)[4])-1) << 6;
	out|=(((int_T)mxGetPr(MODE_ARG)[5])-1) << 5;
	out|=(((int_T)mxGetPr(MODE_ARG)[6])-1) << 4;
	out|=(((int_T)mxGetPr(MODE_ARG)[7])-1) << 3;
	out|=(((int_T)mxGetPr(MODE_ARG)[8])-1);

	//printf("%x\n",out);

	rl32eOutpB((unsigned short)(base_addr+base_offset+0x00),(unsigned short)(out & 0xff));
	rl32eOutpB((unsigned short)(base_addr+base_offset+0x00),(unsigned short)((out >> 8) & 0xff)); 

	rl32eOutpB((unsigned short)(base_addr+base_offset+0x00),(unsigned short)(((int_T)mxGetPr(LOAD_ARG)[0]) & 0xff));
	rl32eOutpB((unsigned short)(base_addr+base_offset+0x00),(unsigned short)(((int_T)mxGetPr(LOAD_ARG)[0] >> 8) & 0xff));

  rl32eOutpB((unsigned short)(base_addr+base_offset+0x00),(unsigned short)(((int_T)mxGetPr(HOLD_ARG)[0]) & 0xff));
	rl32eOutpB((unsigned short)(base_addr+base_offset+0x00),(unsigned short)(((int_T)mxGetPr(HOLD_ARG)[0] >> 8) & 0xff));

	// set toggle start level
	if ((int_T)mxGetPr(TOGGLE_ARG)[0]==1) {
		rl32eOutpB((unsigned short)(base_addr+base_offset+0x01),(unsigned short)(0xe0 | num_counter));
	}
	if ((int_T)mxGetPr(TOGGLE_ARG)[0]==2) {
		rl32eOutpB((unsigned short)(base_addr+base_offset+0x01),(unsigned short)(0xe8 | num_counter));
	}

	// load counter 
	rl32eOutpB((unsigned short)(base_addr+base_offset+0x01),(unsigned short)(0x40 | (1 << (num_counter-1)))); 

	
	if ((int_T)mxGetPr(INIT_ARM_ARG)[0]==2) { 
		// arm counter 
		rl32eOutpB((unsigned short)(base_addr+base_offset+0x01),(unsigned short)(0x20 | (1 << (num_counter-1)))); 
		ssSetIWorkValue(S,ACT_ARM_I_IND , 1);
	} else {
	    ssSetIWorkValue(S,ACT_ARM_I_IND , 0);	
	}

       
#endif

                 
}

/* Function to compute outputs */
static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
        uint_T base_addr = ssGetIWorkValue(S, BASE_ADDR_I_IND);
		uint_T base_offset = ssGetIWorkValue(S, BASE_OFFSET_I_IND);
        int_T num_counter = ssGetIWorkValue(S, COUNTER_I_IND);
		int_T load = ssGetIWorkValue(S, LOAD_I_IND);
		int_T hold = ssGetIWorkValue(S, HOLD_I_IND);
		int_T arm  = ssGetIWorkValue(S, ARM_I_IND);
		int_T act_arm  = ssGetIWorkValue(S, ACT_ARM_I_IND);
        int_T i;
        int_T load_val, hold_val, new_arm;
    
        
#ifndef MATLAB_MEX_FILE

		if (load) {
			load_val=(int_T)u[0];
			rl32eOutpB((unsigned short)(base_addr+base_offset+0x01),(unsigned short)(0x08 | num_counter));
			rl32eOutpB((unsigned short)(base_addr+base_offset+0x00),(unsigned short)(load_val & 0xff));
			rl32eOutpB((unsigned short)(base_addr+base_offset+0x00),(unsigned short)((load_val >> 8) & 0xff));
		}

		if (hold) {
			hold_val=(int_T)u[1];
			rl32eOutpB((unsigned short)(base_addr+base_offset+0x01),(unsigned short)(0x10 | num_counter));
			rl32eOutpB((unsigned short)(base_addr+base_offset+0x00),(unsigned short)(hold_val & 0xff));
			rl32eOutpB((unsigned short)(base_addr+base_offset+0x00),(unsigned short)((hold_val >> 8) & 0xff));
		}

		if (arm) {
			new_arm=(int_T)u[2];
			if (act_arm!=new_arm) {
				if (new_arm) {
					rl32eOutpB((unsigned short)(base_addr+base_offset+0x01),(unsigned short)(0x20 | (1 << (num_counter-1)))); 
					ssSetIWorkValue(S,ACT_ARM_I_IND , 1);
				} else {
					rl32eOutpB((unsigned short)(base_addr+base_offset+0x01),(unsigned short)(0xc0 | (1 << (num_counter-1)))); 
					// set toggle start level
					if ((int_T)mxGetPr(TOGGLE_ARG)[0]==1) {
						rl32eOutpB((unsigned short)(base_addr+base_offset+0x01),(unsigned short)(0xe0 | num_counter));
					}
					if ((int_T)mxGetPr(TOGGLE_ARG)[0]==2) {
						rl32eOutpB((unsigned short)(base_addr+base_offset+0x01),(unsigned short)(0xe8 | num_counter));
					}
					ssSetIWorkValue(S,ACT_ARM_I_IND , 0);
				}
			}
		}

				
#endif
        
}

/* Function to compute model update */
static void mdlUpdate(real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
}
 
/* Function to compute derivatives */
static void mdlDerivatives(real_T *dx, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
}
 
/* Function to perform housekeeping at execution termination */
static void mdlTerminate(SimStruct *S)
{

    uint_T base_addr = ssGetIWorkValue(S, BASE_ADDR_I_IND);
	uint_T base_offset = ssGetIWorkValue(S, BASE_OFFSET_I_IND);
    int_T num_counter = ssGetIWorkValue(S, COUNTER_I_IND);
	
#ifndef MATLAB_MEX_FILE

	// disarm counter
	rl32eOutpB((unsigned short)(base_addr+base_offset+0x01),(unsigned short)(0xc0 | (1 << (num_counter-1)))); 

#endif


}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif


