/*
 * Abstract:
 *   Main program for the Rapid Simulation target.
 *
 * Compiler specified defines:
 *      MODEL=modelname - Required.
 *	SAVEFILE        - Optional (non-quoted) name of MAT-file to create.
 *			  Default is <MODEL>.mat
 *      MULTITASKING    - Simulate multitasking mode.
 *
 * $Revision: 1.32.4.5 $
 * Copyright 1994-2004 The MathWorks, Inc.
 */


#include <float.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "tmwtypes.h"
#include "simstruc.h"
#include "rt_logging.h"
#include "rt_nonfinite.h"
#include "rsim.h"
#include "rsim_sup.h"

#include "ext_work.h"

#ifdef RSIM_WITH_SL_SOLVER
# ifdef __WATCOMC__
# define MATLABROOT  MATLAB_ROOT
#else
# define MATLABROOT   QUOTE(MATLAB_ROOT)
#ifdef  MATLAB_ROOTQ 
# define MATLABROOTQ  MATLAB_ROOTQ 
#else
# define MATLABROOTQ  QUOTE(MATLAB_ROOT)
#endif
#endif
#include "rsim_engine.h"
#else
#include "rt_sim.h"
#endif

/*=========*
 * Defines *
 *=========*/

#ifndef TRUE
#define FALSE (0)
#define TRUE  (1)
#endif

#ifndef EXIT_FAILURE
#define EXIT_FAILURE  1
#endif
#ifndef EXIT_SUCCESS
#define EXIT_SUCCESS  0
#endif

#ifndef MODEL
# error "must define MODEL"
#endif

#ifndef RSIM_WITH_SL_SOLVER
# ifndef NUMST
#  error "must define number of sample times, NUMST"
# endif
# ifndef NCSTATES
#  error "must define NCSTATES"
# endif
#endif

#define GOTO_EXIT_IF_ERROR(msg, cond)            \
        if (cond) {                           \
            (void)fprintf(stderr, msg, cond); \
            goto EXIT_POINT;                  \
        }

#define ERROR_EXIT(msg, cond)                 \
        if (cond) {                           \
            (void)fprintf(stderr, msg, cond); \
            return(EXIT_FAILURE);             \
        }

/*====================*
 * External functions *
 *====================*/
extern SimStruct *MODEL(void);

extern void MdlInitializeSizes(void);
extern void MdlInitializeSampleTimes(void);
extern void MdlStart(void);
extern void MdlOutputs(int_T tid);
extern void MdlUpdate(int_T tid);
extern void MdlTerminate(void);

#ifndef RSIM_WITH_SL_SOLVER
# if NCSTATES > 0
   extern void rt_CreateIntegrationData(SimStruct *S);
   extern void rt_UpdateContinuousStates(SimStruct *S);
# else
#  define rt_CreateIntegrationData(S)  ssSetSolverName(S,"FixedStepDiscrete");
#  define rt_UpdateContinuousStates(S) ssSetT(S,ssGetSolverStopTime(S));
# endif
#endif

#ifdef EXT_MODE
#  define rtExtModeSingleTaskUpload(S)                          \
   {                                                            \
        int stIdx;                                              \
        rtExtModeUploadCheckTrigger(ssGetNumSampleTimes(S));    \
        for (stIdx=0; stIdx<ssGetNumSampleTimes(S); stIdx++) {  \
            if (ssIsSampleHit(S, stIdx, 0 /*unused*/)) {        \
                rtExtModeUpload(stIdx,ssGetTaskTime(S,stIdx));  \
            }                                                   \
        }                                                       \
   }
#else
#  define rtExtModeSingleTaskUpload(S) /* Do nothing */
#endif

/*=============*
 * Global data *
 *=============*/

const char gblModelName[] = QUOTE(MODEL);
extern int gblTimeLimit;

#ifdef RSIM_WITH_SL_SOLVER

/* Function: rsimOutputLogUpdate ===============================================
 *
 */
