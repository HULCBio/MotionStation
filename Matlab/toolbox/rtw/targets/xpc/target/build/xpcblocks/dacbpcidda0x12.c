/* $Revision: 1.12 $ $Date: 2002/03/25 04:05:37 $ */
/* dacbpcidda0x12.c - xPC Target, non-inlined S-function driver for D/A section of CB PCI-DDA0x/12 and /16 series boards  */
/* Copyright 1996-2002 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         dacbpcidda0x12

#include        <stddef.h>
#include        <stdlib.h>

#include        "tmwtypes.h"
#include        "simstruc.h"

#ifdef MATLAB_MEX_FILE
#include        "mex.h"
#else
#include        <windows.h>
#include        "io_xpcimport.h"
#include        "pci_xpcimport.h"
#include        "util_xpcimport.h"
#include        "time_xpcimport.h"
static void     cal_da(unsigned int base_dac, int channel, int range);
#endif


/* Input Arguments */
#define NUMBER_OF_ARGS                  (7)
#define CHANNEL_ARG                     ssGetSFcnParam(S,0)
#define RANGE_ARG                       ssGetSFcnParam(S,1)
#define RESET_ARG                       ssGetSFcnParam(S,2)
#define INIT_VAL_ARG                    ssGetSFcnParam(S,3)
#define SAMP_TIME_ARG                   ssGetSFcnParam(S,4)
#define PCI_DEV_ARG                     ssGetSFcnParam(S,5)
#define DEV_ID_ARG                      ssGetSFcnParam(S,6)

#define SAMP_TIME_IND                   (0)

#define NO_I_WORKS                      (4)
#define CHANNEL_I_IND                   (0)
#define RANGE_I_IND                     (1)
#define BASE_ADDR_I_IND                 (2)
#define RES_I_IND                       (3)

