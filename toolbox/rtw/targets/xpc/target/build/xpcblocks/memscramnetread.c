/* $Revision: 1.2 $ $Date: 2002/06/06 15:56:43 $ */
/* xpcbyte2any.c - xPC Target, non-inlined S-function driver for *
 *                 byte-unpacking                                */
/* Copyright 1994-2002 The MathWorks, Inc. */

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         memscramnetread

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
#endif

#define CSR0 					0x400001
#define CSR1 					0x400080
#define CSR2 					0x400103
#define CSR3 					0x400182
#define CSR4 					0x400205
#define CSR5 					0x400284
#define CSR6 					0x400307
#define CSR7 					0x400386
#define CSR8 					0x400409
#define CSR9 					0x400488
#define CSR10 					0x40050B
#define CSR11 					0x40058A
#define CSR12 					0x40060D
#define CSR13 					0x40068C
#define CSR14 					0x40070F
#define CSR15 					0x40078E

/* Input Arguments */
#define NUMBER_OF_ARGS          (4)
#define ADDRESS_ARG             ssGetSFcnParam(S, 0)
#define NDWORDS_ARG           	ssGetSFcnParam(S, 1)
#define SAMPLETIME_ARG          ssGetSFcnParam(S, 2)
#define SLOT_ARG				ssGetSFcnParam(S, 3)


#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)

#define NO_I_WORKS              (1)
#define BASE_ADDR_I_IND 		(0)

#define NO_R_WORKS              (0)

#define NO_P_WORKS              (0)

static char_T msg[256];

static int INIT=0;

static void mdlInitializeSizes(SimStruct *S)
{

	#ifndef MATLAB_MEX_FILE
	#include "io_xpcimport.c"
	#include "pci_xpcimport.c"
	#endif

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"Wrong number of input arguments passed.\n"
                "%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);


	ssSetNumInputPorts(S, 0);
   
    ssSetNumOutputPorts(S, 1);
    ssSetOutputPortWidth(S, 0, (int_T)mxGetPr(NDWORDS_ARG)[0]);
    ssSetOutputPortDataType(S, 0, SS_UINT32);

	//ssSetOutputPortWidth(S, 1, 1);
    
    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumPWork(S, NO_P_WORKS);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);


}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    if (mxGetPr(SAMPLETIME_ARG)[0]==-1.0) {
    	ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    	ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
	} else {
		ssSetSampleTime(S, 0, mxGetPr(SAMPLETIME_ARG)[0]);
    	ssSetOffsetTime(S, 0, 0.0);
	}
}

#define MDL_START
static void mdlStart(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE


	PCIDeviceInfo pciinfo;
    void *Physical1;
    void *Virtual1;
    volatile unsigned long *ioaddress32;
    char devName[20];
    int  devId;

	strcpy(devName,"Scramnet SC150+");
	devId=0x4750;
	  
    if ((int_T)mxGetPr(SLOT_ARG)[0]<0) {
        /* look for the PCI-Device */
        if (rl32eGetPCIInfo((unsigned short)0x11B0,(unsigned short)devId,&pciinfo)) {
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
        if (rl32eGetPCIInfoAtSlot((unsigned short)0x11B0,(unsigned short)devId,(slot & 0xff) | ((bus & 0xff)<< 8),&pciinfo)) {
        	sprintf(msg,"%s (bus %d, slot %d): board not present",devName, bus, slot );
            ssSetErrorStatus(S,msg);
            return;
        }
    }

    // show Device Information
    //rl32eShowPCIInfo(pciinfo);
   
    Physical1=(void *)pciinfo.BaseAddress[1];
    Virtual1 = rl32eGetDevicePtr(Physical1, 0x1000000, RT_PG_USERREADWRITE);
    ioaddress32=(void *)Physical1;
       
    ssSetIWorkValue(S, BASE_ADDR_I_IND, (uint_T)ioaddress32);
    
#endif

}





static void mdlOutputs(SimStruct *S, int_T tid)
{


#ifndef MATLAB_MEX_FILE

    uint_T base = ssGetIWorkValue(S, BASE_ADDR_I_IND);
    volatile unsigned long *ioaddress32;
	volatile unsigned short *ioaddress16;
    uint32_T  *y;
	//real_T *y1;
	uint32_T  i;
	uint16_T csr5, csr4;

    ioaddress32=(void *) base;
	ioaddress16=(void *) base;

	/*
	y1= (real_T *)ssGetOutputPortSignal(S,1);

	y1[0]=0.0;

	csr5= ioaddress16[CSR5];

	if ( (csr5 & 0x8000)== 0x8000) {
		
		csr4= ioaddress16[CSR4];

		y1[0]=(real_T)( (((uint32_T)csr5) & 0x007F)<<16 | (uint32_T)csr4 );

	}
	*/

    y= (uint32_T *)ssGetOutputPortSignal(S,0);

    for (i=0; i<(uint32_T)mxGetPr(NDWORDS_ARG)[0]; i++) {
		y[i]=ioaddress32[((uint32_T)mxGetPr(ADDRESS_ARG)[0]/4)+i];
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
