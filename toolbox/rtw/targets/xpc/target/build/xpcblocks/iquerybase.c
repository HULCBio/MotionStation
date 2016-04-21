/* $Revision: 1.2.6.1 $ $Date: 2003/11/13 06:22:27 $ */
/* Iquerybase.c - xPC Target, non-inlined S-function driver for digital
 * input section for the baseboard serial ports */
/* Copyright 1996-2003 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         iquerybase

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
#define NUMBER_OF_ARGS          (2)
#define ADDR1_ARG                ssGetSFcnParam(S,0)
#define ADDR2_ARG                ssGetSFcnParam(S,1)

#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)

#define NO_I_WORKS              (2)
#define BASE1_I_IND             (0)
#define BASE2_I_IND             (1)

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

    ssSetNumOutputPorts(S, 1);
    ssSetOutputPortWidth(S, 0, 2);
    ssSetOutputPortDataType( S, 0, SS_UINT32 );

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
    	ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    	ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
}

#define MDL_START
static void mdlStart(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE
    int_T base1;
    int_T base2;
    short* biosram;
    bool found = false;
    int i;

//printf("iquery start\n");
    // Save the base address for mdlOutputs
    base1 = mxGetPr(ADDR1_ARG)[0];
    // Check the BIOS data area for this base address.
    biosram = (short *)rl32eGetDevicePtr( (void *)0x400, 1024, RT_PG_USERREADWRITE);
    for( i = 0 ; i < 4 ; i++ )
    {
        if( biosram[i] == base1 )
        {
            found = true;
            break;
        }
    }
    if( found == false )
        base1 = 0;

    ssSetIWorkValue(S, BASE1_I_IND, base1);

    // Save the base address for mdlOutputs
    base2 = mxGetPr(ADDR2_ARG)[0];
    // Check the BIOS data area for this base address.
    found = false;
    for( i = 0 ; i < 4 ; i++ )
    {
        if( biosram[i] == base2 )
        {
            found = true;
            break;
        }
    }
    if( found == false )
        base2 = 0;

    ssSetIWorkValue(S, BASE2_I_IND, base2);
#endif

}

static int intcount = 0;

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

    int base[2];
    int_T *OPtr = ssGetOutputPortSignal(S,0);
    int i;
    volatile int lint;  // local interrupt register, per uart

//printf("ISR entry\n");

    base[0] = ssGetIWorkValue(S, BASE1_I_IND);
    base[1] = ssGetIWorkValue(S, BASE2_I_IND);

    for( i = 0 ; i < 2 ; i++ )
    {
        int reason = 0;

        if( base[i] == 0 )
        {
            OPtr[i] = 0;
            continue;
        }

        lint = rl32eInpB( (unsigned short)(base[i] + IIR) ) & 0xff;
//printf("lint = 0x%x\n", lint );

        switch( lint & IIRREASON )
        {
          case 1:  // No interrupt on this UART
            reason = 0;
            break;
          case 4:   // received data available
          case 6:   // receiver line status, overrun etc.
          case 0xc: // character timeout
//printf("%1xa", base[i]>>8);
            reason = 1;  // All three are receive interrupts
            break;
          case 2:
//printf("%1xb", base[i]>>8);
            reason = 2;  // Transmitter holding register empty
            break;
          case 0:
            reason = 3;  // Modem status change
            break;
        }
        OPtr[i] = reason | lint << 8;
//if( reason != 0 )
//   printf("int reason = %x, port = %d, count = %d\n", OPtr[i], i+1, ++intcount );
    }
#endif

}

static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
//    printf("iquerybase: terminate\n");
#endif
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