#define NO_R_WORKS                      (16)

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{

    int_T num_channels, i;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "pci_xpcimport.c"
#include "util_xpcimport.c"
#include "time_xpcimport.c"
#endif

    num_channels=mxGetN(CHANNEL_ARG);

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

    uint_T base_status, base_dac, base_pci;
    int_T num_channels;
    real_T *RWork=ssGetRWork(S);
    int_T i, range, counts, channel;
    real_T value;
    uint_T range1, range_reg;
    int_T resolution_f;
    int_T resolution_i;

    PCIDeviceInfo pciinfo;
    char devName[20];
    int  devId;

    num_channels=(int_T)mxGetN(CHANNEL_ARG);
    ssSetIWorkValue(S,CHANNEL_I_IND , num_channels);

    switch ((int_T)mxGetPr(DEV_ID_ARG)[0]) {
      case 1:
        strcpy(devName,"CB PCI-DDA02/12");
        devId=0x20;
        resolution_f = 4096.0;
        resolution_i = 4095;
        break;
      case 2:
        strcpy(devName,"CB PCI-DDA04/12");
        devId=0x21;
        resolution_f = 4096.0;
        resolution_i = 4095;
        break;
      case 3:
        strcpy(devName,"CB PCI-DDA08/12");
        devId=0x22;
        resolution_f = 4096.0;
        resolution_i = 4095;
        break;
      case 4:
        strcpy(devName,"CB PCI-DDA02/16");
        devId=0x23;
        resolution_f = 65536.0;
        resolution_i = 65535;
        break;
      case 5:
        strcpy(devName,"CB PCI-DDA04/16");
        devId=0x24;
        resolution_f = 65536.0;
        resolution_i = 65535;
        break;
      case 6:
        strcpy(devName,"CB PCI-DDA08/16");
        devId=0x25;
        resolution_f = 65536.0;
        resolution_i = 65535;
        break;
      case 7:
        strcpy(devName,"CB PCIM-DDA06/16");
        devId=0x53;
        resolution_f = 65536.0;
        resolution_i = 65535;
        break;
      case 8:
        strcpy(devName,"CB PCIM-DAS1602/16");
        devId=0x56;
        resolution_f = 4096.0;
        resolution_i = 4095;
        break;

    }

    ssSetIWorkValue(S, RES_I_IND, resolution_i);

    if ((int_T)mxGetPr(PCI_DEV_ARG)[0]<0) {
        // look for the PCI-Device
        if (rl32eGetPCIInfo((unsigned short)0x1307,(unsigned short)devId,&pciinfo)) {
            sprintf(msg,"%s: board not present", devName);
            ssSetErrorStatus(S,msg);
            return;
        }
    } else {
        int_T bus, slot;
        if (mxGetN(PCI_DEV_ARG) == 1) {
            bus = 0;
            slot = (int_T)mxGetPr(PCI_DEV_ARG)[0];
        } else {
            bus = (int_T)mxGetPr(PCI_DEV_ARG)[0];
            slot = (int_T)mxGetPr(PCI_DEV_ARG)[1];
        }
        // look for the PCI-Device
        if (rl32eGetPCIInfoAtSlot((unsigned short)0x1307,(unsigned short)devId, (slot & 0xff) | ((bus & 0xff)<< 8), &pciinfo)) {
            sprintf(msg,"%s (bus %d, slot %d): board not present", devName, bus, slot );
            ssSetErrorStatus(S,msg);
            return;
        }
    }

    // show Device Information
    // rl32eShowPCIInfo(pciinfo);
    if ((int_T)mxGetPr(DEV_ID_ARG)[0]!=8) {
        base_dac=pciinfo.BaseAddress[3];
    } else {
        base_dac=pciinfo.BaseAddress[2];
    }
    ssSetIWorkValue(S, BASE_ADDR_I_IND, base_dac);

    /* process channel and range arguments */

    for (i=0; i<num_channels; i++) {
        channel=(int_T)mxGetPr(CHANNEL_ARG)[i]-1;
        range=(int_T)(10.0*mxGetPr(RANGE_ARG)[i]);
        if (range==-100){ // Bip 10V
            RWork[i*2]=20.0/resolution_f;
            RWork[i*2+1]=10.0;
            range1=0x3;
        } else if (range==-50) { // Bip 5V
            RWork[i*2]=10.0/resolution_f;
            RWork[i*2+1]=5.0;
            range1=0x2;
        } else if (range==-25) { // Bip 2.5V
            RWork[i*2]=5.0/resolution_f;
            RWork[i*2+1]=2.5;
            range1=0x0;
        } else if (range==100) { // Uni 10V
            RWork[i*2]=10.0/resolution_f;
            RWork[i*2+1]=0.0;
            range1=0x7;
        } else if (range==50) { // Uni 5V
            RWork[i*2]=5.0/resolution_f;
            RWork[i*2+1]=0.0;
            range1=0x6;
        } else if (range==25) { // Uni 2.5V
            RWork[i*2]=2.5/resolution_f;
            RWork[i*2+1]=0.0;
            range1=0x4;
        }

        if ((int_T)mxGetPr(DEV_ID_ARG)[0]<7) {
            // calibrate DAC according to channel and range
            cal_da(base_dac, channel, range1);
            // enabling simultaneous update, DAC's and set range
            rl32eOutpW((unsigned short)(base_dac+0x0), (unsigned short)((range1<<6) | (channel<<2) | 0x3));
        }
    }

#endif


}


