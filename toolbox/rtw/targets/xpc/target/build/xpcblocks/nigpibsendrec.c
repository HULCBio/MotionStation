/* $Revision: 1.4 $ $Date: 2002/03/25 04:10:42 $ */
/* nigpibsendrec.c - xPC Target, non-inlined S-function driver for NI GPIB-232CT-A send/receive (synchronious)  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define S_FUNCTION_LEVEL 2
#undef S_FUNCTION_NAME
#define S_FUNCTION_NAME nigpibsendrec

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
#define NUMBER_OF_ARGS        	(12)
#define PORT_ARG				ssGetSFcnParam(S,0)
#define FORMAT_SEND_ARG        	ssGetSFcnParam(S,1)
#define FORMAT_REC_ARG        	ssGetSFcnParam(S,2)
#define IN_PORT_ARG				ssGetSFcnParam(S,3)
#define OUT_PORT_ARG			ssGetSFcnParam(S,4)
#define NUM_IN_ARG				ssGetSFcnParam(S,5)
#define NUM_OUT_ARG				ssGetSFcnParam(S,6)
#define FORMAT_SEND_INFO		ssGetSFcnParam(S,7)
#define FORMAT_REC_INFO			ssGetSFcnParam(S,8)
#define WAIT_ARG				ssGetSFcnParam(S,9)
#define DTYPE_ARG               ssGetSFcnParam(S,10)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,11)

#define NO_I_WORKS              	(0)
#define NO_R_WORKS              	(0)
#define NO_P_WORKS              	(3)

#define tmpsize 					128

#define RECV_BUF_SIZE               65536

#define RECV_OK					    0
#define RECV_TIMEOUT				1
#define RECV_ERROR					2
#define RECV_DATA_ERROR             3
#define RECV_BUF_OVERFLOW_ERROR     4

static char_T msg[256];

extern int rs232ports[];

static int datacount(char *formatstring)
{
  int i,n;

  n=0;
  for (i=0;i<strlen(formatstring);i++) {
	if (formatstring[i]=='%') n++;
  }
  return(n);
}

#ifndef MATLAB_MEX_FILE
static void build(SimStruct *S, char *formatstring, int port, int inputindex)
{

  int i, fi, j, found, k;
  char tmp[tmpsize];
  char token[tmpsize];
  char tmp_send[tmpsize];
  char tmp2[tmpsize];
  char tmp3[tmpsize];
  int_T portindex;

  strcpy (tmp_send,"");

  i=0;
  fi=0;
  k=0;
  j=0;

  while (fi<strlen(formatstring)) {
  	   if (formatstring[fi]=='%') {
  	        // search format token
	        found=0;
	        j=fi;
			k=0;
	      	while (!found) {
			  portindex = (int)mxGetPr(IN_PORT_ARG)[i+inputindex]-1;
			  switch (formatstring[j]) {
				  case 'c':
				  case 'C':
				  case 'd':
				  case 'i':
				  case 'o':
				  case 'u':
				  case 'x':
				  case 'X':	{
			   		InputPtrsType uPtrs= ssGetInputPortSignalPtrs(S,portindex); 
                    strncpy(token,formatstring+fi,k+1);
					token[k+1]='\0';
  			        switch (ssGetInputPortDataType(S,portindex)) { 
			          case SS_INT8: {
                        const int8_T *data = uPtrs[0];
				        sprintf(tmp,token,(int)*data);
                        break;
			          }
      		          case SS_UINT8: {
                        const uint8_T *data = uPtrs[0];
				        sprintf(tmp,token,(int)*data);
                        break;
                      }
			          case SS_INT16: {
                        const int16_T *data = uPtrs[0];
				        sprintf(tmp,token,(int)*data);
                        break;
			          }
      		          case SS_UINT16: {
                        const uint16_T *data = uPtrs[0];
				        sprintf(tmp,token,(int)*data);
                        break;
			          }
			          case SS_INT32: {
                        const int32_T *data = uPtrs[0];
				        sprintf(tmp,token,(int)*data);
                        break;
			          }
      		          case SS_UINT32: {
                        const uint32_T *data = uPtrs[0];
				        sprintf(tmp,token,(int)*data);
                        break;
			          }
                      case SS_DOUBLE: {
                        const double *data = uPtrs[0];
				        sprintf(tmp,token,(int)*data);
                        break;
			          }
				    }
                    strcat(tmp_send,tmp);
           	        found=1;
					break;
				  }
				  case 'e':
				  case 'E':
				  case 'f':
				  case 'g':
				  case 'G':	{
				    InputPtrsType uPtrs= ssGetInputPortSignalPtrs(S,portindex); 
       	   	        strncpy(token,formatstring+fi,k+1);
					token[k+1]='\0';
  			        switch (ssGetInputPortDataType(S,portindex)) { 
			          case SS_INT8: {
                        const int8_T *data = uPtrs[0];
				        sprintf(tmp,token,(double)*data);
                        break;
			          }
      		          case SS_UINT8: {
                        const uint8_T *data = uPtrs[0];
				        sprintf(tmp,token,(double)*data);
                        break;
                      }
			          case SS_INT16: {
                        const int16_T *data = uPtrs[0];
				        sprintf(tmp,token,(double)*data);
                        break;
			          }
      		          case SS_UINT16: {
                        const uint16_T *data = uPtrs[0];
				        sprintf(tmp,token,(double)*data);
                        break;
			          }
			          case SS_INT32: {
                        const int32_T *data = uPtrs[0];
				        sprintf(tmp,token,(double)*data);
                        break;
			          }
      		          case SS_UINT32: {
                        const uint32_T *data = uPtrs[0];
				        sprintf(tmp,token,(double)*data);
                        break;
			          }
                      case SS_DOUBLE: {
                        const double *data = uPtrs[0];
				        sprintf(tmp,token,(double)*data);
                        break;
			          }
				    }
                    strcat(tmp_send,tmp); 
         		    found=1;
					break;
			      }					
				  default: {
				  	k++;
				  	j++;
				  	if (j>strlen(formatstring)-1) {
	              		ssSetErrorStatus(S,"error in format string\n");
						return;
				  	}
				  	break;
				  }
	         	}
	     	}
	      	// set new fi
	      	fi=j+1;
	      	i++;
   		} else {
		  tmp3[0] = formatstring[fi];
          tmp3[1] = '\0';
          strcat(tmp_send,tmp3);
       	  fi++;
   		}
	}
  rl32eSendBlock(port,(void *) tmp_send, strlen(tmp_send));
}

static void extract(char *formatstring, char *in, SimStruct *S, int outputindex)
{

  int  i, fi, ini, found, k;
  char token[tmpsize];
  char endchar;
  char data_types[tmpsize];
  int type,inputType[tmpsize];
  int tmpi;
  float tmpd;
  int num_data, j;
  real_T            *yStatus;
  char tempRecChar;
  int_T portindex;

  i=0;
  fi=0;
  ini=fi;
  j=0;

  while (fi<=strlen(formatstring)) {
   	if (formatstring[fi]=='%') {
      // search format token
      found=0;
      j=fi;

	  while (!found) {
        switch (formatstring[j]) {
		  case 'c':
		  case 'C':
		  case 'd':
		  case 'i':
		  case 'o':
		  case 'u':
		  case 'x':
		  case 'X': {
            type=2; 
		    found=1;
		    break;
          }
          case 'e':
		  case 'E':
          case 'f': 
          case 'g':
          case 'G': {
         	type=1; 
			found=1;
			break;
          } 
		  default: {
	        j++;
    	    if (j>=strlen(formatstring)) {
        	  ssSetErrorStatus(S,"error in format string\n");
			  return;
            }
         	break;
		  }
		}
      }
      // token found
      // save it
      strncpy(token,formatstring+fi,j-fi+1);
	  token[j-fi+1]='\0';
            
      // endchar
      found=0;
      k=ini;
      while (!found) {
        if (k < RECV_BUF_SIZE) {
		  k++;
		  if (in[k]=='\r') {
			found=1;
			if ((in[k]=='\r')&&(in[k+1]=='\n')) {
			  k = k + 2;
			} else {
			  k++;
			}
		  }
          if (in[k]=='\0') {
			found=1;
			while (in[k]=='\0') {
			  k++;
			}
		  }	
        } else {
          ssSetErrorStatus(S,"GPIB Send/Rec: receive data error\n");
          return;
		}
      } 
      // save it
      tempRecChar = in[k];
	  in[k] ='\0';
      
	  portindex = (int)mxGetPr(OUT_PORT_ARG)[i+outputindex]-1;
	   
	  if (portindex >= 0)
	  {
		void *y= ssGetOutputPortSignal(S,portindex); 

		if (type==1) {
		  sscanf(in+ini,token,&tmpd);
		  switch (ssGetOutputPortDataType(S,portindex)) { 
			case SS_INT8: {
              int8_T *data = y;
              *data = (int8_T)tmpd;
              break;
			}
    		case SS_UINT8: {
              uint8_T *data = y;
              *data = (uint8_T)tmpd;
              break;
            }
			case SS_INT16: {
              int16_T *data = y;
              *data = (int16_T)tmpd;
              break;
			}
      		case SS_UINT16: {
              uint16_T *data = y;
              *data = (uint16_T)tmpd;
              break;
			}
			case SS_INT32: {
              int32_T *data = y;
              *data = (int32_T)tmpd;
              break;
			}
      		case SS_UINT32: {
              uint32_T *data = y;
              *data = (uint32_T)tmpd;
              break;
			}
            case SS_DOUBLE: {
              double *data = y;
              *data = (double)tmpd;
              break;
			}
		  }
		} else {
		  if (type == 2) {
			sscanf(in+ini,token,&tmpi);
  			switch (ssGetOutputPortDataType(S,portindex)) { 
			  case SS_INT8: {
                int8_T *data = y;
                *data = (int8_T)tmpi;
                break;
			  }
      		  case SS_UINT8: {
                uint8_T *data = y;
                *data = (uint8_T)tmpi;
                break;
              }
			  case SS_INT16: {
                int16_T *data = y;
                *data = (int16_T)tmpi;
                break;
			  }
      		  case SS_UINT16: {
                uint16_T *data = y;
                *data = (uint16_T)tmpi;
                break;
			  }
			  case SS_INT32: {
                int32_T *data = y;
                *data = (int32_T)tmpi;
                break;
			  }
      		  case SS_UINT32: {
                uint32_T *data = y;
                *data = (uint32_T)tmpi;
                break;
			  }
              case SS_DOUBLE: {
                double *data = y;
                *data = (double)tmpi;
                break;
			  }
			}
		  }      								   
      	}
	  }	
	  // set new ini and fi
	  in[k] = tempRecChar;
      fi=j;
      ini=k;
	  i++;
   	}
   	fi++;
  }
}
#endif

static void mdlInitializeSizes(SimStruct *S)
{
  int_T i, num_in, num_out,port;
  char_T *buffersend, *bufferrec;

#ifndef MATLAB_MEX_FILE
#include "rs232_xpcimport.c"
#include "time_xpcimport.c"
#endif


#ifdef MATLAB_MEX_FILE
  ssSetNumSFcnParams(S, NUMBER_OF_ARGS);  /* Number of expected parameters */
  if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
    sprintf(msg,"Wrong number of input arguments passed.\nFive arguments are expected\n");
    ssSetErrorStatus(S,msg);
    return;
  }
