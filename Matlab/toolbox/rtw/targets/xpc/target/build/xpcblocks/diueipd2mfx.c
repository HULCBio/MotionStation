/* $Revision: 1.4.4.1 $ $Date: 2003/12/01 04:25:41 $ */
/* diueipd2mfx.c - xPC Target, non-inlined S-function driver for D/I section of UEI series boards  */
/* Copyright 1996-2003 The MathWorks, Inc. */

#define 		XPC 1

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         diueipd2mfx

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
#include        "time_xpcimport.h"
#include 		"ioext_xpcimport.h"
#endif									  

/* Input Arguments */
#define NUMBER_OF_ARGS          (6)
#define CHANNEL_ARG             ssGetSFcnParam(S,0)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,1)
#define SLOT_ARG                ssGetSFcnParam(S,2)
#define DEV_ARG                 ssGetSFcnParam(S,3)
#define BOARD_ARG             	ssGetSFcnParam(S,4)
#define DEVNAME_ARG            	ssGetSFcnParam(S,5)



#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)

#define NO_I_WORKS              (2)
#define CHANNELS_I_IND          (0)
#define BOARD_I_IND          	(1)


#define NO_R_WORKS              (2)
#define RANGE_R_IND          	(0)
#define OFFSET_R_IND          	(1)

static char_T msg[256];

static first=1;

#ifndef MATLAB_MEX_FILE
#define PD_MAX_CL_SIZE 64
#define AIB_CVSTART0    (1L<<3)
#define AIB_CVSTART1    (1L<<4)
#define AIN_CV_CLOCK_CONTINUOUS  (AIB_CVSTART0 | AIB_CVSTART1)
#define AIB_INPTYPE     (1L<<1)  // AIn Input Type (Unipolar/Bipolar)
#define AIN_BIPOLAR        AIB_INPTYPE
#define AIB_INPRANGE    (1L<<2)  // AIn Input Range (Low/High)
#define AIN_RANGE_10V      AIB_INPRANGE
#define CL_SIZE     48

#define CHAN(c)     ((c) & 0x3f)
#define GAIN(g)     (((g) & 0x3) << 6)
#define SLOW        (1<<8)
#define CHLIST_ENT(c,g,s)   (CHAN(c) | GAIN(g) | ((s) ? SLOW : 0))
//#include "xpcuei.c"
//#include "pdfw_lib.c"
#endif



static void mdlInitializeSizes(SimStruct *S)
{	    

    int i;

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
    uint32_T buffer[32], count;
    int  subDevId = mxGetPr(DEV_ARG)[0];
    int_T bus, slot;
    void *Physical0;
    void *Virtual0;
    PCIDeviceInfo pciinfo;
    uint16_T wArr[10];
    uint32_T range;
    int_T board;
    char_T devName[50];

    uint32_T dwChList[PD_MAX_CL_SIZE];

    uint32_T stat;

    uint16_T sample;

    int_T samples;

    nChannels = mxGetN(CHANNEL_ARG);
    ssSetIWorkValue(S, CHANNELS_I_IND, nChannels);

    mxGetString(DEVNAME_ARG,devName, mxGetN(DEVNAME_ARG));

    if ((int_T)mxGetPr(SLOT_ARG)[0]<0) {
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
        if (mxGetN(SLOT_ARG) == 1) {
            bus = 0;
            slot = (int_T)mxGetPr(SLOT_ARG)[0];
        } else {
            bus = (int_T)mxGetPr(SLOT_ARG)[0];
            slot = (int_T)mxGetPr(SLOT_ARG)[1];
        }
        // look for the PCI-Device
        if (rl32eGetPCIInfoAtSlotExt( (unsigned short)0x1057,
                                      (unsigned short)0x1801,
                                      (unsigned short)0x54A9,
                                      (unsigned short)subDevId,
                                      (slot & 0xff) | ((bus & 0xff)<< 8),
                                      &pciinfo))
        {
            sprintf(msg,"%s (bus %d, slot %d): board not present",
                    devName,
                    bus,
                    slot );
            ssSetErrorStatus(S,msg);
            return;
        }
    }

    Physical0=(void *)pciinfo.BaseAddress[0];
    Virtual0 = rl32eGetDevicePtr(Physical0, 0x8000, RT_PG_USERREADWRITE);

    board = pd_xpc_assign_device( subDevId,
                                  pciinfo.BaseAddress[0],
                                  pciinfo.InterruptLine );	
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

    if (!pd_din_reset(board)) {
        printf("error in pd_din_reset\n");
    }

#endif

}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

    int_T nChannels = ssGetIWorkValue(S, CHANNELS_I_IND);
    int_T board = ssGetIWorkValue(S, BOARD_I_IND);
    int_T i;
    int_T channel;
    real_T  *y;
    uint32_T input;

    pd_din_read_inputs(board, &input);
    for (i=0;i<nChannels;i++) {
        channel=(int_T)mxGetPr(CHANNEL_ARG)[i];
        y=ssGetOutputPortSignal(S,i);
        y[0]=(input & (1<<(channel-1))) >>(channel-1);
    }

#endif

}


static void mdlTerminate(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE    
#endif

}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
