function y = winintegrate(x,Tp)
%WININTEGRATE Numerically integrates window function
%  WINI = WININTEGRATE(WIN,T) - returns the integral function WINI
%  which is numerically computed from the passed vector WIN. The 
%  integral is computed using a simple trapezoid method.  The period
%  of the input waveform is passed by T.  This defines the period
%  of time spanned by the input function.  
%
%  See also WINDTRANDEMO, WINORDERFIRST, SCALEWINFO 

%   Author(s): A. Dowd, Tom Bryant
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/15 01:19:42 $
%
step=Tp/(length(x)-1);
y=[0 (x(1:end-1)+x(2:end))*step/2];
y(2:end) = y(2:end)+cumsum(y(1:end-1));

% [EOF] winintegrate.m