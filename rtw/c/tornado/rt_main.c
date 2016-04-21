/*
 * Copyright 1994-2004 The MathWorks, Inc.
 *
 * File: rt_main.c     $Revision: 1.48.4.4 $
 *
 * Abstract:
 *  The real-time main program for targetting Tornado/VxWorks.
 *  
 *  The code works by attaching a semaphore to the Aux clock interrupt.
 *  Each clock tick, a semaphore is given that runs a task to execute and
 *  advance the model one time step.  That task may in turn start the 
 *  execution of several sub-tasks(in multitasking mode), each performing
 *  one sample rate in a multi-rate system.
 *  
 *  There are 2 modes that the model can be executed in, multitasking
 *  and singletasking, the default mode is singletasking.  If the model
 *  has only 1 state or has 2 states, 1 continuous and 1 discrete but
 *  they have equal rates, the model is forced to run in the 
 *  singletasking mode.  Otherwise the user can run the model in either
 *  mode by using the OPTS=-DMT macro in the make command field of the RTW 
 *  page dialog.  Depending on the model, one mode will be able to achieve
 *  higher sample rates than the other.
 *  In order to build the model for multitasking mode, Zero-Order Hold
 *  and Unit Delay blocks are needed between blocks with different sample
 *  rates.  They are required to ensure proper execution of the model.
 *  See the RTW User's Guide for more information.  
 *
 *  NOTES:
 *  A makefile is provided; it can be used to compile this code.  You
 *  should first edit it to reflect your host system and target system
 *  configurations.
 *   
 *  When using mat file logging or StethoScope, signals are sampled in 
 *  the base rate task asynchronously from slower rate tasks.  Therefore,
 *  when running the model in multitasking mode, signals sampled from slower
 *  rate blocks in the model may change at different base rate sample times
 *  from run to run of the model.  To remove this variation, run the model
 *  in singletasking mode.
 *
 *  When using external mode, parameter downloading is performed by a 
 *  background (lower priority) task which can get preempted by the model
 *  tasks(tBaseRate, tSingleRate, tRateN).  Thus, a given parameter update is
 *  not guaranteed to complete within one base rate sample time of the model.
 *
 *  Using the Tornado Browser or Shell while the model is running can cause
 *  a "rate to fast" error  because the tWdbTask has a priority of 3 which
 *  is higher than the tasks create for model execution.
 *   
 *  Defines automatically generated during build:
 *	RT              - Required. real-time.
 *      MODEL           - Required. model name.
 *	NUMST=#         - Required. Number of sample times.
 *	NCSTATES=#      - Required. Number of continuous states.
 *      TID01EQ=1 or 0  - Required. Only define to 1 if sample time task
 *                        id's 0 and 1 have equal rates.
 *
 *  Defines controlled from the RTW page make command dialog:
 *      MULTITASKING    - Optional. To enable multitasking mode.
 *                        Use the OPTS=-DMT macro in the dialog.
 *      EXT_MODE        - Optional. Simulink External Mode.
 *                        Use the EXT_MODE=1 macro in the dialog.
 *      VERBOSE         - Optional. To enable verbose external mode.
 *                        Use the OPTS=-DVERBOSE macro in the dialog.
 *      STETHOSCOPE     - Optional. Data collection/graphical monitoring.
 *                        Use the STETHOSCOPE=1 macro in the dialog.
 *      MAT_FILE        - Optional. MAT File Logging.
 *                        Use the MAT_FILE=1 macro in the dialog.
 *	SAVEFILE        - Optional. (non-quoted) name of .mat file to create. 
 *                        Use the OPTS="-DSAVEFILE=filename" macro.
 *                        Use if name is desired other than MODEL.mat for the
 *                        mat log file or device other than the current VxWorks
 *                        default device is desired.
 *
 *  Defines controlled from this file.
 *      STOPONOVERRUN   - Optional. Comment out below to ignore rate overruns.
*/

/*****************
 * Include files *
 *****************/

/*ANSI C headers*/
#include <float.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>

/*VxWorks headers*/
#include <vxWorks.h>
#include <taskLib.h>
#include <sysLib.h>
#include <semLib.h>
#include <rebootLib.h>
#include <logLib.h>

/*Real-Time Workshop headers*/
#include "tmwtypes.h"  
#include "rtmodel.h"
#include "rt_sim.h"
#include "rt_nonfinite.h"

/*Stethoscope header*/
#ifdef STETHOSCOPE
#include <string.h>
#include <ctype.h>
#include "bio_sig.h"
typedef int boolean;
#include "scope/scope.h" 
#endif

/*External Mode header*/
#ifdef EXT_MODE
#include "ext_work.h"
#endif

/*MAT File header*/
#ifdef MAT_FILE
#include "rt_logging.h"
#endif

/*******************************************************************
 * Comment out the following define to cause program to print a    *
 * warning message, but continue executing when an overrun occurs. *
 *******************************************************************/
#define STOPONOVERRUN

