/* $Revision: 1.17.4.1 $ $Date: 2004/04/08 21:02:01 $ */
/* danipcie.c - xPC Target, non-inlined S-function driver for D/A section of NI PCI-E series boards  */
/* Copyright 1996-2003 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         danipcie

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

#define NO_I_WORKS              (2)
#define CHANNELS_I_IND          (0)
#define BASE_ADDR_I_IND         (1)

#define NO_R_WORKS              (6)
#define GAIN_R_IND              (0)
#define MINVAL_R_IND            (2)
#define MAXVAL_R_IND            (4)


static char_T msg[256];

#ifndef         MATLAB_MEX_FILE
#include        "xpcioni.c"
#endif


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


    int_T nChannels, range;
    int_T i, channel;
    int_T Control_Register;
    short outval;

    PCIDeviceInfo pciinfo;
    void *Physical1, *Physical0;
    void *Virtual1, *Virtual0;
    volatile unsigned int *ioaddress0;
    volatile unsigned short *ioaddress;
    volatile unsigned char *ioaddress8;
    char devName[20];
    int  devId;
    double res_float;

    nChannels = mxGetN(CHANNEL_ARG);
    ssSetIWorkValue(S, CHANNELS_I_IND, nChannels);


    switch ((int_T)mxGetPr(DEV_ARG)[0]) {
      case 1:
        strcpy(devName,"NI PCI-6023E");
        devId=0x2a60;
        res_float=4096.0;
        break;
      case 2:
        strcpy(devName,"NI PCI-6024E");
        devId=0x2a70;
        res_float=4096.0;
        break;
      case 3:
        strcpy(devName,"NI PCI-6025E");
        devId=0x2a80;
        res_float=4096.0;
        break;
      case 4:
        strcpy(devName,"NI PCI-MIO-16E-1");
        devId=0x1180;
        res_float=4096.0;
        break;
      case 5:
        strcpy(devName,"NI PCI-MIO-16E-4");
        devId=0x1190;
        res_float=4096.0;
        break;
      case 6:
        strcpy(devName,"NI PXI-6070E");
        devId=0x11b0;
        res_float=4096.0;
        break;
      case 7:
        strcpy(devName,"NI PXI-6040E");
        devId=0x11c0;
        res_float=4096.0;
        break;
      case 8:
        strcpy(devName,"NI PCI-6071E");
        devId=0x1350;
        res_float=4096.0;
        break;
      case 9:
        strcpy(devName,"NI PCI-6052E");
        devId=0x18b0;
        res_float=65536.0;
        break;
      case 10:
        strcpy(devName,"NI PCI-MIO-16XE-10");
        devId=0x1170;
        res_float=65536.0;
        break;
      case 11:
        strcpy(devName,"NI PCI-6031E");
        devId=0x1330;
        res_float=65536.0;
        break;
      case 12:
        strcpy(devName,"NI PXI-6071E");
        devId=0x15B0;
        res_float=4096.0;
        break;
    }


    if ((int_T)mxGetPr(SLOT_ARG)[0]<0) {
        // look for the PCI-Device
        if (rl32eGetPCIInfo((unsigned short)0x1093,(unsigned short)devId,&pciinfo)) {
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
        if (rl32eGetPCIInfoAtSlot((unsigned short)0x1093,(unsigned short)devId, (slot & 0xff) | ((bus & 0xff)<< 8),&pciinfo)) {
            sprintf(msg,"%s (bus %d, slot %d): board not present", devName, bus, slot );
            ssSetErrorStatus(S,msg);
            return;
        }
    }

    // show Device Information
    //rl32eShowPCIInfo(pciinfo);

    //  printf("Wait for 2 seconds\n");
    //  rl32eWaitDouble(2.0);
    //  printf("time expired\n");


    Physical1=(void *)pciinfo.BaseAddress[1];
    Virtual1 = rl32eGetDevicePtr(Physical1, 4096, RT_PG_USERREADWRITE);
    ioaddress=(void *)Physical1;
    ioaddress8=(void *)Physical1;
    Physical0=(void *)pciinfo.BaseAddress[0];
    Virtual0 = rl32eGetDevicePtr(Physical0, 4096, RT_PG_USERREADWRITE);
    ioaddress0=(void *) Physical0;
    ioaddress0[48]=((unsigned int)ioaddress & 0xffffff00) | 0x00000080;
    ssSetIWorkValue(S, BASE_ADDR_I_IND, (uint_T)ioaddress);



    // calibration
    switch ((int_T)mxGetPr(DEV_ARG)[0]) {
      case 1:
        break;
      case 2:
        // calibrate both DAC's
        writeCALDAC(ioaddress8, 5,readEEPROM(ioaddress8, 426));
        writeCALDAC(ioaddress8, 7,readEEPROM(ioaddress8, 425));
        writeCALDAC(ioaddress8, 6,readEEPROM(ioaddress8, 424));
        writeCALDAC(ioaddress8, 8,readEEPROM(ioaddress8, 423));
        writeCALDAC(ioaddress8,10,readEEPROM(ioaddress8, 422));
        writeCALDAC(ioaddress8, 9,readEEPROM(ioaddress8, 421));
        break;
      case 3:
        // calibrate both DAC's
        writeCALDAC(ioaddress8, 5,readEEPROM(ioaddress8, 426));
        writeCALDAC(ioaddress8, 7,readEEPROM(ioaddress8, 425));
        writeCALDAC(ioaddress8, 6,readEEPROM(ioaddress8, 424));
        writeCALDAC(ioaddress8, 8,readEEPROM(ioaddress8, 423));
        writeCALDAC(ioaddress8,10,readEEPROM(ioaddress8, 422));
        writeCALDAC(ioaddress8, 9,readEEPROM(ioaddress8, 421));
        break;
      case 4:
        /*for (i=0;i<nChannels;i++) {
            channel=mxGetPr(CHANNEL_ARG)[i];
            range=(int_T)(mxGetPr(RANGE_ARG)[i]);
            if (range < 0) { */

                writeCALDAC(ioaddress8,5,readEEPROM(ioaddress8, 420));
                writeCALDAC(ioaddress8,7,readEEPROM(ioaddress8, 419));
                writeCALDAC(ioaddress8,13,readEEPROM(ioaddress8, 419));
                writeCALDAC(ioaddress8,6,readEEPROM(ioaddress8, 418));
                writeCALDAC(ioaddress8,8,readEEPROM(ioaddress8, 417));
                writeCALDAC(ioaddress8,10,readEEPROM(ioaddress8, 416));
                writeCALDAC(ioaddress8,9,readEEPROM(ioaddress8, 415));
        /*    } else {
                writeCALDAC(ioaddress8,5,readEEPROM(ioaddress8, 414));
                writeCALDAC(ioaddress8,7,readEEPROM(ioaddress8, 413));
                writeCALDAC(ioaddress8,6,readEEPROM(ioaddress8, 412));
                writeCALDAC(ioaddress8,8,readEEPROM(ioaddress8, 411));
                writeCALDAC(ioaddress8,10,readEEPROM(ioaddress8, 410));
                writeCALDAC(ioaddress8,9,readEEPROM(ioaddress8, 409));
           }
        } */
        break;
      case 5:
        /*for (i=0;i<nChannels;i++) {
            channel=mxGetPr(CHANNEL_ARG)[i];
            range=(int_T)(mxGetPr(RANGE_ARG)[i]);
            if (range < 0) { */
                writeCALDAC(ioaddress8,5,readEEPROM(ioaddress8, 420));
                writeCALDAC(ioaddress8,7,readEEPROM(ioaddress8, 419));
                writeCALDAC(ioaddress8,13,readEEPROM(ioaddress8, 419));
                writeCALDAC(ioaddress8,6,readEEPROM(ioaddress8, 418));
                writeCALDAC(ioaddress8,8,readEEPROM(ioaddress8, 417));
                writeCALDAC(ioaddress8,10,readEEPROM(ioaddress8, 416));
                writeCALDAC(ioaddress8,9,readEEPROM(ioaddress8, 415));
        /*    } else {
                writeCALDAC(ioaddress8,5,readEEPROM(ioaddress8, 414));
                writeCALDAC(ioaddress8,7,readEEPROM(ioaddress8, 413));
                writeCALDAC(ioaddress8,6,readEEPROM(ioaddress8, 412));
                writeCALDAC(ioaddress8,8,readEEPROM(ioaddress8, 411));
                writeCALDAC(ioaddress8,10,readEEPROM(ioaddress8, 410));
                writeCALDAC(ioaddress8,9,readEEPROM(ioaddress8, 409));
            }
        } */
        break;
      case 6:
        /* for (i=0;i<nChannels;i++) {
            channel=mxGetPr(CHANNEL_ARG)[i];
            range=(int_T)(mxGetPr(RANGE_ARG)[i]);
            if (range < 0) { */
                writeCALDAC(ioaddress8,5,readEEPROM(ioaddress8, 420));
                writeCALDAC(ioaddress8,7,readEEPROM(ioaddress8, 419));
                writeCALDAC(ioaddress8,13,readEEPROM(ioaddress8, 419));
                writeCALDAC(ioaddress8,6,readEEPROM(ioaddress8, 418));
                writeCALDAC(ioaddress8,8,readEEPROM(ioaddress8, 417));
                writeCALDAC(ioaddress8,10,readEEPROM(ioaddress8, 416));
                writeCALDAC(ioaddress8,9,readEEPROM(ioaddress8, 415));
        /*    } else {
                writeCALDAC(ioaddress8,5,readEEPROM(ioaddress8, 414));
                writeCALDAC(ioaddress8,7,readEEPROM(ioaddress8, 413));
                writeCALDAC(ioaddress8,6,readEEPROM(ioaddress8, 412));
                writeCALDAC(ioaddress8,8,readEEPROM(ioaddress8, 411));
                writeCALDAC(ioaddress8,10,readEEPROM(ioaddress8, 410));
                writeCALDAC(ioaddress8,9,readEEPROM(ioaddress8, 409));
            }
        } */
        break;
      case 7:
        /*for (i=0;i<nChannels;i++) {
            channel=mxGetPr(CHANNEL_ARG)[i];
            range=(int_T)(mxGetPr(RANGE_ARG)[i]);
            if (range < 0) { */
                writeCALDAC(ioaddress8,5,readEEPROM(ioaddress8, 420));
                writeCALDAC(ioaddress8,7,readEEPROM(ioaddress8, 419));
                writeCALDAC(ioaddress8,13,readEEPROM(ioaddress8, 419));
                writeCALDAC(ioaddress8,6,readEEPROM(ioaddress8, 418));
                writeCALDAC(ioaddress8,8,readEEPROM(ioaddress8, 417));
                writeCALDAC(ioaddress8,10,readEEPROM(ioaddress8, 416));
                writeCALDAC(ioaddress8,9,readEEPROM(ioaddress8, 415));
        /*    } else {
                writeCALDAC(ioaddress8,5,readEEPROM(ioaddress8, 414));
                writeCALDAC(ioaddress8,7,readEEPROM(ioaddress8, 413));
                writeCALDAC(ioaddress8,6,readEEPROM(ioaddress8, 412));
                writeCALDAC(ioaddress8,8,readEEPROM(ioaddress8, 411));
                writeCALDAC(ioaddress8,10,readEEPROM(ioaddress8, 410));
                writeCALDAC(ioaddress8,9,readEEPROM(ioaddress8, 409));
            }
        }*/
        break;
      case 8:
      case 12:
        /*for (i=0;i<nChannels;i++) {
            channel=mxGetPr(CHANNEL_ARG)[i];
            range=(int_T)(mxGetPr(RANGE_ARG)[i]);
            if (range < 0) { */
                writeCALDAC(ioaddress8,5,readEEPROM(ioaddress8, 420));
                writeCALDAC(ioaddress8,7,readEEPROM(ioaddress8, 419));
                writeCALDAC(ioaddress8,13,readEEPROM(ioaddress8, 419));
                writeCALDAC(ioaddress8,6,readEEPROM(ioaddress8, 418));
                writeCALDAC(ioaddress8,8,readEEPROM(ioaddress8, 417));
                writeCALDAC(ioaddress8,10,readEEPROM(ioaddress8, 416));
                writeCALDAC(ioaddress8,9,readEEPROM(ioaddress8, 415));
        /*    } else {
                writeCALDAC(ioaddress8,5,readEEPROM(ioaddress8, 414));
                writeCALDAC(ioaddress8,7,readEEPROM(ioaddress8, 413));
                writeCALDAC(ioaddress8,6,readEEPROM(ioaddress8, 412));
                writeCALDAC(ioaddress8,8,readEEPROM(ioaddress8, 411));
                writeCALDAC(ioaddress8,10,readEEPROM(ioaddress8, 410));
                writeCALDAC(ioaddress8,9,readEEPROM(ioaddress8, 409));
            }
        } */
        break;
      case 9:
        for (i=0;i<nChannels;i++) {
            channel=mxGetPr(CHANNEL_ARG)[i];
            range=(int_T)(mxGetPr(RANGE_ARG)[i]);
            if (range < 0) {
                if (channel==1) {
                    writeCALDAC1(ioaddress8,0,readEEPROM(ioaddress8, 406));
                    writeCALDAC1(ioaddress8,8,readEEPROM(ioaddress8, 405));
                    writeCALDAC1(ioaddress8,4,readEEPROM(ioaddress8, 404));
                    writeCALDAC1(ioaddress8,12,readEEPROM(ioaddress8, 403));
                } else {
                    writeCALDAC1(ioaddress8,2,readEEPROM(ioaddress8, 402));
                    writeCALDAC1(ioaddress8,10,readEEPROM(ioaddress8, 401));
                    writeCALDAC1(ioaddress8,6,readEEPROM(ioaddress8, 400));
                    writeCALDAC1(ioaddress8,14,readEEPROM(ioaddress8, 399));
                }
            } else {
                if (channel==1) {
                    writeCALDAC1(ioaddress8,0,readEEPROM(ioaddress8, 398));
                    writeCALDAC1(ioaddress8,8,readEEPROM(ioaddress8, 397));
                    writeCALDAC1(ioaddress8,4,readEEPROM(ioaddress8, 396));
                    writeCALDAC1(ioaddress8,12,readEEPROM(ioaddress8, 395));
                } else {
                    writeCALDAC1(ioaddress8,2,readEEPROM(ioaddress8, 394));
                    writeCALDAC1(ioaddress8,10,readEEPROM(ioaddress8, 3931));
                    writeCALDAC1(ioaddress8,6,readEEPROM(ioaddress8, 392));
                    writeCALDAC1(ioaddress8,14,readEEPROM(ioaddress8, 391));
                }
            }
        }
        break;
      case 10:
        for (i=0;i<nChannels;i++) {
            channel=mxGetPr(CHANNEL_ARG)[i];
            range=(int_T)(mxGetPr(RANGE_ARG)[i]);
            if (range < 0) {
                writeCALDAC2(ioaddress8,6,readEEPROM(ioaddress8, 417));
                writeCALDAC2(ioaddress8,4,readEEPROM(ioaddress8, 416));
                writeCALDAC2(ioaddress8,7,readEEPROM(ioaddress8, 415));
                writeCALDAC2(ioaddress8,5,readEEPROM(ioaddress8, 414));
            } else {
                writeCALDAC2(ioaddress8,6,readEEPROM(ioaddress8, 413));
                writeCALDAC2(ioaddress8,4,readEEPROM(ioaddress8, 413));
                writeCALDAC2(ioaddress8,7,readEEPROM(ioaddress8, 411));
                writeCALDAC2(ioaddress8,5,readEEPROM(ioaddress8, 410));
            }
        }
        break;
      case 11:
        for (i=0;i<nChannels;i++) {
            channel=mxGetPr(CHANNEL_ARG)[i];
            range=(int_T)(mxGetPr(RANGE_ARG)[i]);
            if (range < 0) {
                writeCALDAC2(ioaddress8,6,readEEPROM(ioaddress8, 417));
                writeCALDAC2(ioaddress8,4,readEEPROM(ioaddress8, 416));
                writeCALDAC2(ioaddress8,7,readEEPROM(ioaddress8, 415));
                writeCALDAC2(ioaddress8,5,readEEPROM(ioaddress8, 414));
            } else {
                writeCALDAC2(ioaddress8,6,readEEPROM(ioaddress8, 413));
                writeCALDAC2(ioaddress8,4,readEEPROM(ioaddress8, 413));
                writeCALDAC2(ioaddress8,7,readEEPROM(ioaddress8, 411));
                writeCALDAC2(ioaddress8,5,readEEPROM(ioaddress8, 410));
            }
        }
        break;
    }


    for (i=0;i<nChannels;i++) {

        channel=mxGetPr(CHANNEL_ARG)[i];
        range=(int_T)(mxGetPr(RANGE_ARG)[i]);

        switch (range) {
          case -10:
            switch (channel) {
              case 1:
                Board_Write(ioaddress, AO_Configuration_Register,0x0001);
                break;
              case 2:
                Board_Write(ioaddress, AO_Configuration_Register,0x0101);
                break;
            }
            ssSetRWorkValue(S, GAIN_R_IND+i, 20.0/res_float);
            ssSetRWorkValue(S, MINVAL_R_IND+i, -10.0);
            ssSetRWorkValue(S, MAXVAL_R_IND+i, 10.0-20.0/res_float);
            break;
          case 10:
            switch (channel) {
              case 1:
                Board_Write(ioaddress, AO_Configuration_Register,0x0000);
                break;
              case 2:
                Board_Write(ioaddress, AO_Configuration_Register,0x0100);
                break;
            }
            ssSetRWorkValue(S, GAIN_R_IND+i, 10.0/res_float);
            ssSetRWorkValue(S, MINVAL_R_IND+i, 0.0);
            ssSetRWorkValue(S, MAXVAL_R_IND+i, 10.0-10.0/res_float);
            break;
        }
    }


    AO_Reset_All(ioaddress);
    AO_Board_Personalize(ioaddress);
    AO_LDAC_Source_And_Update_Mode(ioaddress);

