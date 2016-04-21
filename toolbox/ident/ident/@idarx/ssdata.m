function [A,B,C,D,K,X0,dA,dB,dC,dD,dK,dX0]=ssdata(sys)
%IDARX/SSDATA  Returns state-space matrices for IDARX models.
%
%   [A,B,C,D,K,X0] = SSDATA(M)
%
%   M is an IDARX model object.
%   The output are the matrices of the state-space model
%
%      x[k+1] = A x[k] + B u[k] + K e[k] ;      x[0] = X0
%        y[k] = C x[k] + D u[k] + e[k]
%
%  in   discrete time.  
%
%  [A,B,C,D,K,X0,dA,dB,dC,dD,dK,dX0] = SSDATA(M)
%
%  returns also the model uncertainties (standard deviations) dA etc.

%   L. Ljung 10-2-90,11-25-93
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.6 $ $Date: 2001/04/06 14:21:59 $

ms = getarxms(sys.na,sys.nb,sys.nk);
nx = size(ms.As,1);
[ny,nu]=size(ms.Ds);
na = max(max(sys.na)');
th = pvget(sys.idmodel,'ParameterVector');
A=ms.As;%mod(1:nx,1:nx);
s=1;
for kr=1:nx
        for kc=1:nx
        if isnan(A(kr,kc)), A(kr,kc)=th(s);s=s+1;end
        end
end
B= ms.Bs; 
for kr=1:nx
        for kc=1:nu
        if isnan(B(kr,kc)),B(kr,kc)=th(s);s=s+1;end
        end
end
if na==0
C=ms.Cs; 
for kr=1:ny
        for kc=1:nx
        if isnan(C(kr,kc)),C(kr,kc)=th(s);s=s+1;end
        end
end
D=ms.Ds; 
for kr=1:ny
        for kc=1:nu
        if isnan(D(kr,kc)),D(kr,kc)=th(s);s=s+1;end
        end
end
else
C=A(1:ny,1:nx);
D=B(1:ny,:);
end
K=ms.Ks; 
for kr=1:nx
        for kc=1:ny
        if isnan(K(kr,kc)),K(kr,kc)=th(s);s=s+1;end
        end
end

X0=ms.X0s; 
for kr=1:nx
        if isnan(X0(kr)),X0(kr)=th(s);s=s+1;end
end
 if nargout>6
   cov = pvget(sys.idmodel,'CovarianceMatrix');
   if isempty(cov)
     dA = []; dB = []; dC = [];
     dD = []; dK = []; dX0 = [];
   else
     sys = parset(sys,th+sqrt(diag(cov)));
     [a1,b1,c1,d1,k1,x01] = ssdata(sys);
     dA = abs(A-a1); dB = abs(B-b1); dC = abs(C-c1);
     dD = abs(D-d1); dK = abs(K-k1); dX0 = abs(X0-x01);
   end
 end
