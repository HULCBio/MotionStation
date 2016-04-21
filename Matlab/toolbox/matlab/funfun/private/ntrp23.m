function [yinterp,ypinterp] = ntrp23(tinterp,t,y,tnew,ynew,h,f)
%NTRP23  Interpolation helper function for ODE23.
%   YINTERP = NTRP23(TINTERP,T,Y,TNEW,YNEW,H,F) uses data computed in ODE23
%   to approximate the solution at time TINTERP. TINTERP may be a scalar 
%   or a row vector.  
%   [YINTERP,YPINTERP] = NTRP23(TINTERP,T,Y,TNEW,YNEW,H,F) returns also the
%   derivative of the polynomial approximating the solution. 
%   
%   See also ODE23, DEVAL.

%   Mark W. Reichelt and Lawrence F. Shampine, 6-13-94
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.2 $  $Date: 2004/04/16 22:06:40 $

BI = [
    1       -4/3        5/9
    0       1       -2/3
    0       4/3     -8/9
    0       -1      1
    ];

s = (tinterp - t)/h;       
yinterp = repmat(y,size(tinterp)) + f*(h*BI)*cumprod(repmat(s,3,1));
if nargout > 1
  ypinterp = f*BI*[ ones(size(s)); cumprod([2*s;3/2*s])];
end  
