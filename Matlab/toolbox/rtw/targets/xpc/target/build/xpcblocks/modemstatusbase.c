/* $Revision: 1.2 $ $Date: 2003/01/22 20:18:32 $ */
/* modemstatusbase.c - xPC Target, non-inlined S-function driver for reading
 * the modem status lines for the Quatech QSC-100 board */
/* Copyright 1996-2003 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         modemstatusbase

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
#define NUMBER_OF_ARGS          (8)
#define ADDR_ARG                ssGetSFcnParam(S,0)
#define TYPE_ARG                ssGetSFcnParam(S,1)
#define CTS_ARG                 ssGetSFcnParam(S,2)
#define DSR_ARG                 ssGetSFcnParam(S,3)
#define RI_ARG                  ssGetSFcnParam(S,4)
#define DCD_ARG                 ssGetSFcnParam(S,5)
#define COUNT_ARG               ssGetSFcnParam(S,6)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,7)

#define NO_I_WORKS              (1)
#define BASE_I_IND              (0)

#define NO_R_WORKS              (0)

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{

    int i;
    int boardtype;
    int numout;

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

    numout = (int)mxGetPr(COUNT_ARG)[0];
    ssSetNumOutputPorts(S, numout);
    for( i = 0 ; i < numout ; i++ )
    {
        ssSetOutputPortWidth(S, i, 1);
        ssSetOutputPortDataType( S, i, SS_BOOLEAN );
    }

    ssSetNumInputPorts(S, 0);

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
    if (mxGetPr(SAMP_TIME_ARG)[0] == -1.0)
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
//printf("modemstatus: base = 0x%x\n", base );

    if( boardtype == 4 )  // baseboard UART
    {
        // Check the BIOS data area for this base address.
        biosram = (short *)rl32eGetDevicePtr( (void *)0x400, 1024, RT_PG_USERREADWRITE);
        for( i = 0 ; i < 4 ; i++ )
        {
            if( biosram[i] == base )
            {
                found = true;
                break;
            }
        }
        if( found == false )
            base = 0;
    }

    // Save the base address for mdlOutputs
    ssSetIWorkValue(S, BASE_I_IND, base);

#endif

}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    int base = ssGetIWorkValue(S, BASE_I_IND);
    bool *OPtr;
    int oport = 0;
    int mstatus = rl32eInpB( (unsigned short)(base +MSR)) & 0xff;

//printf("modem status = %x, base = 0x%x\n", mstatus, base );
    if( (int)mxGetPr(CTS_ARG)[0] )
    {
        OPtr = ssGetOutputPortSignal(S,oport);
        if( mstatus & MSRCTS )
            *OPtr = true;
        else
            *OPtr = false;
        oport++;
    }
    if( (int)mxGetPr(DSR_ARG)[0] )
    {
        OPtr = ssGetOutputPortSignal(S,oport);
        if( mstatus & MSRDSR )
            *OPtr = true;
        else
            *OPtr = false;
        oport++;
    }
    if( (int)mxGetPr(RI_ARG)[0] )
    {
        OPtr = ssGetOutputPortSignal(S,oport);
        if( mstatus & MSRRI )
            *OPtr = true;
        else
            *OPtr = false;
        oport++;
    }
    if( (int)mxGetPr(DCD_ARG)[0] )
    {
        OPtr = ssGetOutputPortSignal(S,oport);
        if( mstatus & MSRDCD )
            *OPtr = true;
        else
            *OPtr = false;
        oport++;
    }

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
