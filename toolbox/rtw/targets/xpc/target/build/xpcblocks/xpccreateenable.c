/* $Revision: 1.2 $ $Date: 2002/03/25 04:12:06 $ */
/* xpccreateenable.c - xPC Target, non-inlined S-function to convert an input */
/* signal to a boolean.                                                       */
/* Copyright 1994-2002 The MathWorks, Inc. */

#define 	S_FUNCTION_LEVEL 	2
#undef 		S_FUNCTION_NAME
#define 	S_FUNCTION_NAME 	xpccreateenable

#include 	<stddef.h>
#include 	<stdlib.h>

#include 	"simstruc.h" 

#ifdef 		MATLAB_MEX_FILE
#include 	"mex.h"
#endif

#ifndef         MATLAB_MEX_FILE
#include        <windows.h>
#include        "io_xpcimport.h"
#include        "pci_xpcimport.h"
#endif

/* Input Arguments */
#define NUMBER_OF_ARGS          (2)
#define SHOW_ENABLE_ARG         ssGetSFcnParam(S,0)
#define INPUT_LEVEL_ARG         ssGetSFcnParam(S,1)

#define NO_I_WORKS              (0)

#define NO_R_WORKS              (0)

#define NO_P_WORKS              (0)

static char_T msg[256];
  

static void mdlInitializeSizes(SimStruct *S)
{

#ifndef MATLAB_MEX_FILE
#include "io_xpcimport.c"
#include "pci_xpcimport.c"
#endif

    ssSetNumSFcnParams(S, NUMBER_OF_ARGS);
    if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
        sprintf(msg,"Wrong number of input arguments passed.\n%d arguments are expected\n",NUMBER_OF_ARGS);
        ssSetErrorStatus(S,msg);
        return;
    }

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    ssSetNumOutputPorts(S, 1);
    ssSetOutputPortWidth(S, 0, 1);
    ssSetOutputPortDataType(S, 0, SS_BOOLEAN);

    if (!(int)mxGetPr(SHOW_ENABLE_ARG)[0]) {
        ssSetNumInputPorts(S, 1);
    } else {
        ssSetNumInputPorts(S, 2);
    }
    if (!ssSetInputPortDimensionInfo(S, 0, DYNAMIC_DIMENSION)) return;
    ssSetInputPortDirectFeedThrough(S, 0, 1);
    ssSetInputPortDataType(S, 0, DYNAMICALLY_TYPED);
    ssSetInputPortRequiredContiguous(S, 0, 1);
	
    if ((int)mxGetPr(SHOW_ENABLE_ARG)[0]) {
        ssSetInputPortWidth(S, 1, 1);
        ssSetInputPortDirectFeedThrough(S, 1, 1);
        ssSetInputPortRequiredContiguous(S, 1, 1);
    }
	    
    ssSetNumSampleTimes(S, 1);

    ssSetNumRWork(S, NO_R_WORKS);
    ssSetNumIWork(S, NO_I_WORKS);
    ssSetNumPWork(S, NO_P_WORKS);

    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);

    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE | SS_OPTION_PLACE_ASAP);
}

#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct *S, int portIndex, const DimsInfo_T *dimsInfo)
{
    if (!ssSetInputPortDimensionInfo(S, portIndex, dimsInfo))
        return;
}

#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
static void mdlSetOutputPortDimensionInfo(SimStruct *S, int portIndex, const DimsInfo_T *dimsInfo)
{
}

#define MDL_SET_DEFAULT_PORT_DIMENSION_INFO
static void mdlSetDefaultPortDimensionInfo(SimStruct *S)
{
    if (!ssSetInputPortVectorDimension(S, 0, 1))
        return;
}

#define MDL_SET_INPUT_PORT_DATA_TYPE
static void mdlSetInputPortDataType(SimStruct *S, int portIndex, DTypeId dType)
{
    ssSetInputPortDataType( S, portIndex, dType);
}

#define MDL_SET_OUTPUT_PORT_DATA_TYPE
static void mdlSetOutputPortDataType(SimStruct *S, int portIndex, DTypeId dType)
{
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    	ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    	ssSetOffsetTime(S, 0, 0.0);
}

static void mdlOutputs(SimStruct *S, int_T tid)
{
    boolean_T *y= (boolean_T *)ssGetOutputPortSignal(S,0);
    real_T level;

    y[0] = true;
    
    if ((int)mxGetPr(SHOW_ENABLE_ARG)[0])
    {
        real_T *u = (real_T *)ssGetInputPortSignal(S,1);
        level = (real_T)mxGetPr(INPUT_LEVEL_ARG)[0];
        //printf("ebl: ");
        if (u[0] < level)
        {
            y[0] = false;
            //printf("sig = %f, level = %f, y = 0x%x\n", u[0], level, y );
        }
    }
}

static void mdlTerminate(SimStruct *S)
{
}

#ifdef MATLAB_MEX_FILE  /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* Mex glue */
#else
#include "cg_sfun.h"    /* Code generation glue */
#endif
