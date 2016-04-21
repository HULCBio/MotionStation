/* $Revision: 1.3 $ $Date: 2003/04/24 18:17:20 $ */
/* fiforead.c - xPC Target, non-inlined S-function to perform the write
 * side of a fifo read/write pair */
/* Copyright 1996-2003 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         fiforead

#include        <stddef.h>
#include        <stdlib.h>

#include        "simstruc.h"

#ifdef          MATLAB_MEX_FILE
#include        "mex.h"
#endif

#ifndef         MATLAB_MEX_FILE
#include        <windows.h>
#endif



/* Input Arguments */
#define NUMBER_OF_ARGS          (8)
#define MAX_WIDTH_ARG           ssGetSFcnParam(S,0)
#define MIN_READ_ARG            ssGetSFcnParam(S,1)
#define USE_DELIM_ARG           ssGetSFcnParam(S,2)
#define DELIM_ARG               ssGetSFcnParam(S,3)
#define TYPE_ARG                ssGetSFcnParam(S,4)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,5)
#define ENABLE_ARG              ssGetSFcnParam(S,6)
#define ENABLE_OUT_ARG          ssGetSFcnParam(S,7)

#define NO_I_WORKS              (0)
#define NO_R_WORKS              (0)

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{

    int i;
    int maxwidth;
    int outdatatype;
    int type;
    int enable;
    int enableout;

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"Wrong number of input arguments passed.\n%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }
//printf("mdlinitialize sizes: fiforead\n");
    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    enable = (int)mxGetPr( ENABLE_ARG )[0];
//printf("enable = %d\n", enable );
    if( enable == 1 )
    {
        ssSetNumInputPorts(S, 3);
        // port 1 is the maximum read size
        ssSetInputPortWidth(S, 1, 1 );
        ssSetInputPortRequiredContiguous( S, 1, 1 ); 
        ssSetInputPortDataType( S, 1, SS_UINT32 );
        ssSetInputPortDirectFeedThrough( S, 1, 1 );
        // port 2 is the minimum read size
        ssSetInputPortWidth(S, 2, 1 );
        ssSetInputPortRequiredContiguous( S, 2, 1 ); 
        ssSetInputPortDataType( S, 2, SS_UINT32 );
        ssSetInputPortDirectFeedThrough( S, 2, 1 );
    }
    else
        ssSetNumInputPorts(S, 1);

    // port 0 is the fifo data
    ssSetInputPortWidth(S, 0, DYNAMICALLY_SIZED);
    ssSetInputPortDataType( S, 0, SS_UINT32 );
    ssSetInputPortRequiredContiguous( S, 0, 1 ); 
    ssSetInputPortDirectFeedThrough( S, 0, 1 );

    enableout = (int)mxGetPr( ENABLE_OUT_ARG )[0];
    if( enableout == 1 )
    {
        ssSetNumOutputPorts(S, 2);
        ssSetOutputPortWidth(S, 1, 1 );
        ssSetOutputPortDataType( S, 1, SS_UINT32 );
    }
    else
        ssSetNumOutputPorts(S, 1);
    // port 0 is the data read from the fifo
    maxwidth = (int)mxGetPr( MAX_WIDTH_ARG )[0];
    ssSetOutputPortWidth(S, 0, maxwidth + 1 );

    // This switch has to agree with the popup list in the mask editor
    // for the output vector type.
    outdatatype = (int)mxGetPr( TYPE_ARG )[0];
//printf("outdatatype = %d\n", outdatatype );
    switch( outdatatype )
    {
      case 1:
        type = SS_INT32;
        break;
      case 2:
        type = SS_UINT32;
        break;
      case 3:
        type = SS_INT16;
        break;
      case 4:
        type = SS_UINT16;
        break;
      case 5:
        type = SS_INT8;
        break;
      case 6:
        type = SS_UINT8;
        break;
    }
    ssSetOutputPortDataType( S, 0, type );

    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumPWork(S, 0);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    for( i = 0 ; i < NUMBER_OF_ARGS ; i++ )
    {
        ssSetSFcnParamTunable(S,i,0);  /* None of the parameters are tunable */
    }

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE |
                    SS_OPTION_NONSTANDARD_PORT_WIDTHS ); // |
//                    SS_OPTION_ASYNC_RATE_TRANSITION );
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
//printf("mdlinitialize sample times\n");
    if (mxGetPr(SAMP_TIME_ARG)[0]==-1.0)
    {
        ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
        ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
    }
    else
    {
        ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME_ARG)[0]);
        ssSetOffsetTime(S, 0, 0.0);
    }
//printf("init sample times exit\n");
}

#define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth( SimStruct *S, int_T port, int_T width )
{
//printf("mdlSetInputPortWidth: port %d, width %d\n", port, width );
    ssSetInputPortWidth( S, port, width );
}

#define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth( SimStruct *S, int_T port, int_T width )
{
//printf("mdlSetOutputPortWidth: port %d, width %d\n", port, width );
}