static void mdlOutputs(SimStruct *S, int_T tid)
{
    uint_T      base_dac = ssGetIWorkValue(S, BASE_ADDR_I_IND);
    int_T       num_channels = ssGetIWorkValue(S, CHANNEL_I_IND);
    int_T       i;
    real_T      *RWork=ssGetRWork(S);
    int_T       resolution = ssGetIWorkValue(S, RES_I_IND);
    int_T       counts, channel;
    real_T      value;
    InputRealPtrsType uPtrs;

#ifndef MATLAB_MEX_FILE
    for (i=0;i<num_channels;i++) {
        channel=(int_T)(mxGetPr(CHANNEL_ARG)[i])-1;
        uPtrs=ssGetInputPortRealSignalPtrs(S,i);
        //printf("%f\n",value);
        value=*uPtrs[0];
        counts=(value+RWork[i*2+1])/RWork[i*2];
        if (counts>resolution)  counts=resolution;
        if (counts<0)           counts=0;
        switch ((int_T)mxGetPr(DEV_ID_ARG)[0]) {
          case 1:
          case 2:
          case 3:
          case 4:
          case 5:
          case 6:
            rl32eOutpW((unsigned short)(base_dac+0x08+2*channel),(unsigned short)counts);
            break;
          case 7:
            //rl32eOutpW((unsigned short)(base_dac+2*channel),(unsigned short)counts);
            rl32eOutpB((unsigned short)(base_dac+2*channel),(unsigned short)(counts & 0xff));
            rl32eOutpB((unsigned short)(base_dac+2*channel+1),(unsigned short)((counts>>8) & 0xff));
            break;
          case 8:
            rl32eOutpW((unsigned short)(base_dac+0x02+2*channel),(unsigned short)counts);
            break;
        }

    }

    // initiate simultaneous update of all DAC's
    if ((int_T)mxGetPr(DEV_ID_ARG)[0]!=8) {
        rl32eInpB((unsigned short)(base_dac+0x0));
    }

#endif

}

static void mdlTerminate(SimStruct *S)
{
    uint_T      base_dac = ssGetIWorkValue(S, BASE_ADDR_I_IND);
    int_T       nChannels = ssGetIWorkValue(S, CHANNEL_I_IND);
    real_T      *RWork=ssGetRWork(S);
    int_T       counts, i, channel;
    real_T      value;
    int_T   resolution = ssGetIWorkValue(S, RES_I_IND);;

#ifndef MATLAB_MEX_FILE

    // At load time, set channels to their initial values.
    // At model termination, reset resettable channels to their initial values.

    for (i=0;i<nChannels;i++) {
        if (xpceIsModelInit() || (uint_T)mxGetPr(RESET_ARG)[i]) {
            channel=(int_T)(mxGetPr(CHANNEL_ARG)[i])-1;
            value=(real_T)mxGetPr(INIT_VAL_ARG)[i];
            counts=(value+RWork[i*2+1])/RWork[i*2];
            if (counts>resolution)  counts=resolution;
            if (counts<0)           counts=0;
            switch ((int_T)mxGetPr(DEV_ID_ARG)[0]) {
              case 1:
              case 2:
              case 3:
              case 4:
              case 5:
              case 6:
                rl32eOutpW((unsigned short)(base_dac+0x08+2*channel),(unsigned short)counts);
                break;
              case 7:
                rl32eOutpB((unsigned short)(base_dac+2*channel),(unsigned short)(counts & 0xff));
                rl32eOutpB((unsigned short)(base_dac+2*channel+1),(unsigned short)((counts>>8) & 0xff));
                break;
              case 8:
                rl32eOutpW((unsigned short)(base_dac+0x02+2*channel),(unsigned short)counts);
                break;
            }
        }
    }

    // initiate simultaneous update of all DAC's
    if ((int_T)mxGetPr(DEV_ID_ARG)[0]!=8) {
        rl32eInpB((unsigned short)(base_dac+0x0));
    }

#endif

}

#ifndef MATLAB_MEX_FILE