#ifndef BASE_PRIORITY
#define BASE_PRIORITY		(30)
#endif

#if TID01EQ == 1
#define FIRST_TID 1
#else
#define FIRST_TID 0
#endif

#ifndef RT
# error "must define RT"
#endif

#ifndef MODEL
# error "must define MODEL"
#endif

#ifndef NUMST
# error "must define number of sample times, NUMST"
#endif

#ifndef NCSTATES
# error "must define NCSTATES"
#endif

#define QUOTE1(name) #name
#define QUOTE(name) QUOTE1(name)    /* need to expand name    */

/*NOTE: The default location for the .mat file is the root directory of
 * the VxWorks default device which is typically the file system that 
 * VxWorks was booted from.*/

#ifndef SAVEFILE
# define MATFILE2(file) "/" #file ".mat"
# define MATFILE1(file) MATFILE2(file)
# define MATFILE MATFILE1(MODEL)
#else
# define MATFILE QUOTE(SAVEFILE)
#endif

#define RUN_FOREVER -1.0

#define EXPAND_CONCAT(name1,name2) name1 ## name2
#define CONCAT(name1,name2) EXPAND_CONCAT(name1,name2)
#define RT_MODEL            CONCAT(MODEL,_rtModel)

/**********************
 * External functions *
 **********************/

#ifndef RT_MALLOC
  extern void MdlInitializeSizes(void);
  extern void MdlInitializeSampleTimes(void);
  extern void MdlStart(void);
  extern void MdlOutputs(int_T tid);
  extern void MdlUpdate(int_T tid);
  extern void MdlTerminate(void);

  #define INITIALIZE_SIZES(M)         MdlInitializeSizes()
  #define INITIALIZE_SAMPLE_TIMES(M)  MdlInitializeSampleTimes()
  #define START(M)                    MdlStart()
  #define OUTPUTS(M,tid)              MdlOutputs(tid)
  #define UPDATED(M,tid)              MdlUpdate(tid)
  #define TERMINATE(M)                MdlTerminate()
#else
  #define INITIALIZE_SIZES(M) \
          rtmiInitializeSizes(rtmGetRTWRTModelMethodsInfo(M));
  #define INITIALIZE_SAMPLE_TIMES(M) \
          rtmiInitializeSampleTimes(rtmGetRTWRTModelMethodsInfo(M));
  #define START(M) \
          rtmiStart(rtmGetRTWRTModelMethodsInfo(M));
  #define OUTPUTS(M,tid) \
          rtmiOutputs(rtmGetRTWRTModelMethodsInfo(M),tid);
  #define UPDATED(M,tid) \
          rtmiUpdate(rtmGetRTWRTModelMethodsInfo(M),tid);
  #define TERMINATE(M) \
          rtmiTerminate(rtmGetRTWRTModelMethodsInfo(M))

  const char *RT_MEMORY_ALLOCATION_ERROR = "memory allocation error"; 
#endif



#if NCSTATES > 0
  extern void rt_ODECreateIntegrationData(RTWSolverInfo *si);
  extern void rt_ODEUpdateContinuousStates(RTWSolverInfo *si);

# define rt_CreateIntegrationData(S) \
    rt_ODECreateIntegrationData(rtmGetRTWSolverInfo(S));
# define rt_UpdateContinuousStates(S) \
    rt_ODEUpdateContinuousStates(rtmGetRTWSolverInfo(S));
# else
# define rt_CreateIntegrationData(S)  \
      rtsiSetSolverName(rtmGetRTWSolverInfo(S),"FixedStepDiscrete");
# define rt_UpdateContinuousStates(S) \
      rtmSetT(S, rtsiGetSolverStopTime(rtmGetRTWSolverInfo(S)));
#endif

/***************
 * Global data *
 ***************/

static RT_MODEL *rtM;

SEM_ID volatile startStopSem = NULL;

#ifdef EXT_MODE
#  define rtExtModeSingleTaskUpload(S)                          \
   {                                                            \
        int stIdx;                                              \
        rtExtModeUploadCheckTrigger(rtmGetNumSampleTimes(rtM)); \
        for (stIdx=0; stIdx<NUMST; stIdx++) {                   \
            if (rtmIsSampleHit(S, stIdx, 0 /*unused*/)) {       \
                rtExtModeUpload(stIdx,rtmGetTaskTime(S,stIdx)); \
            }                                                   \
        }                                                       \
   }
#else
#  define rtExtModeSingleTaskUpload(S) /* Do nothing */
#endif

/*******************
 * Local functions *
 *******************/

#ifdef STETHOSCOPE
/* Function: rtInstallRemoveSignals =========================================
 * Abstract:
 *  Setup for stethoscope usage
 */
