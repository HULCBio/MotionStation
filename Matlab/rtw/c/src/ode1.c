/*
 * Copyright 1994-2003 The MathWorks, Inc.
 *
 * File: ode1.c        $Revision: 1.2.4.2 $
 *
 */

#include "odesup.h"

#ifndef ERT_CORE

typedef struct IntgData_tag {
    real_T *f0;
} IntgData;

#ifndef RT_MALLOC
  /* statically declare data */
  static real_T   rt_ODE1_F[NCSTATES];
  static IntgData rt_ODE1_IntgData = {rt_ODE1_F};
 
  void rt_ODECreateIntegrationData(RTWSolverInfo *si)
  {
      rtsiSetSolverData(si,(void *) &rt_ODE1_IntgData);
      rtsiSetdX(si, rt_ODE1_IntgData.f0);
      rtsiSetSolverName(si,"ode1");
  }

#else
  /* dynamically allocated data */
  extern const char *RT_MEMORY_ALLOCATION_ERROR;

  void rt_ODECreateIntegrationData(RTWSolverInfo *si)
  {
      IntgData *id = (IntgData *) malloc(sizeof(IntgData));
      if(id == NULL) {
          rtsiSetErrorStatus(si, RT_MEMORY_ALLOCATION_ERROR);
          return;
      }
      
      id->f0 = (real_T *) malloc(rtsiGetNumContStates(si) * sizeof(real_T));
      if(id->f0 == NULL) {
          rtsiSetErrorStatus(si, RT_MEMORY_ALLOCATION_ERROR);
          return;
      }
      
      rtsiSetSolverData(si, (void *)id);
      rtsiSetdX(si, id->f0);
      rtsiSetSolverName(si,"ode1");
  }

  void rt_ODEDestroyIntegrationData(RTWSolverInfo *si)
  {
      IntgData *id = rtsiGetSolverData(si);
      
      if (id != NULL) {
          if (id->f0 != NULL) {
              free(id->f0);
          }
          free(id);
          rtsiSetSolverData(si, NULL);
      }
  }
#endif

void rt_ODEUpdateContinuousStates(RTWSolverInfo *si)
{
    time_T    h    = rtsiGetStepSize(si);
    time_T    tnew = rtsiGetSolverStopTime(si);
    IntgData  *id  = rtsiGetSolverData(si);
    real_T    *f0  = id->f0;
    real_T    *x   = rtsiGetContStates(si);
    int_T     i;

#ifdef NCSTATES
    int_T     nXc  = NCSTATES;
#else
    int_T     nXc  = rtsiGetNumContStates(si);
#endif

    rtsiSetSimTimeStep(si,MINOR_TIME_STEP);

    DERIVATIVES(si);

    rtsiSetT(si, tnew);

    for (i = 0; i < nXc; i++) {
      *x += h * f0[i];
      x++;
    }

    PROJECTION(si);

    rtsiSetSimTimeStep(si, MAJOR_TIME_STEP);
}

#else  /* ERT_CORE is defined */
void rt_ODECreateIntegrationData(RTWSolverInfo *si)
{
    return;
} /* do nothing */
void rt_ODEDestroyIntegrationData(RTWSolverInfo *si)
{
    return;
} /* do nothing */
void rt_ODEUpdateContinuousStates(RTWSolverInfo *si)
{
    return;
} /* do nothing */
#endif 

/* [EOF] ode1.c */
