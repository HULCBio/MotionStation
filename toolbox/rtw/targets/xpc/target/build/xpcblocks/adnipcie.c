/* $Revision: 1.15.4.1 $ $Date: 2004/04/08 21:01:34 $ */
/* adnipcie.c - xPC Target, non-inlined S-function driver for A/D section of NI PCI-E series boards  */
/* Copyright 1996-2003 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         adnipcie

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
#include        "xpcioni.h"
#endif



/* Input Arguments */
#define NUMBER_OF_ARGS          (6)
#define CHANNEL_ARG             ssGetSFcnParam(S,0)
#define RANGE_ARG               ssGetSFcnParam(S,1)
#define COUPLING_ARG            ssGetSFcnParam(S,2)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,3)
#define SLOT_ARG                ssGetSFcnParam(S,4)
#define DEV_ARG                 ssGetSFcnParam(S,5)

#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)

#define NO_I_WORKS              (66)
#define CHANNELS_I_IND          (0)
#define BASE_ADDR_I_IND         (1)
#define POL_I_IND               (2)


#define NO_R_WORKS              (64)
#define GAIN_R_IND              (0)

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
#endif

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
                sprintf(msg,"Wrong number of input arguments passed.\n%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

        ssSetNumOutputPorts(S, mxGetN(CHANNEL_ARG));
        for (i=0;i<mxGetN(CHANNEL_ARG);i++) {
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


        int_T nChannels;
    int_T i, channel, range, dacRange, coupling, out;
    int_T Control_Register, convDelay;

        PCIDeviceInfo pciinfo;
        void *Physical1, *Physical0;
        void *Virtual1, *Virtual0;
        volatile unsigned int *ioaddress0;
        volatile unsigned short *ioaddress;
        volatile unsigned char *ioaddress8;
        char devName[20];
        int  devId;
        double resFloat;

    nChannels = mxGetN(CHANNEL_ARG);

        switch ((int_T)mxGetPr(DEV_ARG)[0]) {
                case 1:
                        strcpy(devName,"NI PCI-6023E");
                        devId=0x2a60;
                        resFloat=4096.0;
                        convDelay=0x0040;
                        break;
                case 2:
                        strcpy(devName,"NI PCI-6024E");
                        devId=0x2a70;
                        resFloat=4096.0;
                        convDelay=0x0040;
                        break;
                case 3:
                        strcpy(devName,"NI PCI-6025E");
                        devId=0x2a80;
                        resFloat=4096.0;
                        convDelay=0x0040;
                        break;
                case 4:
                        strcpy(devName,"NI PCI-MIO-16E-1");
                        devId=0x1180;
                        resFloat=4096.0;
                        convDelay=0x000f;
                        break;
                case 5:
                        strcpy(devName,"NI PCI-MIO-16E-4");
                        devId=0x1190;
                        resFloat=4096.0;
                        convDelay=0x0027;
                        break;
                case 6:
                        strcpy(devName,"NI PXI-6070E");
                        devId=0x11b0;
                        resFloat=4096.0;
                        convDelay=0x000f;
                        break;
                case 7:
                        strcpy(devName,"NI PXI-6040E");
                        devId=0x11c0;
                        resFloat=4096.0;
                        convDelay=0x0027;
                        break;
                case 8:
                        strcpy(devName,"NI PCI-6071E");
                        devId=0x1350;
                        resFloat=4096.0;
                        convDelay=0x000f;
                        break;
                case 9:
                        strcpy(devName,"NI PCI-6052E");
                        devId=0x18b0;
                        resFloat=65536.0;
                        convDelay=0x003a;
                        break;
                case 10:
                        strcpy(devName,"NI PCI-MIO-16XE-10");
                        devId=0x1170;
                        resFloat=65536.0;
                        convDelay=0x00bc;
                        break;
                case 11:
                        strcpy(devName,"NI PCI-6031E");
                        devId=0x1330;
                        resFloat=65536.0;
                        convDelay=0x00bc;
                        break;
                case 12:
                        strcpy(devName,"NI PXI-6071E");
                        devId=0x15B0;
                        resFloat=4096.0;
                        convDelay=0x000f;
                        break;
        }


    if ((int_T)mxGetPr(SLOT_ARG)[0]<0) {
        /* look for the PCI-Device */
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
        if (rl32eGetPCIInfoAtSlot((unsigned short)0x1093,(unsigned short)devId,(slot & 0xff) | ((bus & 0xff)<< 8),&pciinfo)) {
                sprintf(msg,"%s (bus %d, slot %d): board not present",devName, bus, slot );
                        ssSetErrorStatus(S,msg);
                return;
        }
    }

    // show Device Information
    //rl32eShowPCIInfo(pciinfo);

        Physical1=(void *)pciinfo.BaseAddress[1];
    Virtual1 = rl32eGetDevicePtr(Physical1, 4096, RT_PG_USERREADWRITE);
    ioaddress=(void *)Physical1;
        ioaddress8=(void *)Physical1;
    Physical0=(void *)pciinfo.BaseAddress[0];
    Virtual0 = rl32eGetDevicePtr(Physical0, 4096, RT_PG_USERREADWRITE);
    ioaddress0=(void *) Physical0;
    ioaddress0[48]=((unsigned int)ioaddress & 0xffffff00) | 0x00000080;

    ssSetIWorkValue(S, BASE_ADDR_I_IND, (uint_T)ioaddress);
    ssSetIWorkValue(S, CHANNELS_I_IND, nChannels);


        // calibration
        switch ((int_T)mxGetPr(DEV_ARG)[0]) {
                case 1:
                        writeCALDAC(ioaddress8, 4,readEEPROM(ioaddress8, 442));
                        writeCALDAC(ioaddress8,11,readEEPROM(ioaddress8, 441));
                        writeCALDAC(ioaddress8, 1,readEEPROM(ioaddress8, 440));
                        writeCALDAC(ioaddress8, 2,readEEPROM(ioaddress8, 439));
                        break;
                case 2:
                        writeCALDAC(ioaddress8, 4,readEEPROM(ioaddress8, 430));
                        writeCALDAC(ioaddress8,11,readEEPROM(ioaddress8, 429));
                        writeCALDAC(ioaddress8, 1,readEEPROM(ioaddress8, 428));
                        writeCALDAC(ioaddress8, 2,readEEPROM(ioaddress8, 427));
                        break;
                case 3:
                        writeCALDAC(ioaddress8, 4,readEEPROM(ioaddress8, 430));
                        writeCALDAC(ioaddress8,11,readEEPROM(ioaddress8, 429));
                        writeCALDAC(ioaddress8, 1,readEEPROM(ioaddress8, 428));
                        writeCALDAC(ioaddress8, 2,readEEPROM(ioaddress8, 427));
                        break;
                case 4:
                        writeCALDAC(ioaddress8,4,readEEPROM(ioaddress8, 424));
                        writeCALDAC(ioaddress8,1,readEEPROM(ioaddress8, 423));
                        writeCALDAC(ioaddress8,3,readEEPROM(ioaddress8, 422));
                        writeCALDAC(ioaddress8,14,readEEPROM(ioaddress8, 422));
                        writeCALDAC(ioaddress8,2,readEEPROM(ioaddress8, 421));
                        break;
                case 5:
                        writeCALDAC(ioaddress8,4,readEEPROM(ioaddress8, 424));
                        writeCALDAC(ioaddress8,1,readEEPROM(ioaddress8, 423));
                        writeCALDAC(ioaddress8,3,readEEPROM(ioaddress8, 422));
                        writeCALDAC(ioaddress8,14,readEEPROM(ioaddress8, 422));
                        writeCALDAC(ioaddress8,2,readEEPROM(ioaddress8, 421));
                        break;
                case 6:
                        writeCALDAC(ioaddress8,4,readEEPROM(ioaddress8, 424));
                        writeCALDAC(ioaddress8,1,readEEPROM(ioaddress8, 423));
                        writeCALDAC(ioaddress8,3,readEEPROM(ioaddress8, 422));
                        writeCALDAC(ioaddress8,14,readEEPROM(ioaddress8, 422));
                        writeCALDAC(ioaddress8,2,readEEPROM(ioaddress8, 421));
                        break;
                case 7:
                        writeCALDAC(ioaddress8,4,readEEPROM(ioaddress8, 424));
                        writeCALDAC(ioaddress8,1,readEEPROM(ioaddress8, 423));
                        writeCALDAC(ioaddress8,3,readEEPROM(ioaddress8, 422));
                        writeCALDAC(ioaddress8,14,readEEPROM(ioaddress8, 422));
                        writeCALDAC(ioaddress8,2,readEEPROM(ioaddress8, 421));
                        break;
                case 8:
                case 12:
                        writeCALDAC(ioaddress8,4,readEEPROM(ioaddress8, 424));
                        writeCALDAC(ioaddress8,1,readEEPROM(ioaddress8, 423));
                        writeCALDAC(ioaddress8,3,readEEPROM(ioaddress8, 422));
                        writeCALDAC(ioaddress8,14,readEEPROM(ioaddress8, 422));
                        writeCALDAC(ioaddress8,2,readEEPROM(ioaddress8, 421));
                        break;
                case 9:
                        writeCALDAC(ioaddress8,0,readEEPROM(ioaddress8, 414));
                        writeCALDAC(ioaddress8,8,readEEPROM(ioaddress8, 413));
                        writeCALDAC(ioaddress8,4,readEEPROM(ioaddress8, 412));
                        writeCALDAC(ioaddress8,12,readEEPROM(ioaddress8, 411));
                        writeCALDAC(ioaddress8,2,readEEPROM(ioaddress8, 410));
                        writeCALDAC(ioaddress8,10,readEEPROM(ioaddress8, 409));
                        writeCALDAC(ioaddress8,14,readEEPROM(ioaddress8, 408));
                        writeCALDAC(ioaddress8,7,readEEPROM(ioaddress8, 407));
                        break;
        case 10:
            dacRange=(int_T)(mxGetPr(RANGE_ARG)[0]);
                        if (dacRange > 0) {
                          //Bipolar
                          writeCALDAC3(ioaddress8,(short)(readEEPROM(ioaddress8, 428)|(readEEPROM(ioaddress8, 429) << 8)));
                          writeCALDAC2(ioaddress8,2,readEEPROM(ioaddress8, 427));
                          writeCALDAC2(ioaddress8,3,readEEPROM(ioaddress8, 426));
                          writeCALDAC2(ioaddress8,0,readEEPROM(ioaddress8, 425));
                          writeCALDAC2(ioaddress8,1,readEEPROM(ioaddress8, 424));
                        } else {
              //Unipolar
                          writeCALDAC3(ioaddress8,(short)(readEEPROM(ioaddress8, 422)|(readEEPROM(ioaddress8, 423) << 8)));
                          writeCALDAC2(ioaddress8,2,readEEPROM(ioaddress8, 421));
                          writeCALDAC2(ioaddress8,3,readEEPROM(ioaddress8, 420));
                          writeCALDAC2(ioaddress8,0,readEEPROM(ioaddress8, 419));
                          writeCALDAC2(ioaddress8,1,readEEPROM(ioaddress8, 418));
                        }
                break;
                case 11:
            dacRange=(int_T)(mxGetPr(RANGE_ARG)[0]);
                        if (dacRange > 0) {
                          //Bipolar
                          writeCALDAC3(ioaddress8,(short)(readEEPROM(ioaddress8, 428)|(readEEPROM(ioaddress8, 429) << 8)));
                          writeCALDAC2(ioaddress8,2,readEEPROM(ioaddress8, 427));
                          writeCALDAC2(ioaddress8,3,readEEPROM(ioaddress8, 426));
                          writeCALDAC2(ioaddress8,0,readEEPROM(ioaddress8, 425));
                          writeCALDAC2(ioaddress8,1,readEEPROM(ioaddress8, 424));
                        } else {
              //Unipolar
                          writeCALDAC3(ioaddress8,(short)(readEEPROM(ioaddress8, 422)|(readEEPROM(ioaddress8, 423) << 8)));
                          writeCALDAC2(ioaddress8,2,readEEPROM(ioaddress8, 421));
                          writeCALDAC2(ioaddress8,3,readEEPROM(ioaddress8, 420));
                          writeCALDAC2(ioaddress8,0,readEEPROM(ioaddress8, 419));
                          writeCALDAC2(ioaddress8,1,readEEPROM(ioaddress8, 418));
                        }

                break;
        }

        DAQ_STC_Windowed_Mode_Write(ioaddress, Write_Strobe_0_Register,0x0001);
    DAQ_STC_Windowed_Mode_Write(ioaddress, Write_Strobe_1_Register,0x0001);


    for (i=0;i<nChannels;i++) {

        channel=mxGetPr(CHANNEL_ARG)[i];
                range=(int_T)(1000*mxGetPr(RANGE_ARG)[i]);
                coupling=mxGetPr(COUPLING_ARG)[i];

                out=0x0;
        out=out | (channel -1);
        if (coupling==0) out= out | (0x3<<12);
        else if (coupling==1) out= out | (0x2<<12);
                else if (coupling==2) out= out | (0x1<<12);

        // Writing to register Config_Memory_High_Register with address 18.
        Board_Write(ioaddress, Configuration_Memory_High, (unsigned short)out);


            switch ((int_T)mxGetPr(DEV_ARG)[0]) {
                  case 1:
                  case 2:
                  case 3:
                  case 4:
                  case 5:
                  case 6:
                  case 7:
                  case 8:
                  case 9:
                  case 12:
            if (range== -10000) {
              out=0x0;
              ssSetRWorkValue(S, GAIN_R_IND+i, 20.0/resFloat);
                          ssSetIWorkValue(S, POL_I_IND+i, 0);
            } else if (range==-5000) {
                            out=0x1;
                            ssSetRWorkValue(S, GAIN_R_IND+i, 10.0/resFloat);
                                ssSetIWorkValue(S, POL_I_IND+i, 0);
                    } else if (range==-2500) {
                            out=0x2;
                            ssSetRWorkValue(S, GAIN_R_IND+i, 5.0/resFloat);
                                ssSetIWorkValue(S, POL_I_IND+i, 0);
                    } else if (range==-1000) {
                            out=0x3;
                            ssSetRWorkValue(S, GAIN_R_IND+i, 2.0/resFloat);
                                ssSetIWorkValue(S, POL_I_IND+i, 0);
                    } else if (range==-500) {
                            out=0x4;
                            ssSetRWorkValue(S, GAIN_R_IND+i, 1.0/resFloat);
                                ssSetIWorkValue(S, POL_I_IND+i, 0);
                    } else if (range==-250) {
                            out=0x5;
                            ssSetRWorkValue(S, GAIN_R_IND+i, 0.5/resFloat);
                                ssSetIWorkValue(S, POL_I_IND+i, 0);
                    } else if (range==-100) {
                            out=0x6;
                            ssSetRWorkValue(S, GAIN_R_IND+i, 0.2/resFloat);
                                ssSetIWorkValue(S, POL_I_IND+i, 0);
                    } else if (range==-50) {
                            out=0x7;
                            ssSetRWorkValue(S, GAIN_R_IND+i, 0.1/resFloat);
                                ssSetIWorkValue(S, POL_I_IND+i, 0);
                    } else if (range==10000) {
                            out=0x1 | (1<<8);
                            ssSetRWorkValue(S, GAIN_R_IND+i, 10.0/resFloat);
                                ssSetIWorkValue(S, POL_I_IND+i, 1);
                    } else if (range==5000) {
                            out=0x2 | (1<<8);
                            ssSetRWorkValue(S, GAIN_R_IND+i, 5.0/resFloat);
                                ssSetIWorkValue(S, POL_I_IND+i, 1);
                    } else if (range==2000) {
                            out=0x3 | (1<<8);
                            ssSetRWorkValue(S, GAIN_R_IND+i, 2.0/resFloat);
                                ssSetIWorkValue(S, POL_I_IND+i, 1);
                    } else if (range==1000) {
                            out=0x4 | (1<<8);
                            ssSetRWorkValue(S, GAIN_R_IND+i, 1.0/resFloat);
                                ssSetIWorkValue(S, POL_I_IND+i, 1);
                    } else if (range==500) {
                            out=0x5 | (1<<8);
                            ssSetRWorkValue(S, GAIN_R_IND+i, 0.5/resFloat);
                                ssSetIWorkValue(S, POL_I_IND+i, 1);
                    } else if (range==200) {
                            out=0x6 | (1<<8);
                            ssSetRWorkValue(S, GAIN_R_IND+i, 0.2/resFloat);
                                ssSetIWorkValue(S, POL_I_IND+i, 1);
                    } else if (range==100) {
                            out=0x7 | (1<<8);
                            ssSetRWorkValue(S, GAIN_R_IND+i, 0.1/resFloat);
                                ssSetIWorkValue(S, POL_I_IND+i, 1);
                    }
                    break;
                  case 10:
          case 11:
            if (range== -10000) {
              out=0x1;
              ssSetRWorkValue(S, GAIN_R_IND+i, 20.0/resFloat);
                          ssSetIWorkValue(S, POL_I_IND+i, 0);
            } else if (range==-5000) {
                            out=0x2;
                            ssSetRWorkValue(S, GAIN_R_IND+i, 10.0/resFloat);
                                ssSetIWorkValue(S, POL_I_IND+i, 0);
                    } else if (range==-2000) {
                            out=0x3;
                            ssSetRWorkValue(S, GAIN_R_IND+i, 4.0/resFloat);
                                ssSetIWorkValue(S, POL_I_IND+i, 0);
                    } else if (range==-1000) {
                            out=0x4;
                            ssSetRWorkValue(S, GAIN_R_IND+i, 2.0/resFloat);
                                ssSetIWorkValue(S, POL_I_IND+i, 0);
                    } else if (range==-500) {
                            out=0x5;
                            ssSetRWorkValue(S, GAIN_R_IND+i, 1.0/resFloat);
                                ssSetIWorkValue(S, POL_I_IND+i, 0);
                    } else if (range==-200) {
                            out=0x6;
                            ssSetRWorkValue(S, GAIN_R_IND+i, 0.4/resFloat);
                                ssSetIWorkValue(S, POL_I_IND+i, 0);
                    } else if (range==-100) {
                            out=0x7;
                            ssSetRWorkValue(S, GAIN_R_IND+i, 0.2/resFloat);
                                ssSetIWorkValue(S, POL_I_IND+i, 0);
                    } else if (range==10000) {
                            out=0x1 | (1<<8);
                            ssSetRWorkValue(S, GAIN_R_IND+i, 10.0/resFloat);
                                ssSetIWorkValue(S, POL_I_IND+i, 1);
                    } else if (range==5000) {
                            out=0x2 | (1<<8);
                            ssSetRWorkValue(S, GAIN_R_IND+i, 5.0/resFloat);
                                ssSetIWorkValue(S, POL_I_IND+i, 1);
                    } else if (range==2000) {
                            out=0x3 | (1<<8);
                            ssSetRWorkValue(S, GAIN_R_IND+i, 2.0/resFloat);
                                ssSetIWorkValue(S, POL_I_IND+i, 1);
                    } else if (range==1000) {
                            out=0x4 | (1<<8);
                            ssSetRWorkValue(S, GAIN_R_IND+i, 1.0/resFloat);
                                ssSetIWorkValue(S, POL_I_IND+i, 1);
                    } else if (range==500) {
                            out=0x5 | (1<<8);
                            ssSetRWorkValue(S, GAIN_R_IND+i, 0.5/resFloat);
                                ssSetIWorkValue(S, POL_I_IND+i, 1);
                    } else if (range==200) {
                            out=0x6 | (1<<8);
                            ssSetRWorkValue(S, GAIN_R_IND+i, 0.2/resFloat);
                                ssSetIWorkValue(S, POL_I_IND+i, 1);
                    } else if (range==100) {
                            out=0x7 | (1<<8);
                            ssSetRWorkValue(S, GAIN_R_IND+i, 0.1/resFloat);
                                ssSetIWorkValue(S, POL_I_IND+i, 1);
                    }
                    break;
        }
                if (i==(nChannels-1)) out = out | 0x8000;

        // Writing to register Config_Memory_Low_Register with address 16.
        Board_Write(ioaddress, Configuration_Memory_Low,(unsigned short)out);

        }


        AI_MSC_Clock_Configure(ioaddress);
        AI_Clear_FIFO(ioaddress);
        AI_Reset_All(ioaddress);
        AI_Board_Personalize(ioaddress);
        AI_Initialize_Configuration_Memory_Output(ioaddress);
        AI_Board_Environmentalize(ioaddress);
        //  AI_FIFO_Request(ioaddress);
        //  AI_Hardware_Gating(ioaddress);
        AI_Trigger_Signals(ioaddress);
        //  AI_Number_of_Scans(ioaddress);
        AI_Scan_Start(ioaddress);
        AI_End_of_Scan(ioaddress);
        AI_Convert_Signal(ioaddress,convDelay);
        AI_Clear_FIFO(ioaddress);
        //  AI_Interrupt_Enable(ioaddress);
        AI_Arming(ioaddress);


#endif

}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE


    uint_T base = ssGetIWorkValue(S, BASE_ADDR_I_IND);
    int_T nChannels = ssGetIWorkValue(S, CHANNELS_I_IND);
    int_T i, res;
    double gain;
    volatile unsigned short *ioaddress;
    real_T  *y;
    int count = 0;

    ioaddress=(void *) base;

    // start single scan
    //AI_Start_The_Acquisition(ioaddress);
    //DAQ_STC_Windowed_Mode_Write(ioaddress, AI_Command_2_Register,0x0001);
    ioaddress[0]=AI_Command_2_Register;
    ioaddress[1]=0x0001;
    //DAQ_STC_Windowed_Mode_Write(ioaddress, AI_START_STOP_Select_Register,0xa9FF);
    ioaddress[0]=AI_START_STOP_Select_Register;
    ioaddress[1]=0xa9FF;
    //DAQ_STC_Windowed_Mode_Write(ioaddress, AI_START_STOP_Select_Register,0x29FF);
    ioaddress[0]=AI_START_STOP_Select_Register;
    ioaddress[1]=0x29FF;

    for (i=0;i<nChannels;i++) {
	y=ssGetOutputPortSignal(S,i);

        //DAQ_STC_Windowed_Mode_Read(ioaddress, AI_Status_1_Register)
        do {
	    ioaddress[0]=AI_Status_1_Register;
        } while (((ioaddress[1]& 0x1000) == 0x1000) && (count++ < 10000));
	if (ssGetIWorkValue(S, POL_I_IND+i)) {
	    y[0] = (uint16_T) ioaddress[ADC_FIFO_Data_Register/2] * ssGetRWorkValue(S, GAIN_R_IND+i);
	} else {
	    y[0] = (int16_T) ioaddress[ADC_FIFO_Data_Register/2] * ssGetRWorkValue(S, GAIN_R_IND+i);
	}
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
