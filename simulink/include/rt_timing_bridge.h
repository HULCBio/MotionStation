/**
 *
 * $Revision: 1.1.6.1 $
 */


#ifndef __RT_TIMING_BRIDGE__
#define __RT_TIMING_BRIDGE__

#include "tmwtypes.h"

typedef struct _rtTimingBridge_tag rtTimingBridge;

struct _rtTimingBridge_tag {

    uint32_T     nTasks;

    void**       clockTick;
    void**       clockTickH;

    void**       taskCounter;
    int_T        taskCounterDataType;

    void**     taskTime;

    boolean_T**  rateTransition;
    
    boolean_T    *firstInitCond;
};

#endif  /* __RT_TIMING_BRIDGE__ */
/* EOF */
