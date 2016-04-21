// addiamondmm32frame.c - xPC Target, non-inlined S-function 
// frame-based driver for A/D section of Diamond Systems MM-32 boards  
// Copyright 2003 The MathWorks, Inc.

#define     S_FUNCTION_LEVEL    2
#undef      S_FUNCTION_NAME
#define     S_FUNCTION_NAME     addiamondmm32frame

#include    <stddef.h>
#include    <stdlib.h>
#include    <math.h>

#include    "simstruc.h" 

#ifdef      MATLAB_MEX_FILE
#include    "mex.h"
#endif

#ifndef     MATLAB_MEX_FILE
#include    <windows.h>
#include    "io_xpcimport.h"
#include    "util_xpcimport.h"
#endif


// input arguments
#define NUM_ARGS          (10)
#define RANGE_ARG         ssGetSFcnParam(S,0) // see range switch
#define FIRST_CHAN_ARG    ssGetSFcnParam(S,1) // 1:32, 1:24, or 1:16
#define NUM_CHANS_ARG     ssGetSFcnParam(S,2) // 1:32, 1:24, or 1:16
#define NUM_SCANS_ARG     ssGetSFcnParam(S,3) // scans per frame
#define SCAN_INTERVAL_ARG ssGetSFcnParam(S,4) // 1:5us, 2:10us, 3:15us, 4:20us
#define FREQ12_ARG        ssGetSFcnParam(S,5) // 0:10MHz, 1:100KHz
#define COUNT1_ARG        ssGetSFcnParam(S,6) // counter 1 subdivide 
#define COUNT2_ARG        ssGetSFcnParam(S,7) // counter 2 subdivide 
#define OUT_SIG_TYPE_ARG  ssGetSFcnParam(S,8) // 0:vector, 1:frame
#define BASE_ARG          ssGetSFcnParam(S,9) // ISA base address

// write register offsets
#define START_AD_CONVERSION             (0)
#define AUX_DIGITAL_OUTPUT              (1)
#define AD_LO_CHAN_REGISTER             (2) 
#define AD_HI_CHAN_REGISTER             (3) 
#define DA_LSB_REGISTER                 (4) 
#define DA_MSB_AND_CHAN_REGISTER        (5) 
#define FIFO_DEPTH_REGISTER             (6) 
#define FIFO_CONTROL_REGISTER           (7) 
#define MISC_CONTROL_REGISTER           (8) 
#define OPERATION_CONTROL_REGISTER      (9) 
#define COUNTER_AND_DIO_CONFIG_REGISTER (10) 
#define ANALOG_CONFIGURATION_REGISTER   (11) 

#define COUNTER_0_REGISTER              (12) 
#define COUNTER_1_REGISTER              (13) 
#define COUNTER_2_REGISTER              (14) 
#define COUNTER_CONTROL_REGISTER        (15) 

// read register offsets
#define AD_LSB                          (0)
#define AD_MSB                          (1)
#define AD_LO_CHAN_REGISTER_READBACK    (2) 
#define AD_HI_CHAN_REGISTER_READBACK    (3) 
#define AUX_DIGITAL_INPUT_PORT          (4) 
#define UPDATE_ALL_DA_CHANNELS          (5) 
#define FIFO_DEPTH_REGISTER             (6) 
#define FIFO_STATUS_REGISTER            (7) 
#define AD_STATUS_REGISTER              (8) 
#define OPERATION_STATUS_REGISTER       (9) 
#define COUNTER_TIMER_CONTROL_READBACK  (10) 
#define ANALOG_CONFIGURATION_READBACK   (11) 

#define RESOLUTION                      (65536)

#define SAMP_TIME_IND                   (0)
#define NUM_I_WORKS                     (0)
#define NUM_R_WORKS                     (2)
#define GAIN_R_IND                      (0)
#define OFFSET_R_IND                    (1)

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
    int_T i;
    int_T numChans   = mxGetPr(NUM_CHANS_ARG)[0];
    int_T numScans   = mxGetPr(NUM_SCANS_ARG)[0];
    int_T outSigType = mxGetPr(OUT_SIG_TYPE_ARG)[0];

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

    ssSetNumOutputPorts(S, numChans);

    for (i = 0; i < numChans; i++) {
        if( !ssSetOutputPortMatrixDimensions( S, i, numScans, 1 ) )
            return;
        ssSetOutputPortDataType( S, i, SS_DOUBLE );
        if((outSigType == 2) && (numScans > 1))
            ssSetOutputPortFrameData( S, i, 1 );
        else
            ssSetOutputPortFrameData( S, i, 0 );
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
    int_T  freq12     = mxGetPr(FREQ12_ARG)[0];
    real_T count1     = mxGetPr(COUNT1_ARG)[0]; 
    real_T count2     = mxGetPr(COUNT2_ARG)[0]; 
    real_T numScans   = mxGetPr(NUM_SCANS_ARG)[0]; 
    real_T baseTime   = freq12 ? 1e-5 : 1e-7;
    real_T scanTime   = count1 * count2 * baseTime;
    real_T sampleTime = numScans * scanTime;
 
    ssSetSampleTime(S, 0, sampleTime);
    ssSetOffsetTime(S, 0, 0.0);
}
 

