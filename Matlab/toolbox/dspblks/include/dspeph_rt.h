/*
 *  dspeph_rt.h
 *
 *  Abstract: Header file for run-time library helper functions 
 *  for the event port handler infrastructure.
 *
 *  Copyright 1995-2004 The MathWorks, Inc.
 *  $Revision: 1.4.4.3 $ $Date: 2004/04/12 23:11:46 $
 */

#ifndef dspeph_rt_h
#define dspeph_rt_h

#include "dsp_rt.h"

#ifdef DSPEPH_EXPORTS
#define DSPEPH_EXPORT EXPORT_FCN
#else
#define DSPEPH_EXPORT extern
#endif

/* This library consists of one function and several macros that allow
 * detection of zero-crossing events or non-zero values. 
 *
 * Enumerations:
 *  There are three enumerations used in this library:
 *  (1) Desired event detection: 
 *    - no detection
 *    - non-zero values
 *    - crossing zero from negative to positive
 *    - crossing zero from positive to negative
 *    - crossing zero in either direction
 */
typedef enum {
    EVENT_PORT_MODE_NONE = 0,
    EVENT_PORT_MODE_NONZERO,
    EVENT_PORT_MODE_RISING,
    EVENT_PORT_MODE_FALLING,
    EVENT_PORT_MODE_EITHER   /* Rising or falling */
} EventPortMode;

/*  (2) Event triggered by the current signal:
 *    - no event
 *    - non-zero value
 *    - rising event 
 *    - falling event
 */
typedef enum { 
    EVENT_PORT_EVENT_NONE = 0,
    EVENT_PORT_EVENT_NONZERO,
    EVENT_PORT_EVENT_RISING,
    EVENT_PORT_EVENT_FALLING
} EventPortEvent;

/*  (3) Previous state of signal 
 *    - negative
 *    - zero (no triggered event)
 *    - positive
 *    - zero (triggered rising event)
 *    - zero (triggered falling event)
 *    - uninitialized (e.g., on the first signal)
 */
typedef enum {
    EVENT_PORT_STATE_NEG = 0,
    EVENT_PORT_STATE_ZERO,
    EVENT_PORT_STATE_POS,
    EVENT_PORT_STATE_ZERO_RISING,
    EVENT_PORT_STATE_ZERO_FALLING,
    EVENT_PORT_STATE_UNINIT
} EventPortSigState;
/*   Note that the zero-crossing function (below) tracks whether or not a 
 *   zero state should be rising, falling or neither. 
 */

/* 
 * Zero-crossing detection function: 
 *
 * MWDSP_EPHZCFcn(EventPortMode      direction,
 *                EventPortSigState *prevSigStatePtr,
 *                EventPortSigState  currSigState)
 *
 * This function returns an EventPortEvent if one has occurred in the
 * input direction, else it returns EVENT_PORT_EVENT_NONE.  The
 * function updates the previous state pointer prevSigStatePtr.
 *
 * This function is intended to be used with modes RISING, FALLING and
 * EITHER, not NONZERO or NONE.
 *
 * Which events may be returned depend on the previous and current
 * states according to:
 *
 *     Last   Current 
 *     State  State    Mode               Event
 *     ---------------------------------- ---------------------------
 *     NEG    ZERO     RISING or EITHER   RISING
 *     ZERO   POS      RISING or EITHER   RISING
 *     NEG    POS      RISING or EITHER   RISING
 *                                        
 *     POS    ZERO     FALLING or EITHER  FALLING
 *     ZERO   NEG      FALLING or EITHER  FALLING
 *     POS    NEG      FALLING or EITHER  FALLING
 *                                        
 *     POS    POS      ANY BUT NONZERO    NONE
 *     ZERO   ZERO     ANY BUT NONZERO    NONE
 *     NEG    NEG      ANY BUT NONZERO    NONE
 *
 * "Deglitch" rule when passing through (and stopping at) ZERO:
 * - If we had a RISING event and are currently at ZERO,
 *   then if we get a POS signal, we do not declare another
 *   RISING event.
 * - Likewise, if we had a FALLING event and are currently
 *   at ZERO, then if we get a NEG signal we do not declare
 *   another FALLING event.
 *
 *  For example, a signal consisting of [-1,0,1] will trigger only
 *  one RISING event.  Note, however, that [-1,0,0,1] WILL trigger
 *  two RISING events.  */

/* MWDSP_ZCFcn
 * Checks for zero-crossing events 
 */
DSPEPH_EXPORT EventPortEvent MWDSP_EPHZCFcn(EventPortMode      direction,
                                     EventPortSigState *prevSigStatePtr,
                                     EventPortSigState  currSigState);

/* The following macros are used to determine the current state of the
 * signal.  Each macro corresponds to a different data type based on the
 * function suffix:
 *
 *   Suffix  Data Type
 *   -----------------
 *   signed values
 *     D     double-precision floating point
 *     R     single-precision floating point
 *     I32   32-bit signed integer
 *     I16   16-bit signed integer
 *     I8    8-bit signed integer
 *   unsigned values
 *     B     boolean
 *     U32   32-bit unsigned integer
 *     U16   16-bit unsigned integer
 *     U8    8-bit unsigned integer
 *
 * The macro argument is assumed to be a value of 
 * the correct data type.
 */

/* signed values */
#define EventPortSigStateFcn_D(signal) \
 ((signal < (real_T)0) ? EVENT_PORT_STATE_NEG : \
  ((signal > (real_T)0) ? EVENT_PORT_STATE_POS : \
    EVENT_PORT_STATE_ZERO))

#define EventPortSigStateFcn_R(signal) \
 ((signal < (real32_T)0) ? EVENT_PORT_STATE_NEG : \
  ((signal > (real32_T)0) ? EVENT_PORT_STATE_POS : \
    EVENT_PORT_STATE_ZERO))

#define EventPortSigStateFcn_I32(signal) \
 ((signal < (int32_T)0) ? EVENT_PORT_STATE_NEG : \
  ((signal > (int32_T)0) ? EVENT_PORT_STATE_POS : \
    EVENT_PORT_STATE_ZERO))

#define EventPortSigStateFcn_I16(signal) \
 ((signal < (int16_T)0) ? EVENT_PORT_STATE_NEG : \
  ((signal > (int16_T)0) ? EVENT_PORT_STATE_POS : \
    EVENT_PORT_STATE_ZERO))

#define EventPortSigStateFcn_I8(signal) \
 ((signal < (int8_T)0) ? EVENT_PORT_STATE_NEG : \
  ((signal > (int8_T)0) ? EVENT_PORT_STATE_POS : \
    EVENT_PORT_STATE_ZERO))

/* unsigned values */
#define EventPortSigStateFcn_B(signal) \
 ((signal) ? EVENT_PORT_STATE_POS : EVENT_PORT_STATE_ZERO)

#define EventPortSigStateFcn_U32(signal) \
 ((signal == (uint32_T)0) ? EVENT_PORT_STATE_ZERO : EVENT_PORT_STATE_POS)

#define EventPortSigStateFcn_U16(signal) \
 ((signal == (uint16_T)0) ? EVENT_PORT_STATE_ZERO : EVENT_PORT_STATE_POS)

#define EventPortSigStateFcn_U8(signal) \
 ((signal == (uint8_T)0) ? EVENT_PORT_STATE_ZERO : EVENT_PORT_STATE_POS)

#endif /* dspeph_rt_h */

/* [EOF] dspeph_rt.h */
