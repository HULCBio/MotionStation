/* $Revision: 1.10 $ $Date: 2002/03/25 04:05:23 $ */
/* dacbpcidas.c - xPC Target, non-inlined S-function driver for D/A section of CB PCI-DAS series boards  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         dacbpcidas

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
#include        "util_xpcimport.h"
#include        "xpcioni.h"
#endif



/* Input Arguments */
#define NUMBER_OF_ARGS          (7)
#define CHANNEL_ARG             ssGetSFcnParam(S,0)
#define RANGE_ARG               ssGetSFcnParam(S,1)
#define RESET_ARG               ssGetSFcnParam(S,2)
#define INIT_VAL_ARG            ssGetSFcnParam(S,3)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,4)
#define SLOT_ARG                ssGetSFcnParam(S,5)
#define DEV_ARG                 ssGetSFcnParam(S,6)

#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)

#define NO_I_WORKS              (3)
#define CHANNELS_I_IND          (0)
#define BASE_ADDR_I_IND         (1)

#define NO_R_WORKS              (8)
#define GAIN_R_IND              (0)
#define OFFSET_R_IND            (2)
#define MINVAL_R_IND            (4)
#define MAXVAL_R_IND            (6)

#define RES_FLOAT               4096.0



static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{

    int i;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "pci_xpcimport.c"
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

    for (i = 0; i < NUMBER_OF_ARGS; i++)
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


    int_T  i, channel, nChannels, range;
    int_T  control[2]={1,1};

    PCIDeviceInfo pciinfo;
    uint_T base_status, base_dac, base_pci;
    char devName[20];
    int  devId;


    nChannels = mxGetN(CHANNEL_ARG);
    ssSetIWorkValue(S, CHANNELS_I_IND, nChannels);

    switch ((int_T)mxGetPr(DEV_ARG)[0]) {
      case 1:
        strcpy(devName,"CB PCI-DAS1200");
        devId=0xf;
        break;
    }


    if ((int_T)mxGetPr(SLOT_ARG)[0]<0) {
        // look for the PCI-Device
        if (rl32eGetPCIInfo((unsigned short)0x1307,(unsigned short)devId,&pciinfo)) {
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
        if (rl32eGetPCIInfoAtSlot((unsigned short)0x1307,(unsigned short)devId, (slot & 0xff) | ((bus & 0xff)<< 8) ,&pciinfo)) {
            sprintf(msg,"%s (bus %d, slot %d): board not present",devName, bus, slot );
            ssSetErrorStatus(S,msg);
            return;
        }
    }

    // show Device Information
    //rl32eShowPCIInfo(pciinfo);

    base_pci=pciinfo.BaseAddress[0];
    base_status=pciinfo.BaseAddress[1];
    base_dac=pciinfo.BaseAddress[4];

    ssSetIWorkValue(S, BASE_ADDR_I_IND, (int_T)base_status);
    ssSetIWorkValue(S, BASE_ADDR_I_IND+1, (int_T)base_dac);

    for (i=0;i<nChannels;i++) {

        channel=mxGetPr(CHANNEL_ARG)[i];
        range=(int_T)(mxGetPr(RANGE_ARG)[i]);

        switch (range) {
          case -10:
            control[channel-1]=0x1;
            ssSetRWorkValue(S, GAIN_R_IND+i, 20.0/RES_FLOAT);
            ssSetRWorkValue(S, OFFSET_R_IND+i, 10.0);
            ssSetRWorkValue(S, MINVAL_R_IND+i, -10.0);
            ssSetRWorkValue(S, MAXVAL_R_IND+i, 10.0);
            break;
          case -5:
            control[channel-1]=0x0;
            ssSetRWorkValue(S, GAIN_R_IND+i, 10.0/RES_FLOAT);
            ssSetRWorkValue(S, OFFSET_R_IND+i, 5.0);
            ssSetRWorkValue(S, MINVAL_R_IND+i, -5.0);
            ssSetRWorkValue(S, MAXVAL_R_IND+i, 5.0);
            break;
          case 10:
            control[channel-1]=0x3;
            ssSetRWorkValue(S, GAIN_R_IND+i, 10.0/RES_FLOAT);
            ssSetRWorkValue(S, OFFSET_R_IND+i, 0.0);
            ssSetRWorkValue(S, MINVAL_R_IND+i, 0.0);
            ssSetRWorkValue(S, MAXVAL_R_IND+i, 10.0);
            break;
          case 5:
            control[channel-1]=0x2;
            ssSetRWorkValue(S, GAIN_R_IND+i, 5.0/RES_FLOAT);
            ssSetRWorkValue(S, OFFSET_R_IND+i, 0.0);
            ssSetRWorkValue(S, MINVAL_R_IND+i, 0.0);
            ssSetRWorkValue(S, MAXVAL_R_IND+i, 5.0);
            break;
        }
    }

    // set range
    rl32eOutpW((unsigned short)(base_status+0x8),  (unsigned short)(0x2 | (control[0] <<8) | (control[1] << 10) ));

    //cal_da(0, control[0], base_pci, base_status);
    //cal_da(1, control[1], base_pci, base_status);


#endif

}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

    uint_T base_dac = ssGetIWorkValue(S, BASE_ADDR_I_IND+1);
    int_T  nChannels = ssGetIWorkValue(S, CHANNELS_I_IND);
    int_T  counts, channel, i;
    real_T output;
    InputRealPtrsType uPtrs;

    for (i=0;i<nChannels;i++) {
        channel=mxGetPr(CHANNEL_ARG)[i];
        uPtrs=ssGetInputPortRealSignalPtrs(S,i);
        output=*uPtrs[0];
        if (output<ssGetRWorkValue(S, MINVAL_R_IND+i)) output=ssGetRWorkValue(S, MINVAL_R_IND+i);
        if (output>ssGetRWorkValue(S, MAXVAL_R_IND+i)) output=ssGetRWorkValue(S, MAXVAL_R_IND+i);
        counts=(output+ssGetRWorkValue(S, OFFSET_R_IND+i))/ssGetRWorkValue(S, GAIN_R_IND+i);
        switch (channel) {
          case 1:
            rl32eOutpW((unsigned short)(base_dac+0x0), (unsigned short)counts);
            break;
          case 2:
            rl32eOutpW((unsigned short)(base_dac+0x2), (unsigned short)counts);
            break;
        }
    }

#endif

}


