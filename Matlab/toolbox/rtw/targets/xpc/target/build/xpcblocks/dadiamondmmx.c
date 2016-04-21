/* $Revision: 1.5 $ $Date: 2002/03/25 04:05:45 $ */
/* dadiamondmmx.c - xPC Target, non-inlined S-function driver for D/A section of Diamond Systems MM-x series boards  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define     S_FUNCTION_LEVEL    2
#undef      S_FUNCTION_NAME
#define     S_FUNCTION_NAME     dadiamondmmx

#include    <stddef.h>
#include    <stdlib.h>

#include    "simstruc.h" 

#ifdef      MATLAB_MEX_FILE
#include    "mex.h"
#endif

#ifndef     MATLAB_MEX_FILE
#include    <windows.h>
#include    "io_xpcimport.h"
#include    "util_xpcimport.h"
#endif



/* Input Arguments */
#define NUMBER_OF_ARGS          (7)
#define CHANNEL_ARG             ssGetSFcnParam(S,0)
#define RANGE_ARG               ssGetSFcnParam(S,1)
#define RESET_ARG               ssGetSFcnParam(S,2)
#define INIT_VAL_ARG            ssGetSFcnParam(S,3)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,4)
#define BASE_ARG                ssGetSFcnParam(S,5)
#define DEV_ID_ARG              ssGetSFcnParam(S,6)


#define SAMP_TIME_IND           (0)

#define NO_I_WORKS              (4)
#define BASE_I_IND              (0)
#define NCHANNELS_I_IND         (1)
#define RESINT_I_IND            (2)
#define DEV_ID_I_IND            (3)


#define NO_R_WORKS              (8)
#define GAIN_R_IND              (0)
#define OFFSET_R_IND            (4)


static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{

    int i;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "util_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
    sprintf(msg,"Wrong number of input arguments passed.\n%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    ssSetNumInputPorts(S, mxGetN(CHANNEL_ARG));
    for (i=0;i<mxGetN(CHANNEL_ARG);i++) {
      ssSetInputPortWidth(S, i, 1);
      ssSetInputPortDirectFeedThrough(S, i, 1);
    }

    ssSetNumOutputPorts(S, 0);

    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumPWork(S, 0);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    for (i=0;i<NUMBER_OF_ARGS;i++) {
        ssSetSFcnParamNotTunable(S,i);
    }

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


    int_T   nChannels, base, i, channel, range, counts; 
    real_T  *RWork=ssGetRWork(S);
    int_T   *IWork=ssGetIWork(S);
    real_T  resFloat, value;

    IWork[DEV_ID_I_IND]=(int_T)mxGetPr(DEV_ID_ARG)[0];

    switch (IWork[DEV_ID_I_IND]) {
        case 1:         // Diamond MM-32
            resFloat=resFloat=4096.0;
            IWork[RESINT_I_IND]=4095;
            break;
    }
    
    base=(int_T)mxGetPr(BASE_ARG)[0];
    IWork[BASE_I_IND]=base;
  
    nChannels = mxGetN(CHANNEL_ARG);
    IWork[NCHANNELS_I_IND]=nChannels;

    range=(uint_T)mxGetPr(RANGE_ARG)[0];
    switch (range) {
        case 1:
            RWork[GAIN_R_IND]=20.0/resFloat;
            RWork[OFFSET_R_IND]=10.0;
            break;
        case 2:
            RWork[GAIN_R_IND]=10.0/resFloat;
            RWork[OFFSET_R_IND]=5.0;
            break;
        case 3:
            RWork[GAIN_R_IND]=10.0/resFloat;
            RWork[OFFSET_R_IND]=0.0;
            break;
        case 4:
            RWork[GAIN_R_IND]=5.0/resFloat;
            RWork[OFFSET_R_IND]=0.0;
            break;
    }

#endif
                     
}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

    int_T               channel, base, i, counts;
    InputRealPtrsType   uPtrs;
    real_T              *RWork=ssGetRWork(S);
    int_T               *IWork=ssGetIWork(S);
    real_T              value;

    base=IWork[BASE_I_IND];

    for (i=0;i<IWork[NCHANNELS_I_IND];i++) {
        channel=(int_T)mxGetPr(CHANNEL_ARG)[i];
        uPtrs=ssGetInputPortRealSignalPtrs(S,i);
        value=*uPtrs[0];
        counts=(value+RWork[OFFSET_R_IND])/RWork[GAIN_R_IND];
        if (counts>IWork[RESINT_I_IND]) counts=IWork[RESINT_I_IND];
        if (counts<0)    counts=0;
        while (rl32eInpB(base+0x04) & 0x80);
        rl32eOutpB((unsigned short)(base+0x04), ((unsigned short)counts) & 0xff);
        while (rl32eInpB(base+0x04) & 0x80);
        rl32eOutpB((unsigned short)(base+0x05), (((unsigned short)counts) >> 8) | ((channel-1)<<6) );
        while (rl32eInpB(base+0x04) & 0x80);
        rl32eInpB((unsigned short)(base+0x05));
    }
        
#endif
        
}

static void mdlTerminate(SimStruct *S)
{   

#ifndef MATLAB_MEX_FILE

    int_T               channel, base, i, counts;
    real_T              *RWork=ssGetRWork(S);
    int_T               *IWork=ssGetIWork(S);
    real_T              value;

    base=IWork[BASE_I_IND];

    // At load time, set channel to its initial value.
    // At termination, set channel to its initial value if reset requested.

    for (i=0;i<IWork[NCHANNELS_I_IND];i++) {
        if (xpceIsModelInit() || (uint_T)mxGetPr(RESET_ARG)[i]) {
            value=mxGetPr(INIT_VAL_ARG)[i];
            channel=(int_T)mxGetPr(CHANNEL_ARG)[i];
            counts=(value+RWork[OFFSET_R_IND])/RWork[GAIN_R_IND];
            if (counts>IWork[RESINT_I_IND]) counts=IWork[RESINT_I_IND];
            if (counts<0)    counts=0;
            while (rl32eInpB(base+0x04) & 0x80);
            rl32eOutpB((unsigned short)(base+0x04), ((unsigned short)counts) & 0xff);
            while (rl32eInpB(base+0x04) & 0x80);
            rl32eOutpB((unsigned short)(base+0x05), (((unsigned short)counts) >> 8) | ((channel-1)<<6) );
            while (rl32eInpB(base+0x04) & 0x80);
            rl32eInpB((unsigned short)(base+0x05));
        }
    }
    
    
#endif

}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
