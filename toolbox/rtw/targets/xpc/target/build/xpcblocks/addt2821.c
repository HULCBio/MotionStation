/*addt2821.c - xPC Target, non-inlined S-function driver for the 
  analog input section of Data Translation DT2821 boards  
  This driver assumes the board is jumpered for a unipolar input range with 
  straight binary coding or a bipolar input range with offset binary ecoding. 
  Two's complement coding is not supported.
  This code supports the dt2828 board, but only for channel 0 (1 to the user).
*/

#define  S_FUNCTION_LEVEL 2
#undef   S_FUNCTION_NAME
#define  S_FUNCTION_NAME  addt2821

#include <stddef.h>
#include <stdlib.h>

#include "simstruc.h" 

#ifdef   MATLAB_MEX_FILE
#include "mex.h"
#else
#include <windows.h>
#include "io_xpcimport.h"
#include "time_xpcimport.h"
#include "dt2821.h"
#endif


/* Input Arguments */
#define NUM_PARAMS       (6)
#define CHANNEL_ARG      (ssGetSFcnParam(S,0))
#define GAIN_ARG         (ssGetSFcnParam(S,1))
#define RANGE_ARG        (ssGetSFcnParam(S,2))
#define SAMPLE_TIME_ARG  (ssGetSFcnParam(S,3))
#define BASE_ARG         (ssGetSFcnParam(S,4))
#define DEVICE_ID_ARG    (ssGetSFcnParam(S,5))

#define NUM_IWORKS       (16)
#define GAINCODE_I_IND   (0)

#define NUM_RWORKS       (2)
#define COEFF_R_IND      (0)
#define OFFSET_R_IND     (1)

static char_T msg[256];


static void mdlCheckParameters(SimStruct *S)
{
}

static void mdlInitializeSizes(SimStruct *S)
{
    uint_T i;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "time_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUM_PARAMS);
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
        mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL) {
            return;
        }
    } else {
        return; /* Parameter mismatch will be reported by Simulink */
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);
    

    if (!ssSetNumInputPorts(S, 0)) return;

    if (!ssSetNumOutputPorts(S, mxGetNumberOfElements(CHANNEL_ARG))) return;

    for (i = 0; i < mxGetNumberOfElements(CHANNEL_ARG); i++) {
        ssSetOutputPortWidth(S, i, 1);
    }

    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NUM_RWORKS);
    ssSetNumIWork(S, NUM_IWORKS);
    ssSetNumPWork(S, 0);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    ssSetSFcnParamNotTunable(S,0);
    ssSetSFcnParamNotTunable(S,1);
    ssSetSFcnParamNotTunable(S,2);
    ssSetSFcnParamNotTunable(S,3);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, (real_T) mxGetPr(SAMPLE_TIME_ARG)[0]);
    ssSetOffsetTime(S, 0, 0.0);
}

