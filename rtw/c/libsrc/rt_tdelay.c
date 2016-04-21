/* File    : rt_tdelay.c
 * Abstract:
 *   Transport delay and Variable Transport delay interpolation routine
 *   
 *   Shared between Simulink and Real-Time Workshop.
 *
 *   See sl_blks/rt_tdelayacc.c for source.
 *
 * $Revision: 1.1.10.1 $
 * $Date: 2002/09/08 20:34:43 $
 */



#include "rtwtypes.h"
#include "rtlibsrc.h"
 
#ifndef PUBLIC
#define PUBLIC
#endif



/* Function: rt_TDelayInterpolate ==============================================
 * Abstract:
 *	Time delay interpolation routine
 *
 * The linear interpolation is performed using the formula:
 *
 *          (t2 - tMinusDelay)         (tMinusDelay - t1)
 * u(t)  =  ----------------- * u1  +  ------------------- * u2
 *              (t2 - t1)                  (t2 - t1)
 */
PUBLIC real_T rt_TDelayInterpolate(
    real_T     tMinusDelay,         /* tMinusDelay = currentSimTime - delay */
    real_T     *tBuf,
    real_T     *uBuf,
    int_T      bufSz,
    int_T      *lastIdx,
    int_T      oldestIdx,
    int_T      newIdx,
    boolean_T  discrete,
    boolean_T  minorStepAndTAtLastMajorOutput)
{
    int_T i;
    real_T yout, t1, t2, u1, u2;

    if (tMinusDelay <= tBuf[oldestIdx]) {
        return(uBuf[oldestIdx]);
    }

    /*
     * Since this block does not have direct feedthrough, we use the
     * table of values to extrapolate off the end of the table for
     * delays that are less than 0 (less then step size).  This is
     * not completely accurate.  The chain of events is as follows for a given
     * time t.  Major output - look in table.  Update - add entry to table.
     * Now, if we call the output at time t again, there is a new entry in
     * the table.  For very small delays, this means that we will have a
     * different answer from the previous call to the output fcn at the same
     * time t.  The following code prevents this from happening.
     */
    if (minorStepAndTAtLastMajorOutput) {
        /* pretend that the new entry has not been added to table */
        if (newIdx != 0) {
            if (*lastIdx == newIdx) {
                (*lastIdx)--;
            }
            newIdx--;
        } else {
            if (*lastIdx == newIdx) {
                *lastIdx = bufSz-1;
            }
            newIdx = bufSz - 1;
        }
    }

    i = *lastIdx;
    if (tBuf[i] < tMinusDelay) {
        /* Look forward starting at last index */
	while (tBuf[i] < tMinusDelay) {

	    /* May occur if the delay is less than step-size - extrapolate */
	    if (i == newIdx) break;

	    i = ( i < (bufSz-1) ) ? (i+1) : 0; /* move through buffer */

            utAssert(i != oldestIdx);
	}
    } else {
        /*
         * Look backwards starting at last index which can happen when the
         * delay time increases.
         */
	while (tBuf[i] >= tMinusDelay) {

            /*
             * Due to the entry condition at top of function, we
             * should never hit the end.
             */
            utAssert(i != oldestIdx);

	    i = (i > 0) ? i-1 : (bufSz-1); /* move through buffer */

	    utAssert(i != newIdx);
	}
	i = ( i < (bufSz-1) ) ? (i+1) : 0;
    }

    *lastIdx = i;

    if (discrete) {
        if (tBuf[i] <= tMinusDelay) {
            yout = uBuf[i];
        } else {
            if (i == 0) {
                yout = uBuf[bufSz-1];
            } else {
                yout = uBuf[i-1];
            }
        }
    } else {
        if (i == 0) {
            t1 = tBuf[bufSz-1];
            u1 = uBuf[bufSz-1];
        } else {
            t1 = tBuf[i-1];
            u1 = uBuf[i-1];
        }

        t2 = tBuf[i];
        u2 = uBuf[i];

        if (t2 == t1) {
            if (tMinusDelay >= t2) {
                yout = u2;
            } else {
                yout = u1;
            }
        } else {
            real_T f1 = (t2-tMinusDelay) / (t2-t1);
            real_T f2 = 1.0 - f1;

            /*
             * Use Lagrange's interpolation formula.  Exact outputs at t1, t2.
             */
            yout = f1*u1 + f2*u2;
        }
    }
    return(yout);

} /* end rt_TDelayInterpolate */



/* [eof] rt_tdelay.c */