static unsigned short getnvramvalue(unsigned int base_dac, unsigned int address)
{
    unsigned short caldat;
    int i;

    double waitt=0.00001;

    // select the EEPROM
    rl32eOutpW((unsigned short)(base_dac+0x6),0x7f);
    rl32eWaitDouble(waitt);

    //write init pattern
    rl32eOutpW((unsigned short)(base_dac+0x4),0x01);
    rl32eWaitDouble(waitt);
    rl32eOutpW((unsigned short)(base_dac+0x4),0x01);
    rl32eWaitDouble(waitt);
    rl32eOutpW((unsigned short)(base_dac+0x4),0x00);
    rl32eWaitDouble(waitt);

    //write address to EEPROM
    //printf("Address: 0x%x\n",address);
    for (i=0;i<8;i++) {
        rl32eOutpW((unsigned short)(base_dac+0x4), (unsigned short)((address >> (7-i)) & 0x1));
        rl32eWaitDouble(waitt);
    }

    // read calibration data
    caldat=0;
    for (i=0;i<16;i++) {
        caldat= caldat | (((rl32eInpW((unsigned short)(base_dac+0x4)) >> 7) & 0x1) << (15-i));
        rl32eWaitDouble(waitt);
    }

    // deselect EEPROM
    rl32eOutpW((unsigned short)(base_dac+0x6),0x7e);
    rl32eWaitDouble(waitt);
    //printf("Data: 0x%x\n",caldat);


    return caldat;


}


static void cal_offset(unsigned int base_dac, int channel, unsigned short cal_data)
{

    int i,j;
    int part;
    unsigned char select, coarse, fine;

    coarse= (cal_data >> 8) & 0xff;
    fine= cal_data & 0xff;
    //coarse=127; fine=127;


    switch (channel) {
      case 0: select= 0x7a; break;
      case 1: select= 0x7a; break;
      case 2: select= 0x76; break;
      case 3: select= 0x76; break;
      case 4: select= 0x6e; break;
      case 5: select= 0x6e; break;
      case 6: select= 0x5e; break;
      case 7: select= 0x5e; break;
    }

    // coarse
    if (!(channel % 2)) {
        // A: 010
        rl32eOutpW((unsigned short)(base_dac+0x4), 0x0);rl32eOutpW((unsigned short)(base_dac+0x4), 0x1);rl32eOutpW((unsigned short)(base_dac+0x4), 0x0);
    } else {
        // A: 110
        rl32eOutpW((unsigned short)(base_dac+0x4), 0x1);rl32eOutpW((unsigned short)(base_dac+0x4), 0x1);rl32eOutpW((unsigned short)(base_dac+0x4), 0x0);
    }


    //printf("Coarse Offset: channel: %d, cal data: %d, select: %x\n",channel, coarse, select);
    // write calibration data to Trim DAC
    for (i=0;i<8;i++) {
        rl32eOutpW((unsigned short)(base_dac+0x4), (unsigned short)((coarse >> (7-i)) & 0x1));
    }
    // assert the correct LDAC
    rl32eOutpW((unsigned short)(base_dac+0x6), (unsigned short)select);
    // deassert LDAC
    rl32eOutpW((unsigned short)(base_dac+0x6), 0x7e);

    // fine
    if (!(channel % 2)) {
        // A: 011
        rl32eOutpW((unsigned short)(base_dac+0x4), 0x0);rl32eOutpW((unsigned short)(base_dac+0x4), 0x1);rl32eOutpW((unsigned short)(base_dac+0x4), 0x1);
    } else {
        // A: 111
        rl32eOutpW((unsigned short)(base_dac+0x4), 0x1);rl32eOutpW((unsigned short)(base_dac+0x4), 0x1);rl32eOutpW((unsigned short)(base_dac+0x4), 0x1);
    }
    //printf("Fine Offset: channel: %d, cal data: %d, select: %x\n",channel, fine, select);
    // write calibration data to Trim DAC
    for (i=0;i<8;i++) {
        rl32eOutpW((unsigned short)(base_dac+0x4), (unsigned short)((fine >> (7-i)) & 0x1));
    }
    // assert the correct LDAC
    rl32eOutpW((unsigned short)(base_dac+0x6), (unsigned short)select);
    // deassert LDAC
    rl32eOutpW((unsigned short)(base_dac+0x6), 0x7e);

}


