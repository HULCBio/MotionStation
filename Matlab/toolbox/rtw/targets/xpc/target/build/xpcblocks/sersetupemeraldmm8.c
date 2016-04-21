/* $Revision: 1.1.6.1 $ $Date: 2003/09/02 01:15:28 $ */
/* setupqua.c - xPC Target, non-inlined S-function driver for digital
 * input section for the Quatech QSC-100 board */
/* Copyright 1996-2003 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         sersetupemeraldmm8

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
//#include        "pci_xpcimport.h"
#include        "serialdefines.h"
#endif

/* Input Arguments */
#define NUMBER_OF_ARGS          (9)
#define ADDR_ARG                ssGetSFcnParam(S,0)
#define IRQ_ARG                 ssGetSFcnParam(S,1)
#define BAUD_ARG                ssGetSFcnParam(S,2)
#define WIDTH_ARG               ssGetSFcnParam(S,3)
#define NSTOP_ARG               ssGetSFcnParam(S,4)
#define PARITY_ARG              ssGetSFcnParam(S,5)
#define FMODE_ARG               ssGetSFcnParam(S,6)
#define CTSMODE_ARG             ssGetSFcnParam(S,7)
#define RLEVEL_ARG              ssGetSFcnParam(S,8)

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
    //#include "pci_xpcimport.c"
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

    int_T addr;

    int port;
    int bauddiv;

    int i;
    int lcrtemp;
    int uarttype;
    int ierread;
    short* biosram;
    bool found = false;
    short temp, temp1;
    int configbase;
    int irq;

    //printf("setup start\n");
    // Save the base address for mdlterminate
    addr = mxGetPr(ADDR_ARG)[0];
    irq = mxGetPr(IRQ_ARG)[0];
    //printf("addr = 0x%x, addr>>3 = 0x%x, irq = 0x%x\n", addr, addr>>3, irq );

    // Derive the configuration base address and port number from base.
    // This assumes that addr is (configbase + (port+1)*8) and the last port
    // overlaps the next configbase address.
    configbase = (addr - 1) & ~0x3f;
    port = (((addr - 1) >> 3) & 7);  // 0 based port number, range [0,7]
    //printf("configbase = 0x%x, port = %d\n", configbase, port );

    rl32eOutpB( (ushort_T)(configbase), port );  // set address pointer to this port UART address
    rl32eOutpB( (ushort_T)(configbase+1), addr>>3 ); // Set this port address to addr.
    rl32eOutpB( (ushort_T)(configbase), port+8 );  // set address pointer to this port IRQ number
    rl32eOutpB( (ushort_T)(configbase+1), irq ); // Set this port irq number to irq.

    // Debug readback
    //{
    //	int testaddr, testirq;
    //	rl32eOutpB( (ushort_T)(configbase), port );
    //	testaddr = (rl32eInpB( (ushort_T)(configbase+1) ) & 0xff) << 3;
    //	rl32eOutpB( (ushort_T)(configbase), port+8 );
    //	testirq  = rl32eInpB( (ushort_T)(configbase+1) ) & 0xff;
    //	printf("Readback: addr = 0x%x, irq = %x\n", testaddr, testirq );
    //}
    // End debug readback

    rl32eOutpB( (ushort_T)(configbase), 0x80 );  // Enable the port
    {
	int ebl = rl32eInpB( (ushort_T)(configbase) ) & 0xff;
	//printf("Configbase = 0x%x\n", ebl );
    }
    ssSetIWorkValue(S, BASE_I_IND, addr);
    //printf("base addr = 0x%x\n", addr );
    bauddiv = basedivisors[ (int)(mxGetPr(BAUD_ARG)[0] - 1) ];

    // Determine if this UART is a 450, 550 or 750.  If it is a 750
    // or greater, then the low power bit in the IER can be set.
    // If 550 or less, then the bit can't be set.
    rl32eOutpB( (ushort_T)(addr + IER), IERPOWER );
    ierread = rl32eInpB( (ushort_T)(addr + IER) );
    rl32eOutpB( (ushort_T)(addr + IER), 0 );
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
        rl32eOutpB( (ushort_T)(addr + FCR), FCREBL );
        fcr = rl32eInpB( (ushort_T)(addr + FCR) ) & 0xff;
        rl32eOutpB( (ushort_T)(addr + FCR), 0 );
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
        printf("UART at 0x%x is a 16450\n", addr );
        break;
      case 2:
        printf("UART at 0x%x is a 16550\n", addr );
        break;
      case 3:
        printf("UART at 0x%x is a 16750\n", addr );
        break;
    }
#endif

    ssSetIWorkValue(S, TYPE_I_IND, uarttype);

    // Block interrupts
    _asm{ cli };

    // Set the DLAB bit so we can get to the baud rate divisor
    // and the options register
    lcrtemp = rl32eInpB( (ushort_T)(addr + LCR) );
    rl32eOutpB( (ushort_T)(addr + LCR), (ushort_T)(lcrtemp | LCRDLAB) );

    // Set the baud rate divisor, assumes 1x multiplier
    rl32eOutpB( (ushort_T)(addr + DLSB), (ushort_T)(bauddiv & 0xff) );
    rl32eOutpB( (ushort_T)(addr + DMSB), (ushort_T)((bauddiv >> 8) & 0xff) );

    // Clear the DLAB bit
    rl32eOutpB( (ushort_T)(addr + LCR), (ushort_T)lcrtemp );

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

    rl32eOutpB( (ushort_T)(addr + LCR), (ushort_T)lcrtemp );

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
        lcrtemp = rl32eInpB( (ushort_T)(addr + LCR) );
        rl32eOutpB( (ushort_T)(addr + LCR), (ushort_T)(lcrtemp | LCRDLAB) );

        rl32eOutpB( (ushort_T)(addr + FCR), (ushort_T)i );

        // Clear the DLAB bit
        rl32eOutpB( (ushort_T)(addr + LCR), (ushort_T)lcrtemp );

        // Reenable interrupts
        _asm{ sti };
    }

    i = MCROUT2;  // On the baseboard UARTS, OUT2 is an extra interrupt mask!
    if( uarttype == UART750 || uarttype == UART550 )
    {
        if( (int)(mxGetPr(CTSMODE_ARG)[0]) == 1 )
            i |= MCRAFE | MCRRTS;  // Auto RTS/CTS mode
    }
    // Defaults to DTR, RTS, OUT1, OUT2 all high, bits = 1 sets outputs high
    rl32eOutpB( (ushort_T)(addr + MCR), (ushort_T)i );

    // Enable receive interrupts, clear power modes.
    rl32eOutpB( (ushort_T)(addr + IER), IERRCV );

    // Transmit interrupt isn't enabled yet, but is delayed until there
    // are characters available to be sent.
    //printf("setup: start exit\n");
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
    int addr = ssGetIWorkValue(S, BASE_I_IND);
    int uarttype = ssGetIWorkValue(S, TYPE_I_IND);

    if( addr == 0 )  // This UART is not configured
        return;

    // Disable interrupts.
    rl32eOutpB( (ushort_T)(addr + IER), 0 );

    if( uarttype == UART750 || uarttype == UART550 )
    {
	// Flush the transmit and receive fifos so the next start will be clean
	rl32eOutpB( (ushort_T)(addr + FCR), FCREBL | FCRRCLR | FCRTCLR );
    }
#endif
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
