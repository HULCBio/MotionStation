function pdex2
%PDEX2  Example 2 for PDEPE
%   This example illustrates the solution of a problem with a material
%   interface. In addition to the discontinuity for this reason at x = 0.5,
%   the initial values have a discontinuity at the end x = 1.  There is a 
%   coordinate singularity from spherical symmetry. This is Example 2 of [1].
%
%   For 0 <= x <= 0.5, the partial differential equation is
%
%    [1] .*  D_ [u] = x^(-2) * D_ [x^2 *   5* Du/Dx  ] + [- 1000*exp(u)]
%            Dt                Dx
%
%   and for 0.5 < x <= 1, it is 
%
%    [1] .*  D_ [u] = x^(-2) * D_ [x^2 *      Du/Dx  ] + [  - exp(u)   ]
%            Dt                Dx
%    ---        ---                     -------------     -------------
%     c          u                      f(x,t,u,Du/Dx)    s(x,t,u,Du/Dx)
%
%   The flux f is required to be continuous at x = 0.5, which obviously 
%   requires the partial derivative Du/Dx to change by a factor of 5 at
%   the material interface.
%
%   The initial condition is u(x,0) = 0 for 0 <= x < 1, u(1,0) = 1.  
%   The left boundary condition Du/Dx = 0 states that the spherically
%   symmetric solution is bounded at the origin. PDEPE imposes it
%   automatically, ignoring any condition specified for it in PDEX2BC.
%
%   The right boundary condition is u(1,t) = 1:
%
%    [ u - 1 ] + [0] .* [   Du/Dx    ] = [0]
%
%     -------    ---    --------------   ---
%     p(1,t,u)  q(1,t)   f(1,t,u,Du/Dx)   0
%
%   See the subfunctions PDEX2PDE, PDEX2IC, and PDEX2BC for the coding of the
%   problem definition.  
%
%   The spatial mesh should include 0.5 to account for the interface. It also
%   should include points near 1.0 because of the inconsistency of initial and
%   boundary values there.  The solution changes rapidly for small t.  The 
%   program selects the step size in time to resolve this sharp change, but to 
%   see this behavior in the plots, output times must be selected accordingly.
%   Solution profiles at these times show clearly the effect of the interface.
%
%   [1] D03PBF, NAG Library Manual, Numerical Algorithms Group, Oxford. 
%
%   See also PDEPE, @.

%   Lawrence F. Shampine and Jacek Kierzenka
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/15 03:30:24 $

m = 2;
x = [0 0.1 0.2 0.3 0.4 0.45 0.475 0.5 0.525 0.55 0.6 0.7 0.8 0.9 0.95 0.975 0.99 1];
t = [0 0.001 0.005 0.01 0.05 0.1 0.5 1];

sol = pdepe(m,@pdex2pde,@pdex2ic,@pdex2bc,x,t);
u = sol(:,:,1);

figure;
surf(x,t,u);
title('Numerical solution computed using a nonuniform mesh.');
xlabel('Distance x');
ylabel('Time t');

figure;
plot(x,u,x,u,'*');
xlabel('Distance x');
title('Solution profiles at a selection of times.');

% --------------------------------------------------------------------------

function [c,f,s] = pdex2pde(x,t,u,DuDx)
c = 1;
if x <= 0.5
  f = 5*DuDx;
  s = -1000*exp(u);
else
  f = DuDx;
  s = -exp(u);
end

% --------------------------------------------------------------------------

function u0 = pdex2ic(x)
if x < 1
  u0 = 0;
else
  u0 = 1;
end

% --------------------------------------------------------------------------

function [pl,ql,pr,qr] = pdex2bc(xl,ul,xr,ur,t)
pl = 0;  % pdepe will use pl=ql=0 because this 
ql = 0;  % problem has a singularity: xl=0 and m>0
pr = ur - 1;
qr = 0;
