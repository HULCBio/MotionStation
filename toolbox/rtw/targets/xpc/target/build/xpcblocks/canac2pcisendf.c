/* $Revision: 1.6.6.1 $ $Date: 2004/04/08 21:01:45 $ */
/* canac2pcisendf.c - xPC Target, non-inlined S-function driver for CAN-AC2-PCI (104) from Softing (FIFO mode)  */
/* Copyright 1996-2003 The MathWorks, Inc.
*/


#define         DEBUG                  0

#define         S_FUNCTION_LEVEL       2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME        canac2pcisendf

#include        <stddef.h>
#include        <stdlib.h>


#ifndef         MATLAB_MEX_FILE
#include        "can_def.h"
#include        "canlay2_mb1.h"
#include        "canlay2_mb2.h"
#include        "canlay2_mb3.h"
#endif

#include        "tmwtypes.h"
#include        "simstruc.h"

#ifdef          MATLAB_MEX_FILE
#include        "mex.h"
#endif


#define         NUMBER_OF_ARGS         (3)
#define         BOARD_ARG              ssGetSFcnParam(S,0)
#define         STATUS_ARG             ssGetSFcnParam(S,1)
#define         SAMP_TIME_ARG          ssGetSFcnParam(S,2)

#define         NO_I_WORKS             (0)
#define         NO_R_WORKS             (0)

#define         MAXEXTIDENT            536870911
#define         MAXSTDIDENT            2047


static char_T msg[256];


#ifndef MATLAB_MEX_FILE
unsigned char get_double_byte(double value, int n);

static unsigned char get_double_byte(double value, int n)
{
    unsigned char *p;

    p = (unsigned char *) &value;
    return p[n];
}
#endif



static void mdlInitializeSizes(SimStruct *S)
{

    int_T i;

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"Wrong number of input arguments passed.\n%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    ssSetNumInputPorts(S, 1);
    if (!ssSetInputPortMatrixDimensions(S, 0, DYNAMICALLY_SIZED, DYNAMICALLY_SIZED)) return;
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortRequiredContiguous(S, 0, 1);

    if ((int_T)mxGetPr(STATUS_ARG)[0]) {
        ssSetNumOutputPorts(S, 1);
        ssSetOutputPortWidth(S, 0, DYNAMICALLY_SIZED);
    } else {
        ssSetNumOutputPorts(S, 0);
    }

    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumPWork(S, 0);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    for (i=0;i<NUMBER_OF_ARGS;i++) {
        ssSetSFcnParamNotTunable(S,i);
    }

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);

}

#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct *S, int portIndex, const DimsInfo_T *dimsInfo)
{

    if (dimsInfo->dims[1] != 5 && dimsInfo->dims[1] != 6) {
        sprintf(msg,"Input must be a m*5 or a m*6  matrix");
        ssSetErrorStatus(S,msg);
        return;
    }
    if (!ssSetInputPortDimensionInfo(S, portIndex, dimsInfo)) return;
    if ((int_T)mxGetPr(STATUS_ARG)[0]) {
        if (!ssSetOutputPortVectorDimension(S, 0, dimsInfo->dims[0])) return;
    }


}

#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct *S, int portIndex, const DimsInfo_T *dimsInfo)
{
    if (!ssSetOutputPortDimensionInfo(S, portIndex, dimsInfo)) return;
}

#define MDL_SET_DEFAULT_PORT_DIMENSION_INFO
static void mdlSetDefaultPortDimensionInfo(SimStruct *S)
{
    if (!ssSetInputPortMatrixDimensions(S, 0, 1, 5)) return;
    if ((int_T)mxGetPr(STATUS_ARG)[0]) {
        if (!ssSetOutputPortVectorDimension(S, 0, 1)) return;
    }

}


static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, mxGetPr(SAMP_TIME_ARG)[0]);
    if (mxGetN((SAMP_TIME_ARG))==1) {
        ssSetOffsetTime(S, 0, 0.0);
    } else {
        ssSetOffsetTime(S, 0, mxGetPr(SAMP_TIME_ARG)[1]);
    }

}

static void mdlOutputs(SimStruct *S, int_T tid)
{



    int_T      index, frc, i, m, j;
    uint8_T   *p_data;
    real_T    *u, *y, dataReal;
    int_T     *dims;
    int_T      control, doSend;


#ifndef MATLAB_MEX_FILE

    dims= ssGetInputPortDimensions(S,0);
    if (dims[1] == 5) {
        control=0;
        m=dims[0];
    } else {
        control=1;
        m=6;
    }
    m=dims[0];

    u= (real_T *) ssGetInputPortSignal(S,0);

    if ((int_T)mxGetPr(STATUS_ARG)[0]) {
        y= (real_T *) ssGetOutputPortSignal(S,0);
    }

    for (i=0;i<m;i++) {
        //printf("%f %f %f %f %f\n",u[i+m*0], u[i+m*1], u[i+m*2], u[i+m*3], u[i+m*4]);

        int_T           port= (int_T)u[i+m*0];
        uint32_T        ident= (uint32_T)u[i+m*1];
        int_T           type=  (int_T)u[i+m*2];
        int_T           fsize=  (int_T)u[i+m*3];


        doSend=1;
        if (control) {
            if (u[i+m*5] < 0.5) {
                doSend=0;
                frc=0;
            }
        }

        /* check for valid format */

        if (port!=1 && port!=2) {
            doSend=0;
            frc=-10;
        }

        if (type!=0 && type!=1) {
            doSend=0;
            frc=-11;
        }

        switch (type) {
          case 0:
            if (ident<0 || ident>MAXSTDIDENT) {
                doSend=0;
                frc=-12;
            }
            break;
          case 1:
            if (ident<0 || ident>MAXEXTIDENT) {
                doSend=0;
                frc=-13;
            }
            break;
        }

        if (fsize<0 || fsize>8) {
            doSend=0;
            frc=-14;
        }

        if (doSend) {

            dataReal= u[i+m*4];
            p_data= (uint8_T *) &dataReal;
			_asm{pushf
    		    cli};
            switch (port) {
              case 1:   // port CAN 1
                switch ((int_T)mxGetPr(BOARD_ARG)[0]) {
                  case 1:
                    frc = CANPC_send_data_mb1(ident, type, fsize, p_data);
                    break;
                  case 2:
                    frc = CANPC_send_data_mb2(ident, type, fsize, p_data);
                    break;
                  case 3:
                    frc = CANPC_send_data_mb3(ident, type, fsize, p_data);
                    break;
                }
                break;
              case 2: // port CAN 2
			    switch ((int_T)mxGetPr(BOARD_ARG)[0]) {
                  case 1:
                    frc = CANPC_send_data2_mb1(ident, type, fsize, p_data);
                    break;
                  case 2:
                    frc = CANPC_send_data2_mb2(ident, type, fsize, p_data);
                    break;
                  case 3:
                    frc = CANPC_send_data2_mb3(ident, type, fsize, p_data);
                    break;
                }
                break;
            }
			_asm{popf};
        }

        if ((int_T)mxGetPr(STATUS_ARG)[0]) {
            y[i]= (real_T)frc;
        }

    }


#endif

}

static void mdlTerminate(SimStruct *S)
{
}

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif
