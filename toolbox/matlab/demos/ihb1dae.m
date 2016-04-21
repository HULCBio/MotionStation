function  ihb1dae
%IHB1DAE  Stiff differential-algebraic equation (DAE) from a conservation law.
%   IHB1DAE runs a demo of the solution of a stiff differential-algebraic
%   equation (DAE) system expressed as a fully implicit system f(t,y,y') = 0. 
%   
%   The Robertson problem, as it is coded in HB1ODE, is a classic test problem 
%   for codes that solve stiff ODEs.  The problem is 
%
%         y(1)' = -0.04*y(1) + 1e4*y(2)*y(3)
%         y(2)' =  0.04*y(1) - 1e4*y(2)*y(3) - 3e7*y(2)^2
%         y(3)' =  3e7*y(2)^2
%
%   It is to be solved with initial conditions y(1) = 1, y(2) = 0, y(3) = 0 
%   to steady state.  
%
%   These differential equations satisfy a linear conservation law that can
%   be used to reformulate the problem as the DAE
%
%         0 =  y(1)' + 0.04*y(1) - 1e4*y(2)*y(3)
%         0 =  y(2)' - 0.04*y(1) + 1e4*y(2)*y(3) + 3e7*y(2)^2
%         0 =  y(1)  + y(2) + y(3) - 1
%
%   This problem is used as an example in the prolog to LSODI [1].  Though
%   consistent initial conditions are obvious, the guess y(3) = 1e-3 is used
%   to test initialization.  A logarithmic scale is appropriate for plotting
%   the solution on the long time interval.  y(2) is small and its major
%   change takes place in a relatively short time.  Accordingly, the prolog
%   to LSODI specifies a much smaller absolute error tolerance on this
%   component. Also, when plotting it with the other components, it is
%   multiplied by 1e4. The natural output of the code does not show clearly
%   the behavior of this component, so additional output is specified for
%   this purpose.
%   
%   [1]  A.C. Hindmarsh, LSODE and LSODI, two new initial value ordinary
%        differential equation solvers, SIGNUM Newsletter, 15 (1980), 
%        pp. 10-11.
%   
%   See also ODE15I, ODE15S, ODE23T, ODESET, HB1ODE, HB1DAE, @.

%   Mark W. Reichelt and Lawrence F. Shampine
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $

% Use an inconsistent initial condition to test initialization.
y0 = [1; 0; 1e-3];
yp0 =[0; 0;    0];

tspan = [0 4*logspace(-6,6)];

M = [1 0 0
     0 1 0
     0 0 0];

% Use the LSODI example tolerances and set the value of df/dy'
options = odeset('RelTol',1e-4,'AbsTol',[1e-6 1e-10 1e-6], ...
                 'Jacobian',{[],M});

% For this problem you cannot fix more than two components of the guesses. 
% Fixing the first two components of y0 leads to the same consistent initial
% conditions found by ODE15S in HB1DAE.  
[y0,yp0] = decic(@f,0,y0,[1 1 0],yp0,[],options);

[t,y] = ode15i(@f,tspan,y0,yp0,options);

y(:,2) = 1e4*y(:,2);

figure;
semilogx(t,y);
ylabel('1e4 * y(:,2)');
title('Robertson DAE problem with a Conservation Law, solved by ODE15I');
xlabel('This is equivalent to the stiff ODEs coded in HB1ODE.');

% --------------------------------------------------------------------------

function res = f(t,y,yp)
res = [ yp(1) + 0.04*y(1) - 1e4*y(2)*y(3)
        yp(2) - 0.04*y(1) + 1e4*y(2)*y(3) + 3e7*y(2)^2
         y(1) + y(2) + y(3) - 1 ];

