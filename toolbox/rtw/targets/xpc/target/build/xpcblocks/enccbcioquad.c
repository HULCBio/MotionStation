/* $Revision: 1.7.6.2 $ $Date: 2004/04/08 21:02:15 $ */
/* enccbcioquad.c - xPC Target, non-inlined S-function driver for CB CIO/PCI-QUAD series boards */
/* Copyright 1996-2003 The MathWorks, Inc.
*/

#define S_FUNCTION_LEVEL 2
#define S_FUNCTION_NAME  enccbcioquad

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

#define NUM_PARAMS             (9)
#define BASE_ADDRESS_PARAM     (ssGetSFcnParam(S,0))
#define RESOLUTION_PARAM       (ssGetSFcnParam(S,1))
#define MODE_PARAM             (ssGetSFcnParam(S,2))
#define MODULE_PARAM           (ssGetSFcnParam(S,3))
#define COUNTING_PARAM         (ssGetSFcnParam(S,4))
#define ROTATION_PARAM         (ssGetSFcnParam(S,5))
#define PRESCALE_PARAM         (ssGetSFcnParam(S,6))
#define SAMPLE_TIME            (ssGetSFcnParam(S,7))
#define BOARD_ARG              (ssGetSFcnParam(S,8))



#define NO_I_WORKS             (5)
#define FIRSTINDEX_I_IND       (0)
#define TURNS_I_IND            (1)
#define MODE_I_IND             (2)
#define PREVCNTR_I_IND         (3)
#define BASE_ADDR_I_IND        (4)

#define NO_R_WORKS             (0)

#define RLD 0x00
#define CMR 0x20
#define IOR 0x40
#define IDR 0x60

#define PI      3.14159265358979

#define RESET_DETECT 0x800000
#define INDEX_DETECT 0x400000

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

    ssSetNumOutputPorts(S, 3);
    for (i=0;i<3;i++) {
        ssSetOutputPortWidth(S, i, 1);
    }

    ssSetNumSampleTimes(S, 1);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumPWork(S, 0);
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    ssSetSFcnParamNotTunable(S,0);
    ssSetSFcnParamNotTunable(S,1);
    ssSetSFcnParamNotTunable(S,2);
    ssSetSFcnParamNotTunable(S,3);
    ssSetSFcnParamNotTunable(S,4);
    ssSetSFcnParamNotTunable(S,5);
    ssSetSFcnParamNotTunable(S,6);
    ssSetSFcnParamNotTunable(S,7);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, mxGetPr(SAMPLE_TIME)[0]);
    if (mxGetN((SAMPLE_TIME))==1) {
        ssSetOffsetTime(S, 0, 0.0);
    } else {
        ssSetOffsetTime(S, 0, mxGetPr(SAMPLE_TIME)[1]);
    }
}

