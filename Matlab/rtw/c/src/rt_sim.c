/* Copyright 1994-2003 The MathWorks, Inc.
 *
 * File    : rt_sim.c     $Revision: 1.19.4.2 $
 * Abstract:
 *   Performs one time step of a real-time single tasking or multitasking
 *   system for statically or dynamically allocated timing data.
 *
 *   The tasking mode is controlled by the MULTITASKING #define.
 *
 *   The data allocation type is controlled by the RT_MALLOC #define, where
 *   the static case is contained in this file and the dynamic case is
 *   contained in mrt_sim.c.
 */


#include <string.h>
#include <stdlib.h>
#include <math.h>

#include "tmwtypes.h"
#ifdef USE_RTMODEL
# include "simstruc_types.h"
#else
# include "simstruc.h"
#endif
#include "rt_sim.h"

#ifndef ERT_CORE

#ifndef RT_MALLOC /* statically declare data */

/*==========*
 * Struct's *
 *==========*/

/*
 * TimingData
 */
typedef struct TimingData_Tag {
    real_T period[NUMST];       /* Task periods in seconds                   */
    real_T offset[NUMST];       /* Task offsets in seconds                   */
    real_T clockTick[NUMST];    /* Flint task time tick counter              */
    int_T  taskTick[NUMST];     /* Counter for determining task hits         */
    int_T  nTaskTicks[NUMST];   /* Number base rate ticks for a task hit     */
    int_T  firstDiscIdx;        /* First discrete task index                 */
} TimingData;

/*=========================*
 * Data local to this file *
 *=========================*/

static TimingData td;

/*==================*
 * Visible routines *
 *==================*/

/* Function: rt_SimInitTimingEngine ============================================
 * Abstract:
 *      This function is for use with single tasking or multitasking
 *      real-time systems.  
 *
 *      Initializes the timing engine for a fixed-step real-time system. 
 *      It is assumed that start time is 0.0.
 *
 * Returns:
 *      NULL     - success
 *      non-NULL - error string
 */
const char *rt_SimInitTimingEngine(int_T       rtmNumSampTimes,
                                   real_T      rtmStepSize,
                                   real_T      *rtmSampleTimePtr,
                                   real_T      *rtmOffsetTimePtr,
                                   int_T       *rtmSampleHitPtr,
                                   int_T       *rtmSampleTimeTaskIDPtr,
                                   real_T      rtmTStart,
                                   SimTimeStep *rtmSimTimeStepPtr,
                                   void        **rtmTimingDataPtr)
{
    int_T     i;
    int       *tsMap     = rtmSampleTimeTaskIDPtr;
    real_T    *period    = rtmSampleTimePtr;
    real_T    *offset    = rtmOffsetTimePtr;
    int_T     *sampleHit = rtmSampleHitPtr;
    real_T    stepSize   = rtmStepSize;

    if (rtmTStart != 0.0) {
        return("Start time must be zero for real-time systems");
    }

    *rtmSimTimeStepPtr = MAJOR_TIME_STEP;

    *rtmTimingDataPtr = (void*)&td;

    for (i = 0; i < NUMST; i++) {
        tsMap[i]         = i;
        td.period[i]     = period[i];
        td.offset[i]     = offset[i];
        td.nTaskTicks[i] = (int_T)floor(period[i]/stepSize + 0.5);
        if (td.period[i] == CONTINUOUS_SAMPLE_TIME ||
            td.offset[i] == 0.0) {
            td.taskTick[i]  = 0;
            td.clockTick[i] = 0.0;
            sampleHit[i]    = 1;
        } else {
            td.taskTick[i]  = (int_T)floor((td.period[i]-td.offset[i]) /
                                            stepSize+0.5);
            td.clockTick[i] = -1.0;
            sampleHit[i]    = 0;
        }
    }

    /* Correct first sample time if continuous task */
    td.period[0]     = stepSize;
    td.nTaskTicks[0] = 1; 

    /* Set first discrete task index */
#if NUMST == 1    
    td.firstDiscIdx = (int_T)(period[0] == CONTINUOUS_SAMPLE_TIME);
#else
    td.firstDiscIdx = ((int_T)(period[0] == CONTINUOUS_SAMPLE_TIME) + 
                       (int_T)(period[1] == CONTINUOUS_SAMPLE_TIME));
#endif

    return(NULL); /* success */

} /* end rt_SimInitTimingEngine */


#if !defined(MULTITASKING)

/*###########################################################################*/
/*########################### SINGLE TASKING ################################*/
/*###########################################################################*/

/* Function: rt_SimGetNextSampleHit ============================================
 * Abstract:
 *      For a single tasking real-time system, return time of next sample hit.
 */
