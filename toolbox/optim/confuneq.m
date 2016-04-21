function [c, ceq] = confuneq(x)
% Nonlinear inequality constraints:

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $  $Date: 2004/02/07 19:12:53 $

c = -x(1)*x(2) - 10;
% Nonlinear equality constraint:
ceq = x(1)^2 + x(2) - 1;
