function [c, ceq, dc, dceq] = confungrad(x)
% Nonlinear inequality constraints:

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2004/02/07 19:12:54 $

c = [1.5 + x(1)*x(2) - x(1) - x(2); 
     -x(1)*x(2) - 10];
% Gradient (partial derivatives) of nonlinear inequality constraints:
dc = [x(2)-1, -x(2); 
      x(1)-1, -x(1)];
% no nonlinear equality constraints (and gradients)
ceq = [];
dceq = [];