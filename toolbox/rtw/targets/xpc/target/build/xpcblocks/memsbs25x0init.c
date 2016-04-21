/* memsbs25x0init.c - S-func for initialization of SBS Technologies                   
 *                      Broadcast memory board(s) sbs2500 and sbs2510
 *
 * This file configures registers, including WIT table
 *
 * See also:
 * memsbs25x0read.c,memsbs25x0write.c
 * and ..\src\xpcsbs25x0.c
 */
/* Copyright 1994-2004 The MathWorks, Inc.
 * $Revision: 1.1.6.2 $ $Date: 2004/02/06 00:32:11 $
 */

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         memsbs25x0init

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
#include         "time_xpcimport.h"

#endif

// Input Arguments (s-function mask)
// node.Interface.Internal. - Register values
// WITTable - table of bit/addreess for WIT Table
//
//  
//  BT_REG_CTRL(0x0) - YES -  BT_REG_CTRL_ARG
//  BT_REG_IRQ(0x1)  -??
//  BT_REG_MEM_SEZE  - READ and compare to BT_REG_MEM_SIZE
//  PCI_SLOT_ARG     - 

#define NUMBER_OF_ARGS          (5)
#define BT_REG_CTRL_ARG         ssGetSFcnParam(S, 0)
#define BT_REG_MEM_ARG          ssGetSFcnParam(S, 1)
#define WITTABLE_ARG            ssGetSFcnParam(S, 2)
#define SLOTID_ARG              ssGetSFcnParam(S, 3)
#define PCI_SLOT_ARG            ssGetSFcnParam(S, 4)

#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)

// IWorks storage
#define NO_I_WORKS              (1)
#define IWORK_BASE_CSR_BASE     (0)


#define NO_R_WORKS              (0)
#define NO_P_WORKS              (0)

// Macros for command group of board registers that control
// shared memory
//   Note - requires rfmcontrolregisters to be defined
//   as a pointer to bytes (char *)  
#define VENDOR_ID                 (uint16_T)(0x108A) 

#define CSR_BT_REG_CTRL          (*((volatile uint8_T *)(csr_base_address+0x00)))
#define CSR_BT_REG_IRQ           (*((volatile uint8_T *)(csr_base_address+0x01)))
#define CSR_BT_REG_MEM_SIZE      (*((volatile uint8_T *)(csr_base_address+0x02)))
#define CSR_BT_REG_RESET         (*((volatile uint8_T *)(csr_base_address+0x03)))
#define CSR_BT_REG_WRIRQ         (*((volatile uint32_T *)(csr_base_address+0x04)))
#define CSR_BT_REG_TRANS_RX_ERR  (*((volatile uint8_T *)(csr_base_address+0x20)))
#define CSR_BT_REG_LINK_STATUS   (*((volatile uint8_T *)(csr_base_address+0x24)))
#define CSR_BT_REG_TX_ERR        (*((volatile uint8_T *)(csr_base_address+0x28)))
#define CSR_BT_REG_LINK_ID       (*((volatile uint8_T *)(csr_base_address+0x2C)))


// Some useful DEFS
#define CTRL_WRIIRQ_EN  (0x08)
#define CTRL_ERRIRQ_EN  (0x04)

#define MSG_BUFF_SIZE 256
static char msg[MSG_BUFF_SIZE];


