/*
 * Copyright 1994-2003 The MathWorks, Inc.
 *
 * File: ode14x.c        $Revision: 1.1.6.1 $
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
#include "rtlibsrc.h"
#include "odesup.h"

#ifndef ERT_CORE

#define MAXORDER 4

static int_T rt_ODE14x_N[MAXORDER] = {12, 8, 6, 4};

typedef struct IntgData_tag {
    /* ode14x: */
    real_T  *x0;
    real_T  *f0;
    real_T  *x1start;
    real_T  *f1;
    real_T  *Delta;     
    real_T  *E;    /* maxorder x nx */

    /* numjac: */
    real_T  *fac;  /* nx */
    real_T  *DFDX; /* nx x nx */

    /* LU: */
    real_T  *W;    /* nx x nx */
    int32_T *pivots; /* nx */
} IntgData;

#ifndef RT_MALLOC
  /* statically declare data */
  static real_T   rt_ODE14x_X0[NCSTATES];
  static real_T   rt_ODE14x_F0[NCSTATES];
  static real_T   rt_ODE14x_X1START[NCSTATES];
  static real_T   rt_ODE14x_F1[NCSTATES];
  static real_T   rt_ODE14x_DELTA[NCSTATES];
  static real_T   rt_ODE14x_E[MAXORDER*NCSTATES];
  static real_T   rt_ODE14x_FAC[MAXORDER];
  static real_T   rt_ODE14x_DFDX[NCSTATES*NCSTATES];
  static real_T   rt_ODE14x_W[NCSTATES*NCSTATES];
  static int32_T  rt_ODE14x_PIVOTS[NCSTATES];

  static IntgData rt_ODE14x_IntgData = {rt_ODE14x_X0,
                                        rt_ODE14x_F0,
                                        rt_ODE14x_X1START,
                                        rt_ODE14x_F1,
                                        rt_ODE14x_DELTA,
					rt_ODE14x_E,
					rt_ODE14x_FAC,
					rt_ODE14x_DFDX,
                                        rt_ODE14x_W,
                                        rt_ODE14x_PIVOTS};
					
  void rt_ODECreateIntegrationData(RTWSolverInfo *si)
  {
      { /* Initialize */
	  real_T SQRT_EPS = 1.5e-8;   /* sqrt(utGetEps()); */
	  int_T i;
	  for (i = 0; i < NCSTATES; i++) {
	      rt_ODE14x_IntgData.fac[i] = SQRT_EPS;
	  } 
      }

      rtsiSetSolverData(si,(void *)&rt_ODE14x_IntgData);
      rtsiSetSolverName(si,"ode14x");
  }
#else
  /* dynamically allocated data */

  void rt_ODECreateIntegrationData(RTWSolverInfo *si)
  {
      int_T nx    = rtsiGetNumContStates(si);
      int_T vsize = nx * sizeof(real_T);
      int_T msize = nx * vsize;
      int_T size  = (6+MAXORDER)*vsize + 2*msize + (nx+MAXORDER)*sizeof(int_T); 

      int_T i;

      IntgData *id = (IntgData *) malloc(sizeof(IntgData));
      if(id == NULL) {
          rtsiSetErrorStatus(si, RT_MEMORY_ALLOCATION_ERROR);
          return;
      }
      
      id->x0 = (real_T *) malloc(size);
      if(id->x0 == NULL) {
          rtsiSetErrorStatus(si, RT_MEMORY_ALLOCATION_ERROR);
          return;
      }
      id->f0      = id->x0      + nx;
      id->x1start = id->f0      + nx;
      id->f1      = id->x1start + nx;
      id->Delta   = id->f1      + nx;
      id->E       = id->Delta   + nx;
      id->fac     = id->E       + MAXORDER * nx;
      id->DFDX    = id->fac     + nx;
      id->W       = id->DFDX    + nx * nx;
      id->pivots  = (int32_T *) (id->W + nx * nx);

      { /* Initialize */
	  real_T SQRT_EPS = 1.5e-8;   /* sqrt(utGetEps()); */
	  int_T  i;
	  for (i = 0; i < nx; i++) {
	      id->fac[i] = SQRT_EPS;
	  } 
      }

      rtsiSetSolverData(si, (void *)id);
      rtsiSetSolverName(si,"ode14x");
  }

  void rt_ODEDestroyIntegrationData(RTWSolverInfo *si)
  {
      IntgData *id = rtsiGetSolverData(si);
      
      if (id != NULL) {
          if (id->x0 != NULL) {
              free(id->x0);
          }
          free(id);
          rtsiSetSolverData(si, NULL);
      }
  }
#endif