static int_T rtInstallRemoveSignals(RT_MODEL *rtM, char_T *installStr,
				     int_T fullNames, int_T install)
{
  uint_T                  i, w;
  char_T                 *blockName;
  char_T                 name[1024];
  extern BlockIOSignals  rtBIOSignals[];
  int_T                  ret = -1;
  
  if (installStr == NULL) {
    return -1;
  }

  i = 0;
  while(rtBIOSignals[i].blockName != NULL) {
    BlockIOSignals *blockInfo = &rtBIOSignals[i++];
    
    if (fullNames) {
      blockName = blockInfo->blockName;
    } else {
      blockName = strrchr(blockInfo->blockName, '/');
      if (blockName == NULL) {
	blockName = blockInfo->blockName;
      } else {
	blockName++;
      }
    }

    if ((*installStr) == '*') {
    } else if (strcmp("[A-Z]*", installStr) == 0) {
      if (!isupper(*blockName)) {
	continue;
      }
    } else {
      if (strncmp(blockName, installStr, strlen(installStr)) != 0) {
	continue;
      }
    }
    /*install/remove the signals*/
    for (w = 0; w < blockInfo->signalWidth; w++) {
      sprintf(name, "%s_%d_%s_%d", blockName, blockInfo->portNumber,
	      !strcmp(blockInfo->signalName,"NULL")?"":blockInfo->signalName, w);
      if (install) { /*install*/
          if (!ScopeInstallSignal(name, "units", 
                                  (void *)((int)blockInfo->signalAddr + 
                                           w*blockInfo->dtSize),
                                  blockInfo->dtName, 0)) {
              fprintf(stderr,"rtInstallRemoveSignals: ScopeInstallSignal "
                      "possible error: over 256 signals.\n");
              return -1;
          } else {
              ret =0;
          }
      } else { /*remove*/
	if (!ScopeRemoveSignal(name, 0)) {
	  fprintf(stderr,"rtInstallRemoveSignals: ScopeRemoveSignal\n"
		  "%s not found.\n",name);
	} else {
          ret =0;
        }
      }
    }
  }
  return ret;
}
#endif	/* STETHOSCOPE */

/* Function: rtSetSampleRate ===================================================
 * Abstract:
 *	This routine changes the interrupt frequency to the closest available
 *	approximation to ``requestedSR''.  This will not in general be 
 *	exactly the same as requestedSR, as the hardware timer being used has 
 *	a finite resolution.  This routine sets the sample rate of the fastest 
 *	loop rate.  The other models (if present) are set to their appropriate
 *	scaled values.
 *
 *	StethoScope and the model (via rtmSetStepSize) are informed of the 
 *	change, being careful to provide the actual rate in effect (since it 
 *	may be rounded).  However, there is no guarantee the model will 
 *	calculate reasonable results with at the new rate.
 *
 * Returns: 
 *	The actual sample rate achieved.
 *
 */
real_T rtSetSampleRate(real_T requestedSR)
{
  real_T actualSR;
  
  if (requestedSR <= 0.0) {
    fprintf(stderr,"Choose a sample rate > 0.0\n");
    exit(EXIT_FAILURE);
  }
  /* Set the rate of the auxiliary clock */
  sysAuxClkRateSet((int_T) (requestedSR + 0.5));
  
  actualSR = (real_T) sysAuxClkRateGet();
  if ((actualSR/requestedSR > 1.1) || (actualSR/requestedSR < 0.9)) {
    fprintf(stderr,"rtSetSampleRate: requested rate (%f Hz)\n"
	    "not achievable, actual sampling rate is %f Hz\n", 
	    requestedSR, actualSR);
    fprintf(stderr,"\nLook into AUX_CLK_RATE_MIN,AUX_CLK_RATE_MAX in targets "
	    "config.h\nand sysAuxClkRateSet(), sysAuxClkEnable() source code "
	    "for a better\nunderstanding of rates allowable.\n");
  }
  
#ifdef STETHOSCOPE
  /* Tell Scope the "actual" sample rate */
  ScopeChangeSampleRate(actualSR, 0);
#endif	/* STETHOSCOPE */
  
  return(actualSR);
}


#ifdef MULTITASKING

/* Function: tSubRate ==========================================================
 * Abstract:
 *  This is the entry point for each sub-rate task.  This task simply executes
 *  the appropriate  blocks in the model each time the passed semaphore is
 *  given.  This routine never returns.
 */
static int_T tSubRate(RT_MODEL *rtM, SEM_ID sem, int_T i)
{
    while(1) {
        semTake(sem, WAIT_FOREVER);

        OUTPUTS(rtM,i);
#ifdef EXT_MODE
        rtExtModeUpload(i, rtmGetTaskTime(rtM,i));
#endif
        UPDATED(rtM,i);

        rt_SimUpdateDiscreteTaskTime(rtmGetTPtr(rtM),
                                     rtmGetTimingData(rtM),i);
    }
    return(1);
} /* end tSubRate */


/* Function: tBaseRate =========================================================
 * Abstract:
 *  This is the entry point for the base-rate task.  This task executes
 *  the fastest rate blocks in the model each time its semaphore is given
 *  and gives semaphores to the sub tasks if they need to execute.
 */