#ifndef MATLAB_MEX_FILE
int link_reset(volatile uint8_T *csr_base_address, uint8_T ubt_reg_ctrl)
{
    uint8_T control;
    double timeOut, timeOut1, startTime;

    CSR_BT_REG_CTRL = 0x00;

    // clear interrupt
    CSR_BT_REG_IRQ = 0x01;
    CSR_BT_REG_IRQ = 0x10;
    CSR_BT_REG_IRQ = 0x08;

    // clear status
    CSR_BT_REG_LINK_STATUS = 0x20;
    CSR_BT_REG_LINK_STATUS = 0x10;
    CSR_BT_REG_LINK_STATUS = 0x08;
    CSR_BT_REG_LINK_STATUS = 0x04;
    CSR_BT_REG_LINK_STATUS = 0x02;

    // write control register
    control = (ubt_reg_ctrl & 0x23);  // Enable these bits if specified by user
    // (rx_enable) (tx_enable) or loop_back (only)
    CSR_BT_REG_CTRL = control;

   // printf("first reset %x\n",ubt_reg_ctrl);

        // initiate LINK_OK reset
    CSR_BT_REG_LINK_STATUS = 0x01;


    // poll LINK_OK bit until it gets 1 (time out after 1ms)
    startTime= rl32eGetTicksDouble();
    timeOut=0;
    while ( !(CSR_BT_REG_LINK_STATUS & 0x01) ) {
        if ( rl32eETimeDouble(rl32eGetTicksDouble(),startTime) > 0.001 ) {
            timeOut=1;
            break;
        }
    }

    if (timeOut) {

        //printf("second reset\n");

        CSR_BT_REG_CTRL = 0x00;
        CSR_BT_REG_RESET = 0x01;
        CSR_BT_REG_CTRL = control;

        // poll LINK_OK bit until it is 1 (time out after 1ms)

        startTime= rl32eGetTicksDouble();
        timeOut1=0;
        while ( !(CSR_BT_REG_LINK_STATUS & 0x01) ) {
            if ( rl32eETimeDouble(rl32eGetTicksDouble(),startTime) > 0.001 ) {
                timeOut1=1;
                break;
            }
        }
        if (timeOut1) {
            printf("Error - SBS25x0 Link is down\n");
            return -1;
        }

    }

    // disable LINK_UP and LINK_DOWN interrupt
    CSR_BT_REG_IRQ = 0x10;
    CSR_BT_REG_IRQ = 0x08;


    if (!(ubt_reg_ctrl&0x20)) {  // Not loopback

        if ( CSR_BT_REG_LINK_ID == 0x3f) {    // node2node
            control |= 0x10;
            CSR_BT_REG_CTRL = control;
        }
    }
    return 0;

}
#endif

static void mdlInitializeSizes(SimStruct *S)
{
    
#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "pci_xpcimport.c"
#include "time_xpcimport.c"
#include "util_xpcimport.c"  // Required for xpceIsModelInit()
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
    ssSetNumOutputPorts(S, 0);
    
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
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, FIXED_IN_MINOR_STEP_OFFSET);
}


// #define REG_RUNTIME_INTCSR   0x68  //  Interrupt Control and Status Register (page 57)

#define MDL_START

