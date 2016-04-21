/* $Revision: 1.13.4.1 $ $Date: 2004/04/08 21:01:56 $ */
/* dacbpcidas1600.c - S-function driver for analog output on Computer Boards PCI-DAS 1600 Series Boards*/
/* Copyright 1996-2003 The MathWorks, Inc.
*/

#define   S_FUNCTION_LEVEL   2
#undef    S_FUNCTION_NAME
#define   S_FUNCTION_NAME    dacbpcidas1600

#include  <stddef.h>
#include  <stdlib.h>

#include  "simstruc.h"

#ifdef    MATLAB_MEX_FILE
#include  "mex.h"
#endif

#ifndef   MATLAB_MEX_FILE
#include  <windows.h>
#include  "io_xpcimport.h"
#include  "pci_xpcimport.h"
#include  "time_xpcimport.h"
#include  "util_xpcimport.h"
#include  "xpcioni.h"
#endif

// Input Arguments
#define NUM_ARGS        (7)
#define CHANNEL_ARG     ssGetSFcnParam(S,0)
#define RANGE_ARG       ssGetSFcnParam(S,1)
#define RESET_ARG       ssGetSFcnParam(S,2)
#define INIT_VAL_ARG    ssGetSFcnParam(S,3)
#define SAMP_TIME_ARG   ssGetSFcnParam(S,4)
#define SLOT_ARG        ssGetSFcnParam(S,5)
#define DEV_ARG         ssGetSFcnParam(S,6)

#define NUM_I_WORKS     (5)
#define MAXCOUNT_I_IND  (0)
#define BADR1_I_IND     (1)
#define BADR4_I_IND     (2)
#define CONTROL_I_IND   (3) // two elements

#define NUM_R_WORKS     (4)
#define GAIN_R_IND      (0)
#define OFFSET_R_IND    (2)

#define DAC_CSR         (0x8)  // BADR1 register offsets

#define DAC_DATA        (0x0)  // BADR4 register offsets
#define DAC_FIFO_CLEAR  (0x2)


static void cal_da(int chan, int range,unsigned int badr0, unsigned int badr1);

typedef enum {
    PCI_DAS1602_12 = 1,
    PCI_DAS1602_16 = 2
} device_T;

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{
    int i;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "pci_xpcimport.c"
#include "time_xpcimport.c"
#include "util_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUM_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"%d input args expected, %d passed", 
            NUM_ARGS, ssGetSFcnParamsCount(S));
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    ssSetNumInputPorts(S, mxGetN(CHANNEL_ARG));
    for (i = 0;i<mxGetN(CHANNEL_ARG);i++) {
        ssSetInputPortWidth(S, i, 1);
        ssSetInputPortDirectFeedThrough(S, i, 1);
    }

    ssSetNumOutputPorts(S, 0);

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
    ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME_ARG)[0]);
    ssSetOffsetTime(S, 0, 0.0);
}