/* Simplified version of numjac.cpp, for use with RTW. */
void local_numjac(RTWSolverInfo   *si,
		  real_T          *y,
		  const real_T    *Fty,
		  real_T          *fac,
		  real_T          *dFdy)
{
    /* constants */
    real_T THRESH = 1e-6;
    real_T EPS    = 2.2e-16;  /* utGetEps(); */
    real_T BL     = pow(EPS, 0.75);
    real_T BU     = pow(EPS, 0.25);
    real_T FACMIN = pow(EPS, 0.78);
    real_T FACMAX = 0.1;

#ifdef NCSTATES
    int_T     nx = NCSTATES;
#else
    int_T     nx = rtsiGetNumContStates(si);
#endif

    real_T    *x = rtsiGetContStates(si);
    real_T    del;
    real_T    difmax;
    real_T    FdelRowmax;
    real_T    temp;
    real_T    Fdiff;
    real_T    maybe;
    real_T    xscale;
    real_T    fscale;
    real_T    *p;
    int_T     rowmax;
    int_T     i,j;

    if (x != y) (void)memcpy(x,y,nx*sizeof(real_T));

    for (p = dFdy, j = 0; j < nx; j++, p += nx) {

        /* Select an increment del for a difference approximation to
           column j of dFdy.  The vector fac accounts for experience
           gained in previous calls to numjac. */
        xscale = fabs(x[j]);
        if (xscale < THRESH) xscale = THRESH;
	temp = (x[j] + fac[j]*xscale); 
        del  = temp  - y[j];
        while (del == 0.0) {
            if (fac[j] < FACMAX) {
                fac[j] *= 100.0;
                if (fac[j] > FACMAX) fac[j] = FACMAX;
		temp = (x[j] + fac[j]*xscale); 
                del  = temp  - x[j];
            } else {
                del = THRESH; /* thresh is nonzero */
                break;
            }
        }
        /* Keep del pointing into region. */
        if (Fty[j] >= 0.0) del = fabs(del);
        else del = -fabs(del);

        /* Form a difference approximation to column j of dFdy. */
        temp = x[j];
        x[j] += del;

	rtsiSetdX(si,p);
	OUTPUTS(si,0);
	DERIVATIVES(si);

        x[j] = temp;
        difmax = 0.0;
        rowmax = 0;
        FdelRowmax = p[0];
        temp = 1.0 / del;
        for (i = 0; i < nx; i++) {
            Fdiff = p[i] - Fty[i];
            maybe = fabs(Fdiff);
            if (maybe > difmax) {
                difmax = maybe;
                rowmax = i;
                FdelRowmax = p[i];
            }
            p[i] = temp * Fdiff;
        }

        /* Adjust fac for next call to numjac. */
        if (((FdelRowmax != 0.0) && (Fty[rowmax] != 0.0)) || (difmax == 0.0)) {
            fscale = fabs(FdelRowmax);
            if (fscale < fabs(Fty[rowmax])) fscale = fabs(Fty[rowmax]);

	    if (difmax <= BL*fscale) {
                /* The difference is small, so increase the increment. */
                fac[j] *= 10.0;
                if (fac[j] > FACMAX) fac[j] = FACMAX;

            } else if (difmax > BU*fscale) {
                /* The difference is large, so reduce the increment. */
                fac[j] *= 0.1;
                if (fac[j] < FACMIN) fac[j] = FACMIN;

            }
        }
    }

} /* end local_numjac */


