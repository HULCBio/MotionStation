function [A,B,dA,dB]=arxdata(sys)
%ARXDATA returns the ARX-polynomials for a multivariable IDARX model.
%
%   [A,B] = ARXDATA(M)
%
%   M: The IDARX model object. See help IDARX.
%
%   A, B : ny-by-ny-by-n and ny-b-ynu-by-m matrices defining 
%   the ARX-structure. (ny: number of outputs, nu: number of inputs)
%
%   y(t) + A1 y(t-1) + .. + An y(t-n) = 
%          = B0 u(t) + ..+ B1 u(t-1) + .. + Bm u(t-m)
%
%          A(:,:,k+1) = Ak,  B(:,:,k+1) = Bk
%
%
%   With [A,B,dA,dB] = ARXDATA(M), also the standard deviations
%   of A and B, i.e. dA and dB are computed.
%
%   See also IDARX, and ARX

%   L. Ljung 10-2-90,3-13-93
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.7 $ $Date: 2001/04/06 14:21:57 $

if nargin < 1
   disp('Usage: [A,B,dA,dB] = ARXDATA(M)')
   return
end

 
 
 [as,bs,cs,ds]=ssdata(sys);
 ms = getarxms(sys.na,sys.nb,sys.nk); %%LL%% Fix this simpler
 [ny,nz]=size(cs);[nx,nz]=size(as);[nz,nu]=size(bs);
 na = max(max(sys.na)');
 nb = max(max(sys.nb)');
 A2=[eye(ny) -cs(:,1:na*ny)];
if nu>0,
   B2=[ds cs(:,na*ny+1:nx)];
else 
   B2=[];B=[];
end
if na==0 & ~any(isnan(ms.Cs));%arg(:,nx+nu+1:nx+nu+ny))),
   B2=ds;
end
for kk=1:na+1
   A(:,:,kk)=A2(:,ny*(kk-1)+1:ny*kk);
end
if nu>0
for kk=1:size(B2,2)/nu
   B(:,:,kk)=B2(:,nu*(kk-1)+1:nu*kk);
end
end
if nargout>2
  cov = pvget(sys,'CovarianceMatrix');
  if isempty(cov)|ischar(cov)
    dA=[];dB=[];
    return
  end
  
  sys=parset(sys,pvget(sys,'ParameterVector')+sqrt(diag(cov)));
  [A1,B1]=arxdata(sys);
  dA=abs(A-A1);
  dB=abs(B-B1);
end


 