#endif

  num_in= mxGetPr(NUM_IN_ARG)[0];
  num_out= mxGetPr(NUM_OUT_ARG)[0];

  /* Set-up size information */
  ssSetNumContStates(S, 0);
  ssSetNumDiscStates(S, 0);
  ssSetNumOutputPorts(S, num_out);
  
  i = 0;
  while (i<(int)num_out) {
	ssSetOutputPortWidth(S, i, DYNAMICALLY_SIZED);
    ssSetOutputPortDataType(S, i, mxGetPr(DTYPE_ARG)[i]);
	i++;
  }

  ssSetNumInputPorts(S, num_in);

  i = 0;
  
  while (i<(int)num_in) {
	ssSetInputPortWidth(S, i, DYNAMICALLY_SIZED);
    ssSetInputPortDirectFeedThrough(S, i, 1);
    ssSetInputPortDataType(S, i, DYNAMICALLY_TYPED);
	i++;
  }

  ssSetNumSampleTimes(S,1);
  ssSetNumIWork(S, NO_I_WORKS); 
  ssSetNumRWork(S, NO_R_WORKS);
  ssSetNumPWork(S, NO_P_WORKS);
  ssSetNumModes(         S, 0);
  ssSetNumNonsampledZCs( S, 0);

  ssSetSFcnParamNotTunable(S,0);
  ssSetSFcnParamNotTunable(S,1);
  ssSetSFcnParamNotTunable(S,2);
  ssSetSFcnParamNotTunable(S,3);
  ssSetSFcnParamNotTunable(S,4);

  ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
}
 
