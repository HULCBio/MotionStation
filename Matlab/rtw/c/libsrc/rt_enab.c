/* Copyright 1994-2004 The MathWorks, Inc.
 *
 * $RCSfile: rt_enab.c,v $
 * $Revision: 1.8.4.2 $
 * $Date: 2004/04/14 23:44:08 $
 *
 * Abstract:
 *   This function determines the enable state of a subsystem.
 */

#include "rtlibsrc.h"

/* Function: rt_EnableState ===================================================
 * Abstract:
 *   Determines the enable state of a subsystem based on the value of
 *   the current enable signal and the previous enable state.  This function
 *   is only valid under these conditions.
 *
 *   1. The system's enable signal is scalar
 *   2. The function is called from single rate system
 *   3. The system's output function does not execute in minor time steps
 */
CondStates rt_EnableState(boolean_T enableTest, int_T prevEnableState)
{
    CondStates enableState = (enableTest) ? SUBSYS_ENABLED : SUBSYS_DISABLED;

    /* Remove influence of trigger bit */
    prevEnableState &= (~(int_T)SUBSYS_TRIGGERED);

    if (enableState == SUBSYS_ENABLED) {
        if (prevEnableState == SUBSYS_DISABLED) {
            return SUBSYS_BECOMING_ENABLED;
        }
    } else {
        if (prevEnableState == SUBSYS_ENABLED) {
            return SUBSYS_BECOMING_DISABLED;
        }
    }

    return enableState;
}

/* [EOF] rt_enab.c */
