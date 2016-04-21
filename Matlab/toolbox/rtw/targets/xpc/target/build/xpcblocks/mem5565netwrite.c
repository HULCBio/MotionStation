/* mem5565netwrite.c- S-function for writing to the VMIC 5565 
 *   shared memory board.  Applied by the '5565 write' block.
 *   block: xpclib->Shared Memory->VMIC->5565 Write
 *   
 * 
 * See also: 
 * mem5565netinit.c,mem5565netread.c, meme5565netbroadcast.c 
 * and ..\src\xpcvmic5565.c
 */

/* Copyright 1994-2003 The MathWorks, Inc.
 * $Revision: 1.1.6.1 $ $Date: 2003/09/19 22:09:08 $         
 */


#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         mem5565netwrite

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

// Input Arguments (s-function mask)
#define NUMBER_OF_ARGS          (5)
#define ADDRESS_ARG             ssGetSFcnParam(S, 0)
#define NDWORDS_ARG           	ssGetSFcnParam(S, 1)
#define SAMPLETIME_ARG          ssGetSFcnParam(S, 2)
#define SLOT_ARG		ssGetSFcnParam(S, 3)
#define ERROR_STATUS_ARG        ssGetSFcnParam(S, 4)

#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)

#define NO_I_WORKS              (2)
#define BASE_ADDR_I_MEMORY 	(0)
#define BASE_ADDR_RFM_CONT 	(1)

#define NO_R_WORKS              (0)
#define NO_P_WORKS              (0)


#define MEM_SIZE_64MBYTE        0x4000000
#define MEM_SIZE_128MBYTE       0x8000000

// Macros for command group of board registers that control
// shared memory
//   Note - requires rfmcontrolregisters to be defined as
//   a pointer to bytes (char *)
#define RFM_BRV    (*((uint8_T *)(rfmcontrolregisters+0x00)))
#define RFM_BID    (*((uint8_T *)(rfmcontrolregisters+0x01)))
#define RFM_NID    (*((uint8_T *)(rfmcontrolregisters+0x04)))
#define RFM_LCSR1  (*((uint32_T *)(rfmcontrolregisters+0x08)))
#define RFM_LISR   (*((uint32_T *)(rfmcontrolregisters+0x10)))


static char_T msg[256];


static void mdlInitializeSizes(SimStruct *S)
{
   int_T status_port;

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


    // Grow a status port, if necessary 
    status_port = (int_T)*mxGetPr(ERROR_STATUS_ARG);
    if(status_port) {
        if (!ssSetNumOutputPorts(S,1)) return;
        ssSetOutputPortWidth(S, 1, 1);
        ssSetOutputPortDataType(S, 1, SS_UINT32);
        ssSetNumSampleTimes(S, 1);
    }
    else {
        ssSetNumOutputPorts(S, 0);
    }
   
    ssSetNumInputPorts(S, 1);
    ssSetInputPortWidth(S, 0, (int_T)mxGetPr(NDWORDS_ARG)[0]);
    ssSetInputPortDataType(S, 0, SS_UINT32);
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortRequiredContiguous(S, 0, 1);

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
    volatile uint8_T  *rfmcontrolregisters;  // Base Address 2 (define as byte-wide to simplify offset calculation)
    uint32_T mem_size;

    const char *device_name = "VMIC 5565";
    const unsigned short vendor_id = 0x114A;
    const unsigned short device_id = 0x5565; 
    
    
    if ((int_T)mxGetPr(SLOT_ARG)[0]<0) {
        /* look for the PCI-Device */
        if (rl32eGetPCIInfo(vendor_id,device_id,&pciinfo)) {
            sprintf(msg,"%s: board not present", device_name);
            ssSetErrorStatus(S,msg);
            return;
        }
    } 
    else {
        int_T bus;
        int_T slot;
        if (mxGetN(SLOT_ARG) == 1) {
            bus = 0;
            slot = (int_T)mxGetPr(SLOT_ARG)[0];
        } else {
            bus = (int_T)mxGetPr(SLOT_ARG)[0];
            slot = (int_T)mxGetPr(SLOT_ARG)[1];
        }
        // look for the PCI-Device
        if (rl32eGetPCIInfoAtSlot(vendor_id,device_id,(slot & 0xff) | ((bus & 0xff)<< 8),&pciinfo)) {
            sprintf(msg,"%s (bus %d, slot %d): board not present",device_name, bus, slot );
            ssSetErrorStatus(S,msg);
            return;
        }
    }

    Physical1=(void *)pciinfo.BaseAddress[2];
    Virtual1 = rl32eGetDevicePtr(Physical1, 0x40, RT_PG_USERREADWRITE);
    rfmcontrolregisters=(uint8_T *)Physical1;

    ssSetIWorkValue(S, BASE_ADDR_RFM_CONT, (uint_T)rfmcontrolregisters);

    // Check memory size and reserve as needed

    mem_size = (((RFM_LCSR1 >> 20) & 0x03) == 1)? MEM_SIZE_64MBYTE : MEM_SIZE_128MBYTE;


    Physical1=(void *)pciinfo.BaseAddress[3];
    Virtual1 = rl32eGetDevicePtr(Physical1, mem_size, RT_PG_USERREADWRITE);
    ioaddress32=(void *)Physical1;
       
    ssSetIWorkValue(S, BASE_ADDR_I_MEMORY, (uint_T)ioaddress32);


    //printf("Reserved Memory area = %x\n",mem_size);
    // show Device Information
    //rl32eShowPCIInfo(pciinfo);
   
    
#endif

}





static void mdlOutputs(SimStruct *S, int_T tid)
{


#ifndef MATLAB_MEX_FILE

    uint_T base = ssGetIWorkValue(S, BASE_ADDR_I_MEMORY);
    volatile uint8_T  *rfmcontrolregisters = ssGetIWorkValue(S, BASE_ADDR_RFM_CONT);    
    volatile unsigned long *ioaddress32;
    uint32_T  *u = (uint32_T *)ssGetInputPortSignal(S,0);
    uint32_T  i;

    ioaddress32=(void *) base;

    for (i=0; i<(uint32_T)mxGetPr(NDWORDS_ARG)[0]; i++) { 
        ioaddress32[((uint32_T)mxGetPr(ADDRESS_ARG)[0]/4)+i]=u[i];
    }



    // Check for an error status and write to port (if available)

    if( ssGetNumOutputPorts(S) > 0) {
      
        u= (uint32_T *)ssGetOutputPortSignal(S,0);
        u[0] = RFM_LISR;
        RFM_LISR = u[0] & 0xFFFFC030; // clear status bits (but leave rest alone)
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
