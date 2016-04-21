function [A,B] = d2cmp(Phi,Gam,T)
%D2CMP	Convert from discrete to continuous systems
%	[A,B] = d2cmp(Phi,Gam,T)
%
%       Discrete System   : x(k+1)  = Phi*x(k) + Gam*u(k)
%       Continuous System : dx/dt   = Ax + Bu
%       Sample Time (ZOH) : T
%

%     Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

%  Check Dimensions First:

[nx,nx2]    = size(Phi);
if(nx ~= nx2),
   error('Matrix Phi must be square')
end

[nx2,nu]    = size(Gam);
if(nx2 ~= nx)
  error('Matrices Phi and Gam must have same number of rows')
end

M           = [Phi  Gam];
vec         = [nx+1:nx+nu];
M(vec,vec)  = eye(nu);

Cont        = real(logm(M));
A           = Cont(1:nx,1:nx)/T;
B           = Cont(1:nx,vec)/T;