static int_T tBaseRate(
    RT_MODEL *rtM,
    SEM_ID    sem,
    SEM_ID    startStopSem,
    SEM_ID    taskSemList[])
{
    int_T  i;
    real_T tnext;
    int_T  finalstep = 0;
    int_T  *sampleHit = rtmGetSampleHitPtr(rtM);
    
    while(1) {
        /***********************************
         * Check and see if stop requested *
         ***********************************/
        if (rtmGetStopRequested(rtM)) {
            semGive(startStopSem);
            return(0);
        }
        
        /***************************************
         * Check and see if final time reached *
         ***************************************/
        if (rtmGetTFinal(rtM) != RUN_FOREVER &&
            rtmGetTFinal(rtM)-rtmGetT(rtM) <= rtmGetT(rtM)*DBL_EPSILON) {
            if (finalstep) {
                semGive(startStopSem);
                return(0);
            }
            finalstep = 1;
        }
        
        /***********************************************
         * Check and see if error status has been set  *
         ***********************************************/
        if (rtmGetErrorStatus(rtM) != NULL) {
            fprintf(stderr,"%s\n", rtmGetErrorStatus(rtM));
            semGive(startStopSem);
            return(1);
        }
        
        if (semTake(sem,NO_WAIT) != ERROR) {
            logMsg("Rate for BaseRate task too fast.\n",0,0,0,0,0,0);
#ifdef STOPONOVERRUN
            logMsg("Aborting real-time simulation.\n",0,0,0,0,0,0);
            semGive(startStopSem);
            return(1);
#endif
        } else {
            semTake(sem, WAIT_FOREVER);
        }
        
        tnext = rt_SimUpdateDiscreteEvents(rtmGetNumSampleTimes(rtM),
                                           rtmGetTimingData(rtM),
                                           rtmGetSampleHitPtr(rtM),
                                           rtmGetPerTaskSampleHitsPtr(rtM));
        rtsiSetSolverStopTime(rtmGetRTWSolverInfo(rtM),tnext);
        for (i = FIRST_TID + 1; i < NUMST; i++) {
            if (sampleHit[i]) {
                /* Signal any lower priority tasks that have a hit,
                 * then check to see if task took sema (i.e. is it  
                 * blocking).  If not, it means that task did not 
                 * finish in its alloted time period.
                 *
                 * NOTE:These tasks won't run until tBaseRate blocks
                 * on semTake(sem, WAIT_FOREVER) above.
                 */
                semGive(taskSemList[i]);
                if (semTake(taskSemList[i],NO_WAIT) != ERROR) {
                    logMsg("Rate for SubRate task %d is too fast.\n",i,0,0,0,0,0);
#ifdef STOPONOVERRUN
                    logMsg("Aborting real-time simulation.\n",0,0,0,0,0,0);
                    semGive(startStopSem);
                    return(1);
#endif
                    semGive(taskSemList[i]);
                }
                
            }
        }
        
        /*******************************************
         * Step the model for the base sample time *
         *******************************************/
        OUTPUTS(rtM,FIRST_TID);
        
#ifdef EXT_MODE
        rtExtModeUploadCheckTrigger(rtmGetNumSampleTimes(rtM));
        rtExtModeUpload(FIRST_TID,rtmGetTaskTime(rtM, FIRST_TID));
#endif

#ifdef MAT_FILE
        if (rt_UpdateTXYLogVars(rtmGetRTWLogInfo(rtM),
                                rtmGetTPtr(rtM)) != NULL) {
            fprintf(stderr,"rt_UpdateTXYLogVars() failed\n");
            return(1);
        }
#endif
        
#ifdef STETHOSCOPE
        ScopeCollectSignals(0);
#endif
        
        UPDATED(rtM,FIRST_TID);
        
        if (rtmGetSampleTime(rtM,0) == CONTINUOUS_SAMPLE_TIME) {
            rt_UpdateContinuousStates(rtM);
        } else {
            rt_SimUpdateDiscreteTaskTime(rtmGetTPtr(rtM),
                                         rtmGetTimingData(rtM),0);
        }
#if FIRST_TID == 1
        rt_SimUpdateDiscreteTaskTime(rtmGetTPtr(rtM),
                                     rtmGetTimingData(rtM),1);
#endif

#ifdef EXT_MODE
        rtExtModeCheckEndTrigger();
#endif
    }  /* end while(1) */
    return(1);
} /* end tBaseRate */

#else /*SingleTasking*/

/* Function: tSingleRate ========================================================
 * Abstract:
 *	This is the entry point for the single-rate task.  This task executes
 *      all required blocks in the model each time its semaphore is given.
 */
