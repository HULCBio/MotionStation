/* $Revision: 1.2.6.1 $ $Date: 2003/09/02 01:14:56 $ */
/* fifowrite.c - xPC Target, non-inlined S-function to perform the write
 * side of a fifo read/write pair */
/* Copyright 1996-2003 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         fifowrite

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
#define NUMBER_OF_ARGS          (5)
#define SIZE_ARG                ssGetSFcnParam(S,0)
#define TYPE_ARG                ssGetSFcnParam(S,1)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,2)
#define DATA_PRESENT_ARG        ssGetSFcnParam(S,3)
#define ID_ARG                  ssGetSFcnParam(S,4)

#define NO_I_WORKS              (0)
#define NO_R_WORKS              (0)

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{

    int i;
    int width;
    int intype;
    int type;
    int presence;

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"Wrong number of input arguments passed.\n%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    presence = (int)mxGetPr( DATA_PRESENT_ARG )[0];

    if( presence == 1 )
    { 
        ssSetNumOutputPorts(S, 2);
        ssSetOutputPortWidth(S, 1, 1 );
        ssSetOutputPortDataType( S, 1, SS_BOOLEAN );
    }else
        ssSetNumOutputPorts(S, 1);

    width = (int)mxGetPr( SIZE_ARG )[0];
    // Set the output vector width to the fifo size plus 2 places for the
    // pointers.  Read is index 0, write is index 1
    ssSetOutputPortWidth(S, 0, width + 2);
    ssSetOutputPortDataType( S, 0, SS_UINT32 );

    ssSetNumInputPorts(S, 1);
    ssSetInputPortRequiredContiguous( S, 0, 1 ); 
    ssSetInputPortWidth(S, 0, DYNAMICALLY_SIZED);
    intype = (int)mxGetPr( TYPE_ARG )[0];
    type = SS_DOUBLE;
    switch( intype )
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
    ssSetInputPortDataType( S, 0, type );
    ssSetInputPortDirectFeedThrough( S, 0, 1 );

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
                    SS_OPTION_NONSTANDARD_PORT_WIDTHS );
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
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
}

#define MDL_SET_INPUT_PORT_WIDTH
static void mdlSetInputPortWidth( SimStruct *S, int_T port, int_T width )
{
    ssSetInputPortWidth( S, port, width );
}

#define MDL_SET_OUTPUT_PORT_WIDTH
static void mdlSetOutputPortWidth( SimStruct *S, int_T port, int_T width )
{
}

#define MDL_START
static void mdlStart(SimStruct *S)
{
    int i;
    int size;
    int_T *OPtr = ssGetOutputPortSignal(S,0);

    // Clear the FIFO data
    size = (int)mxGetPr( SIZE_ARG )[0];
    for( i = 0 ; i < size+2 ; i++ )
        OPtr[i] = 0;
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
    // This block uses the output arrays as persistent storage between
    // calls.

    int_T *Fifo = ssGetOutputPortSignal(S,0);
    int_T *rptr = &Fifo[0];
    int_T *wptr = &Fifo[1];
    void *IPtr = (void *)ssGetInputPortSignal(S,0);
    int_T incount;
    int_T *intdata   = (int *)IPtr + 1;
    short *shortdata = (short *)IPtr + 1;
    char  *chardata  = (char *)IPtr;
    int_T size = (int_T)mxGetPr( SIZE_ARG )[0];
    int space;
    int count;
    int i;
    int type = (int)mxGetPr( TYPE_ARG )[0];
    int inwidth = ssGetInputPortWidth(S,0);
    int presenceflag = (int)mxGetPr( DATA_PRESENT_ARG )[0];
    int_T *presenceout;

    // We can't fill the last spot or the write pointer would become
    // equal to the read pointer and the fifo would look empty.  Hence
    // the -1 when computing the space available in the fifo.
    // Computing the difference mod size takes wraparound into account.
    count = *wptr - *rptr;
    if( count < 0 )
        count += size;
    space = size - count - 1;

    incount = 0;  // Character input arrays don't receive incount.
    switch( type )
    {
      case 1:  // int 32
      case 2:  // uint 32
        incount = *(int *)IPtr;
        break;

      case 3:  // int 16
      case 4:  // uint 16
        incount = *(short *)IPtr;
        break;

      case 5:  // int 8
      case 6:  // uint 8
        for( incount = 0 ; incount <= inwidth ; incount++ )
        {
            if( chardata[incount] == 0 )
                break;
        }
//printf("incount = %d, space = %d\n", incount, space );
        break;
    }

    if( incount > space )
    {
	int lid = mxGetN( ID_ARG ) + 1;
	char *idtmp;
        if( presenceflag )
        {
            presenceout = ssGetOutputPortSignal(S,1);
        }
	idtmp = malloc(lid);
	mxGetString( ID_ARG, idtmp, lid );
        sprintf(msg,"FIFO overflow: %s", idtmp);
	free(idtmp);
        ssSetErrorStatus(S,msg);
        return;
    }

    if( incount > inwidth )
    {
        sprintf(msg,"Input port width is less than the input count, inconsistent");
        ssSetErrorStatus(S,msg);
        return;
    }

    // DEBUG: print contents of the fifo
//    printf("write: start -> ");
//    for( i = 0 ; i < size+2 ; i++ )
//        printf("%04x ", Fifo[i] );
//    printf("\n");

    // Since the write block only increments the write pointer and
    // the read block only increments the read pointer, we don't have
    // to protect access to either of these with interrupt blocks
    // even though one side access is in interrupt service.
    switch( type )
    {
      case 1:  // int 32
      case 2:  // uint 32
        for( i = 0 ; i < incount ; i++ )
        {
            Fifo[ *wptr + 2 ] = intdata[ i ];
            *wptr = (*wptr + 1)%size;
        }
        break;

      case 3:  // 16 bit signed, do sign extension
        for( i = 0 ; i < incount ; i++ )
        {
            int data = (int)(shortdata[i]);  // sign extend is implicit here.
            Fifo[ *wptr + 2 ] = data;
            *wptr = (*wptr + 1)%size;
        }
        break;
      case 4:  // 16 bit unsigned, no sign extension
//printf("incount = %d\n", incount );
        for( i = 0 ; i < incount ; i++ )
        {
            unsigned int data = (unsigned int)shortdata[i];
//printf("%d ", data );
            Fifo[ *wptr + 2 ] = data;
            *wptr = (*wptr + 1)%size;
        }
//printf("\n");
        break;

      case 5:  // 8 bit signed, do sign extension
        for( i = 0 ; i < inwidth ; i++ )
        {
            int c = (int)chardata[i];
            if( c == 0 )  // copy until null terminator, or width
                break;
            Fifo[ *wptr + 2 ] = c;
            *wptr = (*wptr + 1)%size;
        }
        break;
      case 6:  // 8 bit unsigned no sign extension
        for( i = 0 ; i < inwidth ; i++ )
        {
            unsigned int c = (unsigned int)chardata[i];
            if( c == 0 )  // copy until null terminator, or width
                break;
            Fifo[ *wptr + 2 ] = c;
            *wptr = (*wptr + 1)%size;
        }
        break;
    }

    if( presenceflag == 1 )  // set the output boolean true if data now present
    {
        presenceout = ssGetOutputPortSignal(S,1);
        if( *wptr != *rptr )
            *presenceout = true;
        else
            *presenceout = false;
    }

    // DEBUG: print contents of the fifo
//    printf("write: end -> ");
//    for( i = 0 ; i < size+2 ; i++ )
//        printf("%04x ", Fifo[i] );
//    printf("\n");

}

static void mdlTerminate(SimStruct *S)
{
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
