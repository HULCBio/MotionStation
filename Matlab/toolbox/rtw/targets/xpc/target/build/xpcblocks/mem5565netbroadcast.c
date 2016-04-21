/* mem5565netboardcast.c - S-Func for generation of
 *    network interrupts with the VMIC 5565 Shared memory
 *    board 
 *
 * See also: 
 * mem5565netwrite.c,mem5565netread.c, meme5565netinit.c 
 * and ..\src\xpcvmic5565.c
 */

/* Copyright 1994-2003 The MathWorks, Inc.
 * $Revision: 1.1.6.1 $ $Date: 2003/09/19 22:09:05 $ 
 */


#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         mem5565netbroadcast

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

/* Input Arguments */
#define NUMBER_OF_ARGS          (4)
#define INUMBER_ARG             ssGetSFcnParam(S, 0)
#define NODE_ARG                ssGetSFcnParam(S, 1)
#define SAMPLETIME_ARG          ssGetSFcnParam(S, 2)
#define SLOT_ARG		ssGetSFcnParam(S, 3)


#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)

#define NO_I_WORKS              (3)
#define BASE_ADDR_RFM_CONT 	(0)
#define INTERRUPT_NUMBER 	(1)
#define TARGET_NODE 	        (2)

#define NO_R_WORKS              (0)
#define NO_P_WORKS              (0)


// Macros for command group of board registers that control
// shared memory
//   Note - requires rfmcontrolregisters to be defined
//   as a pointer to bytes (char *)  
#define RFM_BRV    (*((uint8_T *)(rfmcontrolregisters+0x00)))
#define RFM_BID    (*((uint8_T *)(rfmcontrolregisters+0x01)))
#define RFM_NID    (*((uint8_T *)(rfmcontrolregisters+0x04)))
#define RFM_LCSR1  (*((uint32_T *)(rfmcontrolregisters+0x08)))
#define RFM_LISR   (*((uint32_T *)(rfmcontrolregisters+0x10)))

#define RFM_NTD    (*((uint32_T *)(rfmcontrolregisters+0x18)))
#define RFM_NTN    (*((uint8_T *)(rfmcontrolregisters+0x1C)))
#define RFM_NIC    (*((uint8_T *)(rfmcontrolregisters+0x1D)))


static char_T msg[256];


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


    ssSetNumInputPorts(S, 2);

    // Enable port 
    ssSetInputPortWidth(S, 0, 1);
    ssSetInputPortDataType(S, 0, SS_BOOLEAN);
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortRequiredContiguous(S, 0, 1);

    // Data port 
    ssSetInputPortWidth(S, 1, 1);
    ssSetInputPortDataType(S, 1, SS_UINT32);
    ssSetInputPortDirectFeedThrough(S, 1, 1);
    ssSetInputPortRequiredContiguous(S, 1, 1);


    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumPWork(S, NO_P_WORKS);


    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
        return; 

}


static void mdlInitializeSampleTimes(SimStruct *S)
{

    if (mxGetPr(SAMPLETIME_ARG)[0]==-1.0) {
        ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
        ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);

    } 
    else {
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
    int32_T interrupt_number,target_node;

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

    interrupt_number = (int32_T)mxGetPr(INUMBER_ARG)[0];
    ssSetIWorkValue(S, INTERRUPT_NUMBER, (int32_T)interrupt_number);

    target_node = (int32_T)mxGetPr(NODE_ARG)[0];
    ssSetIWorkValue(S, TARGET_NODE, (int32_T)target_node);

#endif

}





static void mdlOutputs(SimStruct *S, int_T tid)
{


#ifndef MATLAB_MEX_FILE

    boolean_T  *u = (boolean_T *)ssGetInputPortSignal(S,0);

    if ( u[0] ) {  // Network interrupt enable? 

        volatile uint8_T  *rfmcontrolregisters = ssGetIWorkValue(S, BASE_ADDR_RFM_CONT);    

        uint32_T  *u = (uint32_T *)ssGetInputPortSignal(S,1);
        int32_T interrupt_number = ssGetIWorkValue(S, INTERRUPT_NUMBER);
        int32_T target_node = ssGetIWorkValue(S, TARGET_NODE);
        uint8_T rfmd_nic  =  (uint8_T)interrupt_number;

        if( interrupt_number > 3 || interrupt_number <0) {  // init channel
            rfmd_nic = 0x7;
        }
        RFM_NTD = u[0];  // data (from port)
        if(target_node < 0) { // Broadcast !
            RFM_NIC = 0x8 | rfmd_nic;
        }
        else {
            RFM_NTN = (uint8_T)target_node;
            RFM_NIC = rfmd_nic;

        }
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
