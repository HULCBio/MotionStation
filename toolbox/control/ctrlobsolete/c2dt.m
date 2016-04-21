function [PHI,GAMMA,H,J] = c2dt(A,B,C,T,lambda)
%C2DT   Conversion of continuous state space models to discrete 
%       models with pure time delay in the inputs.
%
%   [Ad,Bd,Cd,Dd] = C2DT(A,B,C,T,lambda) converts the continuous time
%   system
%              .
%              x(t) = Ax(t) + Bu(t-lambda)
%              y(t) = Cx(t) 
%
%   to the discrete system with sample time T,
%
%            x(k+1) = Ad x(k) + Bd u(k)
%              y(k) = Cd x(k) + Dd u(k) 
%
%   See also  PADE.

%   G. Franklin 1-17-87
%   Revised 8-23-87 JNL
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 06:35:01 $

%   From results in Franklin and Powell, Digital Control; Addison
%   and Wesley; 1980 chapter 6, pages 171-177, with extension for
%   multivariable controls and outputs.

[ns,nc] = size(B);
[no,ns] = size(C);
l = ceil(lambda/T);
m = l*T - lambda;

s1 = expm([A*m, B*m; zeros(nc,ns+nc)]);
s2 = expm([A*(T-m), B*(T-m); zeros(nc,ns+nc)]);
s3 = eye((l-1)*nc);
s4 = zeros(ns,(l-2)*nc);
s5 = zeros((l-1)*nc,ns+nc);
s6 = zeros(nc,ns+l*nc);

PHI1 = s1(1:ns,1:ns)*s2(1:ns,1:ns);
GAMMA1 = s1(1:ns,1:ns)*s2(1:ns,ns+1:ns+nc);
GAMMA2 = s1(1:ns,ns+1:ns+nc);
if l == 0
% This is the modified z-transform case
    PHI = PHI1;
    GAMMA = PHI1 * GAMMA2 + GAMMA1;
    H     =  C;
    J     =  C * GAMMA2;
elseif l == 1
%
% Delay less than one period
%
    PHI    = [PHI1, GAMMA1; s6];
    GAMMA  = [GAMMA2;eye(nc)];
    H      = [C,zeros(no,nc)];
    J      = zeros(no,nc);
else
    PHI    = [PHI1,GAMMA1,GAMMA2,s4;s5,s3;s6];
    GAMMA  = [zeros(ns+(l-1)*nc,nc);eye(nc)];
    H      = [C,zeros(no,l*nc)];
    J      = zeros(no,nc);
end
