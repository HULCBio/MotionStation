function y = simple_objective(x)
%SIMPLE_OBJECTIVE Objective function for PATTERNSEARCH solver

%   Copyright 2004 The MathWorks, Inc.  
%   $Revision: 1.1 $  $Date: 2004/01/14 15:35:08 $

x1 = x(1);
x2 = x(2);
y = (4-2.1.*x1.^2+x1.^4./3).*x1.^2+x1.*x2+(-4+4.*x2.^2).*x2.^2;