static int_T tSingleRate(RT_MODEL *rtM, SEM_ID sem, SEM_ID startStopSem)
{
    real_T tnext;
    int_T  finalstep = 0;
    
    while(1) {
        /***********************************
         * Check and see if stop requested *
         ***********************************/
        if (rtmGetStopRequested(rtM)) {
            semGive(startStopSem);
            return(0);
        }
        
        /***************************************
         * Check and see if final time reached *
         ***************************************/
        if (rtmGetTFinal(rtM) != RUN_FOREVER &&
            rtmGetTFinal(rtM)-rtmGetT(rtM) <= rtmGetT(rtM)*DBL_EPSILON) {
            if (finalstep) {
                semGive(startStopSem);
                return(0);
            }
            finalstep = 1;
        }
        
        /***********************************************
         * Check and see if error status has been set  *
         ***********************************************/
        if (rtmGetErrorStatus(rtM) != NULL) {
            fprintf(stderr,"%s\n", rtmGetErrorStatus(rtM));
            semGive(startStopSem);
            return(1);
        }
        
        if (semTake(sem,NO_WAIT) != ERROR) {
            logMsg("Rate for SingleRate task too fast.\n",0,0,0,0,0,0);
#ifdef STOPONOVERRUN
            logMsg("Aborting real-time simulation.\n",0,0,0,0,0,0);
            semGive(startStopSem);
            return(1);
#endif
        } else {
            semTake(sem, WAIT_FOREVER);
        }
        
#if defined(RT_MALLOC)
        tnext = rt_SimGetNextSampleHit(rtmGetTimingData(rtM),
                                       rtmGetNumSampleTimes(rtM));
#else
        tnext = rt_SimGetNextSampleHit();
#endif
        rtsiSetSolverStopTime(rtmGetRTWSolverInfo(rtM),tnext);

        /*******************************************
         * Step the model for the all sample times *
         *******************************************/
        OUTPUTS(rtM,0);

#ifdef EXT_MODE
        rtExtModeSingleTaskUpload(rtM);
#endif
        
#ifdef MAT_FILE
        if (rt_UpdateTXYLogVars(rtmGetRTWLogInfo(rtM),
                                rtmGetTPtr(rtM)) != NULL) {
            fprintf(stderr,"rt_UpdateTXYLogVars() failed\n");
            return(1);
        }
#endif
        
#ifdef STETHOSCOPE
        ScopeCollectSignals(0);
#endif
        
        UPDATED(rtM,0);
        rt_SimUpdateDiscreteTaskSampleHits(rtmGetNumSampleTimes(rtM),
                                           rtmGetTimingData(rtM),
                                           rtmGetSampleHitPtr(rtM),
                                           rtmGetTPtr(rtM));
        
        if (rtmGetSampleTime(rtM,0) == CONTINUOUS_SAMPLE_TIME) {
            rt_ODEUpdateContinuousStates(rtmGetRTWSolverInfo(rtM));
        }

#ifdef EXT_MODE
        rtExtModeCheckEndTrigger();
#endif
    }  /*end while(1)*/
    return(1);
} /* end tSingleRate */

#endif /*MULTITASKING*/


/* Function: PrintUsageMsg =====================================================
 * Abstract:
 *  Print message describing the usage of rt_main (i.e., how it should be
 *  invoked - API).
 */
static void PrintUsageMsg(void)
{
    printf("\nInvalid command line arguments:\n");
    printf(
        "Usage: "
        "rt_main(\n"
        "\tRT_MODEL * (*model_name)(void),\n"
        "\tchar_T *optStr,\n"
        "\tchar_T *scopeInstallString,\n"
        "\tint_T scopeFullNames,\n"
        "\tint_T priority)\n\nwhere,\n\n");

    printf("optStr is an option string of the form:\n\t"
           "-option1 val1 -option2 val2 -option3\n\n");

    printf("\tValid options are:\n");
    printf("\t-tf 20    - sets final time to 20 seconds\n");
} /* end PrintUsageMsg */


/* Function: CountStrs =========================================================
 * Abstract:
 *  Count the number of space delimited strings.
 */
static int CountStrs(const char_T *str)
{
    int          count   = 0;
    const char_T *strPtr = str;

    while(*strPtr != '\0') {
        /* find substring */
        while (isspace(*strPtr)) strPtr++;
        count++;
        strPtr++;

        /* move over this substring */
        while ((!isspace(*strPtr)) && (*strPtr != '\0')) strPtr++;
    }
    return(count);
} /* end CountStrs */


/* Function: GetNextStr ========================================================
 * Abstract:
 *  Assuming an input string that consists of space seperators return a pointer
 *  to the next string, replace the space delimiter with '\0' and return
 *  a pointer to the next non-white space character (or NULL if end of string).
 *
 *  str = "  cat dog";
 *  
 *  GetNextStr returns:
 *      strPtr     = pointer to 'c' (or NULL if no non-space char)
 *      strPtrNext = pointer to 'd' (or NULL if end of string)
 */