static void rsimOutputLogUpdate(SimStruct* S)
{
    int_T nOutputTimes = ssGetNumOutputTimes(S);

#ifdef DEBUG_TIMING
    rsimDisplayTimingData(S,
                          sizeof(struct SimStruct_tag),
                          sizeof(struct _ssMdlInfo));
#endif

    rtExtModeOneStep(ssGetRTWExtModeInfo(S),
                     ssGetNumSampleTimes(S),
                     (boolean_T*)&ssGetStopRequested(S));

    rsimUpdateDiscreteTaskSampleHits(S);
    if (ssGetErrorStatus(S) != NULL) return;

    ssSetLogOutput(S, ( !ssGetOutputTimesOnly(S) ||
                        ( ssGetNumOutputTimes(S) > 0 &&
                          ssGetT(S) == ssGetNextOutputTime(S) ) ));
    MdlOutputs(0);

    rtExtModeSingleTaskUpload(S);

    if (ssGetLogOutput(S)) {

        (void)rt_UpdateTXYLogVars(ssGetRTWLogInfo(S), ssGetTPtr(S));
        if (ssGetErrorStatus(S) != NULL) return;

        if (nOutputTimes > 0) {
            int_T idx = ssGetOutputTimesIndex(S);
            if ( idx < nOutputTimes && ssGetT(S) == ssGetNextOutputTime(S) ) {
                ++idx;
                ssSetOutputTimesIndex(S, idx);
            }
        }
    }

    MdlUpdate(0);

    ssSetLogOutput(S, FALSE);
    ssSetTimeOfLastOutput(S, ssGetT(S));

    rsimUpdateTimingEngine(S);
    if (ssGetErrorStatus(S) != NULL) return;

    if (nOutputTimes > 0) {
        time_T solverStopTime = ssGetSolverStopTime(S);
        int_T  idx            = ssGetOutputTimesIndex(S);

        if (idx < nOutputTimes) {
            time_T nextOutputTime = ssGetNextOutputTime(S);
            if (nextOutputTime < solverStopTime) {
                ssSetSolverStopTime(S, nextOutputTime);
            }
        }
    }

    rtExtModeCheckEndTrigger();

    return;

} /* rsimOutputLogUpdate */


/* Function: rsimOneStep =======================================================
 *
 *      Perform one step of the model.
 *      Errors are set in the SimStruct's ErrorStatus, NULL means no errors.
 */
static void rsimOneStep(SimStruct *S)
{
    rsimOutputLogUpdate(S);
    if (ssGetErrorStatus(S) != NULL) return;

    rsimAdvanceSolver(S);

} /* rsimOneStep */

#else

#if !defined(MULTITASKING)  /* SINGLETASKING */

/* Function: rsimOneStep =======================================================
 *
 *      Perform one step of the model.
 *      Errors are set in the SimStruct's ErrorStatus, NULL means no errors.
 */
static void rsimOneStep(SimStruct *S)
{
    real_T tnext;

    if (ssGetErrorStatus(S) != NULL) return;

    rtExtModeOneStep(ssGetRTWExtModeInfo(S),
                     ssGetNumSampleTimes(S),
                     (boolean_T *)&ssGetStopRequested(S));

    tnext = rt_GetNextSampleHit();
    ssSetSolverStopTime(S,tnext);

    MdlOutputs(0);

    rtExtModeSingleTaskUpload(S);

    (void)rt_UpdateTXYLogVars(ssGetRTWLogInfo(S), ssGetTPtr(S));
    if (ssGetErrorStatus(S) != NULL) return;

    MdlUpdate(0);
    rt_UpdateDiscreteTaskSampleHits(S);

    if (ssGetSampleTime(S,0) == CONTINUOUS_SAMPLE_TIME) {
        rt_UpdateContinuousStates(S);
    }

    rtExtModeCheckEndTrigger();

} /* rsimOneStep */

#else /* MULTITASKING */

# if TID01EQ == 1
#  define FIRST_TID 1
# else
#  define FIRST_TID 0
# endif

/* Function: rsimOneStep =======================================================
 *
 *      Perform one step of the model in "simulated" multitasking mode
 *      Errors are set in the SimStruct's ErrorStatus, NULL means no errors.
 */