static void mdlTerminate(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE

    uint_T base_dac = ssGetIWorkValue(S, BASE_ADDR_I_IND+1);
    int_T  nChannels = ssGetIWorkValue(S, CHANNELS_I_IND);
    real_T *RWork=ssGetRWork(S);
    int_T  counts, channel, i;
    real_T output;

    // At load time, set channels to their initial values.
    // At model termination, reset resettable channels to their initial values.
    for (i=0;i<nChannels;i++) {
        if (xpceIsModelInit() || (uint_T)mxGetPr(RESET_ARG)[i]) {
            channel=mxGetPr(CHANNEL_ARG)[i];
            output=mxGetPr(INIT_VAL_ARG)[i];
            if (output<ssGetRWorkValue(S, MINVAL_R_IND+i)) output=ssGetRWorkValue(S, MINVAL_R_IND+i);
            if (output>ssGetRWorkValue(S, MAXVAL_R_IND+i)) output=ssGetRWorkValue(S, MAXVAL_R_IND+i);
            counts=(output+ssGetRWorkValue(S, OFFSET_R_IND+i))/ssGetRWorkValue(S, GAIN_R_IND+i);
            switch (channel) {
              case 1:
                rl32eOutpW((unsigned short)(base_dac+0x0), (unsigned short)counts);
                break;
              case 2:
                rl32eOutpW((unsigned short)(base_dac+0x2), (unsigned short)counts);
                break;
            }
        }
    }

#endif

}

#ifndef MATLAB_MEX_FILE

static unsigned char getnvramvalue(unsigned int base_pci, unsigned int offset)
{
    unsigned char caldat;

    while ( (rl32eInpB((unsigned short)(base_pci+0x3f)) & 0x80)!=0x00);

    rl32eOutpB((unsigned short)(base_pci+0x3f),0x80);
    rl32eOutpB((unsigned short)(base_pci+0x3e),offset);

    rl32eOutpB((unsigned short)(base_pci+0x3f),0xa0);
    rl32eOutpB((unsigned short)(base_pci+0x3e),0x00);

    rl32eOutpB((unsigned short)(base_pci+0x3f),0xe0);
    while ( (rl32eInpB((unsigned short)(base_pci+0x3f)) & 0x80)!=0x00);

    caldat=rl32eInpB((unsigned short)(base_pci+0x3e));
    return caldat;

}

