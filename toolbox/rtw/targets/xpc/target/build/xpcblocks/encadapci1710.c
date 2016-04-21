/* $Revision: 1.7.4.1 $ $Date: 2004/04/08 21:02:14 $*/
/* encadapci1710.c - xPC Target, non-inlined S-function driver for incremental encoder firmware of APCI-1710 from ADDI-DATA  */
/* Copyright 1996-2003 The MathWorks, Inc.
*/


#undef S_FUNCTION_NAME
#define S_FUNCTION_NAME encadapci1710

#include <stddef.h>
#include <stdlib.h>

#include "tmwtypes.h"
#include "simstruc.h"

#ifdef MATLAB_MEX_FILE
#include "mex.h"
#else
#include <windows.h>
#include "io_xpcimport.h"
#include "pci_xpcimport.h"
#endif



/* Input Arguments */
#define NUMBER_OF_ARGS                  (7)
#define RESET_ARG                       ssGetSFcnParam(S,0)
#define MODULE_ARG                      ssGetSFcnParam(S,1)
#define MODE_ARG                        ssGetSFcnParam(S,2)
#define HYST_ARG                        ssGetSFcnParam(S,3)
#define RES_ARG                         ssGetSFcnParam(S,4)
#define SAMP_TIME_ARG                   ssGetSFcnParam(S,5)
#define PCI_DEV_ARG                     ssGetSFcnParam(S,6)

#define RESET_IND                       (0)
#define MODULE_IND                      (0)
#define MODE_IND                        (0)
#define HYST_IND                        (0)
#define RES_IND                         (0)
#define SAMP_TIME_IND                   (0)
#define BASE_ADDR_IND                   (0)

#define NO_I_WORKS                      (4)
#define BASE_ADDR_I_IND                 (0)
#define MODE_I_IND                      (1)
#define INDEXOK_I_IND                   (2)
#define TURNS_I_IND                     (3)


#define NO_R_WORKS                      (1)
#define RES_R_IND                       (0)

#define PI                              3.14159265358979


static char_T msg[256];

static void mdlInitializeSizes(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "pci_xpcimport.c"
#endif


#ifdef MATLAB_MEX_FILE
    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"Wrong number of input arguments passed.\n7 arguments are expected\n");
        ssSetErrorStatus(S,msg);
        return;
    }
    if ( mxGetM(MODULE_ARG)!=1 | mxGetN(MODULE_ARG)!=1 ) {
        sprintf(msg,"counter argument must be scalar\n");
        ssSetErrorStatus(S,msg);
        return;
    }
    if ( mxGetM(MODE_ARG)!=1 | mxGetN(MODE_ARG)!=1 ) {
        sprintf(msg,"mode argument must be scalar\n");
        ssSetErrorStatus(S,msg);
        return;
    }
    if ( mxGetM(HYST_ARG)!=1 | mxGetN(HYST_ARG)!=1 ) {
        sprintf(msg,"hystheresis argument must be scalar\n");
        ssSetErrorStatus(S,msg);
        return;
    }
    if ( mxGetM(RES_ARG)!=1 | mxGetN(RES_ARG)!=1 ) {
        sprintf(msg,"resolution argument must be scalar\n");
        ssSetErrorStatus(S,msg);
        return;
    }
    if ( mxGetM(SAMP_TIME_ARG)!=1 | mxGetN(SAMP_TIME_ARG)!=1 ) {
        sprintf(msg,"sample time argument must be scalar\n");
        ssSetErrorStatus(S,msg);
        return;
    }
    if ( mxGetM(PCI_DEV_ARG)!=1 | mxGetN(PCI_DEV_ARG)!=1 ) {
        sprintf(msg,"resolution argument must be scalar\n");
        ssSetErrorStatus(S,msg);
        return;
    }

#endif

    /* Set-up size information */
    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);
    ssSetNumOutputs(S, 2);
    ssSetNumInputs(S, 0);
    ssSetDirectFeedThrough(S, 0); /* Direct dependency on inputs */
    ssSetNumSampleTimes(S,1);
    ssSetNumInputArgs(S, NUMBER_OF_ARGS);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumPWork(         S, 0);   /* number of pointer work vector elements*/
    ssSetNumModes(         S, 0);   /* number of mode work vector elements   */
    ssSetNumNonsampledZCs( S, 0);   /* number of nonsampled zero crossings   */
    ssSetOptions(          S, 0);   /* general options (SS_OPTION_xx)        */

}

/* Function to initialize sample times */
static void mdlInitializeSampleTimes(SimStruct *S)
{

    ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME_ARG)[SAMP_TIME_IND]);
    if (mxGetN((SAMP_TIME_ARG))==1) {
        ssSetOffsetTime(S, 0, 0.0);
    } else {
        ssSetOffsetTime(S, 0, mxGetPr(SAMP_TIME_ARG)[1]);
    }

}


