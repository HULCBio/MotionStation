/*****************************************************************************
******************************************************************************
*
*               Real-Time main for use with Real-Time Windows Target
*
*               $Revision: 1.31.2.5 $
*               $Date: 2003/12/31 19:46:15 $
*               $Author: batserve $
*
*               Copyright 1994-2003 The MathWorks, Inc.
*
******************************************************************************
*****************************************************************************/


/*
*
* Defines used:
*      RT              - Required.
*      MODEL=modelname - Required.
*      NUMST=#         - Required. Number of sample times.
*      NCSTATES=#      - Required. Number of continuous states.
*      TID01EQ=1 or 0  - Optional. Only define to 1 if sample time task
*                        id's 0 and 1 have equal rates.
*/

#include <simstruc.h>
#include <rt_sim.h>
#include <rt_nonfinite.h>
#include <ext_svr.h>
#include <ext_share.h>
#include <ext_svr_transport.h>
#include <updown.h>
#include <rterror.h>
#include <wintmain.h>


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

#define str(s)    # s
#define xstr(s)   str(s)
#define MODEL_NAME xstr(MODEL)

#define RUN_FOREVER -1.0



/*****************************************************************************
;*
 *      Global data - needed to be compatible with GRT
;*
;****************************************************************************/

#ifdef EXT_MODE

int_T volatile           startModel      = FALSE;
TargetSimStatus volatile modelStatus     = TARGET_STATUS_WAITING_TO_START;

#endif



static SimStruct *S;

extern TargetSimStatus volatile modelStatus;

extern void rtUpdateContinuousStates(double *y, double *x, double *u, SimStruct *S, int id);
extern SimStruct *MODEL(void);

extern size_t SB;   // shared buffer structure - the first element is its size


extern void MdlInitializeSizes(void);
extern void MdlInitializeSampleTimes(void);
extern void MdlStart(void);
extern void MdlOutputs(int_T tid);
extern void MdlUpdate(int_T tid);
extern void MdlTerminate(void);

extern int InitTimer(SimStruct *S, int tid);
extern void StopTimers(void);

extern int  IsSharedBufferFull(void);
extern void SendShutdownPkt(void);


#if NCSTATES > 0
extern void rt_CreateIntegrationData(SimStruct *S);
extern void rt_UpdateContinuousStates(SimStruct *S);
#else
#define rt_CreateIntegrationData(S)  ssSetSolverName(S,"FixedStepDiscrete")
#define rt_UpdateContinuousStates(S) ssSetT(S,ssGetSolverStopTime(S))
#endif



/*****************************************************************************
;*
;*		sim_initialize
;*		main simulation initialization
;*
;*		Input:	none
;*		Output:	error
;*
;****************************************************************************/

int sim_initialize(void)
{
int error=ERR_OK;

/* create external mode data structures */

#ifdef EXT_MODE
  ExtParseArgsAndInitUD(0, NULL);
#endif // EXT_MODE


/* initialize the model */

rt_InitInfAndNaN(sizeof(real_T));
S=MODEL();
ssSetModelName(S,MODEL_NAME);

MdlInitializeSizes();
if (ssGetErrorStatus(S) != NULL)
  return(ERR_INITHW);

MdlInitializeSampleTimes();
if (ssGetErrorStatus(S) != NULL)
  return(ERR_INITHW);

if ((rt_InitTimingEngine(S)) != NULL)
  return(ERR_SIMNOTINIT);

rt_CreateIntegrationData(S);

#ifdef EXT_MODE
  if (rt_ExtModeInit(ssGetNumSampleTimes(S)) != EXT_NO_ERROR)
    return(ERR_SIMNOTINIT);
#endif // EXT_MODE

error=InitTimer(S,0);           // create timer for base rate
if(error!=ERR_OK)
  return(error);

#ifdef MULTITASKING
{
int i;

for (i=FIRST_TID+1; i<NUMST; i++)
 {
  error=InitTimer(S,i);         // create timer for each subrate
  if(error!=ERR_OK)
    return(error);
 }
}
#endif // MULTITASKING

MdlStart();  // process initial output values during loading

return(ERR_OK);
}



/*****************************************************************************
;*
;*		DISABLE
;*		disable the model
;*
;*		Input:	none
;*		Output:	none
;*
;****************************************************************************/

void __cdecl Disable(void)
{

#ifdef EXT_MODE
  rt_ExtModeShutdown(ssGetNumSampleTimes(S));
#endif // EXT_MODE

}



/*****************************************************************************
;*
;*		EXECUTE
;*		execute the model
;*
;*		Input:	tid = task id
;*		Output:	step size
;*
;****************************************************************************/

