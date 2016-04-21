/*
 *  dsp_sim.c - Simulation only functions for DSP Blockset
 *
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.1.6.2 $ $Date: 2004/04/12 23:12:52 $
 */

#include "dsp_sim.h"

#if !defined(MATLAB_MEX_FILE)
#   error "dsp_sim.c should not be used for S-Functions without a corresponding TLC file."
#endif

/*
 * Intended only for use via REGISTER_SFCN_PARAMS macro - see below.
 * Returns true if no errors occurred.
 */
EXPORT_FCN boolean_T registerSFunctionParams(SimStruct *S, int_T numParams)
{
    boolean_T argCountOK = (boolean_T)(numParams == ssGetSFcnParamsCount(S));

    ssSetNumSFcnParams(S, numParams);
        
    if(numParams > 0) {
        if (!argCountOK) return(false);
        
        if (ssGetmdlCheckParameters(S) != NULL) {
            /* Call mdlCheckParameters() in the S-Function */
            sfcnCheckParameters(S);
        } else {
            ssSetErrorStatus(S,"Parameters passed to S-Function, but "
                               "mdlCheckParameters not present.");
        }
        return( (boolean_T)(!ANY_ERRORS(S)) );

    } else {
        return(argCountOK);
    }
}


/* Version of calloc for Simulink S-Functions */
EXPORT_FCN void *slCalloc(
    SimStruct *S,
    const int_T count,
    const int_T size)
    {
    void *buf = mxCalloc(count, size);
    if ((buf == NULL) && (count * size > 0)) {
        ssSetErrorStatus(S, "Failed to allocate memory in slCalloc.");
    } else {
        mexMakeMemoryPersistent(buf);
    }
    return(buf);
}

/* Version of malloc for Simulink S-Functions */
EXPORT_FCN void *slMalloc(
    SimStruct *S,
    const int_T size)
    {
    void *buf = mxMalloc(size);
    if ((buf == NULL) && (size > 0)) {
        ssSetErrorStatus(S, "Failed to allocate memory in slMalloc.");
    } else {
        mexMakeMemoryPersistent(buf);
    }
    return(buf);
}
     

EXPORT_FCN void slFree(void *ptr)
{
    if (ptr != NULL) {
        mxFree(ptr);
    }
}

EXPORT_FCN int_T getNextPow2(int_T inValue)
{
    int_T outValue;

    if      (inValue <= 1) outValue = 1;
    else if (inValue <= 2) outValue = 2;
    else
    {
        int          nextPow2Exponent;
        const double frexpScaleFactor = frexp( ((double)((int)inValue)), &nextPow2Exponent);

        if (frexpScaleFactor == 0.5) {
            /* inValue is a power of 2 already */
            outValue = inValue;
        } else {
            /* inValue is NOT a power of 2 */
            outValue = (int_T)((int)(ldexp(1.0, nextPow2Exponent)));
        }
    }

    return outValue;
}

/* [EOF] dsp_sim.c */
