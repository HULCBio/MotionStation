function [A,V,P,S] = scalewinfo(winobj)
%SCALEWINZO computes acceleration, velocity, etc from a window
%  [A,V,P,S] = SCALEWINZO(WINF,PARAM,NP) - returns the 
%  acceleration(A), velocity(V), position(P) and the necessary 
%  scaling(S) to produce a unit change in velocity from the
%  supplied window function.  The window function is supplied
%  as a function handle: WINF.  The window handle should 
%  refer to a zero-order window.   If the passed window handle 
%  supports a parameter, it should be passed by PARAM.  The 
%  supplied window is applied as an acceleration profile.
%  The resulting waveforms will have NP points and have a velocity 
%  value of 1 at the last point.
%
%  [A,V,P] = SCALEWINZO(WINF,PARAM,NP) - same as above
%  except the Scaling term is not returned.
%
%  See also WINDTRANDEMO, WINORDERFIRST, SCALEWINFO 

%   Author(s): A. Dowd
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 01:19:39 $

error(nargchk(1,1,nargin));

Tp = 1;

A = generate(winobj)';

V = winintegrate(A,Tp);
P = winintegrate(V,Tp);

Vcum = V(end);
A = A/Vcum;
V = V/Vcum;
P = P/Vcum;

if nargout > 3,
    S = Vcum;
end

% [EOF] scalewinfo.m
