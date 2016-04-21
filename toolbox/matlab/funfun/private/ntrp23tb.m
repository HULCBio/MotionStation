function [yint,ypint] = ntrp23tb(tint,t,y,tnew,ynew,t2,y2)
%NTRP23TB  Interpolation helper function for ODE23TB.
%   YINT = NTRP23TB(TINT,T,Y,TNEW,YNEW,T2,Y2) uses data computed in ODE23TB
%   to approximate the solution at TINT. TINT may be a scalar or a row vector.        
%   [YINT,YPINT] = NTRP23TB(TINT,T,Y,TNEW,YNEW,T2,Y2) returns also the
%   derivative of the polynomial approximating the solution.   
%
%   See also ODE23TB, DEVAL.

%   Mark W. Reichelt, Lawrence F. Shampine, and Yanyuan Ma, 7-1-97
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $  $Date: 2004/04/16 22:06:43 $

a1 = (((tint - tnew) .* (tint - t2)) ./ ((t - tnew) .* (t - t2)));
a2 = (((tint - t) .* (tint - tnew)) ./ ((t2 - t) .* (t2 - tnew)));
a3 = (((tint - t) .* (tint - t2)) ./ ((tnew - t) .* (tnew - t2)));
yint = y*a1 + y2*a2 + ynew*a3;
if nargout > 1
  ap1 = (((tint - tnew) + (tint - t2)) ./ ((t - tnew) .* (t - t2)));
  ap2 = (((tint - t) + (tint - tnew)) ./ ((t2 - t) .* (t2 - tnew)));
  ap3 = (((tint - t) + (tint - t2)) ./ ((tnew - t) .* (tnew - t2)));
  ypint = y*ap1 + y2*ap2 + ynew*ap3;
end  
