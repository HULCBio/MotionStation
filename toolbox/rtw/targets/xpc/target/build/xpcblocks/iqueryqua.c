/* $Revision: 1.2.6.1 $ $Date: 2003/11/13 06:22:30 $ */
/* Iqueryqua.c - xPC Target, non-inlined S-function driver for digital
 * input section for the Quatech QSC-100 board */
/* Copyright 1996-2003 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         iqueryqua

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
#define NUMBER_OF_ARGS          (2)
#define SLOT_ARG                ssGetSFcnParam(S,0)
#define TYPE_ARG                ssGetSFcnParam(S,1)

#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)

#define NO_I_WORKS              (1)
#define BASE_I_IND              (0)

#define NO_R_WORKS              (0)

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{

    int i;
    int boardtype;

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
    boardtype = (int)mxGetPr(TYPE_ARG)[0];
    switch( boardtype )
    {
      case 1:  // QSC-100, 4 serial ports
        ssSetOutputPortWidth(S, 0, 4);
        break;
      case 2:  // ESC-100, 8 serial ports
        ssSetOutputPortWidth(S, 0, 8);
        break;
      case 3:  // QSC-200/300, 4 serial ports
        ssSetOutputPortWidth(S, 0, 4);
        break;
      default:
        sprintf(msg, "Unknown board type: %d\n", boardtype );
        ssSetErrorStatus(S,msg);
        return;
    }
    ssSetOutputPortDataType( S, 0, SS_UINT32 );

    ssSetNumInputPorts(S, 0);

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

    base = pciinfo.BaseAddress[1] & 0xffff;
    ssSetIWorkValue(S, BASE_I_IND, base);
#endif

}

static int intcount = 0;

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

    int base = ssGetIWorkValue(S, BASE_I_IND);
    int_T ports = 0;
    int_T *OPtr = ssGetOutputPortSignal(S,0);
    int i;
    volatile int gint;  // global interrupt register
    volatile int lint;  // local interrupt register, per uart

//printf("ISR entry\n");
    switch( (int)(mxGetPr(TYPE_ARG)[0]) )
    {
      case 1:
        ports = 4;
        break;
      case 2:
        ports = 8;
        break;
      case 3:
        ports = 4;
        break;
    }

    gint = rl32eInpB( (unsigned short)(base + GISTAT) ) & 0xff;
//printf("       gint = %x\n", gint );
    for( i = 0 ; i < ports ; i++ )
    {
        if( gint & (1 << i) )
        {
            int reason = 1;

            lint = rl32eInpB( (unsigned short)(base + i*8 + IIR) ) & 0xff;
            reason = 0;

            switch( lint & IIRREASON )
            {
              case 1:  // No interrupt on this UART
                reason = 0;
                break;
//              case 0xd: // This one shouldn't happen, but it does!
              case 4:   // received data available
              case 6:   // receiver line status, overrun etc.
              case 0xc: // character timeout
                reason = 1;  // All three are receive interrupts
                break;
              case 2:
                reason = 2;  // Transmitter holding register empty
                break;
              case 0:
                reason = 3;  // Modem status change
                break;
            }
            OPtr[i] = reason | lint << 8;
//if( reason != 0 )
//   printf("int reason = %x, port = %d, count = %d\n", OPtr[i], i+1, ++intcount );
        }
        else
            OPtr[i] = 0;   // No interrupt pending on port i.
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
