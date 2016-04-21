function hb1ode
%HB1ODE  Stiff problem 1 of Hindmarsh and Byrne.
%   HB1ODE runs a demo of the solution of the original Robertson chemical
%   reaction problem on a very long interval.  Because the components tend to
%   a constant limit, it tests reuse of Jacobians.  The equations themselves
%   can be unstable for negative solution components, which is admitted by
%   the error control.  Many codes can, therefore, go unstable on a long time
%   interval because a solution component goes to zero and a negative
%   approximation is entirely possible.  The default interval is the 
%   longest for which the Hindmarsh and Byrne code EPISODE is stable.  The
%   system satisfies a conservation law which can be monitored:  
%   
%       y(1) + y(2) + y(3) = 1
%   
%   A. C. Hindmarsh and G. D. Byrne, Applications of EPISODE: An
%   Experimental Package for the Integration of Ordinary Differential
%   Equations, in Numerical Methods for Differential Systems, L. Lapidus and
%   W. E. Schiesser eds., Academic Press, Orlando, FL, 1976, pp 147-166.
%   
%   See also ODE15S, ODE23S, ODE23T, ODE23TB, ODESET, @.

%   Mark W. Reichelt and Lawrence F. Shampine, 2-11-94, 4-18-94
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.16 $  $Date: 2002/04/15 03:30:46 $

tspan = [0; 0.04e9];
y0 = [1; 0; 0];

[t,y] = ode15s(@f,[0 4*logspace(-6,6)],y0);

y(:,2) = 1e4*y(:,2);

figure;
semilogx(t,y);
ylabel('1e4 * y(:,2)');
title('Robertson problem solved by ODE15S');
xlabel('This is equivalent to the DAEs coded in HB1DAE.');

% --------------------------------------------------------------------------

function dydt = f(t,y)
dydt = [ (-0.04*y(1) + 1e4*y(2)*y(3))
         (0.04*y(1) - 1e4*y(2)*y(3) - 3e7*y(2)^2)
         3e7*y(2)^2 ];
    