#define MDL_START
static void mdlStart(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE

    int_T    nChans      = mxGetN(CHANNEL_ARG);
    device_T device      = (device_T) mxGetPr(DEV_ARG)[0];
    int_T    calRange[2] = {1,1};

    int_T    i, chan, count, range;
    int_T    control[2], dacnr, DACnR;
    int_T    devId, badr0, badr1, badr4;
    real_T   value, resolution;

    PCIDeviceInfo pciinfo;
    char devName[20];

    switch (device) {
      case PCI_DAS1602_12:
        strcpy(devName,"CB PCI-DAS1602/12");
        devId = 0x10;
        resolution = 4096.0;
        ssSetIWorkValue(S, MAXCOUNT_I_IND, 4095);
        break;
      case PCI_DAS1602_16:
        strcpy(devName,"CB PCI-DAS1602/16");
        devId = 0x1;
        resolution = 65536.0;
        ssSetIWorkValue(S, MAXCOUNT_I_IND, 65535);
        break;
      default:
        sprintf(msg,"bad device argument: %d", device);
        ssSetErrorStatus(S,msg);
        return;
    }

    if ((int_T)mxGetPr(SLOT_ARG)[0]<0) {
        // look for the PCI-Device
        if (rl32eGetPCIInfo((unsigned short)0x1307,(unsigned short)devId, &pciinfo)) {
            sprintf(msg,"%s: board not present", devName);
            ssSetErrorStatus(S,msg);
            return;
        }
    } else {
        int_T bus, slot;
        if (mxGetN(SLOT_ARG) == 1) {
            bus = 0;
            slot = (int_T)mxGetPr(SLOT_ARG)[0];
        } else {
            bus = (int_T)mxGetPr(SLOT_ARG)[0];
            slot = (int_T)mxGetPr(SLOT_ARG)[1];
        }
        // look for the PCI-Device
        if (rl32eGetPCIInfoAtSlot((unsigned short)0x1307,(unsigned short)devId,(slot & 0xff) | ((bus & 0xff)<< 8),&pciinfo)) {
            sprintf(msg,"%s (bus %d, slot %d): board not present",devName, bus, slot );
            ssSetErrorStatus(S,msg);
            return;
        }
    }

    // show Device Information
    // rl32eShowPCIInfo(pciinfo);

    badr0 = pciinfo.BaseAddress[0];
    badr1 = pciinfo.BaseAddress[1];
    badr4 = pciinfo.BaseAddress[4];

    ssSetIWorkValue(S, BADR1_I_IND, badr1);
    ssSetIWorkValue(S, BADR4_I_IND, badr4);

    control[0] = control[1] = 7;
    DACnR = 0;

    for (i = 0; i < nChans; i++) {

        chan = mxGetPr(CHANNEL_ARG)[i] - 1;
        range = (int_T)(mxGetPr(RANGE_ARG)[i]);

        switch (range) {
          case -10:
            dacnr = 0x1;
            calRange[chan] = 0x1;
            ssSetRWorkValue(S, GAIN_R_IND + chan, 20.0 / resolution);
            ssSetRWorkValue(S, OFFSET_R_IND + chan, 10.0);
            break;
          case -5:
            dacnr = 0x0;
            calRange[chan] = 0x0;
            ssSetRWorkValue(S, GAIN_R_IND + chan, 10.0 / resolution);
            ssSetRWorkValue(S, OFFSET_R_IND + chan, 5.0);
            break;
          case 10:
            dacnr = 0x3;
            calRange[chan] = 0x3;
            ssSetRWorkValue(S, GAIN_R_IND + chan, 10.0 / resolution);
            ssSetRWorkValue(S, OFFSET_R_IND + chan, 0.0);
            break;
          case 5:
            dacnr = 0x2;
            calRange[chan] = 0x2;
            ssSetRWorkValue(S, GAIN_R_IND + chan, 5.0 / resolution);
            ssSetRWorkValue(S, OFFSET_R_IND + chan, 0.0);
            break;
          default:
            sprintf(msg, "bad range argument: %d", range);
            ssSetErrorStatus(S, msg);
            return;
        }
        
        DACnR |= (dacnr << (2 * chan + 8));   // gain and range settings
        
        control[chan] |= (1 << (chan + 5));   // high-speed DAC mode 
    }

    control[0] |= DACnR;
    control[1] |= DACnR;

    ssSetIWorkValue(S, CONTROL_I_IND + 0, control[0]);
    ssSetIWorkValue(S, CONTROL_I_IND + 1, control[1]);

    cal_da(0, calRange[0], badr0, badr1);
    cal_da(1, calRange[1], badr0, badr1);
#endif
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE

    int_T    nChans   = mxGetN(CHANNEL_ARG);
    int_T    maxCount = ssGetIWorkValue(S, MAXCOUNT_I_IND);
    int_T    badr1    = ssGetIWorkValue(S, BADR1_I_IND);
    int_T    badr4    = ssGetIWorkValue(S, BADR4_I_IND);
    device_T device   = (device_T)mxGetPr(DEV_ARG)[0];

    int_T    i, chan, count, control[2];
    real_T   value;

    InputRealPtrsType uPtrs;

    control[0] = ssGetIWorkValue(S, CONTROL_I_IND + 0);
    control[1] = ssGetIWorkValue(S, CONTROL_I_IND + 1);

    for (i = 0; i < nChans; i++) {
        chan = mxGetPr(CHANNEL_ARG)[i] - 1;
        uPtrs = ssGetInputPortRealSignalPtrs(S,i);
        value = *uPtrs[0];

        count = (value + ssGetRWorkValue(S, OFFSET_R_IND + chan)) /
            ssGetRWorkValue(S, GAIN_R_IND + chan);

        if (count < 0) 
            count = 0;
        if (count > maxCount) 
            count = maxCount;

        rl32eOutpW(badr4 + DAC_FIFO_CLEAR, 0x0); 
        rl32eOutpW(badr1 + DAC_CSR, control[chan]);
        rl32eOutpW(badr4 + DAC_DATA, count);
    }
    rl32eOutpW(badr4 + DAC_FIFO_CLEAR, 0x0); 
#endif
}


