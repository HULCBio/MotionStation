/* $Revision: 1.3 $ $Date: 2003/01/22 20:18:05 $ */
/* AsciiDecode.c - xPC Target, non-inlined S-function for decoding
 * an ascii string to a scanf format  */
/* Copyright 1996-2003 The MathWorks, Inc.
*/

#define S_FUNCTION_LEVEL 2
#undef S_FUNCTION_NAME
#define S_FUNCTION_NAME asciiencode

#include <stddef.h>
#include <stdlib.h>

#include "tmwtypes.h"
#include "simstruc.h" 

#ifdef MATLAB_MEX_FILE
#include "mex.h"
#else
#include <windows.h>
#include <string.h>
#endif

/* Input Arguments */
#define NUMBER_OF_ARGS          (4)
#define FORMAT_REC_ARG          ssGetSFcnParam(S,0)
#define MAX_OUTPUT_ARG          ssGetSFcnParam(S,1)
#define NUM_IN_ARG              ssGetSFcnParam(S,2)
#define DTYPE_ARG               ssGetSFcnParam(S,3)

#define NO_I_WORKS              (0)
#define NO_R_WORKS              (0)
#define NO_P_WORKS              (1)

#define tmpsize                 128

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
    int_T i;
    int_T num_in;
    int_T max_out;

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);

    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S))
    {
        sprintf(msg,"Wrong number of input arguments passed.\n%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }

    num_in = (int)mxGetPr(NUM_IN_ARG)[0];

    /* Set-up size information */
    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    ssSetNumInputPorts(S, num_in);
  
    for(i = 0 ; i < num_in ; i++)
    {
        ssSetInputPortWidth(S, i, 1);
//printf("type[%d] = %d\n", i, mxGetPr(DTYPE_ARG)[i] );
        ssSetInputPortDataType(S, i, (int)mxGetPr(DTYPE_ARG)[i] );
        ssSetInputPortDirectFeedThrough( S, i, 1 );
    }

    ssSetNumOutputPorts(S, 1);
    max_out = (int_T)mxGetPr( MAX_OUTPUT_ARG )[0];
    ssSetOutputPortWidth( S, 0, max_out );
    ssSetOutputPortDataType( S, 0, SS_UINT8 );

    ssSetNumSampleTimes(S,1);
    ssSetNumIWork(S, NO_I_WORKS); 
    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumPWork(S, NO_P_WORKS);
    ssSetNumModes(         S, 0);
    ssSetNumNonsampledZCs( S, 0);

    for( i = 0 ; i < NUMBER_OF_ARGS ; i++ )
    {
        ssSetSFcnParamTunable(S,i,0);  /* None of the parameters are tunable */
    }

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE );
}
 
/* Function to initialize sample times */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
}

#define MDL_START
static void mdlStart(SimStruct *S)
{
    char *formatstringbuffer = malloc( mxGetN(FORMAT_REC_ARG)+1 );
    // Get storage 1 larger to account for the null terminator on the string.
    ssSetPWorkValue( S, 0, (void *)formatstringbuffer );
}

/* Function to compute outputs */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    int  fi, ini, found, k;
    char token[tmpsize];

    char tmp[tmpsize];
    char *outvec = (char *)ssGetOutputPortSignal( S, 0 );
    unsigned int maxlth = (unsigned int)mxGetPr( MAX_OUTPUT_ARG )[0];

    int j;
    int_T portindex = 0;
    int_T typeChar;
    char *formatstring = (char *)ssGetPWorkValue( S, 0 );

    mxGetString( FORMAT_REC_ARG, formatstring, mxGetN(FORMAT_REC_ARG)+1 );
