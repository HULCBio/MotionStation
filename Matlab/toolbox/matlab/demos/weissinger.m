function res = weissinger(t,y,yp)
%WEISSINGER  Evaluate the residual of the Weissinger implicit ODE
%
%   See also ODE15I.

%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2002/09/26 01:52:37 $

res = t*y^2 * yp^3 - y^3 * yp^2 + t*(t^2 + 1)*yp - t^2 * y;
