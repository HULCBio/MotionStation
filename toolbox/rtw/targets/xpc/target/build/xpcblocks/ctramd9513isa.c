/* $Revision: 1.5 $ $Date: 2002/03/25 04:03:03 $ */
/* ctramd9513isa.c - xPC Target, non-inlined S-function driver for AMD9513 based counter boards  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/


//#define DEBUG

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME ctramd9513isa
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
#endif

#define 	NUMBER_OF_ARGS        	(8)
#define 	IO_ARG        			ssGetSFcnParam(S,0)
#define 	MM_ARG        			ssGetSFcnParam(S,1)
#define 	CMS_ARG        			ssGetSFcnParam(S,2)
#define		INIT_ARG				ssGetSFcnParam(S,3)
#define 	COMMAND_ARG        		ssGetSFcnParam(S,4)
#define 	TERM_ARG        		ssGetSFcnParam(S,5)
#define 	SAMP_TIME_ARG          	ssGetSFcnParam(S,6)
#define 	BASE_ADDR_ARG           ssGetSFcnParam(S,7)


#define 	SAMP_TIME_IND           (0)

#define 	NO_I_WORKS             	(0)

#define 	NO_R_WORKS              (0)

#define 	THRESHOLD				0.5

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
	int_T num_channels, i;
	const real_T *io;
	int_T nInputs, nOutputs;


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

	io= mxGetPr(IO_ARG);

	nInputs= (int_T)io[0];
	nOutputs= (int_T)io[1];

	/* define number of inputs */
	ssSetNumInputPorts(S, nInputs); 
	/* define number of outputs */
	ssSetNumOutputPorts(S, nOutputs);

	/* define input ports */
	for (i=0;i<nInputs;i++) {
		ssSetInputPortWidth(S, i, (int_T)io[i+2]);
		ssSetInputPortDirectFeedThrough(S, i, 1);
	}

	/* define output ports */
	for (i=0;i<nOutputs;i++) {
		ssSetOutputPortWidth(S, i, (int_T)io[i+2+nInputs]);
	}
	

    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumPWork(S, 0);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);


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

#ifndef MATLAB_MEX_FILE
	/* if necessary, the MM gets initailized here, because we have to do it before the counter modes */
	if (mxGetN(MM_ARG)) {
		uint16_T mm= (uint16_T)mxGetPr(MM_ARG)[0];
		uint_T base_addr = (uint_T)mxGetPr(BASE_ADDR_ARG)[0];	
#ifdef DEBUG
		printf("MM: %x\n", mm);
#endif
		rl32eOutpB(base_addr+0x01,0x17);
		rl32eOutpB(base_addr+0x00, mm & 0xff);
		// high byte
		rl32eOutpB(base_addr+0x00, (mm>>8) & 0xff);
	}
#endif

}