time_T rt_SimGetNextSampleHit(void)
{
    time_T timeOfNextHit;
    td.clockTick[0] += 1;
    timeOfNextHit = td.clockTick[0] * td.period[0];

#   if NUMST > 1
    {
        int i;
        for (i = 1; i < NUMST; i++) {
            if (++td.taskTick[i] == td.nTaskTicks[i]) {
                td.taskTick[i] = 0;
                td.clockTick[i]++;
            }
        }
    }
#   endif

    return(timeOfNextHit);

} /* end rt_SimGetNextSampleHit */



/* Function: rt_SimUpdateDiscreteTaskSampleHits ================================
 * Abstract:
 *      This function is for use with single tasking real-time systems.  
 *      
 *      If the number of sample times is greater than one, then we need to 
 *      update the discrete task sample hits for the next time step. Note, 
 *      task 0 always has a hit since it's sample time is the fundamental 
 *      sample time.
 */
void rt_SimUpdateDiscreteTaskSampleHits(int_T  rtmNumSampTimes,
                                        void   *rtmTimingData,
                                        int_T  *rtmSampleHitPtr,
                                        real_T *rtmTPtr)
{
    int_T *sampleHit = rtmSampleHitPtr;
    int   i;
    
    UNUSED_PARAMETER(rtmTimingData);
    UNUSED_PARAMETER(rtmNumSampTimes);
    
    for (i = td.firstDiscIdx; i < NUMST; i++) {
        int_T hit = (td.taskTick[i] == 0);
        if (hit) {
            rttiSetTaskTime(rtmTPtr, i, 
                            td.clockTick[i]*td.period[i] + td.offset[i]);
        }
        sampleHit[i] = hit;
    }
} /* rt_SimUpdateDiscreteTaskSampleHits */



#else /* defined(MULTITASKING) */

/*###########################################################################*/
/*############################## MULTITASKING ###############################*/
/*###########################################################################*/


/* Function: rt_SimUpdateDiscreteEvents ========================================
 * Abstract:
 *      This function is for use with multitasking real-time systems. 
 *
 *      This function updates the status of the RT_MODEL sampleHits
 *      flags and the perTaskSampleHits matrix which is used to determine 
 *      when special sample hits occur.
 *
 *      The RT_MODEL contains a matrix, called perTaskSampleHits. 
 *      This matrix is used by the ssIsSpecialSampleHit macro. The row and 
 *      column indices are both task id's (equivalent to the root RT_MODEL 
 *      sample time indices). This is a upper triangle matrix. This routine 
 *      only updates the slower task hits (kept in column j) for row
 *      i if we have a sample hit in row i.
 *
 *                       column j
 *           tid   0   1   2   3   4   5  
 *               -------------------------
 *             0 |   | X | X | X | X | X |
 *         r     -------------------------
 *         o   1 |   |   | X | X | X | X |      This matrix(i,j) answers:
 *         w     -------------------------      If we are in task i, does
 *             2 |   |   |   | X | X | X |      slower task j have a hit now?
 *         i     -------------------------
 *             3 |   |   |   |   | X | X |
 *               -------------------------
 *             4 |   |   |   |   |   | X |      X = 0 or 1
 *               -------------------------
 *             5 |   |   |   |   |   |   |
 *               -------------------------
 *
 *      How macros index this matrix:
 *
 *          ssSetSampleHitInTask(S, j, i, X)   => matrix(i,j) = X
 *
 *          ssIsSpecialSampleHit(S, my_sti, promoted_sti, tid) => 
 *              (tid_for(promoted_sti) == tid && !minor_time_step &&
 *               matrix(tid,tid_for(my_sti)) 
 *              )
 *
 *            my_sti       = My (the block's) original sample time index.
 *            promoted_sti = The block's promoted sample time index resulting
 *                           from a transition via a ZOH from a fast to a 
 *                           slow block or a transition via a unit delay from 
 *                           a slow to a fast block.
 *
 *      The perTaskSampleHits array, of dimension n*n, is accessed using 
 *      perTaskSampleHits[j + i*n] where n is the total number of sample
 *      times, 0 <= i < n, and 0 <= j < n.  The C language stores arrays in 
 *      row-major order, that is, row 0 followed by row 1, etc.
 * 
 */
time_T rt_SimUpdateDiscreteEvents(int_T  rtmNumSampTimes,
                                  void   *rtmTimingData,
                                  int_T  *rtmSampleHitPtr,
                                  int_T  *rtmPerTaskSampleHits)
{
    int   i, j;
    int_T *sampleHit = rtmSampleHitPtr;
    
    UNUSED_PARAMETER(rtmTimingData);
    
    /*
     * Run this loop in reverse so that we do lower priority events first.
     */
    i = NUMST;
    while (--i >= 0) {
        if (td.taskTick[i] == 0) {
            /* 
             * Got a sample hit, reset the counter, and update the clock
             * tick counter.
             */
            sampleHit[i] = 1;
            td.clockTick[i]++;

            /*
             * Record the state of all "slower" events 
             */
            for (j = i + 1; j < NUMST; j++) {
                rttiSetSampleHitInTask(rtmPerTaskSampleHits, rtmNumSampTimes,
                                       j, i, sampleHit[j]);
            }
        } else {
            /*
             * no sample hit, increment the counter 
             */
            sampleHit[i] = 0;
        }

        if (++td.taskTick[i] == td.nTaskTicks[i]) { /* update for next time */
            td.taskTick[i] = 0;
        }
    }

    return(td.clockTick[0]*td.period[0]);
    
} /* rt_SimUpdateDiscreteEvents */