void rt_ODEUpdateContinuousStates(RTWSolverInfo *si)
{
    time_T    t0         = rtsiGetT(si);
    time_T    t1         = t0;
    time_T    h          = rtsiGetStepSize(si);
    real_T    *x1        = rtsiGetContStates(si);
    int_T     order      = rtsiGetSolverExtrapolationOrder(si);
    int_T     numIter    = rtsiGetSolverNumberNewtonIterations(si);

    IntgData  *id        = rtsiGetSolverData(si);
    real_T    *x0        = id->x0;
    real_T    *f0        = id->f0;
    real_T    *x1start   = id->x1start;
    real_T    *f1        = id->f1;
    real_T    *Delta     = id->Delta;
    real_T    *E         = id->E;
    real_T    *fac       = id->fac;
    real_T    *dfdx      = id->DFDX;
    real_T    *W         = id->W;
    int_T     *pivots    = id->pivots;
    int_T     *N         = &(rt_ODE14x_N[0]); 
    int_T     i,j,k,iter;

#ifdef NCSTATES
    int_T     nx        = NCSTATES;
#else
    int_T     nx        = rtsiGetNumContStates(si);
#endif

    rtsiSetSimTimeStep(si,MINOR_TIME_STEP);

    /* Save the state values at time t in y, we'll use x as ynew. */
    (void)memcpy(x0, x1, nx*sizeof(real_T));

    /* Assumes that rtsiSetT and ModelOutputs are up-to-date */
    /* f0 = f(t,y) */
    rtsiSetdX(si, f0);
    DERIVATIVES(si);

    /* Compute the Jacobian */
    local_numjac(si,x0,f0,fac,dfdx);

    for (j = 0; j < order; j++) {
	
	real_T *p;
	real_T hN = h / N[j];
	
	/* Get the iteration matrix and solution at t0 */

	/* [L,U] = lu(I - hN*J) */
        (void) memcpy(W, dfdx, nx*nx*sizeof(real_T));
        for (p = W, i = 0; i < nx*nx; i++, p++) *p *= (-hN);
        for (p = W, i = 0; i < nx; i++, p += (nx+1)) *p += 1.0;
	rt_lu_real(W,nx,pivots);

	/* First Newton's iteration at t0. */
	/* rhs = hN*f0  */
	for (i = 0; i < nx; i++) Delta[i] = hN*f0[i];
	/* Delta = (U \ (L \ rhs)) */
	rt_ForwardSubstitutionRR_Dbl(W,Delta,f1,nx,1,pivots,1);
	rt_BackwardSubstitutionRR_Dbl(W+nx*nx-1,f1+nx-1,Delta,nx,1,0);
	/* ytmp = y0 + Delta */ 
	(void)memcpy(x1, x0, nx*sizeof(real_T));
	for (i = 0; i < nx; i++) x1[i] += Delta[i];

	/* Additional Newton's iterations, if desired. 
	   for iter = 2:NewtIter
	     rhs = (yn - ytmp) + hN*feval(odefun,tn,ytmp,extraArgs{:});
	     Delta = ( U \ ( L \ rhs ) );
	     ytmp = ytmp + Delta;
	   end  
	*/
	rtsiSetT(si, t0);
	rtsiSetdX(si, f1);
	for (iter = 1; iter < numIter; iter++) {

	    OUTPUTS(si,0);
	    DERIVATIVES(si);

	    for (i = 0; i < nx; i++) Delta[i] = (x0[i]-x1[i]) + hN*f1[i];

	    rt_ForwardSubstitutionRR_Dbl(W,Delta,f1,nx,1,pivots,1);
	    rt_BackwardSubstitutionRR_Dbl(W+nx*nx-1,f1+nx-1,Delta,nx,1,0);

	    for (i = 0; i < nx; i++) x1[i] += Delta[i];
	}

	/* Subintegration of N(j) steps for extrapolation 
	   ttmp = t0;
	   for i = 2:N(j)
	     ttmp = ttmp + hN
	     ytmp0 = ytmp;
	     for iter = 1:NewtIter
               rhs = (ytmp0 - ytmp) + hN*feval(odefun,ttmp,ytmp,extraArgs{:});
	       Delta = ( U \ ( L \ rhs ) );
	       ytmp = ytmp + Delta;
	     end
	   end 
	*/
	for (k = 1; k < N[j]; k++) {
	    t1 = t0 + k*hN;
	    (void)memcpy(x1start, x1, nx*sizeof(real_T));
	    rtsiSetT(si, t1);
	    rtsiSetdX(si, f1);
	    for (iter = 0; iter < numIter; iter++) {

		OUTPUTS(si,0);
		DERIVATIVES(si);

		if (iter == 0) {
		    for (i = 0; i < nx; i++) Delta[i] = hN*f1[i];
		} else {
		    for (i = 0; i < nx; i++) Delta[i] = (x1start[i]-x1[i]) + hN*f1[i];
		}

		/* Modeled after rt_matdivrr_dbl.c, use f1 as a temp storage */
		rt_ForwardSubstitutionRR_Dbl(W,Delta,f1,nx,1,pivots,1);
		rt_BackwardSubstitutionRR_Dbl(W+nx*nx-1,f1+nx-1,Delta,nx,1,0);

		for (i = 0; i < nx; i++) x1[i] += Delta[i];
	    }   
	}

	/* Extrapolate to order j
	   E(:,j) = ytmp
	   for k = j:-1:2
             coef = N(k-1)/(N(j) - N(k-1))
             E(:,k-1) = E(:,k) + coef*( E(:,k) - E(:,k-1) )
	   end 
	*/
	(void)memcpy( &(E[nx*j]), x1, nx*sizeof(real_T));
	for (k = j; k > 0; k--) {
	    real_T coef = (real_T)(N[k-1]) / (N[j]-N[k-1]);

	    for (i = 0; i < nx; i++) {
		x1[i] = E[nx*k+i] + coef*(E[nx*k+i] - E[nx*(k-1)+i]);
	    }

	    (void)memcpy( &(E[nx*(k-1)]), x1, nx*sizeof(real_T));
	}
    }

    /* Extrapolated solution
       x1 = E(:,1);
    */
    (void)memcpy(x1, E, nx*sizeof(real_T));

    /* t1 = t0 + h; */
    rtsiSetT(si,rtsiGetSolverStopTime(si));

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