double __cdecl Execute(int tid)
{

/* TID==0 means the base rate */

if (tid==0)
 {
#ifdef EXT_MODE
  boolean_T stopReq = 0;
#endif // EXT_MODE

/* initialize the model continuous states on the first tick */
#if NCSTATES>0
  if (ssGetT(S)==ssGetTStart(S))
    MdlStart();
#endif

/* first process any packets and upload any buffer data */

#ifdef EXT_MODE

  rt_PktServerWork(ssGetRTWExtModeInfo(S),
                   ssGetNumSampleTimes(S),
                   (boolean_T *)(&stopReq));
  ssSetStopRequested(S, stopReq);
  if (!IsSharedBufferFull())     // we can upload only if buffer is not full
    rt_UploadServerWork(ssGetNumSampleTimes(S));

#endif // EXT_MODE


/* if MULTITASKING is defined, this is the multitasking base rate */

#ifdef MULTITASKING

  ssSetSolverStopTime(S,rt_UpdateDiscreteEvents(S));
  MdlOutputs(FIRST_TID);

#ifdef EXT_MODE
  {
      int j;
      for (j=0; j<NUM_UPINFOS; j++) {
          UploadCheckTrigger(j, ssGetNumSampleTimes(S));
          UploadBufAddTimePoint(FIRST_TID,ssGetTaskTime(S, FIRST_TID), j);
      }
  }

#endif // EXT_MODE

  MdlUpdate(FIRST_TID);
  if (ssGetSampleTime(S,0) == CONTINUOUS_SAMPLE_TIME)
    rt_UpdateContinuousStates(S);
  else
    rt_UpdateDiscreteTaskTime(S,0);

#if FIRST_TID == 1
    rt_UpdateDiscreteTaskTime(S,1);
#endif

/* if MULTITASKING is not defined, this is the whole model */

#else // MULTITASKING

  ssSetSolverStopTime(S,rt_GetNextSampleHit());
  MdlOutputs(0);

#ifdef EXT_MODE

  {
   int i,j;

   for (j=0; j<NUM_UPINFOS; j++) {
       UploadCheckTrigger(j, ssGetNumSampleTimes(S));
       for (i=0; i<NUMST; i++)
           if (ssIsSampleHit(S,i,0)) {
               UploadBufAddTimePoint(i,ssGetTaskTime(S,i), j);
           }
   }
  }
  
#endif // EXT_MODE

  MdlUpdate(0);
  rt_UpdateDiscreteTaskSampleHits(S);
  if (ssGetSampleTime(S,0) == CONTINUOUS_SAMPLE_TIME)
    rt_UpdateContinuousStates(S);

#endif // MULTITASKING

/* test if the execution should be stopped */

  if (ssGetStopRequested(S) || (  ssGetT(S) >= ssGetTFinal(S) && ssGetTFinal(S) != RUN_FOREVER ) )
   {
    StopTimers();
    MdlTerminate();

#ifdef EXT_MODE
    {
        int j;
        for (j=0; j<NUM_UPINFOS; j++) {
            UploadPrepareForFinalFlush(j);
        }
        rt_UploadServerWork(ssGetNumSampleTimes(S));
        SendShutdownPkt();
    }
#endif // EXT_MODE
   }

/* check for end of the trigger */

#ifdef EXT_MODE
  {
      int j;
      for (j=0; j<NUM_UPINFOS; j++) {
          UploadCheckEndTrigger(j);
      }
  }
#endif

 }


/* TID!=0 means multitasking subrate */

#ifdef MULTITASKING

else

 {
  MdlOutputs(tid);

#ifdef EXT_MODE
  {
      int j;
      for (j=0; j<NUM_UPINFOS; j++) {
          UploadBufAddTimePoint(tid,ssGetTaskTime(S,tid), j);
      }
  }
#endif // EXT_MODE

  MdlUpdate(tid);
  rt_UpdateDiscreteTaskTime(S,tid);
 }

#endif // MULTITASKING

return(ssGetSampleTime(S,0));
}



/*****************************************************************************
;*
;*		COMM
;*		communication interface
;*
;*		Input:	func = function, not used
;*			comm_type = communication type
;*			np = number od parameters changed, not used
;*			dummy1 = not used
;*			dummy2 = not used
;*			InBuf =  incoming packet buffer
;*		Output:	0 if success, error code otherwise
;*
;****************************************************************************/

int __cdecl Comm(int func, int comm_type, int np, void* dummy1, void* dummy2, double *InBuf)
{

#ifdef EXT_MODE
if (comm_type==EXT_GET_BUFFER)              /* get pointer to shared buffer */
 {
  int* ud = (int *) InBuf;

  ud[0] = (int) (&SB + 1);
  return(ERR_OK);
 }

if (comm_type==EXT_PROCESS_PKT)           /* process packet on target */
 {
  boolean_T stopReq = 0;

  rt_PktServerWork(ssGetRTWExtModeInfo(S),
                   ssGetNumSampleTimes(S),
                   &stopReq);
  ssSetStopRequested(S, stopReq);
 }
#endif // EXT_MODE

return(ERR_OK);
}