static void set_gainc0(unsigned int base_status, unsigned char caldat)
{

    int i,j;

    // address =0x1;
    rl32eOutpW(base_status+0x6,0x4000 | 0x0000);
    rl32eOutpW(base_status+0x6,0x4000 | 0x0000);
    rl32eOutpW(base_status+0x6,0x4000 | 0x8000);
    for (i=0;i<8;i++) {
        j=7-i;
        if ( ((caldat & (1<<j)) >> j) == 0x1) {
            rl32eOutpW((unsigned short)(base_status+0x6),(unsigned short)(0x4000 | 0x8000));
        } else {
            rl32eOutpW((unsigned short)(base_status+0x6),(unsigned short)(0x4000 | 0x0000));
        }
    }
    rl32eOutpW((unsigned short)(base_status+0x6),0x4100);
    rl32eOutpW((unsigned short)(base_status+0x6),0x4000);

    rl32eOutpW((unsigned short)(base_status+0x6),0x0000);



}

static void set_gainc1(unsigned int base_status, unsigned char caldat)
{

    int i,j;

    // address =0x5;
    rl32eOutpW((unsigned short)(base_status+0x6),(unsigned short)(0x4000 | 0x8000));
    rl32eOutpW((unsigned short)(base_status+0x6),(unsigned short)(0x4000 | 0x0000));
    rl32eOutpW((unsigned short)(base_status+0x6),(unsigned short)(0x4000 | 0x8000));
    for (i=0;i<8;i++) {
        j=7-i;
        if ( ((caldat & (1<<j)) >> j) == 0x1) {
            rl32eOutpW((unsigned short)(base_status+0x6),(unsigned short)(0x4000 | 0x8000));
        } else {
            rl32eOutpW((unsigned short)(base_status+0x6),(unsigned short)(0x4000 | 0x0000));
        }
    }
    rl32eOutpW((unsigned short)(base_status+0x6),0x4100);
    rl32eOutpW((unsigned short)(base_status+0x6),0x4000);

    rl32eOutpW((unsigned short)(base_status+0x6),0x0000);



}


static void set_offset0(unsigned int base_status, unsigned char caldat)
{

    int i,j;

    // address =0x2;
    rl32eOutpW((unsigned short)(base_status+0x6),(unsigned short)(0x4000 | 0x0000));
    rl32eOutpW((unsigned short)(base_status+0x6),(unsigned short)(0x4000 | 0x8000));
    rl32eOutpW((unsigned short)(base_status+0x6),(unsigned short)(0x4000 | 0x0000));
    for (i=0;i<8;i++) {
        j=7-i;
        if ( ((caldat & (1<<j)) >> j) == 0x1) {
            rl32eOutpW((unsigned short)(base_status+0x6),(unsigned short)(0x4000 | 0x8000));
        } else {
            rl32eOutpW((unsigned short)(base_status+0x6),(unsigned short)(0x4000 | 0x0000));
        }
    }
    rl32eOutpW((unsigned short)(base_status+0x6),0x4100);
    rl32eOutpW((unsigned short)(base_status+0x6),0x4000);

    rl32eOutpW((unsigned short)(base_status+0x6),0x0000);

}

static void set_offset1(unsigned int base_status, unsigned char caldat)
{

    int i,j;

    // address =0x3;
    rl32eOutpW((unsigned short)(base_status+0x6),(unsigned short)(0x4000 | 0x0000));
    rl32eOutpW((unsigned short)(base_status+0x6),(unsigned short)(0x4000 | 0x8000));
    rl32eOutpW((unsigned short)(base_status+0x6),(unsigned short)(0x4000 | 0x8000));
    for (i=0;i<8;i++) {
        j=7-i;
        if ( ((caldat & (1<<j)) >> j) == 0x1) {
            rl32eOutpW((unsigned short)(base_status+0x6),(unsigned short)(0x4000 | 0x8000));
        } else {
            rl32eOutpW((unsigned short)(base_status+0x6),(unsigned short)(0x4000 | 0x0000));
        }
    }
    rl32eOutpW((unsigned short)(base_status+0x6),0x4100);
    rl32eOutpW((unsigned short)(base_status+0x6),0x4000);

    rl32eOutpW((unsigned short)(base_status+0x6),0x0000);

}


