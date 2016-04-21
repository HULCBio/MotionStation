/*
 *  Copyright 1995-2003 The MathWorks, Inc.
 *  $Revision: 1.2.2.2 $ $Date: 2004/04/12 23:42:47 $
 */

#include "dspeph_rt.h"

#define LOOK_NEGATIVE(d) ((d) != EVENT_PORT_MODE_RISING)
#define LOOK_POSITIVE(d) ((d) != EVENT_PORT_MODE_FALLING)

EXPORT_FCN EventPortEvent MWDSP_EPHZCFcn(EventPortMode      direction,
                                     EventPortSigState *prevSigStatePtr,
                                     EventPortSigState  currSigState)
{
  EventPortSigState prevSigState = *prevSigStatePtr;
  EventPortEvent    zcEvent      =  EVENT_PORT_EVENT_NONE;

  if (prevSigState == EVENT_PORT_STATE_UNINIT) {
    /*
     * If previous zero crossing isn't initialized, then
     * we haven't had a previous zero crossing, so we just
     * initialize the previous zc signal.
     */
    *prevSigStatePtr = currSigState;
  } else if (prevSigState != currSigState) {
    /*
     * Check for an event
     */
    EventPortEvent lastZCEvent = EVENT_PORT_EVENT_NONE;

    if (prevSigState == EVENT_PORT_STATE_ZERO_RISING) {
      /* Just had a negative to zero event */
      if (currSigState == EVENT_PORT_STATE_ZERO) {
        *prevSigStatePtr = EVENT_PORT_STATE_ZERO;
        return(EVENT_PORT_EVENT_NONE);
      }
      lastZCEvent = EVENT_PORT_EVENT_RISING;
      prevSigState = EVENT_PORT_STATE_ZERO;
    } else if (prevSigState == EVENT_PORT_STATE_ZERO_FALLING) {
      /* Just had a positive to zero event */
      if (currSigState == EVENT_PORT_STATE_ZERO) {
        *prevSigStatePtr = EVENT_PORT_STATE_ZERO;
        return(EVENT_PORT_EVENT_NONE);
      }
      lastZCEvent = EVENT_PORT_EVENT_FALLING;
      prevSigState = EVENT_PORT_STATE_ZERO;
    }

    if (prevSigState == EVENT_PORT_STATE_POS) {
      if (LOOK_NEGATIVE(direction)) {
        zcEvent = EVENT_PORT_EVENT_FALLING;
      }
    } else if (prevSigState == EVENT_PORT_STATE_ZERO) {
      if (currSigState == EVENT_PORT_STATE_POS) {
        if (LOOK_POSITIVE(direction)) {
          zcEvent = EVENT_PORT_EVENT_RISING;
        }
      } else if (currSigState == EVENT_PORT_STATE_NEG) {
        if (LOOK_NEGATIVE(direction)) {
          zcEvent = EVENT_PORT_EVENT_FALLING;
        }
      }
    } else { /* prevSigState == EVENT_PORT_STATE_NEG */
      if (LOOK_POSITIVE(direction)) {
        zcEvent = EVENT_PORT_EVENT_RISING;
      }
    }

    if (zcEvent == lastZCEvent) {
      zcEvent = EVENT_PORT_EVENT_NONE;
    }

    /*
     * Update prev sig state for next time.
     */
    if (currSigState == EVENT_PORT_STATE_ZERO) {
      if (zcEvent == EVENT_PORT_EVENT_RISING) {
        *prevSigStatePtr = EVENT_PORT_STATE_ZERO_RISING;
      } else if (zcEvent == EVENT_PORT_EVENT_FALLING) {
        *prevSigStatePtr = EVENT_PORT_STATE_ZERO_FALLING;
      } else {
        *prevSigStatePtr = currSigState;
      }
    } else {
      *prevSigStatePtr = currSigState;
    }
  }

  return(zcEvent);
}

/* [EOF] eph_zc_fcn.c */

