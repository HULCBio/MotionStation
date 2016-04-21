/* $Revision: 1.2.2.3 $ $Date: 2004/04/08 21:02:16 $ */
/* enccbcioquad.c - xPC Target, non-inlined S-function driver for CB
 * CIO/PCI-QUAD series boards
 */
/* Copyright 1996-2003 The MathWorks, Inc.
 */

#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME  enccbcioquadcount

#include        <stdlib.h>     /* malloc(), free(), strtoul() */
#include "simstruc.h"

#ifdef          MATLAB_MEX_FILE
#include        "mex.h"
#else
#include        <windows.h>
#include        "io_xpcimport.h"
#include        "pci_xpcimport.h"
#endif

/* S Function Parameters */

#define NUM_PARAMS             (11)
#define BASE_ADDRESS_PARAM     (ssGetSFcnParam(S,0))
#define CHANNEL_PARAM          (ssGetSFcnParam(S,1))
#define RESET_PARAM            (ssGetSFcnParam(S,2))
#define POLARITY_PARAM         (ssGetSFcnParam(S,3))
#define MODE_PARAM             (ssGetSFcnParam(S,4))
#define LIMIT_PARAM            (ssGetSFcnParam(S,5))
#define RANGE_PARAM            (ssGetSFcnParam(S,6))
#define SPEED_PARAM            (ssGetSFcnParam(S,7))
#define PRESCALE_PARAM         (ssGetSFcnParam(S,8))
#define SAMP_TIME_ARG          (ssGetSFcnParam(S,9))
#define BOARD_ARG              (ssGetSFcnParam(S,10))

#define NO_I_WORKS             (1)
#define BASE_ADDR_I_IND        (0)

#define NO_R_WORKS             (0)

#define RLD 0x00
#define CMR 0x20
#define IOR 0x40
#define IDR 0x60

#define TEST_VALUE 0x123456

static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{

    int i;

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "pci_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUM_PARAMS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"Wrong number of input arguments passed.\n%d arguments are expected\n",NUM_PARAMS);
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    if (!ssSetNumInputPorts(S, 0)) return;

    ssSetNumOutputPorts(S, 1);
    for ( i = 0 ; i < 1 ; i++ )
    {
        ssSetOutputPortWidth(S, i, 1);
    }

    ssSetNumSampleTimes(S, 1);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    for( i = 0 ; i < NUM_PARAMS ; i++ )
        ssSetSFcnParamNotTunable(S,i);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    if (mxGetPr(SAMP_TIME_ARG)[0]==-1.0)
    {
    	ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    	ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
    }
    else
    {
        ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME_ARG)[0]);
    	ssSetOffsetTime(S, 0, 0.0);
    }
}