/* Function to initialize sample times */
static void mdlInitializeSampleTimes(SimStruct *S)
{
  ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME_ARG)[0]);
  if (mxGetN((SAMP_TIME_ARG))==1) {
	ssSetOffsetTime(S, 0, 0.0);
  } else {
    ssSetOffsetTime(S, 0, mxGetPr(SAMP_TIME_ARG)[1]);
  }
}
 
 

#define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth(SimStruct *S, int portIndex, int inWidth)
{
  ssSetInputPortWidth(S, portIndex, inWidth);
}

#define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth(SimStruct *S, int portIndex, int outWidth)
{
  ssSetOutputPortWidth(S, portIndex, outWidth);
}


#define MDL_SET_WORK_WIDTHS
static void mdlSetWorkWidths(SimStruct *S)
{
  int port;

  for (port=0; port < ssGetNumOutputPorts(S); port++) {
	switch (ssGetOutputPortDataType( S, port)) {
	  case SS_INT8:
      case SS_UINT8:
	  case SS_INT16:
      case SS_UINT16:
	  case SS_INT32:
      case SS_UINT32:
      case SS_DOUBLE: 
      break;
      default:
        ssSetErrorStatus(S, "Output signal(s) must be one of the types: "
                         "int8, uint8, int16, uint16, int32, uint32, double.\n" 
                         "Suggest using a data type conversion block "
                         "after the output." );
     
    }
  }
}

