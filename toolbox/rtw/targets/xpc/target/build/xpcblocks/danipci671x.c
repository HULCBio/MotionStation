/* $Revision $ $Date: 2003/09/14 13:58:26 $ */
/* danipci671x.c - xPC Target, non-inlined S-function driver for D/A section
 *                 of NI PCI-6713, PCI-6714 and PXI-6714 series boards  */
/* Copyright 1996-2003 The MathWorks, Inc.
*/

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         danipci671x

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
#define NUMBER_OF_ARGS          (6)
#define CHANNEL_ARG             ssGetSFcnParam(S,0)
#define SAMP_TIME_ARG           ssGetSFcnParam(S,1)
#define SLOT_ARG                ssGetSFcnParam(S,2)
#define DEV_ARG                 ssGetSFcnParam(S,3)
#define RESET_ARG               ssGetSFcnParam(S,4)
#define INIT_ARG                ssGetSFcnParam(S,5)

#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)

#define NO_I_WORKS              (2)
#define CHANNELS_I_IND          (0)
#define BASE_ADDR_I_IND         (1)

#define NO_R_WORKS              (0)

static char_T msg[256];

#define AOCINFIGREG		0x16/2  // AO config register offset, 16 bit offset
#define IOWINDOWADDR            24/2    // address to put the register address to
#define IOWINDOWDATA            30/2    // address to put/get the register data to/from

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
    int_T outcode;

    PCIDeviceInfo pciinfo;
    void *Physical1, *Physical0;
    void *Virtual1, *Virtual0;
    volatile uint32_T *miteaddr;
    volatile uint32_T *ioaddr;
    volatile uint16_T *ioaddr16;
    volatile uint8_T  *ioaddr8;
    char devName[20];
    int  devId;

    nChannels = mxGetN(CHANNEL_ARG);
    ssSetIWorkValue(S, CHANNELS_I_IND, nChannels);

    switch ((int_T)mxGetPr(DEV_ARG)[0]) {
      case 1:
        strcpy(devName,"NI PCI-6713");
        devId = 0x1870;
        break;
    case 2:
        strcpy(devName,"NI PXI-6713");
        devId = 0x2B80;
        break;
      case 3:
        strcpy(devName,"NI PCI-6711");
        devId = 0x1880;
        break;
        //case 4:
        //  strcpy(devName,"NI PXI-6711");
        //  devId = 0x????;
        //  break;
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

    Physical1=(void *)pciinfo.BaseAddress[1];
    Virtual1 = rl32eGetDevicePtr(Physical1, 4096, RT_PG_USERREADWRITE);
    ioaddr = (uint32_T *)Virtual1;
    ioaddr16 = (uint16_T *)Virtual1;
    ioaddr8 = (uint8_T *)Virtual1;

    Physical0 = (void *)pciinfo.BaseAddress[0];  // MITE space
    Virtual0 = rl32eGetDevicePtr(Physical0, 4096, RT_PG_USERREADWRITE);
    miteaddr = (uint32_T *) Virtual0;
    miteaddr[48] = ((unsigned int)ioaddr & ~0xff) | 0x80;
    miteaddr[49] = 0;
    miteaddr[61] = ((unsigned int)ioaddr & ~0xff) | 0x8b;

    //printf("6713: bar0 = 0x%x, bar1 = 0x%x\n", Physical0, Physical1 );
    ssSetIWorkValue(S, BASE_ADDR_I_IND, (uint_T)ioaddr);

    for ( i = 0 ; i < 8 ; i++ )
    {

        output = mxGetPr( INIT_ARG )[i];
        if (output < -10.0) output= -10.0;  // --> 0x800
        if (output > 9.995) output= 9.995;  // --> 0x7ff
        outcode = (uint32_T)((( output ) / 20.0 ) * 4096.0);
        //printf("ch %d, %f, 0x%x\n", i, output, outcode );

        ioaddr16[AOCINFIGREG] = i << 8;

        ioaddr16[IOWINDOWADDR] = i;
        ioaddr16[IOWINDOWDATA] = outcode;
    }

    // Display the stuff in the EEPROM
    //for( i = 319 ; i < 345 ; i++ )
    //{
    //    unsigned char val = readEEPROM( ioaddr8, i );
    //    printf("%d(0x%x)%c", i, val, (i%5==4)?'\n':' ');
    //}
    //printf("\n");
    //for( i = 345 ; i < 371 ; i++ )
    //{
    //    unsigned char val = readEEPROM( ioaddr8, i );
    //    printf("%d(0x%x)%c", i, val, (i%5==4)?'\n':' ');
    //}
    //printf("\n");
    //for( i = 443 ; i < 469 ; i++ )
    //{
    //    unsigned char val = readEEPROM( ioaddr8, i );
    //    printf("%d(0x%x)%c", i, val, (i%5==4)?'\n':' ');
    //}
    //printf("\n");

    // Reset all caldac regs to value in the EEPROM
    writeCALDACN( ioaddr8, 0,  8, readEEPROM(ioaddr8, 467) );  // Chan 0
    writeCALDACN( ioaddr8, 0,  4, readEEPROM(ioaddr8, 466) );
    writeCALDACN( ioaddr8, 0,  7, readEEPROM(ioaddr8, 465) );

    writeCALDACN( ioaddr8, 0,  2, readEEPROM(ioaddr8, 464) );  // chan 1
    writeCALDACN( ioaddr8, 0, 10, readEEPROM(ioaddr8, 463) );
    writeCALDACN( ioaddr8, 0,  6, readEEPROM(ioaddr8, 462) );

    writeCALDACN( ioaddr8, 0, 11, readEEPROM(ioaddr8, 461) );  // chan 2
    writeCALDACN( ioaddr8, 0,  1, readEEPROM(ioaddr8, 460) );
    writeCALDACN( ioaddr8, 0,  9, readEEPROM(ioaddr8, 459) );

    writeCALDACN( ioaddr8, 0,  5, readEEPROM(ioaddr8, 458) );  // chan 3
    writeCALDACN( ioaddr8, 0,  0, readEEPROM(ioaddr8, 457) );
    writeCALDACN( ioaddr8, 0,  3, readEEPROM(ioaddr8, 456) );

    writeCALDACN( ioaddr8, 1,  8, readEEPROM(ioaddr8, 455) );  // Chan 4
    writeCALDACN( ioaddr8, 1,  4, readEEPROM(ioaddr8, 454) );
    writeCALDACN( ioaddr8, 1,  7, readEEPROM(ioaddr8, 453) );

    writeCALDACN( ioaddr8, 1,  2, readEEPROM(ioaddr8, 452) );  // chan 5
    writeCALDACN( ioaddr8, 1, 10, readEEPROM(ioaddr8, 451) );
    writeCALDACN( ioaddr8, 1,  6, readEEPROM(ioaddr8, 450) );

    writeCALDACN( ioaddr8, 1, 11, readEEPROM(ioaddr8, 449) );  // chan 6
    writeCALDACN( ioaddr8, 1,  1, readEEPROM(ioaddr8, 448) );
    writeCALDACN( ioaddr8, 1,  9, readEEPROM(ioaddr8, 447) );

    writeCALDACN( ioaddr8, 1,  5, readEEPROM(ioaddr8, 446) );  // chan 7
    writeCALDACN( ioaddr8, 1,  0, readEEPROM(ioaddr8, 445) );
    writeCALDACN( ioaddr8, 1,  3, readEEPROM(ioaddr8, 444) );

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
    volatile uint16_T *ioaddr16;
    InputRealPtrsType uPtrs;

    ioaddr16 = (uint16_T *) base;

    for( i = 0 ; i < nChannels ; i++ )
    {
	int outcode;

        channel = mxGetPr(CHANNEL_ARG)[i]-1;
        uPtrs = ssGetInputPortRealSignalPtrs(S,i);
        output = *uPtrs[0];

        if (output < -10.0) output= -10.0;  // --> 0x800
        if (output > 9.995) output= 9.995;  // --> 0x7ff
        outcode = (uint32_T)((( output ) / 20.0 ) * 4096.0);

	ioaddr16[AOCINFIGREG] = channel << 8;  // DAC select

	ioaddr16[IOWINDOWADDR] = channel;       // address and write data
	ioaddr16[IOWINDOWDATA] = outcode;
    }
#endif
}

static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
    uint_T  base = ssGetIWorkValue(S, BASE_ADDR_I_IND);
    int_T nChannels = ssGetIWorkValue(S, CHANNELS_I_IND);
    int_T i;
    real_T output;
    int_T channel;
    volatile uint16_T *ioaddr16;

    ioaddr16 = (uint16_T *) base;

    for( i = 0 ; i < nChannels ; i++ )
    {
	int outcode;

        channel = mxGetPr(CHANNEL_ARG)[i]-1;

        if( mxGetPr( RESET_ARG )[i] == 1 )
        {
            output = mxGetPr( INIT_ARG )[i];
            if (output < -10.0) output= -10.0;  // --> 0x800
            if (output > 9.995) output= 9.995;  // --> 0x7ff
            outcode = (uint32_T)((( output ) / 20.0 ) * 4096.0);
            //printf("ch %d, %f, 0x%x\n", i, output, outcode );

            ioaddr16[AOCINFIGREG] = channel << 8;  // DAC select

            ioaddr16[IOWINDOWADDR] = channel;       // address and write data
            ioaddr16[IOWINDOWDATA] = outcode;
        }
        // Else leave the value along.
    }
#endif
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
