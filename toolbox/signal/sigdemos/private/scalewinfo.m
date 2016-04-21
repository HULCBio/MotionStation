function [A,V,P,S] = scalewinfo(winobj,convType)

%SCALEWINFO computes acceleration, velocity, etc from a window
%  [A,V,P,S] = SCALEWINFO(WINF,PARAM,NP,TYPE) - returns the
%  acceleration(A), velocity(V), position(P) and the necessary 
%  scaling(S) to produce a unit change in position from the
%  supplied window function.  The window function is supplied
%  as a function handle: WINF.  The window handle should 
%  refer to a zero-order window that can be converted to a first-
%  order window by appling the WINORDERFIRST function.  The
%  desired conversion technique should be supplied by the
%  TYPE parameters.  Also, if the passed window handle supports
%  a parameter, it should be passed by PARAM.  The generated
%  first-order window is applied as an acceleration profile.
%  The resulting waveforms will have NP points and have a position 
%  value of 1 at the last point.
%
%  [A,V,P] = SCALEWINFO(WINF,PARAM,NP,TYPE) - same as above
%  except the Scaling term is not returned.
%
%  See also WINDTRANDEMO, WINORDERFIRST, SCALEWINZO 

%   Author(s): A. Dowd
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 01:19:36 $

error(nargchk(2,2,nargin));

Tp = 1;
A = winorderfirst(winobj,convType)';

V = winintegrate(A,Tp);
P = winintegrate(V,Tp);

Pcum = P(end);
A = A/Pcum;
V = V/Pcum;
P = P/Pcum;

if nargout > 3,
    S = Pcum;
end

% [EOF] scalewinfo.m