/* Function: rt_SimUpdateDiscreteTaskTime ======================================
 * Abstract:
 *      This function is for use with multitasking systems. 
 *
 *      After a discrete task output and update has been performed, this 
 *      function must be called to update the discrete task time for next 
 *      time around.
 */
void rt_SimUpdateDiscreteTaskTime(real_T *rtmTPtr,
                                  void   *rtmTimingData,
                                  int    tid)
{
    UNUSED_PARAMETER(rtmTimingData);
    rttiSetTaskTime(rtmTPtr, tid,
                    td.clockTick[tid]*td.period[tid] + td.offset[tid]);
}

#endif /* MULTITASKING */

#else

#include "mrt_sim.c" /* dynamically allocate data */

#endif /* RT_MALLOC */

/*
 *******************************************************************************
 * FUNCTIONS MAINTAINED FOR BACKWARDS COMPATIBILITY WITH THE SimStruct
 *******************************************************************************
 */
#ifndef USE_RTMODEL
const char *rt_InitTimingEngine(SimStruct *S)
{
    const char_T *retVal = rt_SimInitTimingEngine(
        ssGetNumSampleTimes(S),
        ssGetStepSize(S),
        ssGetSampleTimePtr(S),
        ssGetOffsetTimePtr(S),
        ssGetSampleHitPtr(S),
        ssGetSampleTimeTaskIDPtr(S),
        ssGetTStart(S),
        &ssGetSimTimeStep(S),
        &ssGetTimingData(S));
    return(retVal);
}

# ifdef RT_MALLOC
void rt_DestroyTimingEngine(SimStruct *S)
{
    rt_SimDestroyTimingEngine(ssGetTimingData(S));
}
# endif

# if !defined(MULTITASKING)
void rt_UpdateDiscreteTaskSampleHits(SimStruct *S)
{
    rt_SimUpdateDiscreteTaskSampleHits(
        ssGetNumSampleTimes(S),
        ssGetTimingData(S),
        ssGetSampleHitPtr(S),
        ssGetTPtr(S));
}

#   ifndef RT_MALLOC

time_T rt_GetNextSampleHit(void)
{
    return(rt_SimGetNextSampleHit());
}

#   else /* !RT_MALLOC */

time_T rt_GetNextSampleHit(SimStruct *S)
{
    return(rt_SimGetNextSampleHit(ssGetTimingData(S),
                                  ssGetNumSampleTimes(S)));
}

#   endif

# else /* MULTITASKING */

time_T rt_UpdateDiscreteEvents(SimStruct *S)
{
    return(rt_SimUpdateDiscreteEvents(
               ssGetNumSampleTimes(S),
               ssGetTimingData(S),
               ssGetSampleHitPtr(S),
               ssGetPerTaskSampleHitsPtr(S)));
}

void rt_UpdateDiscreteTaskTime(SimStruct *S, int tid)
{
    rt_SimUpdateDiscreteTaskTime(ssGetTPtr(S), ssGetTimingData(S), tid);
}

#endif
#endif
#else /* !ifndef ERT_CORE *******************/
const char *rt_SimInitTimingEngine(int_T       rtmNumSampTimes,
                                   real_T      rtmStepSize,
                                   real_T      *rtmSampleTimePtr,
                                   real_T      *rtmOffsetTimePtr,
                                   int_T       *rtmSampleHitPtr,
                                   int_T       *rtmSampleTimeTaskIDPtr,
                                   real_T      rtmTStart,
                                   SimTimeStep *rtmSimTimeStepPtr,
                                   void        **rtmTimingDataPtr)
{
    if (rtmTStart != 0.0) {
        return("Start time must be zero for real-time systems");
    } else {
        return(NULL);
    }
}
#if !defined(MULTITASKING)

/* SINGLE TASKING */
time_T rt_SimGetNextSampleHit(void){
 return -1;
}

void rt_SimUpdateDiscreteTaskSampleHits(int_T  rtmNumSampTimes,
                                        void   *rtmTimingData,
                                        int_T  *rtmSampleHitPtr,
                                        real_T *rtmTPtr)
{
    return;
}
#else /* defined(MULTITASKING) */

void rt_SimUpdateDiscreteTaskTime(real_T *rtmTPtr,
                                  void   *rtmTimingData,
                                  int    tid)
{
    return;
}
#endif /* MULTITASKING */

#endif /* end of !ifndef ERT_CORE */
/* EOF: rt_sim.c */