static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE

    int_T    nChans   = mxGetN(CHANNEL_ARG);
    int_T    maxCount = ssGetIWorkValue(S, MAXCOUNT_I_IND);
    int_T    badr1    = ssGetIWorkValue(S, BADR1_I_IND);
    int_T    badr4    = ssGetIWorkValue(S, BADR4_I_IND);
    device_T device   = (device_T)mxGetPr(DEV_ARG)[0];

    int_T    i, chan, count, control[2];
    real_T   value;

    // At load time, set channels to their initial values.
    // At model termination, reset resettable channels to their initial values.

    for (i = 0; i < nChans; i++) {
        if (xpceIsModelInit() || (uint_T)mxGetPr(RESET_ARG)[i]) {
        
            control[0] = ssGetIWorkValue(S, CONTROL_I_IND + 0);
            control[1] = ssGetIWorkValue(S, CONTROL_I_IND + 1);

            chan = mxGetPr(CHANNEL_ARG)[i] - 1;
            value = (real_T)mxGetPr(INIT_VAL_ARG)[i];

            count = (value + ssGetRWorkValue(S, OFFSET_R_IND + chan)) / 
                ssGetRWorkValue(S, GAIN_R_IND + chan);

            if (count < 0) 
                count = 0;
            if (count > maxCount) 
                count = maxCount;
            
            rl32eOutpW(badr4 + DAC_FIFO_CLEAR, 0x0); 
            rl32eOutpW(badr1 + DAC_CSR, control[chan]);
            rl32eOutpW(badr4 + DAC_DATA, count);
        }
        rl32eOutpW(badr4 + DAC_FIFO_CLEAR, 0x0); 
    }
#endif
}


#ifndef MATLAB_MEX_FILE

static unsigned char getnvramvalue(unsigned int badr0, unsigned int offset)
{
    unsigned char caldat;

    while ( (rl32eInpB((unsigned short)(badr0 + 0x3f)) & 0x80) != 0x00);

    rl32eOutpB((unsigned short)(badr0 + 0x3f), 0x80);
    rl32eOutpB((unsigned short)(badr0 + 0x3e),(unsigned short)offset);

    rl32eOutpB((unsigned short)(badr0 + 0x3f), 0xa0);
    rl32eOutpB((unsigned short)(badr0 + 0x3e), 0x00);

    rl32eOutpB((unsigned short)(badr0 + 0x3f), 0xe0);
    while ( (rl32eInpB((unsigned short)(badr0 + 0x3f)) & 0x80) != 0x00);

    caldat=rl32eInpB((unsigned short)(badr0 + 0x3e));
    return caldat;
}

static void set_gainc0(unsigned int badr1, unsigned char caldat)
{
    int i,j;

    // address = 0x1;
    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000 | 0x0000);
    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000 | 0x0000);
    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000 | 0x8000);
    for (i = 0; i < 8; i++) {
        j = 7-i;
        if ( ((caldat & (1<<j)) >> j) == 0x1) {
            rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000 | 0x8000);
        } else {
            rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000 | 0x0000);
        }
    }
    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4100);
    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000);

    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x0000);
}