#define MDL_START  /* Change to #undef to remove function */
#if defined(MDL_START)
static void mdlStart(SimStruct *S)
{
    int   mode;
    int   speed;
    int   limit;
    int   resetmode;
    int   polarity;
    int   prescale;
    int_T baseAddr;
    int_T channelAddr;  // baseAddr plus channel offset
    int_T cntrout = 0;
    int_T cmrInit = 0;
    int_T idrInit = 0;
    int_T iorInit = 0;

#ifndef MATLAB_MEX_FILE

    PCIDeviceInfo pciinfo;

    if ( ((int_T)mxGetPr(BOARD_ARG)[0])<3) {

        baseAddr= (int_T)mxGetPr(BASE_ADDRESS_PARAM)[0];

    } else {

        if ((int_T)mxGetPr(BASE_ADDRESS_PARAM)[0]<0) {
            /* look for the PCI-Device */
            if (rl32eGetPCIInfo((unsigned short)0x1307,(unsigned short)0x4d,&pciinfo)) {
                sprintf(msg,"CB PCI-QUAD04: board not present");
                ssSetErrorStatus(S,msg);
                return;
            }
        } else {
            int_T bus, slot;
            if (mxGetN(BASE_ADDRESS_PARAM) == 1) {
                bus = 0;
                slot = (int_T)mxGetPr(BASE_ADDRESS_PARAM)[0];
            } else {
                bus = (int_T)mxGetPr(BASE_ADDRESS_PARAM)[0];
                slot = (int_T)mxGetPr(BASE_ADDRESS_PARAM)[1];
            }
            // look for the PCI-Device
            if (rl32eGetPCIInfoAtSlot((unsigned short)0x1307,(unsigned short)0x4d,(slot & 0xff) | ((bus & 0xff)<< 8),&pciinfo)) {
                sprintf(msg,"CB PCI-QUAD04 (bus %d, slot %d): board not present", bus, slot );
                ssSetErrorStatus(S,msg);
                return;
            }
        }

        baseAddr=pciinfo.BaseAddress[2];

    }

    ssSetIWorkValue(S, BASE_ADDR_I_IND, (int_T)baseAddr);

    channelAddr = baseAddr + ((mxGetPr(CHANNEL_PARAM)[0]-1) * 2);

    //Set Counter Mode Register(CMR)
    mode = mxGetPr(MODE_PARAM)[0];
    speed = mxGetPr(SPEED_PARAM)[0];

    switch( mode )
    {
      default:
      case 1:   // Normal counting mode, 24 bit count
        cmrInit = 0;
        break;

      case 2:   // Range limit mode
        cmrInit = 0x2;
        break;

      case 3:   // Non-recycle mode
        cmrInit = 0x4;
        break;

      case 4:   // Modulo-N counting
        cmrInit = 0x6;
        break;
    }

    switch( speed )
    {
      case 1:   // Non-quadrature counting
        // Don't change cmrInit, 0 in bits 3 and 4 for this mode.
        break;

      default:
      case 2:   // 1x counting
        cmrInit |= 0x8;
        break;

      case 3:   // 2x counting
        cmrInit |= 0x10;
        break;

      case 4:   // 4x counting
        cmrInit |= 0x18;
        break;
    }
    cmrInit |= CMR;
    //printf("cmrInit = 0x%x\n", cmrInit );
    rl32eOutpB( (unsigned short)(channelAddr + 0x01), (unsigned short)cmrInit );

    //Reset Error detect bit
    rl32eOutpB( (unsigned short)(channelAddr + 0x01),RLD + 0x06);

    //Reset BP
    rl32eOutpB( (unsigned short)(channelAddr + 0x01),RLD + 0x01);

    //Load PR0 with the user specified value before transferring the 
    // value to the PSC (Prescale) register.
    // The value 0 allows the maximum counting frequency.
    prescale = (int)mxGetPr(PRESCALE_PARAM)[0];
    rl32eOutpB( (unsigned short)channelAddr, prescale & 0xff ); //LSB

    //Transfer from PR0 to PSC
    rl32eOutpB((unsigned short)(channelAddr + 0x01),RLD + 0x18);

    //Reset BP
    rl32eOutpB( (unsigned short)(channelAddr + 0x01),RLD + 0x01);

    //Load preset register(PR) with a test value
    rl32eOutpB( (unsigned short)channelAddr, TEST_VALUE & 0x0000ff); //LSB
    rl32eOutpB( (unsigned short)channelAddr,(TEST_VALUE >> 8) & 0x0000ff);
    rl32eOutpB( (unsigned short)channelAddr,(TEST_VALUE >> 16) & 0x0000ff); //MSB

    //IDR - Enable index, Set index polarity, Index pin select
    polarity = mxGetPr( POLARITY_PARAM )[0];
    switch( polarity )
    {
      case 1:
        idrInit = IDR;
        break;
      case 2:
        idrInit = IDR + 2;
        break;
    }
    resetmode = mxGetPr( RESET_PARAM )[0];
    switch( resetmode )
    {
      case 1:  // Reset on all index marks
        idrInit |= 1;
        iorInit = IOR + 1;  // PR to CNTR at index, A and B enabled
        break;
      case 0:  // Index not used, 0 in lsb of idrInit.
        iorInit = IOR + 3;  // CNTR to OL at index (essentially a NOOP), A and B enabled
        break;
    }
    //idrInit = IDR + 2;
    //IOR - Enable A/B input, Set reset CNTR at index
    rl32eOutpB((unsigned short)(channelAddr + 0x01), iorInit );

    //printf("idrInit = 0x%x\n", idrInit );
    rl32eOutpB((unsigned short)(channelAddr + 0x01), idrInit );

    /* Setup index/interrupt routing control register
     * Note: If later index pin select is changed this
     *       value needs to be changed accordingly. Also
     *       this may required it to be set on a per
     *       channel basis.
     */
    rl32eOutpB((unsigned short)(baseAddr + 0x08),0x0f);

    //Disable cascading
    rl32eOutpB((unsigned short)(baseAddr + 0x09),0x00);

    //Disable interrupts
    rl32eOutpB((unsigned short)(baseAddr + 0x12),0x00);

    //Load CNTR with PR
    rl32eOutpB((unsigned short)(channelAddr + 0x01),RLD + 0x08);

    //Load OL with Data
    rl32eOutpB((unsigned short)(channelAddr + 0x01),RLD + 0x10);

    //Reset BP
    rl32eOutpB((unsigned short)(channelAddr + 0x01),RLD + 0x01);

    //Read OL
    cntrout = (rl32eInpB((unsigned short)channelAddr) & 0x00ff);
    cntrout = cntrout | ((rl32eInpB((unsigned short)channelAddr) & 0x00ff) << 8  );
    cntrout = cntrout | ((rl32eInpB((unsigned short)channelAddr) & 0x00ff) << 16 );

    if (cntrout != TEST_VALUE) {
        sprintf(msg,"Init Failed: Check CB CIO/PCI-QUAD Encoder Board");
        ssSetErrorStatus(S,msg);
    }

     //Reset BP
    rl32eOutpB((unsigned short)(channelAddr + 0x01),RLD + 0x01);

    //Load preset register(PR) with 0 to use to reset CNTR.
    rl32eOutpB((unsigned short)channelAddr, 0 ); //LSB
    rl32eOutpB((unsigned short)channelAddr, 0 );
    rl32eOutpB((unsigned short)channelAddr, 0 ); //MSB

    //printf("Reset CNT to 0\n");
    //Load CNTR with PR
    rl32eOutpB((unsigned short)(channelAddr + 0x01),RLD + 0x08);

   //Reset BP
    rl32eOutpB((unsigned short)(channelAddr + 0x01),RLD + 0x01);

    // Leave the preset register(PR) set to the limiting value specified by the
    // user.
    limit = mxGetPr(LIMIT_PARAM)[0];
    rl32eOutpB((unsigned short)channelAddr, (char)limit ); //LSB
    rl32eOutpB((unsigned short)channelAddr, (char)(limit >> 8) );
    rl32eOutpB((unsigned short)channelAddr, (char)(limit >> 16) ); //MSB

    // If resetmode == 1, then initialize CNTR to LIMIT_PARAM, else leave
    // it cleared to 0.
    if( resetmode == 1 )
        rl32eOutpB((unsigned short)(channelAddr + 0x01),RLD + 0x08);

#endif // MATLAB_MEX_FILE
}
#endif /*  MDL_START */

