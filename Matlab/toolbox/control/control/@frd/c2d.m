function sysd = c2d(sys,Ts,method,varargin)
%C2D  Conversion of continuous-time models to discrete time.
%
%   SYSD = C2D(SYSC,Ts,METHOD) converts the continuous-time LTI 
%   model SYSC to a discrete-time model SYSD with sample time Ts.  
%   The string METHOD selects the discretization method among the 
%   following:
%      'zoh'       Zero-order hold on the inputs
%      'foh'       Linear interpolation of inputs (triangle appx.)
%      'imp'       Impulse-invariant discretization
%      'tustin'    Bilinear (Tustin) approximation
%      'prewarp'   Tustin approximation with frequency prewarping.  
%                  The critical frequency Wc (in rad/sec) is specified
%                  as fourth input by 
%                     SYSD = C2D(SYSC,Ts,'prewarp',Wc)
%      'matched'   Matched pole-zero method (for SISO systems only).
%   The default is 'zoh' when METHOD is omitted.
%
%   For state-space models,
%      [SYSD,G] = C2D(SYSC,Ts,METHOD)
%   also returns a matrix G that maps continuous initial conditions
%   into discrete initial conditions.  Specifically, if x0,u0 are
%   initial states and inputs for SYSC, then equivalent initial
%   conditions for SYSD are given by
%      xd[0] = G * [x0;u0],     ud[0] = u0 .
%
%   See also D2C, D2D, LTIMODELS.

%	Clay M. Thompson  7-19-90, A.Potvin 12-5-95
%       P. Gahinet  7-18-96
%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.9 $  $Date: 2002/04/10 06:18:33 $
error('C2D is not supported for FRD models.')
