/* $Revision: 1.2 $ $Date: 2003/01/22 20:18:58 $ */
/* setupqua.c - xPC Target, non-inlined S-function driver for digital
 * input section for the Quatech QSC-100 board */
/* Copyright 1996-2003 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         setupqua

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
#define NUMBER_OF_ARGS          (10)
#define SLOT_ARG                ssGetSFcnParam(S,0)
#define TYPE_ARG                ssGetSFcnParam(S,1)
#define PORT_ARG                ssGetSFcnParam(S,2)
#define BAUD_ARG                ssGetSFcnParam(S,3)
#define WIDTH_ARG               ssGetSFcnParam(S,4)
#define NSTOP_ARG               ssGetSFcnParam(S,5)
#define PARITY_ARG              ssGetSFcnParam(S,6)
#define FMODE_ARG               ssGetSFcnParam(S,7)
#define CTSMODE_ARG             ssGetSFcnParam(S,8)
#define RLEVEL_ARG              ssGetSFcnParam(S,9)

#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)

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

    ssSetNumOutputPorts(S, 0);

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

    int port;
    int bauddiv;
    int srcmult;

    int i;
    int lcrtemp;
    bool tl16c750 = false;
    int ierread;

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
        if (rl32eGetPCIInfo((ushort_T)vendorId,(ushort_T)deviceId,&pciinfo))
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
        if (rl32eGetPCIInfoAtSlot((ushort_T)vendorId,(ushort_T)deviceId,(slot & 0xff) | ((bus & 0xff)<< 8),&pciinfo))
        {
            sprintf( msg, "%s (bus %d,slot %d): board not present", devName, bus, slot );
            ssSetErrorStatus( S, msg );
            return;
        }
    }

    // show Device Information
    // rl32eShowPCIInfo(pciinfo);

    // Save the base address for mdlterminate
    base = pciinfo.BaseAddress[1] & 0xffff;
    ssSetIWorkValue(S, BASE_I_IND, base);

    port = (int)mxGetPr(PORT_ARG)[0] - 1;
    base = base + port * 8;
    bauddiv = divisors[ (int)(mxGetPr(BAUD_ARG)[0] - 1) ];
    srcmult = OPTX8;

    // Determine if this UART is a 550 or 750.  If it is a 750
    // or greater, then the low power bit in the IER can be set.
    // If 550 or less, then the bit can't be set.
    rl32eOutpB( (ushort_T)(base + IER), IERPOWER );
    ierread = rl32eInpB( (ushort_T)(base + IER) );
    rl32eOutpB( (ushort_T)(base + IER), 0 );
    if( (ierread & IERPOWER) == IERPOWER )
    {
        tl16c750 = true;
    }
    if( !tl16c750 )
    {
        bauddiv >>= 2;
        srcmult = OPTX2;
        if( bauddiv == 0 )
        {
            // The QSC-200/300 uses either 16750 or 16550 UART
            // The 16550 can't use the X8 or X4 multiplier!
            sprintf( msg, "This %s board does not support the chosen baud rate.", devName );
            ssSetErrorStatus( S, msg );
            return;
        }
    }

    // Block interrupts
    _asm{ cli };

    // Set the DLAB bit so we can get to the baud rate divisor
    // and the options register
    lcrtemp = rl32eInpB( (ushort_T)(base + LCR) );
    rl32eOutpB( (ushort_T)(base + LCR), (ushort_T)(lcrtemp | LCRDLAB) );

    // Set the baud rate divisor, assumes 8x multiplier
    rl32eOutpB( (ushort_T)(base + DLSB), (ushort_T)(bauddiv & 0xff) );
    rl32eOutpB( (ushort_T)(base + DMSB), (ushort_T)((bauddiv >> 8) & 0xff) );

    // Set the baud rate source multiplier
    rl32eOutpB( (ushort_T)(base + OPTIONS), (ushort_T)srcmult );

    // Clear the DLAB bit
    rl32eOutpB( (ushort_T)(base + LCR), (ushort_T)lcrtemp );

    // Reenable interrupts
    _asm{ sti };


    // Construct the contents of the LCR register.
    lcrtemp = 0;

    switch( (int)(mxGetPr(WIDTH_ARG)[0]) )
    {
      case 1:
        i = LCR5BIT;
        break;
      case 2:
        i = LCR6BIT;
        break;
      case 3:
        i = LCR7BIT;
        break;
      case 4:
        i = LCR8BIT;
        break;
    }
    lcrtemp |= i;

    if( (int)(mxGetPr(NSTOP_ARG)[0]) == 2 )  // If 2 stop bits are chosen,
        lcrtemp |= LCRSTOP;

    // Parity selection involves 3 bits in the LCR
    i = 0;
    switch( (int)(mxGetPr(PARITY_ARG)[0] ) )
    {
      case 1:   // no parity
        i = 0;
        break;
      case 2:   // even parity
        i = LCRPARITY | LCREVEN;
        break;
      case 3:   // odd parity
        i = LCRPARITY;
        break;
      case 4:   // mark parity
        i = LCRPARITY | LCRSTICK;
        break;
      case 5:   // space parity
        i = LCRPARITY | LCREVEN | LCRSTICK;
        break;
    }
    lcrtemp |= i;

    rl32eOutpB( (ushort_T)(base + LCR), (ushort_T)lcrtemp );

    // Set the FCR with fifo properties
    switch( (int)(mxGetPr(RLEVEL_ARG)[0] ) )
    {
      case 1:  // interrupt at 1 byte
        i = FCRONE;
        break;
      case 2:  // interrupt at quarter full (4 or 16)
        i = FCRQUARTER;
        break;
      case 3:  // interrupt at half full   (8 or 32)
        i = FCRHALF;
        break;
      case 4:  // interrupt at almost full (14 or 56)
        i = FCRFULL;
        break;
    }
    switch( (int)(mxGetPr(FMODE_ARG)[0]) )
    {
      case 1:   // 64 deep fifo
        i |= FCREBL | FCR64 | FCRRCLR | FCRTCLR;
        break;
      case 2:   // 16 deep fifo
        i |= FCREBL | FCRRCLR | FCRTCLR;
        break;
      case 3:   // no fifo
        i = 0;
        break;
    }
    // Block interrupts while DLAB is set
    _asm{ cli };

    // Set the DLAB bit so that writing to the 64 bit fifo mode bit is enabled
    lcrtemp = rl32eInpB( (ushort_T)(base + LCR) );
    rl32eOutpB( (ushort_T)(base + LCR), (ushort_T)(lcrtemp | LCRDLAB) );

    rl32eOutpB( (ushort_T)(base + FCR), (ushort_T)i );

    // Clear the DLAB bit
    rl32eOutpB( (ushort_T)(base + LCR), (ushort_T)lcrtemp );

    // Reenable interrupts
    _asm{ sti };

    i = 0;
    if( (int)(mxGetPr(CTSMODE_ARG)[0]) == 1 )
        i = MCRAFE | MCRRTS;  // Auto RTS/CTS mode
    // Defaults to DTR, RTS, OUT1, OUT2 all high, bits = 1 sets outputs high
    rl32eOutpB( (ushort_T)(base + MCR), (ushort_T)i );

    // Enable receive interrupts, clear power modes.
    rl32eOutpB( (ushort_T)(base + IER), IERRCV );

    // Transmit interrupt isn't enabled yet, but is delayed until there
    // are characters available to be sent.
#endif

}

static void mdlOutputs(SimStruct *S, int_T tid)
{

#ifndef MATLAB_MEX_FILE

// No body, this block does nothing at run time.

#endif

}

static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
    int base = ssGetIWorkValue(S, BASE_I_IND);

    // Disable interrupts.
    rl32eOutpB( (ushort_T)(base + IER), 0 );

    // Flush the transmit and receive fifos so the next start will be clean
    rl32eOutpB( (ushort_T)(base + FCR), FCREBL | FCRRCLR | FCRTCLR );
#endif
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
