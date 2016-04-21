%   LQG design for 60 degree aircraft turn

%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/10 06:40:38 $

% State vector = [u,v,w,p,q,r,theta,phi]
%     u,v,w: linear velocities
%     p,q,r: roll, pitch, yaw rates
%     theta: pitch angle 
%     phi: bank angle

% Linear dynamics
A = [-0.0404    0.0618    0.0501   -0.0000   -0.0005    0.0000 
   -0.1686   -1.1889    7.6870         0    0.0041         0
    0.1633   -2.6139   -3.8519    0.0000    0.0489   -0.0000 
   -0.0000   -0.0000   -0.0000   -0.3386   -0.0474   -6.5405  
   -0.0000    0.0000   -0.0000   -1.1288   -0.9149   -0.3679  
   -0.0000   -0.0000   -0.0000    0.9931   -0.1763   -1.2047 
         0         0    0.9056         0         0   -0.0000
         0         0   -0.0000         0    0.9467   -0.0046];
A = [A, zeros(8,2)];
 

B =[ 20.3929   -0.4694   -0.2392   -0.7126
    0.1269   -2.6932    0.0013    0.0033
  -64.6939  -75.6295    0.6007    3.2358
   -0.0000         0    0.1865    3.6625
   -0.0000         0   23.6053    5.6270
   -0.0001         0    3.9462  -41.4112
         0         0         0         0
         0         0         0         0];

% Trim nonlinear dynamics about phi=15 degrees with p,q,r,theta small.
% Note: Since 
%          * u,v,w don't enter the nonlinear terms
%          * theta=0 during the maneuver (cancels the trim values of p,q,r)
%       this is equivalent to linearizing about x=[0,0,0,0,0,0,0,phi]
g = 32.2;
th0 = 0;
ph0 = 15*pi/180;  % 15 degrees
q0 = 0;
r0 = 0;
A_nl = [...
        0  0 -g*cos(th0) 0; ...
        0  0 -g*sin(th0)*sin(ph0) g*cos(th0)*cos(ph0); ...
        0  0 -g*sin(th0)*cos(ph0) -g*cos(th0)*sin(ph0); ...
        0  0  0  0; ...
        0  0  0  0; ...
        0  0  0  0; ...
        cos(ph0)  -sin(ph0) 0  -q0*sin(ph0)-r0*cos(ph0); ...
        sin(ph0)*tan(th0)  cos(ph0)*tan(th0) ...
           (q0*sin(ph0)+r0*cos(ph0))*(1+tan(th0)^2) (q0*cos(ph0)-r0*sin(ph0))*tan(th0)];
A15 = A + [zeros(8,4) A_nl];
 
% Add integrator state dz/dt = -phi
A_aug = [zeros(1,8) -1; zeros(8,1) A15];
B_aug = [zeros(1,4) ; B];

% LQR gain synthesis
Q = blkdiag(1,0.1*eye(6),1000,1);
R = diag([10,50,1,1]);
K_lqr = lqr(A_aug,B_aug,Q,R);