#endif

}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

    uint_T  base = ssGetIWorkValue(S, BASE_ADDR_I_IND);
    int_T nChannels = ssGetIWorkValue(S, CHANNELS_I_IND);
    int_T i;
    real_T output;
    int_T channel;
    short outval;
    unsigned short *ioaddress;
    InputRealPtrsType uPtrs;

    ioaddress=(void *) base;

    for (i=0;i<nChannels;i++) {
        channel=mxGetPr(CHANNEL_ARG)[i];
        uPtrs=ssGetInputPortRealSignalPtrs(S,i);
        output=*uPtrs[0];
        if (output<ssGetRWorkValue(S, MINVAL_R_IND+i)) 
            output=ssGetRWorkValue(S, MINVAL_R_IND+i);
        if (output>ssGetRWorkValue(S, MAXVAL_R_IND+i)) 
            output=ssGetRWorkValue(S, MAXVAL_R_IND+i);
        outval=(short)(output/ssGetRWorkValue(S, GAIN_R_IND+i));
        switch (channel) {
          case 1:
            Board_Write(ioaddress, AO_DAC_0_Data_Register,outval);
            break;
          case 2:
            Board_Write(ioaddress, AO_DAC_1_Data_Register,outval);
            break;
        }
    }

#endif

}


static void mdlTerminate(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE

    uint_T base = ssGetIWorkValue(S, BASE_ADDR_I_IND);
    int_T nChannels = ssGetIWorkValue(S, CHANNELS_I_IND);
    unsigned short *ioaddress;
    int_T channel, i;
    short outval;
    real_T output;

    ioaddress=(void *) base;

    outval=(short) 0;

    // At load time, set channels to their initial values.
    // At model termination, reset resettable channels to their initial values.
    for (i=0;i<nChannels;i++) {
        if (xpceIsModelInit() || (uint_T)mxGetPr(RESET_ARG)[i]) {
            channel=mxGetPr(CHANNEL_ARG)[i];
            output=mxGetPr(INIT_VAL_ARG)[i];
            if (output<ssGetRWorkValue(S, MINVAL_R_IND+i)) 
                output=ssGetRWorkValue(S, MINVAL_R_IND+i);
            if (output>ssGetRWorkValue(S, MAXVAL_R_IND+i)) 
                output=ssGetRWorkValue(S, MAXVAL_R_IND+i);
            outval=(short)(output/ssGetRWorkValue(S, GAIN_R_IND+i));
            switch (channel) {
              case 1:
                Board_Write(ioaddress, AO_DAC_0_Data_Register,outval);
                break;
              case 2:
                Board_Write(ioaddress, AO_DAC_1_Data_Register,outval);
                break;
            }
        }
    }

#endif

}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
