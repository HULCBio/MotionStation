function [A,B,C,D,K,X0]=ssmodxx(th,mod)
%SSMODX9 The standard state-space model
%
%   [A,B,C,D,K,X0] = ssmodxx(PARVAL,MS)
%
%   This routine is used as the standard model-defining routine
%   inside the THETA-structure for state space models if no user-
%   defined structure is specified. The use of SSMODXX should be
%   transparent to the user.
%
%   A,B etc: The discrete time state space matrices corresponding to
%   the parameter values PARVAL for a linear model structure
%   defined by MS (obtained from MODSTRUC or CANFORM)

%   L. Ljung 10-2-90,11-25-93
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $  $Date: 2004/04/10 23:20:28 $
 
s=1;
A=mod.as;nx=size(A,1);
for kr=1:nx
   for kc=1:nx
      if isnan(A(kr,kc)), A(kr,kc)=th(s);s=s+1;end
   end
end
B=mod.bs;nu=size(B,2); 
for kr=1:nx
   for kc=1:nu
      if isnan(B(kr,kc)),B(kr,kc)=th(s);s=s+1;end
   end
end
C=mod.cs;ny=size(C,1);
for kr=1:ny
   for kc=1:nx
      if isnan(C(kr,kc)),C(kr,kc)=th(s);s=s+1;end
   end
end
D=mod.ds;
for kr=1:ny
   for kc=1:nu
      if isnan(D(kr,kc)),D(kr,kc)=th(s);s=s+1;end
   end
end
K=mod.ks;
for kr=1:nx
   for kc=1:ny
      if isnan(K(kr,kc)),K(kr,kc)=th(s);s=s+1;end
   end
end

X0=mod.x0s;
for kr=1:nx
   if isnan(X0(kr)),X0(kr)=th(s);s=s+1;end
end
 
 