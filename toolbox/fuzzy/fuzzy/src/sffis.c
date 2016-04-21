/*
 * sffis.c : SIMULINK MEX Level 2 S-function for fuzzy controllers
 *
 * Author   : Murali Yeddanapudi, 13-Nov-1997
 *
 * Copyright 1994-2002 The MathWorks, Inc. 
 * All Rights Reserved
 * $Revision: 1.18 $
 */

/*
 * Syntax  [sys, x0] = sffis(t, x, u, flag, FISMATRIX)
 */

/*
 * The following #define is used to specify the name of this S-Function.
 */
#define S_FUNCTION_NAME sffis
#define S_FUNCTION_LEVEL 2

#include <stdio.h>	/* needed for declaration of sprintf */
#include <stdlib.h>	/* needed for declaration of calloc */

/*
 * Include simstruc.h for the definition of the SimStruct and
 * its associated macro definitions (e.g., ssPrintf)
 * Note: Do not include this in FIS.H (fails to compile in standalone mode)
 */
#include "simstruc.h"
#include "fis.h"

/* This is to make sure that the TLC file is used for RTW purposes */
#if !defined(MATLAB_MEX_FILE)
# error "sffis.c cannot be used with Real-Time Workshop."
#endif

#define FISMATRIX  ssGetSFcnParam(S,0)


extern void fisFreeFisNode(FIS *fis);
extern void fisEvaluate(FIS *fis, int numofpoints);
extern FIS  *matlab2cStr(const mxArray *matlabmat, int numofpoints);
extern bool WriteMatlabStructureToRTWFile(SimStruct     *S,
                                          const mxArray *mlStruct,
                                          const char    *structName,
                                          char          *strBuffer,
                                          const int     strBufferLen);
/* This makes sure parameter types is only checked at sim time (so that errors
 * in mdlCheckParameters are not thrown while editing a mask when fis=[])
 */
#define DONT_CHECK_PARAMS(S, ARG)  ((ssGetSimMode(S) == SS_SIMMODE_SIZES_CALL_ONLY) && mxIsEmpty(ARG))

#define MDL_CHECK_PARAMETERS
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
/* Function: mdlCheckParameters =============================================
 * Abstract:
 *    Validate our parameters to verify they are okay.
 */
static void mdlCheckParameters(SimStruct *S)
{
    /* Check FIS parameter: has to be a structure */
    
    if (!mxIsStruct(FISMATRIX)) {
        ssSetErrorStatus(S,"FIS parameter must be a structure");
        return;
    } 
}
#endif /* MDL_CHECK_PARAMETERS */


/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *      Initialize the sizes array
 */
static void mdlInitializeSizes(SimStruct *S)
{
    int     in_n;
    int     out_n;
    mxArray *fispointer;

    /* the fis structure is the only parameter */
    ssSetNumSFcnParams(S, 1);
    if ((DONT_CHECK_PARAMS(S,FISMATRIX)) || (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)))
	{
        /* Parameter check not related to simulation, or parameter mismatch */
		return; 
    } else {
        mdlCheckParameters(S);
        if (ssGetErrorStatus(S) != NULL) return;
    }

    /* the fis structure cannot be changed during simulation */
    ssSetSFcnParamNotTunable(S,0);

    ssSetNumContStates(S, 0);
    ssSetNumDiscStates(S, 0);

    /* set number of input ports, their widths and direct feed thru flags */
    if (!ssSetNumInputPorts(S, 1)) return;
    fispointer = mxGetField(FISMATRIX, 0,"input");
    in_n       = mxGetN(fispointer);
    ssSetInputPortWidth(S, 0, in_n);

    ssSetInputPortDirectFeedThrough(S, 0, 1);

    /* set the number of output ports and their widths */
    if (!ssSetNumOutputPorts(S, 1)) return;
    fispointer = mxGetField(FISMATRIX, 0,"output");
    out_n      = mxGetN(fispointer);
    ssSetOutputPortWidth(S, 0, out_n);

    ssSetNumSampleTimes(S, 1);
    ssSetNumRWork(S, 0);
    ssSetNumIWork(S, 0);
    ssSetNumPWork(S, 1); /* pwork to cache pointer to the fis data struture */
    ssSetNumModes(S, 0);
    ssSetNumNonsampledZCs(S, 0);
    ssSetOptions(S, 0);

} /* end mdlInitializeSizes */



/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *      Initialize the sample times array
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, INHERITED_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);
}



#define MDL_START
#if defined(MDL_START)
/* Function: mdlStart =========================================================
 * Abstract:
 *    Setup the FIS Data Structure.
 */
static void mdlStart(SimStruct *S)
{
    FIS *fis;

    if ( (fis = matlab2cStr(FISMATRIX, 101)) == NULL) {
        ssSetErrorStatus(S,"Memory Allocation Error");
        return;
    }
    fis->next = NULL;

    /* Cache the fis pointer in the pwork */
    ssSetPWorkValue(S, 0, fis);
}
#endif /* MDL_START */



/* Function: mdlOutputs =======================================================
 * Abstract:
 *      Compute the outputs
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
    FIS   *fis = ssGetPWorkValue(S,0);
    int_T j;

    /* Copy over the input */
    {
        InputRealPtrsType uPtrs  = ssGetInputPortRealSignalPtrs(S,0);
        int_T             in_n   = fis->in_n;

        for (j = 0; j < in_n; j++) {
            fis->input[j]->value = (*uPtrs[j]);
        }
    }

    /* Compute the output */
    fisEvaluate(fis, 101);

    /* Copy over the output */
    {
        real_T *y    = ssGetOutputPortRealSignal(S,0);
        int_T  out_n = fis->out_n;

        for (j = 0; j < out_n; j++) {
            y[j] = fis->output[j]->value;
        }
    }
} /* end mdlOutputs */



/* Function: mdlTerminate =====================================================
 * Abstract:
 *      Free up the fis data structure.
 */
static void mdlTerminate(SimStruct *S)
{
    FIS *fis = ssGetPWorkValue(S,0);
    fisFreeFisNode(fis);

} /* end mdlTerminate */



#define MDL_RTW
#if defined(MDL_RTW) && (defined(MATLAB_MEX_FILE) || defined(NRT))
/* Function: mdlRTW =========================================================
 * Abstract:
 *
 */
static void mdlRTW(SimStruct *S)
{
    const mxArray *fis          = FISMATRIX;
    char          tmpStrBuf[80] = "\0";

    if ( !WriteMatlabStructureToRTWFile(S,fis,"SFcnFIS",tmpStrBuf,80) ) {
        ssSetErrorStatus(S,"Error writing to RTW File");
    }
    return;
}
#endif /* MDL_RTW */



/*=============================*
 * Required S-function trailer *
 *=============================*/

#ifdef MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
# include "simulink.c"      /* MEX-file interface mechanism */
#else
# include "cg_sfun.h"       /* Code generation registration function */
#endif