#define MDL_START  /* Change to #undef to remove function */
#if defined(MDL_START) 
static void mdlStart(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE

  char_T *buffer;

  //printf("%d\n",mxGetN(FORMAT_SEND_ARG)+1);
  buffer=(char *)calloc(mxGetN(FORMAT_SEND_ARG)+1,sizeof(char));
  if (buffer==NULL) {
	ssSetErrorStatus(S,"GPIB Send/Rec: could not allocate memory\n");
	return;
  }
  mxGetString(FORMAT_SEND_ARG, buffer, mxGetN(FORMAT_SEND_ARG)+1);
  //printf("%s\n",buffer);
  ssSetPWorkValue(S,0,(void *)buffer);

  buffer=(char *)calloc(mxGetN(FORMAT_REC_ARG)+1,sizeof(char));
  if (buffer==NULL) {
	ssSetErrorStatus(S,"GPIB Send/Rec: could not allocate memory\n");
	return;
  }
  mxGetString(FORMAT_REC_ARG, buffer, mxGetN(FORMAT_REC_ARG)+1);
  ssSetPWorkValue(S,1,(void *)buffer);

  buffer=(char *)calloc(RECV_BUF_SIZE,sizeof(char));
  if (buffer==NULL) {
	ssSetErrorStatus(S,"GPIB Send/Rec: could not allocate memory\n");
	return;
  }
  *buffer='\0';
  ssSetPWorkValue(S,2,(void *)buffer);

#endif	
}
#endif

