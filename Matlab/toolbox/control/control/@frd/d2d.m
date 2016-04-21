function sys = d2d(sys,Ts,Nd)
%D2D  Resample discrete LTI system.
%
%   SYS = D2D(SYS,TS) resamples the discrete-time LTI model SYS 
%   to produce an equivalent discrete system with sample time TS.
%
%   See also D2C, C2D, LTIMODELS.

%	Andrew C. W. Grace 2-20-91, P. Gahinet 8-28-96
%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.6 $  $Date: 2002/04/10 06:18:12 $

error('D2D is not supported for FRD models.')



