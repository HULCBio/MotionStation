/* $Revision: 1.1.6.2 $ $Date: 2003/11/13 06:22:29 $ */
/* Iquerybase.c - xPC Target, non-inlined S-function driver for digital
 * input section for the baseboard serial ports */
/* Copyright 1996-2003 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         iqueryemeraldmm8

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
#define NUMBER_OF_ARGS          (9)
#define ADDR1_ARG               ssGetSFcnParam(S,0)
#define ADDR2_ARG               ssGetSFcnParam(S,1)
#define ADDR3_ARG               ssGetSFcnParam(S,2)
#define ADDR4_ARG               ssGetSFcnParam(S,3)
#define ADDR5_ARG               ssGetSFcnParam(S,4)
#define ADDR6_ARG               ssGetSFcnParam(S,5)
#define ADDR7_ARG               ssGetSFcnParam(S,6)
#define ADDR8_ARG               ssGetSFcnParam(S,7)
#define INTSTAT_ARG             ssGetSFcnParam(S,8)

#define NO_I_WORKS              (9)
#define BASE1_I_IND             (0)
#define BASE2_I_IND             (1)
#define BASE3_I_IND             (2)
#define BASE4_I_IND             (3)
#define BASE5_I_IND             (4)
#define BASE6_I_IND             (5)
#define BASE7_I_IND             (6)
#define BASE8_I_IND             (7)
#define ISTAT_I_IND             (8)

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
    ssSetOutputPortWidth(S, 0, 8);
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
    int_T base;

//printf("iquery start\n");
    // Save the base addresses for mdlOutputs
    base = mxGetPr(ADDR1_ARG)[0];
    ssSetIWorkValue( S, BASE1_I_IND, base );
    base = mxGetPr(ADDR2_ARG)[0];
    ssSetIWorkValue( S, BASE2_I_IND, base );
    base = mxGetPr(ADDR3_ARG)[0];
    ssSetIWorkValue( S, BASE3_I_IND, base );
    base = mxGetPr(ADDR4_ARG)[0];
    ssSetIWorkValue( S, BASE4_I_IND, base );
    base = mxGetPr(ADDR5_ARG)[0];
    ssSetIWorkValue( S, BASE5_I_IND, base );
    base = mxGetPr(ADDR6_ARG)[0];
    ssSetIWorkValue( S, BASE6_I_IND, base );
    base = mxGetPr(ADDR7_ARG)[0];
    ssSetIWorkValue( S, BASE7_I_IND, base );
    base = mxGetPr(ADDR8_ARG)[0];
    ssSetIWorkValue( S, BASE8_I_IND, base );

    base = mxGetPr(INTSTAT_ARG)[0];
    ssSetIWorkValue( S, ISTAT_I_IND, base );
 #endif

}

static int intcount = 0;

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

    int base[8];
    int intstat;
    int status;
    int_T *OPtr = ssGetOutputPortSignal(S,0);
    int i;
    int lint;  // local interrupt register, per uart

    //printf("ISR entry: ");

    base[0] = ssGetIWorkValue( S, BASE1_I_IND );
    base[1] = ssGetIWorkValue( S, BASE2_I_IND );
    base[2] = ssGetIWorkValue( S, BASE3_I_IND );
    base[3] = ssGetIWorkValue( S, BASE4_I_IND );
    base[4] = ssGetIWorkValue( S, BASE5_I_IND );
    base[5] = ssGetIWorkValue( S, BASE6_I_IND );
    base[6] = ssGetIWorkValue( S, BASE7_I_IND );
    base[7] = ssGetIWorkValue( S, BASE8_I_IND );
    intstat = ssGetIWorkValue( S, ISTAT_I_IND );

    status = rl32eInpB( (unsigned short)(intstat) ) & 0xff;
    //printf("status = 0x%x, ", status );
    for( i = 0 ; i < 8 ; i++ )
    {
        int reason = 0;

        if( base[i] == 0 )
        {
            OPtr[i] = 0;
            continue;
        }

	if( status & (1 << i) )
	{
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
		reason = 1;  // All three are receive interrupts
		break;
	    case 2:
		reason = 2;  // Transmitter holding register empty
		break;
	    case 0:
		reason = 3;  // Modem status change
		break;
	    }
	}
	else
	{
	    reason = 0;
	    lint = 0;
	}
        OPtr[i] = reason | lint << 8;
	//if( reason != 0 )
	//printf("int reason = %x, port = %d, count = %d\n", OPtr[i], i+1, ++intcount );
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