#define MDL_START  /* Change to #undef to remove function */
#if defined(MDL_START)
static void mdlStart(SimStruct *S)
{
    int   tmpres = 0;
    int   mode;
    int_T baseAddr;
    int_T cntrout = 0;
    int_T baseAddr1;
    int   prescale;

#ifndef MATLAB_MEX_FILE

    PCIDeviceInfo pciinfo;


    ssSetIWorkValue(S,FIRSTINDEX_I_IND , 0);
    ssSetIWorkValue(S,TURNS_I_IND , 0);
    ssSetIWorkValue(S,PREVCNTR_I_IND , 0);

    mode = mxGetPr(MODE_PARAM)[0];

    if (mode==1) {
        ssSetIWorkValue(S,MODE_I_IND , 1);
    } else if (mode==2) {
        ssSetIWorkValue(S,MODE_I_IND , 2);
    } else if (mode==3) {
        ssSetIWorkValue(S,MODE_I_IND , 4);
    }

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

    baseAddr1 = baseAddr;
    baseAddr = baseAddr + ((mxGetPr(MODULE_PARAM)[0]-1) * 2);

    //Set Counter Mode Register(CMR)
    rl32eOutpB((unsigned short)(baseAddr + 0x01),(unsigned short)(CMR + ((int)mxGetPr(MODE_PARAM)[0] << 3)));

    //Reset E
    rl32eOutpB((unsigned short)(baseAddr + 0x01),RLD + 0x06);

    //Reset BP
    rl32eOutpB( (unsigned short)(baseAddr + 0x01),RLD + 0x01);

    //Load PR0 with the user specified before transferring the 
    // value to the PSC (Prescale) register.
    // The value 0 allows the maximum counting frequency.
    prescale = (int)mxGetPr(PRESCALE_PARAM)[0];
    rl32eOutpB( (unsigned short)baseAddr, prescale & 0xff ); //LSB

    //Transfer from PR0 to PSC
    rl32eOutpB((unsigned short)(baseAddr + 0x01),RLD + 0x18);

    //Reset BP
    rl32eOutpB((unsigned short)(baseAddr + 0x01),RLD + 0x01);

    //Load preset register(PR) with Index Detect
    rl32eOutpB((unsigned short)baseAddr,INDEX_DETECT & 0x0000ff); //LSB
    rl32eOutpB((unsigned short)baseAddr,(INDEX_DETECT >> 8) & 0x0000ff);
    rl32eOutpB((unsigned short)baseAddr,(INDEX_DETECT >> 16) & 0x0000ff); //MSB

    //IOR - Enable A/B input, Set reset CNTR at index
    rl32eOutpB((unsigned short)(baseAddr + 0x01),IOR + 0x01);

    //IDR - Enable index, Set index polarity, Index pin select
    rl32eOutpB((unsigned short)(baseAddr + 0x01),IDR + 0x03);

    /* Setup index/interrupt routing control register
     * Note: If later index pin select is changed this
     *       value needs to be changed accordingly. Also
     *       this may required it to be set on a per
     *       module basis.
     */
    rl32eOutpB((unsigned short)(baseAddr1 + 0x08),0x0f);

    //Disable cascading
    rl32eOutpB((unsigned short)(baseAddr1 + 0x09),0x00);

    //Disable interrupts
    rl32eOutpB((unsigned short)(baseAddr1 + 0x12),0x00);

    //Load CNTR with PR
    rl32eOutpB((unsigned short)(baseAddr + 0x01),RLD + 0x08);

    //Load OL with Data
    rl32eOutpB((unsigned short)(baseAddr + 0x01),RLD + 0x10);

    //Reset BP
    rl32eOutpB((unsigned short)(baseAddr + 0x01),RLD + 0x01);

    //Read OL
    cntrout = (rl32eInpB((unsigned short)baseAddr) & 0x00ff);
    cntrout = cntrout | ((rl32eInpB((unsigned short)baseAddr) & 0x00ff) * 0x100);
    cntrout = cntrout | ((rl32eInpB((unsigned short)baseAddr) & 0x00ff) * 0x10000);

    if (cntrout != INDEX_DETECT) {
        sprintf(msg,"Init Failed: Check CB CIO/PCI-QUAD Encoder Board");
        ssSetErrorStatus(S,msg);
    }

    //Reset BP
    rl32eOutpB((unsigned short)(baseAddr + 0x01),RLD + 0x01);

    //Load preset register(PR) with Reset Detect Value
    rl32eOutpB((unsigned short)baseAddr,RESET_DETECT & 0x0000ff); //LSB
    rl32eOutpB((unsigned short)baseAddr,(RESET_DETECT >> 8) & 0x0000ff);
    rl32eOutpB((unsigned short)baseAddr,(RESET_DETECT >> 16) & 0x0000ff); //MSB

    if (mxGetPr(COUNTING_PARAM)[0] == 3) {
        //Load CNTR with PR
        rl32eOutpB((unsigned short)(baseAddr + 0x01),RLD + 0x08);
    }



#endif // MATLAB_MEX_FILE
}
#endif /*  MDL_START */

