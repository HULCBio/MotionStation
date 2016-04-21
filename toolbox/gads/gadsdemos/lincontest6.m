function y = lincontest6(x)
%From example of QUADPROG (Optim toolbox)

%   Copyright 2003 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2003/08/04 13:49:17 $

p1=0.5;
p2=6.0;
y = p1*x(1)^2 + x(2)^2 -x(1)*x(2) -2*x(1) - p2*x(2);

%Derivative of the function above
% dy = [(2*p1*x(1) - x(2) -2);(2*x(2) -x(1) -p2)];