static char_T *GetNextStr(char_T *str, char_T **strPtrNext)
{
    int_T  done    = TRUE; /* assume */
    char_T *strPtr = NULL; /* assume */

    *strPtrNext = NULL; /* assume */

    /*
     * Find beginning of this sub-string.
     */
    while (isspace(*str)) {
        str++;
        if (*str == '\0') {
            /* reached end of string */
            goto EXIT_POINT;
        }
    }

    strPtr = str++;

    /*
     * Find end of this sub-string and make sure that it terminates with '\0'.
     */
    while (!isspace(*str) && (*str != '\0')) {
        str++;
    }
    if (*str != '\0') {
        done = FALSE;
        *str = '\0';
    }

    /*
     * Return a pointer to the next subString (or NULL) if at string end.
     */
    if (!done) {
        str++;
        while(isspace(*str)) {
            str++;
            if (*str == '\0') {
                break;
            }
        }
        *strPtrNext = (*str == '\0') ? NULL : str;
    } else {
        *strPtrNext = NULL;
    }
    
EXIT_POINT:
    return(strPtr);
} /* end GetNextOptionStr */


/*********************
 * Visible functions *
 *********************/

/* Function: rt_main ===========================================================
 * Abstract:
 *  Initialize the Simulink model pointed to by "model_name" and start
 *  model execution.
 *
 *  This routine spawns a task to execute the passed model.  It will 
 *  optionally initialize StethoScope (via ScopeInitServer), if it hasn't
 *  already been done.  It also optionally sets up external mode 
 *  communications channels to Simulink.
 *
 * Parameters:
 *  
 *  "model_name" is the entry point for the Simulink-generated code 
 *  and is the same as the Simulink block diagram model name.
 *
 *  "optStr" is an option string of the form:
 *      -option1 val1 -option2 val2 -option3
 *
 *      for example, "-tf 20 -w" instructs the target program to use a stop time
 *      of 20 and to wait (in external mode) for a message from Simulink
 *      before starting the "simulation".  Note that -tf inf sets the stop time to
 *      infinity.
 *
 *  "scopeInstallString" determines which signals will be installed to
 *  StethoScope.  If scopeInstallString is NULL (the default) no signals
 *  are installed.  If it is "*", then all signals are installed.  If it
 *  is "[A-Z]*", signals coming from blocks whose names start with capital
 *  letters will be installed. If it is any other string, then signals 
 *  starting with that string are installed.  
 *
 *  "scopeFullNames" parameter determines how signals are named: if
 *  0, the block names are used, if 1, then the full hierarchical 
 *  name is used.
 *
 *  "priority" is the priority at which the model's highest priority task
 *  will run.  Other model tasks will run at successively lower priorities
 *  (i.e., high priority numbers).
 *
 * Example:
 *  To run the equalizer example from windsh, with printing of external mode
 *  information, use:
 *  
 *      sp(rt_main,vx_equal,"0.0", "*", 0, 30)
 *
 * Returns:
 *  EXIT_SUCCESS on success.
 *  EXIT_FAILURE on failure.
 */
