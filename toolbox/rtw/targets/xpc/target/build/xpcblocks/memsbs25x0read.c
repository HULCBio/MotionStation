/* memsbs25x0read.c - S-func for Reading from SBS 2510/2510 Shared
 *  Memory board.
 *
 * See also:
 * memsbs25x0write.c,memsbs25x0read.c
 * and ..\src\xpcsbs25x0.c
 */

/* Copyright 1994-2004 The MathWorks, Inc.
 * $Revision: 1.1.6.1 $ $Date: 2004/01/22 18:35:16 $
 */


#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         memsbs25x0read

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
//  partition(1).Internal.Address
//  partition(1).Internal.NDwords
//  ts 
//  pci
//  errport
#define NUMBER_OF_ARGS          (5)
#define ADDRESS_ARG             ssGetSFcnParam(S, 0)
#define SIZEOF_ARG           	  ssGetSFcnParam(S, 1)
#define SAMPLETIME_ARG          ssGetSFcnParam(S, 2)
#define PCI_SLOT_ARG		        ssGetSFcnParam(S, 3)
#define ERROR_STATUS_ARG        ssGetSFcnParam(S, 4)         


#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)

// IWorks storage
#define NO_I_WORKS              (2)
#define IWORD_SBS_CSR_BASE_M 	  (0)   // Control Register Base
#define IWORK_SBS_MEMORY_M      (1)   // Broadcast Memory Base

#define NO_R_WORKS              (0)
#define NO_P_WORKS              (0)

/* Shared Memory Map(s)     */
/* 64 MByte Option  0x0 to 0x3FF FFFF */
/* 128 MByte Option 0x0 to 0x7FF FFFF */
#define MEM_SIZE_64MBYTE        0x4000000
#define MEM_SIZE_128MBYTE       0x8000000

// Macros for command group of board registers that control
// shared memory
//   Note - requires rfmcontrolregisters to be defined
//   as a pointer to bytes (char *)  
#define VENDOR_ID                (uint16_T)(0x108A)  

#define CSR_BT_REG_CTRL          (*((volatile uint8_T *)(csr_base_address+0x00)))
#define CSR_BT_REG_IRQ           (*((volatile uint8_T *)(csr_base_address+0x01)))
#define CSR_BT_REG_MEM_SIZE      (*((volatile uint8_T *)(csr_base_address+0x02)))
#define CSR_BT_REG_RESET         (*((volatile uint8_T *)(csr_base_address+0x03)))
#define CSR_BT_REG_WRIRQ         (*((volatile uint32_T *)(csr_base_address+0x04)))
#define CSR_BT_REG_TRANS_RX_ERR  (*((volatile uint8_T *)(csr_base_address+0x20)))
#define CSR_BT_REG_LINK_STATUS   (*((volatile uint8_T *)(csr_base_address+0x24)))
#define CSR_BT_REG_TX_ERR        (*((volatile uint8_T *)(csr_base_address+0x28)))
#define CSR_BT_REG_LINK_ID       (*((volatile uint8_T *)(csr_base_address+0x2C)))