#define MDL_START
static void mdlStart(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE
	/* if necessary, the counter modes get initailized here */
	if (mxGetN(CMS_ARG)) {
		uint_T base_addr = (uint_T)mxGetPr(BASE_ADDR_ARG)[0];
		int i;
		uint16_T cm;
		for (i=0;i<5;i++) {
			if ((int_T)mxGetPr(CMS_ARG)[i]!=-1) {
				cm= (uint16_T)mxGetPr(CMS_ARG)[i];	 
#ifdef DEBUG
				printf("CM counter %d: %x\n", i+1, cm);
#endif
				rl32eOutpB(base_addr+0x01, i+1); 
				rl32eOutpB(base_addr+0x00, cm & 0xff);
				rl32eOutpB(base_addr+0x00, (cm >> 8) & 0xff);

				if (mxGetN(INIT_ARG)) { 

					const real_T *command= mxGetPr(INIT_ARG);

					int_T k, i, j, execute, input, counter, com, ctr, isInput;
					uint8_T counterPattern;
					int_T value;

					/* loop over all commands */

					k=1;

					for  (i=0; i< (int_T)command[0]; i++) {

						
						execute= (int_T)command[k+1]; 

						if (execute) {

							com= (int_T)command[k]; 

				#ifdef DEBUG
							printf("command: %d\n",com);
				#endif

							switch (com) {

								case 10:	/* WriteLoad */
								case 11:	/* WriteHold */



									/* get first I/O element */
									value=(int_T)command[k+9];

									/* loop over all counters */
									for (ctr=0; ctr<(int_T)command[k+2]; ctr++) {

										/* get counter */
										counter= (int_T)command[k+4+ctr]; 
										
										/* get value */
										value= (int_T)command[k+9+ctr];

										/* execute command */
										if (com==10) {
				#ifdef DEBUG
											printf("WriteLoad\n");
				#endif
										 	rl32eOutpB(base_addr+0x01,0x08 | counter);
										} else if (com==11) {
				#ifdef DEBUG
											printf("WriteHold\n");
				#endif
											rl32eOutpB(base_addr+0x01,0x10 | counter);
										}
										rl32eOutpB(base_addr+0x00, value & 0xff);
										rl32eOutpB(base_addr+0x00, (value>>8) & 0xff);
									}
									break;

									
								case 20:	/* Arm */
				#ifdef DEBUG
									printf("Arm\n");
				#endif
									/* execute command */
									rl32eOutpB(base_addr+0x01,0x20 | (int_T)command[k+3]);
									break;

								case 21:	/* Disarm */
				#ifdef DEBUG
									printf("Disarm\n");
				#endif
									/* execute command */
									rl32eOutpB(base_addr+0x01,0xc0 | (int_T)command[k+3]);
									break;

								case 22:	/* LoadAndArm */
				#ifdef DEBUG
									printf("LoadAndArm\n");
				#endif
									/* execute command */
									rl32eOutpB(base_addr+0x01,0x60 | (int_T)command[k+3]);
									break;

								case 23:	/* DisarmAndSave */
				#ifdef DEBUG
									printf("DisarmAndSave\n");
				#endif
									/* execute command */
									rl32eOutpB(base_addr+0x01,0x80 | (int_T)command[k+3]);
									break;


								case 30:	/* Load */
				#ifdef DEBUG
									printf("Load\n");
				#endif
									/* execute command */
									rl32eOutpB(base_addr+0x01,0x40 | (int_T)command[k+3]);
									break;


								case 31:	/* Save */
				#ifdef DEBUG
									printf("Save\n");
				#endif
									/* execute command */
									rl32eOutpB(base_addr+0x01,0x90 | (int_T)command[k+3]);
									break;

								case 40:	/* Set Toggle */
									
				#ifdef DEBUG
									printf("Set Toggle Output\n");
				#endif
									for (ctr=0; ctr<(int_T)command[k+2]; ctr++) {

										/* get counter */
										counter= (int_T)command[k+4+ctr]; 
										
										/* execute command */
										rl32eOutpB(base_addr+0x01,0xe8 | counter);
									}
									break;

								case 41:	/* Clear Toggle */
									
				#ifdef DEBUG
									printf("Clear Toggle Output\n");
				#endif
									for (ctr=0; ctr<(int_T)command[k+2]; ctr++) {

										/* get counter */
										counter= (int_T)command[k+4+ctr]; 
										
										/* execute command */
										rl32eOutpB(base_addr+0x01,0xe0 | counter);
									}
									break;

							}
						}
						k+= 14;
					}
				}
			}
		} 
	}

		
#endif

}




	
static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE


	const real_T *command= mxGetPr(COMMAND_ARG);
	InputRealPtrsType uPtrs;
	real_T  *y;

	int_T k, i, j, execute, input, counter, com, ctr, isInput;
	uint8_T counterPattern;
	int_T value;

	uint_T base_addr = (uint_T) mxGetPr(BASE_ADDR_ARG)[0];	


	/* loop over all commands */

	k=1;

	for  (i=0; i< (int_T)command[0]; i++) {

		
		execute= (int_T)command[k+1]; 

		if (execute<0) {
			input= -execute-1;
			uPtrs= ssGetInputPortRealSignalPtrs(S,input);
			if (*uPtrs[0] < THRESHOLD) {
				execute=0;
			} else {
				execute=1;
			}
		}

		if (execute) {

			com= (int_T)command[k]; 

#ifdef DEBUG
			printf("command: %d\n",com);
#endif

			switch (com) {

				case 10:	/* WriteLoad */
				case 11:	/* WriteHold */



					/* get first I/O element */
					value=(int_T)command[k+9];

					isInput=0;
					if (value<0) {  /* input */
						input= -value-1;
						uPtrs= ssGetInputPortRealSignalPtrs(S,input);
						isInput=1;
					}

					/* loop over all counters */
					for (ctr=0; ctr<(int_T)command[k+2]; ctr++) {

						/* get counter */
						counter= (int_T)command[k+4+ctr]; 
						
						/* get value */
						if (isInput) {
							value= (int_T)*uPtrs[ctr]; 
						} else {
							value= (int_T)command[k+9+ctr];
						}

						/* execute command */
						if (com==10) {
#ifdef DEBUG
							printf("WriteLoad\n");
#endif
						 	rl32eOutpB(base_addr+0x01,0x08 | counter);
						} else if (com==11) {
#ifdef DEBUG
							printf("WriteHold\n");
#endif
							rl32eOutpB(base_addr+0x01,0x10 | counter);
						}
						rl32eOutpB(base_addr+0x00, value & 0xff);
						rl32eOutpB(base_addr+0x00, (value>>8) & 0xff);
					}
					break;

				case 12:	/* ReadLoad */
				case 13:	/* ReadHold */

					//printf("%d\n",-((int_T)command[k+9])-1); 

					y=ssGetOutputPortSignal(S,-((int_T)command[k+9])-1);

					/* loop over all counters */
					for (ctr=0; ctr<(int_T)command[k+2]; ctr++) {


						/* get counter */
						counter= (int_T)command[k+4+ctr]; 
						
						/* execute command */
						if (com==12) {
#ifdef DEBUG
							printf("ReadLoad CTR %d\n", counter);
#endif
						 	rl32eOutpB(base_addr+0x01,0x08 | counter);
						} else if (com==13) {
#ifdef DEBUG
							printf("ReadHold CTR %d\n", counter);
#endif
							rl32eOutpB(base_addr+0x01,0x10 | counter);
						}
						value= rl32eInpB(base_addr+0x00) & 0xff;
						value|= (rl32eInpB(base_addr+0x00) & 0xff) << 8; 

						y[ctr]= (real_T)value;

					}
					break;

					
				case 20:	/* Arm */
#ifdef DEBUG
					printf("Arm\n");
#endif
					/* execute command */
					rl32eOutpB(base_addr+0x01,0x20 | (int_T)command[k+3]);
					break;

				case 21:	/* Disarm */
#ifdef DEBUG
					printf("Disarm\n");
#endif
					/* execute command */
					rl32eOutpB(base_addr+0x01,0xc0 | (int_T)command[k+3]);
					break;

				case 22:	/* LoadAndArm */
#ifdef DEBUG
					printf("LoadAndArm\n");
#endif
					/* execute command */
					rl32eOutpB(base_addr+0x01,0x60 | (int_T)command[k+3]);
					break;

				case 23:	/* DisarmAndSave */
#ifdef DEBUG
					printf("DisarmAndSave\n");
#endif
					/* execute command */
					rl32eOutpB(base_addr+0x01,0x80 | (int_T)command[k+3]);
					break;


				case 30:	/* Load */
#ifdef DEBUG
					printf("Load\n");
#endif
					/* execute command */
					rl32eOutpB(base_addr+0x01,0x40 | (int_T)command[k+3]);
					break;


				case 31:	/* Save */
#ifdef DEBUG
					printf("Save\n");
#endif
					/* execute command */
					rl32eOutpB(base_addr+0x01,0xa0 | (int_T)command[k+3]);
					break;

				case 40:	/* Set Toggle */
					
#ifdef DEBUG
					printf("Set Toggle Output\n");
#endif
					for (ctr=0; ctr<(int_T)command[k+2]; ctr++) {

						/* get counter */
						counter= (int_T)command[k+4+ctr]; 
						
						/* execute command */
						rl32eOutpB(base_addr+0x01,0xe8 | counter);
					}
					break;

				case 41:	/* Clear Toggle */
					
#ifdef DEBUG
					printf("Clear Toggle Output\n");
#endif
					for (ctr=0; ctr<(int_T)command[k+2]; ctr++) {

						/* get counter */
						counter= (int_T)command[k+4+ctr]; 
						
						/* execute command */
						rl32eOutpB(base_addr+0x01,0xe0 | counter);
					}
					break;

			}
		}
		k+= 14;
	}

