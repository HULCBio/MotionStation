/* $Revision: 1.1.6.2 $ */
// targetboxwatchdog.c - xPC Target, non-inlined S-function driver 
// for the MPL TargetBox watchdog timer  
// Copyright 2000-2003 The MathWorks, Inc.

#define     S_FUNCTION_LEVEL  2
#undef      S_FUNCTION_NAME
#define     S_FUNCTION_NAME   targetboxwatchdog

#include    <stddef.h>
#include    <stdlib.h>

#include    "simstruc.h"

#ifdef  MATLAB_MEX_FILE
#include    "mex.h"
#endif

#ifndef MATLAB_MEX_FILE
#include    <windows.h>
#include    "io_xpcimport.h"
#include    "util_xpcimport.h"
#endif

#define NUM_ARGS         (7)
#define UNITS_ARG        ssGetSFcnParam(S,0) // double (1:minutes; 2:seconds)
#define INTERVAL_ARG     ssGetSFcnParam(S,1) // double (timeout interval)
#define PORT_RESET_ARG   ssGetSFcnParam(S,2) // boolean (provide reset input port?)
#define KYBD_RESET_ARG   ssGetSFcnParam(S,3) // boolean (kybd causes reset?)
#define MOUSE_RESET_ARG  ssGetSFcnParam(S,4) // boolean (mouse causes reset?)
#define REBOOT_ARG       ssGetSFcnParam(S,5) // boolean (reboot upon expiration?)
#define SAMP_TIME_ARG    ssGetSFcnParam(S,6) // double

#define SAMP_TIME_IND    (0)
#define NUM_I_WORKS      (0)
#define NUM_R_WORKS      (0)
#define THRESHOLD        (0.5) 


static bool firstTime = true;

static char_T msg[256];


static void mdlInitializeSizes(SimStruct *S)
{
    int_T portReset = mxGetPr(PORT_RESET_ARG)[0];
    int_T i;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "util_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUM_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"%d arguments passed - %d expected\n",
            ssGetSFcnParamsCount(S), ssGetNumSFcnParams(S));
        ssSetErrorStatus(S,msg);
        return;
    }

    if (portReset) {
        ssSetNumInputPorts(S, 1);
        ssSetInputPortWidth(S, 0, 1);
        ssSetInputPortDirectFeedThrough(S, 0, 1);
    } else {
        ssSetNumInputPorts(S, 0);
    }

    ssSetNumOutputPorts(S, 0);
    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);
    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, NUM_R_WORKS);
    ssSetNumIWork(S, NUM_I_WORKS);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    for (i = 0; i < NUM_ARGS; i++)
        ssSetSFcnParamTunable(S, i, 0);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME_ARG)[SAMP_TIME_IND]);
    ssSetOffsetTime(S, 0, 0.0);
}

#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
    int_T units      = mxGetPr(UNITS_ARG)[0];
    int_T portReset  = mxGetPr(PORT_RESET_ARG)[0];
    int_T kybdReset  = mxGetPr(KYBD_RESET_ARG)[0];
    int_T mouseReset = mxGetPr(MOUSE_RESET_ARG)[0];
    int_T reboot     = mxGetPr(REBOOT_ARG)[0];
    int_T cmd;

    rl32eOutpB(0x3f0, 0x55);     // enter FDC37C672 configuration state

    rl32eOutpB(0x3f0, 0x07);     // register = logical device number register
    rl32eOutpB(0x3f1, 0x08);     // logical device number = 8 (auxiliary I/O)

    rl32eOutpB(0x3f0, 0xf1);     // register = WDT timeout units register
    switch (units) {
        case 1: rl32eOutpB(0x3f1, 0x80); break; // timout units = seconds
        case 2: rl32eOutpB(0x3f1, 0x00); break; // timout units = minutes
    }

    rl32eOutpB(0x3f0, 0xf2);     // register = timeout register
    rl32eOutpB(0x3f1, 0x00);     // disable watchdog

    rl32eOutpB(0x3f0, 0xf3);     // register = WDT configuration register
    cmd = 0x01 * portReset       // reset watchdog upon joystick activity
        | 0x02 * kybdReset       // reset watchdog upon keyboard activity
        | 0x04 * mouseReset      // reset watchdog upon mouse activity 
        | 0xf0;                  // map WDT interrupt to IRQ15
    rl32eOutpB(0x3f1, cmd);

    if (reboot)
        rl32eOutpB(0x808, 0x01); // reboot when WDT asserts IRQ15

    rl32eOutpB(0x3f0, 0xaa);     // exit FDC37C672 configuration state
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    int_T portReset  = mxGetPr(PORT_RESET_ARG)[0];

    InputRealPtrsType uPtrs;
    
    if (firstTime) {
        int_T interval = mxGetPr(INTERVAL_ARG)[0];

        rl32eOutpB(0x3f0, 0x55);     // enter FDC37C672 configuration state

        rl32eOutpB(0x3f0, 0x07);     // register = logical device number register
        rl32eOutpB(0x3f1, 0x08);     // logical device number = 8 (auxiliary I/O)

        rl32eOutpB(0x3f0, 0xf2);     // register = timeout register
        rl32eOutpB(0x3f1, interval); // set timeout interval 

        rl32eOutpB(0x3f0, 0xaa);     // exit FDC37C672 configuration state

        firstTime = false;
        return;
    } 

    if (portReset) {
        uPtrs = ssGetInputPortRealSignalPtrs(S, 0);
        if (*uPtrs[0] > THRESHOLD) {
            uint8_T dummy = rl32eInpB(0x201); // trigger watchdog reset
        }
    }
#endif
}

static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
    if (xpceIsModelInit())
        return;

    rl32eOutpB(0x3f0, 0x55);  // enter FDC37C672 configuration state

    rl32eOutpB(0x3f0, 0x07);  // register = logical device number register
    rl32eOutpB(0x3f1, 0x08);  // logical device number = 8 (auxiliary I/O)

    rl32eOutpB(0x808, 0x00);  // disable {reboot when WDT asserts IRQ15} 

    rl32eOutpB(0x3f0, 0xf2);  // register = timeout register
    rl32eOutpB(0x3f1, 0x00);  // disable WDT

    rl32eOutpB(0x3f0, 0xaa);  // exit FDC37C672 configuration state
#endif
}

#ifdef MATLAB_MEX_FILE  // Is this file being compiled as a MEX-file?
#include "simulink.c"   // Mex glue
#else
#include "cg_sfun.h"    // Code generation glue
#endif
