function [yinterp,ypinterp] = ntrp45(tinterp,t,y,tnew,ynew,h,f)
%NTRP45  Interpolation helper function for ODE45.
%   YINTERP = NTRP45(TINTERP,T,Y,TNEW,YNEW,H,F) uses data computed in ODE45
%   to approximate the solution at time TINTERP. TINTERP may be a scalar 
%   or a row vector. 
%   [YINTERP,YPINTERP] = NTRP45(TINTERP,T,Y,TNEW,YNEW,H,F) returns also the
%   derivative of the polynomial approximating the solution. 
%   
%   See also ODE45, DEVAL.

%   Mark W. Reichelt and Lawrence F. Shampine, 6-13-94
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.2 $  $Date: 2004/04/16 22:06:44 $

BI = [
    1       -183/64     37/12       -145/128
    0       0       0       0
    0       1500/371    -1000/159   1000/371
    0       -125/32     125/12      -375/64 
    0       9477/3392   -729/106    25515/6784
    0       -11/7       11/3        -55/28
    0       3/2     -4      5/2
    ];

s = (tinterp - t)/h;  
yinterp = repmat(y,size(tinterp)) + f*(h*BI)*cumprod(repmat(s,4,1));
if nargout > 1
  ypinterp = f*BI*[ ones(size(s)); cumprod([2*s;3/2*s;4/3*s])];
end