#define MSG_BUFF_SIZE 256
static char msg[MSG_BUFF_SIZE];


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

    ssSetNumInputPorts(S, 0);
    
    // Grow if necessary 
    status_port = (int_T)*mxGetPr(ERROR_STATUS_ARG);
    if(status_port) {
        if (!ssSetNumOutputPorts(S,2)) return;
        ssSetOutputPortWidth(S, 1, 1);
        ssSetOutputPortDataType(S, 1, SS_UINT8);
        ssSetNumSampleTimes(S, 1);
    }
    else {
        ssSetNumOutputPorts(S, 1);
    }

    // set type of data port (required)
    ssSetOutputPortWidth(S, 0, (int_T)mxGetPr(SIZEOF_ARG)[0]>>2);
    ssSetOutputPortDataType(S, 0, SS_UINT32);
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
    void *Physical;
    void *Virtual;

    volatile uint32_T *net_ram;
	  volatile uint8_T  *csr_base_address;  // Base Address 2 (define as byte-wide to simplify offset calculation)
    unsigned long  memwindow;
 
    uint32_T mem_size;
    const char *device_name = "SBS Tech 25x0";
    
    if ((int_T)mxGetPr(PCI_SLOT_ARG)[0]<0) {
        // look for the PCI-Device
		  if (rl32eGetPCIInfo(VENDOR_ID,0x100,&pciinfo)) {
			  if (rl32eGetPCIInfo(VENDOR_ID,0x101,&pciinfo)) {
				  if (rl32eGetPCIInfo(VENDOR_ID,0x102,&pciinfo)) {
					  if (rl32eGetPCIInfo(VENDOR_ID,0x103,&pciinfo)) {
              sprintf(msg,"%s: board not present",device_name);
              ssSetErrorStatus(S,msg);
						  return;
					  }
				  }
			  }
		  }
    } else {
      int_T bus, slot;
      if (mxGetN(PCI_SLOT_ARG) == 1) {
          bus = 0;
          slot = (int_T)mxGetPr(PCI_SLOT_ARG)[0];
      } else {
          bus = (int_T)mxGetPr(PCI_SLOT_ARG)[0];
          slot = (int_T)mxGetPr(PCI_SLOT_ARG)[1];
      }
      slot = (slot & 0xff) | ((bus & 0xff)<< 8);

      // look for the PCI-Device
      if (rl32eGetPCIInfoAtSlot(VENDOR_ID,0x100,slot,&pciinfo)) {
	      if (rl32eGetPCIInfoAtSlot(VENDOR_ID,0x101,slot,&pciinfo)) {
          if (rl32eGetPCIInfoAtSlot(VENDOR_ID,0x102,slot,&pciinfo)) {
            if (rl32eGetPCIInfoAtSlot(VENDOR_ID,0x103,slot,&pciinfo)) {
                sprintf(msg,"%s (bus %d, slot %d): board not present",device_name, bus, slot );
                ssSetErrorStatus(S,msg);
                return;
            }
          }
        }
      }
    }

    Physical =(void *)(pciinfo.BaseAddress[0] & 0xFFFFFFF0);
    Virtual = rl32eGetDevicePtr(Physical,0x2C, RT_PG_USERREADWRITE);
    csr_base_address=(volatile uint8_T *)Physical;
    ssSetIWorkValue(S, IWORD_SBS_CSR_BASE_M,(uint32_T)csr_base_address);

    // Reserve memory (
    // Fetch 
    switch( CSR_BT_REG_MEM_SIZE ) {
    case 0x20 :  // 8 MByte
      memwindow = 0x800000;
      break;
    case 0x10 :  // 4 MByte
      memwindow = 0x400000;
      break;
    case 0x08 :  // 2 MByte
      memwindow = 0x200000;
      break;
    case 0x04:  // 1 MByte
      memwindow = 0x100000;
      break;
    case 0x02:  // 512 KByte
      memwindow = 0x080000;
      break;
    case 0x01:  // 256 KByte
      memwindow = 0x040000;
      break;
    default:
      sprintf(msg,"SBS25x0 Broadcast Memory - Unknown Memory Size\n");
      ssSetErrorStatus(S,msg);
      return;
      return;
    }

    Physical=(void *)(pciinfo.BaseAddress[1] & 0xFFFFFFF0);
    Virtual = rl32eGetDevicePtr(Physical, memwindow, RT_PG_USERREADWRITE);
    net_ram =(volatile uint32_T *)Physical;
    ssSetIWorkValue(S, IWORK_SBS_MEMORY_M,(uint32_T)net_ram);
    
#endif

}





static void mdlOutputs(SimStruct *S, int_T tid)
{


#ifndef MATLAB_MEX_FILE
    uint32_T i;
    volatile uint32_T *net_ram = (volatile uint32_T *)ssGetIWorkValue(S, IWORK_SBS_MEMORY_M);
	  volatile uint8_T  *csr_base_address = (volatile uint8_T  *)ssGetIWorkValue(S, IWORD_SBS_CSR_BASE_M);    
    uint32_T  *u = (uint32_T *)ssGetOutputPortSignal(S,0);



    for (i=0; i<((uint32_T)mxGetPr(SIZEOF_ARG)[0]/4); i++) { 
        u[i] = net_ram[((uint32_T)mxGetPr(ADDRESS_ARG)[0]/4)+i];
    }


    if( ssGetNumOutputPorts(S) > 1) {
        uint8_T  *ps = (uint8_T *)ssGetOutputPortSignal(S,1);
        ps[0] = CSR_BT_REG_LINK_STATUS;
        CSR_BT_REG_LINK_STATUS = ps[0] & 0xFE;  // Clear Bits (but don't ever do a link reset!) 
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
