/* $Revision: 1.1 $ */
// addiamondmm32.c - xPC Target, non-inlined S-function driver 
// for A/D section of Diamond Systems MM-32 boards  
// Copyright 1996-2002 The MathWorks, Inc.

#define     S_FUNCTION_LEVEL    2
#undef      S_FUNCTION_NAME
#define     S_FUNCTION_NAME     addiamondmm32

#include    <stddef.h>
#include    <stdlib.h>

#include    "simstruc.h" 

#ifdef      MATLAB_MEX_FILE
#include    "mex.h"
#endif

#ifndef     MATLAB_MEX_FILE
#include    <windows.h>
#include    "io_xpcimport.h"
#endif


// input arguments
#define NUM_ARGS                       (5)
#define FIRST_CHAN_ARG                 ssGetSFcnParam(S,0)
#define NUM_CHANS_ARG                  ssGetSFcnParam(S,1)
#define RANGE_ARG                      ssGetSFcnParam(S,2)
#define SAMP_TIME_ARG                  ssGetSFcnParam(S,3)
#define BASE_ARG                       ssGetSFcnParam(S,4)

// write register offsets
#define START_AD_CONVERSION            (0)
#define AUX_DIGITAL_OUTPUT             (1)
#define AD_LO_CHAN_REGISTER            (2) 
#define AD_HI_CHAN_REGISTER            (3) 
#define DA_LSB_REGISTER                (4) 
#define DA_MSB_AND_CHAN_REGISTER       (5) 
#define FIFO_DEPTH_REGISTER            (6) 
#define FIFO_CONTROL_REGISTER          (7) 
#define MISC_CONTROL_REGISTER          (8) 
#define OPERATION_CONTROL_REGISTER     (9) 
#define COUNTER_TIMER_CONTROL_REGISTER (10) 
#define ANALOG_CONFIGURATION_REGISTER  (11) 

// read register offsets
#define AD_LSB                         (0)
#define AD_MSB                         (1)
#define AD_LO_CHAN_REGISTER_READBACK   (2) 
#define AD_HI_CHAN_REGISTER_READBACK   (3) 
#define AUX_DIGITAL_INPUT_PORT         (4) 
#define UPDATE_ALL_DA_CHANNELS         (5) 
#define FIFO_DEPTH_REGISTER            (6) 
#define FIFO_STATUS_REGISTER           (7) 
#define AD_STATUS_REGISTER             (8) 
#define OPERATION_STATUS_REGISTER      (9) 
#define COUNTER_TIMER_CONTROL_READBACK (10) 
#define ANALOG_CONFIGURATION_READBACK  (11) 

#define SAMP_TIME_IND                  (0)
#define NUM_I_WORKS                    (1)
#define RESETS_I_IND                   (0)
#define NUM_R_WORKS                    (2)
#define GAIN_R_IND                     (0)
#define OFFSET_R_IND                   (1)

#define RESOLUTION                     (65536)


static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
    int_T  i;
    int_T nChans = mxGetPr(NUM_CHANS_ARG)[0];

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUM_ARGS);
    if (NUM_ARGS != ssGetSFcnParamsCount(S)) {
        sprintf(msg, "%d input args expected, %d passed", 
            NUM_ARGS, ssGetSFcnParamsCount(S));
        ssSetErrorStatus(S, msg);
        return;
    }

    ssSetNumContStates(S,0);
    ssSetNumDiscStates(S,0);
    ssSetNumInputPorts(S,0);

    ssSetNumOutputPorts(S, nChans);
    for (i = 0; i < nChans; i++) {
        ssSetOutputPortWidth(S, i, 1);
    }

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
    if (mxGetPr(SAMP_TIME_ARG)[0] == -1.0) {
        ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
        ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
    } else {
        ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME_ARG)[0]);
        ssSetOffsetTime(S, 0, 0.0);
    }
}
 

