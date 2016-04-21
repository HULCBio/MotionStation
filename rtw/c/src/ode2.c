/*
 * Copyright 1994-2003 The MathWorks, Inc.
 *
 * File: ode2.c        $Revision: 1.2.4.2 $
 *
 */

#include <math.h>
#include <string.h>
#include "tmwtypes.h"
#ifdef USE_RTMODEL
# include "simstruc_types.h"
#else
# include "simstruc.h"
#endif
#include "odesup.h"

#ifndef ERT_CORE

typedef struct IntgData_tag {
    real_T *y;
    real_T *f[2];
} IntgData;

#ifndef RT_MALLOC
  /* statically declare data */
  static real_T   rt_ODE2_Y[NCSTATES];
  static real_T   rt_ODE2_F[2][NCSTATES];
  static IntgData rt_ODE2_IntgData = {rt_ODE2_Y, {rt_ODE2_F[0], rt_ODE2_F[1]}};

  void rt_ODECreateIntegrationData(RTWSolverInfo *si)
  {
      rtsiSetSolverData(si, (void *)&rt_ODE2_IntgData);
      rtsiSetSolverName(si,"ode2");
  }

#else
  /* dynamically allocated data */
  void rt_ODECreateIntegrationData(RTWSolverInfo *si)
  {
      IntgData *id = (IntgData *) malloc(sizeof(IntgData));
      if(id == NULL) {
          rtsiSetErrorStatus(si, RT_MEMORY_ALLOCATION_ERROR);
          return;
      }
      
      id->y = (real_T *) malloc(3*rtsiGetNumContStates(si) * sizeof(real_T));
      if(id->y == NULL) {
          rtsiSetErrorStatus(si, RT_MEMORY_ALLOCATION_ERROR);
          return;
      }
      id->f[0] = id->y + rtsiGetNumContStates(si);
      id->f[1] = id->f[0] + rtsiGetNumContStates(si);
      
      rtsiSetSolverData(si, (void *)id);
      rtsiSetSolverName(si,"ode2");
  }

  void rt_ODEDestroyIntegrationData(RTWSolverInfo *si)
  {
    IntgData *id = rtsiGetSolverData(si);

    if (id != NULL) {
      if (id->y != NULL) {
        free(id->y);
      }
      free(id);
      rtsiSetSolverData(si, NULL);
    }
  }
#endif

void rt_ODEUpdateContinuousStates(RTWSolverInfo *si)
{
    time_T    tnew  = rtsiGetSolverStopTime(si);
    time_T    h     = rtsiGetStepSize(si);
    real_T    *x    = rtsiGetContStates(si);
    IntgData  *id   = rtsiGetSolverData(si);
    real_T    *y    = id->y;
    real_T    *f0   = id->f[0];
    real_T    *f1   = id->f[1];
    real_T    temp;
    int_T     i;

#ifdef NCSTATES
    int_T     nXc   = NCSTATES;
#else
    int_T     nXc   = rtsiGetNumContStates(si);
#endif

    rtsiSetSimTimeStep(si,MINOR_TIME_STEP);

    /* Save the state values at time t in y, we'll use x as ynew. */
    (void)memcpy(y, x, nXc*sizeof(real_T));

    /* Assumes that rtsiSetT and ModelOutputs are up-to-date */
    /* f0 = f(t,y) */
    rtsiSetdX(si, f0);
    DERIVATIVES(si);

    /* f1 = f(t + h, y + h*f0) */
    for (i = 0; i < nXc; i++) x[i] = y[i] + (h*f0[i]);
    rtsiSetT(si, tnew);
    rtsiSetdX(si, f1);
    OUTPUTS(si,0);
    DERIVATIVES(si);

    /* tnew = t + h
       ynew = y + (h/2)*(f0 + f1) */
    temp = 0.5*h;
    for (i = 0; i < nXc; i++) {
        x[i] = y[i] + temp*(f0[i] + f1[i]);
    }

    PROJECTION(si);

    rtsiSetSimTimeStep(si,MAJOR_TIME_STEP);
}

#else /* ERT_CORE is defined */
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

/* [EOF] ode2.c */