static void rsimOneStep(SimStruct* S)
{
    int_T  i;
    real_T tnext;
    int_T* sampleHit = ssGetSampleHitPtr(S);

    rtExtModeOneStep(ssGetRTWExtModeInfo(S),
                     ssGetNumSampleTimes(S),
                     (boolean_T*)&ssGetStopRequested(S));

    /* Update discrete events */
    tnext = rt_UpdateDiscreteEvents(S);
    ssSetSolverStopTime(S, tnext);

    /* Do output, log, update for the base rate */

    MdlOutputs(FIRST_TID);

    rtExtModeUploadCheckTrigger(ssGetNumSampleTimes(S));
    rtExtModeUpload(FIRST_TID, ssGetTaskTime(S, FIRST_TID));

    (void)rt_UpdateTXYLogVars(ssGetRTWLogInfo(S), ssGetTPtr(S));
    if (ssGetErrorStatus(S) != NULL) return;

    MdlUpdate(FIRST_TID);

    if (ssGetSampleTime(S,0) == CONTINUOUS_SAMPLE_TIME) {
        rt_UpdateContinuousStates(S);
    } else {
        rt_UpdateDiscreteTaskTime(S,0);
    }

#if FIRST_TID == 1
    rt_UpdateDiscreteTaskTime(S,1);
#endif

    /* Do output and update for the remaining rates */

    for (i=FIRST_TID+1; i<NUMST; i++) {
        if ( !sampleHit[i] ) continue;

        MdlOutputs(i);
        rtExtModeUpload(i, ssGetTaskTime(S,i));
        MdlUpdate(i);
        rt_UpdateDiscreteTaskTime(S, i);
    }

    rtExtModeCheckEndTrigger();

} /* end rsimOneStep */

#endif /* MULTITASKING */

#endif /* RSIM_WITH_SL_SOLVER */


/* Function: WriteResultsToMatFile =============================================
 *
 *     This function is called from main for normal exit or from the
 *     signal handler in case of abnormal exit (^C, time out etc).
 */
void WriteResultsToMatFile(SimStruct* S)
{
    rt_StopDataLogging(gblMatLoggingFilename,ssGetRTWLogInfo(S));
}

/* Function: main ==============================================================
 *
 *      Execute model on a generic target such as a workstation.
 */
