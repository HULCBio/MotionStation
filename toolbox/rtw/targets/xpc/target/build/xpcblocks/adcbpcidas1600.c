/* $Revision: 1.7 $ $Date: 2002/03/25 03:59:30 $ */
/* adcbpcidas1600.c - S-function driver for analog input on Computer Boards PCI-DAS 1600 Series Boards*/
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL    2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME     adcbpcidas1600

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
static void     cal_ad12(int range,unsigned int base_pci, unsigned int base_status);
static void     cal_ad16(int range,unsigned int base_pci, unsigned int base_status);
#endif


/* Input Arguments */
#define NUMBER_OF_ARGS          (9)
#define CHANNEL_ARG             ssGetSFcnParam(S,0)
#define RANGE_ARG               ssGetSFcnParam(S,1)
#define GAIN_ARG                ssGetSFcnParam(S,2)
#define OFFSET_ARG              ssGetSFcnParam(S,3)
#define CONTROL_ARG             ssGetSFcnParam(S,4)
#define MUX_ARG                 ssGetSFcnParam(S,5)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,6)
#define SLOT_ARG                ssGetSFcnParam(S,7)
#define DEV_ARG                 ssGetSFcnParam(S,8)

#define SAMP_TIME_IND           (0)

#define NO_I_WORKS              (2)
#define BASE_ADDR_I_IND         (0)

#define NO_R_WORKS              (0)


