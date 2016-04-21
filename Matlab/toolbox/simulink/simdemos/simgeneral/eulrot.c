/* EULROT.c computes Psi, Theta, Phi based upon P,Q,R


     Psi = Aircraft Yaw Angle (Z-Body Axis)         
     Theta = Aircraft Pitch Angle (Y-Body Axis)    
     Phi = Aircraft Roll Angle (X-Body Axis)
     
     P = Aircraft Roll Rate (X-Body Axis)
     Q = Aircraft Pitch Rate (Y-Body Axis)
     R = Aircraft Yaw Rate (Z-Body Axis)
     
       -+ X (North)
       /|
      /
     /           
     -------------> Y (East)
     |           
     |
     |
    \|/
     + Z (Down)
     

   Loren Dean
   Copyright 1990-2002 The MathWorks, Inc.
   $Revision: 1.12 $
   
*/

#define S_FUNCTION_NAME eulrot

#include <math.h>
#include "simstruc.h"

#define PI atan2(0.,-1.)
#define R2D (180./PI)

#define Quat x
#define QuatRates dx

#define Psi   (mxGetPr(ssGetArg(S,0))[0]/R2D)
#define Theta (mxGetPr(ssGetArg(S,1))[0]/R2D)
#define Phi   (mxGetPr(ssGetArg(S,2))[0]/R2D)

#define P (u[0]/R2D)
#define Q (u[1]/R2D)
#define R (u[2]/R2D)

static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumContStates(    S, 4);
    ssSetNumDiscStates(    S, 0);
    ssSetNumInputs(        S, 3);
    ssSetNumOutputs(       S, 3);
    ssSetDirectFeedThrough(S, 0);
    ssSetNumInputArgs(     S, 3);
    ssSetNumSampleTimes(   S, 1);
}

static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTimeEvent(S, 0, 0.);
    ssSetOffsetTimeEvent(S, 0, 0.);
}

static void mdlInitializeConditions(double *x0, SimStruct *S)
{
  x0[0] = cos(Psi/2.)*cos(Theta/2.)*sin(Phi/2.)
         -cos(Phi/2.)*sin(Psi/2.)*sin(Theta/2.);

  x0[1] = sin(Psi/2.)*cos(Theta/2.)*sin(Phi/2.)
         +cos(Phi/2.)*cos(Psi/2.)*sin(Theta/2.);

  x0[2] = sin(Psi/2.)*cos(Theta/2.)*cos(Phi/2.)
         -sin(Phi/2.)*cos(Psi/2.)*sin(Theta/2.);

  x0[3] = cos(Psi/2.)*cos(Theta/2.)*cos(Phi/2.)
         +sin(Phi/2.)*sin(Psi/2.)*sin(Theta/2.); 
}
static void mdlOutputs(double *y, double *x, double *u, 
                       SimStruct *S,int tid)
{
  int lp;

  double PsiNew, ThetaNew, PhiNew;
  double Trans[3][3];
  double CosTheta;
  double QuatSum=0.;

  for (lp=0;lp<4;lp++)
    QuatSum+=pow(x[lp],2.);
    
  QuatSum=sqrt(QuatSum);

  /* Normalize Quat
    for (lp=0;lp<4;lp++)
      x[lp]=Quat[lp]/QuatSum; */
    
  Trans[0][0]=1.-2.*pow(Quat[1],2.)-2.*pow(Quat[2],2.); 
  Trans[0][1]=2.*(Quat[0]*Quat[1]+Quat[2]*Quat[3]); 
  Trans[0][2]=2.*(Quat[2]*Quat[0]-Quat[1]*Quat[3]);  
  
  Trans[1][0]=2.*(Quat[0]*Quat[1]-Quat[2]*Quat[3]); 
  Trans[1][1]=1.-2.*pow(Quat[2],2.)-2.*pow(Quat[0],2.);   
  Trans[1][2]=2.*(Quat[1]*Quat[2]+Quat[0]*Quat[3]);  
  
  Trans[2][0]=2.*(Quat[2]*Quat[0]+Quat[1]*Quat[3]);  
  Trans[2][1]=2.*(Quat[1]*Quat[2]-Quat[0]*Quat[3]);
  Trans[2][2]=1.-2.*pow(Quat[0],2.)-2.*pow(Quat[1],2.);
         
  PhiNew   = atan2(Trans[1][2],Trans[2][2])*R2D;
  PsiNew   = atan2(Trans[0][1],Trans[0][0])*R2D;
  CosTheta = sqrt(pow(Trans[0][0],2.)+pow(Trans[0][1],2.));
  ThetaNew = atan2(-Trans[0][2],CosTheta)*R2D;
  
  y[0] = PsiNew;
  y[1] = ThetaNew;
  y[2] = PhiNew;

}

static void mdlUpdate(double *x, double *u, SimStruct *S, int tid)
{ 
}

static void mdlDerivatives(double *dx, double *x, double *u, 
                           SimStruct *S, int tid)
{
  dx[0]=(-Q*Quat[2]+P*Quat[3]+R*Quat[1] )/2.;
  dx[1]=( P*Quat[2]+Q*Quat[3]-R*Quat[0] )/2.;
  dx[2]=( Q*Quat[0]-P*Quat[1]+R*Quat[3] )/2.;
  dx[3]=(-P*Quat[0]-Q*Quat[1]-R*Quat[2] )/2.;
}

static void mdlTerminate(SimStruct *S)
{
}

#ifdef  MATLAB_MEX_FILE /* Is this file being compiled as a MEX-file? */
#include "simulink.c"   /* MEX-File interface mechanism */
#else
#include "cg_sfun.h"    /* Code generation registration function */
#endif
