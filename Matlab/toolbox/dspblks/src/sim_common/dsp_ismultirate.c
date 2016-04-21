/*
 * dsp_ismultirate_sim.c 
 *
 * DSP Blockset helper function.
 *
 * Check if the block is multirate:
 * If any port has a different sample time,
 * then the block is multirate.
 *
 * Include this file to determine if block is multirate
 *
 * Copyright 1995-2003 The MathWorks, Inc.
 * $Revision: 1.1.6.2 $ $Date: 2004/04/12 23:12:58 $
 */

#include "dsp_ismultirate_sim.h"

EXPORT_FCN boolean_T isInputMultiRate(SimStruct *S, int_T numIn)
{
    if (numIn < 1) return(false);
    {
        /* Compare all input ports */
        const real_T inTs_old = ssGetInputPortSampleTime(S, 0);
        int_T idx;

        for (idx = 1; idx < numIn; idx++) {
            const real_T inTs_new = ssGetInputPortSampleTime(S, idx);
            if (inTs_old != inTs_new) {
                return(true);
            }
        }
        return(false);
    }
}


EXPORT_FCN boolean_T isOutputMultiRate(SimStruct *S, int_T numOut)
{
    if (numOut < 1) return(false);
    {
        /* Compare all output ports */
        const real_T outTs_old = ssGetOutputPortSampleTime(S, 0);
        int_T idx;

        for (idx = 1; idx < numOut; idx++) {
            const real_T outTs_new = ssGetOutputPortSampleTime(S, idx);
            if (outTs_old != outTs_new) {
                return(true);
            }
        }
        return(false);
    }
}


EXPORT_FCN boolean_T isBlockMultiRate(
    SimStruct *S, 
    int_T numIn, 
    int_T numOut)
{
    return((boolean_T)(isInputMultiRate(S,numIn)
           || isOutputMultiRate(S,numOut)
           || (ssGetInputPortSampleTime(S, 0) != ssGetOutputPortSampleTime(S, 0)) ));
}


EXPORT_FCN boolean_T isModelMultiTasking(SimStruct *S)
{
    return(boolean_T)(!ssIsVariableStepSolver(S) &&
           (ssGetSolverMode(S) == SOLVER_MODE_MULTITASKING)
          ); 

}

/* [EOF] dsp_ismultirate_sim.c */
