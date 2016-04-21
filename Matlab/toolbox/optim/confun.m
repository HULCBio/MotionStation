function [c, ceq] = confun(x)
% Nonlinear inequality constraints:

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2004/04/06 01:10:16 $

c = [1.5 + x(1)*x(2) - x(1) - x(2); 
     -x(1)*x(2) - 10];
% No nonlinear equality constraints:
ceq = [];