#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
#define WAIT (0x80)

    real_T *RWork  = ssGetRWork(S);
    int_T   nChans = mxGetPr(NUM_CHANS_ARG)[0]; 
    uint_T  base   = mxGetPr(BASE_ARG)[0]; 
    int_T   range  = mxGetPr(RANGE_ARG)[0];
    int_T   loChan = mxGetPr(FIRST_CHAN_ARG)[0] - 1;
    int_T   hiChan = mxGetPr(FIRST_CHAN_ARG)[0] - 1 + nChans - 1;

    bool    ok;
    uint8_T cmd, code;
    int_T   i;
        
    switch (range) {
        case 1:  // -10V to +10V
            RWork[GAIN_R_IND] = 10.0 / (RESOLUTION / 2);
            RWork[OFFSET_R_IND] = 0;
            code =  8; 
            break;
        case 2:  // -5V to +5V
            RWork[GAIN_R_IND] = 5.0 / (RESOLUTION / 2);
            RWork[OFFSET_R_IND] = 0;
            code =  0; 
            break;
        case 3:  // -2.5V to +2.5V
            RWork[GAIN_R_IND] = 2.5 / (RESOLUTION / 2);
            RWork[OFFSET_R_IND] = 0;
            code =  1; 
            break;
        case 4:  // -1.25V to +1.25V
            RWork[GAIN_R_IND] = 1.25 / (RESOLUTION / 2);
            RWork[OFFSET_R_IND] = 0;
            code =  2; 
            break;
        case 5:  // -0.625V to +0.625V
            RWork[GAIN_R_IND] = 0.625 / (RESOLUTION / 2);
            RWork[OFFSET_R_IND] = 0;
            code =  3; 
            break;
        case 6:  // 0 to +10V
            RWork[GAIN_R_IND] = 10.0 / RESOLUTION;
            RWork[OFFSET_R_IND] = RESOLUTION / 2;
            code = 12; 
            break;
        case 7:  // 0V to +5V
            RWork[GAIN_R_IND] = 5.0 / RESOLUTION;
            RWork[OFFSET_R_IND] = RESOLUTION / 2;
            code = 13; 
            break;
        case 8:  // 0V to +2.5V
            RWork[GAIN_R_IND] = 2.5 / RESOLUTION;
            RWork[OFFSET_R_IND] = RESOLUTION / 2;
            code = 14; 
            break;
        case 9:  // 0V to +1.25V
            RWork[GAIN_R_IND] = 1.25 / RESOLUTION;
            RWork[OFFSET_R_IND] = RESOLUTION / 2;
            code = 15; 
            break;
        default: 
            printf("bad range param for MM-32 A/D: %d\n", range);
    }


    cmd = 0
        | 0x20 * 0  //  reset everything (RESETA) = disabled
        | 0x10 * 1  // reset all but D/A (RESETD) = enabled
        | 0x08 * 0  //   reset interrupt (INTRST) = disabled
        | 0x01 * 1; //    base + 12 to base + 15  = digital I/O
    rl32eOutpB(base + MISC_CONTROL_REGISTER, cmd);

    cmd = 0
        | 0x80 * 0  //  analog interrupt = disabled
        | 0x40 * 0  // digital interrupt = disabled
        | 0x20 * 0  // timer 0 interrupt = disabled
        | 0x02 * 0  //    sampling clock = disabled
        | 0x01 * 0; //      clock source = external
    rl32eOutpB(base + OPERATION_CONTROL_REGISTER, cmd);

    cmd = 0
        | 0x08 * 0  //       FIFO = disabled
        | 0x04 * 1  //       scan = enabled
        | 0x02 * 1; // reset FIFO = yes
    rl32eOutpB(base + FIFO_CONTROL_REGISTER, cmd);

    rl32eOutpB(base + AD_LO_CHAN_REGISTER, loChan);
    rl32eOutpB(base + AD_HI_CHAN_REGISTER, hiChan);

    cmd = code
        | 0x10 * 2;  //  scan interval = 10 microsec
    rl32eOutpB(base + ANALOG_CONFIGURATION_REGISTER, cmd);

    cmd = 0
        | 0x08 * 0  //       FIFO = disabled
        | 0x04 * 1  //       scan = enabled
        | 0x02 * 1; // reset FIFO = yes
    rl32eOutpB(base + FIFO_CONTROL_REGISTER, cmd);

    /* wait for the analog input circuitry to settle */
    for (i = 0, ok = false; i < 1000 && !ok; i++) 
        ok = (rl32eInpB(base + ANALOG_CONFIGURATION_READBACK) & WAIT) == 0;

    if (!ok) {
        sprintf(msg, "MM-32 does not respond - is one present?");
        ssSetErrorStatus(S, msg);
        return;
    }
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
#define IN_PROGRESS (0x80)
#define FIFO_EMPTY  (0x80)

    real_T *RWork = ssGetRWork(S);
    real_T gain   = RWork[GAIN_R_IND];
    real_T offset = RWork[OFFSET_R_IND];
    uint_T base   = mxGetPr(BASE_ARG)[0];
    uint_T nChans = mxGetPr(NUM_CHANS_ARG)[0];

    bool    ok;
    int_T   i, j, chan;
    int16_T count;
    real_T *y;

    for (ok = false, i = 0; !ok && i < 5; i++) {
        rl32eOutpB(base + START_AD_CONVERSION, 0);
        for (j = 0; !ok && j < 2; j++) 
            ok = (rl32eInpB(base + AD_STATUS_REGISTER) & IN_PROGRESS) != 0;
    }

    if (!ok) {
        printf("Can't start A/D conversion on MM-32\n");
        return;
    }
    
    for (chan = 0; chan < nChans; chan++) {

        y = ssGetOutputPortSignal(S, chan);

        for (ok = false, i = 0; !ok && i < 15; i++)
            ok = (rl32eInpB(base + FIFO_STATUS_REGISTER) & FIFO_EMPTY) == 0;

        if (!ok) {
            int_T *IWork = ssGetIWork(S);
            IWork[RESETS_I_IND] += 1;
            mdlStart(S);
            return;
        }

        count = rl32eInpW(base + AD_LSB);

        y[0] = gain * (count + offset);             
    }
#endif
}

static void mdlTerminate(SimStruct *S)
{   
#ifndef MATLAB_MEX_FILE
    int_T *IWork  = ssGetIWork(S);
    int_T  resets = IWork[RESETS_I_IND];

    if (resets > 0)
        printf("MM-32 A/D had to be reset %d times\n", resets);
#endif
}


#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
