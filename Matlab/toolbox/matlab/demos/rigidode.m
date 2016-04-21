function rigidode
%RIGIDODE  Euler equations of a rigid body without external forces.
%   A standard test problem for non-stiff solvers proposed by Krogh.  The
%   analytical solutions are Jacobian elliptic functions, accessible in
%   MATLAB.  The interval here is about 1.5 periods; it is that for which
%   solutions are plotted on p. 243 of Shampine and Gordon.
%   
%   L. F. Shampine and M. K. Gordon, Computer Solution of Ordinary
%   Differential Equations, W.H. Freeman & Co., 1975.
%   
%   See also ODE45, ODE23, ODE113, @.

%   Mark W. Reichelt and Lawrence F. Shampine, 3-23-94, 4-19-94
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.14 $  $Date: 2002/04/15 03:30:50 $

tspan = [0 12];
y0 = [0; 1; 1];

% solve the problem using ODE45
figure;
ode45(@f,tspan,y0);

% --------------------------------------------------------------------------

function dydt = f(t,y)
dydt = [    y(2)*y(3) 
           -y(1)*y(3) 
        -0.51*y(1)*y(2) ];

