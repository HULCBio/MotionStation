/* $Revision: 1.4 $ $Date: 2002/03/25 04:00:10 $ */
/* adrtddm7420.c - xPC Target, non-inlined S-function driver for A/D section of RTD DM7420 board  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         adrtddm7420

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
#include        "time_xpcimport.h"
#endif


/* Input Arguments */
#define NUMBER_OF_ARGS          (7)
#define CHANNEL_ARG             ssGetSFcnParam(S,0)
#define COUPLING_ARG            ssGetSFcnParam(S,1)
#define RANGE_ARG               ssGetSFcnParam(S,2)
#define GAIN_ARG                ssGetSFcnParam(S,3)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,4)
#define SLOT_ARG                ssGetSFcnParam(S,5)
#define DEV_ARG                 ssGetSFcnParam(S,6)

#define SAMP_TIME_IND           (0)

#define NO_I_WORKS              (3)
#define LAS0_I_IND              (0)
#define LAS1_I_IND              (1)
#define LAS2_I_IND              (2)


#define NO_R_WORKS              (0)

#define RES20V                  0.0048828125
#define RES10V                  0.00244140625


static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{

    uint_T i;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "pci_xpcimport.c"
#include "time_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"Wrong number of input arguments passed.\n%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    ssSetNumOutputPorts(S,mxGetN(CHANNEL_ARG));
    for (i=0; i<mxGetN(CHANNEL_ARG); i++) {
        ssSetOutputPortWidth(S, i, 1);
    }

    ssSetNumInputPorts(S, 0);

    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumPWork(S, 0);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    for (i=0; i<NUMBER_OF_ARGS; i++) {
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


    uint16_T numChannels;

    PCIDeviceInfo pciinfo;
    char devName[20];
    uint16_T        LAS0, LAS1, LAS2;
    int  devId;
    uint16_T i, j;
    uint16_T output, channel, gain, coupling, range;
    real_T currentTime;

    switch ((int_T)mxGetPr(DEV_ARG)[0]) {
      case 1:
        strcpy(devName,"RTD DM7420");
        devId=0x7420;
        break;
    }


    if ((int_T)mxGetPr(SLOT_ARG)[0]<0) {
        /* look for the PCI-Device */
        if (rl32eGetPCIInfo((unsigned short)0x1435,(unsigned short)devId,&pciinfo)) {
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
        if (rl32eGetPCIInfoAtSlot((unsigned short)0x1435,(unsigned short)devId,(slot & 0xff) | ((bus & 0xff)<< 8), &pciinfo)) {
            sprintf(msg,"%s (bus %d, slot %d): board not present",devName, bus, slot );
            ssSetErrorStatus(S,msg);
            return;
        }
    }

    // show Device Information
    // rl32eShowPCIInfo(pciinfo);

    LAS0= pciinfo.BaseAddress[2];
    LAS1= pciinfo.BaseAddress[3];
    LAS2= pciinfo.BaseAddress[4];

    ssSetIWorkValue(S, LAS0_I_IND, (int_T)LAS0);
    ssSetIWorkValue(S, LAS1_I_IND, (int_T)LAS1);
    ssSetIWorkValue(S, LAS2_I_IND, (int_T)LAS2);

    numChannels = (int16_T)mxGetN(CHANNEL_ARG);

    // A/D timing

    // A/D conversion signal select: Burst Mode
    rl32eOutpW(LAS0+0x00,0x0200);
    rl32eOutpW(LAS0+0x02,0x0002);

    // Burst clock start trigger select: Software
    rl32eOutpW(LAS0+0x00,0x0201);
    rl32eOutpW(LAS0+0x02,0x0000);

    // clear high speed digital input FIFO
    rl32eOutpW(LAS0+0x00,0x020e);
    rl32eOutpW(LAS0+0x02,0x0000);
    // clear A/D FIFO
    rl32eOutpW(LAS0+0x00,0x020f);
    rl32eOutpW(LAS0+0x02,0x0000);

    // clear A/D channel gain table
    rl32eOutpW(LAS0+0x00,0x030f);
    rl32eOutpW(LAS0+0x02,0x0000);

    // fill-in A/D channel gain table
    rl32eOutpW(LAS0+0x00,0x0300);
    for (i=0;i<numChannels;i++) {
        channel =       (uint16_T)mxGetPr(CHANNEL_ARG)[i];
        coupling=       (uint16_T)mxGetPr(COUPLING_ARG)[i];
        range   =       (uint16_T)mxGetPr(RANGE_ARG)[i];
        gain    =       (uint16_T)mxGetPr(GAIN_ARG)[i];
        output=0x0000;
        output|= channel;
        output|= gain << 4;
        switch (coupling) {
          case 0: output|= 0x0000; break;
          case 1: output|= 0x0080; break;
          case 2: output|= 0x0400; break;
        }
        output|= range << 8;
        rl32eOutpW(LAS0+0x02,output);
    }

    // reset channel gain table
    rl32eOutpW(LAS0+0x00,0x030e);
    rl32eOutpW(LAS0+0x02,0x0000);


    // enable A/D channel gain table
    rl32eOutpW(LAS0+0x00,0x0303);
    rl32eOutpW(LAS0+0x02,0x0001);

    // programm burst counter (counter 2, mode 2): 500kHz
    rl32eOutpB(LAS2+0x03,0xb4);
    rl32eOutpB(LAS2+0x02,0x10);
    rl32eOutpB(LAS2+0x02,0x00);


#endif

}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE


    uint16_T    LAS0= (uint16_T)ssGetIWorkValue(S, LAS0_I_IND);
    uint16_T        LAS1= (uint16_T)ssGetIWorkValue(S, LAS1_I_IND);
    uint16_T        LAS2= (uint16_T)ssGetIWorkValue(S, LAS2_I_IND);
    int16_T         rawValue, i;
    real_T          *y, resolution, gain;

    // initiate burst scan
    rl32eOutpW(LAS0+0x08,0x0000);
    for (i=0; i<mxGetN(CHANNEL_ARG); i++) {
        y=ssGetOutputPortSignal(S,i);
        if (((uint16_T)mxGetPr(RANGE_ARG)[i])==1) {
            resolution=RES20V;
        } else {
            resolution=RES10V;
        }
        gain= (real_T)(1 << ((uint16_T)mxGetPr(GAIN_ARG)[i]));
        // wait until FIFO is not empty
        while (!(rl32eInpW(LAS0+0x08) & 0x0100));
        // read and otput value
        rawValue=rl32eInpW(LAS1+0x00);
        y[0]=resolution/gain*(real_T)(rawValue>>3);

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
