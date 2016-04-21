function [yint,ypint] = ntrp23t(tint,t,y,tnew,ynew,h,z,znew)
%NTRP23T  Interpolation helper function for ODE23T.
%   YINT = NTRP23T(TINT,T,Y,TNEW,YNEW,H,Z,ZNEW) uses data computed in ODE23T
%   to approximate the solution at time TINT. TINT may be a scalar or a row vector.     
%   [YINT,YPINT] = NTRP23T(TINT,T,Y,TNEW,YNEW,H,Z,ZNEW) returns also the 
%   derivative of the polynomial approximating the solution.   
%   
%   See also ODE23T, DEVAL.

%   Mark W. Reichelt, Lawrence F. Shampine, and Yanyuan Ma, 7-1-97
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $  $Date: 2004/04/16 22:06:42 $

s = (tint - t)/h;
s2 = s .* s;
s3 = s .* s2;
v1 = ynew - y - z;
v2 = znew - z;
yint = repmat(y,size(tint)) + z*s + (3*v1 - v2)*s2 + (v2 - 2*v1)*s3;
if nargout > 1
  ypint = repmat(z/h,size(tint)) + 2/h*(3*v1 - v2)*s + 3/h*(v2 - 2*v1)*s2;
end  