static void mdlStart(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE

    PCIDeviceInfo pciinfo;
    void *Physical;
    void *Virtual;
    unsigned long  memwindow;


    volatile uint32_T  *wit_base_address;
    volatile uint32_T  *net_ram;
	  volatile uint8_T   *csr_base_address;  // Base Address 2 (define as byte-wide to simplify offset calculation)

   // int_T i;

    uint8_T arg_reg_ctrl = (uint8_T)(mxGetPr(BT_REG_CTRL_ARG)[0]);
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

    // Configuration and Status Register

    Physical =(void *)(pciinfo.BaseAddress[0] & 0xFFFFFFF0);
    Virtual = rl32eGetDevicePtr(Physical,0x2C, RT_PG_USERREADWRITE);
    csr_base_address=(void *)Physical;
    //printf("SBS25x0 Control Registers Location = %x\n",pciinfo.BaseAddress[0]);

    ssSetIWorkValue(S, IWORK_BASE_CSR_BASE, (uint_T)csr_base_address);  // (save if  I need in mdlterminate)

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
    }


    //printf("SBS Memory size = %d KBytes\n",memwindow>>10);

    // Broadcast Memory Location 
    Physical=(void *)(pciinfo.BaseAddress[1] & 0xFFFFFFF0);
    Virtual = rl32eGetDevicePtr(Physical, memwindow, RT_PG_USERREADWRITE);
    //printf("SBS25x0 Broadcast Memory Location = %X\n",pciinfo.BaseAddress[1]);
    net_ram = Physical;

    // WIT Memory Location 
    Physical=(void *)(pciinfo.BaseAddress[2] & 0xFFFFFFF0);
    Virtual = rl32eGetDevicePtr(Physical, memwindow, RT_PG_USERREADWRITE);
    //printf("SBS25x0 WIT Location = %X\n",pciinfo.BaseAddress[2]);
    wit_base_address = Physical;


    // Check for user specified memory size (actual memory should be > than value specified by customer)


    if (!mxIsEmpty(BT_REG_MEM_ARG)) {
      if (CSR_BT_REG_MEM_SIZE <  (uint8_T)(mxGetPr(BT_REG_MEM_ARG)[0]) ) {
          sprintf(msg,"Avail. broadcast memory less than required by model\n");
          ssSetErrorStatus(S,msg);
          return;
      }
    }
    if (!xpceIsModelInit() ) {   
      //Start time Initialization -----------------------

    //  printf("+I Bits in CSR = 0x%x\n",(int)CSR_BT_REG_CTRL);  
      if (!( CSR_BT_REG_LINK_STATUS & 0x01)) {
        double startTime = rl32eGetTicksDouble();
        int_T timeOut=0;
        CSR_BT_REG_LINK_STATUS = 0x01;
        while ( !(CSR_BT_REG_LINK_STATUS & 0x01) ) {
             if ( rl32eETimeDouble(rl32eGetTicksDouble(),startTime) > 0.001 ) {
                timeOut=1;
                break;
            }
        }
        if(timeOut) {
          sprintf(msg,"Link failure SBS25x0 - check network");
          ssSetErrorStatus(S,msg);
          return;
        }
      }
      if ( CSR_BT_REG_LINK_ID == 0x3f) {
        printf("Broadcast Memory node up. Node-to-Node, IRQ: %d\n",pciinfo.InterruptLine);
      }
      else {
        printf("Broadcast Memory node up. Slot+Port ID %d, IRQ: %d\n",CSR_BT_REG_LINK_ID,pciinfo.InterruptLine);
      }
 
    }
    else {
      // Load time Initialization -----------------------
      int k;

      if( link_reset(csr_base_address,0x23) )  {  // First try loopback mode.  
        sprintf(msg,"Loopback failure SBS25x0 - check board" );
        ssSetErrorStatus(S,msg);
        return;
      }
      for (k=0; k<memwindow/4; k++) {
        net_ram[k]=0;
      }
      for (k=0; k<memwindow/4; k++) {
        wit_base_address[k]=0;
      }
      rl32eWaitDouble(0.001);

      if( !(arg_reg_ctrl & 0x20) ) 
      {     // link status (but not in loopback mode!)

          if( link_reset(csr_base_address,0x03) ) {  // Next test link itself
            //printf("Link test of SBS25x0 board FAILED, check cables\n");
            //return;
            sprintf(msg,"Link failure SBS25x0 - check cabling" );
            ssSetErrorStatus(S,msg);
            return;

          } 
          rl32eWaitDouble(0.001);
        // printf("-I Bits in CSR = 0x%x\n",(int)CSR_BT_REG_CTRL);
      } 

     // clear interrupt
      CSR_BT_REG_IRQ = 0x01;
      CSR_BT_REG_IRQ = 0x01;
      CSR_BT_REG_IRQ = 0x10;
      CSR_BT_REG_IRQ = 0x08;

      // clear status
      CSR_BT_REG_LINK_STATUS= 0x20;  //(remove these to make it work in node2node(?)
      CSR_BT_REG_LINK_STATUS= 0x10;
      CSR_BT_REG_LINK_STATUS= 0x08;
      CSR_BT_REG_LINK_STATUS= 0x04;
      CSR_BT_REG_LINK_STATUS= 0x02;

  // Load WIT table (
      if (!mxIsEmpty(WITTABLE_ARG) ) {
            uint32_T wit_mask,wit_addr;
            const double *wit_entries = mxGetPr(WITTABLE_ARG);
            int_T nentries = (int_T)mxGetNumberOfElements(WITTABLE_ARG);  // [mask addr]
            int_T i;
            printf("WIT Table");
            if(nentries & 0x01) {
               sprintf(msg,"Illegal WIT Table (mask-addr pairs)");
               ssSetErrorStatus(S,msg);
               return;
            }
            for(i=0; i<nentries; i+=2) {
                wit_mask = (uint32_T)(*wit_entries++);
                wit_addr = (uint32_T)(*wit_entries++);
                wit_base_address[wit_addr/4] |= wit_mask;
                printf("WIT Address = %d, WIT Mask = %d\n",wit_addr,wit_mask);
            }
      }
      CSR_BT_REG_CTRL |= arg_reg_ctrl;  // loaded and ready
   }

  //  printf("Link ID = %x\n",(int)CSR_BT_REG_LINK_ID);
  //  printf("Link Status = %x\n",(int)CSR_BT_REG_LINK_STATUS);

#endif
        
}


static void mdlOutputs(SimStruct *S, int_T tid)
{
#ifndef MATLAB_MEX_FILE
  	volatile uint8_T  *csr_base_address = (volatile uint8_T  *)ssGetIWorkValue(S, IWORK_BASE_CSR_BASE);  
        // Check for an error status and write to port (if available)
   /* if (!( CSR_BT_REG_LINK_STATUS & 0x01)) {
       // printf("Link is down......0x%x\n", CSR_BT_REG_LINK_STATUS);
      CSR_BT_REG_LINK_STATUS = 0x01;
    }  (inserted for host to host) */
#endif
}

static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
   // volatile uint8_T  *csr_base_address = ssGetIWorkValue(S, IWORK_BASE_CSR_BASE);   

#endif
}


#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