/* Function to compute outputs */
static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE

  int_T port;
  int h, i, j, k, n, received, ini, ini2;
  char *in;
  char *format_send, *format_rec;
  char c;
  int receivesize = mxGetPr(FORMAT_SEND_INFO)[0];
  float delay;
  char tempChar;
  int inputindex = 0;
  int outputindex = 0;

  port=((int_T)mxGetPr(PORT_ARG)[0])-1;
  if (!rs232ports[port]) {
	ssSetErrorStatus(S,"        GPIB Send/Rec: choosen COM-port not initialized\n");
	return;
  }

  format_send=(char *)ssGetPWorkValue(S,0);
  format_rec=(char *)ssGetPWorkValue(S,1);
  in=(char *)ssGetPWorkValue(S,2);

  ini = 0;
  ini2 = 0;

  for (h=0;h<mxGetPr(FORMAT_SEND_INFO)[0];h++) {
	if (mxGetPr(FORMAT_SEND_INFO)[h+1]>0) {
	  tempChar = format_send[ini+(int)mxGetPr(FORMAT_SEND_INFO)[h+1]];
      format_send[ini+(int)mxGetPr(FORMAT_SEND_INFO)[h+1]] = '\0';
      build(S, format_send+ini, port,inputindex);
	  inputindex = inputindex + datacount(format_send+ini);
      format_send[ini+(int)mxGetPr(FORMAT_SEND_INFO)[h+1]] = tempChar;
	  ini = ini + mxGetPr(FORMAT_SEND_INFO)[h+1];
	  delay = mxGetPr(WAIT_ARG)[h];
	  if (delay>0.0) {
	    rl32eWaitDouble(delay);
	  }
  	}
    k = 0;
    received = 0;
	if (mxGetPr(FORMAT_REC_INFO)[h+1] > 0) {
	  tempChar = format_rec[ini2+(int)mxGetPr(FORMAT_REC_INFO)[h+1]];
      format_rec[ini2+(int)mxGetPr(FORMAT_REC_INFO)[h+1]] = '\0';
      while (received<datacount(format_rec+ini2)) {
        if (k < RECV_BUF_SIZE) {
	      i = rl32eReceiveBufferCount(port);
	      if (i>0) {
	        c=rl32eReceiveChar(port);
            in[k]=c;
	        in[k+1]='\0';
		    if (in[k]==',') {
		      received++;
	        }
	        if (in[k]=='\r') {
		      received++;
		      //all \r are followed by \n this reads the \n
		      if (i>1) {
		        k++;
	            c=rl32eReceiveChar(port);
                in[k]=c;
	            in[k+1]='\0';
	          }  
	        }
            if (in[k]=='\0') {
	          if (k>0) {
		        if (in[k-1]!='\0') {
		          received++;
		        }
	          }
	        }	
	        k++;
          }
        } else {
          ssSetErrorStatus(S,"GPIB Send/Rec: receive data error\n");
          return;
        }
      }   
      if (received>0) {
        extract(format_rec+ini2,in, S,outputindex);
      }
	  outputindex = outputindex + datacount(format_rec+ini2);
      format_rec[ini2+(int)mxGetPr(FORMAT_REC_INFO)[h+1]] = tempChar;
      ini2 = ini2 + mxGetPr(FORMAT_REC_INFO)[h+1];
	}
  }
#endif
}

/* Function to perform housekeeping at execution termination */
static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
  char *buffer;

  buffer=(char *)ssGetPWorkValue(S,0);
  if (buffer!=NULL) {
  	free(buffer);
  }

  buffer=(char *)ssGetPWorkValue(S,1);
  if (buffer!=NULL) {
	free(buffer);
  }

  buffer=(char *)ssGetPWorkValue(S,2);
  if (buffer!=NULL) {
	free(buffer);
  }
#endif
}

#ifdef	MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
