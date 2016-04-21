/*
 * event_port_handler_old_sim.h
 *
 * Copyright 1995-2003 The MathWorks, Inc.
 * $Revision: 1.9.4.2 $ $Date: 2004/04/12 23:12:22 $
 */
#ifndef EVENT_PORT_HANDLER_OLD_H
#define EVENT_PORT_HANDLER_OLD_H

#include "dsp_sim.h"

#define NO_EVENT_PORT -1

typedef enum {             /* Desired event detection */
    EVENT_PORT_MODE_NONE  = 0,
    EVENT_PORT_MODE_RISING,
    EVENT_PORT_MODE_FALLING,
    EVENT_PORT_MODE_EITHER,  /* Rising or falling */
    EVENT_PORT_MODE_NONZERO
} EventPortMode;

typedef enum {              /* What occurred */
    EVENT_PORT_EVENT_NONE   = 0,
    EVENT_PORT_EVENT_NONZERO,
    EVENT_PORT_EVENT_RISING,
    EVENT_PORT_EVENT_FALLING
} EventPortEvent;

typedef enum {              /* Last state of signal */
    EVENT_PORT_STATE_NEG = 0,
    EVENT_PORT_STATE_ZERO,
    EVENT_PORT_STATE_POS,
    EVENT_PORT_STATE_ZERO_RISING,
    EVENT_PORT_STATE_ZERO_FALLING,
    EVENT_PORT_STATE_UNINIT
} EventPortSigState;


/*
 * Define event port handler cache:
 */
typedef struct {
    const void       *port;       /* event port data buffer */
    EventPortSigState prevState;  /* previous signal state  */
} EventPortSigStateArgs;

typedef EventPortSigState (*EventPortSigStateFcn)(EventPortSigStateArgs *args);

typedef struct {
    EventPortSigStateArgs sigStateArgs;
    EventPortSigStateFcn  sigStateFcn;
    int_T                 sigStateFcnIdx;
} EventPortArgs;

typedef EventPortEvent (*EventPortFcn)(EventPortArgs *args);

typedef struct {
    EventPortArgs fcnArgs;
    EventPortFcn  eventFcn;
    int_T         eventFcnIdx;
} EventPortCache;


#define initEventPortCache(S,cache,portNum,eventMode) _initEventPortCacheFcn(S,cache,portNum,eventMode,ssGetInputPortSignal(S,portNum))
DSP_COMMON_SIM_EXPORT void _initEventPortCacheFcn(
    SimStruct          *S,
    EventPortCache     *cache,
    const int_T         portNum,
    const EventPortMode eventMode,
	const void* inputSignalPtr
    );

#ifdef DEBUG
extern void displayEventPortCache(EventPortCache *cache);
#endif

#define GET_EVENT_PORT_SIG_STATE(event_port_args_ptr) \
    ((event_port_args_ptr)->sigStateFcn)(&((event_port_args_ptr)->sigStateArgs))

#define EVENT_PORT_HAS_EVENT(event_port_cache) \
    (((event_port_cache).eventFcn)(&((event_port_cache).fcnArgs)) != EVENT_PORT_EVENT_NONE)


#endif /* EVENT_PORT_HANDLER_OLD_H */

/* [EOF] event_port_handler_old_sim.h */