static void set_gainf0(unsigned int base_status, unsigned char caldat)
{

    int i,j;

    // address =0x0;
    rl32eOutpW(base_status+0x6,0x4000 | 0x0000);
    rl32eOutpW(base_status+0x6,0x4000 | 0x0000);
    rl32eOutpW(base_status+0x6,0x4000 | 0x0000);
    for (i=0;i<8;i++) {
        j=7-i;
        if ( ((caldat & (1<<j)) >> j) == 0x1) {
            rl32eOutpW((unsigned short)(base_status+0x6),(unsigned short)(0x4000 | 0x8000));
        } else {
            rl32eOutpW((unsigned short)(base_status+0x6),(unsigned short)(0x4000 | 0x0000));
        }
    }
    rl32eOutpW((unsigned short)(base_status+0x6),0x4100);
    rl32eOutpW((unsigned short)(base_status+0x6),0x4000);

    rl32eOutpW((unsigned short)(base_status+0x6),0x0000);



}

static void set_gainf1(unsigned int base_status, unsigned char caldat)
{

    int i,j;

    // address =0x4;
    rl32eOutpW(base_status+0x6,0x4000 | 0x8000);
    rl32eOutpW(base_status+0x6,0x4000 | 0x0000);
    rl32eOutpW(base_status+0x6,0x4000 | 0x0000);
    for (i=0;i<8;i++) {
        j=7-i;
        if ( ((caldat & (1<<j)) >> j) == 0x1) {
            rl32eOutpW((unsigned short)(base_status+0x6),(unsigned short)(0x4000 | 0x8000));
        } else {
            rl32eOutpW((unsigned short)(base_status+0x6),(unsigned short)(0x4000 | 0x0000));
        }
    }
    rl32eOutpW((unsigned short)(base_status+0x6),0x4100);
    rl32eOutpW((unsigned short)(base_status+0x6),0x4000);

    rl32eOutpW((unsigned short)(base_status+0x6),0x0000);



}


static void     cal_da(int channel, int range,unsigned int base_pci, unsigned int base_status)
{

    unsigned char gainc, offset, gainf, caldat;

    if (channel==0) {

        gainc   =0xdc+(range)*4+0;
        offset  =0xdc+(range)*4+1;
        gainf   =0xdc+(range)*4+2;
        //printf("gainc: %x, offset: %x, gainf: %x\n",gainc, offset, gainf);

        //rl32eOutpW((unsigned short)(base_status+0x6),0x4000);
        caldat=getnvramvalue(base_pci, gainc);
        //printf("gainc: %x\n",caldat);
        set_gainc0(base_status, caldat);

        //rl32eOutpW((unsigned short)(base_status+0x6),0x4000);
        caldat=getnvramvalue(base_pci, offset);
        //printf("offset: %x\n",caldat);
        set_offset0(base_status,caldat);

        //rl32eOutpW((unsigned short)(base_status+0x6),0x4000);
        caldat=getnvramvalue(base_pci, gainf);
        //printf("gainf: %x\n",caldat);
        set_gainf0(base_status, caldat);


    } else if (channel==1) {

        gainc   =0xec+(range)*4+0;
        offset  =0xec+(range)*4+1;
        gainf   =0xec+(range)*4+2;
        printf("gainc: %x, offset: %x, gainf: %x\n",gainc, offset, gainf);

        //rl32eOutpW((unsigned short)(base_status+0x6),0x4000);
        caldat=getnvramvalue(base_pci, gainc);
        printf("gainc: %x\n",caldat);
        set_gainc1(base_status, caldat);

        //rl32eOutpW((unsigned short)(base_status+0x6),0x4000);
        caldat=getnvramvalue(base_pci, offset);
        printf("offset: %x\n",caldat);
        set_offset1(base_status,caldat);

        //rl32eOutpW((unsigned short)(base_status+0x6),0x4000);
        caldat=getnvramvalue(base_pci, gainf);
        printf("gainf: %x\n",caldat);
        set_gainf1(base_status, caldat);

    }

}

#endif


#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
