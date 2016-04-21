function[pert,x,y] = perturb(x,l,u,del,y,sigma)
%PERTURB Perturb point from bounds
%
%   [PERT,X] = PERTURB(X,L,U,DEL) perturbs the current point X
%   slightly to shake it loose from tight (less than DEL away)
%   bounds U and L to be strictly feasible. 
%   Called by SNLS and SFMINBX.
%
%   [PERT,X,Y] = PERTURB(X,L,U,DEL,Y,SIGMA) also perturbs the 
%   reflected point Y with respect to SIGMA,

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.3.2.1 $  $Date: 2004/02/01 21:43:34 $

if nargin < 4
   del = 100*eps;
end

if (min(abs(u-x)) < del) | (min(abs(x-l)) < del)
   upperi = (u-x) < del; 
   loweri = (x-l) < del;
   x(upperi) = x(upperi) - del;
   x(loweri) = x(loweri) + del;
   if nargin > 4
      y(upperi) = y(upperi) - del*sigma(upperi);
      y(loweri) = y(loweri) + del*sigma(loweri);
   end
   pert = 1;
else
   pert = 0;
end




