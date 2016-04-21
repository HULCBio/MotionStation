function ddex2
%DDEX2  Example 2 for DDE23.
%   This example solves a cardiovascular model due to J.T. Ottesen, Modelling
%   of the Baroflex-Feedback Mechanism With Time-Delay, J. Math. Biol., 36
%   (1997) when the peripheral pressure R is reduced exponentially from its
%   value of 1.05 to 0.84 beginning at t = 600.  
%
%   The example shows how the 'Jumps' option is used to inform the solver
%   about discontinuities in low-order derivatives at points known in advance
%   (t = 600). Instead of using 'Jumps', this problem can be solved by
%   breaking it into two pieces:  
%       sol = dde23(@ddex2de,tau,history,[0, 600],[],p);
%       sol = dde23(@ddex2de,tau,sol,[600, 1000],[],p);
%   The solution structure SOL on [0, 600] serves as history for restarting
%   the integration at t = 600. In the second call, DDE23 extends SOL so that
%   the solution is available on all of [0 1000]. When discontinuities occur
%   in low-order derivatives at points known in advance, it is better to use
%   the 'Jumps' option. When discontinuities must be located with event 
%   functions, it is necessary to restart at the discontinuities. 
%
%   See also DDE23, DDESET, @.

%   Jacek Kierzenka, Lawrence F. Shampine and Skip Thompson
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2002/04/15 03:35:32 $

p.ca     = 1.55;
p.cv     = 519;
p.R      = 1.05;
p.r      = 0.068;
p.Vstr   = 67.9;
p.alpha0 = 93;
p.alphas = 93;
p.alphap = 93;
p.alphaH = 0.84;
p.beta0  = 7;
p.betas  = 7;
p.betap  = 7;
p.betaH  = 1.17;
p.gammaH = 0;

P0      = 93;
Paval   = P0;
Pvval   = (1 / (1 + p.R/p.r)) * P0;
Hval    = (1 / (p.R * p.Vstr)) * (1 / (1 + p.r/p.R)) * P0;
history = [Paval; Pvval; Hval];
tau     = 4;

opts = ddeset('Jumps',600);
sol = dde23(@ddex2de,tau,history,[0, 1000],opts,p);

figure
plot(sol.x,sol.y(3,:))
title('Heart Rate for Baroflex-Feedback Mechanism.')
xlabel('time t')
ylabel('H(t)')

% --------------------------------------------------------------------------

function dydt = ddex2de(t,y,Z,p)       
% Differential equations function for DDEX2.
if t <= 600
   p.R = 1.05;
else
   p.R = 0.21 * exp(600-t) + 0.84;
end    
ylag = Z(:,1);
Patau = ylag(1);
Paoft = y(1);
Pvoft = y(2);
Hoft  = y(3);
dPadt = - (1 / (p.ca * p.R)) * Paoft + (1/(p.ca * p.R)) * Pvoft ...
        + (1/p.ca) * p.Vstr * Hoft;
dPvdt = (1 / (p.cv * p.R)) * Paoft                          ...
        - ( 1 / (p.cv * p.R) + 1 / (p.cv * p.r) ) * Pvoft;
Ts = 1 / ( 1 + (Patau / p.alphas)^p.betas );
Tp = 1 / ( 1 + (p.alphap / Paoft)^p.betap );
dHdt = (p.alphaH * Ts) / (1 + p.gammaH * Tp) - p.betaH * Tp;
dydt = [ dPadt
         dPvdt
         dHdt ];