#endif

}
				
					

static void mdlTerminate(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE

	if (mxGetN(TERM_ARG)) { 

		const real_T *command= mxGetPr(TERM_ARG);
		uint_T base_addr = (uint_T)mxGetPr(BASE_ADDR_ARG)[0];	

		int_T k, i, j, execute, input, counter, com, ctr, isInput;
		uint8_T counterPattern;
		int_T value;

		/* loop over all commands */

		k=1;

		for  (i=0; i< (int_T)command[0]; i++) {

			
			execute= (int_T)command[k+1]; 

			if (execute) {

				com= (int_T)command[k]; 

	#ifdef DEBUG
				printf("command: %d\n",com);
	#endif

				switch (com) {

					case 10:	/* WriteLoad */
					case 11:	/* WriteHold */



						/* get first I/O element */
						value=(int_T)command[k+9];

						/* loop over all counters */
						for (ctr=0; ctr<(int_T)command[k+2]; ctr++) {

							/* get counter */
							counter= (int_T)command[k+4+ctr]; 
							
							/* get value */
							value= (int_T)command[k+9+ctr];

							/* execute command */
							if (com==10) {
	#ifdef DEBUG
								printf("WriteLoad\n");
	#endif
							 	rl32eOutpB(base_addr+0x01,0x08 | counter);
							} else if (com==11) {
	#ifdef DEBUG
								printf("WriteHold\n");
	#endif
								rl32eOutpB(base_addr+0x01,0x10 | counter);
							}
							printf("%d, %d\n",counter, value);
							rl32eOutpB(base_addr+0x00, value & 0xff);
							rl32eOutpB(base_addr+0x00, (value>>8) & 0xff);
						}
						break;

						
					case 20:	/* Arm */
	#ifdef DEBUG
						printf("Arm\n");
	#endif
						/* execute command */
						rl32eOutpB(base_addr+0x01,0x20 | (int_T)command[k+3]);
						break;

					case 21:	/* Disarm */
	#ifdef DEBUG
						printf("Disarm\n");
	#endif
						/* execute command */
						rl32eOutpB(base_addr+0x01,0xc0 | (int_T)command[k+3]);
						break;

					case 22:	/* LoadAndArm */
	#ifdef DEBUG
						printf("LoadAndArm\n");
	#endif
						/* execute command */
						rl32eOutpB(base_addr+0x01,0x60 | (int_T)command[k+3]);
						break;

					case 23:	/* DisarmAndSave */
	#ifdef DEBUG
						printf("DisarmAndSave\n");
	#endif
						/* execute command */
						rl32eOutpB(base_addr+0x01,0x80 | (int_T)command[k+3]);
						break;


					case 30:	/* Load */
	#ifdef DEBUG
						printf("Load\n");
	#endif
						/* execute command */
						rl32eOutpB(base_addr+0x01,0x40 | (int_T)command[k+3]);
						break;


					case 31:	/* Save */
	#ifdef DEBUG
						printf("Save\n");
	#endif
						/* execute command */
						rl32eOutpB(base_addr+0x01,0x90 | (int_T)command[k+3]);
						break;

					case 40:	/* Set Toggle */
						
	#ifdef DEBUG
						printf("Set Toggle Output\n");
	#endif
						for (ctr=0; ctr<(int_T)command[k+2]; ctr++) {

							/* get counter */
							counter= (int_T)command[k+4+ctr]; 
							
							/* execute command */
							rl32eOutpB(base_addr+0x01,0xe8 | counter);
						}
						break;

					case 41:	/* Clear Toggle */
						
	#ifdef DEBUG
						printf("Clear Toggle Output\n");
	#endif
						for (ctr=0; ctr<(int_T)command[k+2]; ctr++) {

							/* get counter */
							counter= (int_T)command[k+4+ctr]; 
							
							/* execute command */
							rl32eOutpB(base_addr+0x01,0xe0 | counter);
						}
						break;


				}
			}
			k+= 14;
		}
	}

#endif

}

#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

