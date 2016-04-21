/* $Revision: 1.3 $ $Date: 2003/01/22 20:18:02 $ */
/* AsciiDecode.c - xPC Target, non-inlined S-function for decoding
 * an ascii string to a scanf format  */
/* Copyright 1996-2003 The MathWorks, Inc.
*/

#define S_FUNCTION_LEVEL 2
#undef S_FUNCTION_NAME
#define S_FUNCTION_NAME asciidecode

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
#define NUMBER_OF_ARGS          (3)
#define FORMAT_REC_ARG          ssGetSFcnParam(S,0)
#define NUM_OUT_ARG             ssGetSFcnParam(S,1)
#define DTYPE_ARG               ssGetSFcnParam(S,2)

#define NO_I_WORKS              (4)
#define NO_R_WORKS              (0)
#define NO_P_WORKS              (2)

#define tmpsize                 128

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
    int_T i;
    int_T num_out;

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);

    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S))
    {
        sprintf(msg,"Wrong number of input arguments passed.\n%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }

    num_out = (int)mxGetPr(NUM_OUT_ARG)[0];

    /* Set-up size information */
    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    ssSetNumOutputPorts(S, num_out);
  
    i = 0;
    while (i<(int)num_out)
    {
        ssSetOutputPortWidth(S, i, 1);
        ssSetOutputPortDataType(S, i, (int)mxGetPr(DTYPE_ARG)[i]);
        i++;
    }

    ssSetNumInputPorts(S, 1);
    ssSetInputPortWidth( S, 0, DYNAMICALLY_SIZED);
    ssSetInputPortDataType( S, 0, DYNAMICALLY_TYPED );
    ssSetInputPortDirectFeedThrough( S, 0, 1 );
    ssSetInputPortRequiredContiguous( S, 0, 1 );

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

#define MDL_SET_INPUT_PORT_DATA_TYPE
static void mdlSetInputPortDataType( SimStruct *S, int_T port, DTypeId id )
{
    if( id == SS_INT16 || id == SS_UINT16 || id == SS_INT8 || id == SS_UINT8 )
        ssSetInputPortDataType( S, port, id );
    else
    {
        sprintf( msg, "Input must be either 8 or 16 bit integers." );
        ssSetErrorStatus(S,msg);
        return;
    }        
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
    char endchar;
    int type;
    int tmpi;
    float tmpd;
    int j;
    char tempRecChar;
    int_T typeChar;
    char *formatstring = (char *)ssGetPWorkValue( S, 0 );
    int fmtcount;
    char *in;
    char *data = (char *)ssGetInputPortSignal( S, 0 );
    int_T inlength;
    DTypeId inType = ssGetInputPortDataType( S, 0 );

    switch( inType )
    {
      case SS_INT16:
      case SS_UINT16:
        inlength = *(short *)data; // data[0];
        if( inlength <= 0 )
            return;
        in = (char *)malloc( inlength+1 );
        for( j = 0 ; j < inlength ; j++ )
        {
            in[j] = data[2*(j+1)] & 0xff;
        }
        in[j+1] = 0;
        break;

      case SS_INT8:
      case SS_UINT8:
        inlength = strlen( data );
        if( inlength <= 0 )
            return;
        in = (char *)malloc( inlength );
        for( j = 0 ; j < inlength ; j++ )
            in[j] = data[j];
        break;
    }

//printf("input: %s\n", in );
    mxGetString( FORMAT_REC_ARG, formatstring, mxGetN(FORMAT_REC_ARG)+1 );

    fmtcount = 0;
    fi = 0;
    ini = fi;
    j = 0;
    k = 0;

//    if( inlength <= 0 )
//        return;

    while (fi <= (int)strlen(formatstring))
    {
        if (formatstring[fi] == '%')
        {
            // search format token
            found = 0;
            j = fi + 1;

            typeChar = 0;  

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
                        type = 2; 
                        found = 1;
                        break;
                    }
                  case 'e':
                  case 'E':
                  case 'f': 
                  case 'g':
                  case 'G':
                    {
                        type = 1; 
                        found = 1;
                        break;
                    } 
                  default:
                    {
                        j++;
                        if (j >= (int)strlen(formatstring))
                        {
                            ssSetErrorStatus(S,"error in format string\n");
                            return;
                        }
                        break;
                    }
                }
            }


            // token found
            // save it
            strncpy( token, formatstring+fi, j-fi+1 );
            token[j-fi+1] = '\0';
            // endchar
            if ((int)strlen(formatstring) > j)
            {
                endchar = formatstring[j+1];
            }

            found=0;
            if (ini == 0)
            {
                ini = fi;
            }

            k = ini;
            while (!found)
            {
                if (k < inlength)
                {
                    k++;

                    if (typeChar)
                    {
                        found=1;
                    }  

                    if (in[k]==endchar)
                    {
                        found=1;
                    }
                    if (in[k]=='\r')
                    {
                        found=1;
                        if ((in[k]=='\r')&&(in[k+1]=='\n'))
                        {
                            k = k + 1; 
                        }
                    }
                    if (in[k]=='\0')
                    {
                        found=1;
                    }
                } else {
                    ssSetErrorStatus(S,"RS232 Send/Rec: receive data error");
                    return;
                }
            }
      
            // save it
            tempRecChar = in[k];
            in[k] ='\0';

            if ( fmtcount >= 0)
            {
                void *y = ssGetOutputPortSignal( S, fmtcount ); 

                if (type == 1)
                {
                    sscanf( in+ini, token, &tmpd );
                    switch (ssGetOutputPortDataType( S, fmtcount ))
                    {
                      case SS_INT8:
                        {
                            int8_T *data = y;
                            *data = (int8_T)tmpd;
                            break;
                        }
                      case SS_UINT8:
                        {
                            uint8_T *data = y;
                            *data = (uint8_T)tmpd;
                            break;
                        }
                      case SS_INT16:
                        {
                            int16_T *data = y;
                            *data = (int16_T)tmpd;
                            break;
                        }
                      case SS_UINT16:
                        {
                            uint16_T *data = y;
                            *data = (uint16_T)tmpd;
                            break;
                        }
                      case SS_INT32:
                        {
                            int32_T *data = y;
                            *data = (int32_T)tmpd;
                            break;
                        }
                      case SS_UINT32:
                        {
                            uint32_T *data = y;
                            *data = (uint32_T)tmpd;
                            break;
                        }
                      case SS_DOUBLE:
                        {
                            double *data = y;
                            *data = (double)tmpd;
                            break;
                        }
                      case SS_SINGLE:
                        {
                            float *data = y;
                            *data = (float)tmpd;
                            break;
                        }
                    }
                } else
                {
                    if (type == 2)
                    {
                        char tmpc; 
                        if (typeChar)
                        {
                            sscanf( in+ini, token, &tmpc);
                            tmpi = tmpc;
                        } else 
                        {
                            sscanf( in+ini, token, &tmpi);
                        }  
                        switch (ssGetOutputPortDataType( S, fmtcount ))
                        { 
                          case SS_INT8:
                            {
                                int8_T *data = y;
                                *data = (int8_T)tmpi;
                                break;
                            }
                          case SS_UINT8:
                            {
                                uint8_T *data = y;
                                *data = (uint8_T)tmpi;
                                break;
                            }
                          case SS_INT16:
                            {
                                int16_T *data = y;
                                *data = (int16_T)tmpi;
                                break;
                            }
                          case SS_UINT16:
                            {
                                uint16_T *data = y;
                                *data = (uint16_T)tmpi;
                                break;
                            }
                          case SS_INT32:
                            {
                                int32_T *data = y;
                                *data = (int32_T)tmpi;
                                break;
                            }
                          case SS_UINT32:
                            {
                                uint32_T *data = y;
                                *data = (uint32_T)tmpi;
                                break;
                            }
                          case SS_DOUBLE:
                            {
                                double *data = y;
                                *data = (double)tmpi;
                                break;
                            }
                          case SS_SINGLE:
                            {
                                float *data = y;
                                *data = (float)tmpi;
                                break;
                            }
                        }
                    }
                }
            }
            // set new ini and fi
            in[k] = tempRecChar;
            fi=j;
            if (typeChar)
            {
                ini=k;
            } else
            {
                ini=k-1;
            }
            fmtcount++;
        }
        fi++;
        ini++;
    }
    free( in );
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