static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{

    uint_T i;

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

    ssSetNumOutputPorts(S, (int_T)mxGetPr(CHANNEL_ARG)[0]);
    for (i=0; i<(int_T)mxGetPr(CHANNEL_ARG)[0]; i++) {
        ssSetOutputPortWidth(S, i, 1);
    }

    ssSetNumInputPorts(S, 0);

    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumPWork(S, 0);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    ssSetSFcnParamNotTunable(S,0);
    ssSetSFcnParamNotTunable(S,1);
    ssSetSFcnParamNotTunable(S,2);
    ssSetSFcnParamNotTunable(S,3);
    ssSetSFcnParamNotTunable(S,4);
    ssSetSFcnParamNotTunable(S,5);
    ssSetSFcnParamNotTunable(S,6);
    ssSetSFcnParamNotTunable(S,7);
    ssSetSFcnParamNotTunable(S,8);

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


    int_T numChannels;
    int_T range, control;

    PCIDeviceInfo pciinfo;
    uint_T base_adc, base_status, base_pci;
    char devName[20];
    int  devId;


    switch ((int_T)mxGetPr(DEV_ARG)[0]) {
      case 1:
        strcpy(devName,"CB PCI-DAS1602/12");
        devId=0x10;
        break;
      case 2:
        strcpy(devName,"CB PCI-DAS1602/16");
        devId=0x1;
        break;
      case 3:
        strcpy(devName,"CB PCIM-DAS1602/16");
        devId=0x56;
        break;

    }

    if ((int_T)mxGetPr(SLOT_ARG)[0]<0) {
        // look for the PCI-Device
        if (rl32eGetPCIInfo(0x1307,(unsigned short)devId,&pciinfo)) {
            sprintf(msg,"%s: board not present", devName);
            ssSetErrorStatus(S,msg);
            return;
        }
    } else {
        int_T bus, slot;
        if (mxGetN(SLOT_ARG) == 1) {
            bus  = 0;
            slot = (int_T)mxGetPr(SLOT_ARG)[0];
        } else {
            bus = (int_T)mxGetPr(SLOT_ARG)[0];
            slot = (int_T)mxGetPr(SLOT_ARG)[1];
        }
        // look for the PCI-Device
        if (rl32eGetPCIInfoAtSlot(0x1307,(unsigned short)devId,(slot & 0xff) | ((bus & 0xff)<< 8),&pciinfo)) {
            sprintf(msg,"%s (bus %d, slot %d): board not present",devName, bus, slot );
            ssSetErrorStatus(S,msg);
            return;
        }
    }

    // show Device Information
    // rl32eShowPCIInfo(pciinfo);

    base_pci=pciinfo.BaseAddress[0];
    if ((int_T)mxGetPr(DEV_ARG)[0]<3) {
        base_status=pciinfo.BaseAddress[1];
        base_adc=pciinfo.BaseAddress[2];
    } else {
        base_status=pciinfo.BaseAddress[3];
        base_adc=pciinfo.BaseAddress[2];
    }

    ssSetIWorkValue(S, BASE_ADDR_I_IND, (int_T)base_status);
    ssSetIWorkValue(S, BASE_ADDR_I_IND+1, (int_T)base_adc);

    numChannels = (int_T)mxGetPr(CHANNEL_ARG)[0];
    range= (int_T)mxGetPr(RANGE_ARG)[0];
    control= (int_T)mxGetPr(CONTROL_ARG)[0];

    if ((int_T)mxGetPr(DEV_ARG)[0]==3) {
        int_T status;
        status=(int_T)rl32eInpB((unsigned short)(base_status+0x2));
        if (range<5) { // Bipolar
            if ( (status & 0x40) == 0x40 ) {
                sprintf(msg,"%s (%d): Polarity switch is not set to 'Bipolar'", devName, (int_T)mxGetPr(SLOT_ARG)[0]);
                ssSetErrorStatus(S,msg);
                return;
            }
        } else {
            if ( (status & 0x40) == 0x00 ) {
                sprintf(msg,"%s (%d): Polarity switch is not set to 'Unipolar'", devName, (int_T)mxGetPr(SLOT_ARG)[0]);
                ssSetErrorStatus(S,msg);
                return;
            }
        }
        if ((int_T)mxGetPr(MUX_ARG)[0]==1) { // Single-ended
            if ( (status & 0x20) == 0x00 ) {
                sprintf(msg,"%s (%d): MUX switch is not set to 'single-ended'", devName, (int_T)mxGetPr(SLOT_ARG)[0]);
                ssSetErrorStatus(S,msg);
                return;
            }
        } else {
            if ( (status & 0x20) == 0x20 ) {
                sprintf(msg,"%s (%d): MUX switch is not set to 'differential'", devName, (int_T)mxGetPr(SLOT_ARG)[0]);
                ssSetErrorStatus(S,msg);
                return;
            }
        }
        rl32eOutpB((unsigned short)(base_status+0x7),(unsigned short)((int_T)mxGetPr(CONTROL_ARG)[0]));
        /* no DMA, Software triggered A/D, interrupts disabled */
        rl32eOutpB((unsigned short)(base_status+0x4), 0x00);
        rl32eOutpB((unsigned short)(base_status+0x5), 0x00);
        rl32eOutpB((unsigned short)(base_status+0x6), 0x01);
        /* set MUX start and stop channel */
        rl32eOutpB((unsigned short)(base_status+0x0),(unsigned short)((numChannels-1)<<4));
    } else {
        rl32eOutpW((unsigned short)(base_status+0x2), (unsigned short)(((numChannels-1)<<4) | (control << 8)));
        rl32eOutpW((unsigned short)(base_adc+0x2),0x0000);
        switch ((int_T)mxGetPr(DEV_ARG)[0]) {
          case 1:
            cal_ad12(range, base_pci, base_status);
            break;
          case 2:
            cal_ad16(range, base_pci, base_status);
            break;
        }
    }
#endif
}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

    uint_T base_adc = ssGetIWorkValue(S, BASE_ADDR_I_IND+1);
    uint_T base_status = ssGetIWorkValue(S, BASE_ADDR_I_IND);
    uint_T numChannels = (int_T)mxGetPr(CHANNEL_ARG)[0];
    real_T gain = mxGetPr(GAIN_ARG)[0];
    real_T offset = mxGetPr(OFFSET_ARG)[0];
    uint_T i;
    real_T  *y;

    if ((int_T)mxGetPr(DEV_ARG)[0]==3) {
        for (i=0; i<numChannels; i++) {
            y=ssGetOutputPortSignal(S,i);
            /* start conversion */
            rl32eOutpW((unsigned short)(base_adc+0x0),0x0);
            /* wait until conversion finished */
            while ((rl32eInpB((unsigned short)(base_status+0x2)) & 0x80) == 0x80 );
            /* get value */
            y[0]=rl32eInpW((unsigned short)(base_adc+0x0))*gain-offset;
        }
    } else {
        for (i=0; i<numChannels; i++) {
            y=ssGetOutputPortSignal(S,i);
            /* start conversion */
            rl32eOutpW((unsigned short)(base_adc+0x0),0x0);
            /* wait until conversion finished */
            while ( (rl32eInpW((unsigned short)(base_status+0x0)) & 0x1000) ==0x0 );
            /* get value */
            y[0]=rl32eInpW((unsigned short)(base_adc+0x0))*gain-offset;
        }
    }