static void set_gainc1(unsigned int badr1, unsigned char caldat)
{

    int i,j;

    // address = 0x5;
    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000 | 0x8000);
    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000 | 0x0000);
    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000 | 0x8000);
    for (i = 0; i < 8; i++) {
        j = 7-i;
        if ( ((caldat & (1<<j)) >> j) == 0x1) {
            rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000 | 0x8000);
        } else {
            rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000 | 0x0000);
        }
    }
    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4100);
    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000);

    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x0000);
}


static void set_offset0(unsigned int badr1, unsigned char caldat)
{
    int i,j;

    // address = 0x2;
    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000 | 0x0000);
    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000 | 0x8000);
    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000 | 0x0000);
    for (i = 0; i < 8; i++) {
        j = 7-i;
        if ( ((caldat & (1<<j)) >> j) == 0x1) {
            rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000 | 0x8000);
        } else {
            rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000 | 0x0000);
        }
    }
    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4100);
    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000);

    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x0000);
}

static void set_offset1(unsigned int badr1, unsigned char caldat)
{
    int i,j;

    // address = 0x3;
    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000 | 0x0000);
    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000 | 0x8000);
    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000 | 0x8000);
    for (i = 0; i < 8; i++) {
        j = 7-i;
        if ( ((caldat & (1<<j)) >> j) == 0x1) {
            rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000 | 0x8000);
        } else {
            rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000 | 0x0000);
        }
    }
    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4100);
    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000);

    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x0000);
}


static void set_gainf0(unsigned int badr1, unsigned char caldat)
{
    int i,j;

    // address = 0x0;
    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000 | 0x0000);
    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000 | 0x0000);
    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000 | 0x0000);
    for (i = 0; i < 8; i++) {
        j = 7-i;
        if ( ((caldat & (1<<j)) >> j) == 0x1) {
            rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000 | 0x8000);
        } else {
            rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000 | 0x0000);
        }
    }
    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4100);
    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000);

    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x0000);
}

static void set_gainf1(unsigned int badr1, unsigned char caldat)
{
    int i,j;

    // address = 0x4;
    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000 | 0x8000);
    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000 | 0x0000);
    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000 | 0x0000);
    for (i = 0; i < 8; i++) {
        j = 7-i;
        if ( ((caldat & (1<<j)) >> j) == 0x1) {
            rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000 | 0x8000);
        } else {
            rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000 | 0x0000);
        }
    }
    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4100);
    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000);

    rl32eOutpW((unsigned short)(badr1 + 0x6), 0x0000);
}


static void cal_da(int chan, int range,unsigned int badr0, unsigned int badr1)
{
    unsigned char gainc, offset, gainf, caldat;

    if (chan == 0) {

        gainc  = 0xdc+(range)*4+0;
        offset = 0xdc+(range)*4+1;
        gainf  = 0xdc+(range)*4+2;
        //printf("gainc: %x, offset: %x, gainf: %x\n",gainc, offset, gainf);

        rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000);
        caldat = getnvramvalue(badr0, gainc);
        //printf("gainc: %x\n",caldat);
        set_gainc0(badr1, caldat);

        rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000);
        caldat = getnvramvalue(badr0, offset);
        //printf("offset: %x\n",caldat);
        set_offset0(badr1,caldat);

        rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000);
        caldat = getnvramvalue(badr0, gainf);
        //printf("gainf: %x\n",caldat);
        set_gainf0(badr1, caldat);


    } else if (chan == 1) {

        gainc  = 0xec+(range)*4+0;
        offset = 0xec+(range)*4+1;
        gainf  = 0xec+(range)*4+2;
        //printf("gainc: %x, offset: %x, gainf: %x\n",gainc, offset, gainf);

        rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000);
        caldat = getnvramvalue(badr0, gainc);
        //printf("gainc: %x\n",caldat);
        set_gainc1(badr1, caldat);

        rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000);
        caldat = getnvramvalue(badr0, offset);
        //printf("offset: %x\n",caldat);
        set_offset1(badr1,caldat);

        rl32eOutpW((unsigned short)(badr1 + 0x6), 0x4000);
        caldat = getnvramvalue(badr0, gainf);
        //printf("gainf: %x\n",caldat);
        set_gainf1(badr1, caldat);
    }
}
#endif



#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
