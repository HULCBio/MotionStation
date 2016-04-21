function f = objfun(x)
% Objective function

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2004/04/06 01:10:28 $

f = exp(x(1)) * (4*x(1)^2 + 2*x(2)^2 + 4*x(1)*x(2) + 2*x(2) + 1);
