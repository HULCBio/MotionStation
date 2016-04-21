/* $Revision: 1.2 $ $Date: 2003/01/22 20:18:37 $ */
/* filterqua.c - xPC Target, non-inlined S-function driver for digital
 * input section for the Quatech QSC-100 board */
/* Copyright 1996-2003 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         serfilterbase

#include        <stddef.h>
#include        <stdlib.h>

#include        "simstruc.h"

#ifdef          MATLAB_MEX_FILE
#include        "mex.h"
#endif

#ifndef         MATLAB_MEX_FILE
#include        <windows.h>
#include        "io_xpcimport.h"
#include        "pci_xpcimport.h"
#include        "serialdefines.h"
#endif

/* Input Arguments */
#define NUMBER_OF_ARGS          (2)
#define PORT_ARG                ssGetSFcnParam(S,0)
#define VALUE_ARG               ssGetSFcnParam(S,2)

#define NO_I_WORKS              (0)
#define NO_R_WORKS              (0)

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{

    int i;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "pci_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"Wrong number of input arguments passed.\n%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    ssSetNumOutputPorts(S, 1);
    ssSetOutputPortWidth(S, 0, 1);
    ssSetOutputPortDataType( S, 0, SS_UINT32 );

    ssSetNumInputPorts(S, 1);
    ssSetInputPortRequiredContiguous( S, 0, 1 ); 
    ssSetInputPortWidth(S, 0, DYNAMICALLY_SIZED);
    ssSetInputPortDataType( S, 0, SS_UINT32 );
    ssSetInputPortDirectFeedThrough(S, 0, 1);

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

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    	ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    	ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
}

#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE

#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

    int_T ports;
    int_T *OPtr = ssGetOutputPortSignal(S,0);
    int_T *IPtr = (int_T *)ssGetInputPortSignal(S,0);
    int port = (int)mxGetPr(PORT_ARG)[0];
    int value;
    int ivalue;
    int iir;
    int max;

    // Number of ports is dynamically set from source block.
    ports = ssGetInputPortWidth( S, 0 );

    if( port > ports )
    {
        sprintf( msg, "Port number exceeds input port count" );
        ssSetErrorStatus( S, msg );
        return;
    }

    value = (int)mxGetPr(VALUE_ARG)[0];

    ivalue = IPtr[port-1];
    iir = (ivalue >> 8) & 0xff;
    if( (iir & (IIRFEBL | IIR64) ) == (IIRFEBL | IIR64) )
        max = 60;
    else if( (iir & (IIRFEBL | IIR64) ) == IIRFEBL )
        max = 15;
    else
        max = 1;
//if( value == 2 && (ivalue & 0xff == 2) )
//    printf("filter: port %d, value %d, ivalue %x, max = %d\n", port, value, ivalue, max );

    if( value == (ivalue & 0xff) )
        OPtr[0] = max;
    else
        OPtr[0] = 0;

#endif

}

static void mdlTerminate(SimStruct *S)
{
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