#define MDL_START
static void mdlStart(SimStruct *S)
{
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
    // This block uses the output arrays as persistent storage between
    // calls.

    int_T *Fifo = (int_T *)ssGetInputPortSignal(S,0);
    int_T *rptr = &Fifo[0];
    int_T *wptr = &Fifo[1];
    int_T *data = &Fifo[2];
    int fifosize = ssGetInputPortWidth(S,0) - 2;
    int fifocount;
    int enable = (int)mxGetPr( ENABLE_ARG )[0];
    int outenable = (int)mxGetPr( ENABLE_OUT_ARG )[0];
    bool *outebl;

    void  *DPtr     =  (void *)ssGetOutputPortSignal(S,0);
    int   *intPtr   =   (int *)DPtr;   // types 1 and 2
    short *shortPtr = (short *)DPtr;   // types 3 and 4
    char  *charPtr  =  (char *)DPtr;   // types 5 and 6

    // Count is placed in the first element of output array, but only for types
    // 1-4.
    int *intCtr = (int_T *)DPtr;
    short *shortCtr = (short *)DPtr;

    int maxenabled;
    int maxread = (int)mxGetPr( MAX_WIDTH_ARG )[0];
    int minread = (int)mxGetPr( MIN_READ_ARG )[0];
    int usedelim = (int)mxGetPr( USE_DELIM_ARG )[0];
    int delim = (int)mxGetPr( DELIM_ARG )[0];
    int type = (int)mxGetPr( TYPE_ARG )[0];
    int i;

    fifocount = *wptr - *rptr;
    if( fifocount < 0 )
        fifocount += fifosize;

    switch( type )
    {
      case 1:  // int32
      case 2:  // uint32
        // i == 0 covers the count.
        for( i = 0 ; i < maxread+1 ; i++ )
        {
            intPtr[i] = 0;  // Clear for debugging output
        }
        break;
      case 3:  // int16
      case 4:  // uint16
        // i == 0 covers the count
        for( i = 0 ; i < maxread+1 ; i++ )
        {
            shortPtr[i] = 0;  // Clear for debugging output
        }
        break;
      case 5:  // int8
      case 6:  // uint8
        // maxread+1 covers the last possible null terminator
        for( i = 0 ; i < maxread+1 ; i++ )
        {
            charPtr[i] = 0;  // Clear for debugging output
        }
        break;
    }

    // If we exit here, the output count is 0.

    if( outenable )
        outebl = (bool *)ssGetOutputPortSignal(S,1);

    if( enable == 1 )
    {
        if( (maxenabled = *(int *)ssGetInputPortSignal(S,1)) <= 0 )
        {
            if( outenable )
                *outebl = 0;
            return;
        }
        if( maxenabled < maxread )
            maxread = maxenabled;
        if( outenable )
            *outebl = maxread;
        // If the min port is turned on, it overrides the value in the mask.
        minread = *(int *)ssGetInputPortSignal(S, 2 );
    }

    if( usedelim == 0 )  // Return maxread elements if enough available.
    {
        if( fifocount < minread )
        {
            return;
        }

        // return at least minread, but no more than maxread.
        for( i = 0 ; i < maxread && i < fifocount ; i++ )
        {
            int_T value = data[ *rptr ];
            data[*rptr] = 0;  // clear the stale data from the fifo
            switch( type )
            {
              case 1:  // int32
              case 2:  // uint32
                intPtr[i+1] = value;
                (*intCtr)++;
                break;
              case 3:  // int16
              case 4:  // uint16
                shortPtr[i+1] = value & 0xffff;
                (*shortCtr)++;
                break;
              case 5:  // int8
              case 6:  // uint8
                charPtr[i] = value & 0xff;
                break;
            }
            *rptr = (*rptr + 1)%fifosize;
        }
        if( type == 5 || type == 6 )
            charPtr[i+1] = 0;  // Null terminator for strings
    }
    else  // else return up to and including the stated delimiter if found.
        // limited by maxread.
    {
        int delimfound = 0;
        int delimindex;
        int maxcount = (fifocount < maxread) ? fifocount : maxread;

//printf("%d ", maxcount );
        for( delimindex = 0 ; delimindex < maxcount ; delimindex++ )
        {
            int loc = (*rptr + delimindex);
            if( loc >= fifosize )
                loc -= fifosize;
            // since data in the fifo is always a 32 bit int, we don't have
            // to use the output data types here.

            if( (data[loc] & 0xff) == delim )
            {
//printf("d");
                delimfound = 1;
                break;
            }

            // The following is only useful for the RS232 read system!
            if( data[loc] & 0xff00 ) // error byte is set
            {
                delimfound = 1;
            }
        }

        if( delimfound == 0 )
        {
            return;  // Didn't find the delimiter, return nothing.
        }

        for( i = 0 ; i <= delimindex ; i++ )
        {
            int value = data[ *rptr ];

            data[*rptr] = 0;  // clear the stale data
            switch( type )
            {
              case 1:  // int32
              case 2:  // uint32
                intPtr[i+1] = value;
                (*intCtr)++;
                break;
              case 3:  // int16
              case 4:  // uint16
                shortPtr[i+1] = value & 0xffff;
                (*shortCtr)++;
                break;
              case 5:  // int8
              case 6:  // uint8
                charPtr[i] = value & 0xff;
                break;
            }
            *rptr = (*rptr + 1)%fifosize;
        }
        if( type == 5 || type == 6 )
            charPtr[i+1] = 0;  // Null terminator for strings
    }
}

static void mdlTerminate(SimStruct *S)
{
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