#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
    real_T *RWork     = ssGetRWork(S);
    uint_T  base      = mxGetPr(BASE_ARG)[0]; 
    int_T   range     = mxGetPr(RANGE_ARG)[0];
    int_T   numChans  = mxGetPr(NUM_CHANS_ARG)[0]; 
    int_T   numScans  = mxGetPr(NUM_SCANS_ARG)[0]; 
    int_T   fifoDepth = numChans * numScans;
    int_T   scint     = 4 - mxGetPr(SCAN_INTERVAL_ARG)[0]; 
    int_T   freq12    = mxGetPr(FREQ12_ARG)[0]; 
    int_T   count1    = mxGetPr(COUNT1_ARG)[0]; 
    int_T   count2    = mxGetPr(COUNT2_ARG)[0]; 
    int_T   loChan    = mxGetPr(FIRST_CHAN_ARG)[0] - 1;
    int_T   hiChan    = loChan + numChans - 1;

    uint8_T code;

    if (xpceIsModelInit)
        return;

    switch (range) {
        case 1:  // -10V to +10V
            RWork[GAIN_R_IND] = 10.0 / (RESOLUTION / 2);
            RWork[OFFSET_R_IND] = 0;
            code =  8; 
            break;
        case 2:  // -5V to +5V
            RWork[GAIN_R_IND] = 5.0 / (RESOLUTION / 2);
            RWork[OFFSET_R_IND] = 0;
            code =  0x0; 
            break;
        case 3:  // -2.5V to +2.5V
            RWork[GAIN_R_IND] = 2.5 / (RESOLUTION / 2);
            RWork[OFFSET_R_IND] = 0;
            code =  0x1; 
            break;
        case 4:  // -1.25V to +1.25V
            RWork[GAIN_R_IND] = 1.25 / (RESOLUTION / 2);
            RWork[OFFSET_R_IND] = 0;
            code =  0x2; 
            break;
        case 5:  // -0.625V to +0.625V
            RWork[GAIN_R_IND] = 0.625 / (RESOLUTION / 2);
            RWork[OFFSET_R_IND] = 0;
            code =  0x3; 
            break;
        case 6:  // 0 to +10V
            RWork[GAIN_R_IND] = 10.0 / RESOLUTION;
            RWork[OFFSET_R_IND] = RESOLUTION / 2;
            code = 0xc; 
            break;
        case 7:  // 0V to +5V
            RWork[GAIN_R_IND] = 5.0 / RESOLUTION;
            RWork[OFFSET_R_IND] = RESOLUTION / 2;
            code = 0xd; 
            break;
        case 8:  // 0V to +2.5V
            RWork[GAIN_R_IND] = 2.5 / RESOLUTION;
            RWork[OFFSET_R_IND] = RESOLUTION / 2;
            code = 0xe; 
            break;
        case 9:  // 0V to +1.25V
            RWork[GAIN_R_IND] = 1.25 / RESOLUTION;
            RWork[OFFSET_R_IND] = RESOLUTION / 2;
            code = 0xf; 
            break;
        default: 
            printf("bad range param for MM-32 A/D: %d\n", range);
    }

    rl32eOutpB(base + MISC_CONTROL_REGISTER, 0
        | 0x20 * 0  // RESETA: reset all
        | 0x10 * 1  // RESETD: reset all but D/A
        | 0x08 * 1  // INTRST: reset interrupt  
        | 0x01 * 0  // PAGE:   register page = 8254 timer
        );

    rl32eOutpB(base + OPERATION_CONTROL_REGISTER, 0
        | 0x80 * 0  // ADINTE: enable analog interrupt
        | 0x40 * 0  // DINTE:  enable digital interrupt
        | 0x20 * 0  // TINTE:  enable timer 0 interrupt
        | 0x02 * 0  // CLKEN:  enable A/D sampling clock
        | 0x01 * 1  // CLKSEL: select internal H/W clock 
        );

    rl32eOutpB(base + COUNTER_AND_DIO_CONFIG_REGISTER, 0
        | 0x80 * freq12 // FREQ12: 0 for 10MHz, 1 for 100KHz input to counter 1
        | 0x20 * 0      // OUT2EN: put counter 2 output on J3 pin 42
        | 0x01 * 0      // GT12EN: use J3 pin 4 as A/D conversion gate   
        );

    rl32eOutpB(base + FIFO_DEPTH_REGISTER, fifoDepth >> 1);

    rl32eOutpB(base + FIFO_CONTROL_REGISTER, 0
        | 0x08 * 1  // FIFOEN:  enable FIFO
        | 0x04 * 1  // SCANEN:  enable scan
        | 0x02 * 1  // FIFORST: reset FIFO
        );

    rl32eOutpB(base + AD_LO_CHAN_REGISTER, loChan);
    rl32eOutpB(base + AD_HI_CHAN_REGISTER, hiChan);

    rl32eOutpB(base + ANALOG_CONFIGURATION_REGISTER, 0
        | 0x10 * scint // SCINT0-SCINT1: scan interval (5, 10, 15, or 20 us) 
        | 0x01 * code  // RANGE, ADBU, G0-G1: range, polarity, and gain
        );

    rl32eOutpB(base + COUNTER_CONTROL_REGISTER, 0
        | 0x40 * 1  // SC0-SC1: select counter 1
        | 0x10 * 3  // RW0-RW1: R/W lo byte, then hi byte
        | 0x02 * 2  // M0-M2:   mode 2 (rate generator)
        );

    rl32eOutpB(base + COUNTER_1_REGISTER, count1);  
    rl32eOutpB(base + COUNTER_1_REGISTER, count1 >> 8);  

    rl32eOutpB(base + COUNTER_CONTROL_REGISTER, 0
        | 0x40 * 2  // SC0-SC1: select counter 2
        | 0x10 * 3  // RW0-RW1: R/W lo byte, then hi byte
        | 0x02 * 2  // M0-M2:   mode 2 (rate generator)
        );

    rl32eOutpB(base + COUNTER_2_REGISTER, count2);  
    rl32eOutpB(base + COUNTER_2_REGISTER, count2 >> 8);  

    // leave PAGE set to DIO for compatibility with digital drivers
    rl32eOutpB(base + MISC_CONTROL_REGISTER, 0
        | 0x20 * 0  // RESETA: reset all
        | 0x10 * 0  // RESETD: reset all but D/A
        | 0x08 * 0  // INTRST: reset interrupt  
        | 0x01 * 1  // PAGE:   register page = 8255 digital I/O
        );

    // A/D interrupts are enabled in xpcmm32start

