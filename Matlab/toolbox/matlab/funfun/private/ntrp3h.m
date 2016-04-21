function [yint,ypint] = ntrp3h(tint,t,y,tnew,ynew,yp,ypnew)
%NTRP3H  Interpolation helper function for BVP4C and DDE23.
%   YINT = NTRP3H(TINT,T,Y,TNEW,YNEW,YP,YPNEW) evaluates the Hermite cubic
%   interpolant at time TINT. TINT may be a scalar or a row vector.   
%   [YINT,YPINT] = NTRP3H(TINT,T,Y,TNEW,YNEW,YP,YPNEW) returns also the
%   derivative of the interpolating polynomial. 
%   
%   See also BVP4C, DDE23, DEVAL.

%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2003/10/21 11:55:52 $

h = tnew - t;
s = (tint - t)/h;
s2 = s .* s;
s3 = s .* s2;
slope = (ynew - y)/h;
c = (3*slope - 2*yp - ypnew)*h;
d = (yp + ypnew - 2*slope)*h;
yint = d*s3 + c*s2 + h*yp*s + repmat(y,size(tint));        
if nargout > 1
  ypint = 1/h*(3*d*s2 + 2*c*s) + repmat(yp,size(tint));        
end    