static void mdlOutputs(SimStruct *S, int_T tid)
{
    //
    //Note: Given an encoder with max rpm of rpm 12000 and a turn detection of x = PI the minimum Ts is
    //
    //             60 Seconds /(2PI / x)   60 (2PI / PI)
    //  Ts(MIN)    --------------------- = ------------- = 2.5ms
    //                     RPM                 12000

    real_T        *y, *y2, *y3;
    int_T        enc_flags, cntrout;
    real_T       calc_error;
    int_T        tmpout;
    double tmp2;
    int_T        tmpres = mxGetPr(RESOLUTION_PARAM)[0];
    int_T          baseAddr = ssGetIWorkValue(S, BASE_ADDR_I_IND);
    int_T                  baseAddr1;
    int_T        quad_mode = ssGetIWorkValue(S,MODE_I_IND);
    int_T        firstindex = ssGetIWorkValue(S,FIRSTINDEX_I_IND);
    int_T        turns = ssGetIWorkValue(S,TURNS_I_IND);
    int_T        prevcntr = ssGetIWorkValue(S,PREVCNTR_I_IND);
    int_T        rotation = mxGetPr(ROTATION_PARAM)[0];
    real_T       angle;

#ifndef MATLAB_MEX_FILE
    baseAddr1 = baseAddr;
    baseAddr  = baseAddr + ((mxGetPr(MODULE_PARAM)[0]-1) * 2);
    y         = ssGetOutputPortRealSignal(S,0);
    y2        = ssGetOutputPortRealSignal(S,1);
    y3        = ssGetOutputPortRealSignal(S,2);
    enc_flags = rl32eInpB((unsigned short)(baseAddr + 0x01));

    //Load OL with Data
    rl32eOutpB((unsigned short)(baseAddr + 0x01),RLD + 0x10);
    //Reset BP
    rl32eOutpB((unsigned short)(baseAddr + 0x01),RLD + 0x01);
    //Read OL
    cntrout = (rl32eInpB((unsigned short)baseAddr) & 0x00ff);
    cntrout = cntrout | ((rl32eInpB((unsigned short)baseAddr) & 0x00ff) * 0x100);
    cntrout = cntrout | ((rl32eInpB((unsigned short)baseAddr) & 0x00ff) * 0x10000);

    tmpout  = cntrout;

    if (mxGetPr(COUNTING_PARAM)[0] == 3) {

        firstindex=1;
        ssSetIWorkValue(S,FIRSTINDEX_I_IND , 1);
        prevcntr = cntrout;
        rl32eOutpB((unsigned short)(baseAddr + 0x01),IOR + 0x03);
        //IDR - Enable index, Set index polarity, Index pin select
        rl32eOutpB((unsigned short)(baseAddr + 0x01),IDR + 0x02);
        y[0] = 0;
        y2[0] = 0;
        y3[0] = 0;

    } else {
        if (firstindex == 0) {
            if (((tmpout - INDEX_DETECT) > (2 * tmpres * quad_mode)) || ((INDEX_DETECT - tmpout) > (2 * tmpres * quad_mode))) {
                ssSetIWorkValue(S,FIRSTINDEX_I_IND , 1);
                firstindex = 1;
                prevcntr = cntrout;
                if (mxGetPr(COUNTING_PARAM)[0] == 2) {
                    //Set New Flags
                    //IOR - Enable A/B input, Set reset CNTR at index
                    rl32eOutpB((unsigned short)(baseAddr + 0x01),IOR + 0x03);
                    //IDR - Enable index, Set index polarity, Index pin select
                    rl32eOutpB((unsigned short)(baseAddr + 0x01),IDR + 0x02);
                    /* Setup index/interrupt routing control register
                     * Note: If later index pin select is changed this
                     *       value needs to be changed accordingly. Also
                     *       this may required it to be set on a per
                     *       module basis.
                     */
                    //rl32eOutpB((unsigned short)(baseAddr1 + 0x08),0x01);
                }
            } else {
                y[0] = 0;
                y2[0] = 0;
                y3[0] = 0;
            }
        }
    }
    if (firstindex) {
        if (mxGetPr(COUNTING_PARAM)[0] == 1) {
            angle = ((float)tmpout-(float)RESET_DETECT)/((float)tmpres*(float)quad_mode) * 2.0 * PI;
            if ((tmpout-(int)prevcntr) > (tmpres * quad_mode / 2)) {
                turns--;
                ssSetIWorkValue(S,TURNS_I_IND,turns);
            }
            if (((int)prevcntr-tmpout) > (tmpres * quad_mode / 2)) {
                turns++;
                ssSetIWorkValue(S,TURNS_I_IND,turns);
            }
        } else {
            angle = (float)((tmpout-RESET_DETECT)%(tmpres*quad_mode))/(float)(tmpres*quad_mode) * 2.0 * PI;
            turns = (tmpout-RESET_DETECT) / (tmpres * quad_mode);
        }
        if (rotation == 1) {
            turns = -turns;
            angle = -angle;
        }
        y[0] = angle;
        y2[0] = turns;
        if ((abs(turns) > ((RESET_DETECT/(tmpres*quad_mode))-1)) && (mxGetPr(COUNTING_PARAM)[0] == 1)) {
            y3[0] = -1;
        } else {
            y3[0] = 1;
        }
        ssSetIWorkValue(S,PREVCNTR_I_IND,cntrout);
    }
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
