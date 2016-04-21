/* $Revision: 1.2 $ $Date: 2003/01/22 20:18:45 $ */
/* setupqua.c - xPC Target, non-inlined S-function driver for digital
 * input section for the Quatech QSC-100 board */
/* Copyright 1996-2003 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         sersetupbase

#define    DEBUG_PRINTFS   0

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
#define NUMBER_OF_ARGS          (8)
#define ADDR_ARG                ssGetSFcnParam(S,0)
#define BAUD_ARG                ssGetSFcnParam(S,1)
#define WIDTH_ARG               ssGetSFcnParam(S,2)
#define NSTOP_ARG               ssGetSFcnParam(S,3)
#define PARITY_ARG              ssGetSFcnParam(S,4)
#define FMODE_ARG               ssGetSFcnParam(S,5)
#define CTSMODE_ARG             ssGetSFcnParam(S,6)
#define RLEVEL_ARG              ssGetSFcnParam(S,7)

#define NO_I_WORKS              (2)
#define BASE_I_IND              (0)
#define TYPE_I_IND              (1)

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

    int_T base;

    int port;
    int bauddiv;

    int i;
    int lcrtemp;
    int uarttype;
    int ierread;
    short* biosram;
    bool found = false;
    short temp, temp1;

    // Save the base address for mdlterminate
    base = mxGetPr(ADDR_ARG)[0];
    ssSetIWorkValue(S, BASE_I_IND, base);

    // Check the BIOS for this base address.
    biosram = (short *)rl32eGetDevicePtr( (void *)0x400, 1024, RT_PG_USERREADWRITE);
    for( i = 0 ; i < 4 ; i++ )
    {
        if( biosram[i] == base )
        {
            found = true;
            break;
        }
    }

#if DEBUG_PRINTFS == 1
    if( found == true )
        printf("UART addr 0x%x found at COM%d\n", base, i+1 );
    else
        printf("UART addr 0x%x not found\n", base );
#endif

    if( found == false )
    {
        ssSetIWorkValue(S, BASE_I_IND, 0);
        return;
    }

// The following references to IO addresses 0x800 - 0x803 are for
// the targetbox only.
//    switch( base )
//    {
//      case 0x3e8:   // COM3
//        temp = (short)rl32eInpB( (ushort_T)(0x800) ) & 0xff;
//        temp1 = (short)rl32eInpB( (ushort_T)(0x801) ) & 0xff;
//        printf("UART3 resource = 0x%x, control = 0x%x\n", temp, temp1 );
//        break;
//
//        case 0x2e8:   // COM4
//        temp = (short)rl32eInpB( (ushort_T)(0x802) ) & 0xff;
//        temp1 = (short)rl32eInpB( (ushort_T)(0x803) ) & 0xff;
//        printf("UART3 resource = 0x%x, control = 0x%x\n", temp, temp1 );
//        break;
//    }

    bauddiv = basedivisors[ (int)(mxGetPr(BAUD_ARG)[0] - 1) ];

    // Determine if this UART is a 450, 550 or 750.  If it is a 750
    // or greater, then the low power bit in the IER can be set.
    // If 550 or less, then the bit can't be set.
    rl32eOutpB( (ushort_T)(base + IER), IERPOWER );
    ierread = rl32eInpB( (ushort_T)(base + IER) );
    rl32eOutpB( (ushort_T)(base + IER), 0 );
    if( (ierread & IERPOWER) == IERPOWER )
    {
        uarttype = UART750;
    }
    else
    {
        int fcr, mcr;
        // Check for 16C450
        // Try to set the FIFO enable bits in the FCR register.  If it works,
        // then this is a 550, if not then it is a 450.
        rl32eOutpB( (ushort_T)(base + FCR), FCREBL );
        fcr = rl32eInpB( (ushort_T)(base + FCR) ) & 0xff;
        rl32eOutpB( (ushort_T)(base + FCR), 0 );
        // Check to see if the FIFO enable indicators are set
        if( (fcr & 0xc0) != 0xc0 )
            uarttype = UART450;
        else
            uarttype = UART550;
    }

#if DEBUG_PRINTFS == 1
    switch( uarttype )
    {
      case 1:
        printf("UART at 0x%x is a 16450\n", base );
        break;
      case 2:
        printf("UART at 0x%x is a 16550\n", base );
        break;
      case 3:
        printf("UART at 0x%x is a 16750\n", base );
        break;
    }
#endif

    ssSetIWorkValue(S, TYPE_I_IND, uarttype);

    // Block interrupts
    _asm{ cli };

    // Set the DLAB bit so we can get to the baud rate divisor
    // and the options register
    lcrtemp = rl32eInpB( (ushort_T)(base + LCR) );
    rl32eOutpB( (ushort_T)(base + LCR), (ushort_T)(lcrtemp | LCRDLAB) );

    // Set the baud rate divisor, assumes 1x multiplier
    rl32eOutpB( (ushort_T)(base + DLSB), (ushort_T)(bauddiv & 0xff) );
    rl32eOutpB( (ushort_T)(base + DMSB), (ushort_T)((bauddiv >> 8) & 0xff) );

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

    if( uarttype == UART750 || uarttype == UART550 )
    {
        // Set the FCR with fifo properties, 550 or 750 only
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
        // We read the register in interrupt service to see how
        // deep the fifo is.  In the 550 if we try to set the 64
        // deep bit, it won't be set and we fall back to 16 deep.
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
    }

    i = MCROUT2;  // On the baseboard UARTS, OUT2 is an extra interrupt mask!
    if( uarttype == UART750 || uarttype == UART550 )
    {
        if( (int)(mxGetPr(CTSMODE_ARG)[0]) == 1 )
            i |= MCRAFE | MCRRTS;  // Auto RTS/CTS mode
    }
//printf("initial MCR = 0x%x, base = 0x%x\n", i, base );
    // Defaults to DTR, RTS, OUT1, OUT2 all high, bits = 1 sets outputs high
    rl32eOutpB( (ushort_T)(base + MCR), (ushort_T)i );

    // Enable receive interrupts, clear power modes.
    rl32eOutpB( (ushort_T)(base + IER), IERRCV );

//    {
//        int rb = rl32eInpB( (ushort_T)(base + IER) ) & 0xff;
//        printf("IER readback = 0x%x\n", rb );
//    }
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
    int uarttype = ssGetIWorkValue(S, TYPE_I_IND);

//printf("setupbase terminate: base = %x\n", base );
    if( base == 0 )  // This UART is not configured
        return;

    // Disable interrupts.
    rl32eOutpB( (ushort_T)(base + IER), 0 );

    if( uarttype == UART750 || uarttype == UART550 )
    {
        // Flush the transmit and receive fifos so the next start will be clean
        rl32eOutpB( (ushort_T)(base + FCR), FCREBL | FCRRCLR | FCRTCLR );
    }
//printf("setupbase terminate finished\n");
#endif
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