#endif

}

static void mdlTerminate(SimStruct *S)
{
}


#ifndef MATLAB_MEX_FILE

static unsigned char getnvramvalue(unsigned int base_pci, unsigned int offset)
{
    unsigned char caldat;

    while ( (rl32eInpB((unsigned short)(base_pci+0x3f)) & 0x80)!=0x00);

    rl32eOutpB((unsigned short)(base_pci+0x3f),0x80);
    rl32eOutpB((unsigned short)(base_pci+0x3e),(unsigned short)offset);

    rl32eOutpB((unsigned short)(base_pci+0x3f),0xa0);
    rl32eOutpB((unsigned short)(base_pci+0x3e),0x00);

    rl32eOutpB((unsigned short)(base_pci+0x3f),0xe0);
    while ( (rl32eInpB((unsigned short)(base_pci+0x3f)) & 0x80)!=0x00);

    caldat=rl32eInpB((unsigned short)(base_pci+0x3e));
    return caldat;

}

static void set_offsetc(unsigned int base_status, unsigned char caldat)
{

    int i,j;

    // address =0x6;
    rl32eOutpW((unsigned short)(base_status+0x6),0x4000 | 0x8000);
    rl32eOutpW((unsigned short)(base_status+0x6),0x4000 | 0x8000);
    rl32eOutpW((unsigned short)(base_status+0x6),0x4000 | 0x0000);
    for (i=0;i<8;i++) {
        j=7-i;
        if ( ((caldat & (1<<j)) >> j) == 0x1) {
            rl32eOutpW((unsigned short)(base_status+0x6),0x4000 | 0x8000);
        } else {
            rl32eOutpW((unsigned short)(base_status+0x6),0x4000 | 0x0000);
        }
    }
    rl32eOutpW((unsigned short)(base_status+0x6),0x4100);
    rl32eOutpW((unsigned short)(base_status+0x6),0x4000);
    rl32eOutpW((unsigned short)(base_status+0x6),0x0000);
}

static void set_offsetc16(unsigned int base_status, unsigned char caldat)
{

    int i,j;

    //Select 8402
    rl32eOutpW((unsigned short)base_status,0x200);
    //Setect 8402 Offset
    rl32eOutpW((unsigned short)base_status,0x8200);
    //Send Serial Data
    for (i=0;i<8;i++) {
        j=7-i;
        if ( ((caldat & (1<<j)) >> j) == 0x1) {
            rl32eOutpW((unsigned short)(base_status+0x6),0x8200);
        } else {
            rl32eOutpW((unsigned short)(base_status+0x6),0x0200);
        }
    }
    //Deselect
    rl32eOutpW((unsigned short)(base_status+0x6),0x0000);
}


