function yp = lotka(t,y)
%LOTKA  Lotka-Volterra predator-prey model.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.7 $  $Date: 2002/04/15 03:33:21 $

yp = diag([1 - .01*y(2), -1 + .02*y(1)])*y;
