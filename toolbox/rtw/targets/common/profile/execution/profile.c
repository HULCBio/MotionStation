/*
 * File: profile.c
 *
 * Abstract: This file provides functions that implement an execution profiling
 * engine.
 *
 * $Revision: 1.1.6.3 $
 * $Date: 2004/04/19 01:21:34 $
 *
 * Copyright 2002-2003 The MathWorks, Inc.
 */

#include <stdlib.h>
#include "profile.h"
#include "tmwtypes.h"
#include "profile_vars.h"

#ifdef PROFILING_ENABLED
#define PROFILE_LOG_DATA
#define PROFILE_MAX_OVERRUNS
#define PROFILE_MAX_TURNAROUNDS
#endif

/* Defines */
#define PKTSZ  8
#define PROFILING_ENGINE_VER 1

#ifndef PROFILING_NUM_SAMPLES
#define PROFILING_NUM_SAMPLES 0
#endif

#define PROFILING_ARRAY_SIZE ( 2 * PROFILING_NUM_SAMPLES )

#ifdef PROFILE_MAX_OVERRUNS
#define PROFILING_MAX_OVERRUN_SECTION 1
#else
#define PROFILING_MAX_OVERRUN_SECTION 0
#endif

#ifdef PROFILE_MAX_TURNAROUNDS
#define PROFILING_MAX_TURNAROUND_SECTION 1
#else
#define PROFILING_MAX_TURNAROUND_SECTION 0
#endif

#ifdef PROFILE_LOG_DATA
#define PROFILE_LOG_DATA_SECTION 1
#else
#define PROFILE_LOG_DATA_SECTION 0
#endif

#if MT == 0 /* Single tasking */
#define NUM_TIMER_TASKS 1
#else
#define NUM_TIMER_TASKS NUMST
#endif

/* Local variables */
#ifdef PROFILING_ENABLED

const struct {
    uint8_T version;
    uint8_T profileSections;
    uint16_T numTimerTasks;
    uint16_T timerNsPerTick;
    uint16_T reserved;
} profInfo = {
    PROFILING_ENGINE_VER, 
    ( 128 * PROFILING_MAX_OVERRUN_SECTION +
      64 * PROFILING_MAX_TURNAROUND_SECTION + 
      32 * PROFILE_LOG_DATA_SECTION ), 
    NUM_TIMER_TASKS, 
    PROFILING_TIME_PER_TICK,
    0
};

struct {
#ifdef PROFILE_MAX_OVERRUNS
    uint8_T oRunMax[NUM_TIMER_TASKS];
#endif
#ifdef PROFILE_MAX_TURNAROUNDS
    uint_T tMax[NUM_TIMER_TASKS];
#endif
#ifdef PROFILE_LOG_DATA
    uint_T numPoints;
    uint_T loggedData[PROFILING_ARRAY_SIZE];
#endif
} prof;


#ifdef PROFILE_LOG_DATA
uint_T control = PROFILING_INACTIVE;
static uint_T logIdx = PROFILING_ARRAY_SIZE;
static uint_T sendIdx = 0;
#endif
#ifdef PROFILE_MAX_TURNAROUNDS
static uint_T turnAroundStart[NUM_TIMER_TASKS];
#endif

/* See documentation in header file */
void profile_init(void) {
#ifdef PROFILE_MAX_OVERRUNS
    {
        uint_T i;
        for (i=0; i<NUM_TIMER_TASKS; i++) {
            prof.oRunMax[i] = 0;
            prof.tMax[i] = 0;
        }
    }
#endif
}

/* See documentation in header file */
void profile_begin(void) {

    if (control == PROFILING_INACTIVE) {
        /* Update the profiling state variable */
        control = PROFILING_LOG_IN_PROGRESS;

        /* Initialize number of points to log */
#ifdef PROFILE_LOG_DATA
        prof.numPoints = PROFILING_ARRAY_SIZE;
#endif
        
        /* Enable profiling */
        logIdx = 0;
    }
}

/* See documentation in header file */
void overrun_max_log(uint_T overruns, uint_T taskNo) {
    if (prof.oRunMax[taskNo]<overruns) {
        prof.oRunMax[taskNo] = overruns;
    }
}

