function pdex3
%PDEX3  Example 3 for PDEPE
%   This example illustrates the use of PDEVAL to obtain partial derivatives
%   that are part of solving the problem. A relatively fine spatial mesh is
%   needed to obtain accurate partial derivatives. Values are required at a
%   relatively large number of times. 
%
%   This problem arises in transistor theory. It is used in [1] to illustrate
%   solution of PDEs with series. In the form expected by PDEPE, the single PDE
%   is  
%
%    [1] .*  D_ [u] =  D_ [   d*Du/Dx   ] +  [ -(eta/L)*Du/Dx ]
%            Dt        Dx
%    ---        ---        -------------      ----------------
%     c          u         f(x,t,u,Du/Dx)      s(x,t,u,Du/Dx)
%
%   Here d and eta are physical constants. The equation is to hold on an
%   interval 0 <= x <= L for times t >= 0. For the problem at hand, L = 1. 
%   The initial condition  
%
%      u(x,0) = (K*L/d)*((1 - exp(-eta*(1 - x/L)))/eta)
%
%   involves another physical constant K. The left bc is u(0,t) = 0:
%
%      [u]    +     [0] .* [       Du/Dx          ] = [0]
%
%      ---          ---    ------------------------   ---
%    p(0,t,u)      q(0,t)        f(0,t,u,Du/Dx)        0
%
%   The right bc is u(L,t) = 0:
%
%      [u]    +     [0] .* [       Du/Dx          ] = [0]
%
%      ---          ---    ------------------------   ---
%    p(L,t,u)      q(L,t)        f(L,t,u,Du/Dx)        0
%
%   See the subfunctions PDEX3PDE, PDEX3IC, and PDEX3BC for the coding of the
%   problem definition.  
%
%   A quantity of physical interest is the emitter discharge current
%
%      I(t) = (I_p*d/K)*Du(0,t)/Dx
%
%   where I_p is another physical constant. This is meaningful only for t > 0
%   because of the inconsistency in the boundary values at x = 0 for t = 0 and
%   t > 0. This is reflected in the failure to converge of the series solution
%   of [1] for t = 0. Because values for the physical parameters are not
%   specified in [1], nominal values are assumed. I(t) changes rapidly, so
%   output at a relatively large number of t are needed. Recall that the number
%   and placement of the entries of t have little effect on the cost of the
%   computation. Also, the approximation of the solution is only second order
%   in space and the approximation of the partial derivative is of still lower
%   order. Nevertheless, there is reasonable agreement between the computed
%   emitter discharge current and that obtained from the series. 
%
%   [1] E.C. Zachmanoglou and D.L. Thoe,Introduction to Partial Differential 
%       Equations with Applications, Dover, New York, 1986. 
%
%   See also PDEPE, PDEVAL, @.

%   Lawrence F. Shampine and Jacek Kierzenka
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/15 03:30:26 $

L = 1;
d = 0.1;
eta = 10;
K = d;
I_p = 1;

m = 0;
x = linspace(0,L,41);
t = linspace(0,1,51);
sol = pdepe(m,@pdex3pde,@pdex3ic,@pdex3bc,x,t,[],L,K,d,eta);
u = sol(:,:,1);

figure;
surf(x,t,u);
title('Numerical solution computed with 41 mesh points.');
xlabel('Distance x');
ylabel('Time t');

nt = length(t);
I = zeros(1,nt);
seriesI = zeros(1,nt);
iok = 2:nt;
for j = iok
  % At time t(j), compute Du/Dx at x = 0.
  [dummy,I(j)] = pdeval(m,x,u(j,:),0);
  seriesI(j) = serex3(t(j),L,d,eta,I_p);
end
% I(t) = (I_p*d/K)*Du(0,t)/Dx
I = (I_p*d/K)*I;

figure;
plot(t(iok),I(iok),t(iok),seriesI(iok));
legend('From PDEPE','From series');
title('Emitter discharge current I(t)');
xlabel('Time t');
  
% --------------------------------------------------------------------------

function [c,f,s] = pdex3pde(x,t,u,DuDx,L,K,d,eta)
c = 1;                 
f = d*DuDx;            
s = -d*eta*DuDx;       

% --------------------------------------------------------------------------

function u0 = pdex3ic(x,L,K,d,eta)
u0 = (K*L/d)*(1 - exp(-eta*(1 - x)))/eta;

% --------------------------------------------------------------------------

function [pl,ql,pr,qr] = pdex3bc(xl,ul,xr,ur,t,L,K,d,eta)
pl = ul;                 
ql = 0;                 
pr = ur;                 
qr = 0;                 
  
% --------------------------------------------------------------------------

function It = serex3(t,L,d,eta,I_p)
%  Approximate I(t) by 40 terms of a series expansion.

It = 0;
for n = 1:40
  temp = (n*pi)^2 + 0.25*eta^2;
  It = It + ((n*pi)^2 / temp)* exp(-(d/L^2)*temp*t);
end
It = 2*I_p*((1 - exp(-eta))/eta)*It;
