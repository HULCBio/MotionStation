/* mem5565netinit.c - S-func for initialization of VMIC 5565 
 *                      Reflective memory Board
 *
 * See also:
 * mem5565netwrite.c,mem5565netread.c, meme5565netbroadcast.c
 * and ..\src\xpcvmic5565.c
 */
/* Copyright 1994-2003 The MathWorks, Inc.
 * $Revision: 1.1.6.1 $ $Date: 2003/09/19 22:09:06 $
 */



#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         mem5565netinit

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
// node.Interface.Internal.LCSR1 - Register values
// node.Interface.Internal.LIER - Register values
// node.Interface.Internal.INodeID - Desired NodeID (could be [])
//  

#define NUMBER_OF_ARGS          (4)
#define LCSR1_ARG               ssGetSFcnParam(S, 0)
#define LIER_ARG                ssGetSFcnParam(S, 1)
#define INODEID_ARG             ssGetSFcnParam(S, 2)
#define SLOT_ARG                ssGetSFcnParam(S, 3)

#define SAMP_TIME_IND           (0)
#define BASE_ADDR_IND           (0)

// IWorks storage
#define NO_I_WORKS              (1)
#define IWORK_BASE_ADDR_RFM     (0)


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
#define RFM_LIER   (*((uint32_T *)(rfmcontrolregisters+0x14)))


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


#define REG_RUNTIME_INTCSR   0x68  //  Interrupt Control and Status Register (page 57)



#define MDL_START
static void mdlStart(SimStruct *S)
{
    
#ifndef MATLAB_MEX_FILE
    

    PCIDeviceInfo pciinfo;
    void *Physical1;
    void *Virtual1;

    volatile uint8_T  *localconfigurationregisters;  // Base Address 0
    volatile uint8_T  *rfmcontrolregisters;  // Base Address 2 (define as byte-wide to simplify offset calculation)

    int_T i;

    uint32_T temp;
    uint8_T boardrev;
    uint8_T boardid;
    uint8_T nodeid;
    uint8_T  btemp;
    uint32_T arg_lcsr1;
    uint32_T arg_lier;

    const char *device_name = "VMIC 5565";
    const unsigned short vendor_id = 0x114A;
    const unsigned short device_id = 0x5565;                                           

    static int INIT=1;

    
    if ((int_T)mxGetPr(SLOT_ARG)[0]<0) {
        // look for the PCI-Device
        if (rl32eGetPCIInfo(vendor_id,device_id,&pciinfo)) {
            sprintf(msg,"%s: board not present", device_name);
            ssSetErrorStatus(S,msg);
            return;
        }
    } else {
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
    
    
    // Local_Configuration Register
    // AND Runtime Registers
    Physical1=(void *)pciinfo.BaseAddress[0];
    Virtual1 = rl32eGetDevicePtr(Physical1,0x108, RT_PG_USERREADWRITE);
    localconfigurationregisters=(void *)Physical1;

    //RFM Control and Status Regiser

    Physical1=(void *)pciinfo.BaseAddress[2];
    Virtual1 = rl32eGetDevicePtr(Physical1, 0x40, RT_PG_USERREADWRITE);
    rfmcontrolregisters=(uint8_T *)Physical1;

    ssSetIWorkValue(S, IWORK_BASE_ADDR_RFM, (uint_T)rfmcontrolregisters);    
    
    boardrev = RFM_BRV;
    boardid =  RFM_BID;
    nodeid = RFM_NID;
    //printf("VMIC Board Revision = %d\n",boardrev );
    //printf("VMIC Board Id = 0x%x\n",boardid );
    //printf("VMIC Node Id = 0x%x\n",nodeid);

    // Check for Node ID consistency ,,,
    if (!mxIsEmpty(INODEID_ARG) ) {
        int_T arg_nodeid = (int_T)mxGetPr(INODEID_ARG)[0];
        if ( arg_nodeid != nodeid) {
            sprintf(msg,"NodeID 0x%x differs from board's nodeID 0x%x",arg_nodeid,nodeid );
            ssSetErrorStatus(S,msg);
        }
    }


    arg_lcsr1 = (uint32_T)mxGetPr(LCSR1_ARG)[0];
    arg_lier = (uint32_T)mxGetPr(LIER_ARG)[0];

    temp = RFM_LCSR1;
    //printf("LCSR1 = %x\n",temp);
    temp >>= 20;
    temp &= 0x3;
    //if(temp == 0) { // 64 Mbyte
    //    printf("Reflective Memory size = 64 Mbyte\n");  // Error?
    //}
    //else if (temp == 1) {
    //    printf("Reflective Memory size = 128 Mbyte\n");  // Error?
    //}
    //else {
    //    printf("Unexpected Reflective memory size\n");  // Error?
    //}
 
  
    


    if (INIT) {   // Load time execution 
        uint32_T k;
        //printf("%s init (set) LCSR1 = 0x%x\n",device_name,arg_lcsr1);
        //printf("%s init (set) LIER = 0x%x\n",device_name,arg_lier);        
        //printf("%s init (get) LISR = 0x%x\n",k);
        // initialize registers...     

        RFM_LCSR1 = arg_lcsr1 ^ 0x80000000;  // set LED to user defined 'off' state
        k=RFM_LISR;
        RFM_LIER = 0;  // Disable ALL interrupts (at this point)
        INIT=0;
    } 
    else {   // Run time execution 
        uint32_T k;
 
        RFM_LCSR1 = arg_lcsr1;  
        // initialize control registers...     
        k=RFM_LISR;
        RFM_LIER = arg_lier;  // Enable user-defined interrupt sources.  
    }


#endif
        
}





static void mdlOutputs(SimStruct *S, int_T tid)
{
    
}

static void mdlTerminate(SimStruct *S)
{
#ifndef MATLAB_MEX_FILE
    volatile uint8_T  *rfmcontrolregisters = ssGetIWorkValue(S, IWORK_BASE_ADDR_RFM);   
    RFM_LCSR1 ^= 0x80000000;
    RFM_LIER = 0; // disable interrupts
#endif
}


#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
