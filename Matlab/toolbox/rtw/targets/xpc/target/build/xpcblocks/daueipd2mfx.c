/* $Revision: 1.6.6.1 $ $Date: 2003/12/01 04:25:40 $ */
/* daueipd2mfx - xPC Target, non-inlined S-function driver for */
/* D/A section of UEI series boards  */
/* Copyright 1996-2003 The MathWorks, Inc. */

#define 		XPC 1

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         daueipd2mfx

#include        <stddef.h>
#include        <stdlib.h>
#include        <math.h>

#include        "simstruc.h"

#ifdef          MATLAB_MEX_FILE
#include        "mex.h"				   
#endif



#ifndef         MATLAB_MEX_FILE
#include        <windows.h>
#include        "io_xpcimport.h"
#include        "pci_xpcimport.h"
#include        "util_xpcimport.h"
#include 		"ioext_xpcimport.h"
#endif									  

/* Input Arguments */
#define NUMBER_OF_ARGS          (8)
#define CHANNEL_ARG             ssGetSFcnParam(S,0)
#define RESET_ARG             	ssGetSFcnParam(S,1)
#define INIT_VAL_ARG            ssGetSFcnParam(S,2)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,3)
#define SLOT_ARG                ssGetSFcnParam(S,4)
#define DEV_ARG                 ssGetSFcnParam(S,5)
#define BOARD_ARG               ssGetSFcnParam(S,6)
#define DEVNAME_ARG             ssGetSFcnParam(S,7)


#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)

#define NO_I_WORKS              (2)
#define CHANNELS_I_IND          (0)
#define BOARD_I_IND          	(1)

#define NO_R_WORKS              (0)

static char_T msg[256];

static first=1;

#ifndef MATLAB_MEX_FILE
#define AOB_AOUT32      (1L<<14)
#define AOB_REGENERATE  (1L<<13)
#define AOB_CVSTART0    (1L<<0)
//#include "xpcuei.c"
//#include "pdfw_lib.c"
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

    ssSetSFcnParamNotTunable(S,0);
    ssSetSFcnParamNotTunable(S,1);
    ssSetSFcnParamNotTunable(S,2);
    ssSetSFcnParamNotTunable(S,3);

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
    int_T i, channel;
    real_T output;
    uint32_T out, count;
    char devName[50];
    int  subDevId = mxGetPr(DEV_ARG)[0];
    int_T bus, slot;
    void *Physical0;
    void *Virtual0;
    PCIDeviceInfo pciinfo;
    int_T board;


    nChannels = mxGetN(CHANNEL_ARG);
    ssSetIWorkValue(S, CHANNELS_I_IND, nChannels);

    mxGetString(DEVNAME_ARG,devName, mxGetN(DEVNAME_ARG));

    if ((int_T)mxGetPr(SLOT_ARG)[0]<0)
    {
        /* look for the PCI-Device */
        if (rl32eGetPCIInfoExt((unsigned short)0x1057,
                               (unsigned short)0x1801,
                               (unsigned short)0x54A9,
                               (unsigned short)subDevId,
                               &pciinfo))
        {
            sprintf(msg,"%s: board not present", devName);
            ssSetErrorStatus(S,msg);
            return;
        }
    } else {
        int_T bus, slot;
        if (mxGetN(SLOT_ARG) == 1)
        {
            bus = 0;
            slot = (int_T)mxGetPr(SLOT_ARG)[0];
        } else {
            bus = (int_T)mxGetPr(SLOT_ARG)[0];
            slot = (int_T)mxGetPr(SLOT_ARG)[1];
        }
        // look for the PCI-Device
        if (rl32eGetPCIInfoAtSlotExt((unsigned short)0x1057,
                                     (unsigned short)0x1801,
                                     (unsigned short)0x54A9,
                                     (unsigned short)subDevId,
                                     (slot & 0xff) | ((bus & 0xff)<< 8),
                                     &pciinfo))
        {
            sprintf(msg,"%s (bus %d, slot %d): board not present",devName, bus, slot );
            ssSetErrorStatus(S,msg);
            return;
        }
    }

    Physical0=(void *)pciinfo.BaseAddress[0];
    Virtual0 = rl32eGetDevicePtr(Physical0, 0x8000, RT_PG_USERREADWRITE);

    board = pd_xpc_assign_device( subDevId,
                                  pciinfo.BaseAddress[0],
                                  pciinfo.InterruptLine);	
    ssSetIWorkValue(S, BOARD_I_IND, board);

    if( board < 0 )
    {
        switch( board )
        {
        case -2:  // This should never happen, it indicates an inconsistancy
            sprintf(msg,"%s : Different subdevice ID for board at same address",devName );
            break;
        case -3:
            sprintf(msg,"%s : Too many UEI devices",devName );
            break;
        case -4:
            sprintf(msg,"%s : Error downloading firmware to the board",devName );
            break;
        }
        ssSetErrorStatus(S,msg);
        return;
    }

    if (!pd_aout_reset(board))
    {
        sprintf(msg, "%s : Error in pd_aout_reset\n", devName );
        ssSetErrorStatus(S,msg);
        return;
    }

#endif

}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

    int_T nChannels = ssGetIWorkValue(S, CHANNELS_I_IND);
    int_T board = ssGetIWorkValue(S, BOARD_I_IND);
    int_T i;
    real_T time;
    int_T channel;
    InputRealPtrsType uPtrs;
    uint32_T out, count;
    int32_T output;

    out= 0x7ff7ff;
    for (i=0;i<nChannels;i++) {
        channel=(uint_T)mxGetPr(CHANNEL_ARG)[i]-1;
        uPtrs=ssGetInputPortRealSignalPtrs(S,i);
        output=((*uPtrs[0]+10.0)/0.0048828125);
        if (output>4095){
            output=4095;
        }
        if (output<0){
            output=0;
        }

        if (channel==0) {
            out = (out & 0xfff000) | ((uint16_T)output & 0xfff);
        } else {
            out = (out & 0x000fff) | (((uint16_T)output & 0xfff) << 12);
        }
    }
    pd_aout_put_value(board, out);

#endif

}


static void mdlTerminate(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE

    int_T nChannels = ssGetIWorkValue(S, CHANNELS_I_IND);
    int_T board = ssGetIWorkValue(S, BOARD_I_IND);
    int_T i, channel;
    uint32_T out, count;
    int32_T output;

    if (!xpceIsModelInit()) {
        if ((int_T)mxGetPr(RESET_ARG)[0]==0) {
            return;
        }
    }
    out= 0x7ff7ff;
    for (i=0;i<nChannels;i++) {
        channel=(uint_T)mxGetPr(CHANNEL_ARG)[i]-1;
        output=((mxGetPr(INIT_VAL_ARG)[i]+10.0)/0.0048828125);

        if (output>4095){
            output=4095;
        }
        if (output<0){
            output=0;
        }

        if (channel==0) {
            out = (out & 0xfff000) | ((uint16_T)output & 0xfff);
        } else {
            out = (out & 0x000fff) | (((uint16_T)output & 0xfff) << 12);
        }
    }
    pd_aout_put_value(board, out);

#endif

}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