#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    real_T *RWork    = ssGetRWork(S);
    real_T  gain     = RWork[GAIN_R_IND];
    real_T  offset   = RWork[OFFSET_R_IND];
    int_T   base     = mxGetPr(BASE_ARG)[0];
    int_T   numChans = mxGetPr(NUM_CHANS_ARG)[0];
    int_T   numScans = mxGetPr(NUM_SCANS_ARG)[0];

    int16_T count;
    int_T   chan, scan;
    real_T *port, voltage;

    for (scan = 0; scan < numScans; scan++) {
        for (chan = 0; chan < numChans; chan++) {
            port = ssGetOutputPortSignal(S, chan);
            count = rl32eInpW(base + AD_LSB);
            voltage = gain * (count + offset);   
            port[scan] = voltage;          
        }
    }

    // toggle pin 43 for test purposes
    // rl32eOutpB(base + AUX_DIGITAL_OUTPUT, 2); 
    // rl32eOutpB(base + AUX_DIGITAL_OUTPUT, 0);
#endif
}

static void mdlTerminate(SimStruct *S)
{   
#ifndef MATLAB_MEX_FILE
    uint_T base = mxGetPr(BASE_ARG)[0]; 

    if (xpceIsModelInit)
        return;

    rl32eOutpB(base + OPERATION_CONTROL_REGISTER, 0
        | 0x80 * 0  // ADINTE: enable analog interrupt
        | 0x40 * 0  // DINTE:  enable digital interrupt
        | 0x20 * 0  // TINTE:  enable timer 0 interrupt
        | 0x02 * 0  // CLKEN:  enable A/D sampling clock
        | 0x01 * 0  // CLKSEL: select internal H/W clock 
        );
#endif
}


#ifdef MATLAB_MEX_FILE
#include "simulink.c"  // Mex glue
#else
#include "cg_sfun.h"   // Code generation glue
#endif
