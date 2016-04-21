/* $Revision: 1.3 $ $Date: 2002/03/25 04:10:45 $ */
/* nigpibsetup.c - xPC Target, non-inlined S-function driver for setup of NI GPIB-232CT-A*/
/* Copyright 1996-2002 The MathWorks, Inc.
*/


#define S_FUNCTION_LEVEL 2
#undef  S_FUNCTION_NAME
#define S_FUNCTION_NAME  nigpibsetup

#include <stddef.h>
#include <stdlib.h>

#include "tmwtypes.h"
#include "simstruc.h" 

#ifdef MATLAB_MEX_FILE
#include "mex.h"
#else
#include <windows.h>
#include <string.h>
#include "rs232_xpcimport.h"
#include "time_xpcimport.h"
#endif

/* Input Arguments */
#define NUMBER_OF_ARGS        	(20)
#define GPIB_ID					ssGetSFcnParam(S,0)
#define PORT_ARG             	ssGetSFcnParam(S,1)
#define BAUDRATE_ARG 	        ssGetSFcnParam(S,2)
#define DATABIT_ARG           	ssGetSFcnParam(S,3)
#define STOPBIT_ARG             ssGetSFcnParam(S,4)
#define PARITY_ARG 	            ssGetSFcnParam(S,5)
#define PROTOCOL_ARG           	ssGetSFcnParam(S,6)
#define SENDBUF_ARG           	ssGetSFcnParam(S,7)
#define RECBUF_ARG           	ssGetSFcnParam(S,8)
#define WAIT_ARG				ssGetSFcnParam(S,9)
#define INIT_STRING				ssGetSFcnParam(S,10)
#define INIT_ACK				ssGetSFcnParam(S,11)
#define INIT_TIMEOUT            ssGetSFcnParam(S,12)
#define TERM_STRING				ssGetSFcnParam(S,13)
#define TERM_ACK				ssGetSFcnParam(S,14)
#define TERM_TIMEOUT            ssGetSFcnParam(S,15)
#define FORMAT_SEND_INFO_INIT	ssGetSFcnParam(S,16)
#define FORMAT_REC_INFO_INIT	ssGetSFcnParam(S,17)
#define FORMAT_SEND_INFO_TERM	ssGetSFcnParam(S,18)
#define FORMAT_REC_INFO_TERM	ssGetSFcnParam(S,19)

#define NO_I_WORKS              	(0)
#define NO_R_WORKS              	(0)

#define RECV_BUF_SIZE               65536

static char_T msg[256];

extern int rs232ports[];
extern int rs232recbufs[];

static void mdlInitializeSizes(SimStruct *S)
{

int_T num_channels, mux;

#ifndef MATLAB_MEX_FILE
#include "rs232_xpcimport.c"
#include "time_xpcimport.c"
#endif

#ifdef MATLAB_MEX_FILE
  ssSetNumSFcnParams(S, NUMBER_OF_ARGS);  /* Number of expected parameters */
  if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
    sprintf(msg,"Wrong number of input arguments passed.\n9 arguments are expected\n");
            ssSetErrorStatus(S,msg);
    return;
  }
   #endif

  ssSetNumContStates(S, 0);
  ssSetNumDiscStates(S, 0);
  ssSetNumOutputPorts(S, 0);
  ssSetNumInputPorts(S, 0);
  ssSetNumSampleTimes(S, 1);
  ssSetNumIWork(S, NO_I_WORKS); 
  ssSetNumRWork(S, NO_R_WORKS);
  ssSetNumPWork(S, 0);
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
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);

}

