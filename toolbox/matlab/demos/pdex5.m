function pdex5
%PDEX5  Example 5 for PDEPE
%   This example is a mathematical model of the first steps of tumour-related
%   angiogenesis [1]. The PDEs are
%  
%      Dn/Dt = D(d*Dn/Dx - a*n*Dc/Dx)/Dx + s*r*n*(N - n)
%      Dc/Dt = D(Dc/Dx)/Dx + s*(n/(n+1) - c)
%
%   In the form expected by PDEPE, the equations are
%
%    |1|         |n|      | d*D(n)/Dx - a*n*D(c)/Dx |    |  s*r*n*(N - n) |
%    | | .*  D_  | | = D_ |                         | +  |                |
%    |1|     Dt  |c|   Dx |        D(c)/Dx          |    | s*(n/(n+1) - c |
%
%   Figures 3 and 4 of [1] correspond to the parameter values d = 1e-3, a = 3.8, 
%   s = 3, r = 0.88, and N = 1. 
%
%   The initial conditions are perturbations of the constant steady state n = 1, 
%   c = 0.5 for 0 <= x <= 1.  A linear stability analysis predicts evolution of 
%   the system to a spatially inhomogeneous solution.  Step functions are specified 
%   as initial values in PDEX5IC to stimulate the evolution.  
%
%   At both ends of [0,1], both solution components are to have zero flux, so both
%   the left and right boundary conditions are
%
%      |0|       |1|     | d*D(n)/Dx - a*n*D(c)/Dx |   |0|
%      | |   +   | | .*  |                         | = | |
%      |0|       |1|     |        D(c)/Dx          |   |0|
%
%   See the subfunctions PDEX5PDE, PDEX5IC, and PDEX5BC for the coding of the
%   problem definition. 
%
%   It is found that a long time interval is needed to see the limiting 
%   distributions. Also, the limit distribution for c(x,t) varies by only 0.1% 
%   over the interval [0,1], so a relatively fine mesh is appropriate.
%
%   [1] M.E. Orme and M.A.J. Chaplain, A mathematical model of the first steps 
%       of tumour-related angiogenesis: capillary sprout formation and secondary 
%       branching, IMA J. of Mathematics Applied in Medicine & Biology, 13 (1996)
%       pp. 73-98.
%
%   See also PDEPE, @.

%   Lawrence F. Shampine and Jacek Kierzenka
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/15 03:30:30 $

m = 0;
x = linspace(0,1,41);
t = linspace(0,200,10);

sol = pdepe(m,@pdex5pde,@pdex5ic,@pdex5bc,x,t);
n = sol(:,:,1);
c = sol(:,:,2); 

figure;
surf(x,t,c);
title('Distribution of fibronectin--c(x)');
xlabel('Distance x');
ylabel('Time t');

figure;
surf(x,t,n);
title('Distribution of ECs--n(x)');
xlabel('Distance x');
ylabel('Time t');

figure;
plot(x,n(end,:));
title('Final distribution of n(x).');

figure;
plot(x,c(end,:));
title('Final distribution of c(x).');

% --------------------------------------------------------------------------  

function [c,f,s] = pdex5pde(x,t,u,DuDx)
d = 1e-3;
a = 3.8;
S = 3;
r = 0.88;
N = 1;

c = [1; 1];                                  
f = [ d*DuDx(1) - a*u(1)*DuDx(2)
             DuDx(2)            ];
s1 = S*r*u(1)*(N - u(1));
s2 = S*(u(1)/(u(1) + 1) - u(2));
s = [s1; s2];                                

% --------------------------------------------------------------------------  

function u0 = pdex5ic(x)
u0 = [1; 0.5];
if x >= 0.3 & x <= 0.6
  u0(1) = 1.05 * u0(1);
  u0(2) = 1.0005 * u0(2);
end

% --------------------------------------------------------------------------  

function [pl,ql,pr,qr] = pdex5bc(xl,ul,xr,ur,t)
pl = [0; 0];                                  
ql = [1; 1];                                  
pr = [0; 0];                                  
qr = [1; 1];                                  

