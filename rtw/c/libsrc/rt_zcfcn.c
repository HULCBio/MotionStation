/* Copyright 1994-2002 The MathWorks, Inc.
 *
 * File: rt_zcfcn.c     $Revision: 1.14 $
 *
 * Abstract:
 *      Real-Time Workshop zero crossing event detection routine for use with 
 *      real-time (fixed-step) and nonreal-time (variable-step) generated code.
 */

#include "rtlibsrc.h"


/* Function: rt_ZCFcn ========================================================
 * Abstract:
 *      Detect zero crossings events.
 */
ZCEventType rt_ZCFcn(ZCDirection direction,
                     ZCSigState *prevSigStatePtr, 
                     real_T      zcSig)
{

    /***********************************************************
     * First update the sampled zero crossing events if needed *
     ***********************************************************/

    ZCEventType zcEvent      = NO_ZCEVENT; /* assume */
    ZCSigState  prevSigState = *prevSigStatePtr;

    if (prevSigState == UNINITIALIZED_ZCSIG) {
        /* 
         * If previous zero crossing time isn't initialized, then we 
         * haven't had a previous zero crossing, so we just initialize the
         * previous zc signal.
         */
        *prevSigStatePtr = ((zcSig < 0.0)? NEG_ZCSIG: 
                            (zcSig > 0.0? POS_ZCSIG: ZERO_ZCSIG));
    } else {
        /*
         * Update sampled zero crossing events
         */
        ZCSigState sigState = ((zcSig < 0.0)? NEG_ZCSIG: 
                               (zcSig > 0.0? POS_ZCSIG: ZERO_ZCSIG));

        /**********************
         * Check for an event *
         **********************/

        if (prevSigState != sigState) {
#           define LOOK_NEGATIVE(d) ((d) != RISING_ZERO_CROSSING)
#           define LOOK_POSITIVE(d) ((d) != FALLING_ZERO_CROSSING)
            ZCEventType lastZCEvent = NO_ZCEVENT;

            if (prevSigState == ZERO_RISING_EV_ZCSIG) {
                /* Just had a negative to zero event */
                if (sigState == ZERO_ZCSIG) {
                    *prevSigStatePtr = ZERO_ZCSIG;
                    return(NO_ZCEVENT);
                }
                lastZCEvent  = RISING_ZCEVENT;
                prevSigState = ZERO_ZCSIG;
            } else if (prevSigState == ZERO_FALLING_EV_ZCSIG) {
                /* Just had a positive to zero event */
                if (sigState == ZERO_ZCSIG) {
                    *prevSigStatePtr = ZERO_ZCSIG;
                    return(NO_ZCEVENT);
                }
                lastZCEvent  = FALLING_ZCEVENT;
                prevSigState = ZERO_ZCSIG;
            }

            if (prevSigState == POS_ZCSIG) {
                if (LOOK_NEGATIVE(direction)) {
                    zcEvent = FALLING_ZCEVENT;
                }
            } else if (prevSigState == ZERO_ZCSIG) {
                if (sigState == POS_ZCSIG) {
                    if (LOOK_POSITIVE(direction)) {
                        zcEvent = RISING_ZCEVENT;
                    }
                } else if (sigState == NEG_ZCSIG) {
                    if (LOOK_NEGATIVE(direction)) {
                        zcEvent = FALLING_ZCEVENT;
                    }
                }
            } else { /* prevSigState == NEG_ZCSIG */
                if (LOOK_POSITIVE(direction)) {
                    zcEvent = RISING_ZCEVENT;
                }
            }

            if (zcEvent == lastZCEvent) {
                zcEvent = NO_ZCEVENT;
            }

            /*
             * Update prev sig state for next time.
             */
            if (sigState == ZERO_ZCSIG) {
                if (zcEvent == RISING_ZCEVENT) {
                    *prevSigStatePtr = ZERO_RISING_EV_ZCSIG;
                } else if (zcEvent == FALLING_ZCEVENT) {
                    *prevSigStatePtr = ZERO_FALLING_EV_ZCSIG;
                } else {
                    *prevSigStatePtr = sigState;
                }
            } else {
                *prevSigStatePtr = sigState;
            }
        }
    }
    
    return(zcEvent);

} /* end rt_ZCFcn */


/* [EOF] rt_zcfcn.c */