static void cal_gain(unsigned int base_dac, int channel, unsigned short cal_data)
{

    int i,j;
    int part;
    unsigned char coarse, fine, select;

    coarse= (cal_data >> 8) & 0xff;
    fine= cal_data & 0xff;
    //coarse=127; fine=127;


    switch (channel) {
      case 0: select= 0x7a; break;
      case 1: select= 0x7a; break;
      case 2: select= 0x76; break;
      case 3: select= 0x76; break;
      case 4: select= 0x6e; break;
      case 5: select= 0x6e; break;
      case 6: select= 0x5e; break;
      case 7: select= 0x5e; break;
    }

    // coarse
    if (!(channel % 2)) {
        // A: 001
        rl32eOutpW((unsigned short)(base_dac+0x4), 0x0);rl32eOutpW((unsigned short)(base_dac+0x4), 0x0);rl32eOutpW((unsigned short)(base_dac+0x4), 0x1);
    } else {
        // A: 101
        rl32eOutpW((unsigned short)(base_dac+0x4), 0x1);rl32eOutpW((unsigned short)(base_dac+0x4), 0x0);rl32eOutpW((unsigned short)(base_dac+0x4), 0x1);
    }
    //printf("Coarse Gain: channel: %d, cal data: %d, select: %x\n",channel, coarse, select);
    // write calibration data to Trim DAC
    for (i=0;i<8;i++) {
        rl32eOutpW((unsigned short)(base_dac+0x4), (unsigned short)((coarse >> (7-i)) & 0x1));
    }
    // assert the correct LDAC
    rl32eOutpW((unsigned short)(base_dac+0x6), (unsigned short)select);
    // deassert LDAC
    rl32eOutpW((unsigned short)(base_dac+0x6), 0x7e);

    // fine
    if (!(channel % 2)) {
        // A: 000
        rl32eOutpW((unsigned short)(base_dac+0x4), 0x0);rl32eOutpW((unsigned short)(base_dac+0x4), 0x0);rl32eOutpW((unsigned short)(base_dac+0x4), 0x0);
    } else {
        // A: 100
        rl32eOutpW((unsigned short)(base_dac+0x4), 0x1);rl32eOutpW((unsigned short)(base_dac+0x4), 0x0);rl32eOutpW((unsigned short)(base_dac+0x4), 0x0);
    }
    //printf("Fine Gain: channel: %d, cal data: %d, select: %x\n",channel, fine, select);
    // write calibration data to Trim DAC
    for (i=0;i<8;i++) {
        rl32eOutpW((unsigned short)(base_dac+0x4), (unsigned short)((fine >> (7-i)) & 0x1));
    }
    // assert the correct LDAC
    rl32eOutpW((unsigned short)(base_dac+0x6), (unsigned short)select);
    // deassert LDAC
    rl32eOutpW((unsigned short)(base_dac+0x6), 0x7e);

}



static void     cal_da(unsigned int base_dac, int channel, int range)
{


    unsigned char nvram_address;
    unsigned char range_address;
    unsigned short offset, gain;
    unsigned char coarse_offset, fine_offset, coarse_gain, fine_gain;

    if (range==0x3) {
        range_address=0x0;
    } else if (range==0x2) {
        range_address=0x2;
    } else if (range==0x0) {
        range_address=0x4;
    } else if (range==0x7) {
        range_address=0x6;
    } else if (range==0x6) {
        range_address=0x8;
    } else if (range==0x4) {
        range_address=0xa;
    }

    // calculate NVRAM address
    nvram_address= 0x7 + channel * 0xc + range_address;

    // get calibration data
    offset= getnvramvalue(base_dac, nvram_address);
    gain= getnvramvalue(base_dac, nvram_address+0x1);

    // write calibration data to trim DAC's
    cal_offset(base_dac, channel, offset);
    cal_gain(base_dac, channel, gain);

}

#endif



#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
