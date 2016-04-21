function sys = d2d(sys,Ts)
%D2D  Resample discrete IDMODEL.
%
%   MOD = D2D(MOD,TS) resamples the discrete-time IDMODEL model MOD 
%   to produce an equivalent discrete system with sample time TS.
%
%   See also D2C, C2D

%   $Revision: 1.2 $  $Date: 2001/01/16 15:22:38 $
%   Copyright 1986-2001 The MathWorks, Inc.


sys = d2c(sys);
sys = c2d(sys,Ts);
