/* $Revision: 1.1.6.1 $ $Date: 2003/09/02 01:15:29 $ */
/* sertxenable.c - xPC Target, non-inlined S-function driver for serial
 * output direction for the Quatech QSC-100 board */
/* Copyright 1996-2003 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         sertxenableemeraldmm

#include        <stddef.h>
#include        <stdlib.h>

#include        "simstruc.h"

#ifdef          MATLAB_MEX_FILE
#include        "mex.h"
#endif

#ifndef         MATLAB_MEX_FILE
#include        <windows.h>
#include        "io_xpcimport.h"
#include        "serialdefines.h"
#endif

/* Input Arguments */
#define NUMBER_OF_ARGS          (1)
#define ADDR_ARG                ssGetSFcnParam(S,0)

#define NO_I_WORKS              (1)
#define BASE_I_IND              (0)

#define NO_R_WORKS              (0)

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
    int i;

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

    ssSetNumOutputPorts(S, 0);

    ssSetNumInputPorts(S, 1);

    ssSetInputPortRequiredContiguous( S, 0, 1 ); 
    ssSetInputPortWidth(S, 0, 1 );
    ssSetInputPortDataType( S, 0, SS_BOOLEAN );
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

    int_T base;

    //printf("sertxenable\n");
    // Save the base address for mdlOutputs
    base = (int_T)mxGetPr(ADDR_ARG)[0];
    //printf("base = 0x%x\n", base );
    ssSetIWorkValue(S, BASE_I_IND, base);
    //printf("exit\n");
#endif

}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    int base = ssGetIWorkValue(S, BASE_I_IND);
    int_T *IPtr = (int_T *)ssGetInputPortSignal(S,0);
    int enable;
    ushort_T reg;
    int iir;
    int istat;

    if( base == 0 )  // This UART is not configured
        return;

    _asm{ pushf };
    _asm{ cli };

    enable = (IPtr[0]) & 0xff;

    reg = rl32eInpB( (unsigned short)(base + IER) ) & 0xff;
       istat = rl32eInpB( (unsigned short)(0x202) ) & 0xff;
       iir = rl32eInpB( (unsigned short)(base+IIR) ) & 0xff;

    if( enable )
    {
	//if( base == 0x208 || base == 0x228 )
	//{
	//    printf("iir = 0x%x, istat = 0x%x, ", iir, istat );
	//    printf("%3x = 0x%x\n", base+IER, reg );
	//}
        reg |= IERXMT;
        rl32eOutpB( (unsigned short)(base + IER), reg );
    }

    _asm{ popf };

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
