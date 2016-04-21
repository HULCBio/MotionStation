/*
 * File    : sfun_slutils.c
 * Abstract:
 *   Utility routines for S-functions. To use them:
 *
 *         mex -Imatlabroot/simulink/src/sfun_slutils.c sfunction_name.c \
 *             matlabroot/simulink/src/sfun_slutils.c
 *
 *   In sfuntion_name.c, include sfun_slutils.c
 * 
 *  Copyright 1990-2002 The MathWorks, Inc.
 *  $Revision: 1.7 $
 */

#include "simstruc.h"
#include "sfun_slutils.h"  /* keep external definitions consistent */

/*==============*
 * misc defines *
 *==============*/
#if !defined(TRUE)
#define TRUE  1
#endif
#if !defined(FALSE)
#define FALSE 0
#endif

/* Function: IsRealMatrix =====================================================
 * Abstract:
 *      Verify that the mxArray is a real (double) finite matrix 
 */
boolean_T IsRealMatrix(const mxArray *m)
{
    if (mxIsNumeric(m)  &&  
        mxIsDouble(m)   && 
        !mxIsLogical(m) &&
        !mxIsComplex(m) &&  
        !mxIsSparse(m)  && 
        !mxIsEmpty(m)   &&
        mxGetNumberOfDimensions(m) == 2) {
        
        real_T *data = mxGetPr(m);
        int_T  numEl = mxGetNumberOfElements(m);
        int_T  i;

        for (i = 0; i < numEl; i++) {
            if (!mxIsFinite(data[i])) {
                return(FALSE);
            }
        }

        return(TRUE);
    } else {
        return(FALSE);
    }
}
/* end IsRealMatrix */

/* Function: IsDoubleMatrix ====================================================
 * Abstract:
 *      Verify that the mxArray is a double, real or complex finite matrix 
 */
boolean_T IsDoubleMatrix(const mxArray *m)
{
    if (mxIsNumeric(m)  &&  
        mxIsDouble(m)   && 
        !mxIsLogical(m) &&
        !mxIsSparse(m)  && 
        !mxIsEmpty(m)   &&
        mxGetNumberOfDimensions(m) == 2) {

        int_T  numEl = mxGetNumberOfElements(m);        
        real_T *rData = mxGetPr(m);
        int_T  i;
        
        for (i = 0; i < numEl; i++) {
            if (!mxIsFinite(rData[i])) {
                return(FALSE);
            }
        }

        if(mxIsComplex(m)){
            real_T *iData = mxGetPi(m);
            for (i = 0; i < numEl; i++) {
                if (!mxIsFinite(iData[i])) {
                    return(FALSE);
                }
            }
        }
        
        return(TRUE);
    } else {
        return(FALSE);
    }
}
/* end IsDoubleMatrix */


/* Function: IsRealVect ========================================================
 * Abstract:
 *      Verify that the mxArray is a real (double) finite row or column vector.
 */
boolean_T IsRealVect(const mxArray *m)
{
    return((IsRealMatrix(m) &&
            (mxGetM(m) == 1 || mxGetN(m) == 1)));
}

/* Function: IsDoubleVect ======================================================
 * Abstract:
 *      Verify that the mxArray is a double, real or complex finite row or 
 *      column vector.
 */
boolean_T IsDoubleVect(const mxArray *m)
{
    return((IsDoubleMatrix(m) &&
            (mxGetM(m) == 1 || mxGetN(m) == 1)));
}
/* end IsDoubleVect */




