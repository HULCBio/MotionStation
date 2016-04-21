/* $Revision: 1.1.6.1 $ $Date: 2003/09/02 01:15:22 $ */
/* modemcontrolbase.c - xPC Target, non-inlined S-function driver for reading
 * the modem status lines for the baseboard UARTS */
/* Copyright 1996-2003 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         modemcontrolemeraldmm

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
#define NUMBER_OF_ARGS          (5)
#define ADDR_ARG                ssGetSFcnParam(S,0)
#define TYPE_ARG                ssGetSFcnParam(S,1)
#define RTS_ARG                 ssGetSFcnParam(S,2)
#define DTR_ARG                 ssGetSFcnParam(S,3)
#define COUNT_ARG               ssGetSFcnParam(S,4)

#define NO_I_WORKS              (1)
#define BASE_I_IND              (0)

#define NO_R_WORKS              (0)

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{

    int i;
    int boardtype;
    int numin;

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

    numin = (int)mxGetPr(COUNT_ARG)[0];
    ssSetNumInputPorts(S, numin);
    for( i = 0 ; i < numin ; i++ )
    {
        ssSetInputPortWidth(S, i, 1);
        ssSetInputPortDataType( S, i, SS_DOUBLE );
        ssSetInputPortRequiredContiguous( S, i, 1 );
    }

    ssSetNumOutputPorts(S, 0);

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

    int_T base;
    short* biosram;
    int boardtype = (int)mxGetPr(TYPE_ARG)[0];
    bool found = false;
    int i;

    // Save the base address for mdlOutputs
    base = mxGetPr(ADDR_ARG)[0];

    // Save the base address for mdlOutputs
    ssSetIWorkValue(S, BASE_I_IND, base);

#endif

}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    int base = ssGetIWorkValue(S, BASE_I_IND);
    double *IPtr;
    int iport = 0;
    int mcontrol = rl32eInpB( (unsigned short)(base +MCR)) & 0xff;
    double value;

    if( (int)mxGetPr(RTS_ARG)[0] )
    {
        IPtr = (double *)ssGetInputPortSignal(S,iport);
        value = *IPtr;
        if( value > 0.5 )
        {
            mcontrol |= MCRRTS;
        }
        else
        {
            mcontrol &= ~MCRRTS;
        }
        iport++;
    }
    if( (int)mxGetPr(DTR_ARG)[0] )
    {
        IPtr = (double *)ssGetInputPortSignal(S,iport);
        value = *IPtr;
        if( value > 0.5 )
        {
            mcontrol |= MCRDTR;
        }
        else
        {
            mcontrol &= ~MCRDTR;
        }
        iport++;
    }
    rl32eOutpB( (unsigned short)(base + MCR), mcontrol );
#endif

}

static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE

#endif
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