int_T rt_main(
    RT_MODEL * (*model_name)(void),
    char_T      *optStr,
    char_T      *scopeInstallString,
    int_T       scopeFullNames,
    int_T       priority,
    int_T       port)
{
    const char *status;
    int_T      VxWorksTIDs[NUMST];
    int        optStrLen       = strlen(optStr);
    SEM_ID     rtClockSem      = NULL;
    int_T      parseError      = FALSE;
    double     finaltime       = -2.0;
    int        argc            = 0;
    char_T     **argv          = NULL;
 
#ifdef MULTITASKING  
    SEM_ID     rtTaskSemaphoreList[NUMST];
    int_T      i;
#endif

    /*
     * Do error checking on input args and parse the options string.
     */
    if (model_name == NULL) {
        parseError = TRUE;
        goto PARSE_EXIT;
    }

    /* 
     * Parse option string.
     */
    if ((optStr != NULL) && (optStrLen > 0)) {
        int    i;
        int    count;
        char_T *thisStr;
        char_T *nextStr;

        /*
         * Convert to lower case.
         */
        for (i=0; i<optStrLen; i++) {
            optStr[i] = tolower(optStr[i]);
        }

        /*
         * Convert error string to standard argc and argv format. 
         */
        
        /* count strings and allocate an argv */
        argc = CountStrs(optStr) + 1;

        argv = (char **)calloc(argc,sizeof(char *));
        if (argv == NULL) {
            (void)fprintf(stderr,
                "Memory allocation error while parsing options string.");
            exit(EXIT_FAILURE);
        }
        
        /* populate argv & terminate the individual substrings */
        argv[0] = "dummyProgramName";
	i=1;
	nextStr = optStr;
        while ((nextStr != NULL) && (thisStr = GetNextStr(nextStr, &nextStr)) != NULL && ( i < argc )) {
            argv[i] = thisStr;
	    i++;
        }

        /*
         * Parse the standard RTW parameters.  Let all unrecognized parameters
         * pass through to external mode for parsing.  NULL out all args handled
         * so that the external mode parsing can ignore them.
         */
        count = 1;
        while(count < argc) {
            const char_T *option = argv[count++];
            
            /* final time */
            if ((strcmp(option, "-tf") == 0) && (count != argc)) {
                char_T       tmpstr[2];
                char_T       str2[200];
                double       tmpDouble;
                const char_T *tfStr = argv[count++];
                
                sscanf(tfStr, "%200s", str2);
                if (strcmp(str2, "inf") == 0) {
                    tmpDouble = RUN_FOREVER;
                } else {
                    char_T tmpstr[2];

                    if ( (sscanf(str2, "%lf%1s", &tmpDouble, tmpstr) != 1) ||
                         (tmpDouble < 0.0) ) {
                        (void)printf("finaltime must be a positive, real value or inf\n");
                        parseError = TRUE;
                        break;
                    }
                }
                finaltime = (real_T) tmpDouble;

                argv[count-2] = NULL;
                argv[count-1] = NULL;
            }
        }

        if (parseError) {
            PrintUsageMsg();
            goto PARSE_EXIT;
        }

#ifdef EXT_MODE
        rtExtModeParseArgs(argc, (const char_T **)argv, NULL);
        rtExtModeTornadoSetPortInExtUD(port);
#endif

        /*
         * Check for unprocessed ("unhandled") args.
         */
        {
            int i;
            for (i=1; i<argc; i++) {
                if (argv[i] != NULL) {
		    if (strcmp(argv[i], "-w") == 0) {
			printf("Ignoring command line argument: '-w'\n'-w' only applies to external mode.\n");
			continue;
		    } else {
			printf("Unexpected command line argument: %s\n Exiting\n",argv[i]);
			parseError = TRUE;
			goto PARSE_EXIT;
		    }
                }
            }
        }

PARSE_EXIT:
        free(argv);
        argv = NULL;
        if (parseError) {
            exit(EXIT_FAILURE);
        }
    }
        
    if (priority <= 0 || priority > 255-(NUMST)+1) {
        priority = BASE_PRIORITY;
    }

    /************************
     * Initialize the model *
     ************************/
    rt_InitInfAndNaN(sizeof(real_T));
  
    rtM = model_name();
    if (rtM == NULL) {
        (void)fprintf(stderr,"Memory allocation error during model "
                      "registration");
        exit(EXIT_FAILURE);
    }
    if (rtmGetErrorStatus(rtM) != NULL) {
        (void)fprintf(stderr,"Error during model registration: %s\n",
                      rtmGetErrorStatus(rtM));
        TERMINATE(rtM);
        exit(EXIT_FAILURE);
    }
    if (finaltime >= 0.0 || finaltime  == RUN_FOREVER) {
        rtmSetTFinal(rtM, (real_T)finaltime);
    }
    
    INITIALIZE_SIZES(rtM);
    INITIALIZE_SAMPLE_TIMES(rtM);
    status = rt_SimInitTimingEngine(rtmGetNumSampleTimes(rtM),
                                    rtmGetStepSize(rtM),
                                    rtmGetSampleTimePtr(rtM),
                                    rtmGetOffsetTimePtr(rtM),
                                    rtmGetSampleHitPtr(rtM),   
                                    rtmGetSampleTimeTaskIDPtr(rtM),
                                    rtmGetTStart(rtM),
                                    &rtmGetSimTimeStep(rtM),
                                    &rtmGetTimingData(rtM));

    if (status != NULL) {
        fprintf(stderr,
            "Failed to initialize sample time engine: %s\n", status);
        exit(EXIT_FAILURE);
    }
    rt_CreateIntegrationData(rtM);
#if defined(RT_MALLOC) && NCSTATES > 0
    if(rtmGetErrorStatus(rtM) != NULL) {
        fprintf(stderr, "Error creating integration data.\n");
        rt_ODEDestroyIntegrationData(rtmGetRTWSolverInfo(rtM));
        TERMINATE(rtM);
        exit(EXIT_FAILURE);
    }
#endif
    
#ifdef MAT_FILE
    if (rt_StartDataLogging(rtmGetRTWLogInfo(rtM),
                            rtmGetTFinal(rtM),
                            rtmGetStepSize(rtM),
                            &rtmGetErrorStatus(rtM)) != NULL) {
        fprintf(stderr,"Error starting data logging.\n");
        return(EXIT_FAILURE);
    }
#endif

    rtClockSem   = semBCreate(SEM_Q_PRIORITY, SEM_EMPTY);
    startStopSem = semBCreate(SEM_Q_PRIORITY, SEM_EMPTY);

#ifdef EXT_MODE
    rtExtModeTornadoStartup(rtmGetRTWExtModeInfo(rtM),
                            rtmGetNumSampleTimes(rtM),
                            (boolean_T *)&rtmGetStopRequested(rtM),
                            priority,
                            STACK_SIZE,
                            startStopSem);
#endif

    START(rtM);
    
    if (rtmGetErrorStatus(rtM) != NULL) {
        /* Need to execute MdlTerminate() before we can exit */
        goto TERMINATE;
    }
    
#ifdef STETHOSCOPE
    /* Make sure that Stethoscope has been properly initialized. */
    ScopeInitServer(4*32*1024, 4*2*1024, 0, 0);
    rtInstallRemoveSignals(rtM, scopeInstallString,scopeFullNames,1);
#endif
    
    sysAuxClkDisable();
    rtSetSampleRate(1.0 / rtmGetStepSize(rtM));
    
#ifdef MULTITASKING  
    
    for (i = FIRST_TID + 1; i < NUMST; i++) {
        static char taskName[20];
        
        sprintf(taskName, "tRate%d", i);

        rtTaskSemaphoreList[i] = semBCreate(SEM_Q_PRIORITY, SEM_EMPTY);

        VxWorksTIDs[i] = taskSpawn(taskName,
            priority + i, VX_FP_TASK, STACK_SIZE, tSubRate, (int_T) rtM,
            (int_T) rtTaskSemaphoreList[i], i,
            0, 0, 0, 0, 0, 0, 0);
    }
    
    VxWorksTIDs[0] = taskSpawn("tBaseRate",
        priority, VX_FP_TASK, STACK_SIZE, tBaseRate, (int_T) rtM, 
        (int_T) rtClockSem, (int_T) startStopSem, (int_T) rtTaskSemaphoreList,
        0, 0, 0, 0, 0, 0);

#else /*SingleTasking*/
    
    VxWorksTIDs[0] = taskSpawn("tSingleRate",
        priority, VX_FP_TASK, STACK_SIZE, tSingleRate, (int_T) rtM,
        (int_T) rtClockSem, (int_T) startStopSem,
        0, 0, 0, 0, 0, 0, 0);

#endif
    
    if (sysAuxClkConnect((FUNCPTR) semGive, (int_T) rtClockSem) == OK) {
        rebootHookAdd((FUNCPTR) sysAuxClkDisable);
        printf("\nSimulation Starting\n");
        sysAuxClkEnable();	/*start the real-time simulation*/
    }
    
    semTake(startStopSem, WAIT_FOREVER);
    
    /********************
    * Cleanup and exit *
    ********************/
    
    printf("\nSimulation Finished\n");
    sysAuxClkDisable();
    taskDelete(VxWorksTIDs[0]);
    
    semDelete(rtClockSem);
    semDelete(startStopSem);
    
#ifdef EXT_MODE
    rtExtModeTornadoCleanup(rtmGetNumSampleTimes(rtM));
#endif
    
#ifdef STETHOSCOPE
    rtInstallRemoveSignals(rtM, scopeInstallString,scopeFullNames,0);
#endif
    
#ifdef MULTITASKING  
    for (i = FIRST_TID + 1; i < NUMST; i++) {
        taskDelete(VxWorksTIDs[i]);
        semDelete(rtTaskSemaphoreList[i]);
    }
#endif
    
TERMINATE:
#ifdef MAT_FILE
    rt_StopDataLogging(MATFILE,rtmGetRTWLogInfo(rtM));
#endif
    
#if defined(RT_MALLOC) && NCSTATES > 0
    rt_ODEDestroyIntegrationData(rtmGetRTWSolverInfo(rtM));
#endif
    TERMINATE(rtM);
    
    return(EXIT_SUCCESS);
} /* end rt_main */