/* See documentation in header file */
uint_T profile_get_data(uint8_T * p_data_block) {
    uint_T rtn_val = 0;

    if (control == PROFILING_SEND_IN_PROGRESS) {
        uint8_T * ptr = NULL;

        if (sendIdx < ( sizeof(profInfo) ) ) {
            ptr =  ((uint8_T *) (&profInfo.version)) + (sendIdx);
        } else if (sendIdx < ( (sizeof(profInfo) + sizeof(prof)) ) ) {
            ptr = ( (uint8_T *) &prof) + sendIdx - sizeof(profInfo);
        }
        if (ptr != NULL) {
            uint_T i;
            for ( i=0; i< (PKTSZ); i++ ) {
                uint8_T data = *ptr++;
                p_data_block[i] = data;
            }
            sendIdx = sendIdx + (PKTSZ);
            rtn_val = 1;
        } else {
            control = PROFILING_INACTIVE;
        }
    }
    return rtn_val;
}

/* See documentation in header file */
void profile_state_update(void) {
        
    switch (control) {
      case PROFILING_INACTIVE:
        break;
        
      case PROFILING_LOG_IN_PROGRESS:
        if (logIdx >= PROFILING_ARRAY_SIZE) {
            sendIdx = 0;
            control = PROFILING_SEND_IN_PROGRESS;
        }
        break;
        
      case PROFILING_SEND_IN_PROGRESS:
        break;
        
      default:
        break;
    }
}

/* See documentation in header file */
uint_T profile_get_state(void) {
    return control;
}

/* See documentation in header file */
void profile_task_start(int_T task_num) {
    uint_T timer = profileReadTimer();
#ifdef PROFILE_LOG_DATA
    if (logIdx < (PROFILING_ARRAY_SIZE-1) ) {
        prof.loggedData[logIdx++] = task_num+1;
        prof.loggedData[logIdx++] = timer;
    }
#endif
#ifdef PROFILE_MAX_TURNAROUNDS
    turnAroundStart[task_num] = timer;
#endif
}  

/* See documentation in header file */
void profile_task_end(int_T task_num) {
    uint_T timer = profileReadTimer();
#ifdef PROFILE_LOG_DATA
    if (logIdx < (PROFILING_ARRAY_SIZE-1) ) {
        /* Use negative of section number to indicate end of section */
        prof.loggedData[logIdx++] = - ( task_num+1 );
        prof.loggedData[logIdx++] = timer;
    }
#endif
#ifdef PROFILE_MAX_TURNAROUNDS
    {
        uint_T turnAround = turnAroundStart[task_num]-timer;
        if (turnAround > prof.tMax[task_num]) {
            prof.tMax[task_num] = turnAround;
        }
    }
#endif
}    



/* See documentation in header file */
void profile_section_start(int_T section_num) {
    uint_T timer = profileReadTimer();
#ifdef PROFILE_LOG_DATA
    if (logIdx < (PROFILING_ARRAY_SIZE-1) ) {
        prof.loggedData[logIdx++] = section_num;
        prof.loggedData[logIdx++] = timer;
    }
#endif
}  

/* See documentation in header file */
void profile_section_end(int_T section_num) {
    uint_T timer = profileReadTimer();
#ifdef PROFILE_LOG_DATA
    if (logIdx < (PROFILING_ARRAY_SIZE-1) ) {
        /* Use negative of section number to indicate end of section */
        prof.loggedData[logIdx++] = - ( section_num );
        prof.loggedData[logIdx++] = timer;
    }
#endif
}    


/* See documentation in header file */
uint_T profile_get_max_turnaround(uint_T rate) {
    return prof.tMax[rate];
}

#else /* #ifdef PROFILING_ENABLED */  

/* Stub functions that may be required if libraries were built with profiling
   enabled */
void profile_section_start(int_T section_num){}
void profile_section_end(int_T section_num) {}
void profile_task_start(int_T section_num){}
void profile_task_end(int_T section_num) {}
void profile_begin(void) {}
uint_T profile_get_data(uint8_T * p_data_block) { return ( uint_T ) 0U; }
uint_T profile_get_state(void) { return ( uint_T ) PROFILING_INACTIVE; }
#endif /* #ifdef PROFILING_ENABLED */  