#define MDL_START  /* Change to #undef to remove function */
#if defined(MDL_START) 
static void mdlStart(SimStruct *S)
  {

#ifndef MATLAB_MEX_FILE
  char c;
  char in[128];
  char format_send[128];
  char format_rec[128];
  int h,i,j,k;
  int baudrates[]={38400,19200,9600,4800,2400,1200,300};
  int parities[]={0x100,0x200,0x400};
  int baudrate, parity, port;
  double starttime, setupTimeout;
  int lenStr = 0;
  int ini,ini2;
  char tempChar;

  port=((int_T)mxGetPr(PORT_ARG)[0])-1;
  //if (port==PORT) {
  //	printf("        GPIB I/O-Error: choosen COM-port used for host<->target communication\n");
  //	return;
  //}
  baudrate=baudrates[((int_T)mxGetPr(BAUDRATE_ARG)[0])-1];
  parity=parities[((int_T)mxGetPr(PARITY_ARG)[0])-1];

  rl32eInitCOMPort(	port,
				DefaultCOMIOBase[port],
				DefaultCOMIRQ[port],
				baudrate,
				parity,
				(int_T)mxGetPr(STOPBIT_ARG)[0],
				9-((int_T)mxGetPr(DATABIT_ARG)[0]),
				(int_T)mxGetPr(RECBUF_ARG)[0],
				(int_T)mxGetPr(SENDBUF_ARG)[0],
				((int_T)mxGetPr(PROTOCOL_ARG)[0])-1);

  rs232ports[port]=1;

  mxGetString(INIT_STRING, format_send, mxGetN(INIT_STRING)+1);
  mxGetString(INIT_ACK, format_rec, mxGetN(INIT_ACK)+1);
  
  ini = 0;
  ini2 = 0;
  if (strlen(format_send) > 0)
  {
    for (h=0;h<mxGetPr(FORMAT_SEND_INFO_INIT)[0];h++) {
	  if (mxGetPr(FORMAT_SEND_INFO_INIT)[h+1]>0) {
	    tempChar = format_send[ini+(int)mxGetPr(FORMAT_SEND_INFO_INIT)[h+1]];
        format_send[ini+(int)mxGetPr(FORMAT_SEND_INFO_INIT)[h+1]] = '\0';
        rl32eSendBlock(port,format_send , strlen(format_send));
	    while (!(rl32eLineStatus(port) & TX_SHIFT_EMPTY));
        format_send[ini+(int)mxGetPr(FORMAT_SEND_INFO_INIT)[h+1]] = tempChar;
	    ini = ini + mxGetPr(FORMAT_SEND_INFO_INIT)[h+1];
  	  }
      k = 0;
	  if (mxGetPr(FORMAT_REC_INFO_INIT)[h+1] > 0) {
	    tempChar = format_rec[ini2+(int)mxGetPr(FORMAT_REC_INFO_INIT)[h+1]];
        format_rec[ini2+(int)mxGetPr(FORMAT_REC_INFO_INIT)[h+1]] = '\0';
        if (k < RECV_BUF_SIZE) {
	      starttime=rl32eGetTicksDouble();
          setupTimeout = mxGetPr(INIT_TIMEOUT)[0];

	      lenStr = strlen(ini2+format_rec);

		  rl32eWaitDouble(0.01); //wait 

	      while (k<lenStr) {
	        k = rl32eReceiveBufferCount(port);
	        if (rl32eETimeDouble(rl32eGetTicksDouble(),starttime) > setupTimeout) {
		      ssSetErrorStatus(S,"GPIB Setup: Initialization ACK timeout");
		      return;
	        }
	      }
	      //Read excess data out of serial port
	      for (j=0;j<(k-lenStr);j++) {
	        c=rl32eReceiveChar(port);
	      }
	      for (j=0;j<lenStr;j++) {
	        c=rl32eReceiveChar(port);
	        if (( c & 0xff00)!=0) {
	          ssSetErrorStatus(S,"GPIB Setup: Receive error");
	          return;
	        }
	        in[j]=c;
            in[j+1]='\0';
	      }

          if (strcmp(in,ini2+format_rec)!=0) {
            ssSetErrorStatus(S,"GPIB Setup: Initialization ACK failed!");  
          }
        }
        format_rec[ini2+(int)mxGetPr(FORMAT_REC_INFO_INIT)[h+1]] = tempChar;
        ini2 = ini2 + mxGetPr(FORMAT_REC_INFO_INIT)[h+1];
	  }
    }
  }
#endif // Not MATLAB_MEX_FILE  
}
#endif /*  MDL_START */

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
#endif
}

static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
  char c;
  char in[128];
  char format_send[128];
  char format_rec[128];
  int h,i,j,k,port;
  double starttime, setupTimeout;
  int lenStr;
  int ini, ini2;
  char tempChar;

  port=((int_T)mxGetPr(PORT_ARG)[0])-1;


  mxGetString(TERM_STRING, format_send, mxGetN(TERM_STRING)+1);
  mxGetString(TERM_ACK, format_rec, mxGetN(TERM_ACK)+1);
  
  ini = 0;
  ini2 = 0;
  
  if (strlen(format_send) > 0)
  {
    for (h=0;h<mxGetPr(FORMAT_SEND_INFO_TERM)[0];h++) {
	  if (mxGetPr(FORMAT_SEND_INFO_TERM)[h+1]>0) {
	    tempChar = format_send[ini+(int)mxGetPr(FORMAT_SEND_INFO_TERM)[h+1]];
        format_send[ini+(int)mxGetPr(FORMAT_SEND_INFO_TERM)[h+1]] = '\0';
        rl32eSendBlock(port,format_send , strlen(format_send));
	    while (!(rl32eLineStatus(port) & TX_SHIFT_EMPTY));
        format_send[ini+(int)mxGetPr(FORMAT_SEND_INFO_TERM)[h+1]] = tempChar;
	    ini = ini + mxGetPr(FORMAT_SEND_INFO_TERM)[h+1];
  	  }
      k = 0;
	  if (mxGetPr(FORMAT_REC_INFO_TERM)[h+1] > 0) {
	    tempChar = format_rec[ini2+(int)mxGetPr(FORMAT_REC_INFO_TERM)[h+1]];
        format_rec[ini2+(int)mxGetPr(FORMAT_REC_INFO_TERM)[h+1]] = '\0';
        if (k < RECV_BUF_SIZE) {
	      starttime=rl32eGetTicksDouble();
          setupTimeout = mxGetPr(TERM_TIMEOUT)[0];

	      lenStr = strlen(ini2+format_rec);

		  rl32eWaitDouble(0.01); //wait 

	      while (k<lenStr) {
	        k = rl32eReceiveBufferCount(port);
	        if (rl32eETimeDouble(rl32eGetTicksDouble(),starttime) > setupTimeout) {
		      ssSetErrorStatus(S,"GPIB Setup: Termination ACK timeout");
		      return;
	        }
	      }
	      //Read excess data out of serial port
	      for (j=0;j<(k-lenStr);j++) {
	        c=rl32eReceiveChar(port);
	      }
	      for (j=0;j<lenStr;j++) {
	        c=rl32eReceiveChar(port);
	        if (( c & 0xff00)!=0) {
	          ssSetErrorStatus(S,"GPIB Setup: Receive error");
	          return;
	        }
	        in[j]=c;
            in[j+1]='\0';
	      }

          if (strcmp(in,ini2+format_rec)!=0) {
            ssSetErrorStatus(S,"GPIB Setup: Termination ACK failed!");  
          }
        }
        format_rec[ini2+(int)mxGetPr(FORMAT_REC_INFO_TERM)[h+1]] = tempChar;
        ini2 = ini2 + mxGetPr(FORMAT_REC_INFO_TERM)[h+1];
	  }
    }
  }

  rl32eCloseCOMPort(port);
  rs232ports[port]=0;
#endif
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