static void set_offsetf(unsigned int base_status, unsigned char caldat)
{

    int i,j;

    // address =0x7;
    rl32eOutpW((unsigned short)(base_status+0x6),0x4000 | 0x8000);
    rl32eOutpW((unsigned short)(base_status+0x6),0x4000 | 0x8000);
    rl32eOutpW((unsigned short)(base_status+0x6),0x4000 | 0x8000);
    for (i=0;i<8;i++) {
        j=7-i;
        if ( ((caldat & (1<<j)) >> j) == 0x1) {
            rl32eOutpW((unsigned short)(base_status+0x6),0x4000 | 0x8000);
        } else {
            rl32eOutpW((unsigned short)(base_status+0x6),0x4000 | 0x0000);
        }
    }
    rl32eOutpW((unsigned short)(base_status+0x6),0x4100);
    rl32eOutpW((unsigned short)(base_status+0x6),0x4000);

    rl32eOutpW((unsigned short)(base_status+0x6),0x0000);

}

static void set_gain(unsigned int base_status, unsigned char caldat)
{

    int i,j;

    // address =0x0;
    rl32eOutpW((unsigned short)(base_status+0x6),0x4200);
    rl32eOutpW((unsigned short)(base_status+0x6),0x4200);
    for (i=0;i<7;i++) {
        j=7-i;
        if ( ((caldat & (1<<j)) >> j) == 0x1) {
            rl32eOutpW((unsigned short)(base_status+0x6),0x4200 | 0x8000);
        } else {
            rl32eOutpW((unsigned short)(base_status+0x6),0x4200 | 0x0000);
        }
    }
    rl32eOutpW((unsigned short)(base_status+0x6),0x4000);

    rl32eOutpW((unsigned short)(base_status+0x6),0x0000);

}

static void set_gain16(unsigned int base_status, unsigned char caldat)
{
    int i,j;

    //Select 8402
    rl32eOutpW((unsigned short)base_status,0x200);
    //Setect 8402 Offset
    rl32eOutpW((unsigned short)base_status,0x200);
    //Send Serial Data
    for (i=0;i<8;i++) {
        j=7-i;
        if ( ((caldat & (1<<j)) >> j) == 0x1) {
            rl32eOutpW((unsigned short)(base_status+0x6),0x8200);
        } else {
            rl32eOutpW((unsigned short)(base_status+0x6),0x0200);
        }
    }
    //Deselect
    rl32eOutpW((unsigned short)(base_status+0x6),0x0000);
}


static void     cal_ad12(int range,unsigned int base_pci, unsigned int base_status)
{

    unsigned char offsetc, offsetf, gain, caldat;


    offsetc =0xbc+(range-1)*3+0;
    offsetf =0xbc+(range-1)*3+1;
    gain    =0xbc+(range-1)*3+2;

    caldat=getnvramvalue(base_pci, offsetc);
    set_offsetc(base_status, caldat);

    caldat=getnvramvalue(base_pci, offsetf);
    set_offsetf(base_status,caldat);

    caldat=getnvramvalue(base_pci, gain);
    set_gain(base_status, caldat);

}

static void     cal_ad16(int range,unsigned int base_pci, unsigned int base_status)
{
    unsigned char offsetc, offsetf, gain, caldat;

    offsetc =0xbc+(range-1)*3+0;
    offsetf =0xbc+(range-1)*3+1;
    gain    =0xbc+(range-1)*3+2;


    caldat=getnvramvalue(base_pci, offsetc);
    //Set SEL08
    //Select SEL08
    rl32eOutpW((unsigned short)base_status,0x400);
    //Deselect SEL08 + Write Data
    rl32eOutpW((unsigned short)base_status,caldat);

    caldat=getnvramvalue(base_pci, offsetc);
    set_offsetc16(base_status, caldat);

    caldat=getnvramvalue(base_pci, gain);
    set_gain16(base_status, caldat);
}


#endif


#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