int_T main(int_T argc, char_T *argv[])
{
    SimStruct  *S                 = NULL;
    boolean_T  calledMdlStart     = FALSE;
    boolean_T  dataLoggingActive  = FALSE;
    boolean_T  initializedExtMode = FALSE;
    int_T      exitStatus         = EXIT_FAILURE; /* assume */
    const char *result;
    const char *program;
    time_t     now;

    program = argv[0];

    /* No re-defining of data types allowed. */
    if ((sizeof(real_T)   != 8) ||
        (sizeof(real32_T) != 4) ||
        (sizeof(int8_T)   != 1) ||
        (sizeof(uint8_T)  != 1) ||
        (sizeof(int16_T)  != 2) ||
        (sizeof(uint16_T) != 2) ||
        (sizeof(int32_T)  != 4) ||
        (sizeof(uint32_T) != 4) ||
        (sizeof(boolean_T)!= 1)) {
        ERROR_EXIT("Error: %s\n", "Re-defining data types such as REAL_T is not supported by RSIM");
    }

    rt_InitInfAndNaN(sizeof(real_T));

    /* Parse arguments */
    result = ParseArgs(argc, argv);
    ERROR_EXIT("Error parsing input arguments: %s\n", result);

    /* Initialize the model */
    S = MODEL();
    ERROR_EXIT("Error during model registration: %s\n", ssGetErrorStatus(S));

    /* Override StopTime */
    if (gblFinalTime >= 0.0 || gblFinalTime == RUN_FOREVER) {
#ifdef RSIM_WITH_SL_SOLVER
        if (gblFinalTime == RUN_FOREVER)
        {
            ssSetTFinal(S, rtInf);
        }
        else
#endif
        {
            ssSetTFinal(S,gblFinalTime);
        }
    }

    MdlInitializeSizes();
    MdlInitializeSampleTimes();

#ifdef RSIM_WITH_SL_SOLVER

    /* load solver options */
    rsimLoadSolverOpts(S);
    ERROR_EXIT("Error loading solver options: %s\n", ssGetErrorStatus(S));

# if defined(DEBUG_SOLVER)
  rsimEnableDebugOutput(sizeof(struct SimStruct_tag),sizeof(struct _ssMdlInfo));
# endif

    rsimInitializeEngine(program, MATLABROOTQ, S);
    ERROR_EXIT("Error initializing RSIM engine: %s\n", ssGetErrorStatus(S));

#else

    result = rt_InitTimingEngine(S);
    ERROR_EXIT("Error initializing sample time engine: %s\n", result);
    rt_CreateIntegrationData(S);
    ERROR_EXIT("Error creating integration data: %s\n", ssGetErrorStatus(S));

#endif /* RSIM_WITH_SL_SOLVER */

    result = rt_StartDataLogging(ssGetRTWLogInfo(S),
                                 ssGetTFinal(S),
                                 0.0, /* to force log vars to be realloc'ed */
                                 &ssGetErrorStatus(S));
    GOTO_EXIT_IF_ERROR("Error starting data logging: %s\n", result);
    dataLoggingActive = TRUE;

    result = ReadMatFileAndUpdateParams(S);
    GOTO_EXIT_IF_ERROR("Error reading parameter data from mat-file: %s\n", result);

    /*******************
     * Start the model *
     *******************/
    rtExtModeCheckInit(ssGetNumSampleTimes(S));
    initializedExtMode = TRUE;
    rtExtModeWaitForStartPkt(ssGetRTWExtModeInfo(S),
                             ssGetNumSampleTimes(S),
                             (boolean_T *)&ssGetStopRequested(S));

    now = time(NULL);
    (void)printf("\n** Starting model '%s' @ %s", gblModelName, ctime(&now));

    MdlStart();
    calledMdlStart = TRUE;
    GOTO_EXIT_IF_ERROR("Error starting model: %s\n", ssGetErrorStatus(S));

    result = CheckRemappings();
    if (result != NULL) goto EXIT_POINT;

    /*********************
     * Execute the model *
     *********************/

    if (gblFinalTime == RUN_FOREVER) {
        printf("\n** May run forever. Model stop time set to infinity.\n");
    }

#ifdef RSIM_WITH_SL_SOLVER
    /* Install Signal and Run time limit handlers */
    if ( rsimInstallHandlers(S,(void*)WriteResultsToMatFile,gblTimeLimit) ) {
        return(EXIT_FAILURE);
    }
#endif

    while ( (gblFinalTime == RUN_FOREVER) ||
            ((ssGetTFinal(S)-ssGetT(S)) > (ssGetT(S)*DBL_EPSILON)) ) {

        rtExtModePauseIfNeeded(ssGetRTWExtModeInfo(S),
                               ssGetNumSampleTimes(S),
                               (boolean_T *)&ssGetStopRequested(S));

        if (ssGetStopRequested(S)) break;

        rsimOneStep(S);
        if (ssGetErrorStatus(S)) break;
    }
    if (ssGetErrorStatus(S) == NULL && !ssGetStopRequested(S)) {
#ifdef RSIM_WITH_SL_SOLVER
        /* Do a major step at the final time */
        rsimOutputLogUpdate(S);
#else
        rsimOneStep(S);
#endif
    }

    if (ssGetErrorStatus(S) != NULL) {
        (void)fprintf(stderr,"Model execution error: %s\n",
                      ssGetErrorStatus(S));
    } else {
        exitStatus = EXIT_SUCCESS;
    }

EXIT_POINT:
    /********************
     * Cleanup and exit *
     ********************/

    if (S) {
#ifdef RSIM_WITH_SL_SOLVER
        rsimTerminateEngine(S);
        if (ssGetErrorStatus(S) != NULL) {
            (void)fprintf(stderr,
                          "Error terminating RSIM Engine: %s\n",
                          ssGetErrorStatus(S));
            return(EXIT_FAILURE);
        }
#endif
        if (dataLoggingActive) {
            WriteResultsToMatFile(S);
        }
    }

    if (initializedExtMode) {
        rtExtModeShutdown(ssGetNumSampleTimes(S));
    }

    if (calledMdlStart) {
        MdlTerminate();
    }

    FreeGbls();

    if (result != NULL) {
        if (result[0] != '\n') {
            (void)fprintf(stderr,"Error: %s\n",result);
        } else {
            (void)fprintf(stderr,"%s",result);
        }
    }

    return(exitStatus);

} /* end main */

/* EOF */