/* Functions: rt_installSignal, rt_removeSignal=================================
 * Abstract:
 *      Provide functions for users to call from WindSh command prompt that will
 *      install and remove a Blocks' Signals for StethoScope. All output signals
 *      for the Block will be installed/removed.
 *
 * Parameters:
 *      installStr     The name of the Block.
 *      fullNames      Whether or not the installStr is the full path name
 *                     of the Block.
 *                           1 - full hierarchical path name of Block
 *                           0 - name of Block only
 */

#ifdef STETHOSCOPE
int_T rt_installSignal(char_T *installStr, int_T fullNames) {
  return( rtInstallRemoveSignals(rtM, installStr,fullNames, 1));
}
int_T rt_removeSignal(char_T *removeStr, int_T fullNames) {
  return( rtInstallRemoveSignals(rtM, removeStr,fullNames, 0));
}

int_T rt_lkupBlocks(char_T *string) {
  register int_T i;
  extern BlockIOSignals  rtBIOSignals[];
  int_T ret = -1;
  
  if (string == NULL) {
    return -1;
  }
  if (!strcmp(string,"*")) {
    for(i = 0; i < rtmGetNumBlockIO(rtM); i++) {
      printf("blockName: %s\n",rtBIOSignals[i].blockName);
    }
    return 0;
  } else {
    for(i = 0; i < rtmGetNumBlockIO(rtM); i++) {
      if (strstr(rtBIOSignals[i].blockName,string) != NULL) {
        printf("blockName: %s\n",rtBIOSignals[i].blockName);
        ret = 0;
      }
    }
    return ret;
  }
  return -1;
} 
#endif

/* [EOF] rt_main.c */
