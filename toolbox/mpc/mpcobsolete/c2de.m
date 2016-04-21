function [phi,gam,f0] = c2de(a,b,T,dx0)

% [Phi,Gam] = c2de(A,B,T)
%          or
% [Phi,Gam,f0] = c2de(A,B,T,dx0)
%
% Discretizes Continuous System.
% Uses Algorithm of Franklin, Powell and Workman (1990, pag. 63)
% Otherwise identical to C2DMP.
% See C2DMP for description of the variables.

%  Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.1.6.2 $

[nx,nx2] = size(a);
if(nx ~= nx2),
  error('Matrix A should be square')
end
[nx2,nu] = size(b);
if(nx ~= nx2),
  error('Matrices A and B must have same number of rows')
end

if nargin < 4
   dx0=[];
elseif ~isempty(dx0)
   dx0=dx0(:);
   if length(dx0) ~= nx
      error('Size of DX0 is inconsistent with size of A')
   end
end

if nx == 0
   phi=zeros(nx,nx);
   gam=zeros(nx,nu);
   f0=zeros(nx,1);
   return
end


check = ones(1,nx)*abs(a);
check = max(check)*T;
k     = log(check)/log(2);


if(k < 0),
  k = 0;
else
  k = round(k) + 1;
end
T1    = T/(2^k);


% We will compute psi(T/2^k)

 ident = eye(nx);
 psi   = ident;

 for j = 22:-1:2
   psi = ident + T1/j * a * psi;
 end


   for j = k:-1:1
    psi = (ident + a*T1/(2) * psi )*psi;
    T1  = T1*2;
   end


phi = ident + a*T*psi;
gam = psi*T*b;
if isempty(dx0)
   f0=zeros(nx,1);
else
   f0=psi*T*dx0;
end