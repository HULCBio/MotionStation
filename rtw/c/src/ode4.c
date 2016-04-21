/*
 * Copyright 1994-2003 The MathWorks, Inc.
 *
 * File: ode4.c        $Revision: 1.2.4.2 $
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
    real_T *f[4];
} IntgData;

#ifndef RT_MALLOC
  /* statically declare data */
  static real_T   rt_ODE4_Y[NCSTATES];
  static real_T   rt_ODE4_F[4][NCSTATES];
  static IntgData rt_ODE4_IntgData = {rt_ODE4_Y,
                                      {rt_ODE4_F[0],
                                       rt_ODE4_F[1],
                                       rt_ODE4_F[2],
                                       rt_ODE4_F[3]}};

  void rt_ODECreateIntegrationData(RTWSolverInfo *si)
  {
      rtsiSetSolverData(si,(void *)&rt_ODE4_IntgData);
      rtsiSetSolverName(si,"ode4");
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
      
      id->y = (real_T *) malloc(5*rtsiGetNumContStates(si) * sizeof(real_T));
      if(id->y == NULL) {
          rtsiSetErrorStatus(si, RT_MEMORY_ALLOCATION_ERROR);
          return;
      }
      id->f[0] = id->y + rtsiGetNumContStates(si);
      id->f[1] = id->f[0] + rtsiGetNumContStates(si);
      id->f[2] = id->f[1] + rtsiGetNumContStates(si);
      id->f[3] = id->f[2] + rtsiGetNumContStates(si);
      
      rtsiSetSolverData(si, (void *)id);
      rtsiSetSolverName(si,"ode4");
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
    time_T    t          = rtsiGetT(si);
    time_T    tnew       = rtsiGetSolverStopTime(si);
    time_T    h          = rtsiGetStepSize(si);
    real_T    *x         = rtsiGetContStates(si);
    IntgData  *id        = rtsiGetSolverData(si);
    real_T    *y         = id->y;
    real_T    *f0        = id->f[0];
    real_T    *f1        = id->f[1];
    real_T    *f2        = id->f[2];
    real_T    *f3        = id->f[3];
    real_T    temp;
    int_T     i;

#ifdef NCSTATES
    int_T     nXc        = NCSTATES;
#else
    int_T     nXc        = rtsiGetNumContStates(si);
#endif

    rtsiSetSimTimeStep(si,MINOR_TIME_STEP);

    /* Save the state values at time t in y, we'll use x as ynew. */
    (void)memcpy(y, x, nXc*sizeof(real_T));

    /* Assumes that rtsiSetT and ModelOutputs are up-to-date */
    /* f0 = f(t,y) */
    rtsiSetdX(si, f0);
    DERIVATIVES(si);

    /* f1 = f(t + (h/2), y + (h/2)*f0) */
    temp = 0.5 * h;
    for (i = 0; i < nXc; i++) x[i] = y[i] + (temp*f0[i]);
    rtsiSetT(si, t + temp);
    rtsiSetdX(si, f1);
    OUTPUTS(si,0);
    DERIVATIVES(si);

    /* f2 = f(t + (h/2), y + (h/2)*f1) */
    for (i = 0; i < nXc; i++) x[i] = y[i] + (temp*f1[i]);
    rtsiSetdX(si, f2);
    OUTPUTS(si,0);
    DERIVATIVES(si);

    /* f3 = f(t + h, y + h*f2) */
    for (i = 0; i < nXc; i++) x[i] = y[i] + (h*f2[i]);
    rtsiSetT(si, tnew);
    rtsiSetdX(si, f3);
    OUTPUTS(si,0);
    DERIVATIVES(si);

    /* tnew = t + h
       ynew = y + (h/6)*(f0 + 2*f1 + 2*f2 + 2*f3) */
    temp = h / 6.0;
    for (i = 0; i < nXc; i++) {
	x[i] = y[i] + temp*(f0[i] + 2.0*f1[i] + 2.0*f2[i] + f3[i]);
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
