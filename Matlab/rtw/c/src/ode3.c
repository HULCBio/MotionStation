/*
 * Copyright 1994-2003 The MathWorks, Inc.
 *
 * File: ode3.c        $Revision: 1.2.4.2 $
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

static const real_T rt_ODE3_A[3] = {
    1.0/2.0, 3.0/4.0, 1.0
};

static const real_T rt_ODE3_B[3][3] = {
    { 1.0/2.0,     0.0,     0.0 },
    {     0.0, 3.0/4.0,     0.0 },
    { 2.0/9.0, 1.0/3.0, 4.0/9.0 }
};


typedef struct IntgData_tag {
    real_T *y;
    real_T *f[3];
} IntgData;


#ifndef RT_MALLOC
  /* statically declare data */
  static real_T   rt_ODE3_Y[NCSTATES];
  static real_T   rt_ODE3_F[3][NCSTATES];
  static IntgData rt_ODE3_IntgData = {rt_ODE3_Y,
                                      {rt_ODE3_F[0],rt_ODE3_F[1],rt_ODE3_F[2]}};

void rt_ODECreateIntegrationData(RTWSolverInfo *si)
  {
      rtsiSetSolverData(si,(void *)&rt_ODE3_IntgData);
      rtsiSetSolverName(si,"ode3");
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
      
      id->y = (real_T *) malloc(4*rtsiGetNumContStates(si) * sizeof(real_T));
      if(id->y == NULL) {
          rtsiSetErrorStatus(si, RT_MEMORY_ALLOCATION_ERROR);
          return;
      }
      id->f[0] = id->y + rtsiGetNumContStates(si);
      id->f[1] = id->f[0] + rtsiGetNumContStates(si);
      id->f[2] = id->f[1] + rtsiGetNumContStates(si);
      
      rtsiSetSolverData(si, (void *)id);
      rtsiSetSolverName(si,"ode3");
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
    real_T    hB[3];
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

    /* f(:,2) = feval(odefile, t + hA(1), y + f*hB(:,1), args(:)(*)); */
    hB[0] = h * rt_ODE3_B[0][0];
    for (i = 0; i < nXc; i++) {
	x[i] = y[i] + (f0[i]*hB[0]);
    }
    rtsiSetT(si, t + h*rt_ODE3_A[0]);
    rtsiSetdX(si, f1);
    OUTPUTS(si,0);
    DERIVATIVES(si);

    /* f(:,3) = feval(odefile, t + hA(2), y + f*hB(:,2), args(:)(*)); */
    for (i = 0; i <= 1; i++) hB[i] = h * rt_ODE3_B[1][i];
    for (i = 0; i < nXc; i++) {
	x[i] = y[i] + (f0[i]*hB[0] + f1[i]*hB[1]);
    }
    rtsiSetT(si, t + h*rt_ODE3_A[1]);
    rtsiSetdX(si, f2);
    OUTPUTS(si,0);
    DERIVATIVES(si);

    /* tnew = t + hA(3);
       ynew = y + f*hB(:,3); */
    for (i = 0; i <= 2; i++) hB[i] = h * rt_ODE3_B[2][i];
    for (i = 0; i < nXc; i++) {
	x[i] = y[i] + (f0[i]*hB[0] + f1[i]*hB[1] + f2[i]*hB[2]);
    }
    rtsiSetT(si, tnew);

    PROJECTION(si);

    rtsiSetSimTimeStep(si,MAJOR_TIME_STEP);
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

/* [EOF] ode3.c */
