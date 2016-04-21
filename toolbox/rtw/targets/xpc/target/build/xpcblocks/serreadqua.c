/* $Revision: 1.3 $ $Date: 2003/04/24 18:18:32 $ */
/* setupqua.c - xPC Target, non-inlined S-function driver for digital
 * input section for the Quatech QSC-100 board */
/* Copyright 1996-2003 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         serreadqua

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
#include        "serialdefines.h"
#endif

/* Input Arguments */
#define NUMBER_OF_ARGS          (4)
#define SLOT_ARG                ssGetSFcnParam(S,0)
#define PORT_ARG                ssGetSFcnParam(S,1)
#define TYPE_ARG                ssGetSFcnParam(S,2)
#define FLUSH_ARG               ssGetSFcnParam(S,3)

#define NO_I_WORKS              (1)
#define BASE_I_IND              (0)

#define NO_R_WORKS              (0)

static char_T msg[256];

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

    ssSetNumOutputPorts(S, 1);
    // The output is wide enough to hold up to 1 hardware fifo full of characters
    // plus 1 spot for the count.
    ssSetOutputPortWidth(S, 0, 65);
    ssSetOutputPortDataType( S, 0, SS_UINT32 );
//    ssSetOutputPortWidth(S, 1, 1);
//    ssSetOutputPortDataType( S, 1, SS_UINT32 );

    ssSetNumInputPorts(S, 1);
    ssSetInputPortWidth(S, 0, 1);
    ssSetInputPortDataType( S, 0, SS_UINT32 );
    ssSetInputPortDirectFeedThrough(S, 0, 1);

    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumPWork(S, 0);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    for( i = 0 ; i < NUMBER_OF_ARGS ; i++ )
    {
        ssSetSFcnParamTunable(S,i,0);  /* None of the parameters are tunable */
    }

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    	ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    	ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
}

#define MDL_START
static void mdlStart(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE

    PCIDeviceInfo pciinfo;
    int_T base;
    int_T vendorId, deviceId;
    char_T devName[30];
    int boardtype = (int)mxGetPr(TYPE_ARG)[0];
    int port = (int)mxGetPr(PORT_ARG)[0];
    int flush = (int)mxGetPr(FLUSH_ARG)[0];

    vendorId = 0x135c;
    switch( boardtype )
    {
      case 1:
        deviceId = 0x10;
        strcpy( devName, "Quatech QSC-100" );
        break;
      case 2:
        deviceId = 0x50;
        strcpy( devName, "Quatech ESC-100" );
        break;
      case 3:
        deviceId = 0x40;
        strcpy( devName, "Quatech QSC-200/300" );
        break;
      default:
        sprintf( msg, "Quatech: Unknown board type, %d", boardtype );
        ssSetErrorStatus( S, msg );
        return;
    }

    if ((int_T)mxGetPr(SLOT_ARG)[0]<0) {
        // look for the PCI-Device
        if (rl32eGetPCIInfo((unsigned short)vendorId,(unsigned short)deviceId,&pciinfo))
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
        if (rl32eGetPCIInfoAtSlot((unsigned short)vendorId,(unsigned short)deviceId,(slot & 0xff) | ((bus & 0xff)<< 8),&pciinfo))
        {
            sprintf( msg, "%s (bus %d,slot %d): board not present", devName, bus, slot );
            ssSetErrorStatus( S, msg );
            return;
        }
    }

    // show Device Information
    // rl32eShowPCIInfo(pciinfo);

    // Save the base address for mdlterminate
    base = (port - 1) * 8 + (pciinfo.BaseAddress[1] & 0xffff);
    ssSetIWorkValue(S, BASE_I_IND, base);

    if( flush )
    {
        // Flush the hardware fifo on startup.
        while( rl32eInpB( (unsigned short)(base + LSR) ) & LSRDR )
        {
            // Read and discard the data.
            rl32eInpB( (unsigned short)(base + DATA) );
        }
    }
#endif

}

static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
    int base = ssGetIWorkValue(S, BASE_I_IND);
    int_T *OPtr = ssGetOutputPortSignal(S,0);
    int_T *IPtr = (int_T *)ssGetInputPortSignal(S,0);
    int status = 0;
    int count = 0;
    int enable;

    enable = (IPtr[0]) & 0xff;

    if( enable > 0 )
    {
        status = rl32eInpB( (unsigned short)(base + LSR) ) & 0xff;
//printf("read status = %x\n", status );
        // While there is data in the fifo, read it, also read error status.
        // Cap the read length to the interrupt point in 64 byte fifo mode.
        while( (status & LSRDR) && (count < 56) )
        {
            int c;
            int masked;
            
            count++;
            c = rl32eInpB( (unsigned short)(base + DATA) ) & 0xff;  // read character
            masked = status & (LSROE | LSRPE | LSRFE | LSRBI);
//printf("c = %x, stat = 0x%x, masked = 0x%x ", c, status, masked );
            OPtr[count] = ((status & (LSROE | LSRPE | LSRFE | LSRBI)) << 8) | ( c & 0xff );
//printf("o = 0x%x\n", OPtr[count] );
            status = rl32eInpB( (unsigned short)(base + LSR) ) & 0xff;
        }
        OPtr[0] = count;
    }
    else
    {
        OPtr[0] = 0;
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