#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE

    int_T  base      = (int_T) mxGetPr(BASE_ARG)[0];
    int_T  range     = (int_T) mxGetPr(RANGE_ARG)[0];
    int_T  device_id = (int_T) mxGetPr(DEVICE_ID_ARG)[0];
    int_T  nChannels = (int_T) mxGetN(CHANNEL_ARG);
    int_T  *IWork    = ssGetIWork(S);
    real_T *RWork    = ssGetRWork(S);

    real_T size;
    int_T  i, gain, tmrctr;

    switch (device_id) {
        case DT2821:        tmrctr = 0xaf; /* 50 kHz*/    size = 4096.0;    break;
        case DT2821_F_16SE: tmrctr = 0xe5; /*150 kHz*/    size = 4096.0;    break;
        case DT2821_F_8DI:  tmrctr = 0xe5; /*150 kHz*/    size = 4096.0;    break;
        case DT2821_G_16SE: tmrctr = 0xef; /*250 kHz*/    size = 4096.0;    break;
        case DT2821_G_8DI:  tmrctr = 0xef; /*250 kHz*/    size = 4096.0;    break;
        case DT2823:        tmrctr = 0xd7; /*100 kHz*/    size = 65536.0;   break;
        case DT2824_PGH:    tmrctr = 0xaf; /* 50 kHz*/    size = 4096.0;    break;
        case DT2824_PGL:    tmrctr = 0xaf; /* 50 kHz*/    size = 4096.0;    break;
        case DT2825:        tmrctr = 0xa5; /* 45 kHz*/    size = 4096.0;    break;
        case DT2827:        tmrctr = 0xd7; /*100 kHz*/    size = 65536.0;   break;
        case DT2828:        tmrctr = 0xd7; /*100 kHz*/    size = 4096.0;    break;
    }

    if (device_id == DT2825) 
        for (i = 0; i < nChannels; i++) 
            if (mxGetPr(RANGE_ARG)[i] > 10)
                tmrctr = 0x06e6; /* 2.5 kHz */

    /* Set pacer clock speed according to board type*/
    rl32eOutpW(TMRCTR(base), tmrctr);

    /* check that board is present */
    if (rl32eInpW(TMRCTR(base)) != (0xf000 | tmrctr)) {
        sprintf(msg, "no DT2821 for A/D at base address 0x%x", base);
        ssSetErrorStatus(S, msg);
        return;
    }

    /* range must be the same for all channels */
    switch (range) {
    case -5:
        RWork[COEFF_R_IND] = 10.0 / size;
        RWork[OFFSET_R_IND] = -5.0;
        break;

    case -10:
        RWork[COEFF_R_IND] = 20.0 / size;
        RWork[OFFSET_R_IND] = -10.0;
        break;

    case 5:
        RWork[COEFF_R_IND] = 5.0 / size;
        RWork[OFFSET_R_IND] = 0.0;
        break;

    case 10:
        RWork[COEFF_R_IND] = 10.0 / size;
        RWork[OFFSET_R_IND] = 0.0;
        break;
    }

    for (i = 0; i < nChannels; i++) {
        gain  = (int_T) mxGetPr(GAIN_ARG)[i];

        switch (gain) {
            case 1:   IWork[GAINCODE_I_IND + i] = 0 << 4; break;
            case 2:   IWork[GAINCODE_I_IND + i] = 1 << 4; break;
            case 4:   IWork[GAINCODE_I_IND + i] = 2 << 4; break;
            case 8:   IWork[GAINCODE_I_IND + i] = 3 << 4; break;
            case 10:  IWork[GAINCODE_I_IND + i] = 1 << 4; break;
            case 100: IWork[GAINCODE_I_IND + i] = 2 << 4; break;
            case 500: IWork[GAINCODE_I_IND + i] = 3 << 4; break;
        }
    }    

#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    int_T  base      = (int_T) mxGetPr(BASE_ARG)[0];
    int_T  nChannels = (int_T) mxGetN(CHANNEL_ARG);
    int_T  *IWork    = ssGetIWork(S);
    real_T *RWork    = ssGetRWork(S);


    int_T  i, channel, gain, gaincode, count;
    real_T *y;
    
    for (i = 0; i < nChannels; i++) {

        channel = (int_T) mxGetPr(CHANNEL_ARG)[i] - 1;

        gain  = (int_T) mxGetPr(GAIN_ARG)[i];

        gaincode = IWork[GAINCODE_I_IND + i];

        /* clear DMA Done, select DMA buffer A, init A/D */
        rl32eOutpW(SUPCSR(base), 0x2240);
        
        /* enable writes to RAM channel-gain list, set list length to 1 */
        rl32eOutpW(CHANCSR(base), 0x8000);

        /* enable A/D clock, no interrupt on A/D done, select gain & channel */
        rl32eOutpW(ADCSR(base), 0x200 | gaincode | channel);

        /* disable writes to RAM channel-gain list */
        rl32eOutpW(CHANCSR(base), 0);

        /* internal clock source, no DMA, no err interrupt, preload channel */
        rl32eOutpW(SUPCSR(base), 0x10);

        /* wait for MUX to settle */
        while (rl32eInpW(ADCSR(base)) & 0x100);

        /* internal clock source, issue software trigger to start clock */
        rl32eOutpW(SUPCSR(base), 0x08);

        /* wait till A/D is completed */
        while ((rl32eInpW(ADCSR(base)) & 0x80) == 0);

        /* read resulting count */
        count = rl32eInpW(ADDAT(base));
        
        y = ssGetOutputPortRealSignal(S, i);

        y[0] = RWork[COEFF_R_IND] * count + RWork[OFFSET_R_IND];

        y[0] /= gain;

        /* mystery delay here prevents channel crosstalk */
        rl32eWaitDouble(0.000001);
    }

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


