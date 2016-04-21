/* $Revision: 1.2 $ $Date: 2003/01/22 20:18:07 $ */
/* decodestate.c - xPC Target, non-inlined S-function for retrieving
 * the state information from an rs232 data stream.  */
/* Copyright 1996-2003 The MathWorks, Inc.
*/

#define S_FUNCTION_LEVEL 2
#undef S_FUNCTION_NAME
#define S_FUNCTION_NAME decodestate

#include <stddef.h>
#include <stdlib.h>

#include "tmwtypes.h"
#include "simstruc.h" 

#ifdef MATLAB_MEX_FILE
#include "mex.h"
#else
#include <windows.h>
#include <string.h>
#include "serialdefines.h"
#endif

/* Input Arguments */
#define NUMBER_OF_ARGS          (5)
#define OVERRUN_ARG             ssGetSFcnParam(S,0)
#define PARITY_ARG              ssGetSFcnParam(S,1)
#define FRAME_ARG               ssGetSFcnParam(S,2)
#define BREAK_ARG               ssGetSFcnParam(S,3)
#define COUNT_ARG               ssGetSFcnParam(S,4)

#define NO_I_WORKS              (0)
#define NO_R_WORKS              (0)
#define NO_P_WORKS              (0)

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

    num_out = (int)mxGetPr(COUNT_ARG)[0];

    /* Set-up size information */
    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    ssSetNumOutputPorts(S, num_out);
  
    ssSetOutputPortWidth(S, 0, DYNAMICALLY_SIZED );
    ssSetOutputPortDataType(S, 0, SS_UINT8 );

    for( i = 1 ; i < num_out ; i++ )
    {
        ssSetOutputPortWidth(S, i, 1);
        ssSetOutputPortDataType(S, i, SS_BOOLEAN );
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
#define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth( SimStruct *S, int_T port, int_T width )
{
    ssSetInputPortWidth( S, port, width );
    ssSetOutputPortWidth( S, port, width );
}


#define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth( SimStruct *S, int_T port, int_T width )
{
    ssSetOutputPortWidth( S, port, width );
}

#define MDL_START
static void mdlStart(SimStruct *S)
{
}

/* Function to compute outputs */
static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    char *indata = (char *)ssGetInputPortSignal( S, 0 );
    char *outdata = (char *)ssGetOutputPortSignal( S, 0 );
    int_T inlength;
    DTypeId inType = ssGetInputPortDataType( S, 0 );
    int_T status = 0;
    short inword;
    int_T oport;
    bool *statout;
    int i;

//printf("decodestate enter\n");
    switch( inType )
    {
      case SS_INT16:
      case SS_UINT16:
        inlength = indata[0];
//printf("decode state: inlength = %d\n", inlength );
        if( inlength <= 0 )
        {
            outdata[0] = 0;  // Null terminate!
            return;
        }
        for( i = 0 ; i < inlength ; i++ )
        {
            inword = *(short *)(indata + (i+1)*2 );
//printf("%d ", inword );
            outdata[i] = inword & 0xff;
            status |= inword & 0xff00;
//printf("status = %x, ", status );
        }
//printf("\n");
        outdata[inlength] = 0;  // Null terminate!
//printf("decode out: %s\n", outdata );
        break;

      case SS_INT8:
      case SS_UINT8:
        status = 0;
        inlength = strlen( indata );
        if( inlength <= 0 )
        {
            outdata[0] = 0;  // Null terminate!
            return;
        }
        for( i = 0 ; i < inlength ; i++ )
            outdata[i] = indata[i];
        outdata[inlength] = 0;  // Null terminate!
        break;
    }
    status = status >> 8;

    oport = 1;
    if( (int)mxGetPr(OVERRUN_ARG)[0] )
    {
        statout = (bool *)ssGetOutputPortSignal( S, oport );
//printf("overrun: statout = 0x%x\n", statout );
        if( status & LSROE )
            *statout = true;
        else
            *statout = false;
        oport++;
    }
    if( (int)mxGetPr(PARITY_ARG)[0] )
    {
        statout = (bool *)ssGetOutputPortSignal( S, oport );
//printf("parity: statout = 0x%x\n", statout );
        if( status & LSRPE )
        {
            *statout = true;
//printf("parity: statout = 0x%x\n", statout );
        }
        else
        {
            *statout = false;
        }
        oport++;
    }
    if( (int)mxGetPr(FRAME_ARG)[0] )
    {
        statout = (bool *)ssGetOutputPortSignal( S, oport );
        if( status & LSRFE )
            *statout = true;
        else
            *statout = false;
        oport++;
    }
    if( (int)mxGetPr(BREAK_ARG)[0] )
    {
        statout = (bool *)ssGetOutputPortSignal( S, oport );
        if( status & LSRBI )
            *statout = true;
        else
            *statout = false;
    }
//printf("decodestate: exit\n");
#endif
}

/* Function to perform housekeeping at execution termination */
static void mdlTerminate(SimStruct *S)
{
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
