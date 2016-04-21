function [f, G] = objfungrad(x)
% objective function:

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2004/02/07 19:13:23 $

f =exp(x(1)) * (4*x(1)^2 + 2*x(2)^2 + 4*x(1)*x(2) + 2*x(2) + 1);
% gradient (partial derivatives) of the objective function:
t = exp(x(1))*(4*x(1)^2+2*x(2)^2+4*x(1)*x(2)+2*x(2)+1);
G = [ t + exp(x(1)) * (8*x(1) + 4*x(2)), 
      exp(x(1))*(4*x(1)+4*x(2)+2)];