//printf("\nformatstring = %s, ", formatstring );

    fi = 0;
    ini = fi;
    j = 0;
    k = 0;
    outvec[0] = '\0';

    for( j = 0 ; j < tmpsize ; j++ )
        tmp[j] = 0;

    while( fi < (int)strlen(formatstring) )
    {
//printf("fmt = %c\n", formatstring[fi] );
        if( formatstring[fi] == '%' )
        {
            // search format token
            typeChar = 0;

            found = 0;
            j = fi + 1;   // start with the next character
            k = 2;
            while (!found)
            {
                switch (formatstring[j])
                {
                  case 'c':
                  case 'C':
                    typeChar = 1;
                  case 'd':
                  case 'i':
                  case 'o':
                  case 'u':
                  case 'x':
                  case 'X':    
                    {
                        InputPtrsType uPtrs = ssGetInputPortSignalPtrs(S,portindex);
                        strncpy( token, formatstring + fi, k );
                        token[k] = '\0';
                        tmp[0] = '\0';
//printf("int: fi = %d, k = %d, token = %s\n", fi, k, token );
                        switch (ssGetInputPortDataType(S,portindex))
                        { 
                          case SS_INT8:
                            {
                              const int8_T *data = uPtrs[0];
                              sprintf(tmp, token, (int)*data);
                              break;
                            }
      		          case SS_UINT8:
                            {
                                const uint8_T *data = uPtrs[0];
                                sprintf(tmp, token, (int)*data);
                                break;
                            }
                          case SS_INT16:
                            {
                                const int16_T *data = uPtrs[0];
                                sprintf(tmp, token, (int)*data);
                                break;
                            }
      		          case SS_UINT16:
                            {
                                const uint16_T *data = uPtrs[0];
                                sprintf(tmp, token, (int)*data);
                                break;
                            }
                          case SS_INT32:
                            {
                                const int32_T *data = uPtrs[0];
                                sprintf(tmp, token, (int)*data);
                                break;
                            }
      		          case SS_UINT32:
                            {
                                const uint32_T *data = uPtrs[0];
                                sprintf(tmp, token, (int)*data);
                                break;
                            }
                          case SS_DOUBLE:
                            {
                                const double *data = uPtrs[0];
                                sprintf(tmp, token, (int)*data);
//printf("\ndata = %f, token = %s, tmp = %s", *data, token, tmp );
                                break;
                            }
                          case SS_SINGLE:
                            {
                                const float *data = uPtrs[0];
                                sprintf(tmp, token, (int)*data);
                                break;
                            }
                        }
                        if( strlen( tmp ) + strlen( outvec ) > maxlth )
                        {
                            sprintf( msg, "Converted string length exceeds specified output vector width" );
                            ssSetErrorStatus( S, msg );
                            return;
                        }
                        strcat( outvec, tmp );
           	        found=1;
                        portindex++;
                        break;
                    }
                  case 'e':
                  case 'E':
                  case 'f':
                  case 'g':
                  case 'G':
                    {
                        InputPtrsType uPtrs = ssGetInputPortSignalPtrs(S,portindex); 
       	   	        strncpy(token, formatstring+fi, k );
                        token[k] = '\0';
                        tmp[0] = '\0';
//printf("float: fi = %d, k = %d, token = %s, type = %d\n", fi, k, token, ssGetInputPortDataType(S,portindex) );
                        switch (ssGetInputPortDataType(S,portindex))
                        { 
                          case SS_INT8:
                            {
                                const int8_T *data = uPtrs[0];
                                sprintf(tmp, token, (double)*data);
                                break;
                            }
      		          case SS_UINT8:
                            {
                                const uint8_T *data = uPtrs[0];
                                sprintf(tmp, token, (double)*data);
                                break;
                            }
                          case SS_INT16:
                            {
                                const int16_T *data = uPtrs[0];
                                sprintf(tmp, token, (double)*data);
                                break;
                            }
      		          case SS_UINT16:
                            {
                                const uint16_T *data = uPtrs[0];
                                sprintf(tmp, token, (double)*data);
                                break;
                            }
                          case SS_INT32:
                            {
                                const int32_T *data = uPtrs[0];
                                sprintf(tmp, token, (double)*data);
                                break;
                            }
      		          case SS_UINT32:
                            {
                                const uint32_T *data = uPtrs[0];
                                sprintf(tmp, token, (double)*data);
                                break;
                            }
                          case SS_DOUBLE:
                            {
                                const double *data = uPtrs[0];
                                sprintf(tmp, token, (double)*data);
//printf("partial: lth = %d, tmp = %s\n", strlen(tmp), tmp );
                                break;
                            }
                          case SS_SINGLE:
                            {
                                const float *data = uPtrs[0];
                                sprintf(tmp, token, (double)*data);
                                break;
                            }
                        }
                        if( strlen( tmp ) + strlen( outvec ) > maxlth )
                        {
                            sprintf( msg, "Converted string length exceeds specified output vector width" );
                            ssSetErrorStatus( S, msg );
                            return;
                        }
                        strcat( outvec, tmp ); 
                        found=1;
                        portindex++;
                        break;
                    }					
                  default:
                    {
                        k++;
                        j++;
                        if( j > (int)strlen(formatstring) - 1 )
                        {
                            ssSetErrorStatus(S,"error in format string\n");
                            return;
                        }
                        break;
                    }
                }
            }
            // set new fi
            fi = j+1;
        } else
        {
            tmp[0] = formatstring[fi];
            tmp[1] = '\0';
            if( strlen( tmp ) + strlen( outvec ) > maxlth )
            {
                sprintf( msg, "Converted string length exceeds specified output vector width" );
                ssSetErrorStatus( S, msg );
                return;
            }
            strcat( outvec, tmp);
            fi++;
        }
    }
//printf("%d ", strlen(outvec) );
//printf("output: %s, lth = %d, last char = %d\n", outvec, strlen(outvec), outvec[strlen(outvec)-1] );
}

/* Function to perform housekeeping at execution termination */
static void mdlTerminate(SimStruct *S)
{
    char *formatstring = (char *)ssGetPWorkValue( S, 0 );
    if( formatstring )
        free( formatstring );
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
