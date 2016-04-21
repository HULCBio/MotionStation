/*
 * Copyright 1994-2003 The MathWorks, Inc.
 *
 * File: ode5.c        $Revision: 1.2.4.2 $
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

static const real_T rt_ODE5_A[6] = {
    1.0/5.0, 3.0/10.0, 4.0/5.0, 8.0/9.0, 1.0, 1.0
};

static real_T rt_ODE5_B[6][6] = {
    {1.0/5.0, 0.0, 0.0, 0.0, 0.0, 0.0},
    {3.0/40.0, 9.0/40.0, 0.0, 0.0, 0.0, 0.0},
    {44.0/45.0, -56.0/15.0, 32.0/9.0, 0.0, 0.0, 0.0},
    {19372.0/6561.0, -25360.0/2187.0, 64448.0/6561.0, -212.0/729.0, 0.0, 0.0},
    {9017.0/3168.0,-355.0/33.0,46732.0/5247.0,49.0/176.0,-5103.0/18656.0,0.0},
    {35.0/384.0, 0.0, 500.0/1113.0, 125.0/192.0, -2187.0/6784.0, 11.0/84.0}
};

typedef struct IntgData_tag {
    real_T *y;
    real_T *f[6];
} IntgData;

#ifndef RT_MALLOC
  /* statically declare data */
  static real_T   rt_ODE5_Y[NCSTATES];
  static real_T   rt_ODE5_F[6][NCSTATES];
  static IntgData rt_ODE5_IntgData = {rt_ODE5_Y,
                                      {rt_ODE5_F[0],
                                       rt_ODE5_F[1],
                                       rt_ODE5_F[2],
                                       rt_ODE5_F[3],
                                       rt_ODE5_F[4],
                                       rt_ODE5_F[5]}};

  void rt_ODECreateIntegrationData(RTWSolverInfo *si)
  {
      rtsiSetSolverData(si,(void *)&rt_ODE5_IntgData);
      rtsiSetSolverName(si,"ode5");
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
      
      id->y = (real_T *) malloc(7*rtsiGetNumContStates(si) * sizeof(real_T));
      if(id->y == NULL) {
          rtsiSetErrorStatus(si, RT_MEMORY_ALLOCATION_ERROR);
          return;
      }
      id->f[0] = id->y + rtsiGetNumContStates(si);
      id->f[1] = id->f[0] + rtsiGetNumContStates(si);
      id->f[2] = id->f[1] + rtsiGetNumContStates(si);
      id->f[3] = id->f[2] + rtsiGetNumContStates(si);
      id->f[4] = id->f[3] + rtsiGetNumContStates(si);
      id->f[5] = id->f[4] + rtsiGetNumContStates(si);
      
      rtsiSetSolverData(si, (void *)id);
      rtsiSetSolverName(si,"ode5");
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
    IntgData  *intgData  = rtsiGetSolverData(si);
    real_T    *y         = intgData->y;
    real_T    *f0        = intgData->f[0];
    real_T    *f1        = intgData->f[1];
    real_T    *f2        = intgData->f[2];
    real_T    *f3        = intgData->f[3];
    real_T    *f4        = intgData->f[4];
    real_T    *f5        = intgData->f[5];
    real_T    hB[6];
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
    hB[0] = h * rt_ODE5_B[0][0];
    for (i = 0; i < nXc; i++) {
	x[i] = y[i] + (f0[i]*hB[0]);
    }
    rtsiSetT(si, t + h*rt_ODE5_A[0]);
    rtsiSetdX(si, f1);
    OUTPUTS(si,0);
    DERIVATIVES(si);

    /* f(:,3) = feval(odefile, t + hA(2), y + f*hB(:,2), args(:)(*)); */
    for (i = 0; i <= 1; i++) hB[i] = h * rt_ODE5_B[1][i];
    for (i = 0; i < nXc; i++) {
	x[i] = y[i] + (f0[i]*hB[0] + f1[i]*hB[1]);
    }
    rtsiSetT(si, t + h*rt_ODE5_A[1]);
    rtsiSetdX(si, f2);
    OUTPUTS(si,0);
    DERIVATIVES(si);

    /* f(:,4) = feval(odefile, t + hA(3), y + f*hB(:,3), args(:)(*)); */
    for (i = 0; i <= 2; i++) hB[i] = h * rt_ODE5_B[2][i];
    for (i = 0; i < nXc; i++) {
	x[i] = y[i] + (f0[i]*hB[0] + f1[i]*hB[1] + f2[i]*hB[2]);
    }
    rtsiSetT(si, t + h*rt_ODE5_A[2]);
    rtsiSetdX(si, f3);
    OUTPUTS(si,0);
    DERIVATIVES(si);

    /* f(:,5) = feval(odefile, t + hA(4), y + f*hB(:,4), args(:)(*)); */
    for (i = 0; i <= 3; i++) hB[i] = h * rt_ODE5_B[3][i];
    for (i = 0; i < nXc; i++) {
	x[i] = y[i] + (f0[i]*hB[0] + f1[i]*hB[1] + f2[i]*hB[2] +
		       f3[i]*hB[3]);
    }
    rtsiSetT(si, t + h*rt_ODE5_A[3]);
    rtsiSetdX(si, f4);
    OUTPUTS(si,0);
    DERIVATIVES(si);

    /* f(:,6) = feval(odefile, t + hA(5), y + f*hB(:,5), args(:)(*)); */
    for (i = 0; i <= 4; i++) hB[i] = h * rt_ODE5_B[4][i];
    for (i = 0; i < nXc; i++) {
	x[i] = y[i] + (f0[i]*hB[0] + f1[i]*hB[1] + f2[i]*hB[2] +
		       f3[i]*hB[3] + f4[i]*hB[4]);
    }
    rtsiSetT(si, tnew);
    rtsiSetdX(si, f5);
    OUTPUTS(si,0);
    DERIVATIVES(si);

    /* tnew = t + hA(6);
       ynew = y + f*hB(:,6); */
    for (i = 0; i <= 5; i++) hB[i] = h * rt_ODE5_B[5][i];
    for (i = 0; i < nXc; i++) {
	x[i] = y[i] + (f0[i]*hB[0] + f1[i]*hB[1] + f2[i]*hB[2] +
		       f3[i]*hB[3] + f4[i]*hB[4] + f5[i]*hB[5]);
    }

    PROJECTION(si);

    rtsiSetSimTimeStep(si,MAJOR_TIME_STEP);
}
#else 
void rt_ODECreateIntegrationData(RTWSolverInfo *si) {
 /* do nothing */
    return;
}
void rt_ODEDestroyIntegrationData(RTWSolverInfo *si) {
 /* do nothing */
    return;
}
void rt_ODEUpdateContinuousStates(RTWSolverInfo *si) {
 /* do nothing */
    return;
}
#endif 


/* [EOF] ode5.c */