static void mdlInitializeConditions(real_T *x0, SimStruct *S)
{
    uint_T base_addr;
    int_T module, mode, modeout, hyst, turns;
    real_T res;

#ifndef MATLAB_MEX_FILE
    PCIDeviceInfo pciinfo;
#endif

    /* Store the base address, the number of channels,
     * in int_Teger workspace vector.
     */

    module=(int_T)mxGetPr(MODULE_ARG)[MODULE_IND];
    //printf("%d\n",module);
    mode=(int_T)mxGetPr(MODE_ARG)[MODE_IND];
    hyst=(int_T)mxGetPr(HYST_ARG)[HYST_IND];
    res=mxGetPr(RES_ARG)[RES_IND];
    ssSetRWorkValue(S,RES_R_IND , res);
    ssSetIWorkValue(S,INDEXOK_I_IND , 0);


#ifndef MATLAB_MEX_FILE

    if ((int_T)mxGetPr(PCI_DEV_ARG)[0]<0) {
        // look for the PCI-Device
        if (rl32eGetPCIInfo(0x10E8,0x818F,&pciinfo)) {
            sprintf(msg,"APCI-1710: board not present");
            ssSetErrorStatus(S,msg);
            return;
        }
    } else {
        int_T bus, slot;
        if (mxGetN(PCI_DEV_ARG) == 1) {
            bus = 0;
            slot = (int_T)mxGetPr(PCI_DEV_ARG)[0];
        } else {
            bus = (int_T)mxGetPr(PCI_DEV_ARG)[0];
            slot = (int_T)mxGetPr(PCI_DEV_ARG)[1];
        }
        // look for the PCI-Device
        if (rl32eGetPCIInfoAtSlot(0x10E8,0x818F,(slot & 0xff) | ((bus & 0xff)<< 8),&pciinfo)) {
            sprintf(msg,"APCI-1710 (bus &d, slot %d): board not present", bus, slot );
            ssSetErrorStatus(S,msg);
            return;
        }
    }

    // show Device Information
    // rl32eShowPCIInfo(pciinfo);

    base_addr=64*(module-1)+pciinfo.BaseAddress[2];

    ssSetIWorkValue(S, BASE_ADDR_I_IND, (int_T)base_addr);

    if (mode==1) {
        modeout=0x5;
        ssSetIWorkValue(S,MODE_I_IND , 1);
    } else if (mode==2) {
        modeout=0x1;
        ssSetIWorkValue(S,MODE_I_IND , 2);
    } else if (mode==3) {
        modeout=0x0;
        ssSetIWorkValue(S,MODE_I_IND , 4);
    }


    if (hyst==2) {
        modeout=modeout | 0x20;
    }

    modeout=modeout | 0x400;            // SET-INDX

    if (((int_T)mxGetPr(RESET_ARG)[RESET_IND]==1) ) {
        modeout=modeout | 0x800;        // CLR-INDX
    }
    //printf("%x\n",modeout);

    rl32eOutpW((unsigned short)(base_addr+20), (unsigned short)modeout);


#endif


}

/* Function to compute outputs */
static void mdlOutputs(real_T *y, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
    uint_T base_addr = ssGetIWorkValue(S, BASE_ADDR_I_IND);
    //int_T module = ssGetIWorkValue(S, MODULE_I_IND);
    int_T mode = ssGetIWorkValue(S, MODE_I_IND);
    real_T res = ssGetRWorkValue(S, RES_R_IND);
    int_T indexok=ssGetIWorkValue(S,INDEXOK_I_IND);
    int_T turns=ssGetIWorkValue(S,TURNS_I_IND);
    int_T countval, statval, index;
    real_T countfloat;


#ifndef MATLAB_MEX_FILE


    rl32eOutpB((unsigned short)(base_addr+0),0x1);                      // strobe counter to latch 1
    countval=rl32eInpW((unsigned short)(base_addr+4)) | (rl32eInpW((unsigned short)(base_addr+6)) << 16);         // read latch
    if ((int_T)mxGetPr(RESET_ARG)[RESET_IND]==1) {
        if (!indexok) {
            if ( (rl32eInpW((unsigned short)(base_addr+12)) & 0x1) ==0x1) {                 // read index status
                indexok=1;
                ssSetIWorkValue(S,INDEXOK_I_IND , indexok);
            }
        }

        countfloat=countval/res*2.0*PI/mode;
        //printf("%f\n",countfloat);
        y[0]=countfloat;
        y[1]=(double)indexok;
    } else {
        //statval=rl32eInpB(base_addr+24);                 // read status
        index=rl32eInpW((unsigned short)(base_addr+12));
        if ( (index & 0x1) ==0x1 ) {                    // index crossed?
            if (!indexok) {
                indexok=1;
                turns=0;
                ssSetIWorkValue(S,INDEXOK_I_IND , indexok);
                ssSetIWorkValue(S,TURNS_I_IND , turns);
            } else {
                //printf("index: %d\n",index);
                if ( (index & 0x2)==0x2 ) {                             // counts down

                    turns++;
                } else {
                    turns--;
                }
                ssSetIWorkValue(S,TURNS_I_IND , turns);
            }
        }

        countfloat=countval/res*2.0*PI/mode;
        //printf("%f\n",countfloat);
        if (countfloat<0.0) countfloat=2.0*PI+countfloat;
        y[0]=countfloat;
        y[1]=(double)turns;
    }


#endif

}

/* Function to compute model update */
static void mdlUpdate(real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
}

/* Function to compute derivatives */
static void mdlDerivatives(real_T *dx, const real_T *x, const real_T *u, SimStruct *S, int_T tid)
{
}

/* Function to perform housekeeping at execution termination */
static void mdlTerminate(SimStruct *S)
{
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
