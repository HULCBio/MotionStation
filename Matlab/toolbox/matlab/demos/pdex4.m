function pdex4
%PDEX4  Example 4 for PDEPE
%   This example illustrates the solution of a system of partial differential
%   equations with PDEPE. It is a problem from electrodynamics that has boundary
%   layers at both ends of the interval. Also, the solution changes rapidly for
%   small t. This is Example 1 of [1].
%
%   The PDEs are
%   
%      D(u1)/Dt = 0.024*D^2(u1)/Dx^2 - F(u1 - u2)
%      D(u2)/Dt = 0.170*D^2(u2)/Dx^2 + F(u1 - u2)
% 
%   where F(y) = exp(5.73*y) - exp(-11.46*y).
%
%   In the form expected by PDEPE, the equations are
%
%   |1|         |u1|      | 0.024*D(u1)/Dx |    |- F(u1 - u2) |
%   | | .*  D_  |  | = D_ |                | +  |             |
%   |1|     Dt  |u2|   Dx | 0.170*D(u2)/Dx |    |+ F(u1 - u2) |
%
%   ---         ---       ------------------    ---------------
%    c           u          f(x,t,u,Du/Dx)       s(x,t,u,Du/Dx)
%
%   The initial condition is u1(x,0) = 1 and u2(x,0) = 0 for 0 <= x <= 1.
%   The left boundary condition is D(u1)/Dx = 0, u2(0,t) = 0.  The 
%   condition on the partial derivative of u1 has to be written in terms 
%   of the flux.  In the form expected by PDEPE, the left bc is
%
%      |0 |       |1|     | 0.024*D(u1)/Dx |   |0|
%      |  |   +   | | .*  |                | = | |
%      |u2|       |0|     | 0.170*D(u2)/Dx |   |0|
%
%      ---        ---     ------------------   ---
%    p(0,t,u)    q(0,t)     f(0,t,u,Du/Dx)      0
%
%   The right boundary condition is u1(1,t) = 1, D(u2)/Dx = 0:
%
%      |u1 - 1|       |0|     | 0.024*D(u1)/Dx |   |0|
%      |      |   +   | | .*  |                | = | |
%      |   0  |       |1|     | 0.170*D(u2)/Dx |   |0|
%
%      -------       -----    ------------------   ---
%      p(1,t,u)      q(1,t)     f(1,t,u,Du/Dx)      0
%
%   See the subfunctions PDEX4PDE, PDEX4IC, and PDEX4BC for the coding of the
%   problem definition. 
%
%   The solution changes rapidly for small t.  The program selects the step 
%   size in time to resolve this sharp change, but to see this behavior in 
%   the plots, output times must be selected accordingly.  There are boundary
%   layers in the solution at both ends of [0,1], so mesh points must be
%   placed there to resolve these sharp changes.
%
%   [1] D03PBF, NAG Library Manual, Numerical Algorithms Group, Oxford. 
%
%   See also PDEPE, @.

%   Lawrence F. Shampine and Jacek Kierzenka
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2004/04/10 23:25:02 $

m = 0;
x = [0 0.005 0.01 0.05 0.1 0.2 0.5 0.7 0.9 0.95 0.99 0.995 1];
t = [0 0.005 0.01 0.05 0.1 0.5 1 1.5 2];

sol = pdepe(m,@pdex4pde,@pdex4ic,@pdex4bc,x,t);
u1 = sol(:,:,1);
u2 = sol(:,:,2);

figure;
surf(x,t,u1);
title('u1(x,t)');
xlabel('Distance x');
ylabel('Time t');

figure;
surf(x,t,u2);
title('u2(x,t)');
xlabel('Distance x');
ylabel('Time t');

% --------------------------------------------------------------------------

function [c,f,s] = pdex4pde(x,t,u,DuDx)
c = [1; 1];                                  
f = [0.024; 0.17] .* DuDx;                   
y = u(1) - u(2);
F = exp(5.73*y)-exp(-11.47*y);
s = [-F; F];                                 

% --------------------------------------------------------------------------

function u0 = pdex4ic(x)
u0 = [1; 0];                                 

% --------------------------------------------------------------------------

function [pl,ql,pr,qr] = pdex4bc(xl,ul,xr,ur,t)
pl = [0; ul(2)];                               
ql = [1; 0];                                  
pr = [ur(1)-1; 0];                            
qr = [0; 1];                                  