static void mdlOutputs(SimStruct *S, int_T tid)
{
    real_T   *y;
    int_T    cntrout;
    int_T    baseAddr = ssGetIWorkValue(S, BASE_ADDR_I_IND);
    int_T    channelAddr;
    int_T    range = mxGetPr( RANGE_PARAM )[0];

#ifndef MATLAB_MEX_FILE
    channelAddr = baseAddr + ((mxGetPr(CHANNEL_PARAM)[0]-1) * 2);
    y           = ssGetOutputPortRealSignal(S,0);

    // Latch data to OL
    rl32eOutpB((unsigned short)(channelAddr + 0x01),RLD + 0x10);
    // Reset BP
    rl32eOutpB((unsigned short)(channelAddr + 0x01),RLD + 0x01);
    // Read OL
    cntrout = (rl32eInpB((unsigned short)channelAddr) & 0x00ff);
    cntrout = cntrout | ((rl32eInpB((unsigned short)channelAddr) & 0x00ff) << 8 );
    cntrout = cntrout | ((rl32eInpB((unsigned short)channelAddr) & 0x00ff) << 16 );

    if( (range == 2) && (cntrout & 0x800000) )  // If 24 bit sign bit is set
        cntrout |= 0xff000000;  // Sign extend to make 32 bit signed result.

    y[0] = (double)cntrout;
#endif // MATLAB_MEX_FILE
}

static void mdlTerminate(SimStruct *S)
{
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
