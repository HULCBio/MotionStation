/* $Revision: 1.5.6.1 $ $Date: 2004/04/08 21:01:43 $ */
/* canac2pcireceivef.c - xPC Target, non-inlined S-function driver for CAN-AC2-PCI from Softing (FIFO mode)  */
/* Copyright 1996-2003 The MathWorks, Inc.
*/

#define         DEBUG                   0

#define         S_FUNCTION_LEVEL        2
#undef          S_FUNCTION_NAME
#define         S_FUNCTION_NAME         canac2pcireceivef

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


#define         NUMBER_OF_ARGS          (4)
#define         BOARD_ARG               ssGetSFcnParam(S,0)
#define         DEPTH_ARG               ssGetSFcnParam(S,1)
#define         STATUS_ARG              ssGetSFcnParam(S,2)
#define         SAMP_TIME_ARG           ssGetSFcnParam(S,3)


#define         NO_I_WORKS              (0)
#define         NO_R_WORKS              (0)

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
    DECL_AND_INIT_DIMSINFO(iDimsInfo);
    int iDims[2];


    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"Wrong number of input arguments passed.\n%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);


    iDimsInfo.width   = 6 * (int_T)mxGetPr(DEPTH_ARG)[0];
    iDimsInfo.numDims = 2;
    iDimsInfo.dims    = iDims;
    iDims[0] = (int_T)mxGetPr(DEPTH_ARG)[0];
    iDims[1] = 6;



    if ((int_T)mxGetPr(STATUS_ARG)[0]) {
        ssSetNumOutputPorts(S, 2);
        ssSetOutputPortWidth(S,1,2);
    } else {
        ssSetNumOutputPorts(S, 1);
    }
    if (!ssSetOutputPortDimensionInfo(S, 0, &iDimsInfo)) return;

    ssSetNumInputPorts(S, 0);

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

#ifndef MATLAB_MEX_FILE

    int_T           index, frc, i, j, m;
    unsigned char   p_data[8];
    real_T          *y;
    unsigned long   time;
    real_T          *value;
    param_struct    ac;
    real_T          Bus_state;
    real_T          RCV_fifo_lost_msg;

    y= (real_T *) ssGetOutputPortSignal(S,0);

    m=ssGetOutputPortWidth(S,0)/6;

    for (i=0;i<(int_T)mxGetPr(DEPTH_ARG)[0];i++) {
		_asm{pushf
    		    cli};
        switch ((int_T)mxGetPr(BOARD_ARG)[0]) {
          case 1:
            frc = CANPC_read_ac_mb1(&ac);
            break;
          case 2:
            frc = CANPC_read_ac_mb2(&ac);
            break;
          case 3:
            frc = CANPC_read_ac_mb3(&ac);
            break;
        }
		_asm{popf};
		

        y[i+m*0]=0.0;   /* CAN channel */
        y[i+m*1]=-1.0;  /* Identifier */
        y[i+m*2]=(real_T)frc; /* FRC */
        y[i+m*3]=0.0;   /* Data length */
        y[i+m*4]=-1.0;  /* Time */
        y[i+m*5]=0.0;   /* Data */

        Bus_state=0.0;
        RCV_fifo_lost_msg=0.0;

        //printf("%d\n", frc);

        switch (frc) {
          case 1:
            y[i+m*0]=(real_T)ac.Can;
            y[i+m*1]=(real_T)ac.Ident;
            y[i+m*3]=(real_T)ac.DataLength;
            y[i+m*4]=(real_T)ac.Time;
            value=(double *) ac.RCV_data;
            y[i+m*5]=(real_T)*value;
            RCV_fifo_lost_msg= (real_T) ac.RCV_fifo_lost_msg;
            break;
          case 2:
            y[i+m*0]=(real_T)ac.Can;
            y[i+m*1]=(real_T)ac.Ident;
            y[i+m*4]=(real_T)ac.Time;
            RCV_fifo_lost_msg= (real_T) ac.RCV_fifo_lost_msg;
            break;
          case 3:
            y[i+m*0]=(real_T)ac.Can;
            y[i+m*1]=(real_T)ac.Ident;
            y[i+m*3]=(real_T)ac.DataLength;
            y[i+m*4]=(real_T)ac.Time;
            break;
          case 4:
            y[i+m*0]=(real_T)ac.Can;
            break;
          case 5:
            y[i+m*0]=(real_T)ac.Can;
            y[i+m*4]=(real_T)ac.Time;
            Bus_state= (real_T) ac.Bus_state;
            break;
          case 6:
            break;
          case 7:
            y[i+m*0]=(real_T)ac.Can;
            break;
          case 8:
            y[i+m*0]=(real_T)ac.Can;
            y[i+m*1]=(real_T)ac.Ident;
            y[i+m*4]=(real_T)ac.Time;
            RCV_fifo_lost_msg= (real_T) ac.RCV_fifo_lost_msg;
            break;
          case 9:
            y[i+m*0]=(real_T)ac.Can;
            y[i+m*1]=(real_T)ac.Ident;
            y[i+m*3]=(real_T)ac.DataLength;
            y[i+m*4]=(real_T)ac.Time;
            value=(double *) ac.RCV_data;
            y[i+m*5]=(real_T)*value;
            RCV_fifo_lost_msg= (real_T) ac.RCV_fifo_lost_msg;
            break;
          case 10:
            y[i+m*0]=(real_T)ac.Can;
            y[i+m*1]=(real_T)ac.Ident;
            y[i+m*3]=(real_T)ac.DataLength;
            y[i+m*4]=(real_T)ac.Time;
            break;
          case 11:
            y[i+m*0]=(real_T)ac.Can;
            y[i+m*1]=(real_T)ac.Ident;
            y[i+m*4]=(real_T)ac.Time;
            RCV_fifo_lost_msg= (real_T) ac.RCV_fifo_lost_msg;
            break;
          case 12:
            y[i+m*0]=(real_T)ac.Can;
            y[i+m*1]=(real_T)ac.Ident;
            y[i+m*4]=(real_T)ac.Time;
            RCV_fifo_lost_msg= (real_T) ac.RCV_fifo_lost_msg;
            break;
          case 13:
            break;
          case 14:
            break;
          case 15:
            y[i+m*0]=(real_T)ac.Can;
            y[i+m*4]=(real_T)ac.Time;
            value=(double *) ac.RCV_data;
            break;
        }

    }

    if ((int_T)mxGetPr(STATUS_ARG)[0]) {

        y= (real_T *) ssGetOutputPortSignal(S,1);

        if (!ssGetT(S)>0.0) {
            y[0]=0.0;
            y[1]=0.0;
        } else {
            y[0]= RCV_fifo_lost_msg;
            y[1]= Bus_state;
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